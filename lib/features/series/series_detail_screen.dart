import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/session_controller.dart';
import '../../core/utils/time_format.dart';
import '../../data/local/models/tv_series.dart';
import '../../data/local/models/watch_progress.dart';
import '../../data/sources/series_episode.dart';
import '../../data/sources/source_exception.dart';
import '../catalog/widgets/artwork.dart';
import '../player/play_vod.dart';
import '../player/watch_progress.dart';
import 'series_providers.dart';

class SeriesDetailScreen extends ConsumerStatefulWidget {
  const SeriesDetailScreen({super.key, required this.seriesId});

  final int seriesId;

  @override
  ConsumerState<SeriesDetailScreen> createState() =>
      _SeriesDetailScreenState();
}

class _SeriesDetailScreenState extends ConsumerState<SeriesDetailScreen> {
  int? _season;

  @override
  Widget build(BuildContext context) {
    // Cabeçalho vem do Isar (instantâneo); só os episódios vêm da rede.
    final series = ref.watch(seriesItemProvider(widget.seriesId));
    final episodes = ref.watch(seriesEpisodesProvider(widget.seriesId));
    // O que se viu neste dispositivo (no Xtream é a única fonte).
    final local = ref.watch(episodeProgressProvider(widget.seriesId));

    return Scaffold(
      appBar: AppBar(title: Text(series?.name ?? '')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          if (series != null) _Header(series: series),
          const SizedBox(height: 24),
          ...switch (episodes) {
            // Também a recarregar depois de ver um episódio: a lista fica
            // no ecrã até chegar a nova.
            AsyncValue(:final value?) => _episodeSection(value, local),
            AsyncError(:final error) => [
              _LoadError(
                message: error is SourceException
                    ? error.message
                    : 'Não foi possível carregar os episódios',
                onRetry: () =>
                    ref.invalidate(seriesEpisodesProvider(widget.seriesId)),
              ),
            ],
            _ => [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
          },
        ],
      ),
    );
  }

  List<Widget> _episodeSection(
    List<SeriesEpisode> episodes,
    Map<String, WatchProgress> local,
  ) {
    if (episodes.isEmpty) {
      return const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Center(child: Text('Sem episódios disponíveis')),
        ),
      ];
    }

    final seasons = episodes.map((e) => e.season).toSet().toList()..sort();
    final season = seasons.contains(_season) ? _season! : seasons.first;
    final inSeason = episodes.where((e) => e.season == season).toList();

    return [
      if (seasons.length > 1)
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final s in seasons)
              ChoiceChip(
                label: Text(s == 0 ? 'Extras' : 'Temporada $s'),
                selected: s == season,
                showCheckmark: false,
                onSelected: (_) => setState(() => _season = s),
              ),
          ],
        ),
      const SizedBox(height: 8),
      for (final episode in inSeason)
        _EpisodeTile(
          episode: _withLocalProgress(episode, local[episode.id]),
          onTap: () => _play(episode),
        ),
    ];
  }

  Future<void> _play(SeriesEpisode episode) async {
    final seriesName = ref.read(seriesItemProvider(widget.seriesId))?.name;
    await playVod(
      context,
      ref,
      title: [?seriesName, 'T${episode.season}E${episode.number}'].join(' · '),
      target: episodeTarget(widget.seriesId, episode),
      request: (client) => client.episode(episode),
    );
    // O servidor guardou onde ficou (ou marcou como visto).
    if (mounted && ref.read(sourceClientProvider)?.tracksProgress == true) {
      ref.invalidate(seriesEpisodesProvider(widget.seriesId));
    }
  }
}

/// Junta o que se viu neste dispositivo ao que o servidor diz. No Xtream é
/// a única fonte; no Jellyfin o servidor sabe também o que se viu noutros
/// aparelhos, e prevalece.
SeriesEpisode _withLocalProgress(SeriesEpisode episode, WatchProgress? local) {
  if (local == null) return episode;
  final watched = episode.watched || local.finished;
  return SeriesEpisode(
    id: episode.id,
    season: episode.season,
    number: episode.number,
    title: episode.title,
    containerExtension: episode.containerExtension,
    plot: episode.plot,
    image: episode.image,
    duration: episode.duration,
    resumeAt: watched
        ? null
        : episode.resumeAt ?? (local.resumable ? local.position : null),
    watched: watched,
  );
}

class _Header extends StatelessWidget {
  const _Header({required this.series});

  final TvSeries series;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final details = [
      ?series.genre,
      ?series.releaseDate,
      if (series.rating > 0) '★ ${series.rating.toStringAsFixed(1)}',
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          height: 180,
          child: Poster(url: series.cover, title: series.name),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(series.name, style: theme.textTheme.titleLarge),
              if (details.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  details.join('  ·  '),
                  style: theme.textTheme.bodySmall?.copyWith(color: muted),
                ),
              ],
              if (series.plot != null) ...[
                const SizedBox(height: 12),
                Text(
                  series.plot!,
                  maxLines: 6,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _EpisodeTile extends StatelessWidget {
  const _EpisodeTile({required this.episode, required this.onTap});

  final SeriesEpisode episode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurfaceVariant;
    final resumeAt = episode.watched ? null : episode.resumeAt;
    final details = [
      ?episode.duration,
      if (resumeAt != null) 'ficaste em ${formatPosition(resumeAt)}',
    ];

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      leading: SizedBox(
        width: 36,
        child: Text(
          '${episode.number}',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: muted,
          ),
        ),
      ),
      title: Text(episode.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: details.isEmpty ? null : Text(details.join('  ·  ')),
      trailing: episode.watched
          ? Tooltip(
              message: 'Visto',
              child: Icon(Icons.check_circle, color: scheme.primary),
            )
          : const Icon(Icons.play_arrow_rounded),
      onTap: onTap,
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: onRetry,
            child: const Text('Tentar de novo'),
          ),
        ],
      ),
    );
  }
}
