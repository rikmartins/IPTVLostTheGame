// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'watch_progress.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types, experimental_member_use

extension GetWatchProgressCollection on Isar {
  IsarCollection<WatchProgress> get watchProgress => this.collection();
}

const WatchProgressSchema = CollectionSchema(
  name: r'WatchProgress',
  id: -7341403213961839091,
  properties: {
    r'containerExtension': PropertySchema(
      id: 0,
      name: r'containerExtension',
      type: IsarType.string,
    ),
    r'durationMs': PropertySchema(
      id: 1,
      name: r'durationMs',
      type: IsarType.long,
    ),
    r'episode': PropertySchema(id: 2, name: r'episode', type: IsarType.long),
    r'finished': PropertySchema(id: 3, name: r'finished', type: IsarType.bool),
    r'itemKey': PropertySchema(id: 4, name: r'itemKey', type: IsarType.string),
    r'kind': PropertySchema(
      id: 5,
      name: r'kind',
      type: IsarType.byte,
      enumMap: _WatchProgresskindEnumValueMap,
    ),
    r'positionMs': PropertySchema(
      id: 6,
      name: r'positionMs',
      type: IsarType.long,
    ),
    r'season': PropertySchema(id: 7, name: r'season', type: IsarType.long),
    r'seriesId': PropertySchema(id: 8, name: r'seriesId', type: IsarType.long),
    r'title': PropertySchema(id: 9, name: r'title', type: IsarType.string),
    r'updatedAt': PropertySchema(
      id: 10,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
  },

  estimateSize: _watchProgressEstimateSize,
  serialize: _watchProgressSerialize,
  deserialize: _watchProgressDeserialize,
  deserializeProp: _watchProgressDeserializeProp,
  idName: r'id',
  indexes: {
    r'seriesId': IndexSchema(
      id: -6366517829284187702,
      name: r'seriesId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'seriesId',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
    r'updatedAt': IndexSchema(
      id: -6238191080293565125,
      name: r'updatedAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'updatedAt',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _watchProgressGetId,
  getLinks: _watchProgressGetLinks,
  attach: _watchProgressAttach,
  version: '3.4.1',
);

int _watchProgressEstimateSize(
  WatchProgress object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.containerExtension.length * 3;
  bytesCount += 3 + object.itemKey.length * 3;
  bytesCount += 3 + object.title.length * 3;
  return bytesCount;
}

void _watchProgressSerialize(
  WatchProgress object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.containerExtension);
  writer.writeLong(offsets[1], object.durationMs);
  writer.writeLong(offsets[2], object.episode);
  writer.writeBool(offsets[3], object.finished);
  writer.writeString(offsets[4], object.itemKey);
  writer.writeByte(offsets[5], object.kind.index);
  writer.writeLong(offsets[6], object.positionMs);
  writer.writeLong(offsets[7], object.season);
  writer.writeLong(offsets[8], object.seriesId);
  writer.writeString(offsets[9], object.title);
  writer.writeDateTime(offsets[10], object.updatedAt);
}

WatchProgress _watchProgressDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = WatchProgress();
  object.containerExtension = reader.readString(offsets[0]);
  object.durationMs = reader.readLong(offsets[1]);
  object.episode = reader.readLong(offsets[2]);
  object.finished = reader.readBool(offsets[3]);
  object.id = id;
  object.itemKey = reader.readString(offsets[4]);
  object.kind =
      _WatchProgresskindValueEnumMap[reader.readByteOrNull(offsets[5])] ??
      WatchKind.movie;
  object.positionMs = reader.readLong(offsets[6]);
  object.season = reader.readLong(offsets[7]);
  object.seriesId = reader.readLongOrNull(offsets[8]);
  object.title = reader.readString(offsets[9]);
  object.updatedAt = reader.readDateTime(offsets[10]);
  return object;
}

P _watchProgressDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (_WatchProgresskindValueEnumMap[reader.readByteOrNull(offset)] ??
              WatchKind.movie)
          as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readLongOrNull(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _WatchProgresskindEnumValueMap = {'movie': 0, 'episode': 1};
const _WatchProgresskindValueEnumMap = {
  0: WatchKind.movie,
  1: WatchKind.episode,
};

Id _watchProgressGetId(WatchProgress object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _watchProgressGetLinks(WatchProgress object) {
  return [];
}

void _watchProgressAttach(
  IsarCollection<dynamic> col,
  Id id,
  WatchProgress object,
) {
  object.id = id;
}

extension WatchProgressQueryWhereSort
    on QueryBuilder<WatchProgress, WatchProgress, QWhere> {
  QueryBuilder<WatchProgress, WatchProgress, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterWhere> anySeriesId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'seriesId'),
      );
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterWhere> anyUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'updatedAt'),
      );
    });
  }
}

extension WatchProgressQueryWhere
    on QueryBuilder<WatchProgress, WatchProgress, QWhereClause> {
  QueryBuilder<WatchProgress, WatchProgress, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterWhereClause> idNotEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterWhereClause>
  seriesIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'seriesId', value: [null]),
      );
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterWhereClause>
  seriesIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'seriesId',
          lower: [null],
          includeLower: false,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterWhereClause> seriesIdEqualTo(
    int? seriesId,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'seriesId', value: [seriesId]),
      );
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterWhereClause>
  seriesIdNotEqualTo(int? seriesId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'seriesId',
                lower: [],
                upper: [seriesId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'seriesId',
                lower: [seriesId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'seriesId',
                lower: [seriesId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'seriesId',
                lower: [],
                upper: [seriesId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterWhereClause>
  seriesIdGreaterThan(int? seriesId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'seriesId',
          lower: [seriesId],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterWhereClause>
  seriesIdLessThan(int? seriesId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'seriesId',
          lower: [],
          upper: [seriesId],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterWhereClause> seriesIdBetween(
    int? lowerSeriesId,
    int? upperSeriesId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'seriesId',
          lower: [lowerSeriesId],
          includeLower: includeLower,
          upper: [upperSeriesId],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterWhereClause>
  updatedAtEqualTo(DateTime updatedAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'updatedAt', value: [updatedAt]),
      );
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterWhereClause>
  updatedAtNotEqualTo(DateTime updatedAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'updatedAt',
                lower: [],
                upper: [updatedAt],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'updatedAt',
                lower: [updatedAt],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'updatedAt',
                lower: [updatedAt],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'updatedAt',
                lower: [],
                upper: [updatedAt],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterWhereClause>
  updatedAtGreaterThan(DateTime updatedAt, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'updatedAt',
          lower: [updatedAt],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterWhereClause>
  updatedAtLessThan(DateTime updatedAt, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'updatedAt',
          lower: [],
          upper: [updatedAt],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterWhereClause>
  updatedAtBetween(
    DateTime lowerUpdatedAt,
    DateTime upperUpdatedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'updatedAt',
          lower: [lowerUpdatedAt],
          includeLower: includeLower,
          upper: [upperUpdatedAt],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension WatchProgressQueryFilter
    on QueryBuilder<WatchProgress, WatchProgress, QFilterCondition> {
  QueryBuilder<WatchProgress, WatchProgress, QAfterFilterCondition>
  containerExtensionEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'containerExtension',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterFilterCondition>
  containerExtensionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'containerExtension',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterFilterCondition>
  containerExtensionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'containerExtension',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterFilterCondition>
  containerExtensionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'containerExtension',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterFilterCondition>
  containerExtensionStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'containerExtension',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterFilterCondition>
  containerExtensionEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'containerExtension',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterFilterCondition>
  containerExtensionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'containerExtension',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterFilterCondition>
  containerExtensionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'containerExtension',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterFilterCondition>
  containerExtensionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'containerExtension', value: ''),
      );
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterFilterCondition>
  containerExtensionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'containerExtension', value: ''),
      );
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterFilterCondition>
  durationMsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'durationMs', value: value),
      );
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterFilterCondition>
  durationMsGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'durationMs',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterFilterCondition>
  durationMsLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'durationMs',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterFilterCondition>
  durationMsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'durationMs',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterFilterCondition>
  episodeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'episode', value: value),
      );
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterFilterCondition>
  episodeGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'episode',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterFilterCondition>
  episodeLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'episode',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterFilterCondition>
  episodeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'episode',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterFilterCondition>
  finishedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'finished', value: value),
      );
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterFilterCondition>
  idGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterFilterCondition>
  itemKeyEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'itemKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterFilterCondition>
  itemKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'itemKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterFilterCondition>
  itemKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'itemKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterFilterCondition>
  itemKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'itemKey',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterFilterCondition>
  itemKeyStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'itemKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterFilterCondition>
  itemKeyEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'itemKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterFilterCondition>
  itemKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'itemKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterFilterCondition>
  itemKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'itemKey',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterFilterCondition>
  itemKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'itemKey', value: ''),
      );
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterFilterCondition>
  itemKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'itemKey', value: ''),
      );
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterFilterCondition> kindEqualTo(
    WatchKind value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'kind', value: value),
      );
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterFilterCondition>
  kindGreaterThan(WatchKind value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'kind',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterFilterCondition>
  kindLessThan(WatchKind value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'kind',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterFilterCondition> kindBetween(
    WatchKind lower,
    WatchKind upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'kind',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterFilterCondition>
  positionMsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'positionMs', value: value),
      );
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterFilterCondition>
  positionMsGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'positionMs',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterFilterCondition>
  positionMsLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'positionMs',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterFilterCondition>
  positionMsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'positionMs',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterFilterCondition>
  seasonEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'season', value: value),
      );
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterFilterCondition>
  seasonGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'season',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterFilterCondition>
  seasonLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'season',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterFilterCondition>
  seasonBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'season',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterFilterCondition>
  seriesIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'seriesId'),
      );
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterFilterCondition>
  seriesIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'seriesId'),
      );
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterFilterCondition>
  seriesIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'seriesId', value: value),
      );
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterFilterCondition>
  seriesIdGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'seriesId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterFilterCondition>
  seriesIdLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'seriesId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterFilterCondition>
  seriesIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'seriesId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterFilterCondition>
  titleEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterFilterCondition>
  titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterFilterCondition>
  titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterFilterCondition>
  titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'title',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterFilterCondition>
  titleStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterFilterCondition>
  titleEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterFilterCondition>
  titleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterFilterCondition>
  titleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'title',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterFilterCondition>
  titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'title', value: ''),
      );
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterFilterCondition>
  titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'title', value: ''),
      );
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterFilterCondition>
  updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'updatedAt', value: value),
      );
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterFilterCondition>
  updatedAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterFilterCondition>
  updatedAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterFilterCondition>
  updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'updatedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension WatchProgressQueryObject
    on QueryBuilder<WatchProgress, WatchProgress, QFilterCondition> {}

extension WatchProgressQueryLinks
    on QueryBuilder<WatchProgress, WatchProgress, QFilterCondition> {}

extension WatchProgressQuerySortBy
    on QueryBuilder<WatchProgress, WatchProgress, QSortBy> {
  QueryBuilder<WatchProgress, WatchProgress, QAfterSortBy>
  sortByContainerExtension() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'containerExtension', Sort.asc);
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterSortBy>
  sortByContainerExtensionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'containerExtension', Sort.desc);
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterSortBy> sortByDurationMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationMs', Sort.asc);
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterSortBy>
  sortByDurationMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationMs', Sort.desc);
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterSortBy> sortByEpisode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episode', Sort.asc);
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterSortBy> sortByEpisodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episode', Sort.desc);
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterSortBy> sortByFinished() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'finished', Sort.asc);
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterSortBy>
  sortByFinishedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'finished', Sort.desc);
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterSortBy> sortByItemKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemKey', Sort.asc);
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterSortBy> sortByItemKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemKey', Sort.desc);
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterSortBy> sortByKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.asc);
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterSortBy> sortByKindDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.desc);
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterSortBy> sortByPositionMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'positionMs', Sort.asc);
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterSortBy>
  sortByPositionMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'positionMs', Sort.desc);
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterSortBy> sortBySeason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'season', Sort.asc);
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterSortBy> sortBySeasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'season', Sort.desc);
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterSortBy> sortBySeriesId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seriesId', Sort.asc);
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterSortBy>
  sortBySeriesIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seriesId', Sort.desc);
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterSortBy>
  sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension WatchProgressQuerySortThenBy
    on QueryBuilder<WatchProgress, WatchProgress, QSortThenBy> {
  QueryBuilder<WatchProgress, WatchProgress, QAfterSortBy>
  thenByContainerExtension() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'containerExtension', Sort.asc);
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterSortBy>
  thenByContainerExtensionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'containerExtension', Sort.desc);
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterSortBy> thenByDurationMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationMs', Sort.asc);
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterSortBy>
  thenByDurationMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationMs', Sort.desc);
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterSortBy> thenByEpisode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episode', Sort.asc);
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterSortBy> thenByEpisodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episode', Sort.desc);
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterSortBy> thenByFinished() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'finished', Sort.asc);
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterSortBy>
  thenByFinishedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'finished', Sort.desc);
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterSortBy> thenByItemKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemKey', Sort.asc);
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterSortBy> thenByItemKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemKey', Sort.desc);
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterSortBy> thenByKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.asc);
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterSortBy> thenByKindDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.desc);
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterSortBy> thenByPositionMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'positionMs', Sort.asc);
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterSortBy>
  thenByPositionMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'positionMs', Sort.desc);
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterSortBy> thenBySeason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'season', Sort.asc);
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterSortBy> thenBySeasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'season', Sort.desc);
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterSortBy> thenBySeriesId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seriesId', Sort.asc);
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterSortBy>
  thenBySeriesIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seriesId', Sort.desc);
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QAfterSortBy>
  thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension WatchProgressQueryWhereDistinct
    on QueryBuilder<WatchProgress, WatchProgress, QDistinct> {
  QueryBuilder<WatchProgress, WatchProgress, QDistinct>
  distinctByContainerExtension({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'containerExtension',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QDistinct> distinctByDurationMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'durationMs');
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QDistinct> distinctByEpisode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'episode');
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QDistinct> distinctByFinished() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'finished');
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QDistinct> distinctByItemKey({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'itemKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QDistinct> distinctByKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'kind');
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QDistinct> distinctByPositionMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'positionMs');
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QDistinct> distinctBySeason() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'season');
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QDistinct> distinctBySeriesId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'seriesId');
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QDistinct> distinctByTitle({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WatchProgress, WatchProgress, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension WatchProgressQueryProperty
    on QueryBuilder<WatchProgress, WatchProgress, QQueryProperty> {
  QueryBuilder<WatchProgress, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<WatchProgress, String, QQueryOperations>
  containerExtensionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'containerExtension');
    });
  }

  QueryBuilder<WatchProgress, int, QQueryOperations> durationMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'durationMs');
    });
  }

  QueryBuilder<WatchProgress, int, QQueryOperations> episodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'episode');
    });
  }

  QueryBuilder<WatchProgress, bool, QQueryOperations> finishedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'finished');
    });
  }

  QueryBuilder<WatchProgress, String, QQueryOperations> itemKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'itemKey');
    });
  }

  QueryBuilder<WatchProgress, WatchKind, QQueryOperations> kindProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'kind');
    });
  }

  QueryBuilder<WatchProgress, int, QQueryOperations> positionMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'positionMs');
    });
  }

  QueryBuilder<WatchProgress, int, QQueryOperations> seasonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'season');
    });
  }

  QueryBuilder<WatchProgress, int?, QQueryOperations> seriesIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'seriesId');
    });
  }

  QueryBuilder<WatchProgress, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<WatchProgress, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
