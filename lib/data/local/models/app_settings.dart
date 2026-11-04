import 'package:isar_community/isar.dart';

part 'app_settings.g.dart';

/// Perfis de pré-buffer do player (ver `buffer_profiles.dart`).
enum BufferProfile { fast, normal, stable }

/// O primeiro valor é o que os registos antigos recebem: claro por omissão.
enum ThemePreference { light, dark, system }

/// Definições do utilizador. Registo único.
@Collection(accessor: 'settings')
class AppSettings {
  Id id = 0;

  @enumerated
  BufferProfile bufferProfile = BufferProfile.normal;

  @enumerated
  ThemePreference theme = ThemePreference.light;
}
