import 'package:flutter/foundation.dart';

/// VPN IKEv2 com as "credenciais VPN" do fornecedor (na PureVPN: página
/// Subscriptions), que não são o email e a palavra-passe da conta. Ao
/// contrário de um .conf, não expiram enquanto a subscrição estiver ativa.
@immutable
class Ikev2Config {
  const Ikev2Config({
    required this.server,
    required this.username,
    required this.password,
  });

  /// Valida o que o utilizador escreveu. Lança [FormatException] com uma
  /// mensagem pronta a mostrar.
  factory Ikev2Config.parse({
    required String server,
    required String username,
    required String password,
  }) {
    final host = normalizeServer(server);
    if (host.isEmpty) {
      throw const FormatException('Falta o endereço do servidor.');
    }
    if (!_host.hasMatch(host)) {
      throw const FormatException(
        'O servidor tem de ser só um nome ou IP, por exemplo '
        'sx460134-ikev.dnsdialer.com.',
      );
    }
    final user = username.trim();
    if (user.isEmpty) throw const FormatException('Falta o utilizador VPN.');
    if (password.isEmpty) {
      throw const FormatException('Falta a palavra-passe VPN.');
    }
    if (user.contains('\n') || password.contains('\n')) {
      throw const FormatException('O utilizador e a palavra-passe têm de '
          'estar numa só linha.');
    }
    return Ikev2Config(server: host, username: user, password: password);
  }

  factory Ikev2Config.fromJson(Map<String, dynamic> json) => Ikev2Config(
    server: json['server'] as String,
    username: json['username'] as String,
    password: json['password'] as String,
  );

  final String server;
  final String username;
  final String password;

  Map<String, String> toJson() => {
    'server': server,
    'username': username,
    'password': password,
  };

  /// Aceita o que se copia de uma página ("https://servidor/", com porta,
  /// com espaços) e fica só com o nome.
  static String normalizeServer(String input) {
    var value = input.trim();
    final scheme = value.indexOf('://');
    if (scheme >= 0) value = value.substring(scheme + 3);
    final slash = value.indexOf('/');
    if (slash >= 0) value = value.substring(0, slash);
    // "host:51820" (copiado de um .conf): o IKEv2 usa sempre 500/4500.
    final colon = value.lastIndexOf(':');
    if (colon > 0 && !value.contains('[') && value.indexOf(':') == colon) {
      value = value.substring(0, colon);
    }
    return value.toLowerCase();
  }

  static final _host = RegExp(
    r'^(?=.{1,253}$)([a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?\.)*'
    r'[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?$',
  );

  @override
  bool operator ==(Object other) =>
      other is Ikev2Config &&
      other.server == server &&
      other.username == username &&
      other.password == password;

  @override
  int get hashCode => Object.hash(server, username, password);

  /// Nunca expor a palavra-passe em logs.
  @override
  String toString() => 'Ikev2Config($server, $username)';
}
