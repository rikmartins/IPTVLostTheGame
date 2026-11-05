import 'package:flutter/foundation.dart';

/// De onde vem o catálogo de um perfil.
enum SourceKind {
  xtream('Xtream Codes'),
  jellyfin('Jellyfin');

  const SourceKind(this.label);

  final String label;
}

/// Dados de acesso de um perfil. Vivem no cofre do sistema (ver
/// `ProfileStore`), nunca no Isar.
@immutable
sealed class SourceCredentials {
  const SourceCredentials();

  factory SourceCredentials.fromJson(Map<String, dynamic> json) {
    return switch (json['type']) {
      'jellyfin' => JellyfinCredentials.fromJson(json),
      // Os perfis anteriores ao Jellyfin não têm "type".
      _ => XtreamCredentials.fromJson(json),
    };
  }

  SourceKind get kind;

  /// Esquema + host + porta + prefixo de caminho, sem barra final.
  String get serverUrl;

  String get username;

  Map<String, String> toJson();

  /// Mesma conta no mesmo servidor (a palavra-passe ou o token podem ter
  /// mudado).
  bool isSameAccount(SourceCredentials other) =>
      other.kind == kind &&
      other.serverUrl == serverUrl &&
      other.username == username;
}

final class XtreamCredentials extends SourceCredentials {
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

  @override
  SourceKind get kind => SourceKind.xtream;

  @override
  final String serverUrl;
  @override
  final String username;
  final String password;

  @override
  Map<String, String> toJson() => {
    'type': 'xtream',
    'serverUrl': serverUrl,
    'username': username,
    'password': password,
  };

  static String normalizeServerUrl(String input) {
    final uri = _parseLoose(input);
    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    // Remove player_api.php / get.php / xmltv.php colados por engano.
    if (segments.isNotEmpty && segments.last.endsWith('.php')) {
      segments.removeLast();
    }
    return _withPath(uri, segments);
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

/// Sessão num servidor Jellyfin. Guarda-se o token de acesso e não a
/// palavra-passe: o token pode ser revogado no painel do servidor
/// ("Dispositivos") sem mudar a palavra-passe.
final class JellyfinCredentials extends SourceCredentials {
  const JellyfinCredentials({
    required this.serverUrl,
    required this.username,
    required this.userId,
    required this.accessToken,
    required this.deviceId,
  });

  factory JellyfinCredentials.fromJson(Map<String, dynamic> json) {
    return JellyfinCredentials(
      serverUrl: json['serverUrl'] as String,
      username: json['username'] as String,
      userId: json['userId'] as String,
      accessToken: json['token'] as String,
      deviceId: json['deviceId'] as String,
    );
  }

  /// Porta por omissão do Jellyfin.
  static const defaultPort = 8096;

  @override
  SourceKind get kind => SourceKind.jellyfin;

  @override
  final String serverUrl;
  @override
  final String username;
  final String userId;
  final String accessToken;

  /// O token está associado a este ID: entrar de novo com o mesmo ID
  /// substitui a sessão anterior em vez de juntar outro dispositivo.
  final String deviceId;

  @override
  Map<String, String> toJson() => {
    'type': 'jellyfin',
    'serverUrl': serverUrl,
    'username': username,
    'userId': userId,
    'token': accessToken,
    'deviceId': deviceId,
  };

  /// Aceita o endereço copiado do browser ("host:8096/web/#/home.html") e
  /// mantém o prefixo de um proxy ("https://casa.pt/jellyfin").
  static String normalizeServerUrl(String input) {
    final uri = _parseLoose(input);
    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    final web = segments.indexOf('web');
    if (web >= 0) segments.removeRange(web, segments.length);
    return _withPath(uri, segments);
  }

  /// Endereços a experimentar, por ordem. Quem escreve só o IP ou o nome
  /// ("192.168.1.10") quase sempre quer a porta do Jellyfin e não a 80.
  static List<String> serverCandidates(String input) {
    final normalized = normalizeServerUrl(input);
    final typed = input.trim();
    final bare = !typed.contains('://') && !Uri.parse(normalized).hasPort;
    if (!bare) return [normalized];
    final uri = Uri.parse(normalized);
    return [uri.replace(port: defaultPort).toString(), normalized];
  }

  @override
  bool operator ==(Object other) =>
      other is JellyfinCredentials &&
      other.serverUrl == serverUrl &&
      other.username == username &&
      other.userId == userId &&
      other.accessToken == accessToken &&
      other.deviceId == deviceId;

  @override
  int get hashCode =>
      Object.hash(serverUrl, username, userId, accessToken, deviceId);

  /// Nunca expor o token em logs.
  @override
  String toString() => 'JellyfinCredentials($serverUrl, $username)';
}

Uri _parseLoose(String input) {
  var raw = input.trim();
  if (!raw.contains('://')) raw = 'http://$raw';
  return Uri.parse(raw);
}

String _withPath(Uri uri, List<String> segments) {
  return Uri(
    scheme: uri.scheme.toLowerCase(),
    host: uri.host,
    port: uri.hasPort ? uri.port : null,
    pathSegments: segments,
  ).toString();
}
