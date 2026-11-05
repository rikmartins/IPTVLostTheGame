import 'package:isar_community/isar.dart';

import '../../local/models/account_info.dart';
import '../../local/models/vod_movie.dart';
import '../../sources/credentials.dart';
import '../../sources/series_episode.dart';
import '../../sources/source_client.dart';
import 'xtream_api.dart';
import 'xtream_stream_urls.dart';

/// No Xtream os URLs dos streams montam-se localmente; só os episódios vão
/// à rede.
class XtreamSourceClient implements SourceClient {
  XtreamSourceClient(this.credentials, this.isar)
    : _urls = XtreamStreamUrls(credentials);

  final XtreamCredentials credentials;
  final Isar isar;
  final XtreamStreamUrls _urls;

  /// Na extensão que a conta prefere.
  @override
  Future<PlaybackRequest?> live(int channelId) async {
    final account = isar.accounts.getSync(0);
    return PlaybackRequest(
      _urls.live(channelId, extension: account?.preferredLiveExtension ?? 'ts'),
    );
  }

  @override
  Future<PlaybackRequest?> movie(int movieId) async {
    final movie = isar.movies.getSync(movieId);
    if (movie == null) return null;
    return PlaybackRequest(_urls.movie(movie.id, movie.containerExtension));
  }

  /// Os episódios não são sincronizados em massa: sincronizar os de 50k
  /// séries seriam 50k pedidos.
  @override
  Future<List<SeriesEpisode>> episodes(int seriesId) async {
    final api = XtreamApi(credentials);
    try {
      return await api.seriesEpisodes(seriesId);
    } finally {
      api.close();
    }
  }

  @override
  Future<PlaybackRequest?> episode(SeriesEpisode episode) async =>
      PlaybackRequest(_urls.episode(episode.id, episode.containerExtension));

  @override
  bool get tracksProgress => false;

  @override
  void close() {}
}
