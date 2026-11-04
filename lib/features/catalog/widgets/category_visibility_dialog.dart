import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../data/local/models/media_category.dart';
import '../category_providers.dart';

/// Escolha dos grupos que aparecem numa secção (TV, filmes ou séries).
///
/// Cada alteração é gravada logo: não há "cancelar", e a lista por trás do
/// diálogo atualiza-se enquanto se escolhe.
Future<void> showCategoryVisibility(
  BuildContext context, {
  required CategoryType type,
}) {
  final size = MediaQuery.sizeOf(context);
  final panel = CategoryVisibilityPanel(type: type);
  return showDialog<void>(
    context: context,
    builder: (_) => size.width < 600
        ? Dialog.fullscreen(child: panel)
        : Dialog(
            clipBehavior: Clip.antiAlias,
            child: SizedBox(
              width: 560,
              height: math.min(size.height * 0.85, 760),
              child: panel,
            ),
          ),
  );
}

/// "canais", "filmes", "séries".
String categoryItemsNoun(CategoryType type, int count) => switch (type) {
  CategoryType.live => count == 1 ? 'canal' : 'canais',
  CategoryType.movie => count == 1 ? 'filme' : 'filmes',
  CategoryType.series => count == 1 ? 'série' : 'séries',
};

class CategoryVisibilityPanel extends ConsumerStatefulWidget {
  const CategoryVisibilityPanel({super.key, required this.type});

  final CategoryType type;

  @override
  ConsumerState<CategoryVisibilityPanel> createState() =>
      _CategoryVisibilityPanelState();
}

class _CategoryVisibilityPanelState
    extends ConsumerState<CategoryVisibilityPanel> {
  final _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final type = widget.type;
    final categories = ref.watch(categoriesProvider(type));
    final hidden = ref.watch(hiddenCategoriesProvider(type));
    final counts = ref.watch(categoryCountsProvider(type));
    final notifier = ref.read(hiddenCategoriesProvider(type).notifier);

    final query = _query.text.trim().toLowerCase();
    final shown = query.isEmpty
        ? categories
        : [
            for (final c in categories)
              if (c.name.toLowerCase().contains(query)) c,
          ];
    final visible = categories
        .where((c) => !hidden.contains(c.categoryId))
        .length;

    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final ids = [for (final c in shown) c.categoryId];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 16, 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Grupos visíveis',
                  style: theme.textTheme.titleLarge,
                ),
              ),
              // Primeiro foco no comando: sair é o mais comum depois de
              // alterar um ou dois grupos.
              FilledButton(
                autofocus: true,
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Concluído'),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            '$visible de ${categories.length} grupos visíveis. '
            'Os grupos ocultos também saem de "Todos".',
            style: theme.textTheme.bodySmall?.copyWith(color: muted),
          ),
        ),
        // No comando da TV escrever é penoso e o campo de texto pode
        // prender o foco: lá fica só a lista e os dois botões.
        if (!isAndroidTvBuild)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
            child: TextField(
              controller: _query,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                isDense: true,
                prefixIcon: const Icon(Icons.search),
                hintText: 'Procurar grupo',
                border: const OutlineInputBorder(),
                suffixIcon: query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Limpar',
                        icon: const Icon(Icons.close),
                        onPressed: () => setState(_query.clear),
                      ),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Wrap(
            spacing: 8,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.visibility_outlined),
                label: Text(query.isEmpty ? 'Mostrar todos' : 'Mostrar estes'),
                onPressed: ids.isEmpty
                    ? null
                    : () => notifier.setAllHidden(ids, hidden: false),
              ),
              TextButton.icon(
                icon: const Icon(Icons.visibility_off_outlined),
                label: Text(query.isEmpty ? 'Ocultar todos' : 'Ocultar estes'),
                onPressed: ids.isEmpty
                    ? null
                    : () => notifier.setAllHidden(ids, hidden: true),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: shown.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      categories.isEmpty
                          ? 'Ainda não há grupos. Aparecem quando a '
                                'sincronização terminar.'
                          : 'Nenhum grupo com esse nome.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: muted),
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: shown.length,
                  itemBuilder: (context, index) {
                    final category = shown[index];
                    final id = category.categoryId;
                    final count = counts[id] ?? 0;
                    return CheckboxListTile(
                      key: ValueKey(id),
                      dense: true,
                      value: !hidden.contains(id),
                      title: Text(
                        category.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '$count ${categoryItemsNoun(type, count)}',
                      ),
                      onChanged: (value) =>
                          notifier.setHidden(id, hidden: value != true),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
