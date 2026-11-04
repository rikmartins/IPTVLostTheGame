import 'package:flutter_test/flutter_test.dart';
import 'package:iptv_app/data/local/models/app_settings.dart';
import 'package:iptv_app/features/player/buffer_profiles.dart';

void main() {
  test('Rápido arranca sem esperar pelo buffer', () {
    final props = BufferProfile.fast.mpvProperties(live: true);
    expect(props['cache-pause-initial'], 'no');
    expect(props['cache-secs'], '2');
  });

  test('Normal pré-carrega 3 s e mantém 5 s', () {
    final props = BufferProfile.normal.mpvProperties(live: true);
    expect(props['cache-pause-initial'], 'yes');
    expect(props['cache-pause-wait'], '3');
    expect(props['cache-secs'], '5');
  });

  test('Estável pré-carrega 10 s e mantém 15 s', () {
    final props = BufferProfile.stable.mpvProperties(live: true);
    expect(props['cache-pause-initial'], 'yes');
    expect(props['cache-pause-wait'], '10');
    expect(props['cache-secs'], '15');
    expect(int.parse(props['demuxer-max-bytes']!), greaterThan(100 << 20));
  });

  test('em direto a cache para trás é pequena', () {
    final live = BufferProfile.normal.mpvProperties(live: true);
    final vod = BufferProfile.normal.mpvProperties(live: false);
    expect(
      int.parse(live['demuxer-max-back-bytes']!),
      lessThan(int.parse(vod['demuxer-max-back-bytes']!)),
    );
  });

  test('todos os perfis ligam a reconexão automática', () {
    for (final profile in BufferProfile.values) {
      expect(
        profile.mpvProperties(live: true)['stream-lavf-o'],
        contains('reconnect=1'),
      );
    }
  });
}
