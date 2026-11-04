import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/sync_controller.dart';
import '../../app/widgets/section_scaffold.dart';
import '../../data/local/models/media_category.dart';
import '../catalog/category_providers.dart';
import '../catalog/widgets/category_list.dart';
import '../catalog/widgets/poster_grid.dart';
import 'series_detail_screen.dart';
import 'series_providers.dart';

class SeriesScreen extends StatelessWidget {
  const SeriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SectionScaffold(
      title: 'Séries',
      child: CatalogLayout(
        type: CategoryType.series,
        allLabel: 'Atualizadas recentemente',
        child: _SeriesGrid(),
      ),
    );
  }
}

class _SeriesGrid extends ConsumerWidget {
  const _SeriesGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryId = ref.watch(
      selectedCategoryProvider(CategoryType.series),
    );
    final ids = ref.watch(seriesIdsProvider(categoryId));

    if (ids.isEmpty) {
      final syncing = ref.watch(syncControllerProvider).isRunning;
      return EmptyCatalog(
        icon: Icons.video_library_outlined,
        message: syncing
            ? 'A descarregar o catálogo de séries…'
            : 'Sem séries neste grupo',
      );
    }

    return PosterGrid(
      storageKey: 'series-$categoryId',
      ids: ids,
      itemBuilder: (context, id) => _SeriesTile(id: id),
    );
  }
}

class _SeriesTile extends ConsumerWidget {
  const _SeriesTile({required this.id});

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
