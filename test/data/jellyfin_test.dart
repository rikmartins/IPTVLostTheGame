import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iptv_app/data/local/models/epg_programme.dart';
import 'package:iptv_app/data/local/models/media_category.dart';
import 'package:iptv_app/data/profiles/profile.dart';
import 'package:iptv_app/data/remote/jellyfin/jellyfin_client.dart';
import 'package:iptv_app/data/remote/jellyfin/jellyfin_mappers.dart';
import 'package:iptv_app/data/repositories/auth_repository.dart';
import 'package:iptv_app/data/sources/credentials.dart';
import 'package:iptv_app/data/sources/source_exception.dart';

/// Servidor falso: responde por "MÉTODO host:porta/caminho". Um handler
/// pode devolver JSON, um código HTTP (int) ou lançar (sem ligação).
class _FakeServer implements HttpClientAdapter {
  _FakeServer(this.routes);

  final Map<String, Object? Function(RequestOptions request)> routes;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final uri = options.uri;
    final handler =
        routes['${options.method} ${uri.host}:${uri.port}${uri.path}'];
    if (handler == null) return ResponseBody.fromString('', 404);
    final body = handler(options);
    if (body is int) return ResponseBody.fromString('', body);
    return ResponseBody.fromString(
      jsonEncode(body),
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json; charset=utf-8'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Dio _dio(_FakeServer server) =>
    JellyfinClient.createDio()..httpClientAdapter = server;

const _credentials = JellyfinCredentials(
  serverUrl: 'http://nas:8096',
  username: 'rui',
  userId: 'u1',
  accessToken: 'tok',
  deviceId: 'dev1',
);

void main() {
  group('credenciais', () {
    test('JSON de ida e volta; perfis antigos sem "type" são Xtream', () {
      expect(SourceCredentials.fromJson(_credentials.toJson()), _credentials);
      const xtream = XtreamCredentials(
        serverUrl: 'http://iptv.pt:8080',
        username: 'ana',
        password: 'p',
      );
      final legacy = Map<String, dynamic>.of(xtream.toJson())..remove('type');
      expect(SourceCredentials.fromJson(legacy), xtream);
      expect(_credentials.isSameAccount(xtream), isFalse);
      expect(_credentials.toString(), isNot(contains('tok')));
    });

    test('endereço do Jellyfin: tira o /web do browser, mantém o proxy', () {
      expect(
        JellyfinCredentials.normalizeServerUrl(
          'http://192.168.1.10:8096/web/#/home.html',
        ),
        'http://192.168.1.10:8096',
      );
      expect(
        JellyfinCredentials.normalizeServerUrl('https://casa.pt/jellyfin/'),
        'https://casa.pt/jellyfin',
      );
      expect(JellyfinCredentials.serverCandidates('192.168.1.10'), [
        'http://192.168.1.10:8096',
        'http://192.168.1.10',
      ]);
      expect(JellyfinCredentials.serverCandidates('https://casa.pt'), [
        'https://casa.pt',
      ]);
      expect(JellyfinCredentials.serverCandidates('nas:8920'), [
        'http://nas:8920',
      ]);
    });

    test('dados memorizados antigos (sem "type") são Xtream', () {
      final login = RememberedLogin.fromJson({
        'serverUrl': 'http://iptv.pt',
        'username': 'ana',
        'password': 'p',
      });
      expect(login.kind, SourceKind.xtream);
      expect(RememberedLogin.fromJson(login.toJson()), login);
    });

    test('nome do perfil: o do servidor Jellyfin, senão o host', () {
      expect(defaultProfileName(_credentials, 0, serverName: ' Sala '), 'Sala');
      expect(defaultProfileName(_credentials, 0), 'nas');
    });
  });

  group('mapeamento', () {
    test('filme: ID em hash, poster pequeno, data de entrada', () {
      final movie = mapJellyfinMovie(
        {
          'Id': 'ABCDEF0123456789abcdef0123456789',
          'Name': 'Filme',
          'CommunityRating': 7.4,
          'DateCreated': '2024-03-01T20:15:00.0000000Z',
          'ImageTags': {'Primary': 'tag1'},
        },
        serverUrl: 'http://nas:8096',
        categoryId: 5,
        sortIndex: 2,
        syncStamp: 9,
      )!;
      expect(movie.id, jellyfinKey('abcdef01-2345-6789-abcd-ef0123456789'));
      expect(movie.remoteId, 'ABCDEF0123456789abcdef0123456789');
      expect(movie.rating, 7.4);
      expect(
        movie.addedAt,
        DateTime.utc(2024, 3, 1, 20, 15).millisecondsSinceEpoch ~/ 1000,
      );
      expect(
        movie.poster,
        'http://nas:8096/Items/ABCDEF0123456789abcdef0123456789/Images/'
        'Primary?maxHeight=600&quality=90&tag=tag1',
      );
      expect(
        mapJellyfinMovie(
          const {'Name': 'Sem ID'},
          serverUrl: '',
          categoryId: 0,
          sortIndex: 0,
          syncStamp: 0,
        ),
        isNull,
      );
    });

    test('série: "atualizada" pela data do último episódio', () {
      final series = mapJellyfinSeries(
        {
          'Id': 's1',
          'Name': 'Série',
          'Overview': 'Enredo',
          'Genres': ['Drama', 'Crime'],
          'ProductionYear': 2019,
          'DateCreated': '2020-01-01T00:00:00Z',
          'DateLastMediaAdded': '2026-10-01T00:00:00Z',
        },
        serverUrl: 'http://nas:8096',
        categoryId: 1,
        sortIndex: 0,
        syncStamp: 0,
      )!;
      expect(series.genre, 'Drama, Crime');
      expect(series.releaseDate, '2019');
      expect(series.plot, 'Enredo');
      expect(series.cover, isNull);
      expect(
        series.lastModified,
        DateTime.utc(2026, 10).millisecondsSinceEpoch ~/ 1000,
      );
    });

    test('canal: sem grupo, número e chave EPG a partir do ID', () {
      final channel = mapJellyfinChannel(
        {'Id': 'C-1', 'Name': 'RTP1', 'ChannelNumber': '5.1'},
        serverUrl: 'http://nas:8096',
        sortIndex: 0,
        syncStamp: 0,
      )!;
      expect(channel.number, 5);
      expect(channel.categoryId, kNoCategory);
      expect(channel.epgChannelId, 'c1');

      final programme = mapJellyfinProgramme({
        'ChannelId': 'c1',
        'Name': 'Série',
        'EpisodeTitle': 'Episódio 3',
        'StartDate': '2026-11-05T20:00:00.0000000Z',
        'EndDate': '2026-11-05T21:00:00.0000000Z',
      }, syncStamp: 0)!;
      expect(programme.channelKey, EpgProgramme.keyFor(channel.epgChannelId!));
      expect(programme.title, 'Série: Episódio 3');
      expect(programme.start, DateTime.utc(2026, 11, 5, 20));
    });

    test('canais ordenam pelo número; sem número no fim', () {
      final keys = [
        {'ChannelNumber': '10'},
        {'Name': 'sem número'},
        {'ChannelNumber': '2.1'},
      ].map(channelSortKey).toList();
      expect(keys, [10, double.infinity, 2.1]);
    });

    test('episódios: temporada, progresso e vistos', () {
      final episodes = mapJellyfinEpisodes([
        {
          'Id': 'e2',
          'Name': 'Dois',
          'ParentIndexNumber': 1,
          'IndexNumber': 2,
          'RunTimeTicks': 27120000000,
          'UserData': {'PlaybackPositionTicks': 6000000000, 'Played': false},
        },
        {
          'Id': 'e1',
          'Name': 'Um',
          'ParentIndexNumber': 1,
          'IndexNumber': 1,
          'UserData': {'Played': true},
        },
      ], serverUrl: 'http://nas:8096');
      expect(episodes.map((e) => e.id), ['e1', 'e2']);
      expect(episodes.first.watched, isTrue);
      expect(episodes.last.duration, '00:45:12');
      expect(episodes.last.resumeAt, const Duration(minutes: 10));
    });
  });

  group('cliente', () {
    test('login: sem porta tenta a 8096 e guarda o endereço final', () async {
      final server = _FakeServer({
        'GET 192.168.1.10:8096/System/Info/Public': (_) => {
          'Id': 'srv',
          'ServerName': 'Sala',
        },
        'POST 192.168.1.10:8096/Users/AuthenticateByName': (request) {
          final body = request.data as Map<String, dynamic>;
          expect(body, {'Username': 'rui', 'Pw': ''});
          expect(
            request.headers[HttpHeaders.authorizationHeader],
            allOf(contains('DeviceId="dev9"'), isNot(contains('Token='))),
          );
          return {
            'AccessToken': 'novo',
            'User': {'Id': 'u1', 'Name': 'Rui'},
          };
        },
      });

      final login = await JellyfinClient.signIn(
        server: ' 192.168.1.10 ',
        username: 'rui',
        password: '',
        deviceId: 'dev9',
        dio: _dio(server),
      );
      expect(login.credentials.serverUrl, 'http://192.168.1.10:8096');
      expect(login.credentials.accessToken, 'novo');
      expect(login.credentials.username, 'Rui');
      expect(login.serverName, 'Sala');
    });

    test('login: palavra-passe errada e endereço que não é Jellyfin', () {
      final wrong = _FakeServer({
        'GET nas:8096/System/Info/Public': (_) => {'Id': 'srv'},
        'POST nas:8096/Users/AuthenticateByName': (_) => 401,
      });
      expect(
        JellyfinClient.signIn(
          server: 'http://nas:8096',
          username: 'rui',
          password: 'x',
          deviceId: 'd',
          dio: _dio(wrong),
        ),
        throwsA(
          isA<SourceException>().having(
            (e) => e.kind,
            'kind',
            SourceErrorKind.invalidCredentials,
          ),
        ),
      );

      final notJellyfin = _FakeServer({});
      expect(
        JellyfinClient.signIn(
          server: 'http://router.lan',
          username: 'rui',
          password: 'x',
          deviceId: 'd',
          dio: _dio(notJellyfin),
        ),
        throwsA(
          isA<SourceException>().having(
            (e) => e.message,
            'message',
            contains('Jellyfin'),
          ),
        ),
      );
    });

    test('bibliotecas: servidores antigos sem /UserViews', () async {
      final server = _FakeServer({
        'GET nas:8096/Users/u1/Views': (request) {
          expect(
            request.headers[HttpHeaders.authorizationHeader],
            contains('Token="tok"'),
          );
          return {
            'Items': [
              {'Id': 'v1', 'Name': 'Filmes', 'CollectionType': 'movies'},
              {'Id': 'v2', 'Name': 'TV', 'CollectionType': 'livetv'},
              {'Id': 'v3', 'Name': 'Misto'},
            ],
          };
        },
      });
      final views = await JellyfinClient(
        _credentials,
        dio: _dio(server),
      ).views();
      expect(views.map((v) => v.name), ['Filmes', 'TV', 'Misto']);
      expect(views[1].isLiveTv, isTrue);
      expect(views[2].hasMovies && views[2].hasSeries, isTrue);
    });

    test('itens aos lotes até um lote incompleto', () async {
      final starts = <String>[];
      final server = _FakeServer({
        'GET nas:8096/Items': (request) {
          final query = request.uri.queryParameters;
          starts.add(query['StartIndex']!);
          expect(query['ParentId'], 'v1');
          expect(query['IncludeItemTypes'], 'Movie');
          final start = int.parse(query['StartIndex']!);
          final count = start == 0 ? 500 : 3;
          return {
            'Items': [
              for (var i = 0; i < count; i++) {'Id': 'm${start + i}'},
            ],
          };
        },
      });
      final pages = await JellyfinClient(_credentials, dio: _dio(server))
          .items(libraryId: 'v1', itemType: 'Movie', fields: 'DateCreated')
          .toList();
      expect(pages.map((p) => p.length), [500, 3]);
      expect(starts, ['0', '500']);
    });

    test('canal: abre no servidor e o stream leva o sintonizador', () async {
      final server = _FakeServer({
        'POST nas:8096/Items/c1/PlaybackInfo': (request) {
          final body = request.data as Map<String, dynamic>;
          expect(body['AutoOpenLiveStream'], isTrue);
          return {
            'PlaySessionId': 'ps',
            'MediaSources': [
              {
                'Id': 'ms',
                'LiveStreamId': 'ls',
                'SupportsDirectStream': true,
                'TranscodingUrl': '/videos/c1/master.m3u8?x=1',
              },
            ],
          };
        },
        'POST nas:8096/Sessions/Playing/Stopped': (request) {
          final body = request.data as Map<String, dynamic>;
          expect(body['LiveStreamId'], 'ls');
          expect(body['PositionTicks'], 0);
          return 204;
        },
      });
      final client = JellyfinClient(_credentials, dio: _dio(server));
      final stream = await client.openLiveStream('c1');

      final url = Uri.parse(stream.url);
      expect(url.path, '/Videos/c1/stream');
      expect(url.queryParameters, {
        'static': 'true',
        'MediaSourceId': 'ms',
        'LiveStreamId': 'ls',
        'PlaySessionId': 'ps',
        'DeviceId': 'dev1',
        'ApiKey': 'tok',
      });
      expect(stream.isLive, isTrue);

      await client.report(PlaybackEvent.stopped, stream, Duration.zero);
      expect(server.requests.last.uri.path, '/Sessions/Playing/Stopped');
    });

    test('canal convertido: TranscodingUrl ganha o token', () async {
      final server = _FakeServer({
        'POST nas:8096/Items/c1/PlaybackInfo': (_) => {
          'MediaSources': [
            {
              'Id': 'ms',
              'LiveStreamId': 'ls',
              'SupportsDirectStream': false,
              'TranscodingUrl': '/videos/c1/master.m3u8?MediaSourceId=ms',
            },
          ],
        },
      });
      final stream = await JellyfinClient(
        _credentials,
        dio: _dio(server),
      ).openLiveStream('c1');
      expect(
        stream.url,
        'http://nas:8096/videos/c1/master.m3u8?MediaSourceId=ms&ApiKey=tok',
      );
      expect(stream.transcoding, isTrue);
    });

    test('canal recusado: a mensagem diz porquê', () {
      final server = _FakeServer({
        'POST nas:8096/Items/c1/PlaybackInfo': (_) => {
          'ErrorCode': 'RateLimitExceeded',
          'MediaSources': <Object>[],
        },
      });
      expect(
        JellyfinClient(_credentials, dio: _dio(server)).openLiveStream('c1'),
        throwsA(
          isA<SourceException>().having(
            (e) => e.message,
            'message',
            contains('sem sintonizadores livres'),
          ),
        ),
      );
    });

    test('token revogado: pede para entrar outra vez', () {
      final server = _FakeServer({'GET nas:8096/Users/u1': (_) => 401});
      expect(
        JellyfinClient(_credentials, dio: _dio(server)).currentUser(),
        throwsA(
          isA<SourceException>().having(
            (e) => e.kind,
            'kind',
            SourceErrorKind.sessionExpired,
          ),
        ),
      );
    });

    test('progresso de um filme em ticks', () async {
      final server = _FakeServer({
        'POST nas:8096/Sessions/Playing/Progress': (request) {
          final body = request.data as Map<String, dynamic>;
          expect(body['ItemId'], 'm1');
          expect(body['PositionTicks'], 90 * 10000000);
          expect(body['IsPaused'], isTrue);
          expect(body['EventName'], 'TimeUpdate');
          expect(body.containsKey('LiveStreamId'), isFalse);
          return 204;
        },
      });
      final client = JellyfinClient(_credentials, dio: _dio(server));
      await client.report(
        PlaybackEvent.progress,
        client.vodStream('m1'),
        const Duration(seconds: 90),
        paused: true,
      );
      expect(server.requests, hasLength(1));
    });

    test('cabeçalho de autenticação no formato do Jellyfin', () {
      final header = JellyfinClient.authorization(deviceId: 'd1', token: 't1');
      expect(header, startsWith('MediaBrowser Client="SoPro Media", '));
      expect(header, contains('DeviceId="d1"'));
      expect(header, endsWith('Token="t1"'));
    });
  });
}
