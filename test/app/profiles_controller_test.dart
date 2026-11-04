import 'dart:ffi' show Abi;
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:iptv_app/app/profiles_controller.dart';
import 'package:iptv_app/app/providers.dart';
import 'package:iptv_app/core/database/app_database.dart';
import 'package:iptv_app/data/local/models/account_info.dart';
import 'package:iptv_app/data/local/models/app_settings.dart';
import 'package:iptv_app/data/profiles/profile.dart';
import 'package:iptv_app/data/profiles/profile_store.dart';
import 'package:iptv_app/data/remote/xtream/xtream_credentials.dart';
import 'package:iptv_app/data/repositories/auth_repository.dart';

// Isar nativo a sério: usa o libisar.dll do build Windows
// (`flutter build windows`). Sem ele (CI em Linux) estes testes saltam.
final _isarLibrary = File(
  'build/windows/x64/runner/Release/libisar.dll',
).absolute.path;
final _skip = !Platform.isWindows || !File(_isarLibrary).existsSync()
    ? 'precisa do libisar.dll de um flutter build windows'
    : null;

class _FakeAuth implements AuthRepository {
  XtreamCredentials? rememberedValue;

  @override
  Future<AccountInfo> authenticate(XtreamCredentials credentials) async =>
      AccountInfo()
        ..username = credentials.username
        ..status = 'Active'
        ..lastLoginAt = DateTime(2026);

  @override
  Future<XtreamCredentials?> remembered() async => rememberedValue;

  @override
  Future<void> setRemembered(XtreamCredentials? credentials) async =>
      rememberedValue = credentials;
}

void main() {
  late Directory dir;
  late Isar main;
  late ProviderContainer container;
  late FlutterSecureStorage storage;

  setUpAll(() async {
    if (_skip != null) return;
    await Isar.initializeIsarCore(
      libraries: {Abi.windowsX64: _isarLibrary},
    );
  });

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('profiles_test');
    main = await AppDatabase.openInstance(dir.path);
    await main.writeTxn(() => main.settings.put(AppSettings()));
    FlutterSecureStorage.setMockInitialValues({});
    storage = const FlutterSecureStorage();
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(
          AppDatabase.withInstance(main, dir.path),
        ),
        initialProfilesProvider.overrideWithValue(const ProfilesState()),
        profileStoreProvider.overrideWithValue(ProfileStore(storage)),
        authRepositoryProvider.overrideWithValue(_FakeAuth()),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    for (final name in Isar.instanceNames) {
      await Isar.getInstance(name)?.close();
    }
    await dir.delete(recursive: true);
  });

  ProfilesController controller() => container.read(profilesProvider.notifier);
  ProfilesState state() => container.read(profilesProvider);

  Future<Profile> signIn(String name, String server, String user) =>
      controller().signIn(
        name: name,
        server: server,
        username: user,
        password: 'segredo',
      );

  bool fileExists(String db) => File('${dir.path}/$db.isar').existsSync();

  test('cada perfil tem o seu catálogo; mudar troca o isarProvider', () async {
    final x = await signIn('IPTV X', 'iptv-x.pt:8080', 'ana');
    expect(x.databaseName, 'iptv', reason: 'o primeiro usa a base principal');
    expect(container.read(isarProvider).name, 'iptv');

    final y = await signIn('IPTV Y', 'http://iptv-y.com', 'ana');
    expect(y.databaseName, 'iptv_${y.id}');
    expect(state().activeId, y.id);
    expect(container.read(isarProvider).name, y.databaseName);
    expect(fileExists(y.databaseName), isTrue);

    // Cada base tem a conta do seu perfil.
    expect(main.accounts.getSync(0)?.username, 'ana');
    expect(Isar.getInstance(y.databaseName)!.accounts.getSync(0), isNotNull);

    await controller().switchTo(x.id);
    expect(state().active?.name, 'IPTV X');
    expect(container.read(isarProvider).name, 'iptv');

    // Persistido: ao reabrir a app volta ao mesmo perfil.
    final reloaded = await ProfileStore(
      storage,
    ).load(legacyDatabaseName: 'iptv');
    expect(reloaded, state());
  }, skip: _skip);

  test('a mesma conta atualiza o perfil em vez de criar outro', () async {
    final x = await signIn('', 'iptv-x.pt:8080', 'ana');
    expect(x.name, 'iptv-x.pt', reason: 'sem nome usa o servidor');
    await signIn('IPTV Y', 'http://iptv-y.com', 'ana');

    final again = await controller().signIn(
      name: 'IPTV X',
      server: 'http://iptv-x.pt:8080/',
      username: 'ana',
      password: 'nova',
    );

    expect(state().profiles, hasLength(2));
    expect(again.id, x.id);
    expect(again.name, 'IPTV X');
    expect(again.credentials.password, 'nova');
    expect(state().activeId, x.id);
  }, skip: _skip);

  test('mudar o nome', () async {
    final x = await signIn('IPTV X', 'iptv-x.pt:8080', 'ana');
    await controller().rename(x.id, '  Sala  ');
    expect(state().active?.name, 'Sala');
    final reloaded = await ProfileStore(
      storage,
    ).load(legacyDatabaseName: 'iptv');
    expect(reloaded.active?.name, 'Sala');
  }, skip: _skip);

  test('remover um perfil apaga a base dele; o ativo passa ao seguinte',
      () async {
    final x = await signIn('IPTV X', 'iptv-x.pt:8080', 'ana');
    final y = await signIn('IPTV Y', 'http://iptv-y.com', 'ana');
    final z = await signIn('IPTV Z', 'http://iptv-z.net', 'rui');

    // Não ativo: a base sai do disco.
    await controller().remove(y.id);
    expect(state().profiles.map((p) => p.id), [x.id, z.id]);
    expect(fileExists(y.databaseName), isFalse);
    expect(state().activeId, z.id);

    // O ativo: passa para o primeiro que sobra.
    await controller().remove(z.id);
    expect(state().activeId, x.id);
    expect(container.read(isarProvider).name, 'iptv');
    expect(fileExists(z.databaseName), isFalse);

    // O último, na base principal: só o catálogo sai, as definições ficam.
    await controller().remove(x.id);
    expect(state().profiles, isEmpty);
    expect(state().active, isNull);
    expect(main.accounts.countSync(), 0);
    expect(main.settings.countSync(), 1);

    // Um perfil novo volta a usar a base principal.
    final w = await signIn('IPTV W', 'http://iptv-w.org', 'eva');
    expect(w.databaseName, 'iptv');
  }, skip: _skip);
}
