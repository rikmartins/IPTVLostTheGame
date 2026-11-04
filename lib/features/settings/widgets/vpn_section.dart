import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/settings_controller.dart';
import '../../../app/vpn_controller.dart';
import '../../../core/config/app_config.dart';
import '../../../data/phone_entry/phone_form_server.dart';
import '../../../data/vpn/vpn_backend.dart';
import '../../../data/vpn/wireguard_config.dart';
import '../../phone_entry/phone_entry_panel.dart';
import 'settings_tiles.dart';

/// VPN pessoal a partir de um ficheiro .conf do WireGuard.
class VpnSection extends ConsumerWidget {
  const VpnSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backend = ref.watch(vpnBackendProvider);
    if (!backend.isSupported) {
      return const SettingsHint(
        'A VPN ainda não está disponível neste sistema.',
      );
    }

    final vpn = ref.watch(vpnControllerProvider).value;
    if (vpn == null) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: LinearProgressIndicator(),
      );
    }

    final config = vpn.config;
    if (config == null) return const _NoConfig();

    final theme = Theme.of(context);
    final controller = ref.read(vpnControllerProvider.notifier);
    final wholeDevice = ref.watch(
      settingsProvider.select((s) => s.vpnWholeDevice),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SwitchListTile(
          title: const Text('VPN pessoal'),
          subtitle: Text(_statusText(vpn, config)),
          value: vpn.isOn,
          onChanged: vpn.busy
              ? null
              : (on) => on ? controller.connect() : controller.disconnect(),
        ),
        if (vpn.error != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              vpn.error!,
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        SettingsInfoTile(label: 'Servidor', value: config.endpoint),
        SettingsInfoTile(label: 'Endereço', value: config.addresses.join(', ')),
        SettingsInfoTile(
          label: 'Tráfego no túnel',
          value: config.routesAllTraffic ? 'Todo' : 'Só algumas redes',
        ),
        if (backend.supportsAppOnly)
          SwitchListTile(
            title: const Text('Todo o dispositivo'),
            subtitle: const Text(
              'Desligado: só o tráfego desta app passa pela VPN. '
              'Aplica-se na próxima ligação.',
            ),
            value: wholeDevice,
            onChanged: (value) =>
                ref.read(settingsProvider.notifier).setVpnWholeDevice(value),
          ),
        if (Platform.isWindows)
          const SettingsHint(
            'Na primeira ligação o Windows pede permissão de administrador, '
            'uma única vez. A VPN fica ativa em todo o sistema, também com a '
            'app fechada, até a desligares aqui. Reiniciar o PC também a '
            'desliga.',
          ),
        if (config.removedScripts)
          const SettingsHint(
            'O ficheiro tinha linhas PreUp/PostUp/PreDown/PostDown: foram '
            'ignoradas, porque correm comandos no sistema.',
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: vpn.busy ? null : () => _import(context, ref),
                icon: const Icon(Icons.upload_file),
                label: const Text('Substituir .conf'),
              ),
              if (isAndroidTvBuild)
                OutlinedButton.icon(
                  onPressed: vpn.busy
                      ? null
                      : () => _receiveFromPhone(context, ref),
                  icon: const Icon(Icons.qr_code_2),
                  label: const Text('Enviar do telemóvel'),
                ),
              TextButton.icon(
                onPressed: vpn.busy ? null : () => _confirmRemove(context, ref),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Remover'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _statusText(VpnState vpn, WireGuardConfig config) {
    return switch (vpn.status) {
      VpnStatus.connected => 'Ligada a ${config.endpoint}',
      VpnStatus.connecting when vpn.checking =>
        'A confirmar que o servidor responde…',
      VpnStatus.connecting => 'A ligar…',
      VpnStatus.disconnecting => 'A desligar…',
      VpnStatus.disconnected => 'Desligada',
    };
  }

  Future<void> _confirmRemove(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover a VPN?'),
        content: const Text(
          'A VPN é desligada e a configuração apagada deste dispositivo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(vpnControllerProvider.notifier).removeConfig();
    }
  }
}

class _NoConfig extends ConsumerWidget {
  const _NoConfig();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SettingsHint(
          'Liga a app a uma VPN tua: importa o ficheiro .conf do WireGuard '
          'que o teu fornecedor de VPN (ou o teu servidor) te deu.',
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.tonalIcon(
                onPressed: () => _import(context, ref),
                icon: const Icon(Icons.upload_file),
                label: const Text('Importar ficheiro .conf'),
              ),
              // Na TV o .conf costuma estar no telemóvel, e colar com o
              // comando é impraticável.
              if (isAndroidTvBuild)
                OutlinedButton.icon(
                  onPressed: () => _receiveFromPhone(context, ref),
                  icon: const Icon(Icons.qr_code_2),
                  label: const Text('Enviar do telemóvel'),
                ),
              OutlinedButton.icon(
                onPressed: () => _paste(context, ref),
                icon: const Icon(Icons.content_paste),
                label: const Text('Colar configuração'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Seletor de ficheiros do sistema. `FileType.any`: o Android não conhece um
/// tipo MIME para .conf e esconderia os ficheiros com um filtro.
Future<void> _import(BuildContext context, WidgetRef ref) async {
  final List<PlatformFile> files;
  try {
    files = await FilePicker.pickFiles(dialogTitle: 'Ficheiro .conf do WireGuard');
  } catch (_) {
    // Muitas boxes Android TV não têm seletor de documentos.
    if (context.mounted) await _paste(context, ref);
    return;
  }
  if (files.isEmpty) return;

  final bytes = await files.first.readAsBytes();
  // Um .conf tem poucas centenas de bytes; recusar ficheiros grandes evita
  // ler por engano um vídeo ou um APK.
  if (bytes.length > 64 * 1024) {
    if (context.mounted) _showError(context, 'O ficheiro não é um .conf.');
    return;
  }
  if (!context.mounted) return;
  await _save(context, ref, utf8.decode(bytes, allowMalformed: true));
}

const _vpnPhoneForm = PhoneForm(
  title: 'VPN pessoal (WireGuard)',
  intro:
      'Escolhe o ficheiro .conf que o teu fornecedor de VPN te deu, ou cola '
      'o conteúdo.',
  fields: [
    PhoneField(
      'config',
      'Configuração WireGuard',
      type: PhoneFieldType.wireguardConfig,
      placeholder: '[Interface]\nPrivateKey = …\nAddress = …',
    ),
  ],
  submitLabel: 'Enviar para a app',
  doneMessage: 'A configuração da VPN ficou guardada na app.',
);

/// O .conf vem do telemóvel pelo QR (ver [PhoneEntryPanel]).
Future<void> _receiveFromPhone(BuildContext context, WidgetRef ref) async {
  final controller = ref.read(vpnControllerProvider.notifier);
  final messenger = ScaffoldMessenger.of(context);
  final saved = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Configuração da VPN'),
      content: SizedBox(
        width: 340,
        child: PhoneEntryPanel(
          form: _vpnPhoneForm,
          onSubmit: (values) async {
            try {
              await controller.importConfig(values['config'] ?? '');
            } on FormatException catch (e) {
              return 'Ficheiro inválido: ${e.message}';
            }
            if (dialogContext.mounted) Navigator.of(dialogContext).pop(true);
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          autofocus: true,
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Fechar'),
        ),
      ],
    ),
  );
  if (saved == true) {
    messenger.showSnackBar(
      const SnackBar(content: Text('Configuração da VPN guardada')),
    );
  }
}

Future<void> _paste(BuildContext context, WidgetRef ref) async {
  final controller = TextEditingController();
  final text = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Colar configuração WireGuard'),
      content: SizedBox(
        width: 520,
        child: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 14,
          minLines: 8,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
          decoration: const InputDecoration(
            hintText: '[Interface]\nPrivateKey = …\nAddress = …\n\n'
                '[Peer]\nPublicKey = …\nEndpoint = …\nAllowedIPs = …',
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(controller.text),
          child: const Text('Guardar'),
        ),
      ],
    ),
  );
  controller.dispose();
  if (text == null || text.trim().isEmpty || !context.mounted) return;
  await _save(context, ref, text);
}

Future<void> _save(BuildContext context, WidgetRef ref, String text) async {
  try {
    await ref.read(vpnControllerProvider.notifier).importConfig(text);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Configuração da VPN guardada')),
      );
    }
  } on FormatException catch (e) {
    if (context.mounted) _showError(context, e.message);
  }
}

void _showError(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Ficheiro inválido: $message')),
  );
}
