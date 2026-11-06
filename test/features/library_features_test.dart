import 'dart:ffi' show Abi;
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:iptv_app/app/providers.dart';
import 'package:iptv_app/core/database/app_database.dart';
import 'package:iptv_app/data/local/models/account_info.dart';
import 'package:iptv_app/data/local/models/epg_programme.dart';
import 'package:iptv_app/data/local/models/favorite_channel.dart';
import 'package:iptv_app/data/local/models/hidden_category.dart';
import 'package:iptv_app/data/local/models/live_channel.dart';
import 'package:iptv_app/data/local/models/media_category.dart';
import 'package:iptv_app/data/local/models/tv_series.dart';
import 'package:iptv_app/data/local/models/vod_movie.dart';
import 'package:iptv_app/data/remote/xtream/xtream_source_client.dart';
import 'package:iptv_app/data/sources/credentials.dart';
import 'package:iptv_app/data/sources/series_episode.dart';
import 'package:iptv_app/features/catalog/category_providers.dart';
import 'package:iptv_app/features/live_tv/favorites.dart';
import 'package:iptv_app/features/live_tv/live_tv_providers.dart';
import 'package:iptv_app/features/player/watch_progress.dart';
import 'package:iptv_app/features/search/search_providers.dart';
import 'package:iptv_app/features/series/series_providers.dart';
import 'package:iptv_app/features/vod/vod_providers.dart';

// Isar nativo a sério: usa o libisar.dll do build Windows
// (`flutter build windows`). Sem ele (CI em Linux) estes testes saltam.
final _isarLibrary = File('build/windows/x64/runner/Release/libisar.dll')
    .absolute
    .path;
final _skip = !Platform.isWindows || !File(_isarLibrary).existsSync()
    ? 'precisa do libisar.dll de um flutter build windows'
    : null;

void main() {
  late Directory dir;
  late Isar isar;
  late ProviderContainer container;

  setUpAll(() async {
    if (_skip != null) return;
    await Isar.initializeIsarCore(libraries: {Abi.windowsX64: _isarLibrary});
  });

  setUp(() async {
    if (_skip != null) return;
    dir = await Directory.systemTemp.createTemp('library_features_test');
    isar = await AppDatabase.openInstance(dir.path, name: 'iptv_lib');
    isar.writeTxnSync(() {
      isar.liveChannels.putAllSync([
        LiveChannel()
          ..id = 10
          ..sortIndex = 2
          ..name = 'PT: Eurosport 1'
          ..categoryId = 1,
        LiveChannel()
          ..id = 11
          ..sortIndex = 1
          ..name = 'PT: Sport TV 1'
          ..categoryId = 1
          ..hasCatchup = true
          ..catchupDays = 3,
        LiveChannel()
          ..id = 12
          ..sortIndex = 0
          ..name = 'ES: Sport Canal'
          ..categoryId = 2,
      ]);
      isar.movies.putAllSync([
        VodMovie()
          ..id = 1
          ..name = 'A Família Addams'
          ..categoryId = 5,
        VodMovie()
          ..id = 2
          ..name = 'Addams: Família Escondida'
          ..categoryId = 6,
        VodMovie()
          ..id = 3
          ..name = 'Outro filme'
          ..categoryId = 5,
      ]);
      isar.series.putSync(
        TvSeries()
          ..id = 7
          ..name = 'Família Moderna',
      );
      isar.accounts.putSync(
        AccountInfo()
          ..username = 'ana'
          ..status = 'Active'
          ..serverUtcOffsetMinutes = 60
          ..lastLoginAt = DateTime(2026),
      );
    });
    container = ProviderContainer(
      overrides: [isarProvider.overrideWithValue(isar)],
    );
  });

  tearDown(() async {
    if (_skip != null) return;
    container.dispose();
    await isar.close(deleteFromDisk: true);
    await dir.delete(recursive: true);
  });

  test('pesquisa global: palavras por qualquer ordem, sem acentos, e fora '
      'os grupos ocultos', () async {
    Future<SearchResults> search(String query) =>
        container.read(searchResultsProvider(query).future);

    var results = await search('familia ADD');
    expect(results.movies, [1, 2], reason: 'o nome mais curto primeiro');
    expect(results.series, isEmpty);
    expect(results.channels, isEmpty);

    results = await search('famíl');
    expect(results.series, [7]);
    expect(results.movies, containsAll([1, 2]));

    expect((await search('sport')).channels, [
      11,
      12,
      10,
    ], reason: 'Eurosport também, mas depois dos que têm a palavra "sport"');
    expect((await search('pt: sport')).channels.first, 11);

    isar.writeTxnSync(
      () => isar.hiddenCategories.putSync(
        HiddenCategory()
          ..id = MediaCategory.idFor(CategoryType.movie, 6)
          ..type = CategoryType.movie
          ..categoryId = 6,
      ),
    );
    container.invalidate(hiddenCategoriesProvider(CategoryType.movie));
    expect((await search('addams')).movies, [1]);
    expect((await search('a')).movies, isEmpty);
  }, skip: _skip);

  test('favoritos: grupo próprio pela ordem dos canais, que some quando '
      'fica vazio', () {
    final favorites = container.read(favoriteChannelsProvider.notifier);
    expect(container.read(specialGroupsProvider(CategoryType.live)), isEmpty);

    expect(favorites.toggle(10), isTrue);
    expect(favorites.toggle(12), isTrue);
    expect(container.read(liveChannelIdsProvider(kFavoritesGroup)), [12, 10]);
    expect(
      container.read(specialGroupsProvider(CategoryType.live)).single.label,
      'Favoritos',
    );

    // Guardado no catálogo do perfil.
    expect(isar.favoriteChannels.countSync(), 2);

    container
        .read(selectedCategoryProvider(CategoryType.live).notifier)
        .select(kFavoritesGroup);
    expect(favorites.toggle(10), isFalse);
    expect(favorites.toggle(12), isFalse);
    expect(
      container.read(selectedCategoryProvider(CategoryType.live)),
      isNull,
      reason: 'o grupo dos favoritos desapareceu',
    );
  }, skip: _skip);

  /// O Isar avisa as gravações de forma assíncrona: espera pelo aviso.
  Future<void> settle() =>
      Future<void>.delayed(const Duration(milliseconds: 50));

  test('continuar a ver: só a partir dos 30 s, e sai quando se vê até ao '
      'fim', () async {
    final movie = isar.movies.getSync(1)!;
    const duration = Duration(minutes: 100);

    LocalProgressReporter(
      isar,
      movieTarget(movie),
    ).stopped(const Duration(seconds: 20), duration: duration);
    await settle();
    expect(container.read(continueMovieIdsProvider), isEmpty);

    final reporter = LocalProgressReporter(isar, movieTarget(movie));
    reporter.progress(
      const Duration(minutes: 40),
      paused: false,
      duration: duration,
    );
    await settle();
    expect(container.read(continueMovieIdsProvider), [1]);
    expect(container.read(movieIdsProvider(kContinueGroup)), [1]);
    expect(
      container.read(movieProgressProvider(1))?.position,
      const Duration(minutes: 40),
    );
    expect(
      container.read(specialGroupsProvider(CategoryType.movie)).single.label,
      'Continuar a ver',
    );

    reporter.stopped(const Duration(minutes: 95), duration: duration);
    await settle();
    expect(container.read(continueMovieIdsProvider), isEmpty);
    expect(container.read(movieProgressProvider(1))?.finished, isTrue);
  }, skip: _skip);

  test('continuar a ver séries: retoma o episódio a meio mais recente', () {
    const episode = SeriesEpisode(
      id: 'ep-203',
      season: 2,
      number: 3,
      title: 'Episódio 3',
      containerExtension: 'mkv',
    );
    LocalProgressReporter(isar, episodeTarget(7, episode)).stopped(
      const Duration(minutes: 12),
      duration: const Duration(minutes: 45),
    );

    expect(container.read(continueSeriesIdsProvider), [7]);
    expect(container.read(seriesIdsProvider(kContinueGroup)), [7]);
    final resume = container.read(resumeEpisodeProvider(7))!;
    final again = episodeFromProgress(resume);
    expect(again.id, 'ep-203');
    expect(again.containerExtension, 'mkv');
    expect(again.resumeAt, const Duration(minutes: 12));
    expect(container.read(episodeProgressProvider(7)).keys, ['ep-203']);
  }, skip: _skip);

  test('catch-up do Xtream na hora do servidor; canais sem arquivo não '
      'têm', () async {
    final client = XtreamSourceClient(
      const XtreamCredentials(
        serverUrl: 'http://iptv.pt',
        username: 'ana',
        password: 'p',
      ),
      isar,
    );
    final programme = EpgProgramme()
      ..channelKey = 0
      ..start = DateTime.utc(2026, 11, 5, 20)
      ..stop = DateTime.utc(2026, 11, 5, 21, 30)
      ..title = 'Jogo';

    final request = await client.catchup(11, programme);
    expect(
      request?.url,
      'http://iptv.pt/timeshift/ana/p/90/2026-11-05:21-00/11.ts',
    );
    expect(await client.catchup(10, programme), isNull);
  }, skip: _skip);

  test('"Adicionados recentemente" fica nos mais recentes', () {
    isar.writeTxnSync(
      () => isar.movies.putAllSync([
        for (var i = 0; i < kRecentLimit + 50; i++)
          VodMovie()
            ..id = 1000 + i
            ..name = 'Filme $i'
            ..addedAt = i,
      ]),
    );
    final ids = container.read(movieIdsProvider(null));
    expect(ids, hasLength(kRecentLimit));
    expect(ids.first, 1000 + kRecentLimit + 49);
  }, skip: _skip);
}
