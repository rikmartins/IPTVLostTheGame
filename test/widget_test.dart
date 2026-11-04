import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iptv_app/app/app.dart';
import 'package:iptv_app/app/session_controller.dart';
import 'package:iptv_app/data/remote/xtream/xtream_credentials.dart';

/// Sem sessão guardada e sem tocar no cofre do sistema nem no Isar (nenhum
/// dos dois existe no `flutter test`).
class _NoSession extends SessionController {
  @override
  Future<XtreamCredentials?> build() async => null;
}

void main() {
  testWidgets('sem sessão guardada mostra o login', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sessionProvider.overrideWith(_NoSession.new)],
        child: const IptvApp(),
      ),
    );
    await tester.pump();

    expect(find.widgetWithText(FilledButton, 'Entrar'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Servidor'), findsOneWidget);
  });

  testWidgets('login com campos vazios não chama o servidor', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sessionProvider.overrideWith(_NoSession.new)],
        child: const IptvApp(),
      ),
    );
    await tester.pump();

    await tester.tap(find.widgetWithText(FilledButton, 'Entrar'));
    await tester.pump();

    expect(find.text('Preenche todos os campos'), findsOneWidget);
  });
}
