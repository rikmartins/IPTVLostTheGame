import 'package:isar_community/isar.dart';

import '../../../core/utils/fast_hash.dart';

part 'watch_progress.g.dart';

enum WatchKind { movie, episode }

/// Onde o utilizador ficou num filme ou episódio, neste dispositivo. É o
/// que alimenta o "Continuar a ver" e as marcas de visto nos episódios
/// (no Jellyfin o servidor também guarda o seu).
///
/// Guarda o suficiente para voltar a abrir o episódio sem ir à rede buscar
/// a lista da série.
@Collection(accessor: 'watchProgress')
class WatchProgress {
  /// Ver [idFor].
  Id id = Isar.autoIncrement;

  @enumerated
  late WatchKind kind;

  /// Filme: o ID do filme no Isar. Episódio: o ID do episódio no servidor.
  late String itemKey;

  /// Série do episódio (ID no Isar).
  @Index()
  int? seriesId;

  int season = 0;
  int episode = 0;

  /// Xtream: extensão do ficheiro do episódio (vai no URL).
  String containerExtension = 'mp4';

  late String title;

  int positionMs = 0;
  int durationMs = 0;

  /// Visto até ao fim (ou quase: os créditos não contam).
  bool finished = false;

  @Index()
  late DateTime updatedAt;

  /// Menos do que isto não é "começou a ver".
  static const minPosition = Duration(seconds: 30);

  static Id idFor(WatchKind kind, String itemKey) =>
      fastHash('${kind.name}:$itemKey');

  @ignore
  Duration get position => Duration(milliseconds: positionMs);

  /// Vale a pena retomar: passou do início e não acabou.
  @ignore
  bool get resumable => !finished && position >= minPosition;
}
