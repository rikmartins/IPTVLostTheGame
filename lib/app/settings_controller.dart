import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/models/app_settings.dart';
import 'providers.dart';

class SettingsController extends Notifier<AppSettings> {
  @override
  AppSettings build() =>
      ref.watch(isarProvider).settings.getSync(0) ?? AppSettings();

  void setBufferProfile(BufferProfile profile) {
    final isar = ref.read(isarProvider);
    final updated = AppSettings()..bufferProfile = profile;
    isar.writeTxnSync(() => isar.settings.putSync(updated));
    state = updated;
  }
}

final settingsProvider = NotifierProvider<SettingsController, AppSettings>(
  SettingsController.new,
);
