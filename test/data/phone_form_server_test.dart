import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:iptv_app/data/phone_entry/phone_form_server.dart';

const _form = PhoneForm(
  title: 'Iniciar sessão',
  intro: 'Dados Xtream',
  fields: [
    PhoneField('server', 'Servidor', type: PhoneFieldType.url),
    PhoneField('username', 'Utilizador'),
    PhoneField('password', 'Palavra-passe', type: PhoneFieldType.password),
  ],
  submitLabel: 'Entrar',
  doneMessage: 'Sessão iniciada.',
);

Future<PhoneFormServer> _start(PhoneSubmit onSubmit) async {
  final server = await PhoneFormServer.start(
    _form,
    onSubmit,
    address: InternetAddress.loopbackIPv4,
    host: '127.0.0.1',
  );
  addTearDown(server.close);
  return server;
}

Future<(int, String)> _get(Uri url) async {
  final client = HttpClient();
  try {
    final response = await (await client.getUrl(url)).close();
    return (response.statusCode, await utf8.decodeStream(response));
  } finally {
    client.close();
  }
}

Future<(int, String)> _post(Uri url, String body) async {
  final client = HttpClient();
  try {
    final request = await client.postUrl(url);
    request.headers.contentType = ContentType(
      'application',
      'x-www-form-urlencoded',
      charset: 'utf-8',
    );
    request.write(body);
    final response = await request.close();
    return (response.statusCode, await utf8.decodeStream(response));
  } finally {
    client.close();
  }
}

void main() {
  test('o endereço leva um código; sem ele dá 404', () async {
    final server = await _start((_) async => null);

    expect(server.url.path, matches(RegExp(r'^/[a-z2-9]{6}$')));
    final (okStatus, page) = await _get(server.url);
    expect(okStatus, 200);
    expect(page, contains('name="server"'));
    expect(page, contains('type="password"'));

    final (status, _) = await _get(server.url.replace(path: '/abcdef'));
    expect(status, 404);
  });

  test('envia os valores para a app e mostra "Pronto!"', () async {
    Map<String, String>? received;
    final server = await _start((values) async {
      received = values;
      return null;
    });

    final (status, page) = await _post(
      server.url,
      'server=http%3A%2F%2Fexemplo.pt%3A8080&username=jos%C3%A9'
      '&password=a+b%26c&extra=ignorado',
    );

    expect(status, 200);
    expect(page, contains('Pronto!'));
    expect(received, {
      'server': 'http://exemplo.pt:8080',
      'username': 'josé',
      'password': 'a b&c',
    });
  });

  test('erro: volta o formulário com a mensagem, sem a palavra-passe', () async {
    final server = await _start((_) async => 'Utilizador <ou> palavra-passe errados');

    final (_, page) = await _post(
      server.url,
      'server=exemplo.pt&username=%22ana%22&password=segredo123',
    );

    expect(page, contains('Utilizador &lt;ou&gt; palavra-passe errados'));
    expect(page, contains('value="&quot;ana&quot;"'));
    expect(page, isNot(contains('segredo123')));
  });

  test('recusa corpos grandes', () async {
    var called = false;
    final server = await _start((_) async {
      called = true;
      return null;
    });

    final (status, _) = await _post(server.url, 'password=${'x' * 70000}');

    expect(status, HttpStatus.requestEntityTooLarge);
    expect(called, isFalse);
  });

  group('pickLanAddress', () {
    ({String name, InternetAddress address}) nic(String name, String ip) =>
        (name: name, address: InternetAddress(ip));

    test('prefere o Wi-Fi/cabo e ignora o túnel da VPN', () {
      final picked = pickLanAddress([
        nic('LostTheGame', '172.21.8.73'),
        nic('tun0', '10.8.0.2'),
        nic('wlan0', '192.168.1.40'),
      ]);
      expect(picked?.address, '192.168.1.40');
    });

    test('Windows: nomes amigáveis', () {
      final picked = pickLanAddress([
        nic('vEthernet (WSL)', '172.30.32.1'),
        nic('Ethernet 4', '10.0.0.15'),
      ]);
      expect(picked?.address, '10.0.0.15');
    });

    test('sem rede local devolve null', () {
      expect(pickLanAddress([nic('Wi-Fi', '169.254.10.2')]), isNull);
      expect(pickLanAddress([]), isNull);
    });
  });
}
