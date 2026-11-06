import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:iptv_app/core/images/cached_network_image.dart';
import 'package:iptv_app/core/utils/search_text.dart';
import 'package:iptv_app/core/utils/time_format.dart';
import 'package:iptv_app/data/remote/xtream/xtream_mappers.dart';
import 'package:iptv_app/data/remote/xtream/xtream_stream_urls.dart';
import 'package:iptv_app/data/sources/credentials.dart';

void main() {
  test('pesquisa: sem acentos nem maiúsculas, palavra a palavra', () {
    expect(foldForSearch('Família ÇÃO Ñ'), 'familia cao n');
    expect(foldForSearch('PT: Sport TV 1'), 'pt: sport tv 1');
    expect(searchTermsOf('  Família   ADDAMS '), ['familia', 'addams']);
    expect(searchTermsOf('   '), isEmpty);
  });

  group('catch-up do Xtream', () {
    test('URL com a hora local do servidor e a duração em minutos', () {
      const urls = XtreamStreamUrls(
        XtreamCredentials(
          serverUrl: 'http://iptv.pt:8080',
          username: 'ana',
          password: 'p',
        ),
      );
      expect(
        urls.timeshift(42, DateTime.utc(2026, 11, 6, 9, 5), 60),
        'http://iptv.pt:8080/timeshift/ana/p/60/2026-11-06:09-05/42.ts',
      );
    });

    test('diferença do servidor para UTC a partir do server_info', () {
      final utc = DateTime.utc(2026, 11, 6, 11, 1, 22);
      final stamp = utc.millisecondsSinceEpoch ~/ 1000;
      expect(
        serverUtcOffsetMinutes({
          'time_now': '2026-11-06 12:01:22',
          'timestamp_now': stamp,
        }),
        60,
      );
      // Uns segundos de atraso na resposta não estragam a conta.
      expect(
        serverUtcOffsetMinutes({
          'time_now': '2026-11-06 11:01:30',
          'timestamp_now': '$stamp',
        }),
        0,
      );
      expect(serverUtcOffsetMinutes({'timezone': 'Europe/Lisbon'}), isNull);
      expect(serverUtcOffsetMinutes(null), isNull);
    });
  });

  test('posição num vídeo', () {
    expect(formatPosition(const Duration(minutes: 42, seconds: 10)), '42:10');
    expect(
      formatPosition(const Duration(hours: 1, minutes: 2, seconds: 3)),
      '1:02:03',
    );
  });

  group('cache de imagens', () {
    test('um ficheiro por URL', () {
      final a = CachedNetworkImage.fileName('http://x/logo1.png');
      final b = CachedNetworkImage.fileName('http://x/logo2.png');
      expect(a, isNot(b));
      expect(a, CachedNetworkImage.fileName('http://x/logo1.png'));
      expect(a, isNot(contains('-')));
    });

    test('acima do limite apaga primeiro as mais antigas', () async {
      final dir = await Directory.systemTemp.createTemp('image_cache_test');
      addTearDown(() => dir.delete(recursive: true));
      final base = DateTime(2026);
      for (var i = 0; i < 10; i++) {
        File('${dir.path}/img$i')
          ..writeAsBytesSync(List.filled(1000, 0))
          ..setLastModifiedSync(base.add(Duration(days: i)));
      }

      await pruneImageCache(dir.path, maxBytes: 5000);

      final left = dir.listSync().map((f) => f.uri.pathSegments.last).toSet();
      expect(left, {'img6', 'img7', 'img8', 'img9'});

      // Abaixo do limite não mexe em nada.
      await pruneImageCache(dir.path, maxBytes: 5000);
      expect(dir.listSync(), hasLength(4));
    });
  });
}
