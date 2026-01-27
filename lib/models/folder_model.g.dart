// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'folder_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetFolderModelCollection on Isar {
  IsarCollection<FolderModel> get folderModels => this.collection();
}

const FolderModelSchema = CollectionSchema(
  name: r'FolderModel',
  id: -424889283014507682,
  properties: {
    r'name': PropertySchema(
      id: 0,
      name: r'name',
      type: IsarType.string,
    )
  },
  estimateSize: _folderModelEstimateSize,
  serialize: _folderModelSerialize,
  deserialize: _folderModelDeserialize,
  deserializeProp: _folderModelDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {
    r'requests': LinkSchema(
      id: -2243479273954010809,
      name: r'requests',
      target: r'RequestModel',
      single: false,
    ),
    r'collection': LinkSchema(
      id: -5043814213505363784,
      name: r'collection',
      target: r'CollectionModel',
      single: true,
    )
  },
  embeddedSchemas: {},
  getId: _folderModelGetId,
  getLinks: _folderModelGetLinks,
  attach: _folderModelAttach,
  version: '3.1.0+1',
);

int _folderModelEstimateSize(
  FolderModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.name.length * 3;
  return bytesCount;
}

void _folderModelSerialize(
  FolderModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.name);
}

FolderModel _folderModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = FolderModel();
  object.id = id;
  object.name = reader.readString(offsets[0]);
  return object;
}

P _folderModelDeserializeProp<P>(
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

Id _folderModelGetId(FolderModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _folderModelGetLinks(FolderModel object) {
  return [object.requests, object.collection];
}

void _folderModelAttach(
    IsarCollection<dynamic> col, Id id, FolderModel object) {
  object.id = id;
  object.requests
      .attach(col, col.isar.collection<RequestModel>(), r'requests', id);
  object.collection
      .attach(col, col.isar.collection<CollectionModel>(), r'collection', id);
}

extension FolderModelQueryWhereSort
    on QueryBuilder<FolderModel, FolderModel, QWhere> {
  QueryBuilder<FolderModel, FolderModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension FolderModelQueryWhere
    on QueryBuilder<FolderModel, FolderModel, QWhereClause> {
  QueryBuilder<FolderModel, FolderModel, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<FolderModel, FolderModel, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<FolderModel, FolderModel, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<FolderModel, FolderModel, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<FolderModel, FolderModel, QAfterWhereClause> idBetween(
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

extension FolderModelQueryFilter
    on QueryBuilder<FolderModel, FolderModel, QFilterCondition> {
  QueryBuilder<FolderModel, FolderModel, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<FolderModel, FolderModel, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<FolderModel, FolderModel, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<FolderModel, FolderModel, QAfterFilterCondition> idBetween(
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

  QueryBuilder<FolderModel, FolderModel, QAfterFilterCondition> nameEqualTo(
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

  QueryBuilder<FolderModel, FolderModel, QAfterFilterCondition> nameGreaterThan(
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

  QueryBuilder<FolderModel, FolderModel, QAfterFilterCondition> nameLessThan(
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

  QueryBuilder<FolderModel, FolderModel, QAfterFilterCondition> nameBetween(
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

  QueryBuilder<FolderModel, FolderModel, QAfterFilterCondition> nameStartsWith(
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

  QueryBuilder<FolderModel, FolderModel, QAfterFilterCondition> nameEndsWith(
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

  QueryBuilder<FolderModel, FolderModel, QAfterFilterCondition> nameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FolderModel, FolderModel, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FolderModel, FolderModel, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<FolderModel, FolderModel, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }
}

extension FolderModelQueryObject
    on QueryBuilder<FolderModel, FolderModel, QFilterCondition> {}

extension FolderModelQueryLinks
    on QueryBuilder<FolderModel, FolderModel, QFilterCondition> {
  QueryBuilder<FolderModel, FolderModel, QAfterFilterCondition> requests(
      FilterQuery<RequestModel> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'requests');
    });
  }

  QueryBuilder<FolderModel, FolderModel, QAfterFilterCondition>
      requestsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'requests', length, true, length, true);
    });
  }

  QueryBuilder<FolderModel, FolderModel, QAfterFilterCondition>
      requestsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'requests', 0, true, 0, true);
    });
  }

  QueryBuilder<FolderModel, FolderModel, QAfterFilterCondition>
      requestsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'requests', 0, false, 999999, true);
    });
  }

  QueryBuilder<FolderModel, FolderModel, QAfterFilterCondition>
      requestsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'requests', 0, true, length, include);
    });
  }

  QueryBuilder<FolderModel, FolderModel, QAfterFilterCondition>
      requestsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'requests', length, include, 999999, true);
    });
  }

  QueryBuilder<FolderModel, FolderModel, QAfterFilterCondition>
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

  QueryBuilder<FolderModel, FolderModel, QAfterFilterCondition> collection(
      FilterQuery<CollectionModel> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'collection');
    });
  }

  QueryBuilder<FolderModel, FolderModel, QAfterFilterCondition>
      collectionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'collection', 0, true, 0, true);
    });
  }
}

extension FolderModelQuerySortBy
    on QueryBuilder<FolderModel, FolderModel, QSortBy> {
  QueryBuilder<FolderModel, FolderModel, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<FolderModel, FolderModel, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }
}

extension FolderModelQuerySortThenBy
    on QueryBuilder<FolderModel, FolderModel, QSortThenBy> {
  QueryBuilder<FolderModel, FolderModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<FolderModel, FolderModel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<FolderModel, FolderModel, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<FolderModel, FolderModel, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }
}

extension FolderModelQueryWhereDistinct
    on QueryBuilder<FolderModel, FolderModel, QDistinct> {
  QueryBuilder<FolderModel, FolderModel, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }
}

extension FolderModelQueryProperty
    on QueryBuilder<FolderModel, FolderModel, QQueryProperty> {
  QueryBuilder<FolderModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<FolderModel, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }
}
