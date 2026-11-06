import 'package:flutter/material.dart';

import '../../features/search/search_screen.dart';
import 'brand.dart';
import 'profile_switcher.dart';
import 'sync_indicator.dart';

/// Cabeçalho comum às secções (título + estado da sincronização).
class SectionScaffold extends StatelessWidget {
  const SectionScaffold({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          SizedBox(
            height: 56,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  // No telemóvel não há barra lateral com o logo.
                  if (MediaQuery.sizeOf(context).width < 720) ...[
                    const BrandIcon(size: 30),
                    const SizedBox(width: 12),
                  ],
                  // Num telemóvel estreito o título encolhe, os botões não.
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Pesquisar canais, filmes e séries',
                    icon: const Icon(Icons.search),
                    onPressed: () => openSearch(context),
                  ),
                  const SizedBox(width: 4),
                  const ProfileSwitcher(),
                  const SizedBox(width: 8),
                  const SyncIndicator(),
                ],
              ),
            ),
          ),
          const Divider(),
          Expanded(child: child),
        ],
      ),
    );
  }
}
