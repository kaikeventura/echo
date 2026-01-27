// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collection_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCollectionModelCollection on Isar {
  IsarCollection<CollectionModel> get collectionModels => this.collection();
}

const CollectionModelSchema = CollectionSchema(
  name: r'CollectionModel',
  id: -6238448902296436685,
  properties: {
    r'name': PropertySchema(
      id: 0,
      name: r'name',
      type: IsarType.string,
    )
  },
  estimateSize: _collectionModelEstimateSize,
  serialize: _collectionModelSerialize,
  deserialize: _collectionModelDeserialize,
  deserializeProp: _collectionModelDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {
    r'requests': LinkSchema(
      id: -2632519931720435079,
      name: r'requests',
      target: r'RequestModel',
      single: false,
    ),
    r'folders': LinkSchema(
      id: -8105905071222111764,
      name: r'folders',
      target: r'FolderModel',
      single: false,
    ),
    r'activeEnvironment': LinkSchema(
      id: -745832077699539396,
      name: r'activeEnvironment',
      target: r'EnvironmentProfile',
      single: true,
    ),
    r'environmentProfiles': LinkSchema(
      id: 5876168938010947097,
      name: r'environmentProfiles',
      target: r'EnvironmentProfile',
      single: false,
    )
  },
  embeddedSchemas: {},
  getId: _collectionModelGetId,
  getLinks: _collectionModelGetLinks,
  attach: _collectionModelAttach,
  version: '3.1.0+1',
);

int _collectionModelEstimateSize(
  CollectionModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.name.length * 3;
  return bytesCount;
}

void _collectionModelSerialize(
  CollectionModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.name);
}

CollectionModel _collectionModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CollectionModel();
  object.id = id;
  object.name = reader.readString(offsets[0]);
  return object;
}

P _collectionModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _collectionModelGetId(CollectionModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _collectionModelGetLinks(CollectionModel object) {
  return [
    object.requests,
    object.folders,
    object.activeEnvironment,
    object.environmentProfiles
  ];
}

void _collectionModelAttach(
    IsarCollection<dynamic> col, Id id, CollectionModel object) {
  object.id = id;
  object.requests
      .attach(col, col.isar.collection<RequestModel>(), r'requests', id);
  object.folders
      .attach(col, col.isar.collection<FolderModel>(), r'folders', id);
  object.activeEnvironment.attach(
      col, col.isar.collection<EnvironmentProfile>(), r'activeEnvironment', id);
  object.environmentProfiles.attach(col,
      col.isar.collection<EnvironmentProfile>(), r'environmentProfiles', id);
}

extension CollectionModelQueryWhereSort
    on QueryBuilder<CollectionModel, CollectionModel, QWhere> {
  QueryBuilder<CollectionModel, CollectionModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CollectionModelQueryWhere
    on QueryBuilder<CollectionModel, CollectionModel, QWhereClause> {
  QueryBuilder<CollectionModel, CollectionModel, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterWhereClause>
      idNotEqualTo(Id id) {
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

  QueryBuilder<CollectionModel, CollectionModel, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterWhereClause> idBetween(
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

extension CollectionModelQueryFilter
    on QueryBuilder<CollectionModel, CollectionModel, QFilterCondition> {
  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      idGreaterThan(
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

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      idLessThan(
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

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      idBetween(
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

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      nameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }
}

extension CollectionModelQueryObject
    on QueryBuilder<CollectionModel, CollectionModel, QFilterCondition> {}

extension CollectionModelQueryLinks
    on QueryBuilder<CollectionModel, CollectionModel, QFilterCondition> {
  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      requests(FilterQuery<RequestModel> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'requests');
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      requestsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'requests', length, true, length, true);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      requestsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'requests', 0, true, 0, true);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      requestsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'requests', 0, false, 999999, true);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      requestsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'requests', 0, true, length, include);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      requestsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'requests', length, include, 999999, true);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      requestsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'requests', lower, includeLower, upper, includeUpper);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition> folders(
      FilterQuery<FolderModel> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'folders');
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      foldersLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'folders', length, true, length, true);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      foldersIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'folders', 0, true, 0, true);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      foldersIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'folders', 0, false, 999999, true);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      foldersLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'folders', 0, true, length, include);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      foldersLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'folders', length, include, 999999, true);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      foldersLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'folders', lower, includeLower, upper, includeUpper);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      activeEnvironment(FilterQuery<EnvironmentProfile> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'activeEnvironment');
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      activeEnvironmentIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'activeEnvironment', 0, true, 0, true);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      environmentProfiles(FilterQuery<EnvironmentProfile> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'environmentProfiles');
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      environmentProfilesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'environmentProfiles', length, true, length, true);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      environmentProfilesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'environmentProfiles', 0, true, 0, true);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      environmentProfilesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'environmentProfiles', 0, false, 999999, true);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      environmentProfilesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'environmentProfiles', 0, true, length, include);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      environmentProfilesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'environmentProfiles', length, include, 999999, true);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterFilterCondition>
      environmentProfilesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'environmentProfiles', lower, includeLower, upper, includeUpper);
    });
  }
}

extension CollectionModelQuerySortBy
    on QueryBuilder<CollectionModel, CollectionModel, QSortBy> {
  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy>
      sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }
}

extension CollectionModelQuerySortThenBy
    on QueryBuilder<CollectionModel, CollectionModel, QSortThenBy> {
  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<CollectionModel, CollectionModel, QAfterSortBy>
      thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }
}

extension CollectionModelQueryWhereDistinct
    on QueryBuilder<CollectionModel, CollectionModel, QDistinct> {
  QueryBuilder<CollectionModel, CollectionModel, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }
}

extension CollectionModelQueryProperty
    on QueryBuilder<CollectionModel, CollectionModel, QQueryProperty> {
  QueryBuilder<CollectionModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CollectionModel, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }
}
