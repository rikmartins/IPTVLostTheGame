import 'dart:async';
import 'dart:io';

/// Testa se há internet depois de ligar a VPN.
///
/// O WireGuard não confirma nada ao ligar: o túnel fica "ativo" mesmo que o
/// servidor nunca responda ao handshake. Com `AllowedIPs = 0.0.0.0/0` o
/// tráfego todo vai para esse túnel morto e o Windows ainda bloqueia o que
/// tentar sair por fora (kill switch), e o dispositivo fica sem rede.
typedef TunnelProbe = Future<bool> Function();

/// IPs fixos (sem DNS) de serviços anycast que respondem em todo o lado.
/// Basta um responder.
final _targets = [
  InternetAddress('1.1.1.1'),
  InternetAddress('8.8.8.8'),
  InternetAddress('9.9.9.9'),
];

/// Tenta até [within]: o WireGuard repete o handshake de 5 em 5 s, por isso
/// 12 s cobrem a primeira tentativa e duas repetições.
Future<bool> probeInternet({
  Duration within = const Duration(seconds: 12),
}) async {
  final deadline = DateTime.now().add(within);
  while (true) {
    if (await _anyReachable()) return true;
    final left = deadline.difference(DateTime.now());
    if (left <= Duration.zero) return false;
    await Future<void>.delayed(
      left < const Duration(seconds: 1) ? left : const Duration(seconds: 1),
    );
  }
}

Future<bool> _anyReachable() {
  final result = Completer<bool>();
  var pending = _targets.length;
  for (final address in _targets) {
    Socket.connect(address, 443, timeout: const Duration(seconds: 3)).then(
      (socket) {
        socket.destroy();
        if (!result.isCompleted) result.complete(true);
      },
      onError: (Object _) {
        pending--;
        if (pending == 0 && !result.isCompleted) result.complete(false);
      },
    );
  }
  return result.future;
}
