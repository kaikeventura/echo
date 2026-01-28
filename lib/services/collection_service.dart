
import 'package:echo/models/collection_model.dart';
import 'package:echo/services/isar_service.dart';
import 'package:isar/isar.dart';

class CollectionService {
  final Isar isar;

  CollectionService(this.isar);

  Future<void> saveCollection(CollectionModel collection) async {
    await isar.writeTxn(() async {
      await isar.collectionModels.put(collection);
      await collection.folders.save();
      await collection.requests.save();

      for (var folder in collection.folders) {
        await folder.requests.save();
      }
    });
  }
}
