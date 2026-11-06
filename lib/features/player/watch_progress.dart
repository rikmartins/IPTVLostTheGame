import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import '../../app/providers.dart';
import '../../data/local/models/tv_series.dart';
import '../../data/local/models/vod_movie.dart';
import '../../data/local/models/watch_progress.dart';
import '../../data/sources/series_episode.dart';
import '../../data/sources/source_client.dart';

/// Quanto do vídeo conta como "visto até ao fim" (os créditos não contam).
const _finishedAt = 0.9;

/// Muda a cada gravação de progresso (o player grava de 10 em 10 s).
final watchProgressVersionProvider = StreamProvider<int>((ref) {
  var version = 0;
  return ref
      .watch(isarProvider)
      .watchProgress
      .watchLazy(fireImmediately: true)
      // Valores sempre diferentes: o Riverpod 3 filtra notificações por ==.
      .map((_) => version++);
});

WatchProgress? _get(Isar isar, WatchKind kind, String key) =>
    isar.watchProgress.getSync(WatchProgress.idFor(kind, key));

/// Onde ficou num filme (neste dispositivo).
final movieProgressProvider = Provider.autoDispose.family<WatchProgress?, int>((
  ref,
  movieId,
) {
  ref.watch(watchProgressVersionProvider);
  return _get(ref.watch(isarProvider), WatchKind.movie, '$movieId');
});

/// Progresso dos episódios de uma série, pelo ID do episódio.
final episodeProgressProvider = Provider.autoDispose
    .family<Map<String, WatchProgress>, int>((ref, seriesId) {
      ref.watch(watchProgressVersionProvider);
      final records = ref
          .watch(isarProvider)
          .watchProgress
          .where()
          .seriesIdEqualTo(seriesId)
          .findAllSync();
      return {for (final record in records) record.itemKey: record};
    });

/// Quantos aparecem em "Continuar a ver".
const _continueLimit = 60;

List<WatchProgress> _resumable(Isar isar, WatchKind kind) => isar.watchProgress
    .where(sort: Sort.desc)
    .anyUpdatedAt()
    .filter()
    .kindEqualTo(kind)
    .finishedEqualTo(false)
    .positionMsGreaterThan(
      WatchProgress.minPosition.inMilliseconds,
      include: true,
    )
    .limit(_continueLimit * 3)
    .findAllSync();

/// Filmes a meio, do mais recente para o mais antigo (só os que ainda
/// estão no catálogo).
final continueMovieIdsProvider = Provider.autoDispose<List<int>>((ref) {
  ref.watch(watchProgressVersionProvider);
  final isar = ref.watch(isarProvider);
  final ids = <int>[];
  for (final record in _resumable(isar, WatchKind.movie)) {
    final id = int.tryParse(record.itemKey);
    if (id == null || isar.movies.getSync(id) == null) continue;
    ids.add(id);
    if (ids.length == _continueLimit) break;
  }
  return ids;
});

/// Séries com um episódio a meio, da mais recente para a mais antiga.
final continueSeriesIdsProvider = Provider.autoDispose<List<int>>((ref) {
  ref.watch(watchProgressVersionProvider);
  final isar = ref.watch(isarProvider);
  final ids = <int>[];
  for (final record in _resumable(isar, WatchKind.episode)) {
    final id = record.seriesId;
    if (id == null || ids.contains(id) || isar.series.getSync(id) == null) {
      continue;
    }
    ids.add(id);
    if (ids.length == _continueLimit) break;
  }
  return ids;
});

/// O episódio a meio mais recente de uma série.
final resumeEpisodeProvider = Provider.autoDispose.family<WatchProgress?, int>((
  ref,
  seriesId,
) {
  ref.watch(watchProgressVersionProvider);
  return ref
      .watch(isarProvider)
      .watchProgress
      .where()
      .seriesIdEqualTo(seriesId)
      .filter()
      .finishedEqualTo(false)
      .positionMsGreaterThan(
        WatchProgress.minPosition.inMilliseconds,
        include: true,
      )
      .sortByUpdatedAtDesc()
      .findFirstSync();
});

/// O episódio guardado, pronto a abrir sem pedir a lista da série.
SeriesEpisode episodeFromProgress(WatchProgress record) => SeriesEpisode(
  id: record.itemKey,
  season: record.season,
  number: record.episode,
  title: record.title,
  containerExtension: record.containerExtension,
  resumeAt: record.position,
);

/// O que se está a ver, para gravar o progresso.
WatchProgress movieTarget(VodMovie movie) => WatchProgress()
  ..kind = WatchKind.movie
  ..itemKey = '${movie.id}'
  ..title = movie.name;

WatchProgress episodeTarget(int seriesId, SeriesEpisode episode) =>
    WatchProgress()
      ..kind = WatchKind.episode
      ..itemKey = episode.id
      ..seriesId = seriesId
      ..season = episode.season
      ..episode = episode.number
      ..containerExtension = episode.containerExtension
      ..title = episode.title;

/// Grava no Isar onde o utilizador vai, para o "Continuar a ver".
///
/// Só grava a partir dos 30 s: abrir um filme por engano (ou um stream
/// que falhou) não apaga onde se tinha ficado.
class LocalProgressReporter implements PlaybackReporter {
  LocalProgressReporter(this._isar, this._target);

  final Isar _isar;
  final WatchProgress _target;
  bool _stopped = false;

  @override
  void started(Duration position) {}

  @override
  void progress(
    Duration position, {
    required bool paused,
    Duration duration = Duration.zero,
  }) {
    if (!_stopped) _save(position, duration);
  }

  @override
  void stopped(Duration position, {Duration duration = Duration.zero}) {
    if (_stopped) return;
    _stopped = true;
    _save(position, duration);
  }

  void _save(Duration position, Duration duration) {
    final finished =
        duration > Duration.zero &&
        position.inMilliseconds >= duration.inMilliseconds * _finishedAt;
    if (!finished && position < WatchProgress.minPosition) return;

    final record = WatchProgress()
      ..id = WatchProgress.idFor(_target.kind, _target.itemKey)
      ..kind = _target.kind
      ..itemKey = _target.itemKey
      ..seriesId = _target.seriesId
      ..season = _target.season
      ..episode = _target.episode
      ..containerExtension = _target.containerExtension
      ..title = _target.title
      ..positionMs = position.inMilliseconds
      ..durationMs = duration.inMilliseconds
      ..finished = finished
      ..updatedAt = DateTime.now();
    _isar.writeTxnSync(() => _isar.watchProgress.putSync(record));
  }
}
