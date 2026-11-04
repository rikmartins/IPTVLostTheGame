import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/vpn/ikev2_backend.dart';
import '../data/vpn/ikev2_config.dart';
import '../data/vpn/tunnel_probe.dart';
import '../data/vpn/vpn_backend.dart';
import '../data/vpn/vpn_config_store.dart';
import '../data/vpn/wireguard_config.dart';
import 'settings_controller.dart';

/// WireGuard (.conf).
final vpnBackendProvider = Provider<VpnBackend>((ref) => createVpnBackend());

/// IKEv2 com utilizador e palavra-passe.
final ikev2BackendProvider = Provider<Ikev2Backend>(
  (ref) => createIkev2Backend(),
);

final vpnConfigStoreProvider = Provider<VpnConfigStore>(
  (ref) => const VpnConfigStore(),
);

final vpnTunnelProbeProvider = Provider<TunnelProbe>((ref) => probeInternet);

@immutable
class VpnState {
  const VpnState({
    this.wireguardSupported = false,
    this.ikev2Supported = false,
    this.kind = VpnKind.wireguard,
    this.wireguard,
    this.ikev2,
    this.status = VpnStatus.disconnected,
    this.busy = false,
    this.checking = false,
    this.error,
  });

  final bool wireguardSupported;
  final bool ikev2Supported;

  /// O tipo que o interruptor liga.
  final VpnKind kind;

  /// null = ainda não foi importado nenhum .conf.
  final WireGuardConfig? wireguard;

  /// null = ainda não foram guardadas credenciais IKEv2.
  final Ikev2Config? ikev2;

  final VpnStatus status;

  /// A ligar/desligar a pedido do utilizador.
  final bool busy;

  /// Túnel ativo, a confirmar que o servidor responde.
  final bool checking;
  final String? error;

  bool get isSupported => wireguardSupported || ikev2Supported;

  bool get isOn =>
      status == VpnStatus.connected || status == VpnStatus.connecting;

  /// O tipo escolhido tem configuração para ligar.
  bool get isConfigured => switch (kind) {
    VpnKind.wireguard => wireguard != null,
    VpnKind.ikev2 => ikev2 != null,
  };

  String? get server => switch (kind) {
    VpnKind.wireguard => wireguard?.endpoint,
    VpnKind.ikev2 => ikev2?.server,
  };

  /// O IKEv2 leva sempre todo o tráfego.
  bool get routesAllTraffic => switch (kind) {
    VpnKind.wireguard => wireguard?.routesAllTraffic ?? false,
    VpnKind.ikev2 => true,
  };

  VpnState copyWith({
    VpnKind? kind,
    WireGuardConfig? wireguard,
    bool clearWireguard = false,
    Ikev2Config? ikev2,
    bool clearIkev2 = false,
    VpnStatus? status,
    bool? busy,
    bool? checking,
    String? error,
    bool clearError = false,
  }) {
    return VpnState(
      wireguardSupported: wireguardSupported,
      ikev2Supported: ikev2Supported,
      kind: kind ?? this.kind,
      wireguard: clearWireguard ? null : wireguard ?? this.wireguard,
      ikev2: clearIkev2 ? null : ikev2 ?? this.ikev2,
      status: status ?? this.status,
      busy: busy ?? this.busy,
      checking: checking ?? this.checking,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class VpnController extends AsyncNotifier<VpnState> {
  StreamSubscription<VpnStatus>? _watch;

  VpnBackend get _wireguardBackend => ref.read(vpnBackendProvider);
  Ikev2Backend get _ikev2Backend => ref.read(ikev2BackendProvider);
  VpnConfigStore get _store => ref.read(vpnConfigStoreProvider);

  @override
  Future<VpnState> build() async {
    final wireguardSupported = ref.watch(vpnBackendProvider).isSupported;
    final ikev2Supported = await ref.watch(ikev2BackendProvider).isSupported();
    ref.onDispose(() => _watch?.cancel());
    if (!wireguardSupported && !ikev2Supported) return const VpnState();

    WireGuardConfig? wireguard;
    final raw = await _store.read();
    if (raw != null) {
      try {
        wireguard = WireGuardConfig.parse(raw);
      } on FormatException {
        wireguard = null;
      }
    }
    final ikev2 = ikev2Supported ? await _store.readIkev2() : null;

    var kind =
        await _store.readKind() ??
        (wireguard == null && ikev2 != null
            ? VpnKind.ikev2
            : VpnKind.wireguard);
    if (kind == VpnKind.ikev2 && !ikev2Supported) kind = VpnKind.wireguard;
    if (kind == VpnKind.wireguard && !wireguardSupported) kind = VpnKind.ikev2;

    _listen(kind);
    return VpnState(
      wireguardSupported: wireguardSupported,
      ikev2Supported: ikev2Supported,
      kind: kind,
      wireguard: wireguard,
      ikev2: ikev2,
      status: await _statusOf(kind),
    );
  }

  /// Só se observa o tipo escolhido: no Windows cada consulta do IKEv2 é um
  /// processo (`rasdial`).
  void _listen(VpnKind kind) {
    _watch?.cancel();
    final stream = switch (kind) {
      VpnKind.wireguard => _wireguardBackend.watch(),
      VpnKind.ikev2 => _ikev2Backend.watch(),
    };
    _watch = stream.listen((status) {
      final current = state.value;
      if (current != null &&
          current.kind == kind &&
          !current.busy &&
          current.status != status) {
        state = AsyncData(current.copyWith(status: status));
      }
    });
  }

  Future<VpnStatus> _statusOf(VpnKind kind) => switch (kind) {
    VpnKind.wireguard => _wireguardBackend.status(),
    VpnKind.ikev2 => _ikev2Backend.status(),
  };

  /// Muda o tipo que o interruptor liga. Desliga primeiro o atual.
  Future<void> setKind(VpnKind kind) async {
    final current = state.value;
    if (current == null || current.kind == kind || current.busy) return;
    if (current.isOn) await disconnect();
    await _store.writeKind(kind);
    _listen(kind);
    state = AsyncData(
      (state.value ?? current).copyWith(
        kind: kind,
        status: await _statusOf(kind),
        clearError: true,
      ),
    );
  }

  /// Valida e guarda o .conf. Lança [FormatException] com a mensagem a
  /// mostrar se o texto não for uma configuração WireGuard válida.
  Future<WireGuardConfig> importConfig(String text) async {
    final config = WireGuardConfig.parse(text);
    await _store.write(config.text);
    await setKind(VpnKind.wireguard);
    final current = state.value ?? const VpnState();
    state = AsyncData(current.copyWith(wireguard: config, clearError: true));
    return config;
  }

  /// Guarda as credenciais IKEv2 (já validadas por `Ikev2Config.parse`).
  Future<void> saveIkev2(Ikev2Config config) async {
    final current = state.value;
    // Credenciais novas só valem na próxima ligação.
    if (current != null && current.kind == VpnKind.ikev2 && current.isOn) {
      await disconnect();
    }
    await _store.writeIkev2(config);
    await setKind(VpnKind.ikev2);
    final updated = state.value ?? const VpnState();
    state = AsyncData(updated.copyWith(ikev2: config, clearError: true));
  }

  /// Apaga a configuração do tipo escolhido.
  Future<void> removeConfig() async {
    final current = state.value;
    if (current == null) return;
    if (current.isOn) await disconnect();
    switch (current.kind) {
      case VpnKind.wireguard:
        await _store.delete();
        state = AsyncData(
          (state.value ?? current).copyWith(
            clearWireguard: true,
            clearError: true,
          ),
        );
      case VpnKind.ikev2:
        await _store.deleteIkev2();
        await _ikev2Backend.forget();
        state = AsyncData(
          (state.value ?? current).copyWith(clearIkev2: true, clearError: true),
        );
    }
  }

  Future<void> connect() async {
    final current = state.value;
    if (current == null || !current.isConfigured || current.busy) return;
    final kind = current.kind;

    state = AsyncData(
      current.copyWith(
        busy: true,
        status: VpnStatus.connecting,
        clearError: true,
      ),
    );
    try {
      switch (kind) {
        case VpnKind.wireguard:
          await _wireguardBackend.connect(
            current.wireguard!,
            wholeDevice: ref.read(settingsProvider).vpnWholeDevice,
          );
        case VpnKind.ikev2:
          await _ikev2Backend.connect(current.ikev2!);
      }
      // Com o tráfego todo no túnel, um servidor que não responde deixa o
      // dispositivo sem internet: só fica ligada se houver rede.
      if (current.routesAllTraffic) {
        state = AsyncData(
          current.copyWith(
            busy: true,
            checking: true,
            status: VpnStatus.connecting,
            clearError: true,
          ),
        );
        if (!await ref.read(vpnTunnelProbeProvider)()) {
          try {
            await _disconnectKind(kind);
          } catch (_) {
            // O erro abaixo já diz o essencial.
          }
          state = AsyncData(
            current.copyWith(
              busy: false,
              checking: false,
              status: await _statusOf(kind),
              error: noResponseMessage(current),
            ),
          );
          return;
        }
      }
      state = AsyncData(
        current.copyWith(
          busy: false,
          checking: false,
          status: await _statusOf(kind),
        ),
      );
    } catch (e) {
      // Qualquer falha tem de libertar o interruptor; VpnException já traz
      // a mensagem pronta.
      state = AsyncData(
        current.copyWith(
          busy: false,
          checking: false,
          status: await _statusOf(kind),
          error: e is VpnException ? e.message : 'Não foi possível ligar ($e)',
        ),
      );
    }
  }

  Future<void> _disconnectKind(VpnKind kind) => switch (kind) {
    VpnKind.wireguard => _wireguardBackend.disconnect(),
    VpnKind.ikev2 => _ikev2Backend.disconnect(),
  };

  @visibleForTesting
  static String noResponseMessage(VpnState vpn) {
    final reason = switch (vpn.kind) {
      VpnKind.wireguard =>
        'O ficheiro .conf pode ter expirado ou não estar ativo na tua conta '
            'do fornecedor (gera um novo), ou esta rede bloqueia UDP na porta '
            '${_port(vpn.wireguard?.endpoint)}.',
      VpnKind.ikev2 =>
        'Experimenta outro servidor do teu fornecedor, ou confirma que esta '
            'rede não bloqueia o IKEv2 (UDP 500 e 4500).',
    };
    return 'O servidor VPN não respondeu, por isso a VPN foi desligada para '
        'não ficares sem internet. $reason';
  }

  static String _port(String? endpoint) {
    if (endpoint == null) return '51820';
    return endpoint.substring(endpoint.lastIndexOf(':') + 1);
  }

  Future<void> disconnect() async {
    final current = state.value;
    if (current == null || current.busy) return;

    state = AsyncData(
      current.copyWith(
        busy: true,
        status: VpnStatus.disconnecting,
        clearError: true,
      ),
    );
    try {
      await _disconnectKind(current.kind);
    } catch (e) {
      state = AsyncData(
        current.copyWith(
          busy: false,
          status: await _statusOf(current.kind),
          error: e is VpnException
              ? e.message
              : 'Não foi possível desligar ($e)',
        ),
      );
      return;
    }
    state = AsyncData(
      current.copyWith(busy: false, status: await _statusOf(current.kind)),
    );
  }
}

final vpnControllerProvider = AsyncNotifierProvider<VpnController, VpnState>(
  VpnController.new,
);
