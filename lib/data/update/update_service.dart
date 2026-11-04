import 'dart:ffi' show Abi;
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'github_release.dart';

class UpdateException implements Exception {
  const UpdateException(this.message);

  /// Pronta a mostrar ao utilizador.
  final String message;

  @override
  String toString() => 'UpdateException: $message';
}

UpdatePlatform get currentUpdatePlatform {
  if (Platform.isAndroid) return UpdatePlatform.android;
  if (Platform.isWindows) return UpdatePlatform.windows;
  if (Platform.isMacOS) return UpdatePlatform.macos;
  // iOS só atualiza pela App Store / TestFlight.
  return UpdatePlatform.unsupported;
}

/// ABI do processo, no formato dos APKs do `--split-per-abi`.
String? get currentAndroidAbi => switch (Abi.current()) {
  Abi.androidArm64 => 'arm64-v8a',
  Abi.androidArm => 'armeabi-v7a',
  Abi.androidX64 => 'x86_64',
  Abi.androidIA32 => 'x86',
  _ => null,
};

/// Atualizações a partir das releases públicas de um repositório GitHub.
///
/// Sem token: a API pública permite 60 pedidos/hora por IP, que chega e
/// sobra para verificações manuais. Um repositório privado exigiria um
/// token embutido na app, o que não se deve fazer.
class UpdateService {
  UpdateService({required this.repository, Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 30),
              headers: {
                'Accept': 'application/vnd.github+json',
                'X-GitHub-Api-Version': '2022-11-28',
                // A API do GitHub recusa pedidos sem User-Agent.
                HttpHeaders.userAgentHeader: 'iptv-app-updater',
              },
            ),
          );

  /// "dono/repo".
  final String repository;
  final Dio _dio;

  Future<GithubRelease> latestRelease() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        'https://api.github.com/repos/$repository/releases/latest',
      );
      return GithubRelease.fromJson(response.data ?? const {});
    } on DioException catch (e) {
      throw UpdateException(switch (e.response?.statusCode) {
        404 => 'Ainda não há versões publicadas no GitHub',
        403 || 429 => 'Limite de pedidos ao GitHub atingido; tenta mais tarde',
        final int code => 'O GitHub respondeu com erro (HTTP $code)',
        null => 'Sem ligação ao GitHub',
      });
    }
  }

  /// Descarrega para a cache temporária da app. [onProgress] recebe 0–1.
  Future<File> download(
    ReleaseAsset asset, {
    required void Function(double progress) onProgress,
    CancelToken? cancelToken,
  }) async {
    final directory = Directory(
      '${(await getTemporaryDirectory()).path}${Platform.pathSeparator}updates',
    );
    await directory.create(recursive: true);
    // O nome vem do GitHub: nada de separadores nem "..".
    final safeName = asset.name.replaceAll(RegExp(r'[\\/:*?"<>|]|\.\.'), '_');
    final file = File('${directory.path}${Platform.pathSeparator}$safeName');

    try {
      await _dio.download(
        asset.downloadUrl,
        file.path,
        cancelToken: cancelToken,
        options: Options(
          headers: {'Accept': 'application/octet-stream'},
          receiveTimeout: const Duration(seconds: 60),
        ),
        onReceiveProgress: (received, total) {
          final expected = total > 0 ? total : asset.size;
          if (expected > 0) onProgress(received / expected);
        },
      );
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) rethrow;
      throw const UpdateException('O download falhou; tenta de novo');
    }

    if (asset.size > 0 && await file.length() != asset.size) {
      await file.delete();
      throw const UpdateException('O ficheiro descarregado está incompleto');
    }
    return file;
  }

  /// Abre o instalador do sistema.
  ///
  /// * Android: o instalador de pacotes. Só aceita o APK se estiver
  ///   assinado com a mesma chave da app instalada, o que protege contra
  ///   um APK adulterado.
  /// * Windows/macOS: `ShellExecute`/`open` através do url_launcher. No
  ///   Windows isto importa: o `Process.start` falha com "requer elevação"
  ///   num instalador que pede UAC.
  Future<void> openInstaller(File file) async {
    if (Platform.isAndroid) {
      final result = await OpenFilex.open(
        file.path,
        type: 'application/vnd.android.package-archive',
      );
      if (result.type != ResultType.done) {
        throw UpdateException(
          result.type == ResultType.permissionDenied
              ? 'Autoriza a instalação de apps desconhecidas para esta app '
                    'nas definições do Android'
              : 'Não foi possível abrir o instalador (${result.message})',
        );
      }
      return;
    }

    if (!await launchUrl(Uri.file(file.path))) {
      throw const UpdateException('Não foi possível abrir o instalador');
    }
  }

  void close() => _dio.close(force: true);
}
