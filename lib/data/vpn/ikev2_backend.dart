import 'dart:io';

import 'android_ikev2_backend.dart';
import 'ikev2_config.dart';
import 'vpn_backend.dart';
import 'windows_ikev2_backend.dart';

/// VPN IKEv2 com utilizador e palavra-passe (EAP-MSCHAPv2), usando o
/// cliente IKEv2 do próprio sistema: no Windows o da rede (sem
/// administrador) e no Android 11+ o `VpnManager`. Nada de motores VPN
/// embutidos.
abstract class Ikev2Backend {
  Future<bool> isSupported();

  Future<VpnStatus> status();

  /// Mudanças de estado, também as feitas fora da app (ex.: desligar no
  /// ícone de rede do Windows).
  Stream<VpnStatus> watch();

  /// Só termina com a VPN ligada. Lança [VpnException] com a mensagem a
  /// mostrar (credenciais erradas, servidor sem resposta, etc.).
  Future<void> connect(Ikev2Config config);

  Future<void> disconnect();

  /// Apaga a ligação do sistema (ao remover a configuração na app).
  Future<void> forget();
}

Ikev2Backend createIkev2Backend() {
  if (Platform.isWindows) return WindowsIkev2Backend();
  if (Platform.isAndroid) return AndroidIkev2Backend();
  return const UnsupportedIkev2Backend();
}

class UnsupportedIkev2Backend implements Ikev2Backend {
  const UnsupportedIkev2Backend();

  @override
  Future<bool> isSupported() async => false;

  @override
  Future<VpnStatus> status() async => VpnStatus.disconnected;

  @override
  Stream<VpnStatus> watch() => const Stream.empty();

  @override
  Future<void> connect(Ikev2Config config) =>
      throw const VpnException('O IKEv2 não está disponível neste sistema');

  @override
  Future<void> disconnect() async {}

  @override
  Future<void> forget() async {}
}
