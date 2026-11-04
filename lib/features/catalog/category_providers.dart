import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import '../../app/providers.dart';
import '../../data/local/models/media_category.dart';
import '../../data/local/models/sync_state.dart';

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
