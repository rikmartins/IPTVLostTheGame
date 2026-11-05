import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/sources/source_client.dart';
import 'playback_session.dart';
import 'widgets/live_osd.dart';

/// Player em ecrã inteiro.
///
/// * Direto: recebe a lista de canais do grupo atual para zapping
///   (cima/baixo, CH+/CH-, deslizar na vertical) e mostra um OSD.
/// * VOD: um único item, com os controlos do media_kit (seek, pausa...).
///
/// Um único player por ecrã: no zapping troca-se só o `Media`, sem recriar
/// o libmpv nem a textura de vídeo. No direto pode vir já a tocar da
/// pré-visualização ([session]); nesse caso continua e não é fechado aqui.
class PlayerScreen extends ConsumerStatefulWidget {
  const PlayerScreen.live({
    super.key,
    required List<int> this.channelIds,
    required this.initialIndex,
    this.session,
  }) : vodTitle = null,
       vodRequest = null,
       vodStart = null;

  /// [start]: retomar a partir daqui (ver `playVod`).
  const PlayerScreen.vod({
    super.key,
    required String title,
    required PlaybackRequest request,
    Duration? start,
  }) : channelIds = null,
       initialIndex = 0,
       vodTitle = title,
       vodRequest = request,
       vodStart = start,
       session = null;

  final List<int>? channelIds;
  final int initialIndex;
  final String? vodTitle;
  final PlaybackRequest? vodRequest;
  final Duration? vodStart;

  /// Sessão de quem abriu o ecrã (a pré-visualização da TV em direto).
  final PlaybackSession? session;

  bool get isLive => channelIds != null;

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  /// Espera depois da última tecla de zapping antes de abrir o stream. Com
  /// `max_connections = 1` (o normal no Xtream), abrir um stream por tecla
  /// esgota a ligação no painel e o canal final recusa.
  static const _zapDebounce = Duration(milliseconds: 400);
  static const _osdTimeout = Duration(seconds: 4);

  late final PlaybackSession _session;
  late final bool _ownsSession;
  StreamSubscription<bool>? _bufferingSubscription;

  late int _index = widget.initialIndex;
  bool _osdVisible = true;
  late bool _buffering;
  String? _error;
  Timer? _osdTimer;
  Timer? _zapTimer;

  @override
  void initState() {
    super.initState();
    _ownsSession = widget.session == null;
    _session =
        widget.session ??
        ref.read(playbackSessionFactoryProvider)(live: widget.isLive);

    // Continua o stream da pré-visualização, ou abre um novo (e aí o
    // erro antigo já não conta).
    final continues = widget.isLive && _isPlaying(widget.channelIds![_index]);
    _buffering = continues ? _session.buffering : true;
    _bufferingSubscription = _session.bufferingStream.listen((value) {
      if (mounted) setState(() => _buffering = value);
    });
    _session.error.addListener(_onError);

    _open(initial: true);
    _scheduleOsdHide();
  }

  @override
  void dispose() {
    _osdTimer?.cancel();
    _zapTimer?.cancel();
    _bufferingSubscription?.cancel();
    _session.error.removeListener(_onError);
    if (_ownsSession) _session.dispose();
    super.dispose();
  }

  void _onError() {
    if (mounted) setState(() => _error = _session.error.value);
  }

  /// A pré-visualização já está a tocar este canal (sem erro).
  bool _isPlaying(int channelId) =>
      _session.liveChannel.value == channelId && _session.error.value == null;

  /// [initial]: chamado do `initState`, onde o estado já foi preparado.
  Future<void> _open({bool initial = false}) async {
    if (!widget.isLive) {
      final request = widget.vodRequest!;
      await _session.open(
        request.url,
        start: widget.vodStart,
        reporter: request.reporter,
      );
      return;
    }

    final channelId = widget.channelIds![_index];
    // Continua sem reabrir (nem pedir outra ligação ao servidor).
    if (_isPlaying(channelId)) return;
    if (!mounted) return;
    if (!initial) setState(() => _buffering = true);
    await openLiveChannel(
      ref,
      _session,
      channelId,
      // Pode ter havido zapping enquanto o servidor abria o canal.
      stillWanted: () => mounted && widget.channelIds![_index] == channelId,
    );
  }

  void _zap(int delta) {
    final ids = widget.channelIds;
    if (ids == null || ids.length < 2) return;
    setState(() => _index = (_index + delta) % ids.length);
    _showOsd();
    _zapTimer?.cancel();
    _zapTimer = Timer(_zapDebounce, _open);
  }

  void _showOsd() {
    setState(() => _osdVisible = true);
    _scheduleOsdHide();
  }

  void _toggleOsd() {
    if (_osdVisible) {
      _osdTimer?.cancel();
      setState(() => _osdVisible = false);
    } else {
      _showOsd();
    }
  }

  void _scheduleOsdHide() {
    _osdTimer?.cancel();
    _osdTimer = Timer(_osdTimeout, () {
      if (mounted) setState(() => _osdVisible = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    void close() => Navigator.of(context).maybePop();

    final bindings = <ShortcutActivator, VoidCallback>{
      const SingleActivator(LogicalKeyboardKey.escape): close,
      if (widget.isLive) ...{
        // Como num comando de TV: cima / CH+ avança para o canal seguinte.
        const SingleActivator(LogicalKeyboardKey.arrowUp): () => _zap(1),
        const SingleActivator(LogicalKeyboardKey.channelUp): () => _zap(1),
        const SingleActivator(LogicalKeyboardKey.pageUp): () => _zap(1),
        const SingleActivator(LogicalKeyboardKey.arrowDown): () => _zap(-1),
        const SingleActivator(LogicalKeyboardKey.channelDown): () => _zap(-1),
        const SingleActivator(LogicalKeyboardKey.pageDown): () => _zap(-1),
        const SingleActivator(LogicalKeyboardKey.select): _toggleOsd,
        const SingleActivator(LogicalKeyboardKey.enter): _toggleOsd,
      },
    };

    return CallbackShortcuts(
      bindings: bindings,
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: Colors.black,
          body: widget.isLive ? _buildLive(close) : _buildVod(close),
        ),
      ),
    );
  }

  Widget _buildLive(VoidCallback close) {
    final ids = widget.channelIds!;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _toggleOsd,
      onVerticalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;
        if (velocity.abs() < 300) return;
        _zap(velocity < 0 ? 1 : -1);
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          _session.video(),
          if (_buffering && _error == null)
            const Center(child: CircularProgressIndicator()),
          if (_error != null) _ErrorMessage(message: _error!),
          AnimatedOpacity(
            opacity: _osdVisible ? 1 : 0,
            duration: const Duration(milliseconds: 200),
            child: IgnorePointer(
              ignoring: !_osdVisible,
              child: LiveOsd(
                channelId: ids[_index],
                position: _index + 1,
                total: ids.length,
                onClose: close,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVod(VoidCallback close) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _session.video(controls: true),
        if (_error != null) _ErrorMessage(message: _error!),
        SafeArea(
          child: Align(
            alignment: Alignment.topLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                BackButton(color: Colors.white, onPressed: close),
                Text(
                  widget.vodTitle!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    shadows: [Shadow(blurRadius: 6)],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'Não foi possível reproduzir.\n$message',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70),
        ),
      ),
    );
  }
}
