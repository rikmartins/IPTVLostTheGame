import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/storage/secure_storage.dart';
import 'ikev2_config.dart';

/// Que VPN o interruptor liga.
enum VpnKind { wireguard, ikev2 }

/// Configurações da VPN no cofre do sistema (o .conf tem a chave privada e
/// o IKEv2 a palavra-passe), nunca no Isar.
class VpnConfigStore {
  const VpnConfigStore([this._storage = appSecureStorage]);

  final FlutterSecureStorage _storage;

  static const _wireguardKey = 'wireguard_config';
  static const _ikev2Key = 'ikev2_config';
  static const _kindKey = 'vpn_kind';

  Future<String?> read() => _storage.read(key: _wireguardKey);

  Future<void> write(String config) =>
      _storage.write(key: _wireguardKey, value: config);

  Future<void> delete() => _storage.delete(key: _wireguardKey);

  Future<Ikev2Config?> readIkev2() async {
    final raw = await _storage.read(key: _ikev2Key);
    if (raw == null) return null;
    try {
      return Ikev2Config.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> writeIkev2(Ikev2Config config) =>
      _storage.write(key: _ikev2Key, value: jsonEncode(config.toJson()));

  Future<void> deleteIkev2() => _storage.delete(key: _ikev2Key);

  Future<VpnKind?> readKind() async {
    final raw = await _storage.read(key: _kindKey);
    return VpnKind.values.where((k) => k.name == raw).firstOrNull;
  }

  Future<void> writeKind(VpnKind kind) =>
      _storage.write(key: _kindKey, value: kind.name);
}
