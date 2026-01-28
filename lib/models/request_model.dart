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
  RequestAuth? auth; // Novo campo de autenticação

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'method': method,
      'url': url,
      'headers': headers?.map((h) => h.toJson()).toList(),
      'body': body,
      'savedAt': savedAt.toIso8601String(),
      'auth': auth?.toJson(), // Serializar auth
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
    
    if (json['auth'] != null) {
      request.auth = RequestAuth.fromJson(json['auth'] as Map<String, dynamic>);
    }

    return request;
  }
}

@embedded
class RequestHeader {
  String? key;
  String? value;

  Map<String, dynamic> toJson() => {'key': key, 'value': value};

  static RequestHeader fromJson(Map<String, dynamic> json) {
    return RequestHeader()
      ..key = json['key'] as String?
      ..value = json['value'] as String?;
  }
}

@embedded
class RequestAuth {
  String type = 'no_auth'; // Padrão
  String? basicUsername;
  String? basicPassword;
  String? bearerToken;
  String? apiKeyKey;
  String? apiKeyValue;
  String? apiKeyLocation; // 'header' ou 'query'

  Map<String, dynamic> toJson() => {
        'type': type,
        'basicUsername': basicUsername,
        'basicPassword': basicPassword,
        'bearerToken': bearerToken,
        'apiKeyKey': apiKeyKey,
        'apiKeyValue': apiKeyValue,
        'apiKeyLocation': apiKeyLocation,
      };

  static RequestAuth fromJson(Map<String, dynamic> json) {
    return RequestAuth()
      ..type = json['type'] as String
      ..basicUsername = json['basicUsername'] as String?
      ..basicPassword = json['basicPassword'] as String?
      ..bearerToken = json['bearerToken'] as String?
      ..apiKeyKey = json['apiKeyKey'] as String?
      ..apiKeyValue = json['apiKeyValue'] as String?
      ..apiKeyLocation = json['apiKeyLocation'] as String?;
  }
}
