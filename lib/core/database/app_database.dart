import 'dart:io';

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

  /// Base já aberta noutra pasta (testes com o Isar nativo).
  @visibleForTesting
  AppDatabase.withInstance(this.isar, this.directory);

  final Isar isar;

  /// Necessário para abrir a mesma instância no isolate de sincronização
  /// (o `path_provider` não está disponível em isolates de fundo).
  final String directory;

  /// Base principal: as definições do dispositivo e, por compatibilidade
  /// com as versões de perfil único, o catálogo do primeiro perfil.
  static const instanceName = 'iptv';

  /// Catálogo de cada perfil seguinte (ver `Profile.databaseName`).
  static String profileInstanceName(String profileId) => 'iptv_$profileId';

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
    String name = instanceName,
    bool inspector = false,
    CompactCondition? compactOnLaunch,
  }) {
    return Isar.open(
      schemas,
      directory: directory,
      name: name,
      inspector: inspector,
      compactOnLaunch: compactOnLaunch,
    );
  }

  /// A instância já aberta com esse nome, ou abre-a.
  static Future<Isar> openCatalog(String directory, String name) async =>
      Isar.getInstance(name) ?? await openInstance(directory, name: name);

  /// Tudo o que vem do fornecedor. As definições ficam.
  static Future<void> clearCatalog(Isar isar) {
    return isar.writeTxn(() async {
      await isar.accounts.clear();
      await isar.categories.clear();
      await isar.liveChannels.clear();
      await isar.movies.clear();
      await isar.series.clear();
      await isar.epgProgrammes.clear();
      await isar.syncStates.clear();
    });
  }

  static final _profileFile = RegExp(r'^(iptv_[0-9a-f]{8})\.isar(-lck)?$');

  /// Apaga ficheiros de perfis que já não existem (removidos com a base de
  /// dados ainda aberta, ou numa sessão que fechou a meio). Corre no
  /// arranque, antes de abrir qualquer catálogo de perfil.
  static Future<void> deleteOrphans(
    String directory, {
    required Set<String> keep,
  }) async {
    try {
      await for (final entity in Directory(directory).list()) {
        if (entity is! File) continue;
        final name = entity.uri.pathSegments.last;
        final match = _profileFile.firstMatch(name);
        if (match == null || keep.contains(match.group(1))) continue;
        try {
          await entity.delete();
        } on FileSystemException {
          // Ainda em uso: fica para o próximo arranque.
        }
      }
    } on FileSystemException {
      // Pasta inacessível: nada a limpar.
    }
  }
}
