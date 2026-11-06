import 'package:isar_community/isar.dart';

part 'app_settings.g.dart';

/// Perfis de pré-buffer do player (ver `buffer_profiles.dart`).
enum BufferProfile { fast, normal, stable }

/// O primeiro valor é o que os registos antigos recebem (claro); as
/// instalações novas começam no escuro (ver [AppSettings.theme]).
enum ThemePreference { light, dark, system }

/// Definições do utilizador. Registo único.
@Collection(accessor: 'settings')
class AppSettings {
  Id id = 0;

  @enumerated
  BufferProfile bufferProfile = BufferProfile.normal;

  @enumerated
  ThemePreference theme = ThemePreference.dark;

  /// Android: falso = só o tráfego desta app passa pela VPN. Fica pela
  /// negativa porque os registos antigos leem `false`.
  bool vpnWholeDevice = false;

  /// Android: o MediaCodec desenha diretamente no ecrã, sem copiar cada
  /// imagem de volta para a memória (menos CPU e bateria). As legendas do
  /// mpv não aparecem neste modo.
  bool directDecoding = false;
}
