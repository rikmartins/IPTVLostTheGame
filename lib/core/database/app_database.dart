import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/local/models/account_info.dart';
import '../../data/local/models/app_settings.dart';
import '../../data/local/models/epg_programme.dart';
import '../../data/local/models/live_channel.dart';
import '../../data/local/models/media_category.dart';
import '../../data/local/models/sync_state.dart';
import '../../data/local/models/tv_series.dart';
import '../../data/local/models/vod_movie.dart';

/// Ponto único de abertura do Isar.
///
/// A UI lê exclusivamente daqui; a rede só escreve, e a partir de outro
/// isolate (ver `XtreamSyncService`).
class AppDatabase {
  AppDatabase._(this.isar, this.directory);

  final Isar isar;

  /// Necessário para abrir a mesma instância no isolate de sincronização
  /// (o `path_provider` não está disponível em isolates de fundo).
  final String directory;

  static const instanceName = 'iptv';

  static final schemas = <CollectionSchema<dynamic>>[
    AccountInfoSchema,
    MediaCategorySchema,
    LiveChannelSchema,
    VodMovieSchema,
    TvSeriesSchema,
    EpgProgrammeSchema,
    SyncStateSchema,
    AppSettingsSchema,
  ];

  static Future<AppDatabase> open() async {
    // Application Support e não Documents: no Windows o Documents é a pasta
    // pessoal do utilizador e no iOS entra no backup do iCloud.
    final dir = await getApplicationSupportDirectory();
    final isar = await openInstance(
      dir.path,
      inspector: kDebugMode,
      // Cada sincronização reescreve muitas páginas; compacta no arranque
      // quando o ficheiro tiver mais do dobro do espaço útil.
      compactOnLaunch: const CompactCondition(
        minFileSize: 64 * 1024 * 1024,
        minRatio: 2.0,
      ),
    );
    return AppDatabase._(isar, dir.path);
  }

  /// Abrir com o mesmo nome e diretório noutro isolate devolve a mesma
  /// instância nativa (com watchers partilhados), não uma cópia.
  static Future<Isar> openInstance(
    String directory, {
    bool inspector = false,
    CompactCondition? compactOnLaunch,
  }) {
    return Isar.open(
      schemas,
      directory: directory,
      name: instanceName,
      inspector: inspector,
      compactOnLaunch: compactOnLaunch,
    );
  }
}
