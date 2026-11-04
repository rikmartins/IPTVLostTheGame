import 'package:isar_community/isar.dart';

import 'media_category.dart';

part 'live_channel.g.dart';

@Collection(accessor: 'liveChannels')
class LiveChannel {
  /// Igual ao `stream_id` do Xtream: o upsert da sincronização é direto,
  /// sem lookups.
  Id id = Isar.autoIncrement;

  /// Índice (categoria, ordem): a grelha de um grupo é lida já ordenada
  /// diretamente do índice.
  @Index(composite: [CompositeIndex('sortIndex')])
  int categoryId = kNoCategory;

  int sortIndex = 0;

  /// Número do canal definido pelo fornecedor (`num`).
  int number = 0;

  late String name;

  String? icon;

  /// `epg_channel_id` normalizado (trim + minúsculas) para casar com o XMLTV.
  String? epgChannelId;

  /// Catch-up / timeshift disponível (`tv_archive`).
  bool hasCatchup = false;

  int catchupDays = 0;

  /// Unix seconds (`added`).
  int addedAt = 0;

  String? directSource;

  int syncStamp = 0;
}
