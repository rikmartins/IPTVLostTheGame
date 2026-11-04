import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/login_screen.dart';
import 'home_shell.dart';
import 'session_controller.dart';

class IptvApp extends ConsumerWidget {
  const IptvApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);

    return MaterialApp(
      title: 'IPTV',
      debugShowCheckedModeBanner: false,
      theme: _theme,
      home: switch (session) {
        AsyncData(value: _?) => const HomeShell(),
        // Ler a sessão do cofre demora milissegundos: um ecrã vazio evita
        // o flash de um spinner.
        AsyncLoading() => const Scaffold(),
        _ => const LoginScreen(),
      },
    );
  }
}

final _theme = _buildTheme();

ThemeData _buildTheme() {
  const background = Color(0xFF0E0F13);
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF3D7BFF),
    brightness: Brightness.dark,
    surface: background,
  );

  return ThemeData(
    colorScheme: scheme,
    scaffoldBackgroundColor: background,
    // Android TV: o foco do comando tem de se ver bem ao longe.
    focusColor: scheme.primary.withValues(alpha: 0.28),
    hoverColor: scheme.onSurface.withValues(alpha: 0.05),
    // Sem ondas de toque: mais limpo e menos trabalho de pintura.
    splashFactory: NoSplash.splashFactory,
    dividerTheme: DividerThemeData(
      color: scheme.outlineVariant.withValues(alpha: 0.35),
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
