import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../app/providers.dart';
import '../../app/session_controller.dart';
import '../../app/settings_controller.dart';
import '../../data/local/models/account_info.dart';
import '../../data/remote/xtream/xtream_api.dart';
import 'buffer_profiles.dart';
import 'widgets/live_osd.dart';

/// Player em ecrã inteiro.
///
/// * Direto: recebe a lista de canais do grupo atual para zapping
///   (cima/baixo, CH+/CH-, deslizar na vertical) e mostra um OSD.
/// * VOD: um único item, com os controlos do media_kit (seek, pausa...).
///
/// Um único [Player] por ecrã: no zapping troca-se só o `Media`, sem
/// recriar o libmpv nem a textura de vídeo.
class PlayerScreen extends ConsumerStatefulWidget {
  const PlayerScreen.live({
    super.key,
    required List<int> this.channelIds,
    required this.initialIndex,
  }) : vodTitle = null,
       vodUrl = null;

  const PlayerScreen.vod({
    super.key,
    required String title,
    required String url,
  }) : channelIds = null,
       initialIndex = 0,
       vodTitle = title,
       vodUrl = url;

  final List<int>? channelIds;
  final int initialIndex;
  final String? vodTitle;
  final String? vodUrl;

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

  final _player = Player();
  late final VideoController _controller;
  late final Future<void> _configured;
  final _subscriptions = <StreamSubscription<Object?>>[];

  late int _index = widget.initialIndex;
  bool _osdVisible = true;
  bool _buffering = true;
  String? _error;
  Timer? _osdTimer;
  Timer? _zapTimer;

  @override
  void initState() {
    super.initState();
    // Antes do primeiro open, para a saída de vídeo já estar ligada.
    _controller = VideoController(_player);
    final profile = ref.read(settingsProvider).bufferProfile;
    _configured = _applyProfile(profile.mpvProperties(live: widget.isLive));

    _subscriptions
      ..add(
        _player.stream.buffering.listen((value) {
          if (mounted) setState(() => _buffering = value);
        }),
      )
      ..add(
        _player.stream.error.listen((message) {
          if (mounted) setState(() => _error = message);
        }),
      );

    _open();
    _scheduleOsdHide();
  }

  @override
  void dispose() {
    _osdTimer?.cancel();
    _zapTimer?.cancel();
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _player.dispose();
    super.dispose();
  }

  /// Tem de correr antes do primeiro `open`: o mpv lê as opções de cache
  /// quando abre o stream.
  Future<void> _applyProfile(Map<String, String> properties) async {
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
        if (actual != value) debugPrint('mpv: $key="$actual" (pedido "$value")');
      }
    }
  }

  Future<void> _open() async {
    await _configured;
    final url = widget.isLive
        ? _liveUrl(widget.channelIds![_index])
        : widget.vodUrl;
    if (url == null || !mounted) return;

    setState(() {
      _error = null;
      _buffering = true;
    });
    await _player.open(
      Media(
        url,
        // Os painéis que filtram o User-Agent na API costumam filtrá-lo
        // também nos streams.
        httpHeaders: const {'User-Agent': XtreamApi.defaultUserAgent},
      ),
    );
  }

  String? _liveUrl(int channelId) {
    final urls = ref.read(streamUrlsProvider);
    if (urls == null) return null;
    final account = ref.read(isarProvider).accounts.getSync(0);
    return urls.live(
      channelId,
      extension: account?.preferredLiveExtension ?? 'ts',
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
          // null = sem controlos (o `NoVideoControls` do media_kit é um
          // `const ... = null` sem tipo, que o strict-casts rejeita).
          Video(controller: _controller, controls: null),
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
        // Controlos adaptativos do media_kit (seek, pausa, ecrã inteiro).
        Video(controller: _controller),
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
