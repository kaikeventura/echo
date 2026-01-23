import 'package:isar/isar.dart';

part 'request_model.g.dart';

@collection
class RequestModel {
  Id id = Isar.autoIncrement;

  late String name;

  late String method;

  late String url;

  List<RequestHeader>? headers;

  String? body;

  late DateTime savedAt;
}

@embedded
class RequestHeader {
  String? key;
  String? value;
}
