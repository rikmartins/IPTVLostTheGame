import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/storage/secure_storage.dart';

/// O .conf importado vai para o cofre do sistema (tem a chave privada),
/// nunca para o Isar.
class VpnConfigStore {
  const VpnConfigStore([this._storage = appSecureStorage]);

  final FlutterSecureStorage _storage;

  static const _key = 'wireguard_config';

  Future<String?> read() => _storage.read(key: _key);

  Future<void> write(String config) => _storage.write(key: _key, value: config);

  Future<void> delete() => _storage.delete(key: _key);
}
