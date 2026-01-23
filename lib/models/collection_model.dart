import 'package:isar/isar.dart';
import 'request_model.dart';

part 'collection_model.g.dart';

@collection
class CollectionModel {
  Id id = Isar.autoIncrement;

  late String name;

  final requests = IsarLinks<RequestModel>();
}
