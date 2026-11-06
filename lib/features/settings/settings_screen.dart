import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/profiles_controller.dart';
import '../../app/providers.dart';
import '../../app/session_controller.dart';
import '../../app/settings_controller.dart';
import '../../app/sync_controller.dart';
import '../../app/theme.dart';
import '../../app/widgets/section_scaffold.dart';
import '../../app/widgets/sync_indicator.dart';
import '../../core/config/app_config.dart';
import '../../core/utils/time_format.dart';
import '../../data/local/models/account_info.dart';
import '../../data/local/models/app_settings.dart';
import '../../data/local/models/sync_state.dart';
import '../../data/sources/credentials.dart';
import '../player/buffer_profiles.dart';
import 'widgets/app_update_section.dart';
import 'widgets/profiles_section.dart';
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
    final credentials = ref.watch(sessionProvider);

    return SectionScaffold(
      title: 'Definições',
      child: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              const SettingsSectionTitle('Perfis'),
              const ProfilesSection(),
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
              if (Platform.isAndroid)
                SwitchListTile(
                  value: settings.directDecoding,
                  onChanged: (value) => ref
                      .read(settingsProvider.notifier)
                      .setDirectDecoding(value),
                  title: const Text('Descodificação direta no ecrã'),
                  subtitle: const Text(
                    'O vídeo vai da placa gráfica diretamente para o ecrã, '
                    'sem cópias: menos CPU e bateria, bom em TV boxes '
                    'fracas. As legendas dos filmes não aparecem neste modo. '
                    'Se o vídeo ficar preto, desliga.',
                  ),
                ),
              // A Play Store só aceita VPN em apps que são uma VPN.
              if (!isPlayStoreBuild) ...[
                const SettingsSectionTitle('VPN'),
                const VpnSection(),
              ],
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
              // O Jellyfin não tem validade nem limite de ligações.
              if (credentials is JellyfinCredentials) ...[
                SettingsInfoTile(
                  label: 'Utilizador',
                  value: credentials.username,
                ),
                SettingsInfoTile(
                  label: 'Servidor Jellyfin',
                  value: credentials.serverUrl,
                ),
              ] else if (account != null) ...[
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
                    onPressed: () {
                      final active = ref.read(profilesProvider).active;
                      if (active != null) {
                        confirmRemoveProfile(context, ref, active);
                      }
                    },
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
