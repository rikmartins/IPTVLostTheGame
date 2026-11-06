import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';

/// Preencher dados no telemóvel em vez do comando da TV.
///
/// A app abre um servidor HTTP na rede local e mostra um QR com o endereço.
/// O telemóvel (na mesma rede) abre a página no browser, sem instalar nada,
/// e o formulário vem direto para a app: os dados não passam pela internet.
///
/// O endereço leva um código aleatório e o servidor só existe enquanto o
/// ecrã que o mostra estiver aberto.
enum PhoneFieldType { text, url, password, wireguardConfig }

@immutable
class PhoneField {
  const PhoneField(
    this.name,
    this.label, {
    this.type = PhoneFieldType.text,
    this.placeholder = '',
    this.optional = false,
    this.autocomplete = 'off',
  });

  final String name;
  final String label;
  final PhoneFieldType type;
  final String placeholder;
  final bool optional;

  /// Para campos de texto: "username" deixa o gestor de palavras-passe do
  /// telemóvel preencher.
  final String autocomplete;
}

@immutable
class PhoneForm {
  const PhoneForm({
    required this.title,
    required this.intro,
    required this.fields,
    required this.submitLabel,
    required this.doneMessage,
  });

  final String title;
  final String intro;
  final List<PhoneField> fields;
  final String submitLabel;

  /// Mostrado no telemóvel quando a app aceita os dados.
  final String doneMessage;
}

/// Recebe os valores do formulário; devolve `null` se correu bem, ou a
/// mensagem de erro a mostrar no telemóvel.
typedef PhoneSubmit = Future<String?> Function(Map<String, String> values);

/// A app não tem um endereço na rede local (sem Wi-Fi nem cabo).
class PhoneEntryUnavailable implements Exception {
  const PhoneEntryUnavailable();
}

class PhoneFormServer {
  PhoneFormServer._(this._server, this._form, this._onSubmit, this.url);

  final HttpServer _server;
  final PhoneForm _form;
  final PhoneSubmit _onSubmit;

  /// O que vai no QR.
  final Uri url;

  bool _submitting = false;

  /// Um .conf tem poucas centenas de bytes; o login ainda menos.
  static const _maxBody = 64 * 1024;

  /// Porta fixa (fácil de escrever à mão); se estiver ocupada, a seguinte.
  static const defaultPort = 47800;

  /// [address] e [host] servem para os testes (loopback).
  static Future<PhoneFormServer> start(
    PhoneForm form,
    PhoneSubmit onSubmit, {
    InternetAddress? address,
    String? host,
    int port = defaultPort,
  }) async {
    final lanHost = host ?? (await findLanAddress())?.address;
    if (lanHost == null) throw const PhoneEntryUnavailable();

    final bindTo = address ?? InternetAddress.anyIPv4;
    HttpServer? server;
    for (var candidate = port; candidate < port + 10; candidate++) {
      try {
        server = await HttpServer.bind(bindTo, candidate);
        break;
      } on SocketException {
        // Ocupada (outra instância da app, por exemplo): tentar a seguinte.
      }
    }
    server ??= await HttpServer.bind(bindTo, 0);
    server.idleTimeout = const Duration(seconds: 10);

    final url = Uri(
      scheme: 'http',
      host: lanHost,
      port: server.port,
      path: '/${_newToken()}',
    );
    final instance = PhoneFormServer._(server, form, onSubmit, url);
    server.listen(instance._handle, onError: (Object _) {});
    return instance;
  }

  /// Sem `force`: uma resposta a meio (o "Pronto!" no telemóvel) ainda
  /// chega ao fim.
  Future<void> close() => _server.close();

  Future<void> _handle(HttpRequest request) async {
    final response = request.response;
    try {
      response.headers
        ..set(HttpHeaders.cacheControlHeader, 'no-store')
        ..set('X-Content-Type-Options', 'nosniff')
        ..set('Referrer-Policy', 'no-referrer')
        ..set(
          'Content-Security-Policy',
          "default-src 'none'; style-src 'unsafe-inline'; "
              "script-src 'unsafe-inline'; form-action 'self'; "
              "base-uri 'none'; frame-ancestors 'none'",
        );

      if (request.uri.path != url.path) {
        await _send(response, HttpStatus.notFound, _page(_notFound()));
        return;
      }

      switch (request.method) {
        case 'GET':
          await _send(response, HttpStatus.ok, _page(_formBody()));
        case 'POST':
          await _handlePost(request);
        default:
          response.headers.set(HttpHeaders.allowHeader, 'GET, POST');
          await _send(response, HttpStatus.methodNotAllowed, '');
      }
    } catch (_) {
      // Ligação cortada pelo telemóvel a meio: nada a fazer.
      try {
        await response.close();
      } catch (_) {}
    }
  }

  Future<void> _handlePost(HttpRequest request) async {
    final response = request.response;
    final body = BytesBuilder(copy: false);
    await for (final chunk in request) {
      body.add(chunk);
      if (body.length > _maxBody) {
        await _send(
          response,
          HttpStatus.requestEntityTooLarge,
          _page(_formBody(error: 'Os dados são demasiado grandes.')),
        );
        return;
      }
    }

    final Map<String, String> parsed;
    try {
      parsed = Uri.splitQueryString(
        utf8.decode(body.takeBytes()),
        encoding: utf8,
      );
    } on FormatException {
      await _send(
        response,
        HttpStatus.badRequest,
        _page(_formBody(error: 'Não foi possível ler o formulário.')),
      );
      return;
    }
    final values = {
      for (final field in _form.fields) field.name: parsed[field.name] ?? '',
    };

    if (_submitting) {
      await _send(
        response,
        HttpStatus.conflict,
        _page(
          _formBody(
            values: values,
            error: 'A app ainda está a tratar do envio anterior. Aguarda.',
          ),
        ),
      );
      return;
    }

    _submitting = true;
    String? error;
    try {
      // Via Completer: a callback pode devolver um Future<Null> (só
      // `return null`), e o `timeout` desse tipo rejeitaria a mensagem.
      final result = Completer<String?>();
      _onSubmit(values).then(result.complete, onError: result.completeError);
      error = await result.future.timeout(
        const Duration(seconds: 60),
        onTimeout: () => 'A app demorou demasiado a responder. Tenta outra vez.',
      );
    } catch (_) {
      error = 'Erro inesperado. Tenta outra vez.';
    } finally {
      _submitting = false;
    }

    if (error == null) {
      await _send(response, HttpStatus.ok, _page(_doneBody()));
    } else {
      await _send(
        response,
        HttpStatus.ok,
        _page(_formBody(values: values, error: error)),
      );
    }
  }

  static Future<void> _send(HttpResponse response, int status, String html) {
    response
      ..statusCode = status
      ..headers.contentType = ContentType.html;
    response.write(html);
    return response.close();
  }

  // --- HTML ----------------------------------------------------------------

  String _formBody({Map<String, String> values = const {}, String? error}) {
    final fields = StringBuffer();
    for (final field in _form.fields) {
      // Palavras-passe e o .conf (chave privada) não voltam na página.
      final keep =
          field.type == PhoneFieldType.text || field.type == PhoneFieldType.url;
      final value = keep ? _escape(values[field.name] ?? '') : '';
      final id = _escape(field.name);
      final label = _escape(field.label);
      final placeholder = _escape(field.placeholder);
      final required = field.optional ? '' : ' required';
      fields.write('<label for="$id">$label</label>');
      switch (field.type) {
        case PhoneFieldType.text:
          fields.write(
            '<input id="$id" name="$id" type="text" value="$value" '
            'placeholder="$placeholder" '
            'autocomplete="${_escape(field.autocomplete)}" '
            'autocapitalize="none" autocorrect="off" spellcheck="false"'
            '$required>',
          );
        case PhoneFieldType.url:
          fields.write(
            '<input id="$id" name="$id" type="text" inputmode="url" '
            'value="$value" placeholder="$placeholder" autocomplete="url" '
            'autocapitalize="none" autocorrect="off" spellcheck="false"'
            '$required>',
          );
        case PhoneFieldType.password:
          fields.write(
            '<input id="$id" name="$id" type="password" '
            'placeholder="$placeholder" autocomplete="current-password"'
            '$required>'
            '<label class="inline"><input type="checkbox" '
            'onchange="document.getElementById(\'$id\').type='
            'this.checked?\'text\':\'password\'"> Mostrar</label>',
          );
        case PhoneFieldType.wireguardConfig:
          fields.write(
            '<input type="file" accept=".conf,text/plain" '
            'onchange="var f=this.files[0];if(!f)return;'
            'var r=new FileReader();r.onload=function(){'
            'document.getElementById(\'$id\').value=r.result};'
            'r.readAsText(f)">'
            '<p class="hint">Escolhe o ficheiro .conf ou cola o conteúdo:</p>'
            '<textarea id="$id" name="$id" rows="10" '
            'placeholder="$placeholder" autocapitalize="none" '
            'autocorrect="off" spellcheck="false"$required></textarea>',
          );
      }
    }

    final errorHtml = error == null
        ? ''
        : '<p class="error" role="alert">${_escape(error)}</p>';
    return '''
<h1>${_escape(_form.title)}</h1>
<p>${_escape(_form.intro)}</p>
$errorHtml
<form method="post" accept-charset="utf-8" onsubmit="var b=this.querySelector('button');b.disabled=true;b.textContent='A enviar…'">
$fields
<button type="submit">${_escape(_form.submitLabel)}</button>
</form>
<p class="hint">Os dados vão diretamente para a app pela tua rede local, sem passar pela internet.</p>''';
  }

  String _doneBody() =>
      '''
<div class="done">✓</div>
<h1>Pronto!</h1>
<p>${_escape(_form.doneMessage)}</p>''';

  static String _notFound() => '''
<h1>Código expirado</h1>
<p>Lê outra vez o código QR que está no ecrã da app.</p>''';

  static String _page(String body) =>
      '''
<!doctype html>
<html lang="pt">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="color-scheme" content="light dark">
<title>SoPro Media</title>
<style>
:root{--bg:#fbf6ef;--card:#fff;--text:#172322;--muted:#566664;--accent:#21615a;--line:#d3dcd9;--error:#b3261e}
@media (prefers-color-scheme:dark){:root{--bg:#0f1514;--card:#19201f;--text:#dde8e5;--muted:#9fb0ac;--accent:#7cc5bb;--line:#33403e;--error:#f2b8b5}}
*{box-sizing:border-box}
body{margin:0;background:var(--bg);color:var(--text);font:16px/1.45 system-ui,-apple-system,"Segoe UI",Roboto,sans-serif}
main{max-width:480px;margin:0 auto;padding:24px 16px 40px}
.brand{font-weight:700;color:var(--accent);letter-spacing:.02em;margin-bottom:16px}
.card{background:var(--card);border:1px solid var(--line);border-radius:16px;padding:20px}
h1{font-size:1.35rem;margin:0 0 8px}
p{margin:0 0 16px;color:var(--muted)}
label{display:block;font-weight:600;margin:14px 0 6px}
label.inline{display:flex;gap:8px;align-items:center;font-weight:400;color:var(--muted);margin:8px 0 0}
input[type=text],input[type=password],textarea{width:100%;padding:12px;border:1px solid var(--line);border-radius:10px;background:var(--bg);color:var(--text);font:inherit}
textarea{font:13px/1.4 ui-monospace,Consolas,monospace;resize:vertical}
input[type=file]{margin:4px 0 8px;max-width:100%}
input:focus,textarea:focus{outline:2px solid var(--accent);outline-offset:1px}
button{width:100%;margin-top:22px;padding:14px;border:0;border-radius:999px;background:var(--accent);color:#fff;font:600 1rem system-ui,sans-serif}
button:disabled{opacity:.6}
.error{color:var(--error);font-weight:600}
.hint{font-size:.85rem;margin:16px 0 0}
.done{font-size:3rem;color:var(--accent);line-height:1}
</style>
</head>
<body><main><div class="brand">SOPRO MEDIA</div><div class="card">
$body
</div></main></body>
</html>''';

  static String _escape(String value) => value
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#39;');

  /// 6 caracteres sem ambíguos (0/o, 1/l): curto para escrever à mão,
  /// impossível de adivinhar durante os minutos em que o ecrã está aberto.
  static String _newToken() {
    const alphabet = 'abcdefghijkmnpqrstuvwxyz23456789';
    final random = Random.secure();
    return String.fromCharCodes([
      for (var i = 0; i < 6; i++)
        alphabet.codeUnitAt(random.nextInt(alphabet.length)),
    ]);
  }
}

/// Endereço desta máquina na rede local (Wi-Fi ou cabo).
Future<InternetAddress?> findLanAddress() async {
  final interfaces = await NetworkInterface.list(
    type: InternetAddressType.IPv4,
  );
  return pickLanAddress([
    for (final interface in interfaces)
      for (final address in interface.addresses)
        (name: interface.name, address: address),
  ]);
}

/// Entre todos os endereços, o que o telemóvel consegue alcançar: privado
/// (192.168/10/172.16) e numa placa real, nunca no túnel da VPN (que também
/// usa endereços privados) nem em adaptadores virtuais.
@visibleForTesting
InternetAddress? pickLanAddress(
  List<({String name, InternetAddress address})> candidates,
) {
  final virtual = RegExp(
    r'tun|tap|wg|ppp|ipsec|utun|vpn|wireguard|lostthegame|zerotier|tailscale|'
    r'vethernet|virtual|vmware|vbox|docker|bluetooth|loopback|rmnet|ccmni',
    caseSensitive: false,
  );

  int score(({String name, InternetAddress address}) c) {
    final bytes = c.address.rawAddress;
    if (bytes.length != 4 || c.address.isLoopback) return -1;
    if (virtual.hasMatch(c.name)) return -1;
    final a = bytes[0], b = bytes[1];
    if (a == 169 && b == 254) return -1; // sem DHCP
    var value = switch ((a, b)) {
      (192, 168) => 30,
      (10, _) => 20,
      (172, >= 16 && <= 31) => 20,
      (100, >= 64 && <= 127) => 0, // CGNAT
      _ => 5,
    };
    if (RegExp(r'^(wlan|eth|en|wi-?fi|ethernet)', caseSensitive: false)
        .hasMatch(c.name)) {
      value += 5;
    }
    return value;
  }

  InternetAddress? best;
  var bestScore = -1;
  for (final candidate in candidates) {
    final value = score(candidate);
    if (value > bestScore) {
      best = candidate.address;
      bestScore = value;
    }
  }
  return best;
}
