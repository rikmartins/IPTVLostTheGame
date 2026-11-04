import 'package:flutter/foundation.dart';

import '../../core/utils/json_values.dart';

@immutable
class ReleaseAsset {
  const ReleaseAsset({
    required this.name,
    required this.downloadUrl,
    required this.size,
  });

  final String name;
  final String downloadUrl;

  /// Bytes; 0 se o GitHub não o indicar.
  final int size;
}

/// Resposta de `GET /repos/{dono}/{repo}/releases/latest`.
@immutable
class GithubRelease {
  const GithubRelease({
    required this.tag,
    required this.name,
    required this.notes,
    required this.pageUrl,
    required this.assets,
  });

  factory GithubRelease.fromJson(Map<String, dynamic> json) {
    final assets = json['assets'];
    final tag = asString(json['tag_name']) ?? '';
    return GithubRelease(
      tag: tag,
      name: asString(json['name']) ?? tag,
      notes: asString(json['body']),
      pageUrl: asString(json['html_url']),
      assets: [
        if (assets is List<Object?>)
          for (final asset in assets) ?_assetFromJson(asset),
      ],
    );
  }

  static ReleaseAsset? _assetFromJson(Object? json) {
    if (json is! Map<String, dynamic>) return null;
    final name = asString(json['name']);
    final url = asString(json['browser_download_url']);
    if (name == null || url == null) return null;
    return ReleaseAsset(
      name: name,
      downloadUrl: url,
      size: asInt(json['size']) ?? 0,
    );
  }

  final String tag;
  final String name;

  /// Notas da release (Markdown, mostrado em texto simples).
  final String? notes;
  final String? pageUrl;
  final List<ReleaseAsset> assets;
}

enum UpdatePlatform { android, windows, macos, unsupported }

/// Variante Android instalada (flavor do build).
enum AndroidVariant { mobile, tv }

/// "tv" como palavra própria no nome ("-tv", "androidtv"), para não
/// apanhar o "tv" de "IPTV".
final _tvApk = RegExp(r'(^|[^a-z])(android)?tv([^a-z]|$)');

/// ABI → nomes que aparecem nos APKs (cada projeto usa os seus: o
/// `--split-per-abi` do Flutter gera "arm64-v8a", outros usam "arm64v8",
/// "arm32v7"...). A ordem importa: as variantes de 64 bits são testadas
/// antes de "x86" e "armeabi", que são substrings delas.
const _androidAbiAliases = {
  'arm64-v8a': ['arm64-v8a', 'arm64v8', 'arm64', 'aarch64'],
  'x86_64': ['x86_64', 'x86-64', 'x64', 'amd64'],
  'armeabi-v7a': ['armeabi-v7a', 'arm32v7', 'armv7', 'armeabi'],
  'x86': ['x86'],
};

/// Escolhe o ficheiro da release para esta plataforma, pela extensão:
///
/// * Android: `.apk` da mesma [androidVariant] (TV ou telemóvel), para a
///   atualização nunca trocar uma pela outra. Se houver um por arquitetura
///   (`--split-per-abi`), escolhe-se o do [androidAbi], senão o universal.
/// * Windows: instalador `.exe` (de preferência com "setup"/"install" no
///   nome), senão `.msix`. Um `.zip` não serve: a app não se consegue
///   substituir a si própria enquanto corre.
/// * macOS: `.dmg`, senão `.pkg`.
ReleaseAsset? pickAsset(
  List<ReleaseAsset> assets,
  UpdatePlatform platform, {
  String? androidAbi,
  AndroidVariant androidVariant = AndroidVariant.mobile,
}) {
  List<ReleaseAsset> withExtension(String extension) => [
    for (final asset in assets)
      if (asset.name.toLowerCase().endsWith(extension)) asset,
  ];

  switch (platform) {
    case UpdatePlatform.android:
      final wantTv = androidVariant == AndroidVariant.tv;
      final apks = [
        for (final apk in withExtension('.apk'))
          if (_tvApk.hasMatch(apk.name.toLowerCase()) == wantTv) apk,
      ];
      if (androidAbi != null) {
        for (final apk in apks) {
          if (_abiOf(apk.name) == androidAbi) return apk;
        }
      }
      final universal = [
        for (final apk in apks)
          if (_abiOf(apk.name) == null) apk,
      ];
      // Com a ABI conhecida, nunca se oferece o APK de outra arquitetura:
      // um APK de 32 bits instala num telemóvel só de 64 bits e rebenta
      // ao abrir.
      return universal.firstOrNull ??
          (androidAbi == null ? apks.firstOrNull : null);

    case UpdatePlatform.windows:
      final installers = withExtension('.exe');
      for (final exe in installers) {
        final name = exe.name.toLowerCase();
        if (name.contains('setup') || name.contains('install')) return exe;
      }
      return installers.firstOrNull ?? withExtension('.msix').firstOrNull;

    case UpdatePlatform.macos:
      return withExtension('.dmg').firstOrNull ??
          withExtension('.pkg').firstOrNull;

    case UpdatePlatform.unsupported:
      return null;
  }
}

/// ABI no nome de um APK, ou null se for universal.
String? _abiOf(String fileName) {
  final name = fileName.toLowerCase();
  for (final MapEntry(key: abi, value: aliases) in _androidAbiAliases.entries) {
    if (aliases.any(name.contains)) return abi;
  }
  return null;
}
