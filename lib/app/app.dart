import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/login_screen.dart';
import 'home_shell.dart';
import 'session_controller.dart';
import 'settings_controller.dart';
import 'theme.dart';

const appName = 'Lost the Game';

class IptvApp extends ConsumerWidget {
  const IptvApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    // Lido do Isar em síncrono: a app abre logo no tema certo, sem flash.
    final theme = ref.watch(settingsProvider.select((s) => s.theme));

    return MaterialApp(
      title: appName,
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: theme.themeMode,
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
