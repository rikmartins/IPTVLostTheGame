import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/models/sync_state.dart';
import '../session_controller.dart';
import '../sync_controller.dart';

/// Indicador discreto na barra superior: a sincronização nunca bloqueia a
/// grelha, só se anuncia aqui.
class SyncIndicator extends ConsumerWidget {
  const SyncIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activity = ref.watch(syncControllerProvider);
    final theme = Theme.of(context);

    final running = activity.running;
    if (running != null) {
      final label = running.processed > 0
          ? '${running.kind.label} · ${formatCount(running.processed)}'
          : 'A atualizar ${running.kind.label.toLowerCase()}';
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox.square(
            dimension: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 8),
        ],
      );
    }

    final failure = activity.lastFailure;
    if (failure != null) {
      return IconButton(
        tooltip:
            '${failure.kind.label}: ${failure.error ?? 'erro'}\n'
            'Clica para tentar de novo.',
        icon: Icon(Icons.sync_problem, color: theme.colorScheme.error),
        onPressed: () => ref.read(sessionProvider.notifier).refresh(),
      );
    }

    return const SizedBox.shrink();
  }
}

extension SyncKindLabel on SyncKind {
  String get label => switch (this) {
    SyncKind.live => 'Canais',
    SyncKind.epg => 'Guia TV',
    SyncKind.movies => 'Filmes',
    SyncKind.series => 'Séries',
  };
}

/// 12345 → "12 345" (espaço fino inquebrável, como em pt-PT).
String formatCount(int value) {
  final digits = value.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(' ');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}
