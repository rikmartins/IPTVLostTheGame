import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/profiles_controller.dart';
import '../../../app/widgets/profile_switcher.dart';
import '../../../data/profiles/profile.dart';

/// Perfis guardados ("Perfil 1 - IPTV X", "Perfil 2 - IPTV Y"): tocar muda
/// de perfil; o menu muda o nome ou remove.
class ProfilesSection extends ConsumerWidget {
  const ProfilesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profilesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final profile in state.profiles)
          _ProfileTile(
            profile: profile,
            active: profile.id == state.activeId,
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.tonalIcon(
              onPressed: () => openAddProfile(context),
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('Adicionar perfil'),
            ),
          ),
        ),
      ],
    );
  }
}

enum _ProfileAction { rename, remove }

class _ProfileTile extends ConsumerWidget {
  const _ProfileTile({required this.profile, required this.active});

  final Profile profile;
  final bool active;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return ListTile(
      selected: active,
      leading: Icon(
        active ? Icons.check_circle : Icons.account_circle_outlined,
        color: active ? theme.colorScheme.primary : null,
      ),
      title: Text(profile.name),
      subtitle: Text(
        active ? 'Ativo · ${profileSummary(profile)}' : profileSummary(profile),
      ),
      onTap: active ? null : () => switchProfile(context, ref, profile),
      trailing: PopupMenuButton<_ProfileAction>(
        tooltip: 'Opções de ${profile.name}',
        onSelected: (action) => switch (action) {
          _ProfileAction.rename => _rename(context, ref),
          _ProfileAction.remove => confirmRemoveProfile(context, ref, profile),
        },
        itemBuilder: (_) => const [
          PopupMenuItem(
            value: _ProfileAction.rename,
            child: Text('Mudar nome'),
          ),
          PopupMenuItem(value: _ProfileAction.remove, child: Text('Remover')),
        ],
      ),
    );
  }

  Future<void> _rename(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController(text: profile.name);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nome do perfil'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 40,
          textCapitalization: TextCapitalization.sentences,
          onSubmitted: (value) => Navigator.of(context).pop(value),
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
    if (name == null) return;
    await ref.read(profilesProvider.notifier).rename(profile.id, name);
  }
}

/// Também é o "Terminar sessão" das definições (remove o perfil ativo).
Future<void> confirmRemoveProfile(
  BuildContext context,
  WidgetRef ref,
  Profile profile,
) async {
  final state = ref.read(profilesProvider);
  final isActive = profile.id == state.activeId;
  final next = state.profiles.where((p) => p.id != profile.id).firstOrNull;

  final consequence = switch ((isActive, next)) {
    (true, final Profile next) => ' A app passa para o perfil «${next.name}».',
    (true, null) => ' A app volta ao ecrã de login.',
    _ => '',
  };

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Remover «${profile.name}»?'),
      content: Text(
        'A lista de canais, filmes, séries e o guia deste perfil são '
        'apagados deste dispositivo.$consequence As definições e os dados '
        'memorizados mantêm-se.',
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
    await ref.read(profilesProvider.notifier).remove(profile.id);
  }
}
