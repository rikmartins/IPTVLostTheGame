import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/update_controller.dart';
import '../../../core/config/app_config.dart';
import '../../../data/update/github_release.dart';
import '../../../data/update/update_service.dart';
import 'settings_tiles.dart';

/// Versão instalada e atualização a partir das releases do GitHub.
class AppUpdateSection extends ConsumerWidget {
  const AppUpdateSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final version = ref.watch(appVersionProvider).value;
    final versionTile = SettingsInfoTile(
      label: 'Versão instalada',
      value: version?.toString() ?? '…',
    );

    if (githubRepository.isEmpty) {
      return Column(
        children: [
          versionTile,
          const SettingsHint(
            'As atualizações não estão configuradas (falta o repositório '
            'GitHub no build).',
          ),
        ],
      );
    }
    if (currentUpdatePlatform == UpdatePlatform.unsupported) {
      return Column(
        children: [
          versionTile,
          const SettingsHint(
            'Nesta plataforma as atualizações chegam pela loja de apps.',
          ),
        ],
      );
    }

    final state = ref.watch(updateControllerProvider);
    final controller = ref.read(updateControllerProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        versionTile,
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          child: switch (state) {
            UpdateIdle() => Align(
              alignment: Alignment.centerLeft,
              child: _CheckButton(onPressed: controller.check),
            ),
            UpdateChecking() => const _Busy('A procurar atualizações…'),
            UpdateUpToDate() => Row(
              children: [
                const Expanded(child: Text('Tens a versão mais recente.')),
                _CheckButton(onPressed: controller.check, again: true),
              ],
            ),
            final UpdateAvailable update => _AvailableUpdate(
              update: update,
              onInstall: () => controller.downloadAndInstall(update),
            ),
            UpdateDownloading(:final progress) => _Downloading(
              progress: progress,
              onCancel: controller.cancelDownload,
            ),
            UpdateInstalling() => _Busy(
              Platform.isWindows
                  ? 'A abrir o instalador; a app vai fechar…'
                  : 'A abrir o instalador…',
            ),
            UpdateFailed(:final message, :final update) => _Failed(
              message: message,
              onRetry: update == null
                  ? controller.check
                  : () => controller.downloadAndInstall(update),
            ),
          },
        ),
      ],
    );
  }
}

class _CheckButton extends StatelessWidget {
  const _CheckButton({required this.onPressed, this.again = false});

  final VoidCallback onPressed;
  final bool again;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(
      onPressed: onPressed,
      icon: const Icon(Icons.system_update_alt),
      label: Text(again ? 'Procurar de novo' : 'Procurar atualizações'),
    );
  }
}

class _AvailableUpdate extends StatelessWidget {
  const _AvailableUpdate({required this.update, required this.onInstall});

  final UpdateAvailable update;
  final VoidCallback onInstall;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final asset = update.asset;
    final notes = update.release.notes;
    final pageUrl = update.release.pageUrl;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nova versão ${update.version} disponível',
          style: theme.textTheme.titleSmall,
        ),
        if (notes != null) ...[
          const SizedBox(height: 8),
          Text(
            notes,
            maxLines: 8,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (asset != null)
              FilledButton.icon(
                onPressed: onInstall,
                icon: const Icon(Icons.download),
                label: Text(
                  asset.size > 0
                      ? 'Descarregar e instalar (${_megabytes(asset.size)})'
                      : 'Descarregar e instalar',
                ),
              )
            else
              const Text('Esta versão não tem instalador para este sistema.'),
            if (pageUrl != null)
              TextButton(
                onPressed: () => launchUrl(
                  Uri.parse(pageUrl),
                  mode: LaunchMode.externalApplication,
                ),
                child: const Text('Ver no GitHub'),
              ),
          ],
        ),
      ],
    );
  }
}

class _Downloading extends StatelessWidget {
  const _Downloading({required this.progress, required this.onCancel});

  final double progress;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LinearProgressIndicator(value: progress),
        Row(
          children: [
            Text('A descarregar… ${(progress * 100).floor()} %'),
            const Spacer(),
            TextButton(onPressed: onCancel, child: const Text('Cancelar')),
          ],
        ),
      ],
    );
  }
}

class _Busy extends StatelessWidget {
  const _Busy(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox.square(
          dimension: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        const SizedBox(width: 12),
        Text(message),
      ],
    );
  }
}

class _Failed extends StatelessWidget {
  const _Failed({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            message,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
        TextButton(onPressed: onRetry, child: const Text('Tentar de novo')),
      ],
    );
  }
}

String _megabytes(int bytes) => '${(bytes / (1024 * 1024)).toStringAsFixed(0)} MB';
