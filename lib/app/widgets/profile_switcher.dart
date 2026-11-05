import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/profiles/profile.dart';
import '../../data/sources/credentials.dart';
import '../../features/auth/login_screen.dart';
import '../profiles_controller.dart';

/// "servidor · utilizador" (e "Jellyfin"), para distinguir perfis com
/// nomes parecidos.
String profileSummary(Profile profile) {
  final credentials = profile.credentials;
  final host = Uri.tryParse(credentials.serverUrl)?.host ?? '';
  final server = host.isEmpty ? credentials.serverUrl : host;
  return [
    if (credentials is JellyfinCredentials) credentials.kind.label,
    server,
    credentials.username,
  ].join(' · ');
}

Future<void> switchProfile(
  BuildContext context,
  WidgetRef ref,
  Profile profile,
) async {
  final messenger = ScaffoldMessenger.of(context);
  await ref.read(profilesProvider.notifier).switchTo(profile.id);
  messenger.showSnackBar(
    SnackBar(content: Text('Perfil «${profile.name}»')),
  );
}

Future<void> openAddProfile(BuildContext context) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => const LoginScreen(addingProfile: true),
    ),
  );
}

/// Perfil ativo no cabeçalho das secções, para mudar sem ir às definições.
/// Só aparece com dois ou mais perfis.
class ProfileSwitcher extends ConsumerWidget {
  const ProfileSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profilesProvider);
    final active = state.active;
    if (active == null || state.profiles.length < 2) {
      return const SizedBox.shrink();
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 200),
      child: ActionChip(
        avatar: const Icon(Icons.account_circle_outlined, size: 18),
        label: Text(active.name, overflow: TextOverflow.ellipsis),
        tooltip: 'Mudar de perfil',
        onPressed: () => _pick(context, ref, state),
      ),
    );
  }

  Future<void> _pick(
    BuildContext context,
    WidgetRef ref,
    ProfilesState state,
  ) async {
    final chosen = await showDialog<Profile>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Mudar de perfil'),
        children: [
          for (final profile in state.profiles)
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop(profile),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  profile.id == state.activeId
                      ? Icons.check_circle
                      : Icons.account_circle_outlined,
                  color: profile.id == state.activeId
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                title: Text(profile.name),
                subtitle: Text(profileSummary(profile)),
              ),
            ),
        ],
      ),
    );
    if (chosen == null || chosen.id == state.activeId || !context.mounted) {
      return;
    }
    await switchProfile(context, ref, chosen);
  }
}
