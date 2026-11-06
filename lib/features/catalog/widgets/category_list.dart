import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/models/media_category.dart';
import '../category_providers.dart';
import 'category_visibility_dialog.dart';

/// Grupos à esquerda em ecrãs largos (TV, desktop, tablet) e em chips por
/// cima do conteúdo no telemóvel.
class CatalogLayout extends StatelessWidget {
  const CatalogLayout({
    super.key,
    required this.type,
    required this.allLabel,
    required this.child,
  });

  /// Abaixo disto (telemóvel em vertical) os grupos passam a chips.
  static const wideBreakpoint = 720.0;

  final CategoryType type;

  /// Rótulo da entrada "todos" (ex.: "Todos os canais").
  final String allLabel;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= wideBreakpoint) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 260,
                child: _CategorySidebar(type: type, allLabel: allLabel),
              ),
              const VerticalDivider(),
              Expanded(child: child),
            ],
          );
        }
        return Column(
          children: [
            _CategoryChips(type: type, allLabel: allLabel),
            const Divider(),
            Expanded(child: child),
          ],
        );
      },
    );
  }
}

class _CategorySidebar extends ConsumerWidget {
  const _CategorySidebar({required this.type, required this.allLabel});

  final CategoryType type;
  final String allLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = _groupEntries(ref, type, allLabel);
    final selected = ref.watch(selectedCategoryProvider(type));
    final hidden = ref.watch(hiddenCategoriesProvider(type)).length;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 6, 8, 0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  hidden == 0
                      ? 'Grupos'
                      : 'Grupos · $hidden ${hidden == 1 ? 'oculto' : 'ocultos'}',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              _ManageButton(type: type),
            ],
          ),
        ),
        Expanded(child: _sidebarList(entries, selected, scheme, ref)),
      ],
    );
  }

  Widget _sidebarList(
    List<_GroupEntry> entries,
    int? selected,
    ColorScheme scheme,
    WidgetRef ref,
  ) {
    return ListView.builder(
      // Cada secção guarda a sua posição de scroll.
      key: PageStorageKey('categories-${type.name}'),
      padding: const EdgeInsets.only(bottom: 8),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final categoryId = entry.id;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
          child: ListTile(
            dense: true,
            // Ponto de partida do foco do comando no Android TV (só pega se
            // nada na secção tiver foco).
            autofocus: index == 0,
            selected: selected == categoryId,
            selectedColor: scheme.onSurface,
            selectedTileColor: scheme.primary.withValues(alpha: 0.14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            leading: entry.icon == null ? null : Icon(entry.icon, size: 20),
            minLeadingWidth: 20,
            title: Text(
              entry.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => ref
                .read(selectedCategoryProvider(type).notifier)
                .select(categoryId),
          ),
        );
      },
    );
  }
}

class _CategoryChips extends ConsumerWidget {
  const _CategoryChips({required this.type, required this.allLabel});

  final CategoryType type;
  final String allLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = _groupEntries(ref, type, allLabel);
    final selected = ref.watch(selectedCategoryProvider(type));

    return SizedBox(
      height: 52,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: _ManageButton(type: type),
          ),
          Expanded(
            child: ListView.separated(
              key: PageStorageKey('chips-${type.name}'),
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(4, 8, 16, 8),
              itemCount: entries.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final entry = entries[index];
                final categoryId = entry.id;

                return ChoiceChip(
                  avatar: entry.icon == null
                      ? null
                      : Icon(entry.icon, size: 18),
                  label: Text(entry.label),
                  selected: selected == categoryId,
                  showCheckmark: false,
                  onSelected: (_) => ref
                      .read(selectedCategoryProvider(type).notifier)
                      .select(categoryId),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

typedef _GroupEntry = ({int? id, String label, IconData? icon});

/// "Todos", os grupos da app (favoritos, continuar a ver) e os do
/// fornecedor que não estão ocultos.
List<_GroupEntry> _groupEntries(
  WidgetRef ref,
  CategoryType type,
  String allLabel,
) {
  return [
    (id: null, label: allLabel, icon: null),
    for (final group in ref.watch(specialGroupsProvider(type)))
      (
        id: group.id,
        label: group.label,
        icon: group.id == kFavoritesGroup ? Icons.star_rounded : Icons.history,
      ),
    for (final category in ref.watch(visibleCategoriesProvider(type)))
      (id: category.categoryId, label: category.name, icon: null),
  ];
}

/// Abre a escolha dos grupos visíveis.
class _ManageButton extends StatelessWidget {
  const _ManageButton({required this.type});

  final CategoryType type;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Escolher grupos visíveis',
      icon: const Icon(Icons.tune),
      onPressed: () => showCategoryVisibility(context, type: type),
    );
  }
}

/// Mensagem centrada para listas vazias.
class EmptyCatalog extends StatelessWidget {
  const EmptyCatalog({super.key, required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40, color: muted),
          const SizedBox(height: 12),
          Text(message, style: TextStyle(color: muted)),
        ],
      ),
    );
  }
}
