import 'package:flutter/services.dart' show MethodChannel, appFlavor;

/// Build da variante Android TV da versão completa (`--flavor tv`): é a
/// variante que o atualizador descarrega. Para saber se a app está numa TV
/// usa-se [isAndroidTv].
bool get isAndroidTvBuild => appFlavor == 'tv';

/// Versão da Play Store (`--flavor play`): sem VPN nem atualizador próprio,
/// que as regras da loja não permitem. As atualizações vêm da loja.
bool get isPlayStoreBuild => appFlavor == 'play';

/// A app está numa TV (comando em vez de ecrã tátil). Na versão completa é
/// a variante `tv`; na da Play Store, que é um só pacote para telemóveis e
/// TVs, é o que [detectAndroidTv] perguntou ao Android no arranque.
bool get isAndroidTv => isAndroidTvBuild || _playStoreOnTv;
bool _playStoreOnTv = false;

/// Chamado antes do `runApp`, para o primeiro ecrã já sair certo.
Future<void> detectAndroidTv() async {
  if (!isPlayStoreBuild) return;
  try {
    _playStoreOnTv =
        await const MethodChannel('sopro/device')
            .invokeMethod<bool>('isTelevision') ??
        false;
  } catch (_) {
    // Sem resposta: interface de telemóvel, que também funciona na TV.
  }
}

/// Repositório GitHub ("dono/repo") onde são publicadas as releases da app.
///
/// Tem de ser público: a app consulta a API sem token. Pode ser sobreposto
/// no build sem mexer no código:
/// `flutter build apk --dart-define=GITHUB_REPO=dono/repo`.
const githubRepository = String.fromEnvironment(
  'GITHUB_REPO',
  defaultValue: 'rikmartins/SoPro-Media',
);
