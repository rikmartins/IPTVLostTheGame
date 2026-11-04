import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../../core/utils/json_object_splitter.dart';
import '../../../core/utils/json_values.dart';
import '../../local/models/account_info.dart';
import 'series_episode.dart';
import 'xtream_credentials.dart';
import 'xtream_exception.dart';
import 'xtream_mappers.dart';

/// Ações de lista do `player_api.php`.
abstract final class XtreamAction {
  static const liveCategories = 'get_live_categories';
  static const liveStreams = 'get_live_streams';
  static const vodCategories = 'get_vod_categories';
  static const vodStreams = 'get_vod_streams';
  static const seriesCategories = 'get_series_categories';
  static const series = 'get_series';
}

// Decoders fundidos: a VM faz parse direto dos bytes UTF-8, sem String
// intermédia por objeto.
final _jsonUtf8 = const Utf8Decoder(
  allowMalformed: true,
).fuse(const JsonDecoder());

/// Cliente da Xtream Codes API.
///
/// Só fala com a rede; não sabe nada do Isar. Corre tanto no isolate da UI
/// (login) como no isolate de sincronização.
///
/// Nunca adicionar um `LogInterceptor` ao [Dio] daqui: a password do Xtream
/// vai na query string de todos os pedidos.
class XtreamApi {
  XtreamApi(this.credentials, {Dio? dio}) : _dio = dio ?? createDio();

  /// Muitos painéis bloqueiam o User-Agent por omissão do dart:io
  /// ("Dart/3.x (dart:io)").
  static const defaultUserAgent = 'okhttp/4.12.0';

  static Dio createDio({String userAgent = defaultUserAgent}) {
    return Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 12),
        // No Dio 5 é o intervalo máximo *entre chunks*, não o total: um
        // catálogo grande não é cortado enquanto continuarem a chegar dados.
        receiveTimeout: const Duration(seconds: 45),
        headers: {HttpHeaders.userAgentHeader: userAgent},
        // Muitos painéis servem JSON como text/html, por isso o decode é
        // sempre feito aqui e nunca pelo transformer do Dio.
        responseType: ResponseType.bytes,
      ),
    );
  }

  final XtreamCredentials credentials;
  final Dio _dio;

  /// Valida as credenciais e devolve o estado da conta.
  Future<AccountInfo> authenticate({CancelToken? cancelToken}) async {
    final body = await _getJson(_playerApi(), cancelToken);
    // Painéis antigos respondem 200 com corpo vazio a credenciais erradas.
    if (body == null) {
      throw const XtreamException(XtreamErrorKind.invalidCredentials);
    }
    if (body is! Map<String, dynamic>) {
      throw const XtreamException(XtreamErrorKind.invalidResponse);
    }

    final user = body['user_info'];
    if (user is! Map<String, dynamic>) {
      throw const XtreamException(XtreamErrorKind.invalidCredentials);
    }
    if (asInt(user['auth']) != 1) {
      throw XtreamException(
        XtreamErrorKind.invalidCredentials,
        asString(user['message']),
      );
    }

    final status = asString(user['status']);
    if (status != null && status.toLowerCase() != 'active') {
      throw XtreamException(XtreamErrorKind.accountInactive, status);
    }

    final server = body['server_info'];
    return mapAccountInfo(user, server is Map<String, dynamic> ? server : null);
  }

  /// Episódios de uma série (`get_series_info`), pedidos quando o
  /// utilizador abre a série: sincronizar os de 50k séries seriam 50k
  /// pedidos.
  Future<List<SeriesEpisode>> seriesEpisodes(
    int seriesId, {
    CancelToken? cancelToken,
  }) async {
    final body = await _getJson(
      _playerApi({'action': 'get_series_info', 'series_id': '$seriesId'}),
      cancelToken,
    );
    return body is Map<String, dynamic> ? mapSeriesEpisodes(body) : const [];
  }

  /// Descarrega uma ação de lista ([XtreamAction]) e emite os itens um a um,
  /// à medida que chegam da rede.
  ///
  /// A memória usada não depende do tamanho do catálogo: a resposta nunca
  /// é carregada inteira (ver [splitJsonObjects]).
  Stream<Map<String, dynamic>> streamList(
    String action, {
    CancelToken? cancelToken,
  }) async* {
    final source = _download(_playerApi({'action': action}), cancelToken);

    await for (final bytes in splitJsonObjects(source)) {
      final Object? item;
      try {
        item = _jsonUtf8.convert(bytes);
      } on FormatException {
        continue; // Um item corrompido não deve deitar abaixo o catálogo.
      }
      if (item is Map<String, dynamic>) yield item;
    }
  }

  /// Bytes do guia XMLTV completo (`xmltv.php`), em streaming.
  Stream<Uint8List> xmltv({CancelToken? cancelToken}) {
    final uri = Uri.parse(
      '${credentials.serverUrl}/xmltv.php',
    ).replace(queryParameters: _authQuery);
    return _download(uri, cancelToken);
  }

  void close() => _dio.close(force: true);

  // -------------------------------------------------------------------------

  Map<String, String> get _authQuery => {
    'username': credentials.username,
    'password': credentials.password,
  };

  Uri _playerApi([Map<String, String> extra = const {}]) {
    return Uri.parse(
      '${credentials.serverUrl}/player_api.php',
    ).replace(queryParameters: {..._authQuery, ...extra});
  }

  /// GET de uma resposta pequena, decodificada de uma vez. `null` = corpo
  /// vazio.
  Future<Object?> _getJson(Uri uri, CancelToken? cancelToken) async {
    try {
      final response = await _dio.getUri<List<int>>(
        uri,
        cancelToken: cancelToken,
      );
      final bytes = response.data;
      if (bytes == null || bytes.isEmpty) return null;
      return _jsonUtf8.convert(bytes);
    } on DioException catch (e) {
      throw XtreamException.fromDio(e);
    } on FormatException {
      throw const XtreamException(XtreamErrorKind.invalidResponse);
    }
  }

  /// GET em streaming com os erros já convertidos em [XtreamException].
  ///
  /// `await for` em vez de `yield*` de propósito: com `yield*` os erros do
  /// stream de origem passavam ao lado deste try/catch.
  Stream<Uint8List> _download(Uri uri, CancelToken? cancelToken) async* {
    try {
      final response = await _dio.getUri<ResponseBody>(
        uri,
        options: Options(responseType: ResponseType.stream),
        cancelToken: cancelToken,
      );
      await for (final chunk in response.data!.stream) {
        yield chunk;
      }
    } on DioException catch (e) {
      throw XtreamException.fromDio(e);
    } on IOException catch (e) {
      throw XtreamException(XtreamErrorKind.network, scrubSecrets('$e'));
    }
  }
}
