import 'package:flutter/services.dart' show appFlavor;

/// Build da variante Android TV (`--flavor tv`). Nas outras plataformas, e
/// num `flutter run` sem flavor, é falso.
bool get isAndroidTvBuild => appFlavor == 'tv';

/// Repositório GitHub ("dono/repo") onde são publicadas as releases da app.
///
/// Tem de ser público: a app consulta a API sem token. Pode ser sobreposto
/// no build sem mexer no código:
/// `flutter build apk --dart-define=GITHUB_REPO=dono/repo`.
const githubRepository = String.fromEnvironment(
  'GITHUB_REPO',
  defaultValue: 'rikmartins/SoPro-Media',
);
