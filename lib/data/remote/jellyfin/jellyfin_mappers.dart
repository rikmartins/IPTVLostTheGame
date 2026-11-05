import 'package:flutter/foundation.dart';

import '../../../core/utils/fast_hash.dart';
import '../../../core/utils/json_values.dart';
import '../../local/models/account_info.dart';
import '../../local/models/epg_programme.dart';
import '../../local/models/live_channel.dart';
import '../../local/models/media_category.dart';
import '../../local/models/tv_series.dart';
import '../../local/models/vod_movie.dart';
import '../../sources/series_episode.dart';

// JSON da API do Jellyfin -> entidades Isar. Itens sem ID devolvem null e
// são descartados pela sincronização.

/// Biblioteca do utilizador ("Filmes", "Séries", "TV em direto"...).
@immutable
class JellyfinView {
  const JellyfinView({
    required this.id,
    required this.name,
    this.collectionType,
  });

  final String id;
  final String name;

  /// "movies", "tvshows", "livetv"... null numa biblioteca mista.
  final String? collectionType;

  bool get hasMovies => collectionType == 'movies' || isMixed;

  bool get hasSeries => collectionType == 'tvshows' || isMixed;

  bool get isLiveTv => collectionType == 'livetv';

  bool get isMixed => collectionType == null || collectionType == 'mixed';
}

/// Os IDs do Jellyfin são GUIDs, com ou sem hífenes consoante o sítio.
String normalizeJellyfinId(String id) =>
    id.trim().toLowerCase().replaceAll('-', '');

/// O `Id` do Isar é int: o hash do GUID.
int jellyfinKey(String id) => fastHash(normalizeJellyfinId(id));

/// Os itens de uma resposta `{"Items": [...]}` (ou de uma lista simples,
/// como a das bibliotecas em servidores antigos).
List<Map<String, dynamic>> jellyfinItems(Object? body) {
  final items = switch (body) {
    final Map<String, dynamic> map => map['Items'],
    final List<Object?> list => list,
    _ => null,
  };
  if (items is! List<Object?>) return const [];
  return items.whereType<Map<String, dynamic>>().toList();
}

/// As imagens do Jellyfin não precisam de autenticação. [maxHeight] evita
/// descarregar o original (muitas vezes 2000px+).
String? primaryImageUrl(
  String serverUrl,
  Map<String, dynamic> json, {
  required int maxHeight,
}) {
  final id = asString(json['Id']);
  final tags = json['ImageTags'];
  final tag = tags is Map<String, dynamic> ? asString(tags['Primary']) : null;
  if (id == null || tag == null) return null;
  return Uri.parse('$serverUrl/Items/$id/Images/Primary')
      .replace(
        queryParameters: {
          'maxHeight': '$maxHeight',
          'quality': '90',
          'tag': tag,
        },
      )
      .toString();
}

/// Datas ISO 8601 do .NET ("2024-03-01T20:15:00.0000000Z").
DateTime? parseJellyfinDate(Object? value) {
  final text = asString(value);
  return text == null ? null : DateTime.tryParse(text)?.toUtc();
}

/// 1 tick = 100 ns.
Duration? ticksToDuration(Object? value) {
  final ticks = asInt(value);
  if (ticks == null || ticks <= 0) return null;
  return Duration(microseconds: ticks ~/ 10);
}

int durationToTicks(Duration duration) => duration.inMicroseconds * 10;

int _epochSeconds(Object? value) {
  final date = parseJellyfinDate(value);
  return date == null ? 0 : date.millisecondsSinceEpoch ~/ 1000;
}

double _rating(Map<String, dynamic> json) =>
    (asDouble(json['CommunityRating']) ?? 0).clamp(0, 10).toDouble();

JellyfinView? mapView(Map<String, dynamic> json) {
  final id = asString(json['Id']);
  if (id == null) return null;
  return JellyfinView(
    id: id,
    name: asString(json['Name']) ?? 'Biblioteca',
    collectionType: asString(json['CollectionType'])?.toLowerCase(),
  );
}

AccountInfo mapJellyfinAccount(Map<String, dynamic> user) {
  final policy = user['Policy'];
  final disabled =
      policy is Map<String, dynamic> && asBool(policy['IsDisabled']);
  return AccountInfo()
    ..username = asString(user['Name']) ?? ''
    ..status = disabled ? 'Disabled' : 'Active'
    // Sem limite de ligações do lado do Jellyfin.
    ..maxConnections = 0
    ..lastLoginAt = DateTime.now();
}

VodMovie? mapJellyfinMovie(
  Map<String, dynamic> json, {
  required String serverUrl,
  required int categoryId,
  required int sortIndex,
  required int syncStamp,
}) {
  final id = asString(json['Id']);
  if (id == null) return null;
  return VodMovie()
    ..id = jellyfinKey(id)
    ..remoteId = id
    ..categoryId = categoryId
    ..sortIndex = sortIndex
    ..name = asString(json['Name']) ?? 'Filme'
    ..poster = primaryImageUrl(serverUrl, json, maxHeight: 600)
    ..rating = _rating(json)
    ..addedAt = _epochSeconds(json['DateCreated'])
    ..syncStamp = syncStamp;
}

TvSeries? mapJellyfinSeries(
  Map<String, dynamic> json, {
  required String serverUrl,
  required int categoryId,
  required int sortIndex,
  required int syncStamp,
}) {
  final id = asString(json['Id']);
  if (id == null) return null;
  final genres = json['Genres'];
  return TvSeries()
    ..id = jellyfinKey(id)
    ..remoteId = id
    ..categoryId = categoryId
    ..sortIndex = sortIndex
    ..name = asString(json['Name']) ?? 'Série'
    ..cover = primaryImageUrl(serverUrl, json, maxHeight: 600)
    ..plot = asString(json['Overview'])
    ..genre = genres is List<Object?> && genres.isNotEmpty
        ? genres.map(asString).whereType<String>().take(3).join(', ')
        : null
    ..releaseDate = asString(json['ProductionYear'])
    ..rating = _rating(json)
    // "Atualizadas recentemente" = com episódios novos primeiro.
    ..lastModified = _epochSeconds(
      json['DateLastMediaAdded'] ?? json['DateCreated'],
    )
    ..syncStamp = syncStamp;
}

/// Ordem dos canais: pelo número ("5", "5.1"), e sem número no fim.
double channelSortKey(Map<String, dynamic> json) {
  final number = asString(json['ChannelNumber']) ?? asString(json['Number']);
  return double.tryParse(number ?? '') ?? double.infinity;
}

LiveChannel? mapJellyfinChannel(
  Map<String, dynamic> json, {
  required String serverUrl,
  required int sortIndex,
  required int syncStamp,
}) {
  final id = asString(json['Id']);
  if (id == null) return null;
  final number = asString(json['ChannelNumber']) ?? asString(json['Number']);
  return LiveChannel()
    ..id = jellyfinKey(id)
    ..remoteId = id
    // O Jellyfin não agrupa canais: ficam todos em "Todos os canais".
    ..categoryId = kNoCategory
    ..sortIndex = sortIndex
    ..number = double.tryParse(number ?? '')?.truncate() ?? 0
    ..name = asString(json['Name']) ?? 'Canal'
    ..icon = primaryImageUrl(serverUrl, json, maxHeight: 120)
    // O guia do Jellyfin já vem por canal: a "chave EPG" é o próprio ID.
    ..epgChannelId = normalizeJellyfinId(id)
    ..syncStamp = syncStamp;
}

/// null = sem canal ou sem horas (não entra no guia).
EpgProgramme? mapJellyfinProgramme(
  Map<String, dynamic> json, {
  required int syncStamp,
}) {
  final channelId = asString(json['ChannelId']);
  final start = parseJellyfinDate(json['StartDate']);
  final stop = parseJellyfinDate(json['EndDate']);
  if (channelId == null || start == null || stop == null) return null;

  final name = asString(json['Name']) ?? '';
  final episode = asString(json['EpisodeTitle']);
  final key = EpgProgramme.keyFor(normalizeJellyfinId(channelId));
  return EpgProgramme()
    ..id = EpgProgramme.idFor(key, start)
    ..channelKey = key
    ..start = start
    ..stop = stop
    ..title = episode == null || episode == name ? name : '$name: $episode'
    ..description = asString(json['Overview'])
    ..syncStamp = syncStamp;
}

/// Onde o utilizador ficou (`UserData.PlaybackPositionTicks`).
Duration? resumePositionOf(Map<String, dynamic> json) {
  final data = json['UserData'];
  return data is Map<String, dynamic>
      ? ticksToDuration(data['PlaybackPositionTicks'])
      : null;
}

bool _played(Map<String, dynamic> json) {
  final data = json['UserData'];
  return data is Map<String, dynamic> && asBool(data['Played']);
}

/// Episódios de `/Shows/{id}/Episodes`, ordenados por temporada e número.
List<SeriesEpisode> mapJellyfinEpisodes(
  List<Map<String, dynamic>> items, {
  required String serverUrl,
}) {
  final episodes = <SeriesEpisode>[
    for (final json in items)
      if (asString(json['Id']) case final id?)
        SeriesEpisode(
          id: id,
          season: asInt(json['ParentIndexNumber']) ?? 0,
          number: asInt(json['IndexNumber']) ?? 0,
          title:
              asString(json['Name']) ??
              'Episódio ${asInt(json['IndexNumber']) ?? ''}'.trim(),
          plot: asString(json['Overview']),
          image: primaryImageUrl(serverUrl, json, maxHeight: 240),
          duration: _clock(ticksToDuration(json['RunTimeTicks'])),
          resumeAt: resumePositionOf(json),
          watched: _played(json),
        ),
  ];
  episodes.sort(
    (a, b) => a.season != b.season
        ? a.season.compareTo(b.season)
        : a.number.compareTo(b.number),
  );
  return episodes;
}

/// "00:45:12", como o Xtream manda a duração.
String? _clock(Duration? duration) {
  if (duration == null) return null;
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(duration.inHours)}:${two(duration.inMinutes % 60)}:'
      '${two(duration.inSeconds % 60)}';
}
