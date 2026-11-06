import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../catalog/widgets/poster_grid.dart';
import '../live_tv/widgets/channel_tile.dart';
import '../player/play_vod.dart';
import '../player/player_screen.dart';
import '../player/watch_progress.dart';
import '../series/series_detail_screen.dart';
import '../series/series_providers.dart';
import '../vod/vod_providers.dart';
import 'search_providers.dart';

Future<void> openSearch(BuildContext context) {
  return Navigator.of(context)
      .push(MaterialPageRoute<void>(builder: (_) => const SearchScreen()));
}

/// Pesquisa global: canais, filmes e séries numa só caixa.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  /// Espera depois da última tecla antes de pesquisar.
  static const debounce = Duration(milliseconds: 250);

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _text = TextEditingController();
  Timer? _debounce;
  String _query = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _text.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(SearchScreen.debounce, () {
      if (mounted) setState(() => _query = value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _text,
          autofocus: true,
          textInputAction: TextInputAction.search,
          onChanged: _onChanged,
          onSubmitted: (value) => setState(() => _query = value),
          decoration: const InputDecoration(
            hintText: 'Canais, filmes ou séries',
            filled: false,
            border: InputBorder.none,
          ),
        ),
        actions: [
          if (_text.text.isNotEmpty)
            IconButton(
              tooltip: 'Limpar',
              icon: const Icon(Icons.close),
              onPressed: () => setState(() {
                _text.clear();
                _query = '';
              }),
            ),
        ],
      ),
      body: _query.trim().length < minSearchLength
          ? _Message(
              icon: Icons.search,
              text: 'Escreve pelo menos $minSearchLength letras.',
              color: muted,
            )
          : _Results(query: _query),
    );
  }
}

class _Results extends ConsumerWidget {
  const _Results({required this.query});

  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Enquanto procura a pesquisa nova, fica a anterior no ecrã.
    final results = switch (ref.watch(searchResultsProvider(query))) {
      AsyncValue(:final value?) => value,
      AsyncError() => const SearchResults(),
      _ => null,
    };
    if (results == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (results.isEmpty) {
      return _Message(
        icon: Icons.search_off,
        text: 'Nada encontrado para «${query.trim()}».',
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      );
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        if (results.movies.isNotEmpty) ...[
          _Header('Filmes', results.movies.length),
          _PosterRow(
            ids: results.movies,
            itemBuilder: (id) => _MovieResult(id: id),
          ),
        ],
        if (results.series.isNotEmpty) ...[
          _Header('Séries', results.series.length),
          _PosterRow(
            ids: results.series,
            itemBuilder: (id) => _SeriesResult(id: id),
          ),
        ],
        if (results.channels.isNotEmpty) ...[
          _Header('Canais', results.channels.length),
          for (final (index, id) in results.channels.indexed)
            SizedBox(
              height: ChannelTile.height,
              child: ChannelTile(
                key: ValueKey(id),
                id: id,
                // Abre em ecrã inteiro; o zapping passa pelos resultados.
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => PlayerScreen.live(
                      channelIds: results.channels,
                      initialIndex: index,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.title, this.count);

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Text(
        '$title · $count',
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// Fila horizontal de posters (o comando da TV anda com esquerda/direita).
class _PosterRow extends StatelessWidget {
  const _PosterRow({required this.ids, required this.itemBuilder});

  final List<int> ids;
  final Widget Function(int id) itemBuilder;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 270,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: ids.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) => SizedBox(
          width: 140,
          child: KeyedSubtree(
            key: ValueKey(ids[index]),
            child: itemBuilder(ids[index]),
          ),
        ),
      ),
    );
  }
}

class _MovieResult extends ConsumerWidget {
  const _MovieResult({required this.id});

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movie = ref.watch(movieProvider(id));
    if (movie == null) return const SizedBox.shrink();
    return PosterTile(
      title: movie.name,
      imageUrl: movie.poster,
      rating: movie.rating,
      onTap: () => playVod(
        context,
        ref,
        title: movie.name,
        target: movieTarget(movie),
        request: (client) => client.movie(movie.id),
      ),
    );
  }
}

class _SeriesResult extends ConsumerWidget {
  const _SeriesResult({required this.id});

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final series = ref.watch(seriesItemProvider(id));
    if (series == null) return const SizedBox.shrink();
    return PosterTile(
      title: series.name,
      imageUrl: series.cover,
      rating: series.rating,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => SeriesDetailScreen(seriesId: series.id),
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text, required this.color});

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
