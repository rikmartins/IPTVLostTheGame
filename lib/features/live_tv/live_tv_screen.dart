import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/sync_controller.dart';
import '../../app/widgets/section_scaffold.dart';
import '../../data/local/models/media_category.dart';
import '../catalog/category_providers.dart';
import '../catalog/widgets/category_list.dart';
import '../player/player_screen.dart';
import 'live_tv_providers.dart';
import 'widgets/channel_tile.dart';

class LiveTvScreen extends StatelessWidget {
  const LiveTvScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SectionScaffold(
      title: 'TV em direto',
      child: CatalogLayout(
        type: CategoryType.live,
        allLabel: 'Todos os canais',
        child: _ChannelList(),
      ),
    );
  }
}

class _ChannelList extends ConsumerWidget {
  const _ChannelList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryId = ref.watch(selectedCategoryProvider(CategoryType.live));
    final ids = ref.watch(liveChannelIdsProvider(categoryId));

    if (ids.isEmpty) {
      final syncing = ref.watch(syncControllerProvider).isRunning;
      return EmptyCatalog(
        icon: Icons.live_tv_outlined,
        message: syncing
            ? 'A descarregar a lista de canais…'
            : 'Sem canais neste grupo',
      );
    }

    return ListView.builder(
      // Guarda a posição de scroll de cada grupo ao alternar entre eles.
      key: PageStorageKey<String>('live-$categoryId'),
      itemExtent: ChannelTile.height,
      itemCount: ids.length,
      itemBuilder: (context, index) {
        final id = ids[index];
        return ChannelTile(
          key: ValueKey(id),
          id: id,
          // O grupo inteiro vai para o player: é a lista do zapping.
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) =>
                  PlayerScreen.live(channelIds: ids, initialIndex: index),
            ),
          ),
        );
      },
    );
  }
}
