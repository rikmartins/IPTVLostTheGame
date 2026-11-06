import 'package:flutter/foundation.dart';

import '../local/models/epg_programme.dart';
import 'series_episode.dart';

/// Quem precisa de saber o que acontece a um stream: o "Continuar a ver"
/// deste dispositivo, e o Jellyfin, que guarda o progresso no servidor e,
/// na TV em direto, liberta o sintonizador quando se para o canal.
abstract interface class PlaybackReporter {
  void started(Duration position);

  /// [duration]: duração total (zero = desconhecida, ex.: em direto).
  void progress(
    Duration position, {
    required bool paused,
    Duration duration = Duration.zero,
  });

  /// Ao abrir outro stream, ao parar ou ao fechar o player. Chamadas
  /// repetidas não fazem nada.
  void stopped(Duration position, {Duration duration = Duration.zero});
}

/// Vários a ouvir o mesmo stream.
class _Reporters implements PlaybackReporter {
  const _Reporters(this.all);

  final List<PlaybackReporter> all;

  @override
  void started(Duration position) {
    for (final reporter in all) {
      reporter.started(position);
    }
  }

  @override
  void progress(
    Duration position, {
    required bool paused,
    Duration duration = Duration.zero,
  }) {
    for (final reporter in all) {
      reporter.progress(position, paused: paused, duration: duration);
    }
  }

  @override
  void stopped(Duration position, {Duration duration = Duration.zero}) {
    for (final reporter in all) {
      reporter.stopped(position, duration: duration);
    }
  }
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

  /// O mesmo pedido, com mais alguém a ouvir o progresso.
  PlaybackRequest alsoReportTo(PlaybackReporter extra) {
    final current = reporter;
    return PlaybackRequest(
      url,
      resumeAt: resumeAt,
      reporter: current == null ? extra : _Reporters([current, extra]),
    );
  }
}

/// O que a UI pede à rede para o perfil ativo: streams e episódios. O
/// catálogo em si vem sempre do Isar.
abstract interface class SourceClient {
  Future<PlaybackRequest?> live(int channelId);

  Future<PlaybackRequest?> movie(int movieId);

  Future<List<SeriesEpisode>> episodes(int seriesId);

  Future<PlaybackRequest?> episode(SeriesEpisode episode);

  /// Gravação (catch-up) de um programa que já passou ou está a passar,
  /// se o canal a tiver. null = o servidor não tem.
  Future<PlaybackRequest?> catchup(int channelId, EpgProgramme programme);

  /// O servidor guarda o progresso de cada episódio: depois de ver um, a
  /// lista tem de ser pedida outra vez.
  bool get tracksProgress;

  void close();
}
