import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:isar/isar.dart';
import '../models/collection_model.dart';
import '../models/environment_profile_model.dart';
import '../models/request_model.dart';
import '../models/folder_model.dart';
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
    final collections = await _isar.collectionModels.where().findAll();
    // Pré-carregar relacionamentos para evitar problemas de UI
    for (var c in collections) {
      await c.folders.load();
      for (var f in c.folders) {
        await f.requests.load();
      }
      await c.requests.load();
    }
    return collections;
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

  Future<void> deleteCollection(Id id) async {
    final collection = await _isar.collectionModels.get(id);
    if (collection != null) {
      await _isar.writeTxn(() async {
        await collection.requests.load();
        await collection.folders.load();
        await collection.environmentProfiles.load();
        
        // Deletar requests da raiz
        for (var req in collection.requests) {
          await _isar.requestModels.delete(req.id);
        }

        // Deletar pastas e seus requests
        for (var folder in collection.folders) {
          await folder.requests.load();
          for (var req in folder.requests) {
            await _isar.requestModels.delete(req.id);
          }
          await _isar.folderModels.delete(folder.id);
        }

        // Deletar perfis de ambiente
        for (var env in collection.environmentProfiles) {
          await _isar.environmentProfiles.delete(env.id);
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
        await oldCollection.requests.load();
        await newCollection.requests.load();

        oldCollection.requests.remove(request);
        await oldCollection.requests.save();

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

  // --- Folder Methods ---

  Future<void> addFolder(Id collectionId, String name) async {
    final collection = await _isar.collectionModels.get(collectionId);
    if (collection != null) {
      final newFolder = FolderModel()..name = name;
      
      await _isar.writeTxn(() async {
        await _isar.folderModels.put(newFolder);
        collection.folders.add(newFolder);
        await collection.folders.save();
      });
      
      state = AsyncValue.data(await _fetchCollections());
    }
  }

  Future<void> deleteFolder(Id folderId) async {
    final folder = await _isar.folderModels.get(folderId);
    if (folder != null) {
      await _isar.writeTxn(() async {
        await folder.requests.load();
        for (var req in folder.requests) {
          await _isar.requestModels.delete(req.id);
        }
        await _isar.folderModels.delete(folderId);
      });
      state = AsyncValue.data(await _fetchCollections());
    }
  }

  Future<void> addRequestToFolder(Id folderId, RequestModel request) async {
    final folder = await _isar.folderModels.get(folderId);
    if (folder != null) {
      await _isar.writeTxn(() async {
        await _isar.requestModels.put(request);
        folder.requests.add(request);
        await folder.requests.save();
      });
      state = AsyncValue.data(await _fetchCollections());
    }
  }

  // --- Environment Methods ---

  Future<void> addEnvironmentProfile(Id collectionId, String name) async {
    await _isar.writeTxn(() async {
      final collection = await _isar.collectionModels.get(collectionId);
      if (collection != null) {
        final newProfile = EnvironmentProfile()..name = name;
        await _isar.environmentProfiles.put(newProfile);
        
        await collection.environmentProfiles.load();
        collection.environmentProfiles.add(newProfile);
        await collection.environmentProfiles.save();
        
        await collection.activeEnvironment.load();
        if (collection.activeEnvironment.value == null) {
          collection.activeEnvironment.value = newProfile;
          await collection.activeEnvironment.save();
        }
      }
    });
    state = AsyncValue.data(await _fetchCollections());
  }

  Future<void> updateEnvironmentVariables(Id profileId, List<EnvironmentVariable> variables) async {
    await _isar.writeTxn(() async {
      final profile = await _isar.environmentProfiles.get(profileId);
      if (profile != null) {
        profile.variables = variables;
        await _isar.environmentProfiles.put(profile);
      }
    });
    state = AsyncValue.data(await _fetchCollections());
  }

  Future<void> setActiveEnvironment(Id collectionId, Id? profileId) async {
    await _isar.writeTxn(() async {
      final collection = await _isar.collectionModels.get(collectionId);
      if (collection != null) {
        if (profileId == null) {
          collection.activeEnvironment.value = null;
        } else {
          final profile = await _isar.environmentProfiles.get(profileId);
          collection.activeEnvironment.value = profile;
        }
        await collection.activeEnvironment.save();
      }
    });
    state = AsyncValue.data(await _fetchCollections());
  }
}
