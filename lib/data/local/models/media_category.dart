import 'package:isar_community/isar.dart';

import '../../../core/utils/fast_hash.dart';

part 'media_category.g.dart';

enum CategoryType { live, movie, series }

/// Categoria sem grupo atribuído pelo fornecedor.
const kNoCategory = -1;

@Collection(accessor: 'categories')
class MediaCategory {
  /// Ver [idFor]: os `category_id` do Xtream só são únicos dentro do mesmo
  /// tipo (Live, VOD e Séries podem repetir o "1").
  Id id = Isar.autoIncrement;

  /// Índice (tipo, ordem do servidor): a lista lateral de grupos sai já
  /// ordenada do índice, sem sort em memória.
  @enumerated
  @Index(composite: [CompositeIndex('sortIndex')])
  late CategoryType type;

  /// `category_id` do Xtream normalizado para int (ver [categoryKeyOf]).
  late int categoryId;

  late String name;

  int parentId = 0;

  /// Posição na resposta do servidor (é a ordem que o fornecedor definiu).
  int sortIndex = 0;

  /// Carimbo da sincronização que escreveu o registo; o que ficar com um
  /// carimbo antigo no fim de uma sincronização completa é apagado.
  int syncStamp = 0;

  static Id idFor(CategoryType type, int categoryId) =>
      fastHash('${type.name}:$categoryId');
}

/// Normaliza o `category_id` do Xtream (quase sempre numérico, por vezes
/// String não numérica ou null) num int indexável.
int categoryKeyOf(String? raw) {
  if (raw == null) return kNoCategory;
  return int.tryParse(raw) ?? fastHash(raw);
}
