import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import '../../app/providers.dart';
import '../../app/session_controller.dart';
import '../../app/widgets/section_scaffold.dart';
import '../../core/utils/time_format.dart';
import '../../data/local/models/epg_programme.dart';
import '../../data/local/models/live_channel.dart';
import '../../data/local/models/media_category.dart';
import '../../data/local/models/sync_state.dart';
import '../../data/sources/source_exception.dart';
import '../catalog/category_providers.dart';
import '../catalog/widgets/artwork.dart';
import '../catalog/widgets/category_list.dart';
import '../live_tv/live_tv_providers.dart';
import '../player/player_screen.dart';
import 'epg_providers.dart';

/// Escala da grelha: 30 minutos = 120 px.
const _pxPerMinute = 4.0;
const _rowHeight = 64.0;
const _headerHeight = 32.0;

/// Dias que se podem escolher, a contar de hoje (o guia guarda um dia para
/// trás e três para a frente).
const _days = [-1, 0, 1, 2, 3];

/// Programas de um canal que tocam num dia (incluindo o que já vinha da
/// noite anterior). Um range scan no índice (canal, início).
final daySchedule = Provider.autoDispose
    .family<List<EpgProgramme>, (String, DateTime)>((ref, key) {
      final (epgChannelId, dayStart) = key;
      ref.watch(catalogVersionProvider(SyncKind.epg));
      final dayEnd = DateTime(dayStart.year, dayStart.month, dayStart.day + 1);
      return ref
          .watch(isarProvider)
          .epgProgrammes
          .where()
          .channelKeyEqualToStartBetween(
            EpgProgramme.keyFor(epgChannelId),
            dayStart.subtract(const Duration(hours: 12)),
            dayEnd,
            includeUpper: false,
          )
          .filter()
          .stopGreaterThan(dayStart)
          .findAllSync();
    });

/// Gravação disponível: o canal tem catch-up e o programa já começou há
/// menos dias do que o servidor guarda.
bool hasRecording(LiveChannel channel, EpgProgramme programme, DateTime now) {
  if (!channel.hasCatchup || !programme.start.isBefore(now)) return false;
  final days = math.max(channel.catchupDays, 1);
  return programme.start.isAfter(now.subtract(Duration(days: days)));
}

/// Guia em grelha: canais em linhas e o tempo na horizontal.
class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SectionScaffold(
      title: 'Guia',
      child: CatalogLayout(
        type: CategoryType.live,
        allLabel: 'Todos os canais',
        child: _Guide(),
      ),
    );
  }
}

class _Guide extends ConsumerStatefulWidget {
  const _Guide();

  @override
  ConsumerState<_Guide> createState() => _GuideState();
}

class _GuideState extends ConsumerState<_Guide> {
  final _horizontal = ScrollController();
  int _day = 0;
  bool _scrolledToNow = false;

  @override
  void dispose() {
    _horizontal.dispose();
    super.dispose();
  }

  DateTime _dayStart(DateTime now) =>
      DateTime(now.year, now.month, now.day + _day);

  /// Hoje abre meia hora antes de agora.
  void _scrollToNow(DateTime now) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_horizontal.hasClients) return;
      final minutes = now.difference(_dayStart(now)).inMinutes - 30;
      _horizontal.jumpTo(
        (minutes * _pxPerMinute).clamp(
          0.0,
          _horizontal.position.maxScrollExtent,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = ref.watch(clockProvider).value ?? DateTime.now();
    final categoryId = ref.watch(selectedCategoryProvider(CategoryType.live));
    final ids = ref.watch(liveChannelIdsProvider(categoryId));
    final dayStart = _dayStart(now);
    final dayEnd = DateTime(dayStart.year, dayStart.month, dayStart.day + 1);
    final dayWidth = dayEnd.difference(dayStart).inMinutes * _pxPerMinute;

    if (!_scrolledToNow && _day == 0) {
      _scrolledToNow = true;
      _scrollToNow(now);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DayPicker(
          selected: _day,
          now: now,
          onSelected: (day) {
            setState(() => _day = day);
            if (day == 0) _scrollToNow(now);
          },
        ),
        const Divider(),
        Expanded(
          child: ids.isEmpty
              ? const EmptyCatalog(
                  icon: Icons.view_timeline_outlined,
                  message: 'Sem canais neste grupo',
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final column = constraints.maxWidth >= 600 ? 200.0 : 112.0;
                    return Scrollbar(
                      controller: _horizontal,
                      child: SingleChildScrollView(
                        controller: _horizontal,
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: column + dayWidth,
                          height: constraints.maxHeight,
                          child: Column(
                            children: [
                              _TimeHeader(
                                dayStart: dayStart,
                                dayEnd: dayEnd,
                                column: column,
                                horizontal: _horizontal,
                              ),
                              Expanded(
                                child: Stack(
                                  children: [
                                    ListView.builder(
                                      key: PageStorageKey('guide-$categoryId'),
                                      itemExtent: _rowHeight,
                                      itemCount: ids.length,
                                      itemBuilder: (context, index) =>
                                          _GuideRow(
                                            key: ValueKey(ids[index]),
                                            ids: ids,
                                            index: index,
                                            dayStart: dayStart,
                                            column: column,
                                            dayWidth: dayWidth,
                                            horizontal: _horizontal,
                                            now: now,
                                          ),
                                    ),
                                    if (!now.isBefore(dayStart) &&
                                        now.isBefore(dayEnd))
                                      _NowLine(
                                        x:
                                            column +
                                            now.difference(dayStart).inMinutes *
                                                _pxPerMinute,
                                        column: column,
                                        horizontal: _horizontal,
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _DayPicker extends StatelessWidget {
  const _DayPicker({
    required this.selected,
    required this.now,
    required this.onSelected,
  });

  final int selected;
  final DateTime now;
  final ValueChanged<int> onSelected;

  static const _weekdays = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

  String _label(int day) {
    if (day == -1) return 'Ontem';
    if (day == 0) return 'Hoje';
    if (day == 1) return 'Amanhã';
    final date = DateTime(now.year, now.month, now.day + day);
    return '${_weekdays[date.weekday - 1]} ${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        itemCount: _days.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final day = _days[index];
          return ChoiceChip(
            label: Text(_label(day)),
            selected: day == selected,
            showCheckmark: false,
            onSelected: (_) => onSelected(day),
          );
        },
      ),
    );
  }
}

/// Mantém um filho no sítio enquanto a grelha anda para os lados (a
/// coluna dos canais e o canto do cabeçalho).
class _Pinned extends StatelessWidget {
  const _Pinned({required this.horizontal, required this.child});

  final ScrollController horizontal;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: horizontal,
      builder: (context, child) => Transform.translate(
        offset: Offset(horizontal.hasClients ? horizontal.offset : 0, 0),
        child: child,
      ),
      child: child,
    );
  }
}

class _TimeHeader extends StatelessWidget {
  const _TimeHeader({
    required this.dayStart,
    required this.dayEnd,
    required this.column,
    required this.horizontal,
  });

  final DateTime dayStart;
  final DateTime dayEnd;
  final double column;
  final ScrollController horizontal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.labelMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final slots = dayEnd.difference(dayStart).inMinutes ~/ 30;

    return SizedBox(
      height: _headerHeight,
      child: Stack(
        children: [
          for (var i = 0; i < slots; i++)
            Positioned(
              left: column + i * 30 * _pxPerMinute,
              top: 0,
              bottom: 0,
              width: 30 * _pxPerMinute,
              child: Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    hhmm(dayStart.add(Duration(minutes: i * 30))),
                    style: style,
                  ),
                ),
              ),
            ),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: column,
            child: _Pinned(
              horizontal: horizontal,
              child: ColoredBox(color: theme.colorScheme.surface),
            ),
          ),
        ],
      ),
    );
  }
}

/// Linha vertical na hora atual (escondida debaixo da coluna dos canais).
class _NowLine extends StatelessWidget {
  const _NowLine({
    required this.x,
    required this.column,
    required this.horizontal,
  });

  final double x;
  final double column;
  final ScrollController horizontal;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Positioned(
      left: x - 1,
      top: 0,
      bottom: 0,
      width: 2,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: horizontal,
          builder: (context, _) {
            final offset = horizontal.hasClients ? horizontal.offset : 0.0;
            return x - offset < column
                ? const SizedBox.shrink()
                : ColoredBox(color: color);
          },
        ),
      ),
    );
  }
}

class _GuideRow extends ConsumerWidget {
  const _GuideRow({
    super.key,
    required this.ids,
    required this.index,
    required this.dayStart,
    required this.column,
    required this.dayWidth,
    required this.horizontal,
    required this.now,
  });

  final List<int> ids;
  final int index;
  final DateTime dayStart;
  final double column;
  final double dayWidth;
  final ScrollController horizontal;
  final DateTime now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final channel = ref.watch(liveChannelProvider(ids[index]));
    if (channel == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final epgId = channel.epgChannelId;
    final programmes = epgId == null
        ? const <EpgProgramme>[]
        : ref.watch(daySchedule((epgId, dayStart)));
    final dayEnd = DateTime(dayStart.year, dayStart.month, dayStart.day + 1);

    double xOf(DateTime time) {
      final clamped = time.isBefore(dayStart)
          ? dayStart
          : time.isAfter(dayEnd)
          ? dayEnd
          : time;
      return clamped.difference(dayStart).inMinutes * _pxPerMinute;
    }

    void playLive() => _playLive(context, ids, index);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.dividerTheme.color ?? Colors.grey),
        ),
      ),
      child: Stack(
        children: [
          if (programmes.isEmpty)
            Positioned(
              left: column,
              top: 0,
              bottom: 0,
              width: math.min(dayWidth, 480),
              child: _Cell(
                title: 'Sem guia',
                subtitle: 'Carrega para ver em direto',
                muted: true,
                onTap: playLive,
              ),
            ),
          for (final programme in programmes)
            Positioned(
              left: column + xOf(programme.start),
              top: 0,
              bottom: 0,
              width: math.max(xOf(programme.stop) - xOf(programme.start), 4),
              child: _Cell(
                title: programme.title,
                subtitle: '${hhmm(programme.start)}–${hhmm(programme.stop)}',
                live:
                    !programme.start.isAfter(now) &&
                    programme.stop.isAfter(now),
                muted: !programme.stop.isAfter(now),
                recording: hasRecording(channel, programme, now),
                onTap: () => _showProgramme(
                  context,
                  ref,
                  channel: channel,
                  programme: programme,
                  ids: ids,
                  index: index,
                  now: now,
                ),
              ),
            ),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: column,
            child: _Pinned(
              horizontal: horizontal,
              child: Material(
                color: theme.colorScheme.surface,
                child: InkWell(
                  onTap: playLive,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        if (column >= 200) ...[
                          ChannelLogo(url: channel.icon, name: channel.name),
                          const SizedBox(width: 10),
                        ],
                        Expanded(
                          child: Text(
                            channel.number > 0
                                ? '${channel.number}  ${channel.name}'
                                : channel.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.live = false,
    this.muted = false,
    this.recording = false,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool live;
  final bool muted;
  final bool recording;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = muted && !recording
        ? scheme.onSurfaceVariant.withValues(alpha: 0.7)
        : scheme.onSurface;

    return Padding(
      padding: const EdgeInsets.all(2),
      child: Material(
        color: live
            ? scheme.primary.withValues(alpha: 0.16)
            : scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: onTap,
          // Com o comando, o programa com foco não pode ficar escondido
          // debaixo da coluna dos canais (que não se mexe).
          onFocusChange: (focused) {
            if (focused) {
              Scrollable.ensureVisible(
                context,
                alignment: 0.4,
                duration: const Duration(milliseconds: 120),
              );
            }
          },
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: live ? FontWeight.w600 : null,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    if (recording) ...[
                      Icon(Icons.history, size: 12, color: scheme.primary),
                      const SizedBox(width: 4),
                    ],
                    Expanded(
                      child: Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void _playLive(BuildContext context, List<int> ids, int index) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => PlayerScreen.live(channelIds: ids, initialIndex: index),
    ),
  );
}

/// Detalhes do programa, com o que se pode fazer: ver em direto (se está a
/// dar), ver a gravação ou do início (se o canal tem catch-up).
Future<void> _showProgramme(
  BuildContext context,
  WidgetRef ref, {
  required LiveChannel channel,
  required EpgProgramme programme,
  required List<int> ids,
  required int index,
  required DateTime now,
}) async {
  final airing = !programme.start.isAfter(now) && programme.stop.isAfter(now);
  final recording = hasRecording(channel, programme, now);
  final theme = Theme.of(context);

  final action = await showDialog<_Action>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(programme.title),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${channel.name} · ${_dayName(programme.start, now)} · '
                '${hhmm(programme.start)}–${hhmm(programme.stop)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (programme.description != null) ...[
                const SizedBox(height: 12),
                Text(programme.description!),
              ],
              if (!airing && !recording && programme.start.isBefore(now)) ...[
                const SizedBox(height: 12),
                Text(
                  'Este canal não tem gravações (catch-up).',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fechar'),
        ),
        if (recording && airing)
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(_Action.recording),
            child: const Text('Ver do início'),
          ),
        if (recording && !airing)
          FilledButton(
            autofocus: true,
            onPressed: () => Navigator.of(context).pop(_Action.recording),
            child: const Text('Ver gravação'),
          ),
        if (airing)
          FilledButton(
            autofocus: true,
            onPressed: () => Navigator.of(context).pop(_Action.live),
            child: const Text('Ver em direto'),
          ),
      ],
    ),
  );
  if (!context.mounted || action == null) return;

  switch (action) {
    case _Action.live:
      _playLive(context, ids, index);
    case _Action.recording:
      await _playRecording(context, ref, channel, programme);
  }
}

enum _Action { live, recording }

Future<void> _playRecording(
  BuildContext context,
  WidgetRef ref,
  LiveChannel channel,
  EpgProgramme programme,
) async {
  final client = ref.read(sourceClientProvider);
  if (client == null) return;
  final messenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context);
  try {
    final request = await client.catchup(channel.id, programme);
    if (request == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Gravação não disponível')),
      );
      return;
    }
    unawaited(
      navigator.push(
        MaterialPageRoute<void>(
          builder: (_) => PlayerScreen.vod(
            title: '${channel.name} · ${programme.title}',
            request: request,
          ),
        ),
      ),
    );
  } on SourceException catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(e.message)));
  }
}

String _dayName(DateTime time, DateTime now) {
  final local = time.toLocal();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(local.year, local.month, local.day);
  return switch (day.difference(today).inDays) {
    -1 => 'ontem',
    0 => 'hoje',
    1 => 'amanhã',
    _ => '${local.day}/${local.month}',
  };
}
