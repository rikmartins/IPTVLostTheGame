import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Cofre do sistema (Keystore, Keychain, DPAPI) para segredos: credenciais
/// Xtream e a configuração WireGuard (que inclui a chave privada).
///
/// No macOS usa o keychain clássico: o "data protection" exige Keychain
/// Sharing e um provisioning profile. A opção só tem efeito lá.
const appSecureStorage = FlutterSecureStorage(
  mOptions: MacOsOptions(usesDataProtectionKeychain: false),
);
