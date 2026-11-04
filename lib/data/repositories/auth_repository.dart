import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/storage/secure_storage.dart';
import '../local/models/account_info.dart';
import '../remote/xtream/xtream_api.dart';
import '../remote/xtream/xtream_credentials.dart';

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

  /// Lança `XtreamException` com a mensagem a mostrar.
  Future<AccountInfo> authenticate(XtreamCredentials credentials) async {
    final api = XtreamApi(credentials);
    try {
      return await api.authenticate();
    } finally {
      api.close();
    }
  }

  /// Dados do último login com "Memorizar dados".
  Future<XtreamCredentials?> remembered() async {
    final raw = await _storage.read(key: _rememberedKey);
    if (raw == null) return null;
    try {
      return XtreamCredentials.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      await _storage.delete(key: _rememberedKey);
      return null;
    }
  }

  /// `null` esquece os dados memorizados.
  Future<void> setRemembered(XtreamCredentials? credentials) {
    if (credentials == null) return _storage.delete(key: _rememberedKey);
    return _storage.write(
      key: _rememberedKey,
      value: jsonEncode(credentials.toJson()),
    );
  }
}
