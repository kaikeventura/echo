import 'package:isar/isar.dart';
import 'request_model.dart';
import 'environment_profile_model.dart';

part 'collection_model.g.dart';

@collection
class CollectionModel {
  Id id = Isar.autoIncrement;

  late String name;

  final requests = IsarLinks<RequestModel>();

  // Link para o perfil de ambiente ativo
  final activeEnvironment = IsarLink<EnvironmentProfile>();

  // Lista de todos os perfis de ambiente disponíveis para esta coleção
  final environmentProfiles = IsarLinks<EnvironmentProfile>();

  Future<Map<String, dynamic>> toJson() async {
    await requests.load();
    await environmentProfiles.load();
    await activeEnvironment.load();

    return {
      'id': id,
      'name': name,
      'requests': requests.map((r) => r.toJson()).toList(),
      'environmentProfiles': environmentProfiles.map((p) => p.toJson()).toList(),
      'activeEnvironmentId': activeEnvironment.value?.id,
    };
  }

  static CollectionModel fromJson(Map<String, dynamic> json) {
    return CollectionModel()
      ..name = json['name'] as String;
  }
}
