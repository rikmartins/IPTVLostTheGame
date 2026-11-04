import 'package:flutter_test/flutter_test.dart';
import 'package:iptv_app/data/vpn/android_ikev2_backend.dart';
import 'package:iptv_app/data/vpn/ikev2_config.dart';
import 'package:iptv_app/data/vpn/vpn_backend.dart';
import 'package:iptv_app/data/vpn/windows_ikev2_backend.dart';

void main() {
  group('Ikev2Config.parse', () {
    test('aceita o servidor como vem copiado', () {
      for (final input in [
        'sx460134-ikev.dnsdialer.com',
        '  SX460134-ikev.dnsdialer.com  ',
        'https://sx460134-ikev.dnsdialer.com/',
        'sx460134-ikev.dnsdialer.com:51820',
      ]) {
        final config = Ikev2Config.parse(
          server: input,
          username: ' purevpn0s123 ',
          password: 'pa ss',
        );
        expect(config.server, 'sx460134-ikev.dnsdialer.com', reason: input);
        expect(config.username, 'purevpn0s123');
        expect(config.password, 'pa ss', reason: 'a palavra-passe fica igual');
      }
    });

    test('recusa campos em falta ou servidores inválidos', () {
      expect(
        () => Ikev2Config.parse(server: '', username: 'a', password: 'b'),
        throwsFormatException,
      );
      expect(
        () => Ikev2Config.parse(
          server: 'servidor com espaços',
          username: 'a',
          password: 'b',
        ),
        throwsFormatException,
      );
      expect(
        () => Ikev2Config.parse(server: 'vpn.pt', username: ' ', password: 'b'),
        throwsFormatException,
      );
      expect(
        () => Ikev2Config.parse(server: 'vpn.pt', username: 'a', password: ''),
        throwsFormatException,
      );
    });

    test('nunca mostra a palavra-passe', () {
      const config = Ikev2Config(
        server: 'vpn.pt',
        username: 'ana',
        password: 'segredo',
      );
      expect('$config', isNot(contains('segredo')));
    });
  });

  group('Windows', () {
    test('estado a partir do rasdial', () {
      expect(
        parseRasdialStatus(
          'Ligado a\r\nLost the Game IKEv2\r\nComando concluído.',
        ),
        VpnStatus.connected,
      );
      expect(
        parseRasdialStatus('Sem ligações\r\nComando concluído com êxito.'),
        VpnStatus.disconnected,
      );
    });

    test('resultado do script de ligação', () {
      expect(parseConnectOutput('RESULT=0\r\n'), (code: 0, error: null));
      expect(parseConnectOutput('RESULT=691'), (code: 691, error: null));
      expect(
        parseConnectOutput('ERROR=credenciais EAP (5)'),
        (code: null, error: 'credenciais EAP (5)'),
      );
    });

    test('mensagens para os erros mais comuns', () {
      expect(ikev2ErrorMessage(691), contains('credenciais VPN'));
      expect(ikev2ErrorMessage(809), contains('UDP 500 e 4500'));
      expect(ikev2ErrorMessage(12345), contains('12345'));
    });
  });

  test('Android: autorização recusada', () {
    expect(
      androidIkev2ErrorMessage('consent_denied', null),
      contains('autorizar'),
    );
  });
}
