import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/remote/xtream/xtream_credentials.dart';
import '../data/remote/xtream/xtream_stream_urls.dart';
import 'providers.dart';
import 'sync_controller.dart';

/// Sessão Xtream atual; `null` = sem login.
///
/// Offline-first: com uma sessão guardada a app abre logo com o que está no
/// Isar e a sincronização corre por trás.
class SessionController extends AsyncNotifier<XtreamCredentials?> {
  @override
  Future<XtreamCredentials?> build() async {
    final credentials = await ref.read(authRepositoryProvider).restore();
    if (credentials != null) {
      ref.read(syncControllerProvider.notifier).syncIfStale(credentials);
    }
    return credentials;
  }

  /// Lança `XtreamException` com a mensagem a mostrar no ecrã de login.
  Future<void> login({
    required String server,
    required String username,
    required String password,
    bool remember = true,
  }) async {
    final result = await ref
        .read(authRepositoryProvider)
        .login(
          server: server,
          username: username,
          password: password,
          remember: remember,
        );
    state = AsyncData(result.credentials);
    ref.read(syncControllerProvider.notifier).syncNow(result.credentials);
  }

  Future<void> refresh() async {
    final credentials = state.value;
    if (credentials == null) return;
    await ref.read(syncControllerProvider.notifier).syncNow(credentials);
  }

  Future<void> logout() async {
    // Primeiro parar o isolate, para não ficar um lote escrito depois do
    // clear.
    await ref.read(syncServiceProvider).stop();
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(null);
  }
}

final sessionProvider =
    AsyncNotifierProvider<SessionController, XtreamCredentials?>(
      SessionController.new,
    );

final streamUrlsProvider = Provider<XtreamStreamUrls?>((ref) {
  final credentials = ref.watch(sessionProvider).value;
  return credentials == null ? null : XtreamStreamUrls(credentials);
});
