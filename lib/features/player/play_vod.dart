import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/session_controller.dart';
import '../../core/utils/time_format.dart';
import '../../data/local/models/watch_progress.dart';
import '../../data/sources/source_client.dart';
import '../../data/sources/source_exception.dart';
import 'player_screen.dart';
import 'watch_progress.dart';

/// Abre um filme ou episódio em ecrã inteiro e grava onde se vai ficando
/// ([target]), para o "Continuar a ver".
///
/// Se se souber onde o utilizador ficou (o servidor Jellyfin, ou este
/// dispositivo), pergunta se quer continuar daí; com [resumeNow] continua
/// logo (vem do "Continuar a ver").
///
/// Completa quando o player fecha.
Future<void> playVod(
  BuildContext context,
  WidgetRef ref, {
  required String title,
  required WatchProgress target,
  required Future<PlaybackRequest?> Function(SourceClient client) request,
  bool resumeNow = false,
}) async {
  final client = ref.read(sourceClientProvider);
  if (client == null) return;
  final isar = ref.read(isarProvider);
  final messenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context);

  final PlaybackRequest? fromServer;
  try {
    fromServer = await request(client);
  } on SourceException catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(e.message)));
    return;
  }
  if (fromServer == null || !context.mounted) return;
  final playback = fromServer.alsoReportTo(LocalProgressReporter(isar, target));

  final local = isar.watchProgress.getSync(
    WatchProgress.idFor(target.kind, target.itemKey),
  );
  // O servidor sabe também o que se viu noutros aparelhos.
  final resumeAt =
      playback.resumeAt ??
      (local != null && local.resumable ? local.position : null);

  Duration? start;
  if (resumeAt != null && resumeAt >= WatchProgress.minPosition) {
    final resume = resumeNow
        ? true
        : await showDialog<bool>(
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
          PlayerScreen.vod(title: title, request: playback, start: start),
    ),
  );
}
