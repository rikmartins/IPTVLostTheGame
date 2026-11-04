import 'package:flutter/foundation.dart';

import '../local/models/sync_state.dart';

enum SyncStatus { running, completed, failed, cancelled }

/// Evento enviado do isolate de sincronização para a UI.
@immutable
class SyncProgress {
  const SyncProgress(this.kind, this.status, {this.processed = 0, this.error});

  final SyncKind kind;
  final SyncStatus status;

  /// Itens gravados até agora nesta etapa.
  final int processed;

  /// Mensagem pronta a mostrar quando [status] é [SyncStatus.failed].
  final String? error;

  @override
  String toString() =>
      'SyncProgress(${kind.name}, ${status.name}, $processed'
      '${error == null ? '' : ', $error'})';
}
