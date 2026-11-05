import 'package:isar_community/isar.dart';

import '../../local/models/live_channel.dart';
import '../../local/models/tv_series.dart';
import '../../local/models/vod_movie.dart';
import '../../sources/credentials.dart';
import '../../sources/series_episode.dart';
import '../../sources/source_client.dart';
import 'jellyfin_client.dart';

/// Streams do Jellyfin: os canais abrem-se no servidor (ocupam um
/// sintonizador) e tudo o que se vê é reportado, para o servidor guardar o
/// progresso.
class JellyfinSourceClient implements SourceClient {
  JellyfinSourceClient(JellyfinCredentials credentials, this.isar)
    : _client = JellyfinClient(credentials);

  final Isar isar;
  final JellyfinClient _client;

  @override
  Future<PlaybackRequest?> live(int channelId) async {
    final remoteId = isar.liveChannels.getSync(channelId)?.remoteId;
    if (remoteId == null) return null;
    final stream = await _client.openLiveStream(remoteId);
    return PlaybackRequest(
      stream.url,
      reporter: _JellyfinReporter(_client, stream),
    );
  }

  /// Pede ao servidor onde o utilizador ficou: pode ter visto parte do
  /// filme noutro aparelho.
  @override
  Future<PlaybackRequest?> movie(int movieId) async {
    final remoteId = isar.movies.getSync(movieId)?.remoteId;
    if (remoteId == null) return null;
    final resumeAt = await _client.resumePosition(remoteId);
    final stream = _client.vodStream(remoteId);
    return PlaybackRequest(
      stream.url,
      resumeAt: resumeAt,
      reporter: _JellyfinReporter(_client, stream),
    );
  }

  @override
  Future<List<SeriesEpisode>> episodes(int seriesId) async {
    final remoteId = isar.series.getSync(seriesId)?.remoteId;
    if (remoteId == null) return const [];
    return _client.episodes(remoteId);
  }

  /// A posição vem da lista de episódios, que se pede outra vez depois de
  /// cada episódio visto (ver [tracksProgress]).
  @override
  Future<PlaybackRequest?> episode(SeriesEpisode episode) async {
    final stream = _client.vodStream(episode.id);
    return PlaybackRequest(
      stream.url,
      resumeAt: episode.watched ? null : episode.resumeAt,
      reporter: _JellyfinReporter(_client, stream),
    );
  }

  @override
  bool get tracksProgress => true;

  @override
  void close() => _client.close();
}

/// Os avisos ao servidor não podem atrasar nem interromper o vídeo: são
/// enviados sem esperar, e uma falha (servidor em baixo) é ignorada.
class _JellyfinReporter implements PlaybackReporter {
  _JellyfinReporter(this._client, this._stream);

  final JellyfinClient _client;
  final JellyfinStream _stream;
  bool _stopped = false;

  @override
  void started(Duration position) =>
      _send(PlaybackEvent.started, position, paused: false);

  @override
  void progress(Duration position, {required bool paused}) {
    if (!_stopped) _send(PlaybackEvent.progress, position, paused: paused);
  }

  @override
  void stopped(Duration position) {
    if (_stopped) return;
    _stopped = true;
    _send(PlaybackEvent.stopped, position, paused: false);
  }

  void _send(PlaybackEvent event, Duration position, {required bool paused}) {
    _client.report(event, _stream, position, paused: paused).ignore();
  }
}
