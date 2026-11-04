import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../app/providers.dart';
import '../../app/session_controller.dart';
import '../../app/settings_controller.dart';
import '../../data/local/models/account_info.dart';
import '../../data/remote/xtream/xtream_api.dart';
import 'buffer_profiles.dart';

/// Um player (libmpv + textura de vídeo) e o estado que a UI lê dele.
///
/// Na TV em direto a pré-visualização e o ecrã inteiro partilham a mesma
/// sessão: abrir o ecrã inteiro continua o stream que já está a tocar, sem
/// segunda ligação ao servidor (no Xtream o normal é `max_connections = 1`,
/// e um segundo stream era recusado).
abstract class PlaybackSession {
  /// Canal de direto aberto (a tocar ou a carregar); null em VOD ou parado.
  ValueListenable<int?> get liveChannel;

  /// Erro do stream atual; volta a null a cada [open].
  ValueListenable<String?> get error;

  bool get buffering;
  Stream<bool> get bufferingStream;

  Future<void> open(String url, {int? liveChannelId});

  /// Fecha o stream (e a ligação ao servidor), mas o player continua
  /// pronto para o próximo [open].
  Future<void> stop();

  /// O vídeo, para pôr na árvore. Pode estar em mais de um sítio ao mesmo
  /// tempo (a textura é a mesma).
  Widget video({bool controls = false});

  void dispose();
}

typedef PlaybackSessionFactory = PlaybackSession Function({required bool live});

/// Sobreposto nos testes (o libmpv não existe no `flutter test`).
final playbackSessionFactoryProvider = Provider<PlaybackSessionFactory>((ref) {
  return ({required bool live}) {
    final profile = ref.read(settingsProvider).bufferProfile;
    return MpvPlaybackSession(profile.mpvProperties(live: live));
  };
});

/// URL do stream de um canal, na extensão que a conta prefere.
final liveStreamUrlProvider = Provider.autoDispose.family<String?, int>((
  ref,
  channelId,
) {
  final urls = ref.watch(streamUrlsProvider);
  if (urls == null) return null;
  final account = ref.watch(isarProvider).accounts.getSync(0);
  return urls.live(
    channelId,
    extension: account?.preferredLiveExtension ?? 'ts',
  );
});

class MpvPlaybackSession implements PlaybackSession {
  MpvPlaybackSession(Map<String, String> mpvProperties) {
    // Antes do primeiro open, para a saída de vídeo já estar ligada.
    _controller = VideoController(_player);
    _configured = _applyProperties(mpvProperties);
    _errors = _player.stream.error.listen((message) => _error.value = message);
  }

  final _player = Player();
  late final VideoController _controller;
  late final Future<void> _configured;
  late final StreamSubscription<String> _errors;
  final _liveChannel = ValueNotifier<int?>(null);
  final _error = ValueNotifier<String?>(null);

  @override
  ValueListenable<int?> get liveChannel => _liveChannel;

  @override
  ValueListenable<String?> get error => _error;

  @override
  bool get buffering => _player.state.buffering;

  @override
  Stream<bool> get bufferingStream => _player.stream.buffering;

  /// Tem de correr antes do primeiro `open`: o mpv lê as opções de cache
  /// quando abre o stream.
  Future<void> _applyProperties(Map<String, String> properties) async {
    final native = _player.platform;
    if (native is! NativePlayer) return;
    for (final MapEntry(:key, :value) in properties.entries) {
      await native.setProperty(key, value);
    }

    // O media_kit ignora o código de erro do mpv: um nome de propriedade
    // errado falhava em silêncio. Em debug, confirma-se cada valor.
    if (kDebugMode) {
      for (final MapEntry(:key, :value) in properties.entries) {
        final actual = await native.getProperty(key);
        if (actual != value) {
          debugPrint('mpv: $key="$actual" (pedido "$value")');
        }
      }
    }
  }

  @override
  Future<void> open(String url, {int? liveChannelId}) async {
    await _configured;
    _error.value = null;
    _liveChannel.value = liveChannelId;
    await _player.open(
      Media(
        url,
        // Os painéis que filtram o User-Agent na API costumam filtrá-lo
        // também nos streams.
        httpHeaders: const {'User-Agent': XtreamApi.defaultUserAgent},
      ),
    );
  }

  @override
  Future<void> stop() async {
    _liveChannel.value = null;
    _error.value = null;
    await _player.stop();
  }

  @override
  Widget video({bool controls = false}) => controls
      // Controlos adaptativos do media_kit (seek, pausa, ecrã inteiro).
      ? Video(controller: _controller)
      // null = sem controlos (o `NoVideoControls` do media_kit é um
      // `const ... = null` sem tipo, que o strict-casts rejeita).
      : Video(controller: _controller, controls: null);

  @override
  void dispose() {
    _errors.cancel();
    _player.dispose();
    _liveChannel.dispose();
    _error.dispose();
  }
}
