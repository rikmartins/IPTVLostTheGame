import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import '../utils/fast_hash.dart';

/// Pasta da cache de imagens, definida em `main()` (o `path_provider` é
/// assíncrono e as imagens são pedidas em síncrono). null = sem cache em
/// disco (testes).
String? imageCacheDirectory;

/// Imagem da rede guardada em disco.
///
/// O `NetworkImage` do Flutter só guarda em memória: a cada arranque os
/// logos e posters eram todos descarregados outra vez dos servidores dos
/// fornecedores, que costumam ser lentos, e apareciam atrasados.
@immutable
class CachedNetworkImage extends ImageProvider<CachedNetworkImage> {
  const CachedNetworkImage(this.url);

  final String url;

  static final _http = HttpClient()
    ..connectionTimeout = const Duration(seconds: 10)
    ..maxConnectionsPerHost = 6;

  /// Endereços que já falharam nesta sessão: um logo partido não é pedido
  /// outra vez a cada scroll.
  static final _failed = <String>{};

  @override
  Future<CachedNetworkImage> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture(this);

  @override
  ImageStreamCompleter loadImage(
    CachedNetworkImage key,
    ImageDecoderCallback decode,
  ) {
    return MultiFrameImageStreamCompleter(
      codec: _load(decode),
      scale: 1,
      debugLabel: url,
    );
  }

  Future<ui.Codec> _load(ImageDecoderCallback decode) async {
    final bytes = await _bytes();
    return decode(await ui.ImmutableBuffer.fromUint8List(bytes));
  }

  Future<Uint8List> _bytes() async {
    final directory = imageCacheDirectory;
    final file = directory == null ? null : File('$directory/${fileName(url)}');
    if (file != null) {
      try {
        final bytes = await file.readAsBytes();
        if (bytes.isNotEmpty) return bytes;
      } on FileSystemException {
        // Ainda não está em cache.
      }
    }

    if (_failed.contains(url)) throw StateError('Imagem indisponível: $url');
    final Uint8List bytes;
    try {
      bytes = await _download();
    } catch (_) {
      _failed.add(url);
      rethrow;
    }
    if (file != null) unawaited(_store(file, bytes));
    return bytes;
  }

  Future<Uint8List> _download() async {
    final request = await _http.getUrl(Uri.parse(url));
    final response = await request.close();
    if (response.statusCode != HttpStatus.ok) {
      await response.drain<void>();
      throw HttpException('HTTP ${response.statusCode}', uri: Uri.parse(url));
    }
    final bytes = await consolidateHttpClientResponseBytes(response);
    if (bytes.isEmpty) throw HttpException('Vazia', uri: Uri.parse(url));
    return bytes;
  }

  /// Escreve num ficheiro temporário e muda o nome: uma imagem a meio
  /// (a app fechou) nunca fica na cache.
  static Future<void> _store(File file, Uint8List bytes) async {
    try {
      final temp = File('${file.path}.tmp');
      await temp.writeAsBytes(bytes, flush: true);
      await temp.rename(file.path);
    } on FileSystemException {
      // Sem espaço ou pasta apagada: fica só em memória.
    }
  }

  @visibleForTesting
  static String fileName(String url) =>
      '${fastHash(url).toRadixString(16).replaceFirst('-', 'n')}'
      '_${url.length}';

  @override
  bool operator ==(Object other) =>
      other is CachedNetworkImage && other.url == url;

  @override
  int get hashCode => url.hashCode;

  @override
  String toString() => 'CachedNetworkImage("$url")';
}

/// Mantém a cache abaixo de [maxBytes], apagando primeiro as imagens
/// descarregadas há mais tempo. Corre num isolate, sem atrasar o arranque.
Future<void> pruneImageCache(
  String directory, {
  int maxBytes = 300 * 1024 * 1024,
}) {
  return Isolate.run(() {
    final files = <(File, FileStat)>[];
    try {
      for (final entity in Directory(directory).listSync()) {
        if (entity is File) files.add((entity, entity.statSync()));
      }
    } on FileSystemException {
      return;
    }
    var total = files.fold<int>(0, (sum, f) => sum + f.$2.size);
    if (total <= maxBytes) return;
    files.sort((a, b) => a.$2.modified.compareTo(b.$2.modified));
    for (final (file, stat) in files) {
      if (total <= maxBytes * 0.8) break;
      try {
        file.deleteSync();
        total -= stat.size;
      } on FileSystemException {
        // Em uso: fica para a próxima.
      }
    }
  }, debugName: 'image-cache-prune');
}
