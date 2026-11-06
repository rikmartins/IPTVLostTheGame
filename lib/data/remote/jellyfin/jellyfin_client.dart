import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/config/app_config.dart';
import '../../../core/utils/json_values.dart';
import '../../local/models/account_info.dart';
import '../../sources/credentials.dart';
import '../../sources/series_episode.dart';
import '../../sources/source_exception.dart';
import 'jellyfin_mappers.dart';

const _notFound = 'Endereço não encontrado (o servidor é Jellyfin?)';

/// Resultado de um login bem-sucedido.
@immutable
class JellyfinLogin {
  const JellyfinLogin({
    required this.credentials,
    required this.account,
    this.serverName,
  });

  final JellyfinCredentials credentials;
  final AccountInfo account;

  /// O nome que o servidor dá a si próprio (Painel → Geral).
  final String? serverName;
}

/// Um stream pronto a tocar, com o que é preciso para avisar o servidor.
@immutable
class JellyfinStream {
  const JellyfinStream({
    required this.url,
    required this.itemId,
    this.mediaSourceId,
    this.liveStreamId,
    this.playSessionId,
    this.transcoding = false,
  });

  final String url;
  final String itemId;
  final String? mediaSourceId;

  /// TV em direto: o sintonizador que o servidor abriu para nós. Fica
  /// ocupado até se dizer que a reprodução parou.
  final String? liveStreamId;
  final String? playSessionId;
  final bool transcoding;

  bool get isLive => liveStreamId != null;
}

enum PlaybackEvent { started, progress, stopped }

/// Cliente da API do Jellyfin.
///
/// Só fala com a rede; não sabe nada do Isar. Corre no isolate da UI
/// (episódios, abrir streams, progresso) e no de sincronização.
///
/// O token vai no cabeçalho `Authorization` em todos os pedidos à API. Só
/// os URLs dos streams o levam na query string (o mpv não manda os
/// cabeçalhos para os segmentos HLS de todos os servidores).
class JellyfinClient {
  JellyfinClient(this.credentials, {Dio? dio}) : _dio = dio ?? createDio();

  static const clientName = 'SoPro Media';

  /// Informativo: aparece no painel do servidor (Dispositivos).
  static const clientVersion = '1';

  /// O mpv reproduz praticamente tudo; isto só serve para o servidor não
  /// decidir converter por causa do débito.
  static const _maxBitrate = 200000000;

  static Dio createDio() {
    return Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 12),
        receiveTimeout: const Duration(seconds: 45),
        responseType: ResponseType.json,
        headers: {HttpHeaders.acceptHeader: 'application/json'},
      ),
    );
  }

  /// Nome do dispositivo no painel do servidor. No computador é o nome da
  /// máquina, para distinguir vários.
  static String get deviceName {
    if (Platform.isAndroid) return isAndroidTvBuild ? 'Android TV' : 'Android';
    if (Platform.isIOS) return 'iOS';
    final host = Platform.localHostname.replaceAll(RegExp(r'[^\w .-]'), '');
    return host.isEmpty ? Platform.operatingSystem : host;
  }

  /// Cabeçalho de autenticação do Jellyfin (esquema "MediaBrowser").
  static String authorization({required String deviceId, String? token}) {
    final fields = {
      'Client': clientName,
      'Device': deviceName,
      'DeviceId': deviceId,
      'Version': clientVersion,
      'Token': ?token,
    };
    final pairs = fields.entries.map((e) => '${e.key}="${e.value}"');
    return 'MediaBrowser ${pairs.join(', ')}';
  }

  /// Valida o servidor e o utilizador e devolve uma sessão nova. Lança
  /// [SourceException] com a mensagem a mostrar.
  static Future<JellyfinLogin> signIn({
    required String server,
    required String username,
    required String password,
    required String deviceId,
    Dio? dio,
  }) async {
    final http = dio ?? createDio();
    try {
      final (serverUrl, info) = await _findServer(http, server);

      final Object? body;
      try {
        final response = await http.post<Object?>(
          '$serverUrl/Users/AuthenticateByName',
          data: {'Username': username.trim(), 'Pw': password},
          options: Options(
            headers: {
              HttpHeaders.authorizationHeader: authorization(
                deviceId: deviceId,
              ),
            },
          ),
        );
        body = response.data;
      } on DioException catch (e) {
        throw SourceException.fromDio(e, notFound: _notFound);
      }

      final user = body is Map<String, dynamic> ? body['User'] : null;
      final token = body is Map<String, dynamic>
          ? asString(body['AccessToken'])
          : null;
      final userId = user is Map<String, dynamic> ? asString(user['Id']) : null;
      if (user is! Map<String, dynamic> || token == null || userId == null) {
        throw const SourceException(SourceErrorKind.invalidResponse);
      }

      final account = mapJellyfinAccount(user);
      if (account.status != 'Active') {
        throw const SourceException(SourceErrorKind.accountInactive);
      }
      return JellyfinLogin(
        credentials: JellyfinCredentials(
          serverUrl: serverUrl,
          // O nome como o servidor o guarda: é o que identifica a conta.
          username: account.username.isEmpty
              ? username.trim()
              : account.username,
          userId: userId,
          accessToken: token,
          deviceId: deviceId,
        ),
        account: account,
        serverName: asString(info['ServerName']),
      );
    } finally {
      if (dio == null) http.close(force: true);
    }
  }

  /// O primeiro endereço candidato que responde como um Jellyfin. Segue
  /// redirecionamentos (http → https) e fica com o endereço final.
  static Future<(String, Map<String, dynamic>)> _findServer(
    Dio http,
    String input,
  ) async {
    const probe = '/System/Info/Public';
    SourceException? firstError;
    for (final candidate in JellyfinCredentials.serverCandidates(input)) {
      try {
        final response = await http.get<Object?>('$candidate$probe');
        final body = response.data;
        if (body is Map<String, dynamic> && asString(body['Id']) != null) {
          final real = response.realUri;
          final path = real.path;
          final base = path.toLowerCase().endsWith(probe.toLowerCase())
              ? Uri(
                  scheme: real.scheme,
                  host: real.host,
                  port: real.hasPort ? real.port : null,
                  path: path.substring(0, path.length - probe.length),
                ).toString()
              : candidate;
          return (base, body);
        }
        firstError ??= const SourceException(
          SourceErrorKind.invalidResponse,
          'o endereço não é de um servidor Jellyfin',
        );
      } on DioException catch (e) {
        firstError ??= SourceException.fromDio(e, notFound: _notFound);
      }
    }
    throw firstError!;
  }

  final JellyfinCredentials credentials;
  final Dio _dio;

  late final _auth = Options(
    headers: {
      HttpHeaders.authorizationHeader: authorization(
        deviceId: credentials.deviceId,
        token: credentials.accessToken,
      ),
    },
  );

  String get _userId => credentials.userId;

  /// Confirma que o token ainda vale e devolve o estado da conta.
  Future<AccountInfo> currentUser({CancelToken? cancelToken}) async {
    final body = await _get('/Users/$_userId', cancelToken: cancelToken);
    if (body is! Map<String, dynamic>) {
      throw const SourceException(SourceErrorKind.invalidResponse);
    }
    final account = mapJellyfinAccount(body);
    if (account.status != 'Active') {
      throw const SourceException(SourceErrorKind.accountInactive);
    }
    return account;
  }

  /// As bibliotecas do utilizador, pela ordem que ele escolheu.
  Future<List<JellyfinView>> views({CancelToken? cancelToken}) async {
    final body =
        await _get(
          '/UserViews',
          query: {'userId': _userId},
          cancelToken: cancelToken,
          nullIfNotFound: true,
        ) ??
        // Servidores anteriores à 10.9.
        await _get('/Users/$_userId/Views', cancelToken: cancelToken);
    return [for (final json in jellyfinItems(body)) ?mapView(json)];
  }

  /// Itens de uma biblioteca ([itemType]: "Movie", "Series"), aos lotes.
  Stream<List<Map<String, dynamic>>> items({
    required String libraryId,
    required String itemType,
    required String fields,
    CancelToken? cancelToken,
  }) {
    return _pages('/Items', {
      'userId': _userId,
      'ParentId': libraryId,
      'IncludeItemTypes': itemType,
      'Recursive': 'true',
      'Fields': fields,
      'SortBy': 'SortName',
      'SortOrder': 'Ascending',
      'EnableImageTypes': 'Primary',
      'ImageTypeLimit': '1',
      'EnableUserData': 'false',
    }, cancelToken: cancelToken);
  }

  Stream<List<Map<String, dynamic>>> liveChannels({CancelToken? cancelToken}) {
    return _pages('/LiveTv/Channels', {
      'userId': _userId,
      'EnableImageTypes': 'Primary',
      'ImageTypeLimit': '1',
      'EnableUserData': 'false',
      'AddCurrentProgram': 'false',
    }, cancelToken: cancelToken);
  }

  /// Guia de todos os canais entre [from] e [until].
  Stream<List<Map<String, dynamic>>> programmes({
    required DateTime from,
    required DateTime until,
    CancelToken? cancelToken,
  }) {
    return _pages(
      '/LiveTv/Programs',
      {
        'UserId': _userId,
        'MinEndDate': from.toUtc().toIso8601String(),
        'MaxStartDate': until.toUtc().toIso8601String(),
        'Fields': 'Overview',
        'SortBy': 'StartDate',
        'EnableImages': 'false',
        'EnableUserData': 'false',
      },
      pageSize: 2000,
      cancelToken: cancelToken,
    );
  }

  /// Episódios de uma série, com o progresso do utilizador.
  Future<List<SeriesEpisode>> episodes(String seriesId) async {
    final body = await _get(
      '/Shows/$seriesId/Episodes',
      query: {
        'userId': _userId,
        'Fields': 'Overview',
        // Episódios que o servidor sabe que existem mas não tem.
        'IsMissing': 'false',
        'EnableImageTypes': 'Primary',
        'ImageTypeLimit': '1',
        'EnableUserData': 'true',
      },
    );
    return mapJellyfinEpisodes(
      jellyfinItems(body),
      serverUrl: credentials.serverUrl,
    );
  }

  /// Onde o utilizador ficou num filme (pode ter visto noutro aparelho).
  Future<Duration?> resumePosition(String itemId) async {
    final body = await _get(
      '/Items',
      query: {
        'userId': _userId,
        'Ids': itemId,
        'EnableImages': 'false',
        'EnableUserData': 'true',
      },
    );
    final items = jellyfinItems(body);
    return items.isEmpty ? null : resumePositionOf(items.first);
  }

  /// Ficheiro original, sem conversão: o mpv lê-o diretamente.
  JellyfinStream vodStream(String itemId) => JellyfinStream(
    url: streamUrl(itemId),
    itemId: itemId,
    mediaSourceId: itemId,
  );

  /// Abre um canal no servidor (ocupa um sintonizador até
  /// [report] com [PlaybackEvent.stopped]).
  Future<JellyfinStream> openLiveStream(String channelId) async {
    final body = await _post(
      '/Items/$channelId/PlaybackInfo',
      query: {'userId': _userId},
      data: {
        'UserId': _userId,
        'IsPlayback': true,
        'AutoOpenLiveStream': true,
        'EnableDirectPlay': true,
        'EnableDirectStream': true,
        'EnableTranscoding': true,
        'AllowVideoStreamCopy': true,
        'AllowAudioStreamCopy': true,
        'MaxStreamingBitrate': _maxBitrate,
        'DeviceProfile': _deviceProfile,
      },
    );
    if (body is! Map<String, dynamic>) {
      throw const SourceException(SourceErrorKind.invalidResponse);
    }
    final error = asString(body['ErrorCode']);
    if (error != null) {
      throw SourceException(SourceErrorKind.server, _playbackError(error));
    }
    final sources = jellyfinItems(body['MediaSources']);
    if (sources.isEmpty) {
      throw const SourceException(
        SourceErrorKind.server,
        'o canal não está disponível',
      );
    }

    final source = sources.first;
    final playSessionId = asString(body['PlaySessionId']);
    final mediaSourceId = asString(source['Id']);
    final liveStreamId = asString(source['LiveStreamId']);
    final transcodingUrl = asString(source['TranscodingUrl']);
    final direct =
        asBool(source['SupportsDirectStream']) ||
        asBool(source['SupportsDirectPlay']);

    return JellyfinStream(
      url: direct || transcodingUrl == null
          ? streamUrl(
              channelId,
              mediaSourceId: mediaSourceId,
              liveStreamId: liveStreamId,
              playSessionId: playSessionId,
            )
          : _withToken('${credentials.serverUrl}$transcodingUrl'),
      itemId: channelId,
      mediaSourceId: mediaSourceId,
      liveStreamId: liveStreamId,
      playSessionId: playSessionId,
      transcoding: !direct && transcodingUrl != null,
    );
  }

  /// URL do stream sem conversão ("static").
  @visibleForTesting
  String streamUrl(
    String itemId, {
    String? mediaSourceId,
    String? liveStreamId,
    String? playSessionId,
  }) {
    return Uri.parse('${credentials.serverUrl}/Videos/$itemId/stream')
        .replace(
          queryParameters: {
            'static': 'true',
            'MediaSourceId': ?mediaSourceId,
            'LiveStreamId': ?liveStreamId,
            'PlaySessionId': ?playSessionId,
            'DeviceId': credentials.deviceId,
            'ApiKey': credentials.accessToken,
          },
        )
        .toString();
  }

  /// Progresso para o "Continuar a ver" e o "visto" do servidor. Ao parar
  /// um canal, liberta também o sintonizador.
  Future<void> report(
    PlaybackEvent event,
    JellyfinStream stream,
    Duration position, {
    bool paused = false,
  }) async {
    await _post(
      switch (event) {
        PlaybackEvent.started => '/Sessions/Playing',
        PlaybackEvent.progress => '/Sessions/Playing/Progress',
        PlaybackEvent.stopped => '/Sessions/Playing/Stopped',
      },
      data: {
        'ItemId': stream.itemId,
        'MediaSourceId': stream.mediaSourceId ?? stream.itemId,
        'PlaySessionId': ?stream.playSessionId,
        'LiveStreamId': ?stream.liveStreamId,
        'PositionTicks': durationToTicks(position),
        'IsPaused': paused,
        'CanSeek': !stream.isLive,
        'PlayMethod': stream.transcoding ? 'Transcode' : 'DirectStream',
        if (event == PlaybackEvent.progress) 'EventName': 'TimeUpdate',
      },
    );
  }

  void close() => _dio.close(force: true);

  // -------------------------------------------------------------------------

  Stream<List<Map<String, dynamic>>> _pages(
    String path,
    Map<String, String> query, {
    int pageSize = 500,
    CancelToken? cancelToken,
  }) async* {
    var start = 0;
    while (true) {
      final body = await _get(
        path,
        query: {
          ...query,
          'StartIndex': '$start',
          'Limit': '$pageSize',
          'EnableTotalRecordCount': 'false',
        },
        cancelToken: cancelToken,
      );
      final page = jellyfinItems(body);
      if (page.isNotEmpty) yield page;
      if (page.length < pageSize) return;
      start += pageSize;
    }
  }

  Uri _uri(String path, Map<String, String> query) {
    final uri = Uri.parse('${credentials.serverUrl}$path');
    return query.isEmpty ? uri : uri.replace(queryParameters: query);
  }

  Future<Object?> _get(
    String path, {
    Map<String, String> query = const {},
    CancelToken? cancelToken,
    bool nullIfNotFound = false,
  }) async {
    try {
      final response = await _dio.getUri<Object?>(
        _uri(path, query),
        options: _auth,
        cancelToken: cancelToken,
      );
      return response.data;
    } on DioException catch (e) {
      if (nullIfNotFound && e.response?.statusCode == 404) return null;
      throw _error(e);
    }
  }

  Future<Object?> _post(
    String path, {
    Map<String, String> query = const {},
    Object? data,
  }) async {
    try {
      final response = await _dio.postUri<Object?>(
        _uri(path, query),
        data: data,
        options: _auth,
      );
      return response.data;
    } on DioException catch (e) {
      throw _error(e);
    }
  }

  static SourceException _error(DioException e) {
    if (e.response?.statusCode == 403) {
      return const SourceException(
        SourceErrorKind.server,
        'a conta não tem permissão para isto',
      );
    }
    return SourceException.fromDio(
      e,
      notFound: _notFound,
      unauthorized: SourceErrorKind.sessionExpired,
    );
  }

  /// TranscodingUrl do servidor: as versões mais antigas não incluem o
  /// token.
  String _withToken(String url) {
    final uri = Uri.parse(url);
    final query = uri.queryParameters.keys.map((k) => k.toLowerCase());
    if (query.contains('apikey') || query.contains('api_key')) return url;
    return uri
        .replace(
          queryParameters: {
            ...uri.queryParameters,
            'ApiKey': credentials.accessToken,
          },
        )
        .toString();
  }

  static String _playbackError(String code) => switch (code) {
    'NotAllowed' => 'a conta não tem permissão para ver este canal',
    'NoCompatibleStream' => 'formato do canal não suportado',
    'RateLimitExceeded' => 'sem sintonizadores livres',
    _ => code,
  };
}

/// O que este player aceita sem conversão: tudo (é o mpv). Se o servidor
/// insistir em converter (ex.: limite de débito configurado para o
/// utilizador), pede HLS com H.264/HEVC.
const _deviceProfile = <String, Object>{
  'Name': 'SoPro Media (mpv)',
  'MaxStreamingBitrate': JellyfinClient._maxBitrate,
  'MaxStaticBitrate': JellyfinClient._maxBitrate,
  'DirectPlayProfiles': [
    {'Type': 'Video'},
    {'Type': 'Audio'},
  ],
  'TranscodingProfiles': [
    {
      'Container': 'ts',
      'Type': 'Video',
      'Protocol': 'hls',
      'Context': 'Streaming',
      'VideoCodec': 'h264,hevc',
      'AudioCodec': 'aac,mp3,ac3,eac3',
      'MaxAudioChannels': '6',
      'BreakOnNonKeyFrames': true,
    },
    {
      'Container': 'mp3',
      'Type': 'Audio',
      'Protocol': 'http',
      'Context': 'Streaming',
      'AudioCodec': 'mp3',
    },
  ],
  'ContainerProfiles': <Object>[],
  'CodecProfiles': <Object>[],
  'SubtitleProfiles': <Object>[],
};
