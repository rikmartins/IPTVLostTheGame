import 'xtream_credentials.dart';

/// URLs de reprodução do Xtream, consumidos pelo media_kit.
///
/// Separado do `XtreamApi` porque só precisa das credenciais, não de um
/// cliente HTTP.
class XtreamStreamUrls {
  const XtreamStreamUrls(this.credentials);

  final XtreamCredentials credentials;

  String live(int streamId, {String extension = 'ts'}) =>
      '$_base/live/$_user/$_pass/$streamId.$extension';

  String movie(int streamId, String containerExtension) =>
      '$_base/movie/$_user/$_pass/$streamId.$containerExtension';

  String episode(String episodeId, String containerExtension) =>
      '$_base/series/$_user/$_pass/$episodeId.$containerExtension';

  String get _base => credentials.serverUrl;

  String get _user => Uri.encodeComponent(credentials.username);

  String get _pass => Uri.encodeComponent(credentials.password);
}
