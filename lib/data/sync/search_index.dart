import 'dart:isolate';

import 'package:isar_community/isar.dart';

import '../../core/database/app_database.dart';
import '../local/models/live_channel.dart';
import '../local/models/tv_series.dart';
import '../local/models/vod_movie.dart';

const _pageSize = 2000;

/// Catálogos gravados antes da pesquisa global (até à 0.1.8) não têm o
/// `searchName`: o Isar só o calcula quando um item é gravado. Regrava
/// esses itens uma vez, num isolate próprio, sem ir à rede. Nas bases já
/// atualizadas sai logo.
Future<void> ensureSearchIndex(String directory, String databaseName) {
  return Isolate.run(() async {
    final isar = await AppDatabase.openInstance(directory, name: databaseName);
    try {
      reindexSearchWords(isar);
    } finally {
      await isar.close();
    }
  }, debugName: 'search-index');
}

/// O trabalho do [ensureSearchIndex], no isolate atual.
void reindexSearchWords(Isar isar) {
  _reindexChannels(isar);
  _reindexMovies(isar);
  _reindexSeries(isar);
}

void _reindexChannels(Isar isar) {
  final items = isar.liveChannels;
  if (items.filter().searchNameIsNull().limit(1).countSync() == 0) return;
  _rewrite(
    isar,
    (from) => items.where().idGreaterThan(from).limit(_pageSize).findAllSync(),
    items.putAllSync,
    (item) => item.id,
  );
}

void _reindexMovies(Isar isar) {
  final items = isar.movies;
  if (items.filter().searchNameIsNull().limit(1).countSync() == 0) return;
  _rewrite(
    isar,
    (from) => items.where().idGreaterThan(from).limit(_pageSize).findAllSync(),
    items.putAllSync,
    (item) => item.id,
  );
}

void _reindexSeries(Isar isar) {
  final items = isar.series;
  if (items.filter().searchNameIsNull().limit(1).countSync() == 0) return;
  _rewrite(
    isar,
    (from) => items.where().idGreaterThan(from).limit(_pageSize).findAllSync(),
    items.putAllSync,
    (item) => item.id,
  );
}

/// Lê e regrava cada lote na mesma transação: se a sincronização estiver a
/// correr ao mesmo tempo, nunca se regrava uma cópia antiga por cima do
/// que ela acabou de escrever.
void _rewrite<T>(
  Isar isar,
  List<T> Function(Id after) page,
  List<Id> Function(List<T> items) put,
  Id Function(T item) idOf,
) {
  // O primeiro ID possível (os IDs podem ser negativos: são hashes).
  var after = Isar.autoIncrement;
  while (true) {
    final count = isar.writeTxnSync(() {
      final items = page(after);
      if (items.isEmpty) return 0;
      put(items);
      after = idOf(items.last);
      return items.length;
    }, silent: true);
    if (count < _pageSize) return;
  }
}
