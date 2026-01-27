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

  Map<String, dynamic> toJson() {
    return {
      'id': id, // Manter o ID para possível uso na importação (ex: para evitar duplicatas ou para referências)
      'name': name,
      'method': method,
      'url': url,
      'headers': headers?.map((h) => h.toJson()).toList(),
      'body': body,
      'savedAt': savedAt.toIso8601String(),
    };
  }
}

@embedded
class RequestHeader {
  String? key;
  String? value;

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'value': value,
    };
  }
}
