import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/vpn/vpn_backend.dart';
import '../data/vpn/vpn_config_store.dart';
import '../data/vpn/wireguard_config.dart';
import 'settings_controller.dart';

final vpnBackendProvider = Provider<VpnBackend>((ref) => createVpnBackend());

final vpnConfigStoreProvider = Provider<VpnConfigStore>(
  (ref) => const VpnConfigStore(),
);

@immutable
class VpnState {
  const VpnState({
    this.config,
    this.status = VpnStatus.disconnected,
    this.busy = false,
    this.error,
  });

  /// null = ainda não foi importado nenhum .conf.
  final WireGuardConfig? config;
  final VpnStatus status;

  /// A ligar/desligar a pedido do utilizador.
  final bool busy;
  final String? error;

  bool get isOn =>
      status == VpnStatus.connected || status == VpnStatus.connecting;

  VpnState copyWith({
    WireGuardConfig? config,
    bool clearConfig = false,
    VpnStatus? status,
    bool? busy,
    String? error,
    bool clearError = false,
  }) {
    return VpnState(
      config: clearConfig ? null : config ?? this.config,
      status: status ?? this.status,
      busy: busy ?? this.busy,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class VpnController extends AsyncNotifier<VpnState> {
  @override
  Future<VpnState> build() async {
    final backend = ref.watch(vpnBackendProvider);
    if (!backend.isSupported) return const VpnState();

    final raw = await ref.read(vpnConfigStoreProvider).read();
    WireGuardConfig? config;
    if (raw != null) {
      try {
        config = WireGuardConfig.parse(raw);
      } on FormatException {
        config = null;
      }
    }

    final subscription = backend.watch().listen((status) {
      final current = state.value;
      if (current != null && !current.busy && current.status != status) {
        state = AsyncData(current.copyWith(status: status));
      }
    });
    ref.onDispose(subscription.cancel);

    return VpnState(config: config, status: await backend.status());
  }

  /// Valida e guarda o .conf. Lança [FormatException] com a mensagem a
  /// mostrar se o texto não for uma configuração WireGuard válida.
  Future<WireGuardConfig> importConfig(String text) async {
    final config = WireGuardConfig.parse(text);
    await ref.read(vpnConfigStoreProvider).write(config.text);
    final current = state.value ?? const VpnState();
    state = AsyncData(current.copyWith(config: config, clearError: true));
    return config;
  }

  Future<void> removeConfig() async {
    final current = state.value;
    if (current == null) return;
    if (current.isOn) await disconnect();
    await ref.read(vpnConfigStoreProvider).delete();
    state = AsyncData(
      (state.value ?? current).copyWith(clearConfig: true, clearError: true),
    );
  }

  Future<void> connect() async {
    final current = state.value;
    final config = current?.config;
    if (current == null || config == null || current.busy) return;

    state = AsyncData(
      current.copyWith(
        busy: true,
        status: VpnStatus.connecting,
        clearError: true,
      ),
    );
    final backend = ref.read(vpnBackendProvider);
    try {
      await backend.connect(
        config,
        wholeDevice: ref.read(settingsProvider).vpnWholeDevice,
      );
      state = AsyncData(
        current.copyWith(busy: false, status: await backend.status()),
      );
    } catch (e) {
      // Qualquer falha tem de libertar o interruptor; VpnException já traz
      // a mensagem pronta.
      state = AsyncData(
        current.copyWith(
          busy: false,
          status: await backend.status(),
          error: e is VpnException ? e.message : 'Não foi possível ligar ($e)',
        ),
      );
    }
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
    final backend = ref.read(vpnBackendProvider);
    try {
      await backend.disconnect();
    } catch (e) {
      state = AsyncData(
        current.copyWith(
          busy: false,
          status: await backend.status(),
          error: e is VpnException
              ? e.message
              : 'Não foi possível desligar ($e)',
        ),
      );
      return;
    }
    state = AsyncData(
      current.copyWith(busy: false, status: await backend.status()),
    );
  }
}

final vpnControllerProvider = AsyncNotifierProvider<VpnController, VpnState>(
  VpnController.new,
);
