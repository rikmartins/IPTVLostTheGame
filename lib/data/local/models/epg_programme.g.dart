// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'epg_programme.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types, experimental_member_use

extension GetEpgProgrammeCollection on Isar {
  IsarCollection<EpgProgramme> get epgProgrammes => this.collection();
}

const EpgProgrammeSchema = CollectionSchema(
  name: r'EpgProgramme',
  id: -5271680722953553897,
  properties: {
    r'channelKey': PropertySchema(
      id: 0,
      name: r'channelKey',
      type: IsarType.long,
    ),
    r'description': PropertySchema(
      id: 1,
      name: r'description',
      type: IsarType.string,
    ),
    r'start': PropertySchema(id: 2, name: r'start', type: IsarType.dateTime),
    r'stop': PropertySchema(id: 3, name: r'stop', type: IsarType.dateTime),
    r'syncStamp': PropertySchema(
      id: 4,
      name: r'syncStamp',
      type: IsarType.long,
    ),
    r'title': PropertySchema(id: 5, name: r'title', type: IsarType.string),
  },

  estimateSize: _epgProgrammeEstimateSize,
  serialize: _epgProgrammeSerialize,
  deserialize: _epgProgrammeDeserialize,
  deserializeProp: _epgProgrammeDeserializeProp,
  idName: r'id',
  indexes: {
    r'channelKey_start': IndexSchema(
      id: 154841890887254321,
      name: r'channelKey_start',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'channelKey',
          type: IndexType.value,
          caseSensitive: false,
        ),
        IndexPropertySchema(
          name: r'start',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _epgProgrammeGetId,
  getLinks: _epgProgrammeGetLinks,
  attach: _epgProgrammeAttach,
  version: '3.4.1',
);

int _epgProgrammeEstimateSize(
  EpgProgramme object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.description;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.title.length * 3;
  return bytesCount;
}

void _epgProgrammeSerialize(
  EpgProgramme object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.channelKey);
  writer.writeString(offsets[1], object.description);
  writer.writeDateTime(offsets[2], object.start);
  writer.writeDateTime(offsets[3], object.stop);
  writer.writeLong(offsets[4], object.syncStamp);
  writer.writeString(offsets[5], object.title);
}

EpgProgramme _epgProgrammeDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = EpgProgramme();
  object.channelKey = reader.readLong(offsets[0]);
  object.description = reader.readStringOrNull(offsets[1]);
  object.id = id;
  object.start = reader.readDateTime(offsets[2]);
  object.stop = reader.readDateTime(offsets[3]);
  object.syncStamp = reader.readLong(offsets[4]);
  object.title = reader.readString(offsets[5]);
  return object;
}

P _epgProgrammeDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _epgProgrammeGetId(EpgProgramme object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _epgProgrammeGetLinks(EpgProgramme object) {
  return [];
}

void _epgProgrammeAttach(
  IsarCollection<dynamic> col,
  Id id,
  EpgProgramme object,
) {
  object.id = id;
}

extension EpgProgrammeQueryWhereSort
    on QueryBuilder<EpgProgramme, EpgProgramme, QWhere> {
  QueryBuilder<EpgProgramme, EpgProgramme, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<EpgProgramme, EpgProgramme, QAfterWhere> anyChannelKeyStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'channelKey_start'),
      );
    });
  }
}

extension EpgProgrammeQueryWhere
    on QueryBuilder<EpgProgramme, EpgProgramme, QWhereClause> {
  QueryBuilder<EpgProgramme, EpgProgramme, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<EpgProgramme, EpgProgramme, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<EpgProgramme, EpgProgramme, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<EpgProgramme, EpgProgramme, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<EpgProgramme, EpgProgramme, QAfterWhereClause> idBetween(
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

  QueryBuilder<EpgProgramme, EpgProgramme, QAfterWhereClause>
  channelKeyEqualToAnyStart(int channelKey) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'channelKey_start',
          value: [channelKey],
        ),
      );
    });
  }

  QueryBuilder<EpgProgramme, EpgProgramme, QAfterWhereClause>
  channelKeyNotEqualToAnyStart(int channelKey) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'channelKey_start',
                lower: [],
                upper: [channelKey],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'channelKey_start',
                lower: [channelKey],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'channelKey_start',
                lower: [channelKey],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'channelKey_start',
                lower: [],
                upper: [channelKey],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<EpgProgramme, EpgProgramme, QAfterWhereClause>
  channelKeyGreaterThanAnyStart(int channelKey, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'channelKey_start',
          lower: [channelKey],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<EpgProgramme, EpgProgramme, QAfterWhereClause>
  channelKeyLessThanAnyStart(int channelKey, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'channelKey_start',
          lower: [],
          upper: [channelKey],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<EpgProgramme, EpgProgramme, QAfterWhereClause>
  channelKeyBetweenAnyStart(
    int lowerChannelKey,
    int upperChannelKey, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'channelKey_start',
          lower: [lowerChannelKey],
          includeLower: includeLower,
          upper: [upperChannelKey],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<EpgProgramme, EpgProgramme, QAfterWhereClause>
  channelKeyStartEqualTo(int channelKey, DateTime start) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'channelKey_start',
          value: [channelKey, start],
        ),
      );
    });
  }

  QueryBuilder<EpgProgramme, EpgProgramme, QAfterWhereClause>
  channelKeyEqualToStartNotEqualTo(int channelKey, DateTime start) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'channelKey_start',
                lower: [channelKey],
                upper: [channelKey, start],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'channelKey_start',
                lower: [channelKey, start],
                includeLower: false,
                upper: [channelKey],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'channelKey_start',
                lower: [channelKey, start],
                includeLower: false,
                upper: [channelKey],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'channelKey_start',
                lower: [channelKey],
                upper: [channelKey, start],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<EpgProgramme, EpgProgramme, QAfterWhereClause>
  channelKeyEqualToStartGreaterThan(
    int channelKey,
    DateTime start, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'channelKey_start',
          lower: [channelKey, start],
          includeLower: include,
          upper: [channelKey],
        ),
      );
    });
  }

  QueryBuilder<EpgProgramme, EpgProgramme, QAfterWhereClause>
  channelKeyEqualToStartLessThan(
    int channelKey,
    DateTime start, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'channelKey_start',
          lower: [channelKey],
          upper: [channelKey, start],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<EpgProgramme, EpgProgramme, QAfterWhereClause>
  channelKeyEqualToStartBetween(
    int channelKey,
    DateTime lowerStart,
    DateTime upperStart, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'channelKey_start',
          lower: [channelKey, lowerStart],
          includeLower: includeLower,
          upper: [channelKey, upperStart],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension EpgProgrammeQueryFilter
    on QueryBuilder<EpgProgramme, EpgProgramme, QFilterCondition> {
  QueryBuilder<EpgProgramme, EpgProgramme, QAfterFilterCondition>
  channelKeyEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'channelKey', value: value),
      );
    });
  }

  QueryBuilder<EpgProgramme, EpgProgramme, QAfterFilterCondition>
  channelKeyGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'channelKey',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EpgProgramme, EpgProgramme, QAfterFilterCondition>
  channelKeyLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'channelKey',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EpgProgramme, EpgProgramme, QAfterFilterCondition>
  channelKeyBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'channelKey',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<EpgProgramme, EpgProgramme, QAfterFilterCondition>
  descriptionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'description'),
      );
    });
  }

  QueryBuilder<EpgProgramme, EpgProgramme, QAfterFilterCondition>
  descriptionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'description'),
      );
    });
  }

  QueryBuilder<EpgProgramme, EpgProgramme, QAfterFilterCondition>
  descriptionEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpgProgramme, EpgProgramme, QAfterFilterCondition>
  descriptionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpgProgramme, EpgProgramme, QAfterFilterCondition>
  descriptionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpgProgramme, EpgProgramme, QAfterFilterCondition>
  descriptionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'description',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpgProgramme, EpgProgramme, QAfterFilterCondition>
  descriptionStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpgProgramme, EpgProgramme, QAfterFilterCondition>
  descriptionEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpgProgramme, EpgProgramme, QAfterFilterCondition>
  descriptionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpgProgramme, EpgProgramme, QAfterFilterCondition>
  descriptionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'description',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpgProgramme, EpgProgramme, QAfterFilterCondition>
  descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'description', value: ''),
      );
    });
  }

  QueryBuilder<EpgProgramme, EpgProgramme, QAfterFilterCondition>
  descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'description', value: ''),
      );
    });
  }

  QueryBuilder<EpgProgramme, EpgProgramme, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<EpgProgramme, EpgProgramme, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<EpgProgramme, EpgProgramme, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<EpgProgramme, EpgProgramme, QAfterFilterCondition> idBetween(
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

  QueryBuilder<EpgProgramme, EpgProgramme, QAfterFilterCondition> startEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'start', value: value),
      );
    });
  }

  QueryBuilder<EpgProgramme, EpgProgramme, QAfterFilterCondition>
  startGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'start',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EpgProgramme, EpgProgramme, QAfterFilterCondition> startLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'start',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EpgProgramme, EpgProgramme, QAfterFilterCondition> startBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'start',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<EpgProgramme, EpgProgramme, QAfterFilterCondition> stopEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'stop', value: value),
      );
    });
  }

  QueryBuilder<EpgProgramme, EpgProgramme, QAfterFilterCondition>
  stopGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'stop',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EpgProgramme, EpgProgramme, QAfterFilterCondition> stopLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'stop',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EpgProgramme, EpgProgramme, QAfterFilterCondition> stopBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'stop',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<EpgProgramme, EpgProgramme, QAfterFilterCondition>
  syncStampEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'syncStamp', value: value),
      );
    });
  }

  QueryBuilder<EpgProgramme, EpgProgramme, QAfterFilterCondition>
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

  QueryBuilder<EpgProgramme, EpgProgramme, QAfterFilterCondition>
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

  QueryBuilder<EpgProgramme, EpgProgramme, QAfterFilterCondition>
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

  QueryBuilder<EpgProgramme, EpgProgramme, QAfterFilterCondition> titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<EpgProgramme, EpgProgramme, QAfterFilterCondition>
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

  QueryBuilder<EpgProgramme, EpgProgramme, QAfterFilterCondition> titleLessThan(
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

  QueryBuilder<EpgProgramme, EpgProgramme, QAfterFilterCondition> titleBetween(
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

  QueryBuilder<EpgProgramme, EpgProgramme, QAfterFilterCondition>
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

  QueryBuilder<EpgProgramme, EpgProgramme, QAfterFilterCondition> titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<EpgProgramme, EpgProgramme, QAfterFilterCondition> titleContains(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<EpgProgramme, EpgProgramme, QAfterFilterCondition> titleMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<EpgProgramme, EpgProgramme, QAfterFilterCondition>
  titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'title', value: ''),
      );
    });
  }

  QueryBuilder<EpgProgramme, EpgProgramme, QAfterFilterCondition>
  titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'title', value: ''),
      );
    });
  }
}

extension EpgProgrammeQueryObject
    on QueryBuilder<EpgProgramme, EpgProgramme, QFilterCondition> {}

extension EpgProgrammeQueryLinks
    on QueryBuilder<EpgProgramme, EpgProgramme, QFilterCondition> {}

extension EpgProgrammeQuerySortBy
    on QueryBuilder<EpgProgramme, EpgProgramme, QSortBy> {
  QueryBuilder<EpgProgramme, EpgProgramme, QAfterSortBy> sortByChannelKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'channelKey', Sort.asc);
    });
  }

  QueryBuilder<EpgProgramme, EpgProgramme, QAfterSortBy>
  sortByChannelKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'channelKey', Sort.desc);
    });
  }

  QueryBuilder<EpgProgramme, EpgProgramme, QAfterSortBy> sortByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<EpgProgramme, EpgProgramme, QAfterSortBy>
  sortByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<EpgProgramme, EpgProgramme, QAfterSortBy> sortByStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'start', Sort.asc);
    });
  }

  QueryBuilder<EpgProgramme, EpgProgramme, QAfterSortBy> sortByStartDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'start', Sort.desc);
    });
  }

  QueryBuilder<EpgProgramme, EpgProgramme, QAfterSortBy> sortByStop() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stop', Sort.asc);
    });
  }

  QueryBuilder<EpgProgramme, EpgProgramme, QAfterSortBy> sortByStopDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stop', Sort.desc);
    });
  }

  QueryBuilder<EpgProgramme, EpgProgramme, QAfterSortBy> sortBySyncStamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStamp', Sort.asc);
    });
  }

  QueryBuilder<EpgProgramme, EpgProgramme, QAfterSortBy> sortBySyncStampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStamp', Sort.desc);
    });
  }

  QueryBuilder<EpgProgramme, EpgProgramme, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<EpgProgramme, EpgProgramme, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }
}

extension EpgProgrammeQuerySortThenBy
    on QueryBuilder<EpgProgramme, EpgProgramme, QSortThenBy> {
  QueryBuilder<EpgProgramme, EpgProgramme, QAfterSortBy> thenByChannelKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'channelKey', Sort.asc);
    });
  }

  QueryBuilder<EpgProgramme, EpgProgramme, QAfterSortBy>
  thenByChannelKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'channelKey', Sort.desc);
    });
  }

  QueryBuilder<EpgProgramme, EpgProgramme, QAfterSortBy> thenByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<EpgProgramme, EpgProgramme, QAfterSortBy>
  thenByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<EpgProgramme, EpgProgramme, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<EpgProgramme, EpgProgramme, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<EpgProgramme, EpgProgramme, QAfterSortBy> thenByStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'start', Sort.asc);
    });
  }

  QueryBuilder<EpgProgramme, EpgProgramme, QAfterSortBy> thenByStartDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'start', Sort.desc);
    });
  }

  QueryBuilder<EpgProgramme, EpgProgramme, QAfterSortBy> thenByStop() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stop', Sort.asc);
    });
  }

  QueryBuilder<EpgProgramme, EpgProgramme, QAfterSortBy> thenByStopDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stop', Sort.desc);
    });
  }

  QueryBuilder<EpgProgramme, EpgProgramme, QAfterSortBy> thenBySyncStamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStamp', Sort.asc);
    });
  }

  QueryBuilder<EpgProgramme, EpgProgramme, QAfterSortBy> thenBySyncStampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStamp', Sort.desc);
    });
  }

  QueryBuilder<EpgProgramme, EpgProgramme, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<EpgProgramme, EpgProgramme, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }
}

extension EpgProgrammeQueryWhereDistinct
    on QueryBuilder<EpgProgramme, EpgProgramme, QDistinct> {
  QueryBuilder<EpgProgramme, EpgProgramme, QDistinct> distinctByChannelKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'channelKey');
    });
  }

  QueryBuilder<EpgProgramme, EpgProgramme, QDistinct> distinctByDescription({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'description', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EpgProgramme, EpgProgramme, QDistinct> distinctByStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'start');
    });
  }

  QueryBuilder<EpgProgramme, EpgProgramme, QDistinct> distinctByStop() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stop');
    });
  }

  QueryBuilder<EpgProgramme, EpgProgramme, QDistinct> distinctBySyncStamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncStamp');
    });
  }

  QueryBuilder<EpgProgramme, EpgProgramme, QDistinct> distinctByTitle({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }
}

extension EpgProgrammeQueryProperty
    on QueryBuilder<EpgProgramme, EpgProgramme, QQueryProperty> {
  QueryBuilder<EpgProgramme, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<EpgProgramme, int, QQueryOperations> channelKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'channelKey');
    });
  }

  QueryBuilder<EpgProgramme, String?, QQueryOperations> descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'description');
    });
  }

  QueryBuilder<EpgProgramme, DateTime, QQueryOperations> startProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'start');
    });
  }

  QueryBuilder<EpgProgramme, DateTime, QQueryOperations> stopProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stop');
    });
  }

  QueryBuilder<EpgProgramme, int, QQueryOperations> syncStampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncStamp');
    });
  }

  QueryBuilder<EpgProgramme, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }
}
