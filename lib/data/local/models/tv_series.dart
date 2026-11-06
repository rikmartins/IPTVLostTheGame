import 'package:isar_community/isar.dart';

import '../../../core/utils/search_text.dart';
import 'media_category.dart';

part 'tv_series.g.dart';

/// Temporadas e episódios não são sincronizados em massa: vêm do
/// `get_series_info` quando o utilizador abre a série.
@Collection(accessor: 'series')
class TvSeries {
  /// Igual ao `series_id` do Xtream.
  Id id = Isar.autoIncrement;

  @Index(composite: [CompositeIndex('sortIndex')])
  int categoryId = kNoCategory;

  int sortIndex = 0;

  late String name;

  String? cover;

  String? plot;

  String? genre;

  String? releaseDate;

  /// Escala 0–10.
  double rating = 0;

  /// Unix seconds (`last_modified`).
  int lastModified = 0;

  /// Jellyfin: ID do item (o [id] é um hash dele). Null no Xtream.
  String? remoteId;

  int syncStamp = 0;

  /// O nome em minúsculas e sem acentos, para a pesquisa global. Sem
  /// índice: o Isar procura dentro do texto em ~30 ms em 186k filmes, e um
  /// índice das palavras punha a sincronização 3x mais lenta e duplicava o
  /// tamanho da base. Nullable só para se reconhecerem os itens gravados
  /// antes de existir (ver `ensureSearchIndex`).
  String? get searchName => _searchName ??= foldForSearch(name);

  @ignore
  String? _searchName;
}
