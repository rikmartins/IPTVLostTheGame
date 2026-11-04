import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'ikev2_backend.dart';
import 'ikev2_config.dart';
import 'vpn_backend.dart';

/// IKEv2 nativo do Android 11+ (ver `Ikev2Vpn.kt`). Em versões anteriores
/// não há IKEv2 para apps sem embutir um motor VPN: fica o WireGuard.
class AndroidIkev2Backend implements Ikev2Backend {
  static const _channel = MethodChannel('lostthegame/ikev2');

  bool? _supported;

  @override
  Future<bool> isSupported() async {
    try {
      return _supported ??=
          await _channel.invokeMethod<bool>('isSupported') ?? false;
    } on MissingPluginException {
      return _supported = false;
    }
  }

  @override
  Future<VpnStatus> status() async {
    final raw = await _rawStatus();
    return raw == 'connected'
        ? VpnStatus.connected
        : raw == 'connecting'
        ? VpnStatus.connecting
        : VpnStatus.disconnected;
  }

  Future<String> _rawStatus() async {
    try {
      return await _channel.invokeMethod<String>('status') ?? 'disconnected';
    } on PlatformException {
      return 'disconnected';
    }
  }

  @override
  Stream<VpnStatus> watch() =>
      pollVpnStatus(status, interval: const Duration(seconds: 2));

  @override
  Future<void> connect(Ikev2Config config) async {
    try {
      await _channel.invokeMethod<void>('connect', config.toJson());
    } on PlatformException catch (e) {
      throw VpnException(androidIkev2ErrorMessage(e.code, e.message));
    }

    // O sistema liga em segundo plano: esperar pelo resultado.
    final deadline = DateTime.now().add(const Duration(seconds: 25));
    while (DateTime.now().isBefore(deadline)) {
      final raw = await _rawStatus();
      if (raw == 'connected') return;
      if (raw == 'failed') {
        await disconnect();
        throw const VpnException(_failedMessage);
      }
      await Future<void>.delayed(const Duration(seconds: 1));
    }
    await disconnect();
    throw const VpnException(_failedMessage);
  }

  @override
  Future<void> disconnect() async {
    try {
      await _channel.invokeMethod<void>('disconnect');
    } on PlatformException {
      // Já desligada.
    }
  }

  @override
  Future<void> forget() async {
    try {
      await _channel.invokeMethod<void>('forget');
    } on PlatformException {
      // Sem perfil guardado no sistema.
    }
  }

  /// O Android não diz porquê: credenciais, servidor ou rede.
  static const _failedMessage =
      'A VPN IKEv2 não ligou. Confirma o servidor e as credenciais VPN (as '
      'da subscrição, não o email e a palavra-passe da conta), e que a rede '
      'não bloqueia o IKEv2 (UDP 500 e 4500).';
}

@visibleForTesting
String androidIkev2ErrorMessage(String code, String? detail) => switch (code) {
  'consent_denied' =>
    'É preciso autorizar a VPN no pedido do Android. Tenta ligar outra vez.',
  'unsupported' => 'Este Android não tem IKEv2 para apps (precisa do 11 ou '
      'mais recente). Usa um ficheiro .conf do WireGuard.',
  'invalid' => 'O Android recusou a configuração: ${detail ?? 'dados inválidos'}.',
  'cancelled' => 'Pedido anterior cancelado. Tenta outra vez.',
  _ => 'Não foi possível ligar (${detail ?? code}).',
};
