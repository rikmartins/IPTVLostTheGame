import 'package:flutter_test/flutter_test.dart';
import 'package:iptv_app/data/update/app_version.dart';
import 'package:iptv_app/data/update/github_release.dart';

ReleaseAsset _asset(String name) =>
    ReleaseAsset(name: name, downloadUrl: 'https://x/$name', size: 1);

void main() {
  group('AppVersion', () {
    AppVersion v(String s) => AppVersion.tryParse(s)!;

    test('aceita os formatos habituais de tag', () {
      expect(v('v1.2.3'), const AppVersion(1, 2, 3));
      expect(v('1.2'), const AppVersion(1, 2, 0));
      expect(v('release-2.0.1-beta.1').toString(), '2.0.1');
      expect(v('0.1.0+7').build, 7);
      expect(AppVersion.tryParse('latest'), isNull);
    });

    test('compara maior, menor e patch como números', () {
      expect(v('v0.10.0').isNewerThan(v('0.9.9')), isTrue);
      expect(v('v1.0.0').isNewerThan(v('0.99.99')), isTrue);
      expect(v('v0.1.1').isNewerThan(v('0.1.0+40')), isTrue);
      expect(v('v0.1.0').isNewerThan(v('0.1.1')), isFalse);
    });

    test('tag sem build não é "mais recente" que a mesma versão instalada', () {
      expect(v('v0.1.0').isNewerThan(v('0.1.0+5')), isFalse);
      expect(v('v0.1.0+6').isNewerThan(v('0.1.0+5')), isTrue);
    });
  });

  group('pickAsset', () {
    final splitApks = [
      _asset('iptv-0.2.0-armeabi-v7a.apk'),
      _asset('iptv-0.2.0-arm64-v8a.apk'),
      _asset('iptv-0.2.0-x86_64.apk'),
      _asset('iptv-0.2.0-windows-setup.exe'),
      _asset('iptv-0.2.0.dmg'),
      _asset('SHA256SUMS.txt'),
    ];

    test('Android: o APK da ABI do dispositivo', () {
      expect(
        pickAsset(splitApks, UpdatePlatform.android, androidAbi: 'arm64-v8a')
            ?.name,
        'iptv-0.2.0-arm64-v8a.apk',
      );
      // Boxes Android TV baratas costumam correr em 32 bits.
      expect(
        pickAsset(splitApks, UpdatePlatform.android, androidAbi: 'armeabi-v7a')
            ?.name,
        'iptv-0.2.0-armeabi-v7a.apk',
      );
    });

    test('Android: "x86" não apanha o APK x86_64', () {
      final assets = [_asset('app-x86_64.apk'), _asset('app-universal.apk')];
      expect(
        pickAsset(assets, UpdatePlatform.android, androidAbi: 'x86')?.name,
        'app-universal.apk',
      );
    });

    test('Android: reconhece nomes alternativos de ABI', () {
      // Convenção do LocalSend, encontrada num repositório real.
      final assets = [
        _asset('LocalSend-1.18.2-android-arm32v7.apk'),
        _asset('LocalSend-1.18.2-android-arm64v8.apk'),
      ];
      expect(
        pickAsset(assets, UpdatePlatform.android, androidAbi: 'arm64-v8a')
            ?.name,
        'LocalSend-1.18.2-android-arm64v8.apk',
      );
    });

    test('Android: nunca oferece o APK de outra arquitetura', () {
      final assets = [_asset('app-armeabi-v7a.apk')];
      expect(
        pickAsset(assets, UpdatePlatform.android, androidAbi: 'arm64-v8a'),
        isNull,
      );
      // ABI desconhecida: fica com o que houver.
      expect(pickAsset(assets, UpdatePlatform.android), isNotNull);
    });

    test('Android: sem APK da ABI usa o universal', () {
      final assets = [_asset('app-arm64-v8a.apk'), _asset('app-release.apk')];
      expect(
        pickAsset(assets, UpdatePlatform.android, androidAbi: 'armeabi-v7a')
            ?.name,
        'app-release.apk',
      );
    });

    test('Windows prefere o instalador; macOS o dmg', () {
      final assets = [
        _asset('helper.exe'),
        _asset('IPTV-Setup-0.2.0.exe'),
        _asset('IPTV.msix'),
      ];
      expect(
        pickAsset(assets, UpdatePlatform.windows)?.name,
        'IPTV-Setup-0.2.0.exe',
      );
      expect(
        pickAsset(splitApks, UpdatePlatform.macos)?.name,
        'iptv-0.2.0.dmg',
      );
    });

    test('sem ficheiro para a plataforma', () {
      expect(pickAsset([_asset('notes.txt')], UpdatePlatform.windows), isNull);
      expect(pickAsset(splitApks, UpdatePlatform.unsupported), isNull);
    });
  });

  test('GithubRelease.fromJson ignora assets incompletos', () {
    final release = GithubRelease.fromJson({
      'tag_name': 'v0.2.0',
      'name': 'IPTV 0.2.0',
      'body': 'Notas',
      'html_url': 'https://github.com/dono/repo/releases/tag/v0.2.0',
      'assets': [
        {
          'name': 'app.apk',
          'browser_download_url': 'https://x/app.apk',
          'size': 1234,
        },
        {'name': 'sem-url.apk'},
        'lixo',
      ],
    });

    expect(release.tag, 'v0.2.0');
    expect(release.assets, hasLength(1));
    expect(release.assets.single.size, 1234);
  });
}
