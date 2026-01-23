// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSessionModelCollection on Isar {
  IsarCollection<SessionModel> get sessionModels => this.collection();
}

const SessionModelSchema = CollectionSchema(
  name: r'SessionModel',
  id: 3961338372060081682,
  properties: {
    r'activeRequestId': PropertySchema(
      id: 0,
      name: r'activeRequestId',
      type: IsarType.long,
    ),
    r'openRequestIds': PropertySchema(
      id: 1,
      name: r'openRequestIds',
      type: IsarType.longList,
    )
  },
  estimateSize: _sessionModelEstimateSize,
  serialize: _sessionModelSerialize,
  deserialize: _sessionModelDeserialize,
  deserializeProp: _sessionModelDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _sessionModelGetId,
  getLinks: _sessionModelGetLinks,
  attach: _sessionModelAttach,
  version: '3.1.0+1',
);

int _sessionModelEstimateSize(
  SessionModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.openRequestIds.length * 8;
  return bytesCount;
}

void _sessionModelSerialize(
  SessionModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.activeRequestId);
  writer.writeLongList(offsets[1], object.openRequestIds);
}

SessionModel _sessionModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SessionModel();
  object.activeRequestId = reader.readLongOrNull(offsets[0]);
  object.id = id;
  object.openRequestIds = reader.readLongList(offsets[1]) ?? [];
  return object;
}

P _sessionModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset)) as P;
    case 1:
      return (reader.readLongList(offset) ?? []) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _sessionModelGetId(SessionModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _sessionModelGetLinks(SessionModel object) {
  return [];
}

void _sessionModelAttach(
    IsarCollection<dynamic> col, Id id, SessionModel object) {
  object.id = id;
}

extension SessionModelQueryWhereSort
    on QueryBuilder<SessionModel, SessionModel, QWhere> {
  QueryBuilder<SessionModel, SessionModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SessionModelQueryWhere
    on QueryBuilder<SessionModel, SessionModel, QWhereClause> {
  QueryBuilder<SessionModel, SessionModel, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<SessionModel, SessionModel, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension SessionModelQueryFilter
    on QueryBuilder<SessionModel, SessionModel, QFilterCondition> {
  QueryBuilder<SessionModel, SessionModel, QAfterFilterCondition>
      activeRequestIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'activeRequestId',
      ));
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterFilterCondition>
      activeRequestIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'activeRequestId',
      ));
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterFilterCondition>
      activeRequestIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activeRequestId',
        value: value,
      ));
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterFilterCondition>
      activeRequestIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'activeRequestId',
        value: value,
      ));
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterFilterCondition>
      activeRequestIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'activeRequestId',
        value: value,
      ));
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterFilterCondition>
      activeRequestIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'activeRequestId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterFilterCondition>
      openRequestIdsElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'openRequestIds',
        value: value,
      ));
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterFilterCondition>
      openRequestIdsElementGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'openRequestIds',
        value: value,
      ));
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterFilterCondition>
      openRequestIdsElementLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'openRequestIds',
        value: value,
      ));
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterFilterCondition>
      openRequestIdsElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'openRequestIds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterFilterCondition>
      openRequestIdsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'openRequestIds',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterFilterCondition>
      openRequestIdsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'openRequestIds',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterFilterCondition>
      openRequestIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'openRequestIds',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterFilterCondition>
      openRequestIdsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'openRequestIds',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterFilterCondition>
      openRequestIdsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'openRequestIds',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterFilterCondition>
      openRequestIdsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'openRequestIds',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension SessionModelQueryObject
    on QueryBuilder<SessionModel, SessionModel, QFilterCondition> {}

extension SessionModelQueryLinks
    on QueryBuilder<SessionModel, SessionModel, QFilterCondition> {}

extension SessionModelQuerySortBy
    on QueryBuilder<SessionModel, SessionModel, QSortBy> {
  QueryBuilder<SessionModel, SessionModel, QAfterSortBy>
      sortByActiveRequestId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeRequestId', Sort.asc);
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterSortBy>
      sortByActiveRequestIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeRequestId', Sort.desc);
    });
  }
}

extension SessionModelQuerySortThenBy
    on QueryBuilder<SessionModel, SessionModel, QSortThenBy> {
  QueryBuilder<SessionModel, SessionModel, QAfterSortBy>
      thenByActiveRequestId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeRequestId', Sort.asc);
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterSortBy>
      thenByActiveRequestIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeRequestId', Sort.desc);
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }
}

extension SessionModelQueryWhereDistinct
    on QueryBuilder<SessionModel, SessionModel, QDistinct> {
  QueryBuilder<SessionModel, SessionModel, QDistinct>
      distinctByActiveRequestId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'activeRequestId');
    });
  }

  QueryBuilder<SessionModel, SessionModel, QDistinct>
      distinctByOpenRequestIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'openRequestIds');
    });
  }
}

extension SessionModelQueryProperty
    on QueryBuilder<SessionModel, SessionModel, QQueryProperty> {
  QueryBuilder<SessionModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SessionModel, int?, QQueryOperations> activeRequestIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'activeRequestId');
    });
  }

  QueryBuilder<SessionModel, List<int>, QQueryOperations>
      openRequestIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'openRequestIds');
    });
  }
}
