import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';

import 'app/app.dart';
import 'app/profiles_controller.dart';
import 'app/providers.dart';
import 'core/database/app_database.dart';
import 'data/profiles/profile.dart';
import 'data/profiles/profile_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  final database = await AppDatabase.open();

  ProfilesState profiles;
  try {
    profiles = await const ProfileStore().load(
      legacyDatabaseName: AppDatabase.instanceName,
    );
  } catch (_) {
    // Cofre ilegível (ex.: chave do Keystore perdida num restauro): login.
    profiles = const ProfilesState();
  }
  await AppDatabase.deleteOrphans(
    database.directory,
    keep: {for (final p in profiles.profiles) p.databaseName},
  );
  final active = profiles.active;
  if (active != null) {
    await AppDatabase.openCatalog(database.directory, active.databaseName);
  }

  runApp(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        initialProfilesProvider.overrideWithValue(profiles),
      ],
      child: const IptvApp(),
    ),
  );
}
