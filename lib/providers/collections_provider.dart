import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:isar/isar.dart';
import '../models/collection_model.dart';
import '../models/request_model.dart';
import '../services/isar_service.dart';

part 'collections_provider.g.dart';

@riverpod
class Collections extends _$Collections {
  late Isar _isar;

  @override
  Future<List<CollectionModel>> build() async {
    _isar = await IsarService().db;
    return _fetchCollections();
  }

  Future<List<CollectionModel>> _fetchCollections() async {
    return await _isar.collectionModels.where().findAll();
  }

  Future<void> addCollection(String name) async {
    final newCollection = CollectionModel()..name = name;
    
    await _isar.writeTxn(() async {
      await _isar.collectionModels.put(newCollection);
    });
    
    state = AsyncValue.data(await _fetchCollections());
  }

  Future<void> deleteCollection(Id id) async {
    await _isar.writeTxn(() async {
      await _isar.collectionModels.delete(id);
    });
    
    state = AsyncValue.data(await _fetchCollections());
  }

  Future<void> addRequestToCollection(Id collectionId, RequestModel request) async {
    final collection = await _isar.collectionModels.get(collectionId);
    if (collection != null) {
      await _isar.writeTxn(() async {
        await _isar.requestModels.put(request);
        collection.requests.add(request);
        await collection.requests.save();
      });
      
      state = AsyncValue.data(await _fetchCollections());
    }
  }

  Future<void> deleteRequest(Id requestId) async {
    await _isar.writeTxn(() async {
      await _isar.requestModels.delete(requestId);
    });
    
    state = AsyncValue.data(await _fetchCollections());
  }
}
