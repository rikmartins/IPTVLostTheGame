import 'dart:isolate';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';

import '../../core/database/app_database.dart';
import '../local/models/account_info.dart';
import '../local/models/epg_programme.dart';
import '../local/models/live_channel.dart';
import '../local/models/media_category.dart';
import '../local/models/sync_state.dart';
import '../local/models/tv_series.dart';
import '../local/models/vod_movie.dart';
import '../remote/jellyfin/jellyfin_client.dart';
import '../remote/xtream/xmltv_parser.dart';
import '../remote/xtream/xtream_api.dart';
import '../remote/xtream/xtream_mappers.dart';
import '../sources/credentials.dart';
import '../sources/source_exception.dart';
import 'jellyfin_sync_worker.dart';
import 'sync_progress.dart';

/// Itens por transação. Transações pequenas libertam o lock de escrita
/// depressa (a UI pode gravar favoritos a meio de uma sincronização) e
/// mantêm a memória do lote limitada.
const _batchSize = 2000;
const epgBatchSize = 5000;

/// TV primeiro (é o que o utilizador abre), EPG logo a seguir porque
/// depende dos `epg_channel_id` dos canais, VOD no fim.
const _order = [SyncKind.live, SyncKind.epg, SyncKind.movies, SyncKind.series];

class SyncRequest {
  const SyncRequest({
    required this.events,
    required this.databaseDirectory,
    required this.databaseName,
    required this.credentials,
    required this.kinds,
    required this.epgPast,
    required this.epgFuture,
  });

  final SendPort events;
  final String databaseDirectory;

  /// Catálogo do perfil a sincronizar.
  final String databaseName;
  final SourceCredentials credentials;
  final Set<SyncKind> kinds;

  /// Janela de EPG guardada (o resto do guia é descartado durante o parse).
  final Duration epgPast;
  final Duration epgFuture;
}

/// Ponto de entrada do isolate (ver `CatalogSyncService`).
///
/// Protocolo com o isolate principal:
/// * worker → main: primeiro um [SendPort] de controlo, depois [SyncProgress];
/// * main → worker: qualquer mensagem no porto de controlo = cancelar.
Future<void> runSyncWorker(SyncRequest request) async {
  final control = ReceivePort();
  final cancelToken = CancelToken();
  control.listen((_) => cancelToken.cancel());
  request.events.send(control.sendPort);

  Isar? isar;
  CatalogSyncWorker? worker;
  try {
    isar = await AppDatabase.openInstance(
      request.databaseDirectory,
      name: request.databaseName,
    );
    worker = switch (request.credentials) {
      final XtreamCredentials credentials => XtreamSyncWorker(
        isar,
        request,
        cancelToken,
        XtreamApi(credentials),
      ),
      final JellyfinCredentials credentials => JellyfinSyncWorker(
        isar,
        request,
        cancelToken,
        JellyfinClient(credentials),
      ),
    };
    await worker.run();
  } finally {
    worker?.close();
    // Sem isto o porto aberto mantinha o isolate vivo para sempre.
    control.close();
    // A instância nativa é partilhada (Arc): isto liberta só a referência
    // deste isolate e a UI continua com a sua.
    await isar?.close();
  }
  // Garante a saída mesmo que fique algum socket keep-alive pendurado.
  // Em caso de erro não se chega aqui: o erro segue para o `onError`.
  Isolate.exit();
}

/// O que é igual para todas as fontes: a ordem das etapas, a escrita em
/// lotes e a limpeza do que o servidor deixou de ter. Cada fonte só
/// implementa o download de cada etapa.
abstract class CatalogSyncWorker {
  CatalogSyncWorker(this.isar, this.request, this.cancelToken)
    : stamp = DateTime.now().millisecondsSinceEpoch;

  final Isar isar;
  final SyncRequest request;
  final CancelToken cancelToken;

  /// Tudo o que esta sincronização escrever leva este carimbo; no fim de
  /// cada etapa bem-sucedida apaga-se o que não o tiver (itens removidos
  /// pelo fornecedor). Se a etapa falhar a meio, os dados antigos ficam
  /// intactos: a UI nunca vê a lista vazia.
  final int stamp;

  /// Valida a conta antes de descarregar o catálogo.
  @protected
  Future<AccountInfo> authenticate();

  @protected
  Future<int> syncLive();

  @protected
  Future<int> syncEpg();

  @protected
  Future<int> syncMovies();

  @protected
  Future<int> syncSeries();

  void close();

  Future<void> run() async {
    final kinds = _order.where(request.kinds.contains).toList();

    final AccountInfo account;
    try {
      account = await authenticate();
    } on SourceException catch (e) {
      for (final kind in kinds) {
        emit(SyncProgress(kind, _statusFor(e), error: e.message));
      }
      return;
    }
    isar.writeTxnSync(() => isar.accounts.putSync(account));

    for (final kind in kinds) {
      if (cancelToken.isCancelled) {
        emit(SyncProgress(kind, SyncStatus.cancelled));
        continue;
      }
      emit(SyncProgress(kind, SyncStatus.running));
      try {
        final count = switch (kind) {
          SyncKind.live => await syncLive(),
          SyncKind.epg => await syncEpg(),
          SyncKind.movies => await syncMovies(),
          SyncKind.series => await syncSeries(),
        };
        emit(SyncProgress(kind, SyncStatus.completed, processed: count));
      } on SourceException catch (e) {
        _recordFailure(kind, e.message);
        emit(SyncProgress(kind, _statusFor(e), error: e.message));
      } catch (e) {
        // Um erro inesperado numa etapa não deve impedir as seguintes.
        final message = scrubSecrets('$e')!;
        _recordFailure(kind, message);
        emit(SyncProgress(kind, SyncStatus.failed, error: message));
      }
    }
  }

  /// Chaves EPG dos canais guardados: só se guardam programas destes.
  @protected
  Set<int> knownEpgChannels() => {
    for (final id
        in isar.liveChannels.where().epgChannelIdProperty().findAllSync())
      if (id != null) EpgProgramme.keyFor(id),
  };

  /// Os lotes são `silent`: os watchers da UI não disparam a cada 2000
  /// itens, só uma vez no [commit].
  @protected
  void flush<T>(IsarCollection<T> collection, List<T> batch) {
    if (batch.isEmpty) return;
    if (cancelToken.isCancelled) {
      throw const SourceException(SourceErrorKind.cancelled);
    }
    isar.writeTxnSync(() => collection.putAllSync(batch), silent: true);
    batch.clear();
  }

  /// Junta [item] ao lote e grava-o quando enche.
  @protected
  void add<T>(IsarCollection<T> collection, List<T> batch, T item) {
    batch.add(item);
    if (batch.length >= _batchSize) flush(collection, batch);
  }

  /// Fecha a etapa: apaga o que o fornecedor removeu e regista o sucesso,
  /// numa só transação (que notifica a UI).
  ///
  /// [allowEmpty]: painéis Xtream sobrecarregados respondem por vezes `[]`,
  /// por isso aí uma lista vazia com dados locais é tratada como falha e
  /// nunca como "apagar tudo". Um servidor Jellyfin sem TV em direto (ou
  /// sem filmes) responde mesmo vazio.
  @protected
  void commit<T>(
    SyncKind kind,
    int count,
    IsarCollection<T> collection,
    void Function() purge, {
    bool allowEmpty = false,
  }) {
    if (!allowEmpty && count == 0 && collection.countSync() > 0) {
      throw const SourceException(
        SourceErrorKind.invalidResponse,
        'o servidor devolveu uma lista vazia',
      );
    }
    isar.writeTxnSync(() {
      purge();
      // O total real e não os itens processados: canais que partilham o
      // mesmo epg_channel_id geram o mesmo programa e o upsert junta-os.
      isar.syncStates.putSync(_successState(kind, collection.countSync()));
    });
  }

  /// Só apaga categorias se a lista de categorias chegou com conteúdo
  /// (ou se [force]). Corre dentro da transação do [commit].
  @protected
  void purgeCategories(
    CategoryType type,
    int downloaded, {
    bool force = false,
  }) {
    if (downloaded == 0 && !force) return;
    isar.categories
        .filter()
        .typeEqualTo(type)
        .not()
        .syncStampEqualTo(stamp)
        .deleteAllSync();
  }

  @protected
  void saveState(SyncKind kind, int count) {
    isar.writeTxnSync(
      () => isar.syncStates.putSync(_successState(kind, count)),
    );
  }

  @protected
  void emit(SyncProgress progress) => request.events.send(progress);

  SyncState _successState(SyncKind kind, int count) => SyncState()
    ..id = kind.index
    ..kind = kind
    ..lastSuccessAt = DateTime.now()
    ..itemCount = count
    ..lastError = null;

  void _recordFailure(SyncKind kind, String message) {
    isar.writeTxnSync(() {
      final state =
          isar.syncStates.getSync(kind.index) ??
          (SyncState()
            ..id = kind.index
            ..kind = kind);
      state.lastError = message;
      isar.syncStates.putSync(state);
    });
  }

  static SyncStatus _statusFor(SourceException e) =>
      e.kind == SourceErrorKind.cancelled
      ? SyncStatus.cancelled
      : SyncStatus.failed;
}

class XtreamSyncWorker extends CatalogSyncWorker {
  XtreamSyncWorker(super.isar, super.request, super.cancelToken, this.api);

  final XtreamApi api;

  @override
  Future<AccountInfo> authenticate() =>
      api.authenticate(cancelToken: cancelToken);

  @override
  void close() => api.close();

  @override
  Future<int> syncLive() async {
    final categories = await _download(
      action: XtreamAction.liveCategories,
      collection: isar.categories,
      map: (json, i) =>
          mapCategory(json, CategoryType.live, sortIndex: i, syncStamp: stamp),
    );
    final channels = await _download(
      action: XtreamAction.liveStreams,
      collection: isar.liveChannels,
      progress: SyncKind.live,
      map: (json, i) => mapLiveChannel(json, sortIndex: i, syncStamp: stamp),
    );
    commit(SyncKind.live, channels, isar.liveChannels, () {
      purgeCategories(CategoryType.live, categories);
      isar.liveChannels.filter().not().syncStampEqualTo(stamp).deleteAllSync();
    });
    return channels;
  }

  @override
  Future<int> syncMovies() async {
    final categories = await _download(
      action: XtreamAction.vodCategories,
      collection: isar.categories,
      map: (json, i) =>
          mapCategory(json, CategoryType.movie, sortIndex: i, syncStamp: stamp),
    );
    final movies = await _download(
      action: XtreamAction.vodStreams,
      collection: isar.movies,
      progress: SyncKind.movies,
      map: (json, i) => mapVodMovie(json, sortIndex: i, syncStamp: stamp),
    );
    commit(SyncKind.movies, movies, isar.movies, () {
      purgeCategories(CategoryType.movie, categories);
      isar.movies.filter().not().syncStampEqualTo(stamp).deleteAllSync();
    });
    return movies;
  }

  @override
  Future<int> syncSeries() async {
    final categories = await _download(
      action: XtreamAction.seriesCategories,
      collection: isar.categories,
      map: (json, i) => mapCategory(
        json,
        CategoryType.series,
        sortIndex: i,
        syncStamp: stamp,
      ),
    );
    final series = await _download(
      action: XtreamAction.series,
      collection: isar.series,
      progress: SyncKind.series,
      map: (json, i) => mapTvSeries(json, sortIndex: i, syncStamp: stamp),
    );
    commit(SyncKind.series, series, isar.series, () {
      purgeCategories(CategoryType.series, categories);
      isar.series.filter().not().syncStampEqualTo(stamp).deleteAllSync();
    });
    return series;
  }

  @override
  Future<int> syncEpg() async {
    // Só se guardam programas de canais que existem na lista: os XMLTV dos
    // fornecedores trazem muitas vezes milhares de canais que o utilizador
    // não tem.
    final known = knownEpgChannels();
    if (known.isEmpty) {
      saveState(SyncKind.epg, 0);
      return 0;
    }

    final now = DateTime.now().toUtc();
    final from = now.subtract(request.epgPast);
    final until = now.add(request.epgFuture);

    final batch = <EpgProgramme>[];
    var count = 0;

    await for (final p in parseXmltv(api.xmltv(cancelToken: cancelToken))) {
      final key = EpgProgramme.keyFor(p.channelId);
      if (!known.contains(key)) continue;
      if (p.stop.isBefore(from) || p.start.isAfter(until)) continue;

      batch.add(
        EpgProgramme()
          ..id = EpgProgramme.idFor(key, p.start)
          ..channelKey = key
          ..start = p.start
          ..stop = p.stop
          ..title = p.title
          ..description = p.description
          ..syncStamp = stamp,
      );
      count++;

      if (batch.length >= epgBatchSize) {
        flush(isar.epgProgrammes, batch);
        emit(SyncProgress(SyncKind.epg, SyncStatus.running, processed: count));
      }
    }
    flush(isar.epgProgrammes, batch);

    commit(SyncKind.epg, count, isar.epgProgrammes, () {
      isar.epgProgrammes.filter().not().syncStampEqualTo(stamp).deleteAllSync();
    });
    return count;
  }

  /// Descarrega uma lista em streaming e grava-a em lotes. Devolve o número
  /// de itens válidos gravados.
  Future<int> _download<T>({
    required String action,
    required IsarCollection<T> collection,
    required T? Function(Map<String, dynamic> json, int index) map,
    SyncKind? progress,
  }) async {
    final batch = <T>[];
    var count = 0;

    await for (final json in api.streamList(action, cancelToken: cancelToken)) {
      final item = map(json, count);
      if (item == null) continue;
      batch.add(item);
      count++;

      if (batch.length >= _batchSize) {
        flush(collection, batch);
        if (progress != null) {
          emit(SyncProgress(progress, SyncStatus.running, processed: count));
        }
      }
    }
    flush(collection, batch);
    return count;
  }
}
