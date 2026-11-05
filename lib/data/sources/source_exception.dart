import 'package:dio/dio.dart';

enum SourceErrorKind {
  invalidCredentials,
  accountInactive,

  /// Token revogado no servidor (Jellyfin): é preciso entrar outra vez.
  sessionExpired,
  network,
  timeout,
  server,
  invalidResponse,
  cancelled,
}

/// Erro ao falar com o servidor de um perfil (Xtream Codes ou Jellyfin).
class SourceException implements Exception {
  const SourceException(this.kind, [this.detail]);

  /// [notFound]: o que dizer a um 404, que quase sempre quer dizer que o
  /// endereço não é do tipo de servidor escolhido.
  factory SourceException.fromDio(
    DioException error, {
    required String notFound,
    SourceErrorKind unauthorized = SourceErrorKind.invalidCredentials,
  }) {
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => const SourceException(
        SourceErrorKind.timeout,
      ),
      DioExceptionType.cancel => const SourceException(
        SourceErrorKind.cancelled,
      ),
      DioExceptionType.badCertificate => const SourceException(
        SourceErrorKind.network,
        'Certificado SSL inválido',
      ),
      DioExceptionType.badResponse => switch (error.response?.statusCode) {
        401 || 403 => SourceException(unauthorized),
        404 => SourceException(SourceErrorKind.invalidResponse, notFound),
        final code => SourceException(SourceErrorKind.server, 'HTTP $code'),
      },
      _ => SourceException(
        SourceErrorKind.network,
        scrubSecrets(error.message),
      ),
    };
  }

  final SourceErrorKind kind;
  final String? detail;

  /// Mensagem pronta a mostrar ao utilizador.
  String get message {
    final base = switch (kind) {
      SourceErrorKind.invalidCredentials =>
        'Utilizador ou palavra-passe incorretos',
      SourceErrorKind.accountInactive => 'A conta não está ativa',
      SourceErrorKind.sessionExpired =>
        'A sessão terminou no servidor: volta a iniciar sessão neste perfil',
      SourceErrorKind.network => 'Sem ligação ao servidor',
      SourceErrorKind.timeout => 'O servidor demorou demasiado a responder',
      SourceErrorKind.server => 'Erro no servidor',
      SourceErrorKind.invalidResponse => 'Resposta inválida do servidor',
      SourceErrorKind.cancelled => 'Cancelado',
    };
    return detail == null ? base : '$base ($detail)';
  }

  @override
  String toString() => 'SourceException: $message';
}

final _queryString = RegExp(r'\?\S*');

/// O Xtream passa a password na query string (e os streams do Jellyfin o
/// token), e o `HttpException` do dart:io inclui o URL na mensagem:
/// corta-se tudo depois do `?` antes de mostrar ou guardar um erro.
String? scrubSecrets(String? text) => text?.replaceAll(_queryString, '?…');
