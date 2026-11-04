import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/session_controller.dart';
import '../../app/widgets/brand.dart';
import '../../core/config/app_config.dart';
import '../../data/phone_entry/phone_form_server.dart';
import '../../data/remote/xtream/xtream_exception.dart';
import '../phone_entry/phone_entry_panel.dart';

/// Escrever com o comando da TV é lento: lá o QR aparece logo. Nos
/// computadores fica atrás de um botão; no telemóvel não faz sentido.
final bool _phoneEntryAvailable =
    isAndroidTvBuild || Platform.isWindows || Platform.isMacOS || Platform.isLinux;

const _phoneForm = PhoneForm(
  title: 'Iniciar sessão',
  intro: 'Dados Xtream Codes do teu fornecedor de IPTV.',
  fields: [
    PhoneField(
      'server',
      'Servidor',
      type: PhoneFieldType.url,
      placeholder: 'http://exemplo.com:8080',
    ),
    PhoneField('username', 'Utilizador'),
    PhoneField('password', 'Palavra-passe', type: PhoneFieldType.password),
  ],
  submitLabel: 'Entrar',
  doneMessage: 'Sessão iniciada. A app já está a carregar a tua lista.',
);

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _server = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();

  bool _busy = false;
  bool _obscure = true;
  bool _remember = true;
  bool _showPhone = isAndroidTvBuild;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fillRemembered();
  }

  @override
  void dispose() {
    _server.dispose();
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _fillRemembered() async {
    final saved = await ref.read(authRepositoryProvider).remembered();
    if (saved == null || !mounted) return;
    // Não apagar o que já se tenha começado a escrever.
    if (_server.text.isNotEmpty || _username.text.isNotEmpty) return;
    setState(() {
      _server.text = saved.serverUrl;
      _username.text = saved.username;
      _password.text = saved.password;
    });
  }

  /// Devolve a mensagem de erro, ou `null` se entrou.
  Future<String?> _login() async {
    if (_busy) return 'Já está a iniciar sessão. Aguarda.';
    if (_server.text.trim().isEmpty ||
        _username.text.trim().isEmpty ||
        _password.text.isEmpty) {
      return 'Preenche todos os campos';
    }

    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(sessionProvider.notifier)
          .login(
            server: _server.text,
            username: _username.text,
            password: _password.text,
            remember: _remember,
          );
      // Sucesso: a app troca para a grelha sozinha (ver IptvApp).
      return null;
    } on XtreamException catch (e) {
      return e.message;
    } catch (_) {
      return 'Erro inesperado ao iniciar sessão';
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _submit() async {
    final error = await _login();
    if (error != null && mounted) setState(() => _error = error);
  }

  /// Dados vindos do telemóvel: aparecem no formulário (a TV mostra o que
  /// chegou) e entra como se tivessem sido escritos aqui.
  Future<String?> _submitFromPhone(Map<String, String> values) async {
    if (!mounted) return 'A app fechou o ecrã de login.';
    if (_busy) return 'Já está a iniciar sessão. Aguarda.';
    setState(() {
      _server.text = values['server'] ?? '';
      _username.text = values['username'] ?? '';
      _password.text = values['password'] ?? '';
      _obscure = true;
    });
    final error = await _login();
    if (error != null && mounted) setState(() => _error = error);
    return error;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    final form = AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(child: BrandLogo()),
          const SizedBox(height: 16),
          Text(
            'Inicia sessão com os dados Xtream Codes do teu fornecedor.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: muted),
          ),
          const SizedBox(height: 28),
          TextField(
            controller: _server,
            // Na TV, focar um campo abre logo o teclado por cima do QR.
            autofocus: !isAndroidTvBuild,
            enabled: !_busy,
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.next,
            autocorrect: false,
            autofillHints: const [AutofillHints.url],
            decoration: const InputDecoration(
              labelText: 'Servidor',
              hintText: 'http://exemplo.com:8080',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _username,
            enabled: !_busy,
            textInputAction: TextInputAction.next,
            autocorrect: false,
            autofillHints: const [AutofillHints.username],
            decoration: const InputDecoration(labelText: 'Utilizador'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _password,
            enabled: !_busy,
            obscureText: _obscure,
            autocorrect: false,
            enableSuggestions: false,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.password],
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              labelText: 'Palavra-passe',
              suffixIcon: IconButton(
                tooltip: _obscure ? 'Mostrar' : 'Ocultar',
                icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
          const SizedBox(height: 4),
          CheckboxListTile(
            value: _remember,
            onChanged: _busy
                ? null
                : (value) => setState(() => _remember = value ?? true),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            title: const Text('Memorizar dados'),
            subtitle: const Text(
              'Ficam guardados neste dispositivo, para não os escreveres '
              'outra vez (mesmo depois de terminares sessão).',
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ],
          const SizedBox(height: 16),
          FilledButton(
            autofocus: isAndroidTvBuild,
            onPressed: _busy ? null : _submit,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            child: _busy
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Entrar'),
          ),
          if (_phoneEntryAvailable && !isAndroidTvBuild) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => setState(() => _showPhone = !_showPhone),
              icon: const Icon(Icons.qr_code_2),
              label: Text(
                _showPhone ? 'Esconder o código QR' : 'Preencher no telemóvel',
              ),
            ),
          ],
        ],
      ),
    );

    final panel = _showPhone && _phoneEntryAvailable
        ? PhoneEntryPanel(form: _phoneForm, onSubmit: _submitFromPhone)
        : null;
    final wide = MediaQuery.sizeOf(context).width >= 820;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: switch (panel) {
            null => ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: form,
            ),
            final panel when wide => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: 420, child: form),
                const SizedBox(width: 48),
                SizedBox(width: 320, child: panel),
              ],
            ),
            final panel => ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [form, const SizedBox(height: 24), panel],
              ),
            ),
          },
        ),
      ),
    );
  }
}
