import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/login_screen.dart';
import 'home_shell.dart';
import 'profiles_controller.dart';
import 'session_controller.dart';
import 'settings_controller.dart';
import 'theme.dart';

const appName = 'SoPro Media';

class IptvApp extends ConsumerWidget {
  const IptvApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final profileId = ref.watch(profilesProvider.select((s) => s.activeId));
    // Lido do Isar em síncrono: a app abre logo no tema certo, sem flash.
    final theme = ref.watch(settingsProvider.select((s) => s.theme));

    return MaterialApp(
      title: appName,
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: theme.themeMode,
      // A chave recria a navegação ao mudar de perfil: o grupo e o scroll
      // de um perfil não fazem sentido no catálogo do outro.
      home: session == null
          ? const LoginScreen()
          : HomeShell(key: ValueKey(profileId)),
    );
  }
}
