import 'package:isar_community/isar.dart';

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

  int syncStamp = 0;
}
