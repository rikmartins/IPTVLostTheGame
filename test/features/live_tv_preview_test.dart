import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iptv_app/app/profiles_controller.dart';
import 'package:iptv_app/app/sync_controller.dart';
import 'package:iptv_app/data/local/models/epg_programme.dart';
import 'package:iptv_app/data/local/models/live_channel.dart';
import 'package:iptv_app/data/profiles/profile.dart';
import 'package:iptv_app/features/catalog/category_providers.dart';
import 'package:iptv_app/features/epg/epg_providers.dart';
import 'package:iptv_app/features/live_tv/live_tv_providers.dart';
import 'package:iptv_app/features/live_tv/live_tv_screen.dart';
import 'package:iptv_app/features/player/playback_session.dart';
import 'package:iptv_app/features/player/player_screen.dart';

// Sem libmpv nem Isar no `flutter test`: o player e o catálogo são falsos.

class _FakeSession implements PlaybackSession {
  final opened = <String>[];
  var stops = 0;
  var disposed = false;
  final _live = ValueNotifier<int?>(null);
  final _error = ValueNotifier<String?>(null);

  @override
  ValueListenable<int?> get liveChannel => _live;

  @override
  ValueListenable<String?> get error => _error;

  @override
  bool get buffering => false;

  @override
  Stream<bool> get bufferingStream => const Stream.empty();

  @override
  Future<void> open(String url, {int? liveChannelId}) async {
    opened.add(url);
    _live.value = liveChannelId;
  }

  @override
  Future<void> stop() async {
    stops++;
    _live.value = null;
  }

  @override
  Widget video({bool controls = false}) =>
      const ColoredBox(key: Key('video'), color: Colors.black);

  @override
  void dispose() => disposed = true;
}

class _IdleSync extends SyncController {
  @override
  SyncActivity build() => const SyncActivity();
}

final _now = DateTime(2026, 11, 4, 21, 30);

EpgProgramme _programme(String title, int startHour, int startMinute) {
  final start = DateTime(2026, 11, 4, startHour, startMinute);
  return EpgProgramme()
    ..channelKey = 0
    ..start = start
    ..stop = start.add(const Duration(hours: 1))
    ..title = title
    ..description = 'Descrição de $title';
}

Future<_FakeSession> _pump(WidgetTester tester, Size size) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final session = _FakeSession();
  final current = _programme('Telejornal', 21, 0);
  final next = _programme('Futebol', 22, 0);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        initialProfilesProvider.overrideWithValue(const ProfilesState()),
        syncControllerProvider.overrideWith(_IdleSync.new),
        categoriesProvider.overrideWith((ref, type) => const []),
        hiddenCategoriesProvider.overrideWithBuild((ref, notifier) => {}),
        liveChannelIdsProvider.overrideWith((ref, category) => [1, 2, 3]),
        liveChannelProvider.overrideWith(
          (ref, id) => LiveChannel()
            ..id = id
            ..number = id
            ..name = 'Canal $id'
            ..epgChannelId = 'canal$id',
        ),
        clockProvider.overrideWith((ref) => Stream.value(_now)),
        nowNextProvider.overrideWith((ref, epg) => NowNext(current, next)),
        channelScheduleProvider.overrideWith((ref, epg) => [current, next]),
        liveStreamUrlProvider.overrideWith(
          (ref, id) => 'http://iptv.test/live/u/p/$id.ts',
        ),
        playbackSessionFactoryProvider.overrideWithValue(
          ({required bool live}) => session,
        ),
      ],
      child: const MaterialApp(home: Scaffold(body: LiveTvScreen())),
    ),
  );
  await tester.pump();
  return session;
}

void main() {
  testWidgets('primeiro toque pré-visualiza com o guia, o segundo abre o '
      'ecrã inteiro com o mesmo stream', (tester) async {
    final session = await _pump(tester, const Size(1600, 900));
    expect(find.text('Escolhe um canal para o pré-visualizar'), findsOneWidget);

    await tester.tap(find.text('Canal 2'));
    await tester.pump(LiveTvScreen.previewDebounce);

    expect(session.opened, ['http://iptv.test/live/u/p/2.ts']);
    expect(find.byKey(const Key('video')), findsOneWidget);
    expect(find.text('2   Canal 2'), findsOneWidget);
    expect(find.text('AGORA  21:00–22:00'), findsOneWidget);
    expect(find.text('Telejornal'), findsOneWidget);
    expect(find.text('Descrição de Telejornal'), findsOneWidget);
    expect(find.text('Futebol'), findsOneWidget);
    expect(find.byType(PlayerScreen), findsNothing);

    await tester.tap(find.text('Canal 2'));
    await tester.pumpAndSettle();

    expect(find.byType(PlayerScreen), findsOneWidget);
    expect(
      session.opened,
      hasLength(1),
      reason: 'continua o stream da pré-visualização, sem nova ligação',
    );

    // Zapping no ecrã inteiro: ao voltar, a lista fica no canal novo.
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pump(const Duration(milliseconds: 450));
    expect(session.opened.last, 'http://iptv.test/live/u/p/3.ts');

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(PlayerScreen), findsNothing);
    expect(session.disposed, isFalse, reason: 'a sessão é da lista');
    expect(find.text('3   Canal 3'), findsOneWidget);

    // "Voltar" fecha a pré-visualização e larga o stream.
    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(session.stops, 1);
    expect(find.text('Escolhe um canal para o pré-visualizar'), findsOneWidget);
  });

  testWidgets('no telemóvel a pré-visualização aparece por cima da lista', (
    tester,
  ) async {
    final session = await _pump(tester, const Size(400, 800));
    expect(find.byKey(const Key('video')), findsNothing);

    await tester.tap(find.text('Canal 1'));
    await tester.pump(LiveTvScreen.previewDebounce);

    expect(session.opened, ['http://iptv.test/live/u/p/1.ts']);
    expect(find.byKey(const Key('video')), findsOneWidget);
    expect(find.text('21:00–22:00  Telejornal'), findsOneWidget);
    expect(find.text('A seguir  22:00  Futebol'), findsOneWidget);

    await tester.tap(find.byTooltip('Fechar pré-visualização'));
    await tester.pump();
    expect(session.stops, 1);
    expect(find.byKey(const Key('video')), findsNothing);
  });

  testWidgets('tocar em vários canais seguidos só abre o último', (
    tester,
  ) async {
    final session = await _pump(tester, const Size(1600, 900));

    await tester.tap(find.text('Canal 1'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('Canal 3'));
    await tester.pump(LiveTvScreen.previewDebounce);

    expect(session.opened, ['http://iptv.test/live/u/p/3.ts']);
  });
}
