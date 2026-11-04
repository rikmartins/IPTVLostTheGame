import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/models/app_settings.dart';
import 'providers.dart';

class SettingsController extends Notifier<AppSettings> {
  @override
  AppSettings build() =>
      ref.watch(isarProvider).settings.getSync(0) ?? AppSettings();

  void setBufferProfile(BufferProfile profile) =>
      _save((s) => s.bufferProfile = profile);

  void setTheme(ThemePreference theme) => _save((s) => s.theme = theme);

  void setVpnWholeDevice(bool value) => _save((s) => s.vpnWholeDevice = value);

  /// Copia o estado atual antes de mudar um campo: um `AppSettings()` novo
  /// repunha os outros campos nos valores por omissão.
  void _save(void Function(AppSettings settings) change) {
    final updated = AppSettings()
      ..bufferProfile = state.bufferProfile
      ..theme = state.theme
      ..vpnWholeDevice = state.vpnWholeDevice;
    change(updated);

    final isar = ref.read(isarProvider);
    isar.writeTxnSync(() => isar.settings.putSync(updated));
    state = updated;
  }
}

final settingsProvider = NotifierProvider<SettingsController, AppSettings>(
  SettingsController.new,
);
