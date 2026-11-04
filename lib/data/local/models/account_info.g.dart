// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_info.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types, experimental_member_use

extension GetAccountInfoCollection on Isar {
  IsarCollection<AccountInfo> get accounts => this.collection();
}

const AccountInfoSchema = CollectionSchema(
  name: r'AccountInfo',
  id: 7933897500292750002,
  properties: {
    r'activeConnections': PropertySchema(
      id: 0,
      name: r'activeConnections',
      type: IsarType.long,
    ),
    r'allowedOutputFormats': PropertySchema(
      id: 1,
      name: r'allowedOutputFormats',
      type: IsarType.stringList,
    ),
    r'createdAt': PropertySchema(
      id: 2,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'expiresAt': PropertySchema(
      id: 3,
      name: r'expiresAt',
      type: IsarType.dateTime,
    ),
    r'isTrial': PropertySchema(id: 4, name: r'isTrial', type: IsarType.bool),
    r'lastLoginAt': PropertySchema(
      id: 5,
      name: r'lastLoginAt',
      type: IsarType.dateTime,
    ),
    r'maxConnections': PropertySchema(
      id: 6,
      name: r'maxConnections',
      type: IsarType.long,
    ),
    r'serverTimezone': PropertySchema(
      id: 7,
      name: r'serverTimezone',
      type: IsarType.string,
    ),
    r'status': PropertySchema(id: 8, name: r'status', type: IsarType.string),
    r'username': PropertySchema(
      id: 9,
      name: r'username',
      type: IsarType.string,
    ),
  },

  estimateSize: _accountInfoEstimateSize,
  serialize: _accountInfoSerialize,
  deserialize: _accountInfoDeserialize,
  deserializeProp: _accountInfoDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},

  getId: _accountInfoGetId,
  getLinks: _accountInfoGetLinks,
  attach: _accountInfoAttach,
  version: '3.4.1',
);

int _accountInfoEstimateSize(
  AccountInfo object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.allowedOutputFormats.length * 3;
  {
    for (var i = 0; i < object.allowedOutputFormats.length; i++) {
      final value = object.allowedOutputFormats[i];
      bytesCount += value.length * 3;
    }
  }
  {
    final value = object.serverTimezone;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.status.length * 3;
  bytesCount += 3 + object.username.length * 3;
  return bytesCount;
}

void _accountInfoSerialize(
  AccountInfo object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.activeConnections);
  writer.writeStringList(offsets[1], object.allowedOutputFormats);
  writer.writeDateTime(offsets[2], object.createdAt);
  writer.writeDateTime(offsets[3], object.expiresAt);
  writer.writeBool(offsets[4], object.isTrial);
  writer.writeDateTime(offsets[5], object.lastLoginAt);
  writer.writeLong(offsets[6], object.maxConnections);
  writer.writeString(offsets[7], object.serverTimezone);
  writer.writeString(offsets[8], object.status);
  writer.writeString(offsets[9], object.username);
}

AccountInfo _accountInfoDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AccountInfo();
  object.activeConnections = reader.readLong(offsets[0]);
  object.allowedOutputFormats = reader.readStringList(offsets[1]) ?? [];
  object.createdAt = reader.readDateTimeOrNull(offsets[2]);
  object.expiresAt = reader.readDateTimeOrNull(offsets[3]);
  object.id = id;
  object.isTrial = reader.readBool(offsets[4]);
  object.lastLoginAt = reader.readDateTime(offsets[5]);
  object.maxConnections = reader.readLong(offsets[6]);
  object.serverTimezone = reader.readStringOrNull(offsets[7]);
  object.status = reader.readString(offsets[8]);
  object.username = reader.readString(offsets[9]);
  return object;
}

P _accountInfoDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readStringList(offset) ?? []) as P;
    case 2:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 3:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _accountInfoGetId(AccountInfo object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _accountInfoGetLinks(AccountInfo object) {
  return [];
}

void _accountInfoAttach(
  IsarCollection<dynamic> col,
  Id id,
  AccountInfo object,
) {
  object.id = id;
}

extension AccountInfoQueryWhereSort
    on QueryBuilder<AccountInfo, AccountInfo, QWhere> {
  QueryBuilder<AccountInfo, AccountInfo, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AccountInfoQueryWhere
    on QueryBuilder<AccountInfo, AccountInfo, QWhereClause> {
  QueryBuilder<AccountInfo, AccountInfo, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<AccountInfo, AccountInfo, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterWhereClause> idBetween(
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
}

extension AccountInfoQueryFilter
    on QueryBuilder<AccountInfo, AccountInfo, QFilterCondition> {
  QueryBuilder<AccountInfo, AccountInfo, QAfterFilterCondition>
  activeConnectionsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'activeConnections', value: value),
      );
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterFilterCondition>
  activeConnectionsGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'activeConnections',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterFilterCondition>
  activeConnectionsLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'activeConnections',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterFilterCondition>
  activeConnectionsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'activeConnections',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterFilterCondition>
  allowedOutputFormatsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'allowedOutputFormats',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterFilterCondition>
  allowedOutputFormatsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'allowedOutputFormats',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterFilterCondition>
  allowedOutputFormatsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'allowedOutputFormats',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterFilterCondition>
  allowedOutputFormatsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'allowedOutputFormats',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterFilterCondition>
  allowedOutputFormatsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'allowedOutputFormats',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterFilterCondition>
  allowedOutputFormatsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'allowedOutputFormats',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterFilterCondition>
  allowedOutputFormatsElementContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'allowedOutputFormats',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterFilterCondition>
  allowedOutputFormatsElementMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'allowedOutputFormats',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterFilterCondition>
  allowedOutputFormatsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'allowedOutputFormats', value: ''),
      );
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterFilterCondition>
  allowedOutputFormatsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'allowedOutputFormats',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterFilterCondition>
  allowedOutputFormatsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'allowedOutputFormats',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterFilterCondition>
  allowedOutputFormatsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'allowedOutputFormats', 0, true, 0, true);
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterFilterCondition>
  allowedOutputFormatsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'allowedOutputFormats', 0, false, 999999, true);
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterFilterCondition>
  allowedOutputFormatsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'allowedOutputFormats',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterFilterCondition>
  allowedOutputFormatsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'allowedOutputFormats',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterFilterCondition>
  allowedOutputFormatsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'allowedOutputFormats',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterFilterCondition>
  createdAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'createdAt'),
      );
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterFilterCondition>
  createdAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'createdAt'),
      );
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterFilterCondition>
  createdAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterFilterCondition>
  createdAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterFilterCondition>
  createdAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterFilterCondition>
  createdAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'createdAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterFilterCondition>
  expiresAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'expiresAt'),
      );
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterFilterCondition>
  expiresAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'expiresAt'),
      );
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterFilterCondition>
  expiresAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'expiresAt', value: value),
      );
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterFilterCondition>
  expiresAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'expiresAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterFilterCondition>
  expiresAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'expiresAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterFilterCondition>
  expiresAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'expiresAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<AccountInfo, AccountInfo, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<AccountInfo, AccountInfo, QAfterFilterCondition> idBetween(
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

  QueryBuilder<AccountInfo, AccountInfo, QAfterFilterCondition> isTrialEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isTrial', value: value),
      );
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterFilterCondition>
  lastLoginAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastLoginAt', value: value),
      );
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterFilterCondition>
  lastLoginAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastLoginAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterFilterCondition>
  lastLoginAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastLoginAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterFilterCondition>
  lastLoginAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastLoginAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterFilterCondition>
  maxConnectionsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'maxConnections', value: value),
      );
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterFilterCondition>
  maxConnectionsGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'maxConnections',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterFilterCondition>
  maxConnectionsLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'maxConnections',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterFilterCondition>
  maxConnectionsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'maxConnections',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterFilterCondition>
  serverTimezoneIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'serverTimezone'),
      );
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterFilterCondition>
  serverTimezoneIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'serverTimezone'),
      );
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterFilterCondition>
  serverTimezoneEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'serverTimezone',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterFilterCondition>
  serverTimezoneGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'serverTimezone',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterFilterCondition>
  serverTimezoneLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'serverTimezone',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterFilterCondition>
  serverTimezoneBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'serverTimezone',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterFilterCondition>
  serverTimezoneStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'serverTimezone',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterFilterCondition>
  serverTimezoneEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'serverTimezone',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterFilterCondition>
  serverTimezoneContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'serverTimezone',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterFilterCondition>
  serverTimezoneMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'serverTimezone',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterFilterCondition>
  serverTimezoneIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'serverTimezone', value: ''),
      );
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterFilterCondition>
  serverTimezoneIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'serverTimezone', value: ''),
      );
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterFilterCondition> statusEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterFilterCondition>
  statusGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterFilterCondition> statusLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterFilterCondition> statusBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'status',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterFilterCondition>
  statusStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterFilterCondition> statusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterFilterCondition> statusContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterFilterCondition> statusMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'status',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterFilterCondition>
  statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'status', value: ''),
      );
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterFilterCondition>
  statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'status', value: ''),
      );
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterFilterCondition> usernameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'username',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterFilterCondition>
  usernameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'username',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterFilterCondition>
  usernameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'username',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterFilterCondition> usernameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'username',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterFilterCondition>
  usernameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'username',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterFilterCondition>
  usernameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'username',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterFilterCondition>
  usernameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'username',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterFilterCondition> usernameMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'username',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterFilterCondition>
  usernameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'username', value: ''),
      );
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterFilterCondition>
  usernameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'username', value: ''),
      );
    });
  }
}

extension AccountInfoQueryObject
    on QueryBuilder<AccountInfo, AccountInfo, QFilterCondition> {}

extension AccountInfoQueryLinks
    on QueryBuilder<AccountInfo, AccountInfo, QFilterCondition> {}

extension AccountInfoQuerySortBy
    on QueryBuilder<AccountInfo, AccountInfo, QSortBy> {
  QueryBuilder<AccountInfo, AccountInfo, QAfterSortBy>
  sortByActiveConnections() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeConnections', Sort.asc);
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterSortBy>
  sortByActiveConnectionsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeConnections', Sort.desc);
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterSortBy> sortByExpiresAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiresAt', Sort.asc);
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterSortBy> sortByExpiresAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiresAt', Sort.desc);
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterSortBy> sortByIsTrial() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isTrial', Sort.asc);
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterSortBy> sortByIsTrialDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isTrial', Sort.desc);
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterSortBy> sortByLastLoginAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastLoginAt', Sort.asc);
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterSortBy> sortByLastLoginAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastLoginAt', Sort.desc);
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterSortBy> sortByMaxConnections() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxConnections', Sort.asc);
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterSortBy>
  sortByMaxConnectionsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxConnections', Sort.desc);
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterSortBy> sortByServerTimezone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverTimezone', Sort.asc);
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterSortBy>
  sortByServerTimezoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverTimezone', Sort.desc);
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterSortBy> sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterSortBy> sortByUsername() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'username', Sort.asc);
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterSortBy> sortByUsernameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'username', Sort.desc);
    });
  }
}

extension AccountInfoQuerySortThenBy
    on QueryBuilder<AccountInfo, AccountInfo, QSortThenBy> {
  QueryBuilder<AccountInfo, AccountInfo, QAfterSortBy>
  thenByActiveConnections() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeConnections', Sort.asc);
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterSortBy>
  thenByActiveConnectionsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeConnections', Sort.desc);
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterSortBy> thenByExpiresAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiresAt', Sort.asc);
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterSortBy> thenByExpiresAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiresAt', Sort.desc);
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterSortBy> thenByIsTrial() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isTrial', Sort.asc);
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterSortBy> thenByIsTrialDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isTrial', Sort.desc);
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterSortBy> thenByLastLoginAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastLoginAt', Sort.asc);
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterSortBy> thenByLastLoginAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastLoginAt', Sort.desc);
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterSortBy> thenByMaxConnections() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxConnections', Sort.asc);
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterSortBy>
  thenByMaxConnectionsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxConnections', Sort.desc);
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterSortBy> thenByServerTimezone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverTimezone', Sort.asc);
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterSortBy>
  thenByServerTimezoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverTimezone', Sort.desc);
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterSortBy> thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterSortBy> thenByUsername() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'username', Sort.asc);
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QAfterSortBy> thenByUsernameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'username', Sort.desc);
    });
  }
}

extension AccountInfoQueryWhereDistinct
    on QueryBuilder<AccountInfo, AccountInfo, QDistinct> {
  QueryBuilder<AccountInfo, AccountInfo, QDistinct>
  distinctByActiveConnections() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'activeConnections');
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QDistinct>
  distinctByAllowedOutputFormats() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'allowedOutputFormats');
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QDistinct> distinctByExpiresAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'expiresAt');
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QDistinct> distinctByIsTrial() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isTrial');
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QDistinct> distinctByLastLoginAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastLoginAt');
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QDistinct> distinctByMaxConnections() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'maxConnections');
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QDistinct> distinctByServerTimezone({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'serverTimezone',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QDistinct> distinctByStatus({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AccountInfo, AccountInfo, QDistinct> distinctByUsername({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'username', caseSensitive: caseSensitive);
    });
  }
}

extension AccountInfoQueryProperty
    on QueryBuilder<AccountInfo, AccountInfo, QQueryProperty> {
  QueryBuilder<AccountInfo, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AccountInfo, int, QQueryOperations> activeConnectionsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'activeConnections');
    });
  }

  QueryBuilder<AccountInfo, List<String>, QQueryOperations>
  allowedOutputFormatsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'allowedOutputFormats');
    });
  }

  QueryBuilder<AccountInfo, DateTime?, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<AccountInfo, DateTime?, QQueryOperations> expiresAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'expiresAt');
    });
  }

  QueryBuilder<AccountInfo, bool, QQueryOperations> isTrialProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isTrial');
    });
  }

  QueryBuilder<AccountInfo, DateTime, QQueryOperations> lastLoginAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastLoginAt');
    });
  }

  QueryBuilder<AccountInfo, int, QQueryOperations> maxConnectionsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'maxConnections');
    });
  }

  QueryBuilder<AccountInfo, String?, QQueryOperations>
  serverTimezoneProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'serverTimezone');
    });
  }

  QueryBuilder<AccountInfo, String, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<AccountInfo, String, QQueryOperations> usernameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'username');
    });
  }
}
