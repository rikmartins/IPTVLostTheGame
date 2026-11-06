import '../../../core/utils/json_values.dart';
import '../../local/models/account_info.dart';
import '../../local/models/live_channel.dart';
import '../../local/models/media_category.dart';
import '../../local/models/tv_series.dart';
import '../../local/models/vod_movie.dart';
import '../../sources/series_episode.dart';

// JSON do Xtream -> entidades Isar. Itens sem ID válido devolvem null e são
// descartados pela sincronização, em vez de rebentarem com ela.

/// `episodes` do `get_series_info`: normalmente um mapa por temporada
/// (`{"1": [...], "2": [...]}`), mas há painéis que mandam uma lista de
/// listas, ou uma lista plana. Sai ordenado por temporada e episódio.
List<SeriesEpisode> mapSeriesEpisodes(Map<String, dynamic> body) {
  final Iterable<Object?> groups = switch (body['episodes']) {
    final Map<String, dynamic> bySeason => bySeason.values,
    final List<Object?> list => list,
    _ => const [],
  };

  final episodes = <SeriesEpisode>[];
  for (final group in groups) {
    final items = group is List<Object?> ? group : [group];
    for (final item in items) {
      if (item is! Map<String, dynamic>) continue;
      final id = asString(item['id']);
      if (id == null) continue;

      // `info` às vezes chega como [] quando está vazio.
      final info = switch (item['info']) {
        final Map<String, dynamic> map => map,
        _ => const <String, dynamic>{},
      };
      final number = asInt(item['episode_num']) ?? 0;

      episodes.add(
        SeriesEpisode(
          id: id,
          season: asInt(item['season']) ?? 0,
          number: number,
          title: asString(item['title']) ?? 'Episódio $number',
          containerExtension: asString(item['container_extension']) ?? 'mp4',
          plot: asString(info['plot']),
          image: asString(info['movie_image']),
          duration: asString(info['duration']),
        ),
      );
    }
  }

  episodes.sort(
    (a, b) => a.season != b.season
        ? a.season.compareTo(b.season)
        : a.number.compareTo(b.number),
  );
  return episodes;
}

MediaCategory? mapCategory(
  Map<String, dynamic> json,
  CategoryType type, {
  required int sortIndex,
  required int syncStamp,
}) {
  final rawId = asString(json['category_id']);
  if (rawId == null) return null;
  final categoryId = categoryKeyOf(rawId);

  return MediaCategory()
    ..id = MediaCategory.idFor(type, categoryId)
    ..type = type
    ..categoryId = categoryId
    ..name = asString(json['category_name']) ?? rawId
    ..parentId = asInt(json['parent_id']) ?? 0
    ..sortIndex = sortIndex
    ..syncStamp = syncStamp;
}

LiveChannel? mapLiveChannel(
  Map<String, dynamic> json, {
  required int sortIndex,
  required int syncStamp,
}) {
  final id = asInt(json['stream_id']);
  if (id == null) return null;

  return LiveChannel()
    ..id = id
    ..categoryId = _primaryCategory(json)
    ..sortIndex = sortIndex
    ..number = asInt(json['num']) ?? 0
    ..name = asString(json['name']) ?? 'Canal $id'
    ..icon = asString(json['stream_icon'])
    ..epgChannelId = asString(json['epg_channel_id'])?.toLowerCase()
    ..hasCatchup = asBool(json['tv_archive'])
    ..catchupDays = asInt(json['tv_archive_duration']) ?? 0
    ..addedAt = asInt(json['added']) ?? 0
    ..directSource = asString(json['direct_source'])
    ..syncStamp = syncStamp;
}

VodMovie? mapVodMovie(
  Map<String, dynamic> json, {
  required int sortIndex,
  required int syncStamp,
}) {
  final id = asInt(json['stream_id']);
  if (id == null) return null;

  return VodMovie()
    ..id = id
    ..categoryId = _primaryCategory(json)
    ..sortIndex = sortIndex
    ..name = asString(json['name']) ?? 'Filme $id'
    ..poster = asString(json['stream_icon'])
    ..rating = _rating(json)
    ..addedAt = asInt(json['added']) ?? 0
    ..containerExtension = asString(json['container_extension']) ?? 'mp4'
    ..directSource = asString(json['direct_source'])
    ..syncStamp = syncStamp;
}

TvSeries? mapTvSeries(
  Map<String, dynamic> json, {
  required int sortIndex,
  required int syncStamp,
}) {
  final id = asInt(json['series_id']);
  if (id == null) return null;

  return TvSeries()
    ..id = id
    ..categoryId = _primaryCategory(json)
    ..sortIndex = sortIndex
    ..name = asString(json['name']) ?? 'Série $id'
    ..cover = asString(json['cover'])
    ..plot = asString(json['plot'])
    ..genre = asString(json['genre'])
    ..releaseDate =
        asString(json['releaseDate']) ?? asString(json['release_date'])
    ..rating = _rating(json)
    ..lastModified = asInt(json['last_modified']) ?? 0
    ..syncStamp = syncStamp;
}

AccountInfo mapAccountInfo(
  Map<String, dynamic> userInfo,
  Map<String, dynamic>? serverInfo,
) {
  final formats = userInfo['allowed_output_formats'];

  return AccountInfo()
    ..username = asString(userInfo['username']) ?? ''
    ..status = asString(userInfo['status']) ?? 'Unknown'
    ..expiresAt = asEpochSeconds(userInfo['exp_date'])
    ..createdAt = asEpochSeconds(userInfo['created_at'])
    ..isTrial = asBool(userInfo['is_trial'])
    ..activeConnections = asInt(userInfo['active_cons']) ?? 0
    ..maxConnections = asInt(userInfo['max_connections']) ?? 1
    ..allowedOutputFormats = formats is List<Object?>
        ?formats.map(asString).whereType<String>().toList()
        : <String>[]
    ..serverTimezone = asString(serverInfo?['timezone'])
    ..serverUtcOffsetMinutes = serverUtcOffsetMinutes(serverInfo)
    ..lastLoginAt = DateTime.now();
}

/// Diferença da hora do servidor para UTC, a partir de `time_now` (hora
/// local, "2026-11-06 12:01:22") e `timestamp_now` (Unix). Arredondada ao
/// quarto de hora: o pedido demora uns segundos.
int? serverUtcOffsetMinutes(Map<String, dynamic>? serverInfo) {
  final now = asString(serverInfo?['time_now']);
  final stamp = asInt(serverInfo?['timestamp_now']);
  if (now == null || stamp == null || stamp <= 0) return null;
  // Lida como se fosse UTC, só para comparar os campos.
  final local = DateTime.tryParse('${now.replaceFirst(' ', 'T')}Z');
  if (local == null) return null;
  final utc = DateTime.fromMillisecondsSinceEpoch(stamp * 1000, isUtc: true);
  final minutes = local.difference(utc).inSeconds / 60;
  return (minutes / 15).round() * 15;
}

/// `category_id` é o campo clássico; painéis recentes (XUI) mandam também
/// `category_ids: [..]` e às vezes deixam o primeiro a null.
int _primaryCategory(Map<String, dynamic> json) {
  final single = asString(json['category_id']);
  if (single != null) return categoryKeyOf(single);

  final multi = json['category_ids'];
  if (multi is List<Object?> && multi.isNotEmpty) {
    return categoryKeyOf(asString(multi.first));
  }
  return kNoCategory;
}

/// `rating` vem em 0–10 (às vezes ""), `rating_5based` em 0–5.
double _rating(Map<String, dynamic> json) {
  final rating = asDouble(json['rating']);
  if (rating != null && rating > 0) return rating.clamp(0, 10).toDouble();
  final fiveBased = asDouble(json['rating_5based']);
  if (fiveBased != null && fiveBased > 0) {
    return (fiveBased * 2).clamp(0, 10).toDouble();
  }
  return 0;
}
