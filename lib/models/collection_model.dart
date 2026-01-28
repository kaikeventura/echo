import 'package:isar/isar.dart';
import 'request_model.dart';
import 'environment_profile_model.dart';
import 'folder_model.dart';

part 'collection_model.g.dart';

@collection
class CollectionModel {
  Id id = Isar.autoIncrement;

  late String name;

  // Requests que estão na raiz da coleção
  final requests = IsarLinks<RequestModel>();

  // Pastas dentro da coleção
  final folders = IsarLinks<FolderModel>();

  // Link para o perfil de ambiente ativo
  final activeEnvironment = IsarLink<EnvironmentProfile>();

  // Lista de todos os perfis de ambiente disponíveis para esta coleção
  final environmentProfiles = IsarLinks<EnvironmentProfile>();

  @ignore
  List<RequestModel> importedRequests = [];

  @ignore
  List<FolderModel> importedFolders = [];

  Future<Map<String, dynamic>> toJson() async {
    await requests.load();
    await folders.load();
    await environmentProfiles.load();
    await activeEnvironment.load();

    // Carrega requests de cada pasta
    for (var folder in folders) {
      await folder.requests.load();
    }

    return {
      'id': id,
      'name': name,
      'requests': requests.map((r) => r.toJson()).toList(),
      'folders': folders.map((f) => {
        'id': f.id,
        'name': f.name,
        'requests': f.requests.map((r) => r.toJson()).toList(),
      }).toList(),
      'environmentProfiles': environmentProfiles.map((p) => p.toJson()).toList(),
      'activeEnvironmentId': activeEnvironment.value?.id,
    };
  }

  static CollectionModel fromJson(Map<String, dynamic> json) {
    return CollectionModel()
      ..name = json['name'] as String;
  }
}
