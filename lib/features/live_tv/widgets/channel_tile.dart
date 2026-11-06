import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/time_format.dart';
import '../../catalog/widgets/artwork.dart';
import '../../epg/epg_providers.dart';
import '../favorites.dart';
import '../live_tv_providers.dart';

class ChannelTile extends ConsumerWidget {
  const ChannelTile({
    super.key,
    required this.id,
    required this.onTap,
    this.selected = false,
  });

  /// Altura fixa: com `itemExtent` a lista não mede linha a linha e o
  /// scroll em 50k canais custa o mesmo que em 50.
  static const height = 72.0;

  final int id;
  final VoidCallback onTap;

  /// Em pré-visualização: o próximo toque abre o ecrã inteiro.
  final bool selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final channel = ref.watch(liveChannelProvider(id));
    if (channel == null) return const SizedBox.shrink();
    final favorite = ref.watch(
      favoriteChannelsProvider.select((ids) => ids.contains(id)),
    );

    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    final epgId = channel.epgChannelId;
    final epg = epgId == null ? null : ref.watch(nowNextProvider(epgId));
    final current = epg?.current;
    final now = ref.watch(clockProvider).value ?? DateTime.now();

    // Material próprio: as ondas do toque ficam por cima da cor de seleção.
    return Material(
      color: selected
          ? theme.colorScheme.primary.withValues(alpha: 0.14)
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        // Clique longo (ou botão direito no computador): favorito.
        onLongPress: () => toggleFavorite(context, ref, channel),
        onSecondaryTap: () => toggleFavorite(context, ref, channel),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                child: Text(
                  channel.number > 0 ? '${channel.number}' : '',
                  textAlign: TextAlign.right,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: muted,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              const SizedBox(width: 14),
              ChannelLogo(url: channel.icon, name: channel.name),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      channel.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall,
                    ),
                    if (current != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        '${hhmm(current.start)}  ${current.title}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: muted,
                        ),
                      ),
                      const SizedBox(height: 6),
                      LinearProgressIndicator(
                        value: epg!.progressAt(now),
                        minHeight: 2,
                        borderRadius: BorderRadius.circular(1),
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                      ),
                    ],
                  ],
                ),
              ),
              if (favorite)
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Tooltip(
                    message: 'Favorito',
                    child: Icon(
                      Icons.star_rounded,
                      size: 18,
                      color: theme.colorScheme.tertiary,
                    ),
                  ),
                ),
              if (channel.hasCatchup)
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Tooltip(
                    message: 'Catch-up disponível',
                    child: Icon(Icons.history, size: 18, color: muted),
                  ),
                ),
              if (selected)
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Tooltip(
                    message: 'Carrega outra vez para ver em ecrã inteiro',
                    child: Icon(
                      Icons.fullscreen,
                      size: 22,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
