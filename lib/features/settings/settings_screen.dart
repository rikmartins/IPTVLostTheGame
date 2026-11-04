import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/session_controller.dart';
import '../../app/settings_controller.dart';
import '../../app/sync_controller.dart';
import '../../app/theme.dart';
import '../../app/widgets/section_scaffold.dart';
import '../../app/widgets/sync_indicator.dart';
import '../../core/utils/time_format.dart';
import '../../data/local/models/account_info.dart';
import '../../data/local/models/app_settings.dart';
import '../../data/local/models/sync_state.dart';
import '../player/buffer_profiles.dart';
import 'widgets/app_update_section.dart';
import 'widgets/settings_tiles.dart';
import 'widgets/vpn_section.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final syncing = ref.watch(syncControllerProvider).isRunning;

    // Conta e estado da lista mudam no fim de cada etapa de sincronização.
    for (final kind in SyncKind.values) {
      ref.watch(catalogVersionProvider(kind));
    }
    final isar = ref.watch(isarProvider);
    final account = isar.accounts.getSync(0);

    return SectionScaffold(
      title: 'Definições',
      child: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              const SettingsSectionTitle('Aparência'),
              RadioGroup<ThemePreference>(
                groupValue: settings.theme,
                onChanged: (theme) {
                  if (theme == null) return;
                  ref.read(settingsProvider.notifier).setTheme(theme);
                },
                child: Column(
                  children: [
                    for (final theme in ThemePreference.values)
                      RadioListTile<ThemePreference>(
                        value: theme,
                        title: Text(theme.label),
                      ),
                  ],
                ),
              ),
              const SettingsSectionTitle('Reprodução'),
              const SettingsHint(
                'Pré-buffer (network cache): quanto vídeo o player acumula '
                'antes de arrancar e durante a reprodução. Aplica-se ao '
                'próximo canal ou filme que abrires.',
              ),
              RadioGroup<BufferProfile>(
                groupValue: settings.bufferProfile,
                onChanged: (profile) {
                  if (profile == null) return;
                  ref
                      .read(settingsProvider.notifier)
                      .setBufferProfile(profile);
                },
                child: Column(
                  children: [
                    for (final profile in BufferProfile.values)
                      RadioListTile<BufferProfile>(
                        value: profile,
                        title: Text(profile.label),
                        subtitle: Text(profile.description),
                      ),
                  ],
                ),
              ),
              const SettingsSectionTitle('VPN'),
              const VpnSection(),
              const SettingsSectionTitle('Lista'),
              for (final kind in SyncKind.values)
                _SyncStateTile(
                  kind: kind,
                  state: isar.syncStates.getSync(kind.index),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton.tonalIcon(
                    onPressed: syncing
                        ? null
                        : () => ref.read(sessionProvider.notifier).refresh(),
                    icon: const Icon(Icons.sync),
                    label: Text(syncing ? 'A atualizar…' : 'Atualizar agora'),
                  ),
                ),
              ),
              const SettingsSectionTitle('Aplicação'),
              const AppUpdateSection(),
              const SettingsSectionTitle('Conta'),
              if (account != null) ...[
                SettingsInfoTile(label: 'Utilizador', value: account.username),
                SettingsInfoTile(label: 'Estado', value: account.status),
                SettingsInfoTile(
                  label: 'Expira',
                  value: account.expiresAt == null
                      ? 'Sem data de expiração'
                      : _date(account.expiresAt!),
                ),
                SettingsInfoTile(
                  label: 'Ligações',
                  value:
                      '${account.activeConnections} ativas de '
                      '${account.maxConnections}',
                ),
              ],
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmLogout(context, ref),
                    icon: const Icon(Icons.logout),
                    label: const Text('Terminar sessão'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terminar sessão?'),
        content: const Text(
          'A lista de canais, filmes, séries e o guia são apagados deste '
          'dispositivo. As definições e os dados de acesso memorizados '
          'mantêm-se.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Terminar sessão'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(sessionProvider.notifier).logout();
    }
  }
}

class _SyncStateTile extends StatelessWidget {
  const _SyncStateTile({required this.kind, required this.state});

  final SyncKind kind;
  final SyncState? state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = this.state;
    final lastSuccess = state?.lastSuccessAt;

    final subtitle = switch (state?.lastError) {
      final String error => 'Falhou: $error',
      null when lastSuccess != null => 'Atualizado ${_relative(lastSuccess)}',
      _ => 'Ainda não sincronizado',
    };

    return ListTile(
      title: Text(kind.label),
      subtitle: Text(
        subtitle,
        style: state?.lastError == null
            ? null
            : TextStyle(color: theme.colorScheme.error),
      ),
      trailing: state == null
          ? null
          : Text(
              formatCount(state.itemCount),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
    );
  }
}

String _date(DateTime time) {
  final local = time.toLocal();
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(local.day)}/${two(local.month)}/${local.year}';
}

String _relative(DateTime time) {
  final elapsed = DateTime.now().difference(time);
  if (elapsed.inMinutes < 1) return 'agora mesmo';
  if (elapsed.inMinutes < 60) return 'há ${elapsed.inMinutes} min';
  if (elapsed.inHours < 24) return 'há ${elapsed.inHours} h';
  return 'em ${_date(time)} às ${hhmm(time)}';
}
