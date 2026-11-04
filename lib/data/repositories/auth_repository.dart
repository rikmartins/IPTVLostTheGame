import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:isar_community/isar.dart';

import '../../core/storage/secure_storage.dart';
import '../local/models/account_info.dart';
import '../local/models/epg_programme.dart';
import '../local/models/live_channel.dart';
import '../local/models/media_category.dart';
import '../local/models/sync_state.dart';
import '../local/models/tv_series.dart';
import '../local/models/vod_movie.dart';
import '../remote/xtream/xtream_api.dart';
import '../remote/xtream/xtream_credentials.dart';

/// Login Xtream e persistência da sessão.
///
/// As credenciais vão para o cofre do sistema (Keystore, Keychain,
/// Credential Manager), nunca para o Isar.
class AuthRepository {
  AuthRepository(this._isar, {this._storage = appSecureStorage});

  final Isar _isar;
  final FlutterSecureStorage _storage;

  static const _credentialsKey = 'xtream_credentials';

  /// Valida no servidor e só depois grava. Lança `XtreamException`.
  Future<({XtreamCredentials credentials, AccountInfo account})> login({
    required String server,
    required String username,
    required String password,
  }) async {
    final credentials = XtreamCredentials.fromInput(
      server: server,
      username: username,
      password: password,
    );

    final api = XtreamApi(credentials);
    try {
      final account = await api.authenticate();

      // Outra conta/servidor: o catálogo antigo não pode misturar-se com o
      // novo até à primeira sincronização terminar.
      final previous = await restore();
      await _isar.writeTxn(() async {
        if (previous != null && previous != credentials) await _clearCatalog();
        await _isar.accounts.put(account);
      });
      await _storage.write(
        key: _credentialsKey,
        value: jsonEncode(credentials.toJson()),
      );

      return (credentials: credentials, account: account);
    } finally {
      api.close();
    }
  }

  /// Sessão guardada, para arrancar sem ecrã de login (offline-first: a UI
  /// abre logo com os dados do Isar e sincroniza em segundo plano).
  Future<XtreamCredentials?> restore() async {
    final raw = await _storage.read(key: _credentialsKey);
    if (raw == null) return null;
    try {
      return XtreamCredentials.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      await _storage.delete(key: _credentialsKey);
      return null;
    }
  }

  /// Cancelar qualquer sincronização em curso antes de chamar isto.
  Future<void> logout() async {
    await _storage.delete(key: _credentialsKey);
    await _isar.writeTxn(_clearCatalog);
  }

  /// Tudo o que vem do fornecedor. As definições do dispositivo (perfil de
  /// buffer, etc.) sobrevivem ao logout. Corre dentro de um writeTxn.
  Future<void> _clearCatalog() async {
    await _isar.accounts.clear();
    await _isar.categories.clear();
    await _isar.liveChannels.clear();
    await _isar.movies.clear();
    await _isar.series.clear();
    await _isar.epgProgrammes.clear();
    await _isar.syncStates.clear();
  }
}
