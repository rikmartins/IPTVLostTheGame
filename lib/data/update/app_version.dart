import 'package:flutter/foundation.dart';

final _versionPattern = RegExp(r'(\d+)(?:\.(\d+))?(?:\.(\d+))?(?:\+(\d+))?');

/// Versão "maior.menor.patch[+build]", tolerante ao formato das tags
/// (`v1.2.0`, `1.2`, `release-1.2.0`).
@immutable
class AppVersion implements Comparable<AppVersion> {
  const AppVersion(this.major, this.minor, this.patch, [this.build]);

  /// A primeira sequência de dígitos que pareça uma versão. Sufixos de
  /// pré-release (`-beta.1`) são ignorados: o `releases/latest` do GitHub
  /// já exclui pré-releases.
  static AppVersion? tryParse(String input) {
    final match = _versionPattern.firstMatch(input);
    if (match == null) return null;
    int part(int group) => int.tryParse(match.group(group) ?? '') ?? 0;
    final build = match.group(4);
    return AppVersion(
      part(1),
      part(2),
      part(3),
      build == null ? null : int.parse(build),
    );
  }

  final int major;
  final int minor;
  final int patch;

  /// Número de build (`+N` no pubspec). As tags normalmente não o têm.
  final int? build;

  /// O build só desempata quando as duas versões o têm: a tag `v1.2.0`
  /// equivale à app `1.2.0+7`, não é mais antiga.
  @override
  int compareTo(AppVersion other) {
    for (final (a, b) in [
      (major, other.major),
      (minor, other.minor),
      (patch, other.patch),
    ]) {
      if (a != b) return a.compareTo(b);
    }
    final thisBuild = build;
    final otherBuild = other.build;
    if (thisBuild == null || otherBuild == null) return 0;
    return thisBuild.compareTo(otherBuild);
  }

  bool isNewerThan(AppVersion other) => compareTo(other) > 0;

  @override
  bool operator ==(Object other) =>
      other is AppVersion && compareTo(other) == 0 && build == other.build;

  @override
  int get hashCode => Object.hash(major, minor, patch, build);

  /// Sem o build: é o que o utilizador vê.
  @override
  String toString() => '$major.$minor.$patch';
}
