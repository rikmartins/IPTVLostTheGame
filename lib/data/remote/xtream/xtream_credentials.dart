import 'package:flutter/foundation.dart';

@immutable
class XtreamCredentials {
  const XtreamCredentials({
    required this.serverUrl,
    required this.username,
    required this.password,
  });

  /// Aceita o que o utilizador escrever ("host:8080", "http://host/",
  /// ".../player_api.php?username=...") e normaliza.
  factory XtreamCredentials.fromInput({
    required String server,
    required String username,
    required String password,
  }) {
    return XtreamCredentials(
      serverUrl: normalizeServerUrl(server),
      username: username.trim(),
      password: password.trim(),
    );
  }

  factory XtreamCredentials.fromJson(Map<String, dynamic> json) {
    return XtreamCredentials(
      serverUrl: json['serverUrl'] as String,
      username: json['username'] as String,
      password: json['password'] as String,
    );
  }

  /// Esquema + host + porta + prefixo de caminho, sem barra final.
  final String serverUrl;
  final String username;
  final String password;

  Map<String, String> toJson() => {
    'serverUrl': serverUrl,
    'username': username,
    'password': password,
  };

  static String normalizeServerUrl(String input) {
    var raw = input.trim();
    if (!raw.contains('://')) raw = 'http://$raw';

    final uri = Uri.parse(raw);
    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    // Remove player_api.php / get.php / xmltv.php colados por engano.
    if (segments.isNotEmpty && segments.last.endsWith('.php')) {
      segments.removeLast();
    }

    return Uri(
      scheme: uri.scheme.toLowerCase(),
      host: uri.host,
      port: uri.hasPort ? uri.port : null,
      pathSegments: segments,
    ).toString();
  }

  @override
  bool operator ==(Object other) =>
      other is XtreamCredentials &&
      other.serverUrl == serverUrl &&
      other.username == username &&
      other.password == password;

  @override
  int get hashCode => Object.hash(serverUrl, username, password);

  /// Nunca expor a password em logs.
  @override
  String toString() => 'XtreamCredentials($serverUrl, $username)';
}
