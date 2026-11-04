import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import '../../app/providers.dart';
import '../../data/local/models/media_category.dart';
import '../../data/local/models/sync_state.dart';
import '../../data/local/models/vod_movie.dart';
import '../catalog/category_providers.dart';

/// IDs dos filmes de um grupo, na ordem do fornecedor. Sem grupo
/// (`null`): todos, do mais recente para o mais antigo, lidos diretamente
/// do índice de `addedAt` (sem sort em memória sobre 186k filmes), menos
/// os dos grupos ocultos.
final movieIdsProvider = Provider.autoDispose.family<List<int>, int?>((
  ref,
  categoryId,
) {
  ref.watch(catalogVersionProvider(SyncKind.movies));
  final movies = ref.watch(isarProvider).movies;
  if (categoryId != null) {
    return movies
        .where()
        .categoryIdEqualToAnySortIndex(categoryId)
        .idProperty()
        .findAllSync();
  }

  final hidden = ref.watch(hiddenCategoriesProvider(CategoryType.movie));
  final newest = movies.where(sort: Sort.desc).anyAddedAt();
  if (hidden.isEmpty) return newest.idProperty().findAllSync();
  return newest
      .filter()
      .not()
      .anyOf(hidden, (q, id) => q.categoryIdEqualTo(id))
      .idProperty()
      .findAllSync();
});

final movieProvider = Provider.autoDispose.family<VodMovie?, int>((ref, id) {
  ref.watch(catalogVersionProvider(SyncKind.movies));
  return ref.watch(isarProvider).movies.getSync(id);
});
