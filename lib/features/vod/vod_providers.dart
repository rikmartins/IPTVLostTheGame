import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import '../../app/providers.dart';
import '../../data/local/models/sync_state.dart';
import '../../data/local/models/vod_movie.dart';

/// IDs dos filmes de um grupo, na ordem do fornecedor. Sem grupo
/// (`null`): todos, do mais recente para o mais antigo, lidos diretamente
/// do índice de `addedAt` (sem sort em memória sobre 186k filmes).
final movieIdsProvider = Provider.autoDispose.family<List<int>, int?>((
  ref,
  categoryId,
) {
  ref.watch(catalogVersionProvider(SyncKind.movies));
  final movies = ref.watch(isarProvider).movies;
  return categoryId == null
      ? movies.where(sort: Sort.desc).anyAddedAt().idProperty().findAllSync()
      : movies
            .where()
            .categoryIdEqualToAnySortIndex(categoryId)
            .idProperty()
            .findAllSync();
});

final movieProvider = Provider.autoDispose.family<VodMovie?, int>((ref, id) {
  ref.watch(catalogVersionProvider(SyncKind.movies));
  return ref.watch(isarProvider).movies.getSync(id);
});
