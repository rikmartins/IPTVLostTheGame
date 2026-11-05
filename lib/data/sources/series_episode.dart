import 'package:flutter/foundation.dart';

/// Episódio de uma série, pedido quando o utilizador abre a série. Não é
/// guardado no Isar.
@immutable
class SeriesEpisode {
  const SeriesEpisode({
    required this.id,
    required this.season,
    required this.number,
    required this.title,
    this.containerExtension = 'mp4',
    this.plot,
    this.image,
    this.duration,
    this.resumeAt,
    this.watched = false,
  });

  /// Xtream: ID do stream do episódio (vai no URL `/series/...`).
  /// Jellyfin: ID do item.
  final String id;
  final int season;
  final int number;
  final String title;
  final String containerExtension;
  final String? plot;
  final String? image;

  /// Como o servidor o manda, ex.: "00:45:12".
  final String? duration;

  /// Onde ficou da última vez (Jellyfin); null = por ver ou sem esse dado.
  final Duration? resumeAt;

  /// Visto até ao fim (Jellyfin).
  final bool watched;
}
