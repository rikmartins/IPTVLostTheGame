import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iptv_app/app/settings_controller.dart';
import 'package:iptv_app/app/vpn_controller.dart';
import 'package:iptv_app/data/local/models/app_settings.dart';
import 'package:iptv_app/data/vpn/ikev2_backend.dart';
import 'package:iptv_app/data/vpn/ikev2_config.dart';
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

class _FakeIkev2 implements Ikev2Backend {
  VpnStatus current = VpnStatus.disconnected;
  final calls = <String>[];

  /// Erro a lançar no connect (ex.: credenciais erradas).
  String? failWith;

  @override
  Future<bool> isSupported() async => true;

  @override
  Future<VpnStatus> status() async => current;

  @override
  Stream<VpnStatus> watch() => const Stream.empty();

  @override
  Future<void> connect(Ikev2Config config) async {
    calls.add('connect ${config.server}');
    if (failWith != null) throw VpnException(failWith!);
    current = VpnStatus.connected;
  }

  @override
  Future<void> disconnect() async {
    calls.add('disconnect');
    current = VpnStatus.disconnected;
  }

  @override
  Future<void> forget() async => calls.add('forget');
}

class _MemoryStore implements VpnConfigStore {
  _MemoryStore(this.value);
  String? value;
  Ikev2Config? ikev2;
  VpnKind? kind;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String config) async => value = config;

  @override
  Future<void> delete() async => value = null;

  @override
  Future<Ikev2Config?> readIkev2() async => ikev2;

  @override
  Future<void> writeIkev2(Ikev2Config config) async => ikev2 = config;

  @override
  Future<void> deleteIkev2() async => ikev2 = null;

  @override
  Future<VpnKind?> readKind() async => kind;

  @override
  Future<void> writeKind(VpnKind kind) async => this.kind = kind;
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
  _FakeIkev2? ikev2,
  _MemoryStore? store,
}) {
  final container = ProviderContainer(
    overrides: [
      vpnBackendProvider.overrideWithValue(backend),
      ikev2BackendProvider.overrideWithValue(ikev2 ?? _FakeIkev2()),
      vpnConfigStoreProvider.overrideWithValue(
        store ?? _MemoryStore(_conf(allowed)),
      ),
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

const _credentials = Ikev2Config(
  server: 'sx460134-ikev.dnsdialer.com',
  username: 'purevpn0s123',
  password: 'segredo',
);

void main() {
  group('WireGuard', () {
    test('servidor que não responde: desliga sozinha e explica porquê',
        () async {
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

    test('só algumas redes no túnel: não testa (não corta a internet)',
        () async {
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
  });

  group('IKEv2', () {
    test('guardar credenciais escolhe o IKEv2 e liga com elas', () async {
      final ikev2 = _FakeIkev2();
      final store = _MemoryStore(null);
      final container = _container(
        _FakeBackend(),
        allowed: '0.0.0.0/0',
        internet: true,
        ikev2: ikev2,
        store: store,
      );
      await container.read(vpnControllerProvider.future);
      final controller = container.read(vpnControllerProvider.notifier);

      await controller.saveIkev2(_credentials);
      expect(store.kind, VpnKind.ikev2);
      expect(container.read(vpnControllerProvider).value!.isConfigured, isTrue);

      await controller.connect();
      final state = container.read(vpnControllerProvider).value!;
      expect(ikev2.calls, ['connect sx460134-ikev.dnsdialer.com']);
      expect(state.status, VpnStatus.connected);
      expect(state.server, 'sx460134-ikev.dnsdialer.com');
    });

    test('credenciais erradas: mostra a mensagem do sistema', () async {
      final ikev2 = _FakeIkev2()
        ..failWith = 'Utilizador ou palavra-passe VPN errados.';
      final store = _MemoryStore(null)
        ..ikev2 = _credentials
        ..kind = VpnKind.ikev2;
      final container = _container(
        _FakeBackend(),
        allowed: '0.0.0.0/0',
        internet: true,
        ikev2: ikev2,
        store: store,
      );
      await container.read(vpnControllerProvider.future);

      await container.read(vpnControllerProvider.notifier).connect();

      final state = container.read(vpnControllerProvider).value!;
      expect(state.isOn, isFalse);
      expect(state.busy, isFalse);
      expect(state.error, contains('errados'));
    });

    test('ligada mas sem internet: desliga sozinha', () async {
      final ikev2 = _FakeIkev2();
      final store = _MemoryStore(null)
        ..ikev2 = _credentials
        ..kind = VpnKind.ikev2;
      final container = _container(
        _FakeBackend(),
        allowed: '0.0.0.0/0',
        internet: false,
        ikev2: ikev2,
        store: store,
      );
      await container.read(vpnControllerProvider.future);

      await container.read(vpnControllerProvider.notifier).connect();

      final state = container.read(vpnControllerProvider).value!;
      expect(ikev2.calls, [
        'connect sx460134-ikev.dnsdialer.com',
        'disconnect',
      ]);
      expect(state.isOn, isFalse);
      expect(state.error, contains('IKEv2'));
    });

    test('mudar para WireGuard desliga o IKEv2 primeiro', () async {
      final ikev2 = _FakeIkev2()..current = VpnStatus.connected;
      final store = _MemoryStore(_conf('0.0.0.0/0'))
        ..ikev2 = _credentials
        ..kind = VpnKind.ikev2;
      final container = _container(
        _FakeBackend(),
        allowed: '0.0.0.0/0',
        internet: true,
        ikev2: ikev2,
        store: store,
      );
      expect((await container.read(vpnControllerProvider.future)).isOn, isTrue);

      await container
          .read(vpnControllerProvider.notifier)
          .setKind(VpnKind.wireguard);

      final state = container.read(vpnControllerProvider).value!;
      expect(ikev2.calls, ['disconnect']);
      expect(state.kind, VpnKind.wireguard);
      expect(state.isOn, isFalse);
      expect(store.kind, VpnKind.wireguard);
    });

    test('remover apaga as credenciais e a ligação do sistema', () async {
      final ikev2 = _FakeIkev2();
      final store = _MemoryStore(null)
        ..ikev2 = _credentials
        ..kind = VpnKind.ikev2;
      final container = _container(
        _FakeBackend(),
        allowed: '0.0.0.0/0',
        internet: true,
        ikev2: ikev2,
        store: store,
      );
      await container.read(vpnControllerProvider.future);

      await container.read(vpnControllerProvider.notifier).removeConfig();

      expect(store.ikev2, isNull);
      expect(ikev2.calls, ['forget']);
      expect(
        container.read(vpnControllerProvider).value!.isConfigured,
        isFalse,
      );
    });
  });
}
