import 'package:isar_community/isar.dart';

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

  int syncStamp = 0;
}
