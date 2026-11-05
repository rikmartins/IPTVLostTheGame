import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/sync_controller.dart';
import '../../app/widgets/section_scaffold.dart';
import '../../data/local/models/media_category.dart';
import '../catalog/category_providers.dart';
import '../catalog/widgets/category_list.dart';
import '../catalog/widgets/poster_grid.dart';
import '../player/play_vod.dart';
import 'vod_providers.dart';

class MoviesScreen extends StatelessWidget {
  const MoviesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SectionScaffold(
      title: 'Filmes',
      child: CatalogLayout(
        type: CategoryType.movie,
        allLabel: 'Adicionados recentemente',
        child: _MovieGrid(),
      ),
    );
  }
}

class _MovieGrid extends ConsumerWidget {
  const _MovieGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryId = ref.watch(selectedCategoryProvider(CategoryType.movie));
    final ids = ref.watch(movieIdsProvider(categoryId));

    if (ids.isEmpty) {
      final syncing = ref.watch(syncControllerProvider).isRunning;
      return EmptyCatalog(
        icon: Icons.movie_outlined,
        message: syncing
            ? 'A descarregar o catálogo de filmes…'
            : 'Sem filmes neste grupo',
      );
    }

    return PosterGrid(
      storageKey: 'movies-$categoryId',
      ids: ids,
      itemBuilder: (context, id) => _MovieTile(id: id),
    );
  }
}

class _MovieTile extends ConsumerWidget {
  const _MovieTile({required this.id});

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
        request: (client) => client.movie(movie.id),
      ),
    );
  }
}
