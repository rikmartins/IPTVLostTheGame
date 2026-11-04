import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/remote/xtream/xtream_credentials.dart';
import '../data/remote/xtream/xtream_stream_urls.dart';
import 'profiles_controller.dart';
import 'sync_controller.dart';

/// Credenciais do perfil ativo; `null` = sem perfil (ecrã de login).
///
/// Offline-first: a app abre logo com o catálogo que está no Isar e o que
/// estiver desatualizado sincroniza por trás, também ao mudar de perfil.
class SessionController extends Notifier<XtreamCredentials?> {
  @override
  XtreamCredentials? build() {
    // Só o perfil e as credenciais: mudar o nome não volta a sincronizar.
    ref.watch(
      profilesProvider.select((s) => (s.activeId, s.active?.credentials)),
    );
    final profile = ref.read(profilesProvider).active;
    if (profile != null) {
      // Depois do build: o isarProvider já aponta para este perfil.
      Future.microtask(
        () => ref.read(syncControllerProvider.notifier).syncIfStale(profile),
      );
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

final sessionProvider = NotifierProvider<SessionController, XtreamCredentials?>(
  SessionController.new,
);

final streamUrlsProvider = Provider<XtreamStreamUrls?>((ref) {
  final credentials = ref.watch(sessionProvider);
  return credentials == null ? null : XtreamStreamUrls(credentials);
});
