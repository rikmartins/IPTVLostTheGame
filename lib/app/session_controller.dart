import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/remote/jellyfin/jellyfin_source_client.dart';
import '../data/remote/xtream/xtream_source_client.dart';
import '../data/sources/credentials.dart';
import '../data/sources/source_client.dart';
import '../data/sync/search_index.dart';
import 'profiles_controller.dart';
import 'providers.dart';
import 'sync_controller.dart';

/// Credenciais do perfil ativo; `null` = sem perfil (ecrã de login).
///
/// Offline-first: a app abre logo com o catálogo que está no Isar e o que
/// estiver desatualizado sincroniza por trás, também ao mudar de perfil.
class SessionController extends Notifier<SourceCredentials?> {
  @override
  SourceCredentials? build() {
    // Só o perfil e as credenciais: mudar o nome não volta a sincronizar.
    ref.watch(
      profilesProvider.select((s) => (s.activeId, s.active?.credentials)),
    );
    final profile = ref.read(profilesProvider).active;
    if (profile != null) {
      // Depois do build: o isarProvider já aponta para este perfil.
      Future.microtask(() {
        ref.read(syncControllerProvider.notifier).syncIfStale(profile);
        // Catálogos de versões anteriores à pesquisa (uma vez só).
        ensureSearchIndex(
          ref.read(appDatabaseProvider).directory,
          profile.databaseName,
        ).ignore();
      });
    }
    return profile?.credentials;
  }

  Future<void> refresh() async {
    final profile = ref.read(profilesProvider).active;
    if (profile == null) return;
    await ref.read(syncControllerProvider.notifier).syncNow(profile);
  }

  /// Terminar sessão = remover o perfil ativo deste dispositivo.
  Future<void> logout() async {
    final id = ref.read(profilesProvider).activeId;
    if (id != null) await ref.read(profilesProvider.notifier).remove(id);
  }
}

final sessionProvider = NotifierProvider<SessionController, SourceCredentials?>(
  SessionController.new,
);

/// Streams e episódios do perfil ativo. Muda (e fecha o anterior) ao
/// trocar de perfil.
final sourceClientProvider = Provider<SourceClient?>((ref) {
  final credentials = ref.watch(sessionProvider);
  if (credentials == null) return null;
  final isar = ref.watch(isarProvider);
  final SourceClient client = switch (credentials) {
    final XtreamCredentials c => XtreamSourceClient(c, isar),
    final JellyfinCredentials c => JellyfinSourceClient(c, isar),
  };
  ref.onDispose(client.close);
  return client;
});
