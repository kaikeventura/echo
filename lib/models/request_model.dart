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
      'id': id,
      'name': name,
      'method': method,
      'url': url,
      'headers': headers?.map((h) => h.toJson()).toList(),
      'body': body,
      'savedAt': savedAt.toIso8601String(),
    };
  }

  static RequestModel fromJson(Map<String, dynamic> json) {
    final request = RequestModel()
      ..name = json['name'] as String
      ..method = json['method'] as String
      ..url = json['url'] as String
      ..body = json['body'] as String?
      ..savedAt = DateTime.parse(json['savedAt'] as String);

    if (json['headers'] != null) {
      request.headers = (json['headers'] as List)
          .map((h) => RequestHeader.fromJson(h as Map<String, dynamic>))
          .toList();
    }

    return request;
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

  static RequestHeader fromJson(Map<String, dynamic> json) {
    return RequestHeader()
      ..key = json['key'] as String?
      ..value = json['value'] as String?;
  }
}
