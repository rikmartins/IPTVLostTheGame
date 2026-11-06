import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../app/session_controller.dart';
import '../../app/settings_controller.dart';
import '../../data/remote/xtream/xtream_api.dart';
import '../../data/sources/source_client.dart';
import '../../data/sources/source_exception.dart';
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

  /// [start]: posição onde começar (retomar um filme). [reporter] é
  /// avisado do progresso e de quando o stream deixa de tocar.
  Future<void> open(
    String url, {
    int? liveChannelId,
    Duration? start,
    PlaybackReporter? reporter,
  });

  /// O stream não chegou a abrir (ex.: o servidor recusou o canal):
  /// mostra [message] como se fosse um erro do player.
  Future<void> fail(String message, {int? liveChannelId});

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

/// Abre um canal na [session]. No Jellyfin o servidor abre primeiro o canal
/// (ocupa um sintonizador) e pode recusá-lo: o erro aparece no player.
///
/// [stillWanted] diz se o canal ainda é o escolhido quando o servidor
/// responder; se não for, o que o servidor abriu é libertado logo.
Future<void> openLiveChannel(
  WidgetRef ref,
  PlaybackSession session,
  int channelId, {
  required bool Function() stillWanted,
}) async {
  final client = ref.read(sourceClientProvider);
  if (client == null) return;

  final PlaybackRequest? request;
  try {
    request = await client.live(channelId);
  } on SourceException catch (e) {
    if (stillWanted()) await session.fail(e.message, liveChannelId: channelId);
    return;
  } catch (_) {
    if (stillWanted()) {
      await session.fail(
        'Não foi possível abrir o canal',
        liveChannelId: channelId,
      );
    }
    return;
  }
  if (request == null) return;
  if (!stillWanted()) {
    request.discard();
    return;
  }
  await session.open(
    request.url,
    liveChannelId: channelId,
    reporter: request.reporter,
  );
}

/// Mensagens de erro do mpv que não querem dizer que o stream falhou.
///
/// "Cannot seek in this stream" / "--force-seekable": alguém pediu um seek
/// num direto, que não se pode recuar (no Android acontece quando a
/// superfície do vídeo muda, ex.: da pré-visualização para o ecrã
/// inteiro). O vídeo continua a tocar.
bool isHarmlessPlayerError(String message) {
  final text = message.toLowerCase();
  return text.contains('cannot seek') || text.contains('force-seekable');
}

class MpvPlaybackSession implements PlaybackSession {
  MpvPlaybackSession(Map<String, String> mpvProperties) {
    // Antes do primeiro open, para a saída de vídeo já estar ligada.
    _controller = VideoController(_player);
    _configured = _applyProperties(mpvProperties);
    _errors = _player.stream.error.listen(_onPlayerError);
    _positions = _player.stream.position.listen(_onPosition);
  }

  /// Vídeo que avançou isto depois de um erro recuperou sozinho.
  static const _recoveredAfter = Duration(seconds: 2);

  final _player = Player();
  late final VideoController _controller;
  late final Future<void> _configured;
  late final StreamSubscription<String> _errors;
  late final StreamSubscription<Duration> _positions;
  final _liveChannel = ValueNotifier<int?>(null);
  final _error = ValueNotifier<String?>(null);

  /// Posição quando o mpv se queixou; null se o erro atual não veio do
  /// mpv (ex.: [fail]) ou não há erro.
  Duration? _errorPosition;

  /// O media_kit passa como erro todas as mensagens de nível "error" do
  /// mpv, também as de coisas que não impedem o vídeo de tocar.
  void _onPlayerError(String message) {
    if (isHarmlessPlayerError(message)) return;
    // O mpv mete o URL nas mensagens: sem a query string (o token do
    // Jellyfin).
    _error.value = scrubSecrets(message);
    _errorPosition = _player.state.position;
  }

  /// O mpv também se queixa do que resolve sozinho (ex.: uma ligação que
  /// caiu e voltou): se o vídeo continua a avançar, não há erro a mostrar.
  void _onPosition(Duration position) {
    final since = _errorPosition;
    if (since == null || position - since < _recoveredAfter) return;
    _errorPosition = null;
    _error.value = null;
  }

  void _clearError() {
    _errorPosition = null;
    _error.value = null;
  }

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
  Future<void> open(
    String url, {
    int? liveChannelId,
    Duration? start,
    PlaybackReporter? reporter,
  }) async {
    await _configured;
    // Antes de abrir o novo: a posição lida ainda é a do stream anterior.
    _endReport();
    _clearError();
    _liveChannel.value = liveChannelId;
    _startReport(reporter, start ?? Duration.zero);
    await _player.open(
      Media(
        url,
        // Os painéis que filtram o User-Agent na API costumam filtrá-lo
        // também nos streams.
        httpHeaders: const {'User-Agent': XtreamApi.defaultUserAgent},
        start: start,
      ),
    );
  }

  @override
  Future<void> fail(String message, {int? liveChannelId}) async {
    _endReport();
    _liveChannel.value = liveChannelId;
    _errorPosition = null;
    _error.value = message;
    await _player.stop();
  }

  @override
  Future<void> stop() async {
    _endReport();
    _liveChannel.value = null;
    _clearError();
    await _player.stop();
  }

  // --- Progresso para o servidor (Jellyfin) --------------------------------

  /// O servidor só precisa de saber o progresso de tempos a tempos; o
  /// "visto" e o "continuar" decidem-se no fim, com a posição final.
  static const _reportInterval = Duration(seconds: 10);

  PlaybackReporter? _reporter;
  Timer? _reportTimer;

  void _startReport(PlaybackReporter? reporter, Duration start) {
    if (reporter == null) return;
    _reporter = reporter;
    reporter.started(start);
    _reportTimer = Timer.periodic(_reportInterval, (_) {
      reporter.progress(_player.state.position, paused: !_player.state.playing);
    });
  }

  void _endReport() {
    _reportTimer?.cancel();
    _reportTimer = null;
    final reporter = _reporter;
    _reporter = null;
    // Visto até ao fim: o servidor marca-o como visto.
    final state = _player.state;
    reporter?.stopped(
      state.completed && state.duration > Duration.zero
          ? state.duration
          : state.position,
    );
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
    _endReport();
    _errors.cancel();
    _positions.cancel();
    _player.dispose();
    _liveChannel.dispose();
    _error.dispose();
  }
}
