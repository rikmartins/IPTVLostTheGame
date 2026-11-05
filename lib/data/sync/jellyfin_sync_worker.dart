import 'package:isar_community/isar.dart';

import '../local/models/account_info.dart';
import '../local/models/epg_programme.dart';
import '../local/models/live_channel.dart';
import '../local/models/media_category.dart';
import '../local/models/sync_state.dart';
import '../local/models/tv_series.dart';
import '../local/models/vod_movie.dart';
import '../remote/jellyfin/jellyfin_client.dart';
import '../remote/jellyfin/jellyfin_mappers.dart';
import 'sync_progress.dart';
import 'sync_worker.dart';

/// Catálogo de um servidor Jellyfin: cada biblioteca de filmes ou de
/// séries é um grupo, e os canais (sem grupos) vêm da TV em direto.
class JellyfinSyncWorker extends CatalogSyncWorker {
  JellyfinSyncWorker(super.isar, super.request, super.cancelToken, this.client);

  final JellyfinClient client;

  List<JellyfinView>? _views;

  String get _server => client.credentials.serverUrl;

  Future<List<JellyfinView>> _libraries() async =>
      _views ??= await client.views(cancelToken: cancelToken);

  @override
  Future<AccountInfo> authenticate() =>
      client.currentUser(cancelToken: cancelToken);

  @override
  void close() => client.close();

  @override
  Future<int> syncLive() async {
    // Sem a biblioteca "TV em direto" o servidor não tem sintonizadores
    // (ou o utilizador não tem acesso): não há canais a pedir.
    final hasLiveTv = (await _libraries()).any((view) => view.isLiveTv);
    final channels = <Map<String, dynamic>>[];
    if (hasLiveTv) {
      await for (final page in client.liveChannels(cancelToken: cancelToken)) {
        channels.addAll(page);
      }
    }
    // Ordenados pelo número, como num comando de TV.
    channels.sort((a, b) {
      final byNumber = channelSortKey(a).compareTo(channelSortKey(b));
      if (byNumber != 0) return byNumber;
      return '${a['Name']}'.toLowerCase().compareTo(
        '${b['Name']}'.toLowerCase(),
      );
    });

    final batch = <LiveChannel>[];
    var count = 0;
    for (final json in channels) {
      final channel = mapJellyfinChannel(
        json,
        serverUrl: _server,
        sortIndex: count,
        syncStamp: stamp,
      );
      if (channel == null) continue;
      add(isar.liveChannels, batch, channel);
      count++;
    }
    flush(isar.liveChannels, batch);

    commit(SyncKind.live, count, isar.liveChannels, () {
      purgeCategories(CategoryType.live, 0, force: true);
      isar.liveChannels.filter().not().syncStampEqualTo(stamp).deleteAllSync();
    }, allowEmpty: true);
    return count;
  }

  @override
  Future<int> syncEpg() async {
    final known = knownEpgChannels();
    if (known.isEmpty) {
      isar.writeTxnSync(() => isar.epgProgrammes.clearSync());
      saveState(SyncKind.epg, 0);
      return 0;
    }

    final now = DateTime.now().toUtc();
    final batch = <EpgProgramme>[];
    var count = 0;
    await for (final page in client.programmes(
      from: now.subtract(request.epgPast),
      until: now.add(request.epgFuture),
      cancelToken: cancelToken,
    )) {
      for (final json in page) {
        final programme = mapJellyfinProgramme(json, syncStamp: stamp);
        if (programme == null || !known.contains(programme.channelKey)) {
          continue;
        }
        batch.add(programme);
        count++;
      }
      if (batch.length >= epgBatchSize) {
        flush(isar.epgProgrammes, batch);
        emit(SyncProgress(SyncKind.epg, SyncStatus.running, processed: count));
      }
    }
    flush(isar.epgProgrammes, batch);

    commit(SyncKind.epg, count, isar.epgProgrammes, () {
      isar.epgProgrammes.filter().not().syncStampEqualTo(stamp).deleteAllSync();
    }, allowEmpty: true);
    return count;
  }

  @override
  Future<int> syncMovies() async {
    final count = await _syncLibraries(
      type: CategoryType.movie,
      progress: SyncKind.movies,
      itemType: 'Movie',
      fields: 'DateCreated',
      include: (view) => view.hasMovies,
      collection: isar.movies,
      map: (json, categoryId, sortIndex) => mapJellyfinMovie(
        json,
        serverUrl: _server,
        categoryId: categoryId,
        sortIndex: sortIndex,
        syncStamp: stamp,
      ),
    );
    commit(SyncKind.movies, count, isar.movies, () {
      purgeCategories(CategoryType.movie, 0, force: true);
      isar.movies.filter().not().syncStampEqualTo(stamp).deleteAllSync();
    }, allowEmpty: true);
    return count;
  }

  @override
  Future<int> syncSeries() async {
    final count = await _syncLibraries(
      type: CategoryType.series,
      progress: SyncKind.series,
      itemType: 'Series',
      fields: 'DateCreated,DateLastMediaAdded,Overview,Genres',
      include: (view) => view.hasSeries,
      collection: isar.series,
      map: (json, categoryId, sortIndex) => mapJellyfinSeries(
        json,
        serverUrl: _server,
        categoryId: categoryId,
        sortIndex: sortIndex,
        syncStamp: stamp,
      ),
    );
    commit(SyncKind.series, count, isar.series, () {
      purgeCategories(CategoryType.series, 0, force: true);
      isar.series.filter().not().syncStampEqualTo(stamp).deleteAllSync();
    }, allowEmpty: true);
    return count;
  }

  /// Grava os itens de cada biblioteca e uma categoria por biblioteca que
  /// tenha algum. Devolve o total de itens.
  Future<int> _syncLibraries<T>({
    required CategoryType type,
    required SyncKind progress,
    required String itemType,
    required String fields,
    required bool Function(JellyfinView view) include,
    required IsarCollection<T> collection,
    required T? Function(
      Map<String, dynamic> json,
      int categoryId,
      int sortIndex,
    )
    map,
  }) async {
    final libraries = (await _libraries()).where(include).toList();
    final categories = <MediaCategory>[];
    final batch = <T>[];
    var total = 0;

    for (final (index, library) in libraries.indexed) {
      final categoryId = categoryKeyOf(normalizeJellyfinId(library.id));
      var inLibrary = 0;
      await for (final page in client.items(
        libraryId: library.id,
        itemType: itemType,
        fields: fields,
        cancelToken: cancelToken,
      )) {
        for (final json in page) {
          final item = map(json, categoryId, inLibrary);
          if (item == null) continue;
          add(collection, batch, item);
          inLibrary++;
        }
        emit(
          SyncProgress(
            progress,
            SyncStatus.running,
            processed: total + inLibrary,
          ),
        );
      }
      flush(collection, batch);
      total += inLibrary;

      if (inLibrary > 0) {
        categories.add(
          MediaCategory()
            ..id = MediaCategory.idFor(type, categoryId)
            ..type = type
            ..categoryId = categoryId
            ..name = library.name
            ..sortIndex = index
            ..syncStamp = stamp,
        );
      }
    }
    flush(isar.categories, categories);
    return total;
  }
}
