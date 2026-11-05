import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iptv_app/data/profiles/profile.dart';
import 'package:iptv_app/data/profiles/profile_store.dart';
import 'package:iptv_app/data/sources/credentials.dart';

const _x = XtreamCredentials(
  serverUrl: 'http://iptv-x.pt:8080',
  username: 'ana',
  password: 'um',
);
const _y = XtreamCredentials(
  serverUrl: 'http://iptv-y.com',
  username: 'ana',
  password: 'dois',
);

void main() {
  late FlutterSecureStorage storage;
  late ProfileStore store;

  void reset(Map<String, String> values) {
    FlutterSecureStorage.setMockInitialValues(values);
    storage = const FlutterSecureStorage();
    store = ProfileStore(storage);
  }

  test('sem nada guardado: sem perfis', () async {
    reset({});
    final state = await store.load(legacyDatabaseName: 'iptv');
    expect(state.profiles, isEmpty);
    expect(state.active, isNull);
  });

  test('sessão das versões antigas passa a ser o perfil 1, na base principal',
      () async {
    reset({'xtream_credentials': jsonEncode(_x.toJson())});

    final state = await store.load(legacyDatabaseName: 'iptv');

    expect(state.profiles, hasLength(1));
    final profile = state.active!;
    expect(profile.credentials, _x);
    expect(profile.databaseName, 'iptv');
    expect(profile.name, 'iptv-x.pt');
    expect(await storage.read(key: 'xtream_credentials'), isNull);

    // Da segunda vez lê o índice novo: mesmo perfil, sem migrar outra vez.
    final again = await ProfileStore(storage).load(legacyDatabaseName: 'iptv');
    expect(again, state);
  });

  test('guarda vários perfis, a ordem e o ativo', () async {
    reset({});
    const first = Profile(
      id: 'aaaa0001',
      name: 'IPTV X',
      databaseName: 'iptv',
      credentials: _x,
    );
    const second = Profile(
      id: 'bbbb0002',
      name: 'IPTV Y',
      databaseName: 'iptv_bbbb0002',
      credentials: _y,
    );
    const state = ProfilesState(
      profiles: [first, second],
      activeId: 'bbbb0002',
    );
    await store.saveProfile(first);
    await store.saveProfile(second);
    await store.saveIndex(state);

    final loaded = await store.load(legacyDatabaseName: 'iptv');
    expect(loaded, state);
    expect(loaded.active?.name, 'IPTV Y');
  });

  test('perfil apagado ou ativo inválido: fica o primeiro que existe',
      () async {
    reset({});
    const kept = Profile(
      id: 'aaaa0001',
      name: 'IPTV X',
      databaseName: 'iptv',
      credentials: _x,
    );
    await store.saveProfile(kept);
    await storage.write(
      key: 'profiles_index',
      value: jsonEncode({
        'active': 'zzzz9999',
        'ids': ['zzzz9999', 'aaaa0001'],
      }),
    );

    final loaded = await store.load(legacyDatabaseName: 'iptv');
    expect(loaded.profiles, [kept]);
    expect(loaded.activeId, 'aaaa0001');
  });

  test('mesma conta = mesmo servidor e utilizador', () {
    const profile = Profile(
      id: 'aaaa0001',
      name: 'IPTV X',
      databaseName: 'iptv',
      credentials: _x,
    );
    expect(
      profile.isSameAccount(
        const XtreamCredentials(
          serverUrl: 'http://iptv-x.pt:8080',
          username: 'ana',
          password: 'nova',
        ),
      ),
      isTrue,
    );
    expect(profile.isSameAccount(_y), isFalse);
  });

  test('nome por omissão e ids', () {
    expect(defaultProfileName(_y, 1), 'iptv-y.com');
    expect(newProfileId(), matches(RegExp(r'^[0-9a-f]{8}$')));
  });
}
