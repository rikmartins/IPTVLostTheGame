import 'dart:isolate';

import 'package:dio/dio.dart';
import 'package:isar_community/isar.dart';

import '../../core/database/app_database.dart';
import '../local/models/account_info.dart';
import '../local/models/epg_programme.dart';
import '../local/models/live_channel.dart';
import '../local/models/media_category.dart';
import '../local/models/sync_state.dart';
import '../local/models/tv_series.dart';
import '../local/models/vod_movie.dart';
import '../remote/xtream/xmltv_parser.dart';
import '../remote/xtream/xtream_api.dart';
import '../remote/xtream/xtream_credentials.dart';
import '../remote/xtream/xtream_exception.dart';
import '../remote/xtream/xtream_mappers.dart';
import 'sync_progress.dart';

/// Itens por transação. Transações pequenas libertam o lock de escrita
/// depressa (a UI pode gravar favoritos a meio de uma sincronização) e
/// mantêm a memória do lote limitada.
const _batchSize = 2000;
const _epgBatchSize = 5000;

/// TV primeiro (é o que o utilizador abre), EPG logo a seguir porque
/// depende dos `epg_channel_id` dos canais, VOD no fim.
const _order = [SyncKind.live, SyncKind.epg, SyncKind.movies, SyncKind.series];

class SyncRequest {
  const SyncRequest({
    required this.events,
    required this.databaseDirectory,
    required this.credentials,
    required this.kinds,
    required this.epgPast,
    required this.epgFuture,
  });

  final SendPort events;
  final String databaseDirectory;
  final XtreamCredentials credentials;
  final Set<SyncKind> kinds;

  /// Janela de EPG guardada (o resto do XMLTV é descartado durante o parse).
  final Duration epgPast;
  final Duration epgFuture;
}

/// Ponto de entrada do isolate (ver `XtreamSyncService`).
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
  XtreamApi? api;
  try {
    isar = await AppDatabase.openInstance(request.databaseDirectory);
    api = XtreamApi(request.credentials);
    await _SyncWorker(isar, api, request, cancelToken).run();
  } finally {
    api?.close();
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

class _SyncWorker {
  _SyncWorker(this.isar, this.api, this.request, this.cancelToken)
    : stamp = DateTime.now().millisecondsSinceEpoch;

  final Isar isar;
  final XtreamApi api;
  final SyncRequest request;
  final CancelToken cancelToken;

  /// Tudo o que esta sincronização escrever leva este carimbo; no fim de
  /// cada etapa bem-sucedida apaga-se o que não o tiver (itens removidos
  /// pelo fornecedor). Se a etapa falhar a meio, os dados antigos ficam
  /// intactos: a UI nunca vê a lista vazia.
  final int stamp;

  Future<void> run() async {
    final kinds = _order.where(request.kinds.contains).toList();

    // Valida a conta antes de descarregar centenas de MB.
    final AccountInfo account;
    try {
      account = await api.authenticate(cancelToken: cancelToken);
    } on XtreamException catch (e) {
      for (final kind in kinds) {
        _emit(SyncProgress(kind, _statusFor(e), error: e.message));
      }
      return;
    }
    isar.writeTxnSync(() => isar.accounts.putSync(account));

    for (final kind in kinds) {
      if (cancelToken.isCancelled) {
        _emit(SyncProgress(kind, SyncStatus.cancelled));
        continue;
      }
      _emit(SyncProgress(kind, SyncStatus.running));
      try {
        final count = switch (kind) {
          SyncKind.live => await _syncLive(),
          SyncKind.epg => await _syncEpg(),
          SyncKind.movies => await _syncMovies(),
          SyncKind.series => await _syncSeries(),
        };
        _emit(SyncProgress(kind, SyncStatus.completed, processed: count));
      } on XtreamException catch (e) {
        _recordFailure(kind, e.message);
        _emit(SyncProgress(kind, _statusFor(e), error: e.message));
      } catch (e) {
        // Um erro inesperado numa etapa não deve impedir as seguintes.
        final message = scrubSecrets('$e')!;
        _recordFailure(kind, message);
        _emit(SyncProgress(kind, SyncStatus.failed, error: message));
      }
    }
  }

  // --- Etapas ---------------------------------------------------------------

  Future<int> _syncLive() async {
    final categories = await _download(
      action: XtreamAction.liveCategories,
      collection: isar.categories,
      map: (json, i) => mapCategory(
        json,
        CategoryType.live,
        sortIndex: i,
        syncStamp: stamp,
      ),
    );
    final channels = await _download(
      action: XtreamAction.liveStreams,
      collection: isar.liveChannels,
      progress: SyncKind.live,
      map: (json, i) => mapLiveChannel(json, sortIndex: i, syncStamp: stamp),
    );
    _commit(SyncKind.live, channels, isar.liveChannels, () {
      _purgeCategories(CategoryType.live, categories);
      isar.liveChannels.filter().not().syncStampEqualTo(stamp).deleteAllSync();
    });
    return channels;
  }

  Future<int> _syncMovies() async {
    final categories = await _download(
      action: XtreamAction.vodCategories,
      collection: isar.categories,
      map: (json, i) => mapCategory(
        json,
        CategoryType.movie,
        sortIndex: i,
        syncStamp: stamp,
      ),
    );
    final movies = await _download(
      action: XtreamAction.vodStreams,
      collection: isar.movies,
      progress: SyncKind.movies,
      map: (json, i) => mapVodMovie(json, sortIndex: i, syncStamp: stamp),
    );
    _commit(SyncKind.movies, movies, isar.movies, () {
      _purgeCategories(CategoryType.movie, categories);
      isar.movies.filter().not().syncStampEqualTo(stamp).deleteAllSync();
    });
    return movies;
  }

  Future<int> _syncSeries() async {
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
    _commit(SyncKind.series, series, isar.series, () {
      _purgeCategories(CategoryType.series, categories);
      isar.series.filter().not().syncStampEqualTo(stamp).deleteAllSync();
    });
    return series;
  }

  Future<int> _syncEpg() async {
    // Só se guardam programas de canais que existem na lista: os XMLTV dos
    // fornecedores trazem muitas vezes milhares de canais que o utilizador
    // não tem.
    final known = <int>{
      for (final id
          in isar.liveChannels.where().epgChannelIdProperty().findAllSync())
        if (id != null) EpgProgramme.keyFor(id),
    };
    if (known.isEmpty) {
      _saveState(SyncKind.epg, 0);
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

      if (batch.length >= _epgBatchSize) {
        _flush(isar.epgProgrammes, batch);
        _emit(SyncProgress(SyncKind.epg, SyncStatus.running, processed: count));
      }
    }
    _flush(isar.epgProgrammes, batch);

    _commit(SyncKind.epg, count, isar.epgProgrammes, () {
      isar.epgProgrammes.filter().not().syncStampEqualTo(stamp).deleteAllSync();
    });
    return count;
  }

  // --- Infraestrutura -------------------------------------------------------

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
        _flush(collection, batch);
        if (progress != null) {
          _emit(SyncProgress(progress, SyncStatus.running, processed: count));
        }
      }
    }
    _flush(collection, batch);
    return count;
  }

  /// Os lotes são `silent`: os watchers da UI não disparam a cada 2000
  /// itens, só uma vez no [_commit].
  void _flush<T>(IsarCollection<T> collection, List<T> batch) {
    if (batch.isEmpty) return;
    if (cancelToken.isCancelled) {
      throw const XtreamException(XtreamErrorKind.cancelled);
    }
    isar.writeTxnSync(() => collection.putAllSync(batch), silent: true);
    batch.clear();
  }

  /// Fecha a etapa: apaga o que o fornecedor removeu e regista o sucesso,
  /// numa só transação (que notifica a UI).
  void _commit<T>(
    SyncKind kind,
    int count,
    IsarCollection<T> collection,
    void Function() purge,
  ) {
    // Painéis sobrecarregados respondem por vezes `[]`. Lista vazia com
    // dados locais é tratada como falha, nunca como "apagar tudo".
    if (count == 0 && collection.countSync() > 0) {
      throw const XtreamException(
        XtreamErrorKind.invalidResponse,
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

  /// Só apaga categorias se a lista de categorias chegou com conteúdo.
  /// Corre dentro da transação do [_commit].
  void _purgeCategories(CategoryType type, int downloaded) {
    if (downloaded == 0) return;
    isar.categories
        .filter()
        .typeEqualTo(type)
        .not()
        .syncStampEqualTo(stamp)
        .deleteAllSync();
  }

  void _saveState(SyncKind kind, int count) {
    isar.writeTxnSync(() => isar.syncStates.putSync(_successState(kind, count)));
  }

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

  void _emit(SyncProgress progress) => request.events.send(progress);

  static SyncStatus _statusFor(XtreamException e) =>
      e.kind == XtreamErrorKind.cancelled
      ? SyncStatus.cancelled
      : SyncStatus.failed;
}
