// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vod_movie.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types, experimental_member_use

extension GetVodMovieCollection on Isar {
  IsarCollection<VodMovie> get movies => this.collection();
}

const VodMovieSchema = CollectionSchema(
  name: r'VodMovie',
  id: 9118621181090945544,
  properties: {
    r'addedAt': PropertySchema(id: 0, name: r'addedAt', type: IsarType.long),
    r'categoryId': PropertySchema(
      id: 1,
      name: r'categoryId',
      type: IsarType.long,
    ),
    r'containerExtension': PropertySchema(
      id: 2,
      name: r'containerExtension',
      type: IsarType.string,
    ),
    r'directSource': PropertySchema(
      id: 3,
      name: r'directSource',
      type: IsarType.string,
    ),
    r'name': PropertySchema(id: 4, name: r'name', type: IsarType.string),
    r'poster': PropertySchema(id: 5, name: r'poster', type: IsarType.string),
    r'rating': PropertySchema(id: 6, name: r'rating', type: IsarType.double),
    r'remoteId': PropertySchema(
      id: 7,
      name: r'remoteId',
      type: IsarType.string,
    ),
    r'sortIndex': PropertySchema(
      id: 8,
      name: r'sortIndex',
      type: IsarType.long,
    ),
    r'syncStamp': PropertySchema(
      id: 9,
      name: r'syncStamp',
      type: IsarType.long,
    ),
  },

  estimateSize: _vodMovieEstimateSize,
  serialize: _vodMovieSerialize,
  deserialize: _vodMovieDeserialize,
  deserializeProp: _vodMovieDeserializeProp,
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
    r'addedAt': IndexSchema(
      id: -8595779697745674092,
      name: r'addedAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'addedAt',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _vodMovieGetId,
  getLinks: _vodMovieGetLinks,
  attach: _vodMovieAttach,
  version: '3.4.1',
);

int _vodMovieEstimateSize(
  VodMovie object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.containerExtension.length * 3;
  {
    final value = object.directSource;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.name.length * 3;
  {
    final value = object.poster;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.remoteId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _vodMovieSerialize(
  VodMovie object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.addedAt);
  writer.writeLong(offsets[1], object.categoryId);
  writer.writeString(offsets[2], object.containerExtension);
  writer.writeString(offsets[3], object.directSource);
  writer.writeString(offsets[4], object.name);
  writer.writeString(offsets[5], object.poster);
  writer.writeDouble(offsets[6], object.rating);
  writer.writeString(offsets[7], object.remoteId);
  writer.writeLong(offsets[8], object.sortIndex);
  writer.writeLong(offsets[9], object.syncStamp);
}

VodMovie _vodMovieDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = VodMovie();
  object.addedAt = reader.readLong(offsets[0]);
  object.categoryId = reader.readLong(offsets[1]);
  object.containerExtension = reader.readString(offsets[2]);
  object.directSource = reader.readStringOrNull(offsets[3]);
  object.id = id;
  object.name = reader.readString(offsets[4]);
  object.poster = reader.readStringOrNull(offsets[5]);
  object.rating = reader.readDouble(offsets[6]);
  object.remoteId = reader.readStringOrNull(offsets[7]);
  object.sortIndex = reader.readLong(offsets[8]);
  object.syncStamp = reader.readLong(offsets[9]);
  return object;
}

P _vodMovieDeserializeProp<P>(
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
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readDouble(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _vodMovieGetId(VodMovie object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _vodMovieGetLinks(VodMovie object) {
  return [];
}

void _vodMovieAttach(IsarCollection<dynamic> col, Id id, VodMovie object) {
  object.id = id;
}

extension VodMovieQueryWhereSort on QueryBuilder<VodMovie, VodMovie, QWhere> {
  QueryBuilder<VodMovie, VodMovie, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterWhere> anyCategoryIdSortIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'categoryId_sortIndex'),
      );
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterWhere> anyAddedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'addedAt'),
      );
    });
  }
}

extension VodMovieQueryWhere on QueryBuilder<VodMovie, VodMovie, QWhereClause> {
  QueryBuilder<VodMovie, VodMovie, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<VodMovie, VodMovie, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterWhereClause> idBetween(
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

  QueryBuilder<VodMovie, VodMovie, QAfterWhereClause>
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

  QueryBuilder<VodMovie, VodMovie, QAfterWhereClause>
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

  QueryBuilder<VodMovie, VodMovie, QAfterWhereClause>
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

  QueryBuilder<VodMovie, VodMovie, QAfterWhereClause>
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

  QueryBuilder<VodMovie, VodMovie, QAfterWhereClause>
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

  QueryBuilder<VodMovie, VodMovie, QAfterWhereClause>
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

  QueryBuilder<VodMovie, VodMovie, QAfterWhereClause>
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

  QueryBuilder<VodMovie, VodMovie, QAfterWhereClause>
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

  QueryBuilder<VodMovie, VodMovie, QAfterWhereClause>
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

  QueryBuilder<VodMovie, VodMovie, QAfterWhereClause>
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

  QueryBuilder<VodMovie, VodMovie, QAfterWhereClause> addedAtEqualTo(
    int addedAt,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'addedAt', value: [addedAt]),
      );
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterWhereClause> addedAtNotEqualTo(
    int addedAt,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'addedAt',
                lower: [],
                upper: [addedAt],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'addedAt',
                lower: [addedAt],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'addedAt',
                lower: [addedAt],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'addedAt',
                lower: [],
                upper: [addedAt],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterWhereClause> addedAtGreaterThan(
    int addedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'addedAt',
          lower: [addedAt],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterWhereClause> addedAtLessThan(
    int addedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'addedAt',
          lower: [],
          upper: [addedAt],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterWhereClause> addedAtBetween(
    int lowerAddedAt,
    int upperAddedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'addedAt',
          lower: [lowerAddedAt],
          includeLower: includeLower,
          upper: [upperAddedAt],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension VodMovieQueryFilter
    on QueryBuilder<VodMovie, VodMovie, QFilterCondition> {
  QueryBuilder<VodMovie, VodMovie, QAfterFilterCondition> addedAtEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'addedAt', value: value),
      );
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterFilterCondition> addedAtGreaterThan(
    int value, {
    bool include = false,
  }) {
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

  QueryBuilder<VodMovie, VodMovie, QAfterFilterCondition> addedAtLessThan(
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

  QueryBuilder<VodMovie, VodMovie, QAfterFilterCondition> addedAtBetween(
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

  QueryBuilder<VodMovie, VodMovie, QAfterFilterCondition> categoryIdEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'categoryId', value: value),
      );
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterFilterCondition> categoryIdGreaterThan(
    int value, {
    bool include = false,
  }) {
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

  QueryBuilder<VodMovie, VodMovie, QAfterFilterCondition> categoryIdLessThan(
    int value, {
    bool include = false,
  }) {
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

  QueryBuilder<VodMovie, VodMovie, QAfterFilterCondition> categoryIdBetween(
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

  QueryBuilder<VodMovie, VodMovie, QAfterFilterCondition>
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

  QueryBuilder<VodMovie, VodMovie, QAfterFilterCondition>
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

  QueryBuilder<VodMovie, VodMovie, QAfterFilterCondition>
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

  QueryBuilder<VodMovie, VodMovie, QAfterFilterCondition>
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

  QueryBuilder<VodMovie, VodMovie, QAfterFilterCondition>
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

  QueryBuilder<VodMovie, VodMovie, QAfterFilterCondition>
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

  QueryBuilder<VodMovie, VodMovie, QAfterFilterCondition>
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

  QueryBuilder<VodMovie, VodMovie, QAfterFilterCondition>
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

  QueryBuilder<VodMovie, VodMovie, QAfterFilterCondition>
  containerExtensionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'containerExtension', value: ''),
      );
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterFilterCondition>
  containerExtensionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'containerExtension', value: ''),
      );
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterFilterCondition> directSourceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'directSource'),
      );
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterFilterCondition>
  directSourceIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'directSource'),
      );
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterFilterCondition> directSourceEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<VodMovie, VodMovie, QAfterFilterCondition>
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

  QueryBuilder<VodMovie, VodMovie, QAfterFilterCondition> directSourceLessThan(
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

  QueryBuilder<VodMovie, VodMovie, QAfterFilterCondition> directSourceBetween(
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

  QueryBuilder<VodMovie, VodMovie, QAfterFilterCondition>
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

  QueryBuilder<VodMovie, VodMovie, QAfterFilterCondition> directSourceEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<VodMovie, VodMovie, QAfterFilterCondition> directSourceContains(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<VodMovie, VodMovie, QAfterFilterCondition> directSourceMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<VodMovie, VodMovie, QAfterFilterCondition>
  directSourceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'directSource', value: ''),
      );
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterFilterCondition>
  directSourceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'directSource', value: ''),
      );
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<VodMovie, VodMovie, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<VodMovie, VodMovie, QAfterFilterCondition> idBetween(
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

  QueryBuilder<VodMovie, VodMovie, QAfterFilterCondition> nameEqualTo(
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

  QueryBuilder<VodMovie, VodMovie, QAfterFilterCondition> nameGreaterThan(
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

  QueryBuilder<VodMovie, VodMovie, QAfterFilterCondition> nameLessThan(
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

  QueryBuilder<VodMovie, VodMovie, QAfterFilterCondition> nameBetween(
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

  QueryBuilder<VodMovie, VodMovie, QAfterFilterCondition> nameStartsWith(
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

  QueryBuilder<VodMovie, VodMovie, QAfterFilterCondition> nameEndsWith(
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

  QueryBuilder<VodMovie, VodMovie, QAfterFilterCondition> nameContains(
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

  QueryBuilder<VodMovie, VodMovie, QAfterFilterCondition> nameMatches(
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

  QueryBuilder<VodMovie, VodMovie, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterFilterCondition> posterIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'poster'),
      );
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterFilterCondition> posterIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'poster'),
      );
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterFilterCondition> posterEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'poster',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterFilterCondition> posterGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'poster',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterFilterCondition> posterLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'poster',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterFilterCondition> posterBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'poster',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterFilterCondition> posterStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'poster',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterFilterCondition> posterEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'poster',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterFilterCondition> posterContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'poster',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterFilterCondition> posterMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'poster',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterFilterCondition> posterIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'poster', value: ''),
      );
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterFilterCondition> posterIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'poster', value: ''),
      );
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterFilterCondition> ratingEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'rating',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterFilterCondition> ratingGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'rating',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterFilterCondition> ratingLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'rating',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterFilterCondition> ratingBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'rating',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterFilterCondition> remoteIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'remoteId'),
      );
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterFilterCondition> remoteIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'remoteId'),
      );
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterFilterCondition> remoteIdEqualTo(
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

  QueryBuilder<VodMovie, VodMovie, QAfterFilterCondition> remoteIdGreaterThan(
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

  QueryBuilder<VodMovie, VodMovie, QAfterFilterCondition> remoteIdLessThan(
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

  QueryBuilder<VodMovie, VodMovie, QAfterFilterCondition> remoteIdBetween(
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

  QueryBuilder<VodMovie, VodMovie, QAfterFilterCondition> remoteIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<VodMovie, VodMovie, QAfterFilterCondition> remoteIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<VodMovie, VodMovie, QAfterFilterCondition> remoteIdContains(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<VodMovie, VodMovie, QAfterFilterCondition> remoteIdMatches(
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

  QueryBuilder<VodMovie, VodMovie, QAfterFilterCondition> remoteIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'remoteId', value: ''),
      );
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterFilterCondition> remoteIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'remoteId', value: ''),
      );
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterFilterCondition> sortIndexEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'sortIndex', value: value),
      );
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterFilterCondition> sortIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
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

  QueryBuilder<VodMovie, VodMovie, QAfterFilterCondition> sortIndexLessThan(
    int value, {
    bool include = false,
  }) {
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

  QueryBuilder<VodMovie, VodMovie, QAfterFilterCondition> sortIndexBetween(
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

  QueryBuilder<VodMovie, VodMovie, QAfterFilterCondition> syncStampEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'syncStamp', value: value),
      );
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterFilterCondition> syncStampGreaterThan(
    int value, {
    bool include = false,
  }) {
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

  QueryBuilder<VodMovie, VodMovie, QAfterFilterCondition> syncStampLessThan(
    int value, {
    bool include = false,
  }) {
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

  QueryBuilder<VodMovie, VodMovie, QAfterFilterCondition> syncStampBetween(
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

extension VodMovieQueryObject
    on QueryBuilder<VodMovie, VodMovie, QFilterCondition> {}

extension VodMovieQueryLinks
    on QueryBuilder<VodMovie, VodMovie, QFilterCondition> {}

extension VodMovieQuerySortBy on QueryBuilder<VodMovie, VodMovie, QSortBy> {
  QueryBuilder<VodMovie, VodMovie, QAfterSortBy> sortByAddedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addedAt', Sort.asc);
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterSortBy> sortByAddedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addedAt', Sort.desc);
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterSortBy> sortByCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.asc);
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterSortBy> sortByCategoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.desc);
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterSortBy> sortByContainerExtension() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'containerExtension', Sort.asc);
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterSortBy>
  sortByContainerExtensionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'containerExtension', Sort.desc);
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterSortBy> sortByDirectSource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'directSource', Sort.asc);
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterSortBy> sortByDirectSourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'directSource', Sort.desc);
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterSortBy> sortByPoster() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'poster', Sort.asc);
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterSortBy> sortByPosterDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'poster', Sort.desc);
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterSortBy> sortByRating() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rating', Sort.asc);
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterSortBy> sortByRatingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rating', Sort.desc);
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterSortBy> sortByRemoteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.asc);
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterSortBy> sortByRemoteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.desc);
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterSortBy> sortBySortIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortIndex', Sort.asc);
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterSortBy> sortBySortIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortIndex', Sort.desc);
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterSortBy> sortBySyncStamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStamp', Sort.asc);
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterSortBy> sortBySyncStampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStamp', Sort.desc);
    });
  }
}

extension VodMovieQuerySortThenBy
    on QueryBuilder<VodMovie, VodMovie, QSortThenBy> {
  QueryBuilder<VodMovie, VodMovie, QAfterSortBy> thenByAddedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addedAt', Sort.asc);
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterSortBy> thenByAddedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addedAt', Sort.desc);
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterSortBy> thenByCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.asc);
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterSortBy> thenByCategoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.desc);
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterSortBy> thenByContainerExtension() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'containerExtension', Sort.asc);
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterSortBy>
  thenByContainerExtensionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'containerExtension', Sort.desc);
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterSortBy> thenByDirectSource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'directSource', Sort.asc);
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterSortBy> thenByDirectSourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'directSource', Sort.desc);
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterSortBy> thenByPoster() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'poster', Sort.asc);
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterSortBy> thenByPosterDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'poster', Sort.desc);
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterSortBy> thenByRating() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rating', Sort.asc);
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterSortBy> thenByRatingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rating', Sort.desc);
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterSortBy> thenByRemoteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.asc);
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterSortBy> thenByRemoteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.desc);
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterSortBy> thenBySortIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortIndex', Sort.asc);
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterSortBy> thenBySortIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortIndex', Sort.desc);
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterSortBy> thenBySyncStamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStamp', Sort.asc);
    });
  }

  QueryBuilder<VodMovie, VodMovie, QAfterSortBy> thenBySyncStampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStamp', Sort.desc);
    });
  }
}

extension VodMovieQueryWhereDistinct
    on QueryBuilder<VodMovie, VodMovie, QDistinct> {
  QueryBuilder<VodMovie, VodMovie, QDistinct> distinctByAddedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'addedAt');
    });
  }

  QueryBuilder<VodMovie, VodMovie, QDistinct> distinctByCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'categoryId');
    });
  }

  QueryBuilder<VodMovie, VodMovie, QDistinct> distinctByContainerExtension({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'containerExtension',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<VodMovie, VodMovie, QDistinct> distinctByDirectSource({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'directSource', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VodMovie, VodMovie, QDistinct> distinctByName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VodMovie, VodMovie, QDistinct> distinctByPoster({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'poster', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VodMovie, VodMovie, QDistinct> distinctByRating() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rating');
    });
  }

  QueryBuilder<VodMovie, VodMovie, QDistinct> distinctByRemoteId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'remoteId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VodMovie, VodMovie, QDistinct> distinctBySortIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sortIndex');
    });
  }

  QueryBuilder<VodMovie, VodMovie, QDistinct> distinctBySyncStamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncStamp');
    });
  }
}

extension VodMovieQueryProperty
    on QueryBuilder<VodMovie, VodMovie, QQueryProperty> {
  QueryBuilder<VodMovie, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<VodMovie, int, QQueryOperations> addedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'addedAt');
    });
  }

  QueryBuilder<VodMovie, int, QQueryOperations> categoryIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'categoryId');
    });
  }

  QueryBuilder<VodMovie, String, QQueryOperations>
  containerExtensionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'containerExtension');
    });
  }

  QueryBuilder<VodMovie, String?, QQueryOperations> directSourceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'directSource');
    });
  }

  QueryBuilder<VodMovie, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<VodMovie, String?, QQueryOperations> posterProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'poster');
    });
  }

  QueryBuilder<VodMovie, double, QQueryOperations> ratingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rating');
    });
  }

  QueryBuilder<VodMovie, String?, QQueryOperations> remoteIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'remoteId');
    });
  }

  QueryBuilder<VodMovie, int, QQueryOperations> sortIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sortIndex');
    });
  }

  QueryBuilder<VodMovie, int, QQueryOperations> syncStampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncStamp');
    });
  }
}
