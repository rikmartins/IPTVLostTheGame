import 'package:flutter/material.dart';

import '../data/local/models/app_settings.dart';

/// Cores tiradas do logo "SoPro Media" (aguarela sobre papel).
abstract final class BrandColors {
  /// Fundo do logo. Também é o fundo do tema claro, por isso o logo assenta
  /// na app sem moldura.
  static const paper = Color(0xFFFBF6EF);

  /// "SOPRO" (verde-azulado escuro): semente da paleta Material.
  static const ink = Color(0xFF21615A);

  /// Folhas cor de ocre: acento (tertiary).
  static const ochre = Color(0xFF7A5F12);

  /// Fundo do tema escuro: verde-azulado quase preto, em vez de cinzento
  /// neutro.
  static const night = Color(0xFF0F1514);
}

extension ThemePreferenceMode on ThemePreference {
  ThemeMode get themeMode => switch (this) {
    ThemePreference.light => ThemeMode.light,
    ThemePreference.dark => ThemeMode.dark,
    ThemePreference.system => ThemeMode.system,
  };

  String get label => switch (this) {
    ThemePreference.light => 'Claro',
    ThemePreference.dark => 'Escuro',
    ThemePreference.system => 'Automático (segue o sistema)',
  };
}

final lightTheme = _buildTheme(Brightness.light);
final darkTheme = _buildTheme(Brightness.dark);

ThemeData _buildTheme(Brightness brightness) {
  final light = brightness == Brightness.light;
  final scheme =
      ColorScheme.fromSeed(
        seedColor: BrandColors.ink,
        brightness: brightness,
      ).copyWith(
        surface: light ? BrandColors.paper : BrandColors.night,
        tertiary: light ? BrandColors.ochre : const Color(0xFFE3C66F),
        onTertiary: light ? Colors.white : const Color(0xFF3D2F00),
        tertiaryContainer: light
            ? const Color(0xFFF6E1A6)
            : const Color(0xFF5B4700),
        onTertiaryContainer: light
            ? const Color(0xFF261900)
            : const Color(0xFFFFE08E),
      );

  return ThemeData(
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    // Android TV: o foco do comando tem de se ver bem ao longe.
    focusColor: scheme.primary.withValues(alpha: light ? 0.20 : 0.28),
    hoverColor: scheme.onSurface.withValues(alpha: 0.05),
    // Sem ondas de toque: mais limpo e menos trabalho de pintura.
    splashFactory: NoSplash.splashFactory,
    // Ecrãs novos (player, série, pesquisa) aparecem logo, sem animação.
    pageTransitionsTheme: PageTransitionsTheme(
      builders: {
        for (final platform in TargetPlatform.values)
          platform: const _InstantPageTransitionsBuilder(),
      },
    ),
    dividerTheme: DividerThemeData(
      color: scheme.outlineVariant.withValues(alpha: light ? 0.6 : 0.35),
      space: 1,
      thickness: 1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    ),
  );
}

class _InstantPageTransitionsBuilder extends PageTransitionsBuilder {
  const _InstantPageTransitionsBuilder();

  @override
  Duration get transitionDuration => Duration.zero;

  @override
  Duration get reverseTransitionDuration => Duration.zero;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => child;
}
