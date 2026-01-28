import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/request_model.dart';
import '../models/collection_model.dart';
import '../models/environment_profile_model.dart';
import '../models/session_model.dart';
import '../models/folder_model.dart';
import '../models/app_settings_model.dart'; // Importar AppSettingsModel

class IsarService {
  static final IsarService _instance = IsarService._internal();

  factory IsarService() => _instance;

  late Future<Isar> db;

  IsarService._internal() {
    db = openDB();
  }

  Future<Isar> openDB() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      return await Isar.open(
        [
          RequestModelSchema,
          CollectionModelSchema,
          SessionModelSchema,
          EnvironmentProfileSchema,
          FolderModelSchema,
          AppSettingsModelSchema, // Adicionar AppSettingsModelSchema
        ],
        directory: dir.path,
        inspector: true,
      );
    }

    return Future.value(Isar.getInstance());
  }
}
