import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:iptv_app/data/sources/source_exception.dart';
import 'package:iptv_app/features/catalog/category_providers.dart';
import 'package:iptv_app/features/epg/epg_providers.dart';
import 'package:iptv_app/features/live_tv/favorites.dart';
import 'package:iptv_app/features/live_tv/live_tv_providers.dart';
import 'package:iptv_app/features/live_tv/live_tv_screen.dart';
import 'package:iptv_app/features/player/playback_session.dart';
import 'package:iptv_app/features/player/player_screen.dart';

// Sem libmpv nem Isar no `flutter test`: o player e o catálogo são falsos.

class _FakeSession implements PlaybackSession {
  final opened = <String>[];
  final failures = <String>[];
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
  Future<void> open(
    String url, {
    int? liveChannelId,
    Duration? start,
    PlaybackReporter? reporter,
  }) async {
    opened.add(url);
    _error.value = null;
    _live.value = liveChannelId;
  }

  @override
  Future<void> fail(String message, {int? liveChannelId}) async {
    failures.add(message);
    _live.value = liveChannelId;
    _error.value = message;
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

/// Canais como no Xtream; os [refused] são recusados pelo servidor (ex.:
/// Jellyfin sem sintonizadores livres).
class _FakeSource implements SourceClient {
  _FakeSource(this.refused);

  final Set<int> refused;

  @override
  Future<PlaybackRequest?> live(int channelId) async {
    if (refused.contains(channelId)) {
      throw const SourceException(
        SourceErrorKind.server,
        'sem sintonizadores livres',
      );
    }
    return PlaybackRequest('http://iptv.test/live/u/p/$channelId.ts');
  }

  @override
  Future<PlaybackRequest?> movie(int movieId) async => null;

  @override
  Future<List<SeriesEpisode>> episodes(int seriesId) async => const [];

  @override
  Future<PlaybackRequest?> episode(SeriesEpisode episode) async => null;

  @override
  Future<PlaybackRequest?> catchup(
    int channelId,
    EpgProgramme programme,
  ) async => null;

  @override
  bool get tracksProgress => false;

  @override
  void close() {}
}

class _MemorySettings extends SettingsController {
  @override
  AppSettings build() => AppSettings();
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

Future<_FakeSession> _pump(
  WidgetTester tester,
  Size size, {
  Set<int> refused = const {},
}) async {
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
        favoriteChannelsProvider.overrideWithBuild((ref, notifier) => {}),
        settingsProvider.overrideWith(_MemorySettings.new),
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
        sourceClientProvider.overrideWithValue(_FakeSource(refused)),
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

  testWidgets('um toque abre logo; toques seguidos esperam pelo último', (
    tester,
  ) async {
    final session = await _pump(tester, const Size(1600, 900));

    await tester.tap(find.text('Canal 1'));
    await tester.pump();
    expect(session.opened, ['http://iptv.test/live/u/p/1.ts']);

    await tester.tap(find.text('Canal 2'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('Canal 3'));
    await tester.pump(LiveTvScreen.previewDebounce);

    expect(session.opened, [
      'http://iptv.test/live/u/p/1.ts',
      'http://iptv.test/live/u/p/3.ts',
    ]);
  });

  testWidgets('canal recusado pelo servidor mostra o motivo', (tester) async {
    final session = await _pump(tester, const Size(1600, 900), refused: {2});

    await tester.tap(find.text('Canal 2'));
    await tester.pump(LiveTvScreen.previewDebounce);
    await tester.pump();

    expect(session.opened, isEmpty);
    expect(session.failures, hasLength(1));
    expect(find.textContaining('sem sintonizadores livres'), findsOneWidget);

    // Outro canal abre normalmente.
    await tester.tap(find.text('Canal 1'));
    await tester.pump(LiveTvScreen.previewDebounce);
    await tester.pump();
    expect(session.opened, ['http://iptv.test/live/u/p/1.ts']);
    expect(find.textContaining('sem sintonizadores livres'), findsNothing);
  });
}
