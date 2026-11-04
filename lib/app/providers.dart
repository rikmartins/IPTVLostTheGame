import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import '../core/database/app_database.dart';
import '../data/local/models/sync_state.dart';
import '../data/repositories/auth_repository.dart';
import '../data/sync/xtream_sync_service.dart';

/// Aberto em `main()` antes do `runApp`, para que nenhum ecrã tenha de
/// esperar pela base de dados.
final appDatabaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError('Sobreposto no ProviderScope em main()'),
);

final isarProvider = Provider<Isar>(
  (ref) => ref.watch(appDatabaseProvider).isar,
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(isarProvider)),
);

final syncServiceProvider = Provider<XtreamSyncService>((ref) {
  final service = XtreamSyncService(
    databaseDirectory: ref.watch(appDatabaseProvider).directory,
  );
  ref.onDispose(service.dispose);
  return service;
});

/// Muda sempre que uma etapa de sincronização de [SyncKind] termina.
///
/// É este o sinal que as queries da UI observam, e não o `watch` das
/// coleções: os lotes da sincronização são gravados em modo `silent` e só o
/// `SyncState` do commit final notifica. Na primeira sincronização (nada
/// para apagar) um `watch` da coleção nunca chegaria a disparar.
final catalogVersionProvider = StreamProvider.family<int, SyncKind>((
  ref,
  kind,
) {
  var version = 0;
  return ref
      .watch(isarProvider)
      .syncStates
      .watchObjectLazy(kind.index, fireImmediately: true)
      // Valores sempre diferentes: o Riverpod 3 filtra notificações por ==.
      .map((_) => version++);
});
