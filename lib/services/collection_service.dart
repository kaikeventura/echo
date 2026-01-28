import 'package:echo/models/collection_model.dart';
import 'package:echo/models/folder_model.dart';
import 'package:echo/models/request_model.dart';
import 'package:isar/isar.dart';

class CollectionService {
  final Isar isar;

  CollectionService(this.isar);

  Future<void> saveCollection(CollectionModel collection) async {
    await isar.writeTxn(() async {
      // 1. Save all requests from all folders to get their IDs.
      for (var folder in collection.importedFolders) {
        if (folder.importedRequests.isNotEmpty) {
          await isar.requestModels.putAll(folder.importedRequests);
        }
      }
      // Save all requests from the collection root.
      if (collection.importedRequests.isNotEmpty) {
        await isar.requestModels.putAll(collection.importedRequests);
      }

      // 2. Save all folder objects to get their IDs.
      if (collection.importedFolders.isNotEmpty) {
        await isar.folderModels.putAll(collection.importedFolders);
      }

      // 3. Now that all children have IDs, build the links.
      for (var folder in collection.importedFolders) {
        folder.requests.addAll(folder.importedRequests);
        await folder.requests.save();
      }
      
      // 4. Save the main collection object.
      await isar.collectionModels.put(collection);

      // 5. Finally, link the children to the main collection.
      collection.requests.addAll(collection.importedRequests);
      collection.folders.addAll(collection.importedFolders);
      await collection.requests.save();
      await collection.folders.save();
    });
  }
}
