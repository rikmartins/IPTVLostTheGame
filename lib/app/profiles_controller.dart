import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import '../core/database/app_database.dart';
import '../data/local/models/account_info.dart';
import '../data/profiles/profile.dart';
import '../data/profiles/profile_store.dart';
import '../data/repositories/auth_repository.dart';
import '../data/sources/credentials.dart';
import 'providers.dart';

/// Lido do cofre em `main()` antes do `runApp` (a app abre logo no perfil
/// certo, sem ecrã intermédio).
final initialProfilesProvider = Provider<ProfilesState>(
  (ref) => throw UnimplementedError('Sobreposto no ProviderScope em main()'),
);

final profileStoreProvider = Provider<ProfileStore>(
  (ref) => const ProfileStore(),
);

/// Perfis guardados e o ativo. O catálogo do ativo é o `isarProvider`.
class ProfilesController extends Notifier<ProfilesState> {
  @override
  ProfilesState build() => ref.watch(initialProfilesProvider);

  String get _directory => ref.read(appDatabaseProvider).directory;

  ProfileStore get _store => ref.read(profileStoreProvider);

  /// Valida no servidor e ativa o perfil. A mesma conta (servidor e
  /// utilizador) atualiza o perfil que já existe; outra conta cria um novo,
  /// com o seu próprio catálogo. Lança `SourceException`.
  Future<Profile> signIn({
    SourceKind kind = SourceKind.xtream,
    required String name,
    required String server,
    required String username,
    required String password,
    bool remember = true,
  }) async {
    final auth = ref.read(authRepositoryProvider);
    final SourceCredentials credentials;
    final AccountInfo account;
    String? serverName;
    switch (kind) {
      case SourceKind.xtream:
        final xtream = XtreamCredentials.fromInput(
          server: server,
          username: username,
          password: password,
        );
        account = await auth.authenticate(xtream);
        credentials = xtream;
      case SourceKind.jellyfin:
        final login = await auth.authenticateJellyfin(
          server: server,
          username: username,
          password: password,
          deviceId: _jellyfinDeviceId(server, username),
        );
        credentials = login.credentials;
        account = login.account;
        serverName = login.serverName;
    }

    final trimmed = name.trim();
    final existing = state.profiles
        .where((p) => p.isSameAccount(credentials))
        .firstOrNull;
    final Profile profile;
    if (existing != null) {
      profile = existing.copyWith(
        credentials: credentials,
        name: trimmed.isEmpty ? null : trimmed,
      );
    } else {
      final id = newProfileId();
      // A base principal guarda o catálogo do primeiro perfil (é onde já
      // estava o das versões de perfil único) enquanto nenhum a usar.
      final mainInUse = state.profiles.any(
        (p) => p.databaseName == AppDatabase.instanceName,
      );
      profile = Profile(
        id: id,
        name: trimmed.isEmpty
            ? defaultProfileName(
                credentials,
                state.profiles.length,
                serverName: serverName,
              )
            : trimmed,
        databaseName: mainInUse
            ? AppDatabase.profileInstanceName(id)
            : AppDatabase.instanceName,
        credentials: credentials,
      );
    }

    final isar = await AppDatabase.openCatalog(
      _directory,
      profile.databaseName,
    );
    await isar.writeTxn(() => isar.accounts.put(account));
    await auth.setRemembered(
      remember
          ? RememberedLogin(
              kind: kind,
              server: credentials.serverUrl,
              username: username.trim(),
              password: password,
            )
          : null,
    );

    await _store.saveProfile(profile);
    await _activate(
      ProfilesState(
        profiles: [
          for (final p in state.profiles) p.id == profile.id ? profile : p,
          if (existing == null) profile,
        ],
        activeId: profile.id,
      ),
    );
    return profile;
  }

  /// Entrar outra vez numa conta Jellyfin que já é um perfil reutiliza o
  /// ID de dispositivo: o servidor substitui a sessão antiga em vez de
  /// juntar mais um dispositivo à lista.
  String _jellyfinDeviceId(String server, String username) {
    final urls = JellyfinCredentials.serverCandidates(server);
    final user = username.trim().toLowerCase();
    for (final profile in state.profiles) {
      if (profile.credentials case final JellyfinCredentials c
          when urls.contains(c.serverUrl) && c.username.toLowerCase() == user) {
        return c.deviceId;
      }
    }
    return newDeviceId();
  }

  /// Imediato: o catálogo do outro perfil já está no dispositivo. O que
  /// estiver desatualizado sincroniza por trás (ver `SessionController`).
  Future<void> switchTo(String id) async {
    final profile = state.byId(id);
    if (profile == null || id == state.activeId) return;
    await AppDatabase.openCatalog(_directory, profile.databaseName);
    await _activate(
      ProfilesState(profiles: state.profiles, activeId: id),
    );
  }

  Future<void> rename(String id, String name) async {
    final profile = state.byId(id);
    final trimmed = name.trim();
    if (profile == null || trimmed.isEmpty || trimmed == profile.name) return;
    final renamed = profile.copyWith(name: trimmed);
    await _store.saveProfile(renamed);
    state = ProfilesState(
      profiles: [for (final p in state.profiles) p.id == id ? renamed : p],
      activeId: state.activeId,
    );
  }

  /// Apaga o perfil e o seu catálogo. Se era o ativo, passa para o
  /// seguinte; sem nenhum, a app volta ao login.
  Future<void> remove(String id) async {
    final profile = state.byId(id);
    if (profile == null) return;
    final wasActive = id == state.activeId;
    if (wasActive) await ref.read(syncServiceProvider).stop();

    final rest = [
      for (final p in state.profiles)
        if (p.id != id) p,
    ];
    final next = ProfilesState(
      profiles: rest,
      activeId: wasActive ? rest.firstOrNull?.id : state.activeId,
    );
    final nextActive = next.active;
    if (wasActive && nextActive != null) {
      await AppDatabase.openCatalog(_directory, nextActive.databaseName);
    }
    await _store.saveIndex(next);
    await _store.deleteProfile(id);
    state = next;

    if (wasActive) {
      // Dar tempo aos ecrãs do perfil removido para largarem a instância.
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }
    await _discardCatalog(profile);
  }

  Future<void> _activate(ProfilesState next) async {
    // A sincronização em curso escreve no catálogo do perfil anterior.
    if (next.activeId != state.activeId) {
      await ref.read(syncServiceProvider).stop();
    }
    await _store.saveIndex(next);
    state = next;
  }

  Future<void> _discardCatalog(Profile profile) async {
    if (profile.databaseName == AppDatabase.instanceName) {
      // A base principal também tem as definições: só sai o catálogo.
      await AppDatabase.clearCatalog(ref.read(mainIsarProvider));
      return;
    }
    try {
      final isar =
          Isar.getInstance(profile.databaseName) ??
          await AppDatabase.openInstance(
            _directory,
            name: profile.databaseName,
          );
      await isar.close(deleteFromDisk: true);
    } catch (_) {
      // Os ficheiros que ficarem são apagados no próximo arranque.
    }
  }
}

final profilesProvider = NotifierProvider<ProfilesController, ProfilesState>(
  ProfilesController.new,
);
