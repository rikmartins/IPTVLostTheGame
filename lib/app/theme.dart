import 'package:flutter/material.dart';

import '../data/local/models/app_settings.dart';

/// Cores tiradas do logo "Lost the Game" (aguarela sobre papel).
abstract final class BrandColors {
  /// Fundo do logo. Também é o fundo do tema claro, por isso o logo assenta
  /// na app sem moldura.
  static const paper = Color(0xFFF5F4EE);

  /// Folhas e botão de play: semente da paleta Material.
  static const leaf = Color(0xFF5E8F4E);

  /// "LOST": acento castanho (tertiary).
  static const bark = Color(0xFF926035);

  /// Fundo do tema escuro: verde quase preto, em vez de cinzento neutro.
  static const night = Color(0xFF111511);
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
        seedColor: BrandColors.leaf,
        brightness: brightness,
      ).copyWith(
        surface: light ? BrandColors.paper : BrandColors.night,
        tertiary: light ? BrandColors.bark : const Color(0xFFE2B48A),
        onTertiary: light ? Colors.white : const Color(0xFF462A10),
        tertiaryContainer: light
            ? const Color(0xFFF4DEC8)
            : const Color(0xFF6A4424),
        onTertiaryContainer: light
            ? const Color(0xFF2F1704)
            : const Color(0xFFFFDCC2),
      );

  return ThemeData(
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    // Android TV: o foco do comando tem de se ver bem ao longe.
    focusColor: scheme.primary.withValues(alpha: light ? 0.20 : 0.28),
    hoverColor: scheme.onSurface.withValues(alpha: 0.05),
    // Sem ondas de toque: mais limpo e menos trabalho de pintura.
    splashFactory: NoSplash.splashFactory,
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
