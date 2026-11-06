import 'package:flutter/material.dart';

import 'artwork.dart';

/// Grelha de posters para Filmes e Séries.
///
/// Como na lista de canais, recebe só os IDs: cada célula lê o seu item do
/// Isar quando é construída e o `GridView.builder` só constrói as visíveis.
class PosterGrid extends StatelessWidget {
  const PosterGrid({
    super.key,
    required this.storageKey,
    required this.ids,
    required this.itemBuilder,
  });

  final String storageKey;
  final List<int> ids;
  final Widget Function(BuildContext context, int id) itemBuilder;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      key: PageStorageKey<String>(storageKey),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 160,
        mainAxisSpacing: 16,
        crossAxisSpacing: 12,
        // Poster 2:3 + duas linhas de título.
        childAspectRatio: 0.54,
      ),
      itemCount: ids.length,
      itemBuilder: (context, index) => KeyedSubtree(
        key: ValueKey(ids[index]),
        child: itemBuilder(context, ids[index]),
      ),
    );
  }
}

class PosterTile extends StatelessWidget {
  const PosterTile({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.rating,
    required this.onTap,
    this.progress,
    this.subtitle,
  });

  final String title;
  final String? imageUrl;

  /// 0–10; 0 = sem classificação.
  final double rating;
  final VoidCallback onTap;

  /// 0–1: quanto já se viu (barra por baixo do poster).
  final double? progress;

  /// Linha por baixo do título (ex.: o episódio a continuar).
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Poster(url: imageUrl, title: title),
                  if (progress case final progress?)
                    Positioned(
                      left: 6,
                      right: 6,
                      bottom: 6,
                      child: LinearProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        minHeight: 4,
                        borderRadius: BorderRadius.circular(2),
                        backgroundColor: Colors.black54,
                      ),
                    ),
                  if (rating > 0)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: DecoratedBox(
                        // Acento castanho do logo ("LOST").
                        decoration: BoxDecoration(
                          color: theme.colorScheme.tertiaryContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          child: Text(
                            rating.toStringAsFixed(1),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onTertiaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 36,
              child: Text(
                subtitle == null ? title : '$title\n$subtitle',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
