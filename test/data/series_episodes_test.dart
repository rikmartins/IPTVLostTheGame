import 'package:flutter_test/flutter_test.dart';
import 'package:iptv_app/data/remote/xtream/xtream_mappers.dart';

void main() {
  group('mapSeriesEpisodes', () {
    test('mapa por temporada (formato habitual), ordenado', () {
      final episodes = mapSeriesEpisodes({
        'episodes': {
          '2': [
            {'id': '201', 'episode_num': 1, 'season': 2, 'title': 'S2E1'},
          ],
          '1': [
            {
              'id': '102',
              'episode_num': '2',
              'season': '1',
              'container_extension': 'mkv',
              'info': {'duration': '00:45:00', 'plot': 'Enredo'},
            },
            {'id': 101, 'episode_num': 1, 'season': 1, 'title': 'Piloto'},
          ],
        },
      });

      expect(episodes.map((e) => e.id), ['101', '102', '201']);
      expect(episodes[0].title, 'Piloto');
      expect(episodes[1].containerExtension, 'mkv');
      expect(episodes[1].duration, '00:45:00');
      // Sem título: gera um.
      expect(episodes[1].title, 'Episódio 2');
      // Sem extensão: mp4.
      expect(episodes[0].containerExtension, 'mp4');
    });

    test('lista de listas e `info` vazio como []', () {
      final episodes = mapSeriesEpisodes({
        'episodes': [
          [
            {'id': '1', 'episode_num': 1, 'season': 1, 'info': <Object?>[]},
          ],
          [
            {'id': '2', 'episode_num': 1, 'season': 2},
          ],
        ],
      });

      expect(episodes.map((e) => e.season), [1, 2]);
      expect(episodes.first.plot, isNull);
    });

    test('sem episódios ou sem id', () {
      expect(mapSeriesEpisodes({}), isEmpty);
      expect(
        mapSeriesEpisodes({
          'episodes': {
            '1': [
              {'title': 'sem id'},
            ],
          },
        }),
        isEmpty,
      );
    });
  });
}
