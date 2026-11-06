import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../core/config/app_config.dart';
import '../data/update/app_version.dart';
import '../data/update/github_release.dart';
import '../data/update/update_service.dart';
import 'providers.dart';

final appVersionProvider = FutureProvider<AppVersion?>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return AppVersion.tryParse('${info.version}+${info.buildNumber}');
});

/// Só há atualizações se houver repositório configurado e a plataforma as
/// permitir (o iOS não permite instalar fora da App Store, e a versão da
/// Play Store só se atualiza pela loja).
bool get updatesAvailableOnThisPlatform =>
    !isPlayStoreBuild &&
    githubRepository.isNotEmpty &&
    currentUpdatePlatform != UpdatePlatform.unsupported;

final updateServiceProvider = Provider<UpdateService>((ref) {
  final service = UpdateService(repository: githubRepository);
  ref.onDispose(service.close);
  return service;
});

sealed class UpdateState {
  const UpdateState();
}

class UpdateIdle extends UpdateState {
  const UpdateIdle();
}

class UpdateChecking extends UpdateState {
  const UpdateChecking();
}

class UpdateUpToDate extends UpdateState {
  const UpdateUpToDate(this.current);
  final AppVersion current;
}

@immutable
class UpdateAvailable extends UpdateState {
  const UpdateAvailable(this.release, this.version, this.asset);

  final GithubRelease release;
  final AppVersion version;

  /// null = a release não traz ficheiro para esta plataforma (só se pode
  /// abrir a página no GitHub).
  final ReleaseAsset? asset;
}

class UpdateDownloading extends UpdateState {
  const UpdateDownloading(this.update, this.progress);
  final UpdateAvailable update;

  /// 0–1.
  final double progress;
}

class UpdateInstalling extends UpdateState {
  const UpdateInstalling(this.update);
  final UpdateAvailable update;
}

class UpdateFailed extends UpdateState {
  const UpdateFailed(this.message, {this.update});
  final String message;

  /// Se a falha foi no download, para o "tentar de novo" repetir o
  /// download e não a verificação.
  final UpdateAvailable? update;
}

class UpdateController extends Notifier<UpdateState> {
  CancelToken? _download;

  @override
  UpdateState build() {
    ref.onDispose(() => _download?.cancel());
    return const UpdateIdle();
  }

  Future<void> check() async {
    if (!updatesAvailableOnThisPlatform) return;
    state = const UpdateChecking();
    try {
      final current = await ref.read(appVersionProvider.future);
      final release = await ref.read(updateServiceProvider).latestRelease();
      final latest = AppVersion.tryParse(release.tag);

      if (current == null || latest == null) {
        state = UpdateFailed(
          'A versão publicada ("${release.tag}") não tem um número de versão '
          'reconhecível',
        );
      } else if (latest.isNewerThan(current)) {
        state = UpdateAvailable(
          release,
          latest,
          pickAsset(
            release.assets,
            currentUpdatePlatform,
            androidAbi: currentAndroidAbi,
            androidVariant: isAndroidTvBuild
                ? AndroidVariant.tv
                : AndroidVariant.mobile,
          ),
        );
      } else {
        state = UpdateUpToDate(current);
      }
    } on UpdateException catch (e) {
      state = UpdateFailed(e.message);
    }
  }

  Future<void> downloadAndInstall(UpdateAvailable update) async {
    final asset = update.asset;
    if (asset == null) return;

    final cancelToken = _download = CancelToken();
    state = UpdateDownloading(update, 0);
    var shownPercent = 0;

    try {
      final service = ref.read(updateServiceProvider);
      final file = await service.download(
        asset,
        cancelToken: cancelToken,
        onProgress: (progress) {
          // O Dio chama isto por cada chunk; só se reconstrói a UI a cada 1%.
          final percent = (progress * 100).floor();
          if (percent == shownPercent) return;
          shownPercent = percent;
          state = UpdateDownloading(update, progress);
        },
      );

      state = UpdateInstalling(update);
      if (Platform.isWindows) {
        // O instalador vai substituir os ficheiros da app: parar a
        // sincronização e fechar a base de dados antes de sair.
        await ref.read(syncServiceProvider).stop();
        await service.openInstaller(file);
        // Todas: a principal e o catálogo de cada perfil aberto.
        for (final name in Isar.instanceNames) {
          await Isar.getInstance(name)?.close();
        }
        exit(0);
      }

      await service.openInstaller(file);
      // Android/macOS: o instalador do sistema fica à frente. Se o
      // utilizador o cancelar, pode voltar a tentar daqui.
      state = update;
    } on UpdateException catch (e) {
      state = UpdateFailed(e.message, update: update);
    } on DioException catch (e) {
      state = CancelToken.isCancel(e)
          ? update
          : UpdateFailed('O download falhou; tenta de novo', update: update);
    } finally {
      _download = null;
    }
  }

  void cancelDownload() => _download?.cancel();
}

final updateControllerProvider = NotifierProvider<UpdateController, UpdateState>(
  UpdateController.new,
);
