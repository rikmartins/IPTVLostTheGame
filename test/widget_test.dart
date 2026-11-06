import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iptv_app/app/app.dart';
import 'package:iptv_app/app/profiles_controller.dart';
import 'package:iptv_app/app/providers.dart';
import 'package:iptv_app/app/settings_controller.dart';
import 'package:iptv_app/app/widgets/brand.dart';
import 'package:iptv_app/data/local/models/account_info.dart';
import 'package:iptv_app/data/local/models/app_settings.dart';
import 'package:iptv_app/data/profiles/profile.dart';
import 'package:iptv_app/data/remote/jellyfin/jellyfin_client.dart';
import 'package:iptv_app/data/repositories/auth_repository.dart';
import 'package:iptv_app/data/sources/credentials.dart';

// Sem cofre do sistema nem Isar: nenhum dos dois existe no `flutter test`.

class _FakeAuth implements AuthRepository {
  _FakeAuth([this.saved]);

  final RememberedLogin? saved;

  @override
  Future<RememberedLogin?> remembered() async => saved;

  @override
  Future<void> setRemembered(RememberedLogin? login) async {}

  @override
  Future<AccountInfo> authenticate(XtreamCredentials credentials) =>
      throw UnimplementedError();

  @override
  Future<JellyfinLogin> authenticateJellyfin({
    required String server,
    required String username,
    required String password,
    required String deviceId,
  }) => throw UnimplementedError();
}

class _MemorySettings extends SettingsController {
  _MemorySettings(this.initial);

  final AppSettings initial;

  @override
  AppSettings build() => initial;
}

Future<void> _pumpApp(
  WidgetTester tester, {
  AppSettings? settings,
  RememberedLogin? remembered,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(_FakeAuth(remembered)),
        // Sem perfis: ecrã de login.
        initialProfilesProvider.overrideWithValue(const ProfilesState()),
        settingsProvider.overrideWith(
          () => _MemorySettings(settings ?? AppSettings()),
        ),
      ],
      child: const IptvApp(),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('sem sessão guardada mostra o login com o logo', (tester) async {
    await _pumpApp(tester);

    expect(find.byType(BrandLogo), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Entrar'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Servidor'), findsOneWidget);
  });

  testWidgets('login com campos vazios não chama o servidor', (tester) async {
    await _pumpApp(tester);

    final enter = find.widgetWithText(FilledButton, 'Entrar');
    await tester.ensureVisible(enter);
    await tester.tap(enter);
    await tester.pump();

    expect(find.text('Preenche todos os campos'), findsOneWidget);
  });

  testWidgets('dados memorizados preenchem o login', (tester) async {
    await _pumpApp(
      tester,
      remembered: const RememberedLogin(
        kind: SourceKind.xtream,
        server: 'http://exemplo.pt:8080',
        username: 'ana',
        password: 'segredo',
      ),
    );
    await tester.pump();

    expect(find.text('http://exemplo.pt:8080'), findsOneWidget);
    expect(find.text('ana'), findsOneWidget);
    final remember = tester.widget<CheckboxListTile>(
      find.widgetWithText(CheckboxListTile, 'Memorizar dados'),
    );
    expect(remember.value, isTrue);
  });

  testWidgets('dados memorizados de um Jellyfin escolhem o Jellyfin', (
    tester,
  ) async {
    await _pumpApp(
      tester,
      remembered: const RememberedLogin(
        kind: SourceKind.jellyfin,
        server: 'http://nas.casa:8096',
        username: 'rui',
        password: '',
      ),
    );
    await tester.pump();

    final kinds = tester.widget<SegmentedButton<SourceKind>>(
      find.byType(SegmentedButton<SourceKind>),
    );
    expect(kinds.selected, {SourceKind.jellyfin});
    expect(find.text('http://nas.casa:8096'), findsOneWidget);
    expect(find.text('Palavra-passe (se tiver)'), findsOneWidget);
  });

  testWidgets('no Jellyfin a palavra-passe pode ficar vazia', (tester) async {
    await _pumpApp(tester);

    await tester.tap(find.text('Jellyfin'));
    await tester.pump();
    expect(find.textContaining('servidor Jellyfin'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextField, 'Servidor'), 'nas');
    await tester.enterText(find.widgetWithText(TextField, 'Utilizador'), 'rui');
    final enter = find.widgetWithText(FilledButton, 'Entrar');
    await tester.ensureVisible(enter);
    await tester.tap(enter);
    await tester.pump();

    // Passou da validação e chegou ao servidor (aqui, um falso que falha).
    expect(find.text('Preenche todos os campos'), findsNothing);
    expect(find.text('Erro inesperado ao iniciar sessão'), findsOneWidget);
  });

  testWidgets('tema escuro por omissão nas instalações novas', (tester) async {
    await _pumpApp(tester);

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
    expect(
      Theme.of(tester.element(find.byType(Scaffold))).brightness,
      Brightness.dark,
    );
  });

  testWidgets('tema claro quando escolhido nas definições', (tester) async {
    await _pumpApp(
      tester,
      settings: AppSettings()..theme = ThemePreference.light,
    );

    expect(
      Theme.of(tester.element(find.byType(Scaffold))).brightness,
      Brightness.light,
    );
  });

  testWidgets('tema escuro quando escolhido nas definições', (tester) async {
    await _pumpApp(
      tester,
      settings: AppSettings()..theme = ThemePreference.dark,
    );

    expect(
      Theme.of(tester.element(find.byType(Scaffold))).brightness,
      Brightness.dark,
    );
  });
}
