import 'dart:convert';
import 'dart:ffi' show Abi;
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:iptv_app/core/database/app_database.dart';
import 'package:iptv_app/data/local/models/account_info.dart';
import 'package:iptv_app/data/local/models/epg_programme.dart';
import 'package:iptv_app/data/local/models/live_channel.dart';
import 'package:iptv_app/data/local/models/media_category.dart';
import 'package:iptv_app/data/local/models/sync_state.dart';
import 'package:iptv_app/data/local/models/tv_series.dart';
import 'package:iptv_app/data/local/models/vod_movie.dart';
import 'package:iptv_app/data/remote/jellyfin/jellyfin_client.dart';
import 'package:iptv_app/data/remote/jellyfin/jellyfin_mappers.dart';
import 'package:iptv_app/data/sources/credentials.dart';
import 'package:iptv_app/data/sync/jellyfin_sync_worker.dart';
import 'package:iptv_app/data/sync/sync_worker.dart';

// Isar nativo a sério: usa o libisar.dll do build Windows
// (`flutter build windows`). Sem ele (CI em Linux) estes testes saltam.
final _isarLibrary = File('build/windows/x64/runner/Release/libisar.dll')
    .absolute
    .path;
final _skip = !Platform.isWindows || !File(_isarLibrary).existsSync()
    ? 'precisa do libisar.dll de um flutter build windows'
    : null;

const _credentials = JellyfinCredentials(
  serverUrl: 'http://nas:8096',
  username: 'rui',
  userId: 'u1',
  accessToken: 'tok',
  deviceId: 'dev1',
);

/// Biblioteca do servidor falso, que cada teste muda entre sincronizações.
class _Library {
  var movies = <Map<String, Object>>[
    {'Id': 'm1', 'Name': 'Filme 1', 'DateCreated': '2026-01-01T00:00:00Z'},
    {'Id': 'm2', 'Name': 'Filme 2', 'DateCreated': '2026-02-01T00:00:00Z'},
  ];
  var series = <Map<String, Object>>[
    {
      'Id': 's1',
      'Name': 'Série 1',
      'Genres': <String>['Drama'],
    },
  ];
  var liveTv = true;
  final channels = <Map<String, Object>>[
    {'Id': 'c2', 'Name': 'Dois', 'ChannelNumber': '2'},
    {'Id': 'c1', 'Name': 'Um', 'ChannelNumber': '1'},
  ];
  final programmes = <Map<String, Object>>[
    {
      'ChannelId': 'c1',
      'Name': 'Notícias',
      'StartDate': DateTime.now().toUtc().toIso8601String(),
      'EndDate': DateTime.now()
          .toUtc()
          .add(const Duration(hours: 1))
          .toIso8601String(),
    },
    // Canal que o utilizador não tem: fica de fora.
    {
      'ChannelId': 'outro',
      'Name': 'X',
      'StartDate': DateTime.now().toUtc().toIso8601String(),
      'EndDate': DateTime.now()
          .toUtc()
          .add(const Duration(hours: 1))
          .toIso8601String(),
    },
  ];

  Object? respond(RequestOptions request) {
    final query = request.uri.queryParameters;
    return switch (request.uri.path) {
      '/Users/u1' => {'Id': 'u1', 'Name': 'Rui'},
      '/UserViews' => {
        'Items': [
          {'Id': 'v1', 'Name': 'Filmes', 'CollectionType': 'movies'},
          {'Id': 'v2', 'Name': 'Séries', 'CollectionType': 'tvshows'},
          if (liveTv)
            {'Id': 'v3', 'Name': 'TV em direto', 'CollectionType': 'livetv'},
        ],
      },
      '/Items' => {
        'Items': switch ((query['ParentId'], query['IncludeItemTypes'])) {
          ('v1', 'Movie') => movies,
          ('v2', 'Series') => series,
          _ => const <Object>[],
        },
      },
      '/LiveTv/Channels' => {'Items': channels},
      '/LiveTv/Programs' => {'Items': programmes},
      _ => 404,
    };
  }
}

class _FakeServer implements HttpClientAdapter {
  _FakeServer(this.library);

  final _Library library;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final body = library.respond(options);
    if (body is int) return ResponseBody.fromString('', body);
    return ResponseBody.fromString(
      jsonEncode(body),
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late Directory dir;
  late Isar isar;
  late ReceivePort events;

  setUpAll(() async {
    if (_skip != null) return;
    await Isar.initializeIsarCore(libraries: {Abi.windowsX64: _isarLibrary});
  });

  setUp(() async {
    if (_skip != null) return;
    dir = await Directory.systemTemp.createTemp('jellyfin_sync_test');
    isar = await AppDatabase.openInstance(dir.path, name: 'iptv_jf');
    events = ReceivePort();
  });

  tearDown(() async {
    if (_skip != null) return;
    events.close();
    await isar.close(deleteFromDisk: true);
    await dir.delete(recursive: true);
  });

  Future<void> sync(_Library library) {
    final client = JellyfinClient(
      _credentials,
      dio: JellyfinClient.createDio()..httpClientAdapter = _FakeServer(library),
    );
    return JellyfinSyncWorker(
      isar,
      SyncRequest(
        events: events.sendPort,
        databaseDirectory: dir.path,
        databaseName: 'iptv_jf',
        credentials: _credentials,
        kinds: {...SyncKind.values},
        epgPast: const Duration(days: 1),
        epgFuture: const Duration(days: 1),
      ),
      CancelToken(),
      client,
    ).run();
  }

  test('bibliotecas viram grupos; canais pelo número; guia só dos canais '
      'existentes', () async {
    final library = _Library();
    await sync(library);

    expect(isar.accounts.getSync(0)?.username, 'Rui');

    final movieGroup = categoryKeyOf(normalizeJellyfinId('v1'));
    final groups = isar.categories.where().findAllSync();
    expect(
      {for (final g in groups) (g.type, g.name)},
      {(CategoryType.movie, 'Filmes'), (CategoryType.series, 'Séries')},
    );
    expect(
      isar.movies
          .where()
          .categoryIdEqualToAnySortIndex(movieGroup)
          .nameProperty()
          .findAllSync(),
      ['Filme 1', 'Filme 2'],
    );
    expect(isar.series.getSync(jellyfinKey('s1'))?.remoteId, 's1');

    expect(
      isar.liveChannels.where().sortBySortIndex().nameProperty().findAllSync(),
      ['Um', 'Dois'],
    );
    expect(isar.epgProgrammes.countSync(), 1);
    for (final kind in SyncKind.values) {
      final state = isar.syncStates.getSync(kind.index);
      expect(state?.lastError, isNull, reason: kind.name);
      expect(state?.lastSuccessAt, isNotNull, reason: kind.name);
    }
  }, skip: _skip);

  test('o que sai do servidor sai da app, mesmo que fique vazio', () async {
    final library = _Library();
    await sync(library);

    library
      ..movies = [library.movies.first]
      ..series = []
      ..liveTv = false;
    await sync(library);

    expect(isar.movies.where().nameProperty().findAllSync(), ['Filme 1']);
    expect(isar.series.countSync(), 0);
    expect(
      isar.categories
          .where()
          .typeEqualToAnySortIndex(CategoryType.series)
          .countSync(),
      0,
      reason: 'biblioteca sem séries não aparece como grupo',
    );
    expect(isar.liveChannels.countSync(), 0);
    expect(isar.epgProgrammes.countSync(), 0);
    expect(isar.syncStates.getSync(SyncKind.series.index)?.lastError, isNull);
  }, skip: _skip);
}
