import 'package:isar_community/isar.dart';

import 'media_category.dart';

part 'hidden_category.g.dart';

/// Grupo que o utilizador escondeu (de TV, filmes ou séries).
///
/// Fica numa coleção à parte e não num campo de [MediaCategory]: a
/// sincronização reescreve as categorias inteiras e apagava a escolha. Vive
/// no catálogo do perfil, porque os grupos são de cada fornecedor.
@Collection(accessor: 'hiddenCategories')
class HiddenCategory {
  /// O mesmo que [MediaCategory.idFor]: esconder duas vezes não duplica.
  Id id = Isar.autoIncrement;

  @enumerated
  @Index()
  late CategoryType type;

  late int categoryId;
}
