import 'package:flutter/foundation.dart';

import 'series_episode.dart';

/// Quem precisa de saber o que acontece a um stream. O Jellyfin guarda o
/// progresso ("Continuar a ver", "visto") e, na TV em direto, liberta o
/// sintonizador quando se para o canal.
abstract interface class PlaybackReporter {
  void started(Duration position);

  void progress(Duration position, {required bool paused});

  /// Ao abrir outro stream, ao parar ou ao fechar o player. Chamadas
  /// repetidas não fazem nada.
  void stopped(Duration position);
}

/// Tudo o que o player precisa para abrir um stream.
@immutable
class PlaybackRequest {
  const PlaybackRequest(this.url, {this.resumeAt, this.reporter});

  final String url;

  /// Onde o utilizador ficou da última vez (Jellyfin). null = do início.
  final Duration? resumeAt;

  final PlaybackReporter? reporter;

  /// O stream foi aberto no servidor mas já não vai tocar (ex.: mudou-se
  /// de canal enquanto abria): liberta-o.
  void discard() => reporter?.stopped(Duration.zero);
}

/// O que a UI pede à rede para o perfil ativo: streams e episódios. O
/// catálogo em si vem sempre do Isar.
abstract interface class SourceClient {
  Future<PlaybackRequest?> live(int channelId);

  Future<PlaybackRequest?> movie(int movieId);

  Future<List<SeriesEpisode>> episodes(int seriesId);

  Future<PlaybackRequest?> episode(SeriesEpisode episode);

  /// O servidor guarda o progresso de cada episódio: depois de ver um, a
  /// lista tem de ser pedida outra vez.
  bool get tracksProgress;

  void close();
}
