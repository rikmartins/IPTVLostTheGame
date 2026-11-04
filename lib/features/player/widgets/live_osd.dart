import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/time_format.dart';
import '../../catalog/widgets/artwork.dart';
import '../../epg/epg_providers.dart';
import '../../live_tv/live_tv_providers.dart';

/// Informação do canal por cima do vídeo: aparece ao abrir e a cada
/// zapping, e esconde-se sozinha (gerido pelo `PlayerScreen`).
class LiveOsd extends ConsumerWidget {
  const LiveOsd({
    super.key,
    required this.channelId,
    required this.position,
    required this.total,
    required this.onClose,
  });

  final int channelId;

  /// Posição do canal no grupo (1-based), para o "12 / 340".
  final int position;
  final int total;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final channel = ref.watch(liveChannelProvider(channelId));
    final epgId = channel?.epgChannelId;
    final epg = epgId == null ? null : ref.watch(nowNextProvider(epgId));
    final now = ref.watch(clockProvider).value ?? DateTime.now();
    final current = epg?.current;
    final next = epg?.next;
    final text = Theme.of(context).textTheme;

    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black54, Colors.transparent],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  BackButton(color: Colors.white, onPressed: onClose),
                  const Spacer(),
                  Text(
                    '$position / $total',
                    style: text.bodyMedium?.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(width: 20),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black87],
              ),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 56, 24, 24),
                child: channel == null
                    ? const SizedBox.shrink()
                    : Row(
                        children: [
                          ChannelLogo(url: channel.icon, name: channel.name),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  channel.number > 0
                                      ? '${channel.number}   ${channel.name}'
                                      : channel.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: text.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (current != null) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    '${hhmm(current.start)}–${hhmm(current.stop)}'
                                    '   ${current.title}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: text.bodyLarge?.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 420,
                                    ),
                                    child: LinearProgressIndicator(
                                      value: epg!.progressAt(now),
                                      minHeight: 3,
                                      borderRadius: BorderRadius.circular(2),
                                      backgroundColor: Colors.white24,
                                    ),
                                  ),
                                ],
                                if (next != null) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'A seguir  ${hhmm(next.start)}   ${next.title}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: text.bodyMedium?.copyWith(
                                      color: Colors.white60,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
