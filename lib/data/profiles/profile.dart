import 'dart:math';

import 'package:flutter/foundation.dart';

import '../sources/credentials.dart';

/// Uma conta guardada na app ("Perfil 1 - IPTV X"), Xtream Codes ou
/// Jellyfin.
///
/// Cada perfil tem a sua base de dados Isar, por isso mudar de perfil é
/// imediato: o catálogo do outro já está no dispositivo.
@immutable
class Profile {
  const Profile({
    required this.id,
    required this.name,
    required this.databaseName,
    required this.credentials,
  });

  factory Profile.fromJson(String id, Map<String, dynamic> json) {
    return Profile(
      id: id,
      name: json['name'] as String,
      databaseName: json['db'] as String,
      credentials: SourceCredentials.fromJson(json),
    );
  }

  final String id;
  final String name;

  /// Nome da instância Isar com o catálogo deste perfil.
  final String databaseName;
  final SourceCredentials credentials;

  bool isSameAccount(SourceCredentials other) =>
      credentials.isSameAccount(other);

  Profile copyWith({String? name, SourceCredentials? credentials}) {
    return Profile(
      id: id,
      name: name ?? this.name,
      databaseName: databaseName,
      credentials: credentials ?? this.credentials,
    );
  }

  Map<String, String> toJson() => {
    'name': name,
    'db': databaseName,
    ...credentials.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      other is Profile &&
      other.id == id &&
      other.name == name &&
      other.databaseName == databaseName &&
      other.credentials == credentials;

  @override
  int get hashCode => Object.hash(id, name, databaseName, credentials);

  /// Nunca expor a password em logs.
  @override
  String toString() => 'Profile($id, $name, $databaseName)';
}

@immutable
class ProfilesState {
  const ProfilesState({this.profiles = const [], this.activeId});

  /// Pela ordem em que foram criados.
  final List<Profile> profiles;
  final String? activeId;

  Profile? get active {
    for (final profile in profiles) {
      if (profile.id == activeId) return profile;
    }
    return null;
  }

  Profile? byId(String id) {
    for (final profile in profiles) {
      if (profile.id == id) return profile;
    }
    return null;
  }

  @override
  bool operator ==(Object other) =>
      other is ProfilesState &&
      other.activeId == activeId &&
      listEquals(other.profiles, profiles);

  @override
  int get hashCode => Object.hash(activeId, Object.hashAll(profiles));
}

/// Nome quando não se escreve nenhum: o nome que o servidor Jellyfin dá a
/// si próprio, ou o servidor ("exemplo.com"), que é o que distingue um
/// fornecedor de outro.
String defaultProfileName(
  SourceCredentials credentials,
  int index, {
  String? serverName,
}) {
  if (serverName != null && serverName.trim().isNotEmpty) {
    return serverName.trim();
  }
  final host = Uri.tryParse(credentials.serverUrl)?.host ?? '';
  return host.isEmpty ? 'Perfil ${index + 1}' : host;
}

/// 8 caracteres hexadecimais: entra no nome do ficheiro da base de dados.
String newProfileId() => _randomHex(8);

/// ID com que a app se apresenta a um servidor Jellyfin (um por perfil).
String newDeviceId() => _randomHex(32);

String _randomHex(int length) {
  final random = Random.secure();
  return List.generate(
    length,
    (_) => random.nextInt(16).toRadixString(16),
  ).join();
}
