import 'dart:io';

import 'android_vpn_backend.dart';
import 'windows_vpn_backend.dart';
import 'wireguard_config.dart';

enum VpnStatus { disconnected, connecting, connected, disconnecting }

class VpnException implements Exception {
  const VpnException(this.message);

  /// Pronta a mostrar ao utilizador.
  final String message;

  @override
  String toString() => 'VpnException: $message';
}

/// Túnel WireGuard ao nível do sistema, por plataforma.
abstract class VpnBackend {
  bool get isSupported;

  /// Só o Android consegue meter apenas o tráfego desta app no túnel.
  bool get supportsAppOnly;

  Future<VpnStatus> status();

  /// Mudanças de estado, incluindo as que não vêm da app (ex.: o
  /// utilizador desligou a VPN nas definições do Android).
  Stream<VpnStatus> watch();

  /// [wholeDevice] só conta onde [supportsAppOnly] é verdade.
  Future<void> connect(WireGuardConfig config, {required bool wholeDevice});

  Future<void> disconnect();
}

VpnBackend createVpnBackend() {
  if (Platform.isAndroid) return AndroidVpnBackend();
  if (Platform.isWindows) return WindowsVpnBackend();
  // iOS e macOS precisam de uma Network Extension (target próprio e conta
  // Apple Developer com essa capability).
  return const UnsupportedVpnBackend();
}

class UnsupportedVpnBackend implements VpnBackend {
  const UnsupportedVpnBackend();

  @override
  bool get isSupported => false;

  @override
  bool get supportsAppOnly => false;

  @override
  Future<VpnStatus> status() async => VpnStatus.disconnected;

  @override
  Stream<VpnStatus> watch() => const Stream.empty();

  @override
  Future<void> connect(WireGuardConfig config, {required bool wholeDevice}) =>
      throw const VpnException('A VPN ainda não está disponível neste sistema');

  @override
  Future<void> disconnect() async {}
}
