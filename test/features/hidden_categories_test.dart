import 'dart:ffi' show Abi;
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:iptv_app/app/providers.dart';
import 'package:iptv_app/core/database/app_database.dart';
import 'package:iptv_app/data/local/models/hidden_category.dart';
import 'package:iptv_app/data/local/models/live_channel.dart';
import 'package:iptv_app/data/local/models/media_category.dart';
import 'package:iptv_app/data/local/models/tv_series.dart';
import 'package:iptv_app/data/local/models/vod_movie.dart';
import 'package:iptv_app/features/catalog/category_providers.dart';
import 'package:iptv_app/features/live_tv/live_tv_providers.dart';
import 'package:iptv_app/features/series/series_providers.dart';
import 'package:iptv_app/features/vod/vod_providers.dart';

// Isar nativo a sério (as queries "todos menos os ocultos" são o que
// interessa testar): usa o libisar.dll do build Windows. Sem ele salta.
final _isarLibrary = File('build/windows/x64/runner/Release/libisar.dll')
    .absolute
    .path;
final _skip = !Platform.isWindows || !File(_isarLibrary).existsSync()
    ? 'precisa do libisar.dll de um flutter build windows'
    : null;

MediaCategory _category(CategoryType type, int id, String name, int order) =>
    MediaCategory()
      ..id = MediaCategory.idFor(type, id)
      ..type = type
      ..categoryId = id
      ..name = name
      ..sortIndex = order;

void main() {
  late Directory dir;
  late Isar isar;

  setUpAll(() async {
    if (_skip != null) return;
    await Isar.initializeIsarCore(libraries: {Abi.windowsX64: _isarLibrary});
  });

  setUp(() async {
    if (_skip != null) return;
    dir = await Directory.systemTemp.createTemp('hidden_categories_test');
    isar = await AppDatabase.openInstance(dir.path, name: 'hidden_test');

    // Três grupos de canais; a ordem global (sortIndex) mistura-os de
    // propósito, para ver que "todos" mantém a ordem do fornecedor.
    await isar.writeTxn(() async {
      await isar.categories.putAll([
        _category(CategoryType.live, 1, 'PT | Generalistas', 0),
        _category(CategoryType.live, 2, 'AR | Árabes', 1),
        _category(CategoryType.live, 3, 'PT | Desporto', 2),
        _category(CategoryType.movie, 1, 'Filmes PT', 0),
        _category(CategoryType.movie, 2, 'Filmes AR', 1),
        _category(CategoryType.series, 2, 'Séries AR', 0),
      ]);
      var order = 0;
      await isar.liveChannels.putAll([
        for (final (id, category) in [
          (10, 1),
          (20, 2),
          (11, 1),
          (30, 3),
          (21, 2),
          (31, 3),
        ])
          LiveChannel()
            ..id = id
            ..categoryId = category
            ..name = 'Canal $id'
            ..sortIndex = order++,
      ]);
      await isar.movies.putAll([
        VodMovie()
          ..id = 100
          ..categoryId = 1
          ..name = 'Antigo PT'
          ..addedAt = 1,
        VodMovie()
          ..id = 200
          ..categoryId = 2
          ..name = 'Recente AR'
          ..addedAt = 3,
        VodMovie()
          ..id = 101
          ..categoryId = 1
          ..name = 'Recente PT'
          ..addedAt = 2,
      ]);
      await isar.series.putAll([
        TvSeries()
          ..id = 500
          ..categoryId = 2
          ..name = 'Série AR',
        TvSeries()
          ..id = 501
          ..categoryId = 7
          ..name = 'Sem grupo conhecido',
      ]);
    });
  });

  tearDown(() async {
    if (_skip != null) return;
    await isar.close(deleteFromDisk: true);
    await dir.delete(recursive: true);
  });

  ProviderContainer containerFor(Isar isar) {
    final container = ProviderContainer(
      overrides: [isarProvider.overrideWithValue(isar)],
    );
    addTearDown(container.dispose);
    return container;
  }

  test(
    skip: _skip,
    'ocultar um grupo tira-o da lista e dos canais de "todos"',
    () {
      final container = containerFor(isar);
      final hidden = container.read(
        hiddenCategoriesProvider(CategoryType.live).notifier,
      );
      List<String> names() => [
        for (final c in container.read(
          visibleCategoriesProvider(CategoryType.live),
        ))
          c.name,
      ];

      expect(container.read(liveChannelIdsProvider(null)), [
        10,
        20,
        11,
        30,
        21,
        31,
      ]);

      hidden.setHidden(2, hidden: true);

      expect(names(), ['PT | Generalistas', 'PT | Desporto']);
      expect(container.read(liveChannelIdsProvider(null)), [
        10,
        11,
        30,
        31,
      ], reason: 'sem os canais árabes e na ordem do fornecedor');
      // As outras secções não mudam.
      expect(
        container.read(visibleCategoriesProvider(CategoryType.movie)),
        hasLength(2),
      );

      hidden.setHidden(2, hidden: false);
      expect(names(), hasLength(3));
      expect(container.read(liveChannelIdsProvider(null)), hasLength(6));
    },
  );

  test(skip: _skip, 'a escolha fica guardada no catálogo do perfil', () {
    containerFor(isar)
        .read(hiddenCategoriesProvider(CategoryType.live).notifier)
        .setAllHidden([1, 3], hidden: true);

    // Como se a app tivesse sido fechada e aberta.
    final reopened = containerFor(isar);
    expect(reopened.read(hiddenCategoriesProvider(CategoryType.live)), {1, 3});
    expect(reopened.read(liveChannelIdsProvider(null)), [20, 21]);
    expect(
      reopened.read(hiddenCategoriesProvider(CategoryType.movie)),
      isEmpty,
    );
  });

  test(skip: _skip, 'esconder o grupo aberto volta a "todos"', () {
    final container = containerFor(isar);
    container
        .read(selectedCategoryProvider(CategoryType.live).notifier)
        .select(2);

    container
        .read(hiddenCategoriesProvider(CategoryType.live).notifier)
        .setHidden(2, hidden: true);

    expect(container.read(selectedCategoryProvider(CategoryType.live)), isNull);
  });

  test(skip: _skip, 'filmes e séries também respeitam os grupos ocultos', () {
    final container = containerFor(isar);
    expect(container.read(movieIdsProvider(null)), [200, 101, 100]);

    container
        .read(hiddenCategoriesProvider(CategoryType.movie).notifier)
        .setHidden(2, hidden: true);
    container
        .read(hiddenCategoriesProvider(CategoryType.series).notifier)
        .setHidden(2, hidden: true);

    expect(container.read(movieIdsProvider(null)), [
      101,
      100,
    ], reason: 'do mais recente para o mais antigo, sem os árabes');
    expect(container.read(seriesIdsProvider(null)), [501]);
  });

  test(
    skip: _skip,
    'contagem por grupo e limpeza ao remover o perfil',
    () async {
      final container = containerFor(isar);
      expect(container.read(categoryCountsProvider(CategoryType.live)), {
        1: 2,
        2: 2,
        3: 2,
      });

      container
          .read(hiddenCategoriesProvider(CategoryType.live).notifier)
          .setHidden(3, hidden: true);
      await AppDatabase.clearCatalog(isar);
      expect(isar.hiddenCategories.countSync(), 0);
    },
  );
}
