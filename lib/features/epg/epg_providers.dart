import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import '../../app/providers.dart';
import '../../data/local/models/epg_programme.dart';
import '../../data/local/models/sync_state.dart';

/// Relógio de 30 s: chega para as barras de progresso e o "agora/a seguir",
/// e evita rebuilds a cada segundo em toda a grelha.
final clockProvider = StreamProvider<DateTime>(
  (ref) => Stream.periodic(
    const Duration(seconds: 30),
    (_) => DateTime.now(),
  ),
);

@immutable
class NowNext {
  const NowNext(this.current, this.next);

  final EpgProgramme? current;
  final EpgProgramme? next;

  /// 0–1, ou null sem programa atual.
  double? progressAt(DateTime now) {
    final p = current;
    if (p == null) return null;
    final total = p.stop.difference(p.start).inSeconds;
    if (total <= 0) return null;
    return (now.difference(p.start).inSeconds / total).clamp(0.0, 1.0);
  }
}

/// Programa atual e seguinte de um canal (por `epgChannelId`).
///
/// Dois range scans no índice (canal, início), cada um com poucos registos:
/// é barato o suficiente para correr em síncrono por linha visível.
final nowNextProvider = Provider.autoDispose.family<NowNext, String>((
  ref,
  epgChannelId,
) {
  final now = ref.watch(clockProvider).value ?? DateTime.now();
  ref.watch(catalogVersionProvider(SyncKind.epg));

  final programmes = ref.watch(isarProvider).epgProgrammes;
  final key = EpgProgramme.keyFor(epgChannelId);

  final current = programmes
      .where()
      .channelKeyEqualToStartLessThan(key, now, include: true)
      .filter()
      .stopGreaterThan(now)
      .findFirstSync();
  final next = programmes
      .where()
      .channelKeyEqualToStartGreaterThan(key, now)
      .findFirstSync();

  return NowNext(current, next);
});
