import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/sync_controller.dart';
import '../../app/widgets/section_scaffold.dart';
import '../../data/local/models/media_category.dart';
import '../catalog/category_providers.dart';
import '../catalog/widgets/category_list.dart';
import '../player/playback_session.dart';
import '../player/player_screen.dart';
import 'live_tv_providers.dart';
import 'widgets/channel_preview.dart';
import 'widgets/channel_tile.dart';

/// TV em direto: grupos, lista de canais e pré-visualização.
///
/// O primeiro toque (ou OK no comando) num canal pré-visualiza-o com o
/// guia; o segundo no mesmo canal abre o ecrã inteiro, que continua o
/// stream da pré-visualização em vez de abrir outro.
class LiveTvScreen extends ConsumerStatefulWidget {
  const LiveTvScreen({super.key});

  /// Abaixo disto (largura da zona dos canais) a pré-visualização passa
  /// para cima da lista.
  static const sidePreviewBreakpoint = 600.0;

  /// Espera antes de abrir o stream: passar por vários canais seguidos não
  /// abre uma ligação por cada um (o Xtream costuma aceitar só uma).
  static const previewDebounce = Duration(milliseconds: 350);

  @override
  ConsumerState<LiveTvScreen> createState() => _LiveTvScreenState();
}

class _LiveTvScreenState extends ConsumerState<LiveTvScreen> {
  PlaybackSession? _session;
  int? _selected;
  Timer? _openTimer;
  bool _visible = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // As secções ficam vivas num IndexedStack: ao ir para Filmes ou
    // Definições, a pré-visualização não pode continuar a tocar.
    final visible = Visibility.of(context);
    if (visible == _visible) return;
    _visible = visible;
    if (!visible) _closePreview();
  }

  @override
  void dispose() {
    _openTimer?.cancel();
    _session?.dispose();
    super.dispose();
  }

  PlaybackSession _ensureSession() =>
      _session ??= ref.read(playbackSessionFactoryProvider)(live: true);

  void _onChannelTap(List<int> ids, int index) {
    final id = ids[index];
    if (id == _selected) {
      _openFullScreen(ids, index);
      return;
    }
    setState(() {
      _selected = id;
      _ensureSession();
    });
    _openTimer?.cancel();
    _openTimer = Timer(LiveTvScreen.previewDebounce, () => _play(id));
  }

  Future<void> _play(int id) async {
    if (!mounted || _selected != id) return;
    final session = _ensureSession();
    if (session.liveChannel.value == id && session.error.value == null) return;
    final url = ref.read(liveStreamUrlProvider(id));
    if (url == null) return;
    await session.open(url, liveChannelId: id);
  }

  Future<void> _openFullScreen(List<int> ids, int index) async {
    _openTimer?.cancel();
    final session = _ensureSession();
    setState(() => _selected = ids[index]);
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PlayerScreen.live(
          channelIds: ids,
          initialIndex: index,
          session: session,
        ),
      ),
    );
    if (!mounted) return;
    // No ecrã inteiro pode ter mudado de canal: a lista e a
    // pré-visualização ficam no canal que estava a ver.
    setState(() => _selected = session.liveChannel.value ?? _selected);
  }

  /// Para o stream (e liberta a ligação ao servidor).
  void _closePreview() {
    _openTimer?.cancel();
    _selected = null;
    _session?.stop();
  }

  void _openSelected() {
    final id = _selected;
    if (id == null) return;
    final categoryId = ref.read(selectedCategoryProvider(CategoryType.live));
    final ids = ref.read(liveChannelIdsProvider(categoryId));
    final index = ids.indexOf(id);
    // O canal pode ser de outro grupo (mudou-se de grupo depois de o
    // escolher): o zapping fica só nesse canal.
    _openFullScreen(index < 0 ? [id] : ids, index < 0 ? 0 : index);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Com um canal em pré-visualização, "voltar" fecha-a primeiro.
      canPop: _selected == null,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(_closePreview);
      },
      child: SectionScaffold(
        title: 'TV em direto',
        child: CatalogLayout(
          type: CategoryType.live,
          allLabel: 'Todos os canais',
          child: LayoutBuilder(
            builder: (context, constraints) {
              final list = _ChannelList(
                selected: _selected,
                onTap: _onChannelTap,
              );

              if (constraints.maxWidth >= LiveTvScreen.sidePreviewBreakpoint) {
                final previewWidth = (constraints.maxWidth * 0.5).clamp(
                  300.0,
                  560.0,
                );
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: list),
                    const VerticalDivider(),
                    SizedBox(
                      width: previewWidth,
                      child: ChannelPreview(
                        channelId: _selected,
                        session: _session,
                        onOpen: _openSelected,
                        onClose: () => setState(_closePreview),
                      ),
                    ),
                  ],
                );
              }

              return Column(
                children: [
                  ChannelPreview(
                    channelId: _selected,
                    session: _session,
                    onOpen: _openSelected,
                    onClose: () => setState(_closePreview),
                    compact: true,
                    // A lista tem de continuar visível por baixo.
                    maxVideoHeight: constraints.maxHeight * 0.38,
                  ),
                  Expanded(child: list),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ChannelList extends ConsumerWidget {
  const _ChannelList({required this.selected, required this.onTap});

  final int? selected;
  final void Function(List<int> ids, int index) onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryId = ref.watch(selectedCategoryProvider(CategoryType.live));
    final ids = ref.watch(liveChannelIdsProvider(categoryId));

    if (ids.isEmpty) {
      final syncing = ref.watch(syncControllerProvider).isRunning;
      return EmptyCatalog(
        icon: Icons.live_tv_outlined,
        message: syncing
            ? 'A descarregar a lista de canais…'
            : 'Sem canais neste grupo',
      );
    }

    return ListView.builder(
      // Guarda a posição de scroll de cada grupo ao alternar entre eles.
      key: PageStorageKey<String>('live-$categoryId'),
      itemExtent: ChannelTile.height,
      itemCount: ids.length,
      itemBuilder: (context, index) {
        final id = ids[index];
        return ChannelTile(
          key: ValueKey(id),
          id: id,
          selected: id == selected,
          // O grupo inteiro vai para o player: é a lista do zapping.
          onTap: () => onTap(ids, index),
        );
      },
    );
  }
}
