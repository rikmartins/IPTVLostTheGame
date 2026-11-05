import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import '../core/database/app_database.dart';
import '../data/local/models/sync_state.dart';
import '../data/repositories/auth_repository.dart';
import '../data/sync/catalog_sync_service.dart';
import 'profiles_controller.dart';

/// Aberto em `main()` antes do `runApp`, para que nenhum ecrã tenha de
/// esperar pela base de dados.
final appDatabaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError('Sobreposto no ProviderScope em main()'),
);

/// Base principal: definições do dispositivo (iguais em todos os perfis).
final mainIsarProvider = Provider<Isar>(
  (ref) => ref.watch(appDatabaseProvider).isar,
);

/// Catálogo do perfil ativo. Muda ao trocar de perfil, e tudo o que lê o
/// catálogo reconstrói-se com ele. Sem perfil, a base principal (vazia).
final isarProvider = Provider<Isar>((ref) {
  final database = ref.watch(appDatabaseProvider);
  final name = ref.watch(
    profilesProvider.select((s) => s.active?.databaseName),
  );
  if (name == null || name == AppDatabase.instanceName) return database.isar;
  // O controlador abre a base antes de ativar o perfil; o openSync é só
  // uma rede de segurança.
  return Isar.getInstance(name) ??
      Isar.openSync(
        AppDatabase.schemas,
        directory: database.directory,
        name: name,
      );
});

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(),
);

final syncServiceProvider = Provider<CatalogSyncService>((ref) {
  final service = CatalogSyncService(
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
