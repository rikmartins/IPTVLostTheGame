import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../data/phone_entry/phone_form_server.dart';

/// Código QR para preencher [form] no telemóvel. O servidor arranca com o
/// painel e fecha quando ele sai do ecrã.
class PhoneEntryPanel extends StatefulWidget {
  const PhoneEntryPanel({
    super.key,
    required this.form,
    required this.onSubmit,
  });

  final PhoneForm form;
  final PhoneSubmit onSubmit;

  @override
  State<PhoneEntryPanel> createState() => _PhoneEntryPanelState();
}

class _PhoneEntryPanelState extends State<PhoneEntryPanel> {
  PhoneFormServer? _server;
  String? _error;
  bool _starting = true;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void dispose() {
    _server?.close();
    super.dispose();
  }

  Future<void> _start() async {
    setState(() {
      _starting = true;
      _error = null;
    });
    try {
      // A callback lê sempre o widget atual (o ecrã pode ter sido
      // reconstruído com outra função).
      final server = await PhoneFormServer.start(
        widget.form,
        (values) => widget.onSubmit(values),
      );
      if (!mounted) {
        await server.close();
        return;
      }
      setState(() => _server = server);
    } on PhoneEntryUnavailable {
      if (mounted) {
        setState(
          () => _error =
              'Este dispositivo não está ligado a uma rede local (Wi-Fi ou '
              'cabo).',
        );
      }
    } on SocketException catch (e) {
      if (mounted) {
        setState(() => _error = 'Não foi possível abrir a ligação (${e.message}).');
      }
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final server = _server;

    final Widget content;
    if (_starting) {
      content = const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (server == null) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _error ?? 'Não foi possível preparar o código.',
            style: TextStyle(color: theme.colorScheme.error),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _start,
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar de novo'),
          ),
        ],
      );
    } else {
      final url = server.url.toString();
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              // Fundo branco também no tema escuro: as câmaras leem pior um
              // QR invertido.
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: QrImageView(
                data: url,
                size: 196,
                padding: EdgeInsets.zero,
                backgroundColor: Colors.white,
                semanticsLabel: 'Código QR para $url',
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: SelectableText(
              url,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall?.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Liga o telemóvel à mesma rede Wi-Fi, aponta a câmara ao código '
            'e preenche os dados na página que abrir.',
            style: theme.textTheme.bodySmall?.copyWith(color: muted),
          ),
          if (Platform.isWindows) ...[
            const SizedBox(height: 8),
            Text(
              'Se o Windows perguntar, permite o acesso em redes privadas.',
              style: theme.textTheme.bodySmall?.copyWith(color: muted),
            ),
          ],
        ],
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.qr_code_2, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('Usar o telemóvel', style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 16),
            content,
          ],
        ),
      ),
    );
  }
}
