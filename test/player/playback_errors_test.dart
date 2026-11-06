import 'package:flutter_test/flutter_test.dart';
import 'package:iptv_app/features/player/playback_session.dart';

void main() {
  test('seek recusado num direto não é erro de reprodução', () {
    // O que o mpv escreve quando o media_kit (Android) faz seek ao mudar a
    // superfície do vídeo num stream em direto.
    expect(isHarmlessPlayerError('Cannot seek in this stream.'), isTrue);
    expect(
      isHarmlessPlayerError("You can force it with '--force-seekable=yes'."),
      isTrue,
    );
  });

  test('falhas a sério continuam a ser erros', () {
    expect(
      isHarmlessPlayerError('tcp: Failed to resolve hostname iptv.pt'),
      isFalse,
    );
    expect(isHarmlessPlayerError('Failed to open http://x/1.ts.'), isFalse);
    expect(isHarmlessPlayerError('Could not open codec.'), isFalse);
  });
}
