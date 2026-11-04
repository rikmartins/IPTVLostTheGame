import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:iptv_app/core/utils/json_object_splitter.dart';
import 'package:iptv_app/data/local/models/media_category.dart';
import 'package:iptv_app/data/remote/xtream/xmltv_parser.dart';
import 'package:iptv_app/data/remote/xtream/xtream_credentials.dart';
import 'package:iptv_app/data/remote/xtream/xtream_mappers.dart';

/// Simula a rede a entregar o corpo aos bocados de [size] bytes.
Stream<List<int>> _chunked(String text, int size) async* {
  final bytes = utf8.encode(text);
  for (var i = 0; i < bytes.length; i += size) {
    yield bytes.sublist(i, i + size > bytes.length ? bytes.length : i + size);
  }
}

Future<List<Map<String, dynamic>>> _split(String json, int chunkSize) {
  return splitJsonObjects(_chunked(json, chunkSize))
      .map((bytes) => jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>)
      .toList();
}

void main() {
  group('splitJsonObjects', () {
    // Chavetas e aspas dentro de strings, objetos aninhados, UTF-8
    // multibyte e valores soltos no topo que devem ser ignorados.
    const json =
        '[{"name":"A {x} [y]","n":1},{"name":"B \\"}\\" ç","n":2},'
        '{"nested":{"a":[1,{"b":2}]}}, 3, "str"]';

    for (final size in [1, 3, 7, 4096]) {
      test('chunks de $size bytes', () async {
        final items = await _split(json, size);
        expect(items, hasLength(3));
        expect(items[0]['name'], 'A {x} [y]');
        expect(items[1]['name'], 'B "}" ç');
        expect(items[2]['nested'], {
          'a': [
            1,
            {'b': 2},
          ],
        });
      });
    }

    test('objeto indexado em vez de array', () async {
      final items = await _split('{"1":{"a":1},"2":{"a":2}}', 5);
      expect(items.map((e) => e['a']), [1, 2]);
    });
  });

  group('parseXmltvDate', () {
    test('offset positivo', () {
      expect(
        parseXmltvDate('20240101120000 +0100'),
        DateTime.utc(2024, 1, 1, 11),
      );
    });

    test('offset negativo com dois pontos', () {
      expect(
        parseXmltvDate('20240101120000 -03:30'),
        DateTime.utc(2024, 1, 1, 15, 30),
      );
    });

    test('sem segundos nem offset assume UTC', () {
      expect(parseXmltvDate('202401011200'), DateTime.utc(2024, 1, 1, 12));
    });

    test('inválida', () {
      expect(parseXmltvDate(null), isNull);
      expect(parseXmltvDate('ontem'), isNull);
    });
  });

  test('parseXmltv', () async {
    const xml =
        '<?xml version="1.0" encoding="UTF-8"?><tv>'
        '<channel id="RTP1.pt"><display-name>RTP 1</display-name></channel>'
        '<programme start="20240101120000 +0000" stop="20240101130000 +0000" '
        'channel="RTP1.pt"><title lang="pt">Telejornal &amp; Mais</title>'
        '<title lang="en">News</title>'
        '<desc><![CDATA[Descrição <b>longa</b>]]></desc></programme>'
        // Fim antes do início: descartado.
        '<programme start="20240101130000 +0000" stop="20240101120000 +0000" '
        'channel="x"><title>Inválido</title></programme>'
        '</tv>';

    final programmes = await parseXmltv(_chunked(xml, 16)).toList();

    expect(programmes, hasLength(1));
    final p = programmes.single;
    expect(p.channelId, 'rtp1.pt');
    expect(p.title, 'Telejornal & Mais');
    expect(p.description, 'Descrição <b>longa</b>');
    expect(p.start, DateTime.utc(2024, 1, 1, 12));
  });

  group('mappers', () {
    test('canal com tipos inconsistentes', () {
      final channel = mapLiveChannel(
        {
          'stream_id': '42',
          'num': 7,
          'name': ' RTP 1 ',
          'category_id': 5,
          'epg_channel_id': 'RTP1.pt',
          'tv_archive': '1',
          'tv_archive_duration': '3',
          'stream_icon': '',
        },
        sortIndex: 0,
        syncStamp: 1,
      )!;

      expect(channel.id, 42);
      expect(channel.number, 7);
      expect(channel.name, 'RTP 1');
      expect(channel.categoryId, 5);
      expect(channel.epgChannelId, 'rtp1.pt');
      expect(channel.hasCatchup, isTrue);
      expect(channel.catchupDays, 3);
      expect(channel.icon, isNull);
    });

    test('sem stream_id é descartado', () {
      expect(
        mapLiveChannel({'name': 'x'}, sortIndex: 0, syncStamp: 1),
        isNull,
      );
    });

    test('category_ids quando category_id vem a null', () {
      final channel = mapLiveChannel(
        {
          'stream_id': 1,
          'category_id': null,
          'category_ids': [9],
        },
        sortIndex: 0,
        syncStamp: 1,
      )!;
      expect(channel.categoryId, 9);
    });

    test('mesmo category_id em tipos diferentes não colide', () {
      final live = mapCategory(
        {'category_id': '1', 'category_name': 'Desporto'},
        CategoryType.live,
        sortIndex: 0,
        syncStamp: 1,
      )!;
      final movie = mapCategory(
        {'category_id': '1', 'category_name': 'Ação'},
        CategoryType.movie,
        sortIndex: 0,
        syncStamp: 1,
      )!;
      expect(live.categoryId, movie.categoryId);
      expect(live.id, isNot(movie.id));
    });
  });

  test('normalizeServerUrl', () {
    expect(
      XtreamCredentials.normalizeServerUrl(' host.tv:8080/ '),
      'http://host.tv:8080',
    );
    expect(
      XtreamCredentials.normalizeServerUrl(
        'https://host.tv/player_api.php?username=a&password=b',
      ),
      'https://host.tv',
    );
    expect(
      XtreamCredentials.normalizeServerUrl('http://host.tv:8080/xc/'),
      'http://host.tv:8080/xc',
    );
  });
}
