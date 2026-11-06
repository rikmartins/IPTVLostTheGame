import 'package:isar_community/isar.dart';

import '../../../core/utils/search_text.dart';
import 'media_category.dart';

part 'vod_movie.g.dart';

/// Só os campos da grelha. Sinopse, elenco, etc. vêm do `get_vod_info`
/// quando o utilizador abre o filme: manter isto leve torna a sincronização
/// de catálogos com 100k+ filmes muito mais rápida.
@Collection(accessor: 'movies')
class VodMovie {
  /// Igual ao `stream_id` do Xtream.
  Id id = Isar.autoIncrement;

  @Index(composite: [CompositeIndex('sortIndex')])
  int categoryId = kNoCategory;

  int sortIndex = 0;

  late String name;

  String? poster;

  /// Escala 0–10.
  double rating = 0;

  /// Unix seconds; indexado para a fila "Adicionados recentemente".
  @Index()
  int addedAt = 0;

  /// Extensão real do ficheiro (mkv, mp4, ...), necessária para o URL.
  String containerExtension = 'mp4';

  String? directSource;

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
