import 'package:isar/isar.dart';
import 'request_model.dart';
import 'collection_model.dart';

part 'folder_model.g.dart';

@collection
class FolderModel {
  Id id = Isar.autoIncrement;

  late String name;

  // Requests que estão dentro desta pasta
  final requests = IsarLinks<RequestModel>();

  // Coleção pai
  final collection = IsarLink<CollectionModel>();

  @ignore
  List<RequestModel> importedRequests = [];

  static FolderModel fromJson(Map<String, dynamic> json) {
    return FolderModel()
      ..name = json['name'] as String;
  }
}
