import 'package:isar_community/isar.dart';

import '../../../core/utils/fast_hash.dart';

part 'media_category.g.dart';

enum CategoryType { live, movie, series }

/// Categoria sem grupo atribuído pelo fornecedor.
const kNoCategory = -1;

/// Grupos que não vêm do fornecedor e aparecem antes dos dele. Como
/// `categoryId` nunca coincidem com os do Xtream (inteiros não negativos ou
/// hashes de 64 bits).
const kFavoritesGroup = -2;

/// "Continuar a ver" em Filmes e Séries.
const kContinueGroup = -3;

/// "Adicionados / Atualizados recentemente" mostram só estes: percorrer
/// 186 mil filmes recentes não serve a ninguém, e a consulta inteira bloqueava
/// a interface quase um segundo numa TV box.
const kRecentLimit = 2000;

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
