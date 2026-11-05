import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/session_controller.dart';
import '../../core/utils/time_format.dart';
import '../../data/sources/source_client.dart';
import '../../data/sources/source_exception.dart';
import 'player_screen.dart';

/// Menos do que isto não vale a pena perguntar se quer continuar.
const _minResume = Duration(seconds: 10);

/// Abre um filme ou episódio em ecrã inteiro. Se o servidor souber onde o
/// utilizador ficou (Jellyfin), pergunta se quer continuar daí.
///
/// Completa quando o player fecha.
Future<void> playVod(
  BuildContext context,
  WidgetRef ref, {
  required String title,
  required Future<PlaybackRequest?> Function(SourceClient client) request,
}) async {
  final client = ref.read(sourceClientProvider);
  if (client == null) return;
  final messenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context);

  final PlaybackRequest? playback;
  try {
    playback = await request(client);
  } on SourceException catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(e.message)));
    return;
  }
  if (playback == null || !context.mounted) return;

  Duration? start;
  final resumeAt = playback.resumeAt;
  if (resumeAt != null && resumeAt >= _minResume) {
    final resume = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text('Ficaste em ${formatPosition(resumeAt)}.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Começar do início'),
          ),
          FilledButton(
            // No comando da TV, OK continua.
            autofocus: true,
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
    if (resume == null) return;
    if (resume) start = resumeAt;
  }

  await navigator.push(
    MaterialPageRoute<void>(
      builder: (_) =>
          PlayerScreen.vod(title: title, request: playback!, start: start),
    ),
  );
}
