import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iptv_app/app/profiles_controller.dart';
import 'package:iptv_app/app/session_controller.dart';
import 'package:iptv_app/app/settings_controller.dart';
import 'package:iptv_app/app/sync_controller.dart';
import 'package:iptv_app/data/local/models/app_settings.dart';
import 'package:iptv_app/data/local/models/epg_programme.dart';
import 'package:iptv_app/data/local/models/live_channel.dart';
import 'package:iptv_app/data/profiles/profile.dart';
import 'package:iptv_app/data/sources/series_episode.dart';
import 'package:iptv_app/data/sources/source_client.dart';
import 'package:iptv_app/features/catalog/category_providers.dart';
import 'package:iptv_app/features/epg/epg_providers.dart';
import 'package:iptv_app/features/epg/guide_screen.dart';
import 'package:iptv_app/features/live_tv/favorites.dart';
import 'package:iptv_app/features/live_tv/live_tv_providers.dart';
import 'package:iptv_app/features/player/playback_session.dart';
import 'package:iptv_app/features/player/player_screen.dart';

// Sem libmpv nem Isar no `flutter test`: o player e o catálogo são falsos.

class _FakeSession implements PlaybackSession {
  final opened = <String>[];
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
  Future<void> open(
    String url, {
    int? liveChannelId,
    Duration? start,
    PlaybackReporter? reporter,
  }) async {
    opened.add(url);
    _live.value = liveChannelId;
  }

  @override
  Future<void> fail(String message, {int? liveChannelId}) async {}

  @override
  Future<void> stop() async {}

  @override
  Widget video({bool controls = false}) =>
      const ColoredBox(key: Key('video'), color: Colors.black);

  @override
  void dispose() {}
}

class _FakeSource implements SourceClient {
  @override
  Future<PlaybackRequest?> live(int channelId) async =>
      PlaybackRequest('http://iptv.test/live/$channelId.ts');

  @override
  Future<PlaybackRequest?> catchup(
    int channelId,
    EpgProgramme programme,
  ) async => PlaybackRequest(
    'http://iptv.test/timeshift/$channelId/${programme.title}.ts',
  );

  @override
  Future<PlaybackRequest?> movie(int movieId) async => null;

  @override
  Future<List<SeriesEpisode>> episodes(int seriesId) async => const [];

  @override
  Future<PlaybackRequest?> episode(SeriesEpisode episode) async => null;

  @override
  bool get tracksProgress => false;

  @override
  void close() {}
}

class _IdleSync extends SyncController {
  @override
  SyncActivity build() => const SyncActivity();
}

class _MemorySettings extends SettingsController {
  @override
  AppSettings build() => AppSettings();
}

final _now = DateTime(2026, 11, 6, 21, 30);

EpgProgramme _programme(String title, int hour, {int length = 60}) {
  final start = DateTime(2026, 11, 6, hour);
  return EpgProgramme()
    ..channelKey = 0
    ..start = start
    ..stop = start.add(Duration(minutes: length))
    ..title = title
    ..description = 'Sobre $title';
}

Future<_FakeSession> _pump(WidgetTester tester, Size size) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final session = _FakeSession();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        initialProfilesProvider.overrideWithValue(const ProfilesState()),
        syncControllerProvider.overrideWith(_IdleSync.new),
        settingsProvider.overrideWith(_MemorySettings.new),
        categoriesProvider.overrideWith((ref, type) => const []),
        hiddenCategoriesProvider.overrideWithBuild((ref, notifier) => {}),
        favoriteChannelsProvider.overrideWithBuild((ref, notifier) => {}),
        liveChannelIdsProvider.overrideWith((ref, category) => [1, 2]),
        liveChannelProvider.overrideWith(
          (ref, id) => LiveChannel()
            ..id = id
            ..number = id
            ..name = 'Canal $id'
            ..epgChannelId = 'canal$id'
            // Só o 1 tem gravações.
            ..hasCatchup = id == 1
            ..catchupDays = 2,
        ),
        clockProvider.overrideWith((ref) => Stream.value(_now)),
        // Informação do canal no player em direto.
        nowNextProvider.overrideWith((ref, epg) => const NowNext(null, null)),
        daySchedule.overrideWith(
          (ref, key) => key.$2 == DateTime(2026, 11, 6)
              ? [
                  _programme('Notícias ${key.$1}', 20),
                  _programme('Jogo ${key.$1}', 21),
                  _programme('Filme ${key.$1}', 22),
                ]
              : const [],
        ),
        sourceClientProvider.overrideWithValue(_FakeSource()),
        playbackSessionFactoryProvider.overrideWithValue(
          ({required bool live}) => session,
        ),
      ],
      child: const MaterialApp(home: Scaffold(body: GuideScreen())),
    ),
  );
  await tester.pump();
  await tester.pump();
  return session;
}

/// A grelha abre na hora real (não na do relógio falso): traz a célula
/// para o meio, fora da coluna dos canais.
Future<void> _reveal(WidgetTester tester, Finder finder) async {
  Scrollable.ensureVisible(tester.element(finder), alignment: 0.5);
  await tester.pumpAndSettle();
}

Future<void> _tapProgramme(WidgetTester tester, String title) async {
  final finder = find.text(title);
  await _reveal(tester, finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('programa a dar: ver em direto ou do início (com catch-up)', (
    tester,
  ) async {
    final session = await _pump(tester, const Size(1600, 900));
    expect(find.text('Hoje'), findsOneWidget);
    expect(find.text('1  Canal 1'), findsOneWidget);

    await _tapProgramme(tester, 'Jogo canal1');
    expect(find.text('Sobre Jogo canal1'), findsOneWidget);
    expect(find.text('Ver em direto'), findsOneWidget);
    expect(find.text('Ver do início'), findsOneWidget);

    await tester.tap(find.text('Ver do início'));
    await tester.pumpAndSettle();
    expect(find.byType(PlayerScreen), findsOneWidget);
    expect(session.opened, ['http://iptv.test/timeshift/1/Jogo canal1.ts']);
  });

  testWidgets('programa que já passou: gravação só nos canais com catch-up', (
    tester,
  ) async {
    final session = await _pump(tester, const Size(1600, 900));

    await _tapProgramme(tester, 'Notícias canal2');
    expect(
      find.text('Este canal não tem gravações (catch-up).'),
      findsOneWidget,
    );
    expect(find.text('Ver gravação'), findsNothing);
    await tester.tap(find.text('Fechar'));
    await tester.pumpAndSettle();

    await _tapProgramme(tester, 'Jogo canal2');
    await tester.tap(find.text('Ver em direto'));
    // O player em direto mostra a roda de carregamento: não assenta.
    await tester.pump();
    await tester.pump();
    expect(find.byType(PlayerScreen), findsOneWidget);
    expect(session.opened, ['http://iptv.test/live/2.ts']);
  });

  testWidgets('no telemóvel cabe sem transbordar e muda de dia', (
    tester,
  ) async {
    await _pump(tester, const Size(400, 800));
    expect(find.text('Jogo canal1'), findsOneWidget);

    await tester.tap(find.text('Amanhã'));
    await tester.pumpAndSettle();
    expect(find.text('Jogo canal1'), findsNothing);
    expect(find.text('Sem guia'), findsNWidgets(2));
  });
}
