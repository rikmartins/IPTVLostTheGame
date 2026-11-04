import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/models/sync_state.dart';
import '../data/remote/xtream/xtream_credentials.dart';
import '../data/sync/sync_progress.dart';
import 'providers.dart';

/// O que a UI precisa de saber sobre a sincronização.
@immutable
class SyncActivity {
  const SyncActivity({this.running, this.lastFailure});

  /// Etapa em curso, ou null se não houver nenhuma.
  final SyncProgress? running;

  /// Última etapa que falhou desde que a sincronização começou.
  final SyncProgress? lastFailure;

  bool get isRunning => running != null;
}

class SyncController extends Notifier<SyncActivity> {
  @override
  SyncActivity build() {
    final subscription = ref
        .watch(syncServiceProvider)
        .progress
        .listen(_onProgress);
    ref.onDispose(subscription.cancel);
    return const SyncActivity();
  }

  /// No arranque: atualiza só o que tiver mais de [maxAge] (como o "update
  /// on app start" do TiviMate), para não descarregar tudo a cada abertura.
  Future<void> syncIfStale(
    XtreamCredentials credentials, {
    Duration maxAge = const Duration(hours: 12),
  }) {
    final states = ref.read(isarProvider).syncStates;
    final threshold = DateTime.now().subtract(maxAge);
    final stale = {
      for (final kind in SyncKind.values)
        if (states.getSync(kind.index)?.lastSuccessAt?.isAfter(threshold) !=
            true)
          kind,
    };
    if (stale.isEmpty) return Future.value();
    return _start(credentials, stale);
  }

  Future<void> syncNow(XtreamCredentials credentials) =>
      _start(credentials, {...SyncKind.values});

  Future<void> _start(XtreamCredentials credentials, Set<SyncKind> kinds) async {
    state = const SyncActivity();
    try {
      await ref.read(syncServiceProvider).start(credentials, kinds: kinds);
    } catch (e) {
      // Só chega aqui se o próprio isolate rebentar; as falhas por etapa
      // vêm como eventos de progresso.
      state = SyncActivity(
        lastFailure: SyncProgress(
          kinds.first,
          SyncStatus.failed,
          error: '$e',
        ),
      );
    }
  }

  void _onProgress(SyncProgress progress) {
    state = switch (progress.status) {
      SyncStatus.running => SyncActivity(
        running: progress,
        lastFailure: state.lastFailure,
      ),
      SyncStatus.failed => SyncActivity(lastFailure: progress),
      SyncStatus.completed || SyncStatus.cancelled => SyncActivity(
        lastFailure: state.lastFailure,
      ),
    };
  }
}

final syncControllerProvider = NotifierProvider<SyncController, SyncActivity>(
  SyncController.new,
);
