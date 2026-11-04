import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/time_format.dart';
import '../../../data/local/models/epg_programme.dart';
import '../../../data/local/models/live_channel.dart';
import '../../catalog/widgets/artwork.dart';
import '../../epg/epg_providers.dart';
import '../../player/playback_session.dart';
import '../live_tv_providers.dart';

/// Pré-visualização do canal escolhido na lista: vídeo pequeno e guia.
///
/// * Ecrãs largos: painel à direita da lista, sempre presente (sem canal
///   explica como funciona).
/// * Telemóvel ([compact]): por cima da lista, só com o "agora / a seguir".
class ChannelPreview extends ConsumerWidget {
  const ChannelPreview({
    super.key,
    required this.channelId,
    required this.session,
    required this.onOpen,
    required this.onClose,
    this.compact = false,
    this.maxVideoHeight = double.infinity,
  });

  final int? channelId;

  /// Null até ao primeiro canal (o player só é criado quando é preciso).
  final PlaybackSession? session;

  /// Ecrã inteiro (o mesmo que carregar outra vez no canal).
  final VoidCallback onOpen;
  final VoidCallback onClose;
  final bool compact;
  final double maxVideoHeight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = channelId;
    final channel = id == null ? null : ref.watch(liveChannelProvider(id));
    if (id == null || channel == null) {
      return compact ? const SizedBox.shrink() : const _Placeholder();
    }

    final video = _PreviewVideo(
      channelId: id,
      session: session,
      onOpen: onOpen,
    );

    if (compact) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ColoredBox(
            color: Colors.black,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final height = (constraints.maxWidth * 9 / 16).clamp(
                  0.0,
                  maxVideoHeight,
                );
                return SizedBox(
                  height: height,
                  child: Center(
                    child: AspectRatio(aspectRatio: 16 / 9, child: video),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 4, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _NowNextSummary(channel: channel)),
                IconButton(
                  tooltip: 'Ecrã inteiro',
                  icon: const Icon(Icons.fullscreen),
                  onPressed: onOpen,
                ),
                IconButton(
                  tooltip: 'Fechar pré-visualização',
                  icon: const Icon(Icons.close),
                  onPressed: onClose,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
        ],
      );
    }

    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: ColoredBox(
              color: Colors.black,
              child: AspectRatio(aspectRatio: 16 / 9, child: video),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
          child: Row(
            children: [
              ChannelLogo(url: channel.icon, name: channel.name),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  channel.number > 0
                      ? '${channel.number}   ${channel.name}'
                      : channel.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Fechar pré-visualização',
                icon: const Icon(Icons.close),
                onPressed: onClose,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Carrega outra vez no canal para o ver em ecrã inteiro.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Divider(height: 1),
        Expanded(child: _Schedule(channel: channel)),
      ],
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.smart_display_outlined, size: 44, color: muted),
            const SizedBox(height: 12),
            Text(
              'Escolhe um canal para o pré-visualizar',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 6),
            Text(
              'Carrega outra vez no mesmo canal para o ver em ecrã inteiro.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(color: muted),
            ),
          ],
        ),
      ),
    );
  }
}

/// O vídeo, com o indicador de carregamento e o erro por cima. Carregar no
/// vídeo abre o ecrã inteiro.
class _PreviewVideo extends StatelessWidget {
  const _PreviewVideo({
    required this.channelId,
    required this.session,
    required this.onOpen,
  });

  final int channelId;
  final PlaybackSession? session;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final session = this.session;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (session != null) session.video(),
        if (session == null)
          const Center(child: CircularProgressIndicator())
        else
          _PlaybackStatus(session: session, channelId: channelId),
        Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onOpen,
            child: const Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Icon(
                  Icons.fullscreen,
                  color: Colors.white,
                  shadows: [Shadow(blurRadius: 6)],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PlaybackStatus extends StatelessWidget {
  const _PlaybackStatus({required this.session, required this.channelId});

  final PlaybackSession session;
  final int channelId;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int?>(
      valueListenable: session.liveChannel,
      builder: (context, playing, _) => ValueListenableBuilder<String?>(
        valueListenable: session.error,
        builder: (context, error, _) => StreamBuilder<bool>(
          stream: session.bufferingStream,
          initialData: session.buffering,
          builder: (context, buffering) {
            if (playing == channelId && error != null) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Não foi possível reproduzir este canal.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              );
            }
            // Ainda a tocar o canal anterior (o novo abre daqui a pouco) ou
            // a encher o buffer.
            if (playing != channelId || buffering.data == true) {
              return const Center(child: CircularProgressIndicator());
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

/// Telemóvel: nome, programa atual com progresso e o seguinte.
class _NowNextSummary extends ConsumerWidget {
  const _NowNextSummary({required this.channel});

  final LiveChannel channel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final epgId = channel.epgChannelId;
    final epg = epgId == null ? null : ref.watch(nowNextProvider(epgId));
    final now = ref.watch(clockProvider).value ?? DateTime.now();
    final current = epg?.current;
    final next = epg?.next;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          channel.number > 0
              ? '${channel.number}   ${channel.name}'
              : channel.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        if (current == null && next == null)
          Text(
            'Sem guia de programação para este canal',
            style: theme.textTheme.bodySmall?.copyWith(color: muted),
          ),
        if (current != null) ...[
          Text(
            '${hhmm(current.start)}–${hhmm(current.stop)}  ${current.title}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: epg!.progressAt(now),
            minHeight: 2,
            borderRadius: BorderRadius.circular(1),
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
          ),
        ],
        if (next != null) ...[
          const SizedBox(height: 4),
          Text(
            'A seguir  ${hhmm(next.start)}  ${next.title}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(color: muted),
          ),
        ],
      ],
    );
  }
}

/// Ecrãs largos: o programa atual (com descrição) e os seguintes.
class _Schedule extends ConsumerWidget {
  const _Schedule({required this.channel});

  final LiveChannel channel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final epgId = channel.epgChannelId;
    final programmes = epgId == null
        ? const <EpgProgramme>[]
        : ref.watch(channelScheduleProvider(epgId));
    final now = ref.watch(clockProvider).value ?? DateTime.now();

    if (programmes.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'Sem guia de programação (EPG) para este canal.',
          style: theme.textTheme.bodyMedium?.copyWith(color: muted),
        ),
      );
    }

    final today = DateUtils.dateOnly(now);
    // Coluna da hora com a mesma largura em todas as linhas.
    final timeWidth =
        programmes.any((p) => DateUtils.dateOnly(p.start.toLocal()) != today)
        ? 104.0
        : 48.0;
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: programmes.length,
      itemBuilder: (context, index) {
        final programme = programmes[index];
        final onAir = !programme.start.isAfter(now);
        final day = DateUtils.dateOnly(programme.start.toLocal());
        final dayLabel = day == today
            ? ''
            : day == today.add(const Duration(days: 1))
            ? 'Amanhã '
            : '${day.day}/${day.month} ';

        if (onAir) {
          final total = programme.stop.difference(programme.start).inSeconds;
          final progress = total <= 0
              ? null
              : (now.difference(programme.start).inSeconds / total).clamp(
                  0.0,
                  1.0,
                );
          return Container(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AGORA  ${hhmm(programme.start)}–${hhmm(programme.stop)}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  programme.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 3,
                  borderRadius: BorderRadius.circular(2),
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                ),
                if (programme.description case final description?
                    when description.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    description.trim(),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(color: muted),
                  ),
                ],
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: timeWidth,
                child: Text(
                  '$dayLabel${hhmm(programme.start)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: muted,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  programme.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
