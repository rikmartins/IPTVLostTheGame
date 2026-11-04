import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iptv_app/app/app.dart';
import 'package:iptv_app/app/providers.dart';
import 'package:iptv_app/app/session_controller.dart';
import 'package:iptv_app/app/settings_controller.dart';
import 'package:iptv_app/app/widgets/brand.dart';
import 'package:iptv_app/data/local/models/account_info.dart';
import 'package:iptv_app/data/local/models/app_settings.dart';
import 'package:iptv_app/data/remote/xtream/xtream_credentials.dart';
import 'package:iptv_app/data/repositories/auth_repository.dart';

// Sem cofre do sistema nem Isar: nenhum dos dois existe no `flutter test`.

class _NoSession extends SessionController {
  @override
  Future<XtreamCredentials?> build() async => null;
}

class _FakeAuth implements AuthRepository {
  _FakeAuth([this.saved]);

  final XtreamCredentials? saved;

  @override
  Future<XtreamCredentials?> remembered() async => saved;

  @override
  Future<XtreamCredentials?> restore() async => null;

  @override
  Future<void> forgetRemembered() async {}

  @override
  Future<void> logout() async {}

  @override
  Future<({XtreamCredentials credentials, AccountInfo account})> login({
    required String server,
    required String username,
    required String password,
    bool remember = true,
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
  XtreamCredentials? remembered,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(_FakeAuth(remembered)),
        sessionProvider.overrideWith(_NoSession.new),
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

    await tester.tap(find.widgetWithText(FilledButton, 'Entrar'));
    await tester.pump();

    expect(find.text('Preenche todos os campos'), findsOneWidget);
  });

  testWidgets('dados memorizados preenchem o login', (tester) async {
    await _pumpApp(
      tester,
      remembered: const XtreamCredentials(
        serverUrl: 'http://exemplo.pt:8080',
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

  testWidgets('tema claro por omissão', (tester) async {
    await _pumpApp(tester);

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.light);
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
