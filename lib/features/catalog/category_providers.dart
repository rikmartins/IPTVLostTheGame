import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import '../../app/providers.dart';
import '../../data/local/models/hidden_category.dart';
import '../../data/local/models/live_channel.dart';
import '../../data/local/models/media_category.dart';
import '../../data/local/models/sync_state.dart';
import '../../data/local/models/tv_series.dart';
import '../../data/local/models/vod_movie.dart';
import '../live_tv/favorites.dart';
import '../player/watch_progress.dart';

extension CategoryTypeSync on CategoryType {
  SyncKind get syncKind => switch (this) {
    CategoryType.live => SyncKind.live,
    CategoryType.movie => SyncKind.movies,
    CategoryType.series => SyncKind.series,
  };
}

/// Grupos de um tipo, na ordem do fornecedor, lidos do Isar (síncrono:
/// centenas de registos, microssegundos).
final categoriesProvider = Provider.family<List<MediaCategory>, CategoryType>((
  ref,
  type,
) {
  ref.watch(catalogVersionProvider(type.syncKind));
  return ref
      .watch(isarProvider)
      .categories
      .where()
      .typeEqualToAnySortIndex(type)
      .findAllSync();
});

/// Grupos da app (favoritos, continuar a ver), que aparecem antes dos do
/// fornecedor e só quando têm alguma coisa.
final specialGroupsProvider = Provider.autoDispose
    .family<List<({int id, String label})>, CategoryType>((ref, type) {
      return switch (type) {
        CategoryType.live => [
          if (ref.watch(favoriteChannelsProvider).isNotEmpty)
            (id: kFavoritesGroup, label: 'Favoritos'),
        ],
        CategoryType.movie => [
          if (ref.watch(continueMovieIdsProvider).isNotEmpty)
            (id: kContinueGroup, label: 'Continuar a ver'),
        ],
        CategoryType.series => [
          if (ref.watch(continueSeriesIdsProvider).isNotEmpty)
            (id: kContinueGroup, label: 'Continuar a ver'),
        ],
      };
    });

/// `categoryId` dos grupos que o utilizador escondeu numa secção.
class HiddenCategories extends Notifier<Set<int>> {
  HiddenCategories(this.type);

  final CategoryType type;

  @override
  Set<int> build() => ref
      .watch(isarProvider)
      .hiddenCategories
      .where()
      .typeEqualTo(type)
      .categoryIdProperty()
      .findAllSync()
      .toSet();

  void setHidden(int categoryId, {required bool hidden}) =>
      setAllHidden([categoryId], hidden: hidden);

  /// Vários de uma vez (ex.: "Ocultar todos" sobre o resultado da pesquisa),
  /// numa só transação.
  void setAllHidden(Iterable<int> categoryIds, {required bool hidden}) {
    final ids = categoryIds.toSet();
    if (ids.isEmpty) return;

    final isar = ref.read(isarProvider);
    isar.writeTxnSync(() {
      final records = isar.hiddenCategories;
      if (hidden) {
        records.putAllSync([
          for (final id in ids)
            HiddenCategory()
              ..id = MediaCategory.idFor(type, id)
              ..type = type
              ..categoryId = id,
        ]);
      } else {
        records.deleteAllSync([
          for (final id in ids) MediaCategory.idFor(type, id),
        ]);
      }
    });

    state = hidden ? {...state, ...ids} : state.difference(ids);

    // O grupo aberto deixou de aparecer na lista: volta a "todos".
    if (hidden && ids.contains(ref.read(selectedCategoryProvider(type)))) {
      ref.read(selectedCategoryProvider(type).notifier).select(null);
    }
  }
}

final hiddenCategoriesProvider =
    NotifierProvider.family<HiddenCategories, Set<int>, CategoryType>(
      HiddenCategories.new,
    );

/// Os grupos que aparecem na lista lateral (ou nos chips).
final visibleCategoriesProvider =
    Provider.family<List<MediaCategory>, CategoryType>((ref, type) {
      final all = ref.watch(categoriesProvider(type));
      final hidden = ref.watch(hiddenCategoriesProvider(type));
      if (hidden.isEmpty) return all;
      return [
        for (final category in all)
          if (!hidden.contains(category.categoryId)) category,
      ];
    });

/// Quantos canais, filmes ou séries tem cada grupo (para o ecrã de escolha
/// dos grupos visíveis). Uma contagem no índice (grupo, ordem) por grupo:
/// algumas centenas de microssegundos no total.
final categoryCountsProvider = Provider.autoDispose
    .family<Map<int, int>, CategoryType>((ref, type) {
      ref.watch(catalogVersionProvider(type.syncKind));
      final isar = ref.watch(isarProvider);
      final categories = ref.watch(categoriesProvider(type));
      int count(int id) => switch (type) {
        CategoryType.live =>
          isar.liveChannels
              .where()
              .categoryIdEqualToAnySortIndex(id)
              .countSync(),
        CategoryType.movie =>
          isar.movies.where().categoryIdEqualToAnySortIndex(id).countSync(),
        CategoryType.series =>
          isar.series.where().categoryIdEqualToAnySortIndex(id).countSync(),
      };
      return {
        for (final category in categories)
          category.categoryId: count(category.categoryId),
      };
    });

/// Grupo selecionado em cada secção; `null` = "todos".
class SelectedCategory extends Notifier<int?> {
  SelectedCategory(this.type);

  final CategoryType type;

  @override
  int? build() => null;

  void select(int? categoryId) => state = categoryId;
}

final selectedCategoryProvider =
    NotifierProvider.family<SelectedCategory, int?, CategoryType>(
      SelectedCategory.new,
    );
