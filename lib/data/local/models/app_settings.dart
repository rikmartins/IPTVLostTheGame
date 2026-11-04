import 'package:isar_community/isar.dart';

part 'app_settings.g.dart';

/// Perfis de pré-buffer do player (ver `buffer_profiles.dart`).
enum BufferProfile { fast, normal, stable }

/// Definições do utilizador. Registo único.
@Collection(accessor: 'settings')
class AppSettings {
  Id id = 0;

  @enumerated
  BufferProfile bufferProfile = BufferProfile.normal;
}
