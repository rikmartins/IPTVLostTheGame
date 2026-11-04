import 'package:flutter/material.dart';

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
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
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
