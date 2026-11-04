import 'package:isar_community/isar.dart';

import '../../../core/utils/fast_hash.dart';

part 'epg_programme.g.dart';

@Collection(accessor: 'epgProgrammes')
class EpgProgramme {
  /// Ver [idFor]: determinístico, para que a sincronização faça upsert.
  Id id = Isar.autoIncrement;

  /// Índice (canal, início): "agora/a seguir" e a grelha EPG de um canal
  /// são range scans diretos no índice.
  @Index(composite: [CompositeIndex('start')])
  late int channelKey;

  late DateTime start;

  late DateTime stop;

  late String title;

  String? description;

  int syncStamp = 0;

  /// Chave a partir de `LiveChannel.epgChannelId` / atributo `channel` do
  /// XMLTV. É int porque o Isar não aceita Strings no início de um índice
  /// composto, e poupa espaço em centenas de milhares de linhas.
  static int keyFor(String epgChannelId) =>
      fastHash(epgChannelId.trim().toLowerCase());

  static Id idFor(int channelKey, DateTime start) =>
      fastHash('$channelKey|${start.millisecondsSinceEpoch}');
}
