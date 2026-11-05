import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/storage/secure_storage.dart';
import '../local/models/account_info.dart';
import '../remote/jellyfin/jellyfin_client.dart';
import '../remote/xtream/xtream_api.dart';
import '../sources/credentials.dart';

/// O que se escreveu no último login com "Memorizar dados".
@immutable
class RememberedLogin {
  const RememberedLogin({
    required this.kind,
    required this.server,
    required this.username,
    required this.password,
  });

  factory RememberedLogin.fromJson(Map<String, dynamic> json) {
    return RememberedLogin(
      // Os dados memorizados antes do Jellyfin não têm "type".
      kind: json['type'] == 'jellyfin'
          ? SourceKind.jellyfin
          : SourceKind.xtream,
      server: json['serverUrl'] as String,
      username: json['username'] as String,
      password: json['password'] as String,
    );
  }

  final SourceKind kind;
  final String server;
  final String username;
  final String password;

  Map<String, String> toJson() => {
    'type': kind.name,
    'serverUrl': server,
    'username': username,
    'password': password,
  };

  @override
  bool operator ==(Object other) =>
      other is RememberedLogin &&
      other.kind == kind &&
      other.server == server &&
      other.username == username &&
      other.password == password;

  @override
  int get hashCode => Object.hash(kind, server, username, password);

  /// Nunca expor a password em logs.
  @override
  String toString() => 'RememberedLogin(${kind.name}, $server, $username)';
}

/// Validação do login no servidor e os dados de "Memorizar dados".
///
/// As contas guardadas são os perfis (ver `ProfileStore`); tudo o que tem
/// palavras-passe vai para o cofre do sistema, nunca para o Isar.
class AuthRepository {
  AuthRepository({this._storage = appSecureStorage});

  final FlutterSecureStorage _storage;

  /// "Memorizar dados": sobrevive a terminar sessão, para preencher o
  /// formulário.
  static const _rememberedKey = 'remembered_login';

  /// Lança `SourceException` com a mensagem a mostrar.
  Future<AccountInfo> authenticate(XtreamCredentials credentials) async {
    final api = XtreamApi(credentials);
    try {
      return await api.authenticate();
    } finally {
      api.close();
    }
  }

  /// Lança `SourceException` com a mensagem a mostrar.
  Future<JellyfinLogin> authenticateJellyfin({
    required String server,
    required String username,
    required String password,
    required String deviceId,
  }) {
    return JellyfinClient.signIn(
      server: server,
      username: username,
      password: password,
      deviceId: deviceId,
    );
  }

  /// Dados do último login com "Memorizar dados".
  Future<RememberedLogin?> remembered() async {
    final raw = await _storage.read(key: _rememberedKey);
    if (raw == null) return null;
    try {
      return RememberedLogin.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      await _storage.delete(key: _rememberedKey);
      return null;
    }
  }

  /// `null` esquece os dados memorizados.
  Future<void> setRemembered(RememberedLogin? login) {
    if (login == null) return _storage.delete(key: _rememberedKey);
    return _storage.write(
      key: _rememberedKey,
      value: jsonEncode(login.toJson()),
    );
  }
}
