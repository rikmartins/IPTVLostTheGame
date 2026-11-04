import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/storage/secure_storage.dart';
import '../remote/xtream/xtream_credentials.dart';
import 'profile.dart';

/// Perfis no cofre do sistema (têm a palavra-passe), nunca no Isar.
///
/// Uma entrada por perfil mais um índice com a ordem e o perfil ativo: cada
/// valor fica pequeno (o Credential Manager do Windows limita o tamanho).
/// Grava-se sempre o perfil antes do índice, para um índice nunca apontar
/// para um perfil que não existe.
class ProfileStore {
  const ProfileStore([this._storage = appSecureStorage]);

  final FlutterSecureStorage _storage;

  static const _indexKey = 'profiles_index';

  /// Sessão única das versões até à 0.1.3.
  static const _legacyKey = 'xtream_credentials';

  static String _profileKey(String id) => 'profile_$id';

  /// [legacyDatabaseName]: a base de dados onde já está o catálogo da sessão
  /// antiga, que passa a ser a do primeiro perfil (sem sincronizar de novo).
  Future<ProfilesState> load({required String legacyDatabaseName}) async {
    final rawIndex = await _storage.read(key: _indexKey);
    if (rawIndex == null) return _migrateLegacy(legacyDatabaseName);

    Map<String, dynamic> index;
    try {
      index = jsonDecode(rawIndex) as Map<String, dynamic>;
    } catch (_) {
      index = const {};
    }
    final ids = (index['ids'] as List<dynamic>? ?? const []).cast<String>();

    final profiles = <Profile>[];
    for (final id in ids) {
      final raw = await _storage.read(key: _profileKey(id));
      if (raw == null) continue;
      try {
        profiles.add(
          Profile.fromJson(id, jsonDecode(raw) as Map<String, dynamic>),
        );
      } catch (_) {
        // Entrada corrompida: fica de fora, as outras continuam.
      }
    }

    final active = index['active'] as String?;
    return ProfilesState(
      profiles: profiles,
      activeId: profiles.any((p) => p.id == active)
          ? active
          : profiles.firstOrNull?.id,
    );
  }

  Future<void> saveProfile(Profile profile) => _storage.write(
    key: _profileKey(profile.id),
    value: jsonEncode(profile.toJson()),
  );

  Future<void> deleteProfile(String id) =>
      _storage.delete(key: _profileKey(id));

  Future<void> saveIndex(ProfilesState state) => _storage.write(
    key: _indexKey,
    value: jsonEncode({
      'active': state.activeId,
      'ids': [for (final profile in state.profiles) profile.id],
    }),
  );

  Future<ProfilesState> _migrateLegacy(String databaseName) async {
    final raw = await _storage.read(key: _legacyKey);
    if (raw == null) return const ProfilesState();

    final XtreamCredentials credentials;
    try {
      credentials = XtreamCredentials.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      await _storage.delete(key: _legacyKey);
      return const ProfilesState();
    }

    final profile = Profile(
      id: newProfileId(),
      name: defaultProfileName(credentials, 0),
      databaseName: databaseName,
      credentials: credentials,
    );
    final state = ProfilesState(profiles: [profile], activeId: profile.id);
    await saveProfile(profile);
    await saveIndex(state);
    await _storage.delete(key: _legacyKey);
    return state;
  }
}
