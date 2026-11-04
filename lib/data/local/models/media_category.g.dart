// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_category.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types, experimental_member_use

extension GetMediaCategoryCollection on Isar {
  IsarCollection<MediaCategory> get categories => this.collection();
}

const MediaCategorySchema = CollectionSchema(
  name: r'MediaCategory',
  id: -3808555923787788769,
  properties: {
    r'categoryId': PropertySchema(
      id: 0,
      name: r'categoryId',
      type: IsarType.long,
    ),
    r'name': PropertySchema(id: 1, name: r'name', type: IsarType.string),
    r'parentId': PropertySchema(id: 2, name: r'parentId', type: IsarType.long),
    r'sortIndex': PropertySchema(
      id: 3,
      name: r'sortIndex',
      type: IsarType.long,
    ),
    r'syncStamp': PropertySchema(
      id: 4,
      name: r'syncStamp',
      type: IsarType.long,
    ),
    r'type': PropertySchema(
      id: 5,
      name: r'type',
      type: IsarType.byte,
      enumMap: _MediaCategorytypeEnumValueMap,
    ),
  },

  estimateSize: _mediaCategoryEstimateSize,
  serialize: _mediaCategorySerialize,
  deserialize: _mediaCategoryDeserialize,
  deserializeProp: _mediaCategoryDeserializeProp,
  idName: r'id',
  indexes: {
    r'type_sortIndex': IndexSchema(
      id: -8625428520318542717,
      name: r'type_sortIndex',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'type',
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

  getId: _mediaCategoryGetId,
  getLinks: _mediaCategoryGetLinks,
  attach: _mediaCategoryAttach,
  version: '3.4.1',
);

int _mediaCategoryEstimateSize(
  MediaCategory object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.name.length * 3;
  return bytesCount;
}

void _mediaCategorySerialize(
  MediaCategory object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.categoryId);
  writer.writeString(offsets[1], object.name);
  writer.writeLong(offsets[2], object.parentId);
  writer.writeLong(offsets[3], object.sortIndex);
  writer.writeLong(offsets[4], object.syncStamp);
  writer.writeByte(offsets[5], object.type.index);
}

MediaCategory _mediaCategoryDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MediaCategory();
  object.categoryId = reader.readLong(offsets[0]);
  object.id = id;
  object.name = reader.readString(offsets[1]);
  object.parentId = reader.readLong(offsets[2]);
  object.sortIndex = reader.readLong(offsets[3]);
  object.syncStamp = reader.readLong(offsets[4]);
  object.type =
      _MediaCategorytypeValueEnumMap[reader.readByteOrNull(offsets[5])] ??
      CategoryType.live;
  return object;
}

P _mediaCategoryDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (_MediaCategorytypeValueEnumMap[reader.readByteOrNull(offset)] ??
              CategoryType.live)
          as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _MediaCategorytypeEnumValueMap = {'live': 0, 'movie': 1, 'series': 2};
const _MediaCategorytypeValueEnumMap = {
  0: CategoryType.live,
  1: CategoryType.movie,
  2: CategoryType.series,
};

Id _mediaCategoryGetId(MediaCategory object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _mediaCategoryGetLinks(MediaCategory object) {
  return [];
}

void _mediaCategoryAttach(
  IsarCollection<dynamic> col,
  Id id,
  MediaCategory object,
) {
  object.id = id;
}

extension MediaCategoryQueryWhereSort
    on QueryBuilder<MediaCategory, MediaCategory, QWhere> {
  QueryBuilder<MediaCategory, MediaCategory, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<MediaCategory, MediaCategory, QAfterWhere> anyTypeSortIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'type_sortIndex'),
      );
    });
  }
}

extension MediaCategoryQueryWhere
    on QueryBuilder<MediaCategory, MediaCategory, QWhereClause> {
  QueryBuilder<MediaCategory, MediaCategory, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<MediaCategory, MediaCategory, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<MediaCategory, MediaCategory, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<MediaCategory, MediaCategory, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<MediaCategory, MediaCategory, QAfterWhereClause> idBetween(
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

  QueryBuilder<MediaCategory, MediaCategory, QAfterWhereClause>
  typeEqualToAnySortIndex(CategoryType type) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'type_sortIndex', value: [type]),
      );
    });
  }

  QueryBuilder<MediaCategory, MediaCategory, QAfterWhereClause>
  typeNotEqualToAnySortIndex(CategoryType type) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'type_sortIndex',
                lower: [],
                upper: [type],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'type_sortIndex',
                lower: [type],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'type_sortIndex',
                lower: [type],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'type_sortIndex',
                lower: [],
                upper: [type],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<MediaCategory, MediaCategory, QAfterWhereClause>
  typeGreaterThanAnySortIndex(CategoryType type, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'type_sortIndex',
          lower: [type],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<MediaCategory, MediaCategory, QAfterWhereClause>
  typeLessThanAnySortIndex(CategoryType type, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'type_sortIndex',
          lower: [],
          upper: [type],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<MediaCategory, MediaCategory, QAfterWhereClause>
  typeBetweenAnySortIndex(
    CategoryType lowerType,
    CategoryType upperType, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'type_sortIndex',
          lower: [lowerType],
          includeLower: includeLower,
          upper: [upperType],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<MediaCategory, MediaCategory, QAfterWhereClause>
  typeSortIndexEqualTo(CategoryType type, int sortIndex) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'type_sortIndex',
          value: [type, sortIndex],
        ),
      );
    });
  }

  QueryBuilder<MediaCategory, MediaCategory, QAfterWhereClause>
  typeEqualToSortIndexNotEqualTo(CategoryType type, int sortIndex) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'type_sortIndex',
                lower: [type],
                upper: [type, sortIndex],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'type_sortIndex',
                lower: [type, sortIndex],
                includeLower: false,
                upper: [type],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'type_sortIndex',
                lower: [type, sortIndex],
                includeLower: false,
                upper: [type],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'type_sortIndex',
                lower: [type],
                upper: [type, sortIndex],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<MediaCategory, MediaCategory, QAfterWhereClause>
  typeEqualToSortIndexGreaterThan(
    CategoryType type,
    int sortIndex, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'type_sortIndex',
          lower: [type, sortIndex],
          includeLower: include,
          upper: [type],
        ),
      );
    });
  }

  QueryBuilder<MediaCategory, MediaCategory, QAfterWhereClause>
  typeEqualToSortIndexLessThan(
    CategoryType type,
    int sortIndex, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'type_sortIndex',
          lower: [type],
          upper: [type, sortIndex],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<MediaCategory, MediaCategory, QAfterWhereClause>
  typeEqualToSortIndexBetween(
    CategoryType type,
    int lowerSortIndex,
    int upperSortIndex, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'type_sortIndex',
          lower: [type, lowerSortIndex],
          includeLower: includeLower,
          upper: [type, upperSortIndex],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension MediaCategoryQueryFilter
    on QueryBuilder<MediaCategory, MediaCategory, QFilterCondition> {
  QueryBuilder<MediaCategory, MediaCategory, QAfterFilterCondition>
  categoryIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'categoryId', value: value),
      );
    });
  }

  QueryBuilder<MediaCategory, MediaCategory, QAfterFilterCondition>
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

  QueryBuilder<MediaCategory, MediaCategory, QAfterFilterCondition>
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

  QueryBuilder<MediaCategory, MediaCategory, QAfterFilterCondition>
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

  QueryBuilder<MediaCategory, MediaCategory, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<MediaCategory, MediaCategory, QAfterFilterCondition>
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

  QueryBuilder<MediaCategory, MediaCategory, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<MediaCategory, MediaCategory, QAfterFilterCondition> idBetween(
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

  QueryBuilder<MediaCategory, MediaCategory, QAfterFilterCondition> nameEqualTo(
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

  QueryBuilder<MediaCategory, MediaCategory, QAfterFilterCondition>
  nameGreaterThan(
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

  QueryBuilder<MediaCategory, MediaCategory, QAfterFilterCondition>
  nameLessThan(
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

  QueryBuilder<MediaCategory, MediaCategory, QAfterFilterCondition> nameBetween(
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

  QueryBuilder<MediaCategory, MediaCategory, QAfterFilterCondition>
  nameStartsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<MediaCategory, MediaCategory, QAfterFilterCondition>
  nameEndsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<MediaCategory, MediaCategory, QAfterFilterCondition>
  nameContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<MediaCategory, MediaCategory, QAfterFilterCondition> nameMatches(
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

  QueryBuilder<MediaCategory, MediaCategory, QAfterFilterCondition>
  nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<MediaCategory, MediaCategory, QAfterFilterCondition>
  nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<MediaCategory, MediaCategory, QAfterFilterCondition>
  parentIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'parentId', value: value),
      );
    });
  }

  QueryBuilder<MediaCategory, MediaCategory, QAfterFilterCondition>
  parentIdGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'parentId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MediaCategory, MediaCategory, QAfterFilterCondition>
  parentIdLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'parentId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MediaCategory, MediaCategory, QAfterFilterCondition>
  parentIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'parentId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<MediaCategory, MediaCategory, QAfterFilterCondition>
  sortIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'sortIndex', value: value),
      );
    });
  }

  QueryBuilder<MediaCategory, MediaCategory, QAfterFilterCondition>
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

  QueryBuilder<MediaCategory, MediaCategory, QAfterFilterCondition>
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

  QueryBuilder<MediaCategory, MediaCategory, QAfterFilterCondition>
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

  QueryBuilder<MediaCategory, MediaCategory, QAfterFilterCondition>
  syncStampEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'syncStamp', value: value),
      );
    });
  }

  QueryBuilder<MediaCategory, MediaCategory, QAfterFilterCondition>
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

  QueryBuilder<MediaCategory, MediaCategory, QAfterFilterCondition>
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

  QueryBuilder<MediaCategory, MediaCategory, QAfterFilterCondition>
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

  QueryBuilder<MediaCategory, MediaCategory, QAfterFilterCondition> typeEqualTo(
    CategoryType value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'type', value: value),
      );
    });
  }

  QueryBuilder<MediaCategory, MediaCategory, QAfterFilterCondition>
  typeGreaterThan(CategoryType value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'type',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MediaCategory, MediaCategory, QAfterFilterCondition>
  typeLessThan(CategoryType value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'type',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MediaCategory, MediaCategory, QAfterFilterCondition> typeBetween(
    CategoryType lower,
    CategoryType upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'type',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension MediaCategoryQueryObject
    on QueryBuilder<MediaCategory, MediaCategory, QFilterCondition> {}

extension MediaCategoryQueryLinks
    on QueryBuilder<MediaCategory, MediaCategory, QFilterCondition> {}

extension MediaCategoryQuerySortBy
    on QueryBuilder<MediaCategory, MediaCategory, QSortBy> {
  QueryBuilder<MediaCategory, MediaCategory, QAfterSortBy> sortByCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.asc);
    });
  }

  QueryBuilder<MediaCategory, MediaCategory, QAfterSortBy>
  sortByCategoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.desc);
    });
  }

  QueryBuilder<MediaCategory, MediaCategory, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<MediaCategory, MediaCategory, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<MediaCategory, MediaCategory, QAfterSortBy> sortByParentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentId', Sort.asc);
    });
  }

  QueryBuilder<MediaCategory, MediaCategory, QAfterSortBy>
  sortByParentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentId', Sort.desc);
    });
  }

  QueryBuilder<MediaCategory, MediaCategory, QAfterSortBy> sortBySortIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortIndex', Sort.asc);
    });
  }

  QueryBuilder<MediaCategory, MediaCategory, QAfterSortBy>
  sortBySortIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortIndex', Sort.desc);
    });
  }

  QueryBuilder<MediaCategory, MediaCategory, QAfterSortBy> sortBySyncStamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStamp', Sort.asc);
    });
  }

  QueryBuilder<MediaCategory, MediaCategory, QAfterSortBy>
  sortBySyncStampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStamp', Sort.desc);
    });
  }

  QueryBuilder<MediaCategory, MediaCategory, QAfterSortBy> sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<MediaCategory, MediaCategory, QAfterSortBy> sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension MediaCategoryQuerySortThenBy
    on QueryBuilder<MediaCategory, MediaCategory, QSortThenBy> {
  QueryBuilder<MediaCategory, MediaCategory, QAfterSortBy> thenByCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.asc);
    });
  }

  QueryBuilder<MediaCategory, MediaCategory, QAfterSortBy>
  thenByCategoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.desc);
    });
  }

  QueryBuilder<MediaCategory, MediaCategory, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MediaCategory, MediaCategory, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MediaCategory, MediaCategory, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<MediaCategory, MediaCategory, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<MediaCategory, MediaCategory, QAfterSortBy> thenByParentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentId', Sort.asc);
    });
  }

  QueryBuilder<MediaCategory, MediaCategory, QAfterSortBy>
  thenByParentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentId', Sort.desc);
    });
  }

  QueryBuilder<MediaCategory, MediaCategory, QAfterSortBy> thenBySortIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortIndex', Sort.asc);
    });
  }

  QueryBuilder<MediaCategory, MediaCategory, QAfterSortBy>
  thenBySortIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortIndex', Sort.desc);
    });
  }

  QueryBuilder<MediaCategory, MediaCategory, QAfterSortBy> thenBySyncStamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStamp', Sort.asc);
    });
  }

  QueryBuilder<MediaCategory, MediaCategory, QAfterSortBy>
  thenBySyncStampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStamp', Sort.desc);
    });
  }

  QueryBuilder<MediaCategory, MediaCategory, QAfterSortBy> thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<MediaCategory, MediaCategory, QAfterSortBy> thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension MediaCategoryQueryWhereDistinct
    on QueryBuilder<MediaCategory, MediaCategory, QDistinct> {
  QueryBuilder<MediaCategory, MediaCategory, QDistinct> distinctByCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'categoryId');
    });
  }

  QueryBuilder<MediaCategory, MediaCategory, QDistinct> distinctByName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MediaCategory, MediaCategory, QDistinct> distinctByParentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'parentId');
    });
  }

  QueryBuilder<MediaCategory, MediaCategory, QDistinct> distinctBySortIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sortIndex');
    });
  }

  QueryBuilder<MediaCategory, MediaCategory, QDistinct> distinctBySyncStamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncStamp');
    });
  }

  QueryBuilder<MediaCategory, MediaCategory, QDistinct> distinctByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type');
    });
  }
}

extension MediaCategoryQueryProperty
    on QueryBuilder<MediaCategory, MediaCategory, QQueryProperty> {
  QueryBuilder<MediaCategory, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<MediaCategory, int, QQueryOperations> categoryIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'categoryId');
    });
  }

  QueryBuilder<MediaCategory, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<MediaCategory, int, QQueryOperations> parentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'parentId');
    });
  }

  QueryBuilder<MediaCategory, int, QQueryOperations> sortIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sortIndex');
    });
  }

  QueryBuilder<MediaCategory, int, QQueryOperations> syncStampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncStamp');
    });
  }

  QueryBuilder<MediaCategory, CategoryType, QQueryOperations> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }
}
