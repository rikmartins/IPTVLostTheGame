import 'dart:async';
import 'dart:isolate';

import '../local/models/sync_state.dart';
import '../remote/xtream/xtream_credentials.dart';
import 'sync_progress.dart';
import 'sync_worker.dart';

/// Sincroniza o catálogo Xtream para o Isar num isolate dedicado.
///
/// Download, parse de JSON/XML e escrita correm todos fora do isolate da
/// UI, por isso a grelha continua fluida mesmo durante uma sincronização de
/// 100k+ itens. A UI não espera por isto: observa o Isar (`watch`) e é
/// notificada no fim de cada etapa.
class XtreamSyncService {
  XtreamSyncService({required this.databaseDirectory});

  final String databaseDirectory;

  final _progress = StreamController<SyncProgress>.broadcast();
  Future<void>? _current;
  SendPort? _control;

  /// Broadcast: vários widgets (barra de progresso, definições) podem
  /// observar. Deixar de ouvir não cancela a sincronização.
  Stream<SyncProgress> get progress => _progress.stream;

  bool get isRunning => _current != null;

  /// Arranca uma sincronização, ou devolve a que já está em curso.
  /// Completa quando o isolate termina.
  Future<void> start(
    XtreamCredentials credentials, {
    required String databaseName,
    Set<SyncKind> kinds = const {...SyncKind.values},
    Duration epgPast = const Duration(days: 1),
    Duration epgFuture = const Duration(days: 3),
  }) {
    return _current ??= _run(
      (events) => SyncRequest(
        events: events,
        databaseDirectory: databaseDirectory,
        databaseName: databaseName,
        credentials: credentials,
        kinds: kinds,
        epgPast: epgPast,
        epgFuture: epgFuture,
      ),
    ).whenComplete(() => _current = null);
  }

  /// Cancelamento cooperativo: o worker para no lote seguinte e os dados
  /// já existentes ficam intactos.
  void cancel() => _control?.send(null);

  /// Cancela e espera que o isolate termine (ex.: antes de limpar a base de
  /// dados no logout, para não ficar um lote a meio).
  Future<void> stop() async {
    final current = _current;
    if (current == null) return;
    cancel();
    try {
      await current;
    } catch (_) {
      // O resultado de uma sincronização cancelada não interessa aqui.
    }
  }

  void dispose() {
    cancel();
    _progress.close();
  }

  Future<void> _run(SyncRequest Function(SendPort events) buildRequest) async {
    final port = ReceivePort('xtream-sync');
    final done = Completer<void>();

    port.listen((Object? message) {
      switch (message) {
        case final SendPort control:
          _control = control;
        case final SyncProgress progress:
          if (!_progress.isClosed) _progress.add(progress);
        // Erro não tratado no isolate (formato do `onError` do spawn).
        case [final String error, final String? stack]:
          if (!done.isCompleted) {
            done.completeError(
              StateError(error),
              stack == null ? null : StackTrace.fromString(stack),
            );
          }
        // onExit.
        case null:
          port.close();
          _control = null;
          if (!done.isCompleted) done.complete();
      }
    });

    try {
      await Isolate.spawn(
        runSyncWorker,
        buildRequest(port.sendPort),
        onError: port.sendPort,
        onExit: port.sendPort,
        debugName: 'xtream-sync',
      );
    } catch (_) {
      port.close();
      rethrow;
    }
    return done.future;
  }
}
