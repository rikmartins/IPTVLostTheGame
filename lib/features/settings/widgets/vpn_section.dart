import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/settings_controller.dart';
import '../../../app/vpn_controller.dart';
import '../../../core/config/app_config.dart';
import '../../../data/phone_entry/phone_form_server.dart';
import '../../../data/vpn/ikev2_config.dart';
import '../../../data/vpn/vpn_backend.dart';
import '../../../data/vpn/vpn_config_store.dart';
import '../../phone_entry/phone_entry_panel.dart';
import 'settings_tiles.dart';

/// VPN pessoal: ficheiro .conf do WireGuard, ou IKEv2 com as credenciais VPN
/// do fornecedor (não expiram como um .conf).
class VpnSection extends ConsumerWidget {
  const VpnSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vpn = ref.watch(vpnControllerProvider).value;
    if (vpn == null) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: LinearProgressIndicator(),
      );
    }
    if (!vpn.isSupported) {
      return const SettingsHint(
        'A VPN ainda não está disponível neste sistema.',
      );
    }

    final controller = ref.read(vpnControllerProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (vpn.wireguardSupported && vpn.ikev2Supported)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: SegmentedButton<VpnKind>(
                segments: const [
                  ButtonSegment(
                    value: VpnKind.wireguard,
                    icon: Icon(Icons.description_outlined),
                    label: Text('WireGuard'),
                  ),
                  ButtonSegment(
                    value: VpnKind.ikev2,
                    icon: Icon(Icons.key_outlined),
                    label: Text('IKEv2'),
                  ),
                ],
                selected: {vpn.kind},
                onSelectionChanged: vpn.busy
                    ? null
                    : (selection) => controller.setKind(selection.first),
              ),
            ),
          ),
        if (vpn.isConfigured)
          _Configured(vpn: vpn)
        else
          switch (vpn.kind) {
            VpnKind.wireguard => const _NoWireGuard(),
            VpnKind.ikev2 => const _NoIkev2(),
          },
      ],
    );
  }
}

class _Configured extends ConsumerWidget {
  const _Configured({required this.vpn});

  final VpnState vpn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final controller = ref.read(vpnControllerProvider.notifier);
    final wholeDevice = ref.watch(
      settingsProvider.select((s) => s.vpnWholeDevice),
    );
    final appOnlyAvailable =
        vpn.kind == VpnKind.wireguard &&
        ref.watch(vpnBackendProvider).supportsAppOnly;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SwitchListTile(
          title: const Text('VPN pessoal'),
          subtitle: Text(_statusText(vpn)),
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
        ...switch (vpn.kind) {
          VpnKind.wireguard => [
            SettingsInfoTile(label: 'Servidor', value: vpn.wireguard!.endpoint),
            SettingsInfoTile(
              label: 'Endereço',
              value: vpn.wireguard!.addresses.join(', '),
            ),
            SettingsInfoTile(
              label: 'Tráfego no túnel',
              value: vpn.wireguard!.routesAllTraffic
                  ? 'Todo'
                  : 'Só algumas redes',
            ),
          ],
          VpnKind.ikev2 => [
            SettingsInfoTile(label: 'Servidor', value: vpn.ikev2!.server),
            SettingsInfoTile(label: 'Utilizador', value: vpn.ikev2!.username),
          ],
        },
        if (appOnlyAvailable)
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
        if (Platform.isWindows && vpn.kind == VpnKind.wireguard)
          const SettingsHint(
            'Na primeira ligação o Windows pede permissão de administrador, '
            'uma única vez. A VPN fica ativa em todo o sistema, também com a '
            'app fechada, até a desligares aqui. Reiniciar o PC também a '
            'desliga.',
          ),
        if (Platform.isWindows && vpn.kind == VpnKind.ikev2)
          const SettingsHint(
            'Usa o IKEv2 do próprio Windows: aparece no ícone de rede como '
            '«SoPro Media IKEv2» e fica ligada em todo o sistema, também '
            'com a app fechada, até a desligares aqui ou aí.',
          ),
        if (Platform.isAndroid && vpn.kind == VpnKind.ikev2)
          const SettingsHint(
            'O IKEv2 do Android cobre todo o dispositivo. Na primeira ligação '
            'o Android pede autorização.',
          ),
        if (vpn.kind == VpnKind.wireguard && vpn.wireguard!.removedScripts)
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
              ...switch (vpn.kind) {
                VpnKind.wireguard => [
                  OutlinedButton.icon(
                    onPressed: vpn.busy ? null : () => _import(context, ref),
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Substituir .conf'),
                  ),
                  if (isAndroidTvBuild)
                    OutlinedButton.icon(
                      onPressed: vpn.busy
                          ? null
                          : () => _wireguardFromPhone(context, ref),
                      icon: const Icon(Icons.qr_code_2),
                      label: const Text('Enviar do telemóvel'),
                    ),
                ],
                VpnKind.ikev2 => [
                  OutlinedButton.icon(
                    onPressed: vpn.busy
                        ? null
                        : () => _editIkev2(context, ref, vpn.ikev2),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Alterar'),
                  ),
                  if (isAndroidTvBuild)
                    OutlinedButton.icon(
                      onPressed: vpn.busy
                          ? null
                          : () => _ikev2FromPhone(context, ref),
                      icon: const Icon(Icons.qr_code_2),
                      label: const Text('Enviar do telemóvel'),
                    ),
                ],
              },
              TextButton.icon(
                onPressed: vpn.busy
                    ? null
                    : () => _confirmRemove(context, ref, vpn.kind),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Remover'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _statusText(VpnState vpn) {
    return switch (vpn.status) {
      VpnStatus.connected => 'Ligada a ${vpn.server}',
      VpnStatus.connecting when vpn.checking =>
        'A confirmar que o servidor responde…',
      VpnStatus.connecting => 'A ligar…',
      VpnStatus.disconnecting => 'A desligar…',
      VpnStatus.disconnected => 'Desligada',
    };
  }

  Future<void> _confirmRemove(
    BuildContext context,
    WidgetRef ref,
    VpnKind kind,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover a VPN?'),
        content: Text(
          kind == VpnKind.wireguard
              ? 'A VPN é desligada e o ficheiro .conf apagado deste '
                    'dispositivo.'
              : 'A VPN é desligada e as credenciais IKEv2 apagadas deste '
                    'dispositivo.',
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

class _NoWireGuard extends ConsumerWidget {
  const _NoWireGuard();

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
                  onPressed: () => _wireguardFromPhone(context, ref),
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

class _NoIkev2 extends ConsumerWidget {
  const _NoIkev2();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SettingsHint(
          'Liga com as credenciais VPN da tua subscrição (na PureVPN: página '
          'Subscriptions). Não são o email e a palavra-passe da conta, e não '
          'expiram como um ficheiro .conf. O servidor é um endereço IKEv2 do '
          'fornecedor, por exemplo sx460134-ikev.dnsdialer.com.',
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.tonalIcon(
                onPressed: () => _editIkev2(context, ref, null),
                icon: const Icon(Icons.key_outlined),
                label: const Text('Configurar credenciais'),
              ),
              if (isAndroidTvBuild)
                OutlinedButton.icon(
                  onPressed: () => _ikev2FromPhone(context, ref),
                  icon: const Icon(Icons.qr_code_2),
                  label: const Text('Enviar do telemóvel'),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// --- WireGuard -------------------------------------------------------------

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

const _wireguardPhoneForm = PhoneForm(
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

Future<void> _wireguardFromPhone(BuildContext context, WidgetRef ref) {
  final controller = ref.read(vpnControllerProvider.notifier);
  return _receiveFromPhone(context, _wireguardPhoneForm, (values) async {
    try {
      await controller.importConfig(values['config'] ?? '');
      return null;
    } on FormatException catch (e) {
      return 'Ficheiro inválido: ${e.message}';
    }
  });
}

// --- IKEv2 -----------------------------------------------------------------

const _ikev2PhoneForm = PhoneForm(
  title: 'VPN IKEv2',
  intro:
      'Credenciais VPN da tua subscrição (na PureVPN: Subscriptions), não o '
      'email e a palavra-passe da conta.',
  fields: [
    PhoneField(
      'server',
      'Servidor IKEv2',
      type: PhoneFieldType.url,
      placeholder: 'sx460134-ikev.dnsdialer.com',
    ),
    PhoneField('username', 'Utilizador VPN', autocomplete: 'username'),
    PhoneField('password', 'Palavra-passe VPN', type: PhoneFieldType.password),
  ],
  submitLabel: 'Enviar para a app',
  doneMessage: 'As credenciais da VPN ficaram guardadas na app.',
);

Future<void> _ikev2FromPhone(BuildContext context, WidgetRef ref) {
  final controller = ref.read(vpnControllerProvider.notifier);
  return _receiveFromPhone(context, _ikev2PhoneForm, (values) async {
    try {
      await controller.saveIkev2(
        Ikev2Config.parse(
          server: values['server'] ?? '',
          username: values['username'] ?? '',
          password: values['password'] ?? '',
        ),
      );
      return null;
    } on FormatException catch (e) {
      return e.message;
    }
  });
}

Future<void> _editIkev2(
  BuildContext context,
  WidgetRef ref,
  Ikev2Config? current,
) async {
  final config = await showDialog<Ikev2Config>(
    context: context,
    builder: (_) => _Ikev2Dialog(initial: current),
  );
  if (config == null) return;
  await ref.read(vpnControllerProvider.notifier).saveIkev2(config);
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Credenciais da VPN guardadas')),
    );
  }
}

class _Ikev2Dialog extends StatefulWidget {
  const _Ikev2Dialog({this.initial});

  final Ikev2Config? initial;

  @override
  State<_Ikev2Dialog> createState() => _Ikev2DialogState();
}

class _Ikev2DialogState extends State<_Ikev2Dialog> {
  late final _server = TextEditingController(text: widget.initial?.server);
  late final _username = TextEditingController(text: widget.initial?.username);
  late final _password = TextEditingController(text: widget.initial?.password);
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _server.dispose();
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    try {
      Navigator.of(context).pop(
        Ikev2Config.parse(
          server: _server.text,
          username: _username.text,
          password: _password.text,
        ),
      );
    } on FormatException catch (e) {
      setState(() => _error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: const Text('VPN IKEv2'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Credenciais VPN da subscrição (na PureVPN: Subscriptions), '
                'não o email e a palavra-passe da conta.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _server,
                autofocus: !isAndroidTvBuild,
                keyboardType: TextInputType.url,
                autocorrect: false,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Servidor IKEv2',
                  hintText: 'sx460134-ikev.dnsdialer.com',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _username,
                autocorrect: false,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.username],
                decoration: const InputDecoration(labelText: 'Utilizador VPN'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _password,
                obscureText: _obscure,
                autocorrect: false,
                enableSuggestions: false,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  labelText: 'Palavra-passe VPN',
                  suffixIcon: IconButton(
                    tooltip: _obscure ? 'Mostrar' : 'Ocultar',
                    icon: Icon(
                      _obscure ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Guardar')),
      ],
    );
  }
}

// --- Telemóvel -------------------------------------------------------------

/// Dados da VPN vindos do telemóvel pelo QR (ver [PhoneEntryPanel]). O
/// diálogo fecha quando [onValues] aceita os dados.
Future<void> _receiveFromPhone(
  BuildContext context,
  PhoneForm form,
  Future<String?> Function(Map<String, String> values) onValues,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final saved = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(form.title),
      content: SizedBox(
        width: 340,
        child: PhoneEntryPanel(
          form: form,
          onSubmit: (values) async {
            final error = await onValues(values);
            if (error == null && dialogContext.mounted) {
              Navigator.of(dialogContext).pop(true);
            }
            return error;
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
