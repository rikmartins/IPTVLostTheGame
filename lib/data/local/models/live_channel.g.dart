// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_channel.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types, experimental_member_use

extension GetLiveChannelCollection on Isar {
  IsarCollection<LiveChannel> get liveChannels => this.collection();
}

const LiveChannelSchema = CollectionSchema(
  name: r'LiveChannel',
  id: -6395034737136214044,
  properties: {
    r'addedAt': PropertySchema(id: 0, name: r'addedAt', type: IsarType.long),
    r'catchupDays': PropertySchema(
      id: 1,
      name: r'catchupDays',
      type: IsarType.long,
    ),
    r'categoryId': PropertySchema(
      id: 2,
      name: r'categoryId',
      type: IsarType.long,
    ),
    r'directSource': PropertySchema(
      id: 3,
      name: r'directSource',
      type: IsarType.string,
    ),
    r'epgChannelId': PropertySchema(
      id: 4,
      name: r'epgChannelId',
      type: IsarType.string,
    ),
    r'hasCatchup': PropertySchema(
      id: 5,
      name: r'hasCatchup',
      type: IsarType.bool,
    ),
    r'icon': PropertySchema(id: 6, name: r'icon', type: IsarType.string),
    r'name': PropertySchema(id: 7, name: r'name', type: IsarType.string),
    r'number': PropertySchema(id: 8, name: r'number', type: IsarType.long),
    r'remoteId': PropertySchema(
      id: 9,
      name: r'remoteId',
      type: IsarType.string,
    ),
    r'sortIndex': PropertySchema(
      id: 10,
      name: r'sortIndex',
      type: IsarType.long,
    ),
    r'syncStamp': PropertySchema(
      id: 11,
      name: r'syncStamp',
      type: IsarType.long,
    ),
  },

  estimateSize: _liveChannelEstimateSize,
  serialize: _liveChannelSerialize,
  deserialize: _liveChannelDeserialize,
  deserializeProp: _liveChannelDeserializeProp,
  idName: r'id',
  indexes: {
    r'categoryId_sortIndex': IndexSchema(
      id: -6671608036174159934,
      name: r'categoryId_sortIndex',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'categoryId',
          type: IndexType.value,
          caseSensitive: false,
        ),
        IndexPropertySchema(
          name: r'sortIndex',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _liveChannelGetId,
  getLinks: _liveChannelGetLinks,
  attach: _liveChannelAttach,
  version: '3.4.1',
);

int _liveChannelEstimateSize(
  LiveChannel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.directSource;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.epgChannelId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.icon;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.name.length * 3;
  {
    final value = object.remoteId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _liveChannelSerialize(
  LiveChannel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.addedAt);
  writer.writeLong(offsets[1], object.catchupDays);
  writer.writeLong(offsets[2], object.categoryId);
  writer.writeString(offsets[3], object.directSource);
  writer.writeString(offsets[4], object.epgChannelId);
  writer.writeBool(offsets[5], object.hasCatchup);
  writer.writeString(offsets[6], object.icon);
  writer.writeString(offsets[7], object.name);
  writer.writeLong(offsets[8], object.number);
  writer.writeString(offsets[9], object.remoteId);
  writer.writeLong(offsets[10], object.sortIndex);
  writer.writeLong(offsets[11], object.syncStamp);
}

LiveChannel _liveChannelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = LiveChannel();
  object.addedAt = reader.readLong(offsets[0]);
  object.catchupDays = reader.readLong(offsets[1]);
  object.categoryId = reader.readLong(offsets[2]);
  object.directSource = reader.readStringOrNull(offsets[3]);
  object.epgChannelId = reader.readStringOrNull(offsets[4]);
  object.hasCatchup = reader.readBool(offsets[5]);
  object.icon = reader.readStringOrNull(offsets[6]);
  object.id = id;
  object.name = reader.readString(offsets[7]);
  object.number = reader.readLong(offsets[8]);
  object.remoteId = reader.readStringOrNull(offsets[9]);
  object.sortIndex = reader.readLong(offsets[10]);
  object.syncStamp = reader.readLong(offsets[11]);
  return object;
}

P _liveChannelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readLong(offset)) as P;
    case 11:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _liveChannelGetId(LiveChannel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _liveChannelGetLinks(LiveChannel object) {
  return [];
}

void _liveChannelAttach(
  IsarCollection<dynamic> col,
  Id id,
  LiveChannel object,
) {
  object.id = id;
}

extension LiveChannelQueryWhereSort
    on QueryBuilder<LiveChannel, LiveChannel, QWhere> {
  QueryBuilder<LiveChannel, LiveChannel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterWhere> anyCategoryIdSortIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'categoryId_sortIndex'),
      );
    });
  }
}

extension LiveChannelQueryWhere
    on QueryBuilder<LiveChannel, LiveChannel, QWhereClause> {
  QueryBuilder<LiveChannel, LiveChannel, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<LiveChannel, LiveChannel, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterWhereClause> idBetween(
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

  QueryBuilder<LiveChannel, LiveChannel, QAfterWhereClause>
  categoryIdEqualToAnySortIndex(int categoryId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'categoryId_sortIndex',
          value: [categoryId],
        ),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterWhereClause>
  categoryIdNotEqualToAnySortIndex(int categoryId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'categoryId_sortIndex',
                lower: [],
                upper: [categoryId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'categoryId_sortIndex',
                lower: [categoryId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'categoryId_sortIndex',
                lower: [categoryId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'categoryId_sortIndex',
                lower: [],
                upper: [categoryId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterWhereClause>
  categoryIdGreaterThanAnySortIndex(int categoryId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'categoryId_sortIndex',
          lower: [categoryId],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterWhereClause>
  categoryIdLessThanAnySortIndex(int categoryId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'categoryId_sortIndex',
          lower: [],
          upper: [categoryId],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterWhereClause>
  categoryIdBetweenAnySortIndex(
    int lowerCategoryId,
    int upperCategoryId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'categoryId_sortIndex',
          lower: [lowerCategoryId],
          includeLower: includeLower,
          upper: [upperCategoryId],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterWhereClause>
  categoryIdSortIndexEqualTo(int categoryId, int sortIndex) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'categoryId_sortIndex',
          value: [categoryId, sortIndex],
        ),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterWhereClause>
  categoryIdEqualToSortIndexNotEqualTo(int categoryId, int sortIndex) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'categoryId_sortIndex',
                lower: [categoryId],
                upper: [categoryId, sortIndex],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'categoryId_sortIndex',
                lower: [categoryId, sortIndex],
                includeLower: false,
                upper: [categoryId],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'categoryId_sortIndex',
                lower: [categoryId, sortIndex],
                includeLower: false,
                upper: [categoryId],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'categoryId_sortIndex',
                lower: [categoryId],
                upper: [categoryId, sortIndex],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterWhereClause>
  categoryIdEqualToSortIndexGreaterThan(
    int categoryId,
    int sortIndex, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'categoryId_sortIndex',
          lower: [categoryId, sortIndex],
          includeLower: include,
          upper: [categoryId],
        ),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterWhereClause>
  categoryIdEqualToSortIndexLessThan(
    int categoryId,
    int sortIndex, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'categoryId_sortIndex',
          lower: [categoryId],
          upper: [categoryId, sortIndex],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterWhereClause>
  categoryIdEqualToSortIndexBetween(
    int categoryId,
    int lowerSortIndex,
    int upperSortIndex, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'categoryId_sortIndex',
          lower: [categoryId, lowerSortIndex],
          includeLower: includeLower,
          upper: [categoryId, upperSortIndex],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension LiveChannelQueryFilter
    on QueryBuilder<LiveChannel, LiveChannel, QFilterCondition> {
  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition> addedAtEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'addedAt', value: value),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition>
  addedAtGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'addedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition> addedAtLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'addedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition> addedAtBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'addedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition>
  catchupDaysEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'catchupDays', value: value),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition>
  catchupDaysGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'catchupDays',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition>
  catchupDaysLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'catchupDays',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition>
  catchupDaysBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'catchupDays',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition>
  categoryIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'categoryId', value: value),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition>
  categoryIdGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'categoryId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition>
  categoryIdLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'categoryId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition>
  categoryIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'categoryId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition>
  directSourceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'directSource'),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition>
  directSourceIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'directSource'),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition>
  directSourceEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'directSource',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition>
  directSourceGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'directSource',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition>
  directSourceLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'directSource',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition>
  directSourceBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'directSource',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition>
  directSourceStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'directSource',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition>
  directSourceEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'directSource',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition>
  directSourceContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'directSource',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition>
  directSourceMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'directSource',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition>
  directSourceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'directSource', value: ''),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition>
  directSourceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'directSource', value: ''),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition>
  epgChannelIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'epgChannelId'),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition>
  epgChannelIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'epgChannelId'),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition>
  epgChannelIdEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'epgChannelId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition>
  epgChannelIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'epgChannelId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition>
  epgChannelIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'epgChannelId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition>
  epgChannelIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'epgChannelId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition>
  epgChannelIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'epgChannelId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition>
  epgChannelIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'epgChannelId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition>
  epgChannelIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'epgChannelId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition>
  epgChannelIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'epgChannelId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition>
  epgChannelIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'epgChannelId', value: ''),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition>
  epgChannelIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'epgChannelId', value: ''),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition>
  hasCatchupEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'hasCatchup', value: value),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition> iconIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'icon'),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition>
  iconIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'icon'),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition> iconEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'icon',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition> iconGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'icon',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition> iconLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'icon',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition> iconBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'icon',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition> iconStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'icon',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition> iconEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'icon',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition> iconContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'icon',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition> iconMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'icon',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition> iconIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'icon', value: ''),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition>
  iconIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'icon', value: ''),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
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

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition> idBetween(
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

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition> nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'name',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition> nameContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition> nameMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'name',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition>
  nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition> numberEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'number', value: value),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition>
  numberGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'number',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition> numberLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'number',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition> numberBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'number',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition>
  remoteIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'remoteId'),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition>
  remoteIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'remoteId'),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition> remoteIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'remoteId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition>
  remoteIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'remoteId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition>
  remoteIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'remoteId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition> remoteIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'remoteId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition>
  remoteIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'remoteId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition>
  remoteIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'remoteId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition>
  remoteIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'remoteId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition> remoteIdMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'remoteId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition>
  remoteIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'remoteId', value: ''),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition>
  remoteIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'remoteId', value: ''),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition>
  sortIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'sortIndex', value: value),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition>
  sortIndexGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'sortIndex',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition>
  sortIndexLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'sortIndex',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition>
  sortIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'sortIndex',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition>
  syncStampEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'syncStamp', value: value),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition>
  syncStampGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'syncStamp',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition>
  syncStampLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'syncStamp',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterFilterCondition>
  syncStampBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'syncStamp',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension LiveChannelQueryObject
    on QueryBuilder<LiveChannel, LiveChannel, QFilterCondition> {}

extension LiveChannelQueryLinks
    on QueryBuilder<LiveChannel, LiveChannel, QFilterCondition> {}

extension LiveChannelQuerySortBy
    on QueryBuilder<LiveChannel, LiveChannel, QSortBy> {
  QueryBuilder<LiveChannel, LiveChannel, QAfterSortBy> sortByAddedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addedAt', Sort.asc);
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterSortBy> sortByAddedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addedAt', Sort.desc);
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterSortBy> sortByCatchupDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'catchupDays', Sort.asc);
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterSortBy> sortByCatchupDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'catchupDays', Sort.desc);
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterSortBy> sortByCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.asc);
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterSortBy> sortByCategoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.desc);
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterSortBy> sortByDirectSource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'directSource', Sort.asc);
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterSortBy>
  sortByDirectSourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'directSource', Sort.desc);
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterSortBy> sortByEpgChannelId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'epgChannelId', Sort.asc);
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterSortBy>
  sortByEpgChannelIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'epgChannelId', Sort.desc);
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterSortBy> sortByHasCatchup() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasCatchup', Sort.asc);
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterSortBy> sortByHasCatchupDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasCatchup', Sort.desc);
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterSortBy> sortByIcon() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'icon', Sort.asc);
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterSortBy> sortByIconDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'icon', Sort.desc);
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterSortBy> sortByNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'number', Sort.asc);
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterSortBy> sortByNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'number', Sort.desc);
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterSortBy> sortByRemoteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.asc);
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterSortBy> sortByRemoteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.desc);
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterSortBy> sortBySortIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortIndex', Sort.asc);
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterSortBy> sortBySortIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortIndex', Sort.desc);
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterSortBy> sortBySyncStamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStamp', Sort.asc);
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterSortBy> sortBySyncStampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStamp', Sort.desc);
    });
  }
}

extension LiveChannelQuerySortThenBy
    on QueryBuilder<LiveChannel, LiveChannel, QSortThenBy> {
  QueryBuilder<LiveChannel, LiveChannel, QAfterSortBy> thenByAddedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addedAt', Sort.asc);
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterSortBy> thenByAddedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addedAt', Sort.desc);
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterSortBy> thenByCatchupDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'catchupDays', Sort.asc);
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterSortBy> thenByCatchupDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'catchupDays', Sort.desc);
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterSortBy> thenByCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.asc);
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterSortBy> thenByCategoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.desc);
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterSortBy> thenByDirectSource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'directSource', Sort.asc);
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterSortBy>
  thenByDirectSourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'directSource', Sort.desc);
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterSortBy> thenByEpgChannelId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'epgChannelId', Sort.asc);
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterSortBy>
  thenByEpgChannelIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'epgChannelId', Sort.desc);
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterSortBy> thenByHasCatchup() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasCatchup', Sort.asc);
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterSortBy> thenByHasCatchupDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasCatchup', Sort.desc);
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterSortBy> thenByIcon() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'icon', Sort.asc);
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterSortBy> thenByIconDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'icon', Sort.desc);
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterSortBy> thenByNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'number', Sort.asc);
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterSortBy> thenByNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'number', Sort.desc);
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterSortBy> thenByRemoteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.asc);
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterSortBy> thenByRemoteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.desc);
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterSortBy> thenBySortIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortIndex', Sort.asc);
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterSortBy> thenBySortIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortIndex', Sort.desc);
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterSortBy> thenBySyncStamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStamp', Sort.asc);
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QAfterSortBy> thenBySyncStampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStamp', Sort.desc);
    });
  }
}

extension LiveChannelQueryWhereDistinct
    on QueryBuilder<LiveChannel, LiveChannel, QDistinct> {
  QueryBuilder<LiveChannel, LiveChannel, QDistinct> distinctByAddedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'addedAt');
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QDistinct> distinctByCatchupDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'catchupDays');
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QDistinct> distinctByCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'categoryId');
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QDistinct> distinctByDirectSource({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'directSource', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QDistinct> distinctByEpgChannelId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'epgChannelId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QDistinct> distinctByHasCatchup() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hasCatchup');
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QDistinct> distinctByIcon({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'icon', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QDistinct> distinctByName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QDistinct> distinctByNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'number');
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QDistinct> distinctByRemoteId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'remoteId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QDistinct> distinctBySortIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sortIndex');
    });
  }

  QueryBuilder<LiveChannel, LiveChannel, QDistinct> distinctBySyncStamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncStamp');
    });
  }
}

extension LiveChannelQueryProperty
    on QueryBuilder<LiveChannel, LiveChannel, QQueryProperty> {
  QueryBuilder<LiveChannel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<LiveChannel, int, QQueryOperations> addedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'addedAt');
    });
  }

  QueryBuilder<LiveChannel, int, QQueryOperations> catchupDaysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'catchupDays');
    });
  }

  QueryBuilder<LiveChannel, int, QQueryOperations> categoryIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'categoryId');
    });
  }

  QueryBuilder<LiveChannel, String?, QQueryOperations> directSourceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'directSource');
    });
  }

  QueryBuilder<LiveChannel, String?, QQueryOperations> epgChannelIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'epgChannelId');
    });
  }

  QueryBuilder<LiveChannel, bool, QQueryOperations> hasCatchupProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hasCatchup');
    });
  }

  QueryBuilder<LiveChannel, String?, QQueryOperations> iconProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'icon');
    });
  }

  QueryBuilder<LiveChannel, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<LiveChannel, int, QQueryOperations> numberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'number');
    });
  }

  QueryBuilder<LiveChannel, String?, QQueryOperations> remoteIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'remoteId');
    });
  }

  QueryBuilder<LiveChannel, int, QQueryOperations> sortIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sortIndex');
    });
  }

  QueryBuilder<LiveChannel, int, QQueryOperations> syncStampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncStamp');
    });
  }
}
