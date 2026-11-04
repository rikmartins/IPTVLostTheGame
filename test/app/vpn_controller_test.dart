import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iptv_app/app/settings_controller.dart';
import 'package:iptv_app/app/vpn_controller.dart';
import 'package:iptv_app/data/local/models/app_settings.dart';
import 'package:iptv_app/data/vpn/vpn_backend.dart';
import 'package:iptv_app/data/vpn/vpn_config_store.dart';
import 'package:iptv_app/data/vpn/wireguard_config.dart';

// Chaves de exemplo (base64 de 32 bytes), sem valor real.
String _conf(String allowed) => '''
[Interface]
PrivateKey = yAnz5TF+lXXJte14tji3zlMNq+hd2rYUIgJBgB3fBmk=
Address = 10.8.0.2/32

[Peer]
PublicKey = xTIBA5rboUvnH4htodjb6e697QjLERt1NAB4mZqp8Dg=
Endpoint = vpn.exemplo.pt:51820
AllowedIPs = $allowed
''';

class _FakeBackend implements VpnBackend {
  VpnStatus current = VpnStatus.disconnected;
  final calls = <String>[];

  @override
  bool get isSupported => true;

  @override
  bool get supportsAppOnly => false;

  @override
  Future<VpnStatus> status() async => current;

  @override
  Stream<VpnStatus> watch() => const Stream.empty();

  @override
  Future<void> connect(WireGuardConfig config, {required bool wholeDevice}) async {
    calls.add('connect');
    current = VpnStatus.connected;
  }

  @override
  Future<void> disconnect() async {
    calls.add('disconnect');
    current = VpnStatus.disconnected;
  }
}

class _MemoryStore implements VpnConfigStore {
  _MemoryStore(this.value);
  String? value;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String config) async => value = config;

  @override
  Future<void> delete() async => value = null;
}

class _FakeSettings extends SettingsController {
  @override
  AppSettings build() => AppSettings();
}

ProviderContainer _container(
  _FakeBackend backend, {
  required String allowed,
  required bool internet,
  List<String>? probes,
}) {
  final container = ProviderContainer(
    overrides: [
      vpnBackendProvider.overrideWithValue(backend),
      vpnConfigStoreProvider.overrideWithValue(_MemoryStore(_conf(allowed))),
      vpnTunnelProbeProvider.overrideWithValue(() async {
        probes?.add('probe');
        return internet;
      }),
      settingsProvider.overrideWith(_FakeSettings.new),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('servidor que não responde: desliga sozinha e explica porquê', () async {
    final backend = _FakeBackend();
    final container = _container(
      backend,
      allowed: '0.0.0.0/0',
      internet: false,
    );
    await container.read(vpnControllerProvider.future);

    await container.read(vpnControllerProvider.notifier).connect();

    final state = container.read(vpnControllerProvider).value!;
    expect(backend.calls, ['connect', 'disconnect']);
    expect(state.status, VpnStatus.disconnected);
    expect(state.busy, isFalse);
    expect(state.checking, isFalse);
    expect(state.error, contains('não respondeu'));
    expect(state.error, contains('51820'));
  });

  test('com resposta fica ligada', () async {
    final backend = _FakeBackend();
    final container = _container(
      backend,
      allowed: '0.0.0.0/0, ::/0',
      internet: true,
    );
    await container.read(vpnControllerProvider.future);

    await container.read(vpnControllerProvider.notifier).connect();

    final state = container.read(vpnControllerProvider).value!;
    expect(backend.calls, ['connect']);
    expect(state.status, VpnStatus.connected);
    expect(state.error, isNull);
    expect(state.isOn, isTrue);
  });

  test('só algumas redes no túnel: não testa (não corta a internet)', () async {
    final backend = _FakeBackend();
    final probes = <String>[];
    final container = _container(
      backend,
      allowed: '10.0.0.0/8',
      internet: false,
      probes: probes,
    );
    await container.read(vpnControllerProvider.future);

    await container.read(vpnControllerProvider.notifier).connect();

    expect(probes, isEmpty);
    expect(container.read(vpnControllerProvider).value!.isOn, isTrue);
  });
}
