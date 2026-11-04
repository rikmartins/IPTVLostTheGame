import 'package:flutter/material.dart';

import '../features/live_tv/live_tv_screen.dart';
import '../features/series/series_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/vod/movies_screen.dart';

/// Navegação principal: TV, Filmes, Séries e Definições.
///
/// Barra lateral em ecrãs largos (TV, desktop) e barra inferior no
/// telemóvel. Cada secção é construída só na primeira visita e depois fica
/// viva (mantém grupo selecionado e scroll): abrir a app não paga as queries
/// de 186k filmes se o utilizador só vê TV.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  static const _sections = [
    (icon: Icons.live_tv_outlined, selected: Icons.live_tv, label: 'TV'),
    (icon: Icons.movie_outlined, selected: Icons.movie, label: 'Filmes'),
    (
      icon: Icons.video_library_outlined,
      selected: Icons.video_library,
      label: 'Séries',
    ),
    (
      icon: Icons.settings_outlined,
      selected: Icons.settings,
      label: 'Definições',
    ),
  ];

  int _index = 0;
  final _visited = <int>{0};

  void _select(int index) => setState(() {
    _index = index;
    _visited.add(index);
  });

  Widget _buildSection(int index) => switch (index) {
    0 => const LiveTvScreen(),
    1 => const MoviesScreen(),
    2 => const SeriesScreen(),
    _ => const SettingsScreen(),
  };

  @override
  Widget build(BuildContext context) {
    final body = IndexedStack(
      index: _index,
      children: [
        for (var i = 0; i < _sections.length; i++)
          _visited.contains(i) ? _buildSection(i) : const SizedBox.shrink(),
      ],
    );

    final wide =
        MediaQuery.sizeOf(context).width >= _wideNavigationBreakpoint;

    if (wide) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              right: false,
              child: NavigationRail(
                selectedIndex: _index,
                onDestinationSelected: _select,
                labelType: NavigationRailLabelType.all,
                groupAlignment: -0.9,
                destinations: [
                  for (final s in _sections)
                    NavigationRailDestination(
                      icon: Icon(s.icon),
                      selectedIcon: Icon(s.selected),
                      label: Text(s.label),
                    ),
                ],
              ),
            ),
            const VerticalDivider(),
            Expanded(child: body),
          ],
        ),
      );
    }

    return Scaffold(
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _select,
        height: 64,
        destinations: [
          for (final s in _sections)
            NavigationDestination(
              icon: Icon(s.icon),
              selectedIcon: Icon(s.selected),
              label: s.label,
            ),
        ],
      ),
    );
  }
}

const _wideNavigationBreakpoint = 720.0;
