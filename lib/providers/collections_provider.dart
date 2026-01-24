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

  Future<void> renameCollection(Id id, String newName) async {
    final collection = await _isar.collectionModels.get(id);
    if (collection != null) {
      collection.name = newName;
      await _isar.writeTxn(() async {
        await _isar.collectionModels.put(collection);
      });
      state = AsyncValue.data(await _fetchCollections());
    }
  }

  Future<void> updateEnvironment(Id collectionId, List<EnvironmentVariable> environment) async {
    final collection = await _isar.collectionModels.get(collectionId);
    if (collection != null) {
      collection.environment = environment;
      await _isar.writeTxn(() async {
        await _isar.collectionModels.put(collection);
      });
      state = AsyncValue.data(await _fetchCollections());
    }
  }

  Future<void> deleteCollection(Id id) async {
    // Also delete all requests inside the collection to avoid orphans
    final collection = await _isar.collectionModels.get(id);
    if (collection != null) {
      await _isar.writeTxn(() async {
        // Load requests first
        await collection.requests.load();
        for (var req in collection.requests) {
          await _isar.requestModels.delete(req.id);
        }
        await _isar.collectionModels.delete(id);
      });
    }
    
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

  Future<void> moveRequestToCollection(Id requestId, Id newCollectionId, Id oldCollectionId) async {
    if (newCollectionId == oldCollectionId) return;

    final request = await _isar.requestModels.get(requestId);
    final newCollection = await _isar.collectionModels.get(newCollectionId);
    final oldCollection = await _isar.collectionModels.get(oldCollectionId);

    if (request != null && newCollection != null && oldCollection != null) {
      await _isar.writeTxn(() async {
        // **CORREÇÃO AQUI**: Carregar os links antes de modificar
        await oldCollection.requests.load();
        await newCollection.requests.load();

        // Remove from old collection
        oldCollection.requests.remove(request);
        await oldCollection.requests.save();

        // Add to new collection
        newCollection.requests.add(request);
        await newCollection.requests.save();
      });
      
      state = AsyncValue.data(await _fetchCollections());
    }
  }

  Future<void> updateRequest(RequestModel request) async {
    await _isar.writeTxn(() async {
      await _isar.requestModels.put(request);
    });
    state = AsyncValue.data(await _fetchCollections());
  }

  Future<void> deleteRequest(Id requestId) async {
    await _isar.writeTxn(() async {
      await _isar.requestModels.delete(requestId);
    });
    
    state = AsyncValue.data(await _fetchCollections());
  }
}
