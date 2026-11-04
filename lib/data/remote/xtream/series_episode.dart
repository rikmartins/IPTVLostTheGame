import 'package:flutter/foundation.dart';

/// Episódio de `get_series_info`. Não é guardado no Isar (ver
/// `XtreamApi.seriesEpisodes`).
@immutable
class SeriesEpisode {
  const SeriesEpisode({
    required this.id,
    required this.season,
    required this.number,
    required this.title,
    required this.containerExtension,
    this.plot,
    this.image,
    this.duration,
  });

  /// ID do stream do episódio (vai no URL `/series/...`).
  final String id;
  final int season;
  final int number;
  final String title;
  final String containerExtension;
  final String? plot;
  final String? image;

  /// Como o servidor o manda, ex.: "00:45:12".
  final String? duration;
}
