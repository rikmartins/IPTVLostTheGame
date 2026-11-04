import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import '../../app/providers.dart';
import '../../app/session_controller.dart';
import '../../data/local/models/media_category.dart';
import '../../data/local/models/sync_state.dart';
import '../../data/local/models/tv_series.dart';
import '../../data/remote/xtream/series_episode.dart';
import '../../data/remote/xtream/xtream_api.dart';
import '../catalog/category_providers.dart';

/// Sem grupo (`null`): todas menos as dos grupos ocultos, das atualizadas
/// mais recentemente (novos episódios) para as mais antigas.
final seriesIdsProvider = Provider.autoDispose.family<List<int>, int?>((
  ref,
  categoryId,
) {
  ref.watch(catalogVersionProvider(SyncKind.series));
  final series = ref.watch(isarProvider).series;
  if (categoryId != null) {
    return series
        .where()
        .categoryIdEqualToAnySortIndex(categoryId)
        .idProperty()
        .findAllSync();
  }

  final hidden = ref.watch(hiddenCategoriesProvider(CategoryType.series));
  if (hidden.isEmpty) {
    return series.where().sortByLastModifiedDesc().idProperty().findAllSync();
  }
  return series
      .where()
      .filter()
      .not()
      .anyOf(hidden, (q, id) => q.categoryIdEqualTo(id))
      .sortByLastModifiedDesc()
      .idProperty()
      .findAllSync();
});

final seriesItemProvider = Provider.autoDispose.family<TvSeries?, int>((
  ref,
  id,
) {
  ref.watch(catalogVersionProvider(SyncKind.series));
  return ref.watch(isarProvider).series.getSync(id);
});

/// Única leitura da UI que vai à rede: os episódios não são sincronizados
/// em massa. Fica em cache durante a sessão depois do primeiro sucesso,
/// para voltar à mesma série ser instantâneo.
final seriesEpisodesProvider = FutureProvider.autoDispose
    .family<List<SeriesEpisode>, int>((ref, seriesId) async {
      final credentials = ref.watch(sessionProvider);
      if (credentials == null) return const [];

      final api = XtreamApi(credentials);
      try {
        final episodes = await api.seriesEpisodes(seriesId);
        ref.keepAlive();
        return episodes;
      } finally {
        api.close();
      }
    });
