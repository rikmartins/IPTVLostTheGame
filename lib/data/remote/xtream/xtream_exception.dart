import 'package:dio/dio.dart';

enum XtreamErrorKind {
  invalidCredentials,
  accountInactive,
  network,
  timeout,
  server,
  invalidResponse,
  cancelled,
}

class XtreamException implements Exception {
  const XtreamException(this.kind, [this.detail]);

  factory XtreamException.fromDio(DioException error) {
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => const XtreamException(
        XtreamErrorKind.timeout,
      ),
      DioExceptionType.cancel => const XtreamException(
        XtreamErrorKind.cancelled,
      ),
      DioExceptionType.badCertificate => const XtreamException(
        XtreamErrorKind.network,
        'Certificado SSL inválido',
      ),
      DioExceptionType.badResponse => switch (error.response?.statusCode) {
        401 || 403 => const XtreamException(XtreamErrorKind.invalidCredentials),
        404 => const XtreamException(
          XtreamErrorKind.invalidResponse,
          'Endereço não encontrado (o servidor é Xtream Codes?)',
        ),
        final code => XtreamException(XtreamErrorKind.server, 'HTTP $code'),
      },
      _ => XtreamException(XtreamErrorKind.network, scrubSecrets(error.message)),
    };
  }

  final XtreamErrorKind kind;
  final String? detail;

  /// Mensagem pronta a mostrar ao utilizador.
  String get message {
    final base = switch (kind) {
      XtreamErrorKind.invalidCredentials => 'Utilizador ou palavra-passe incorretos',
      XtreamErrorKind.accountInactive => 'A conta não está ativa',
      XtreamErrorKind.network => 'Sem ligação ao servidor',
      XtreamErrorKind.timeout => 'O servidor demorou demasiado a responder',
      XtreamErrorKind.server => 'Erro no servidor',
      XtreamErrorKind.invalidResponse => 'Resposta inválida do servidor',
      XtreamErrorKind.cancelled => 'Cancelado',
    };
    return detail == null ? base : '$base ($detail)';
  }

  @override
  String toString() => 'XtreamException: $message';
}

final _queryString = RegExp(r'\?\S*');

/// O Xtream passa a password na query string e o `HttpException` do dart:io
/// inclui o URL na mensagem: corta-se tudo depois do `?` antes de mostrar
/// ou guardar um erro.
String? scrubSecrets(String? text) => text?.replaceAll(_queryString, '?…');
