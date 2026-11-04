import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:wireguard_flutter_plus/wireguard_flutter_plus.dart';

import 'vpn_backend.dart';
import 'wireguard_config.dart';

/// Android: VpnService do WireGuard através do wireguard_flutter_plus.
///
/// A primeira ligação mostra o diálogo de autorização de VPN do sistema;
/// depois disso liga sem perguntar.
class AndroidVpnBackend implements VpnBackend {
  final _wireGuard = WireGuardFlutter.instance;
  Future<void>? _initialized;

  @override
  bool get isSupported => true;

  @override
  bool get supportsAppOnly => true;

  Future<void> _ensureInitialized() => _initialized ??= _wireGuard.initialize(
    interfaceName: 'LostTheGame',
    vpnName: 'Lost the Game',
  );

  @override
  Future<VpnStatus> status() async {
    await _ensureInitialized();
    return _map(await _wireGuard.stage());
  }

  @override
  Stream<VpnStatus> watch() => _wireGuard.vpnStageSnapshot.map(_map);

  @override
  Future<void> connect(
    WireGuardConfig config, {
    required bool wholeDevice,
  }) async {
    await _ensureInitialized();
    try {
      if (!await _wireGuard.checkVpnPermission()) {
        throw const VpnException('A autorização de VPN foi recusada');
      }
      final package = (await PackageInfo.fromPlatform()).packageName;
      await _wireGuard.startVpn(
        serverAddress: config.endpoint,
        wgQuickConfig: config.text,
        providerBundleIdentifier: package,
        // "Só esta app": o plugin junta IncludedApplications ao [Interface]
        // e só o tráfego da app (canais, EPG, VOD) passa pelo túnel.
        includedApps: wholeDevice ? null : [package],
      );
    } on PlatformException catch (e) {
      throw VpnException('Não foi possível ligar a VPN (${e.message ?? e.code})');
    }
  }

  @override
  Future<void> disconnect() async {
    await _ensureInitialized();
    await _wireGuard.stopVpn();
  }

  static VpnStatus _map(VpnStage stage) => switch (stage) {
    VpnStage.connected => VpnStatus.connected,
    VpnStage.disconnecting || VpnStage.exiting => VpnStatus.disconnecting,
    VpnStage.disconnected ||
    VpnStage.noConnection ||
    VpnStage.denied => VpnStatus.disconnected,
    _ => VpnStatus.connecting,
  };
}
