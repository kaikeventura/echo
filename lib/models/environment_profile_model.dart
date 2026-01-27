import 'package:isar/isar.dart';

part 'environment_profile_model.g.dart';

@collection
class EnvironmentProfile {
  Id id = Isar.autoIncrement;

  late String name;

  List<EnvironmentVariable>? variables;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'variables': variables?.map((v) => v.toJson()).toList(),
    };
  }

  static EnvironmentProfile fromJson(Map<String, dynamic> json) {
    final profile = EnvironmentProfile()
      ..name = json['name'] as String;

    if (json['variables'] != null) {
      profile.variables = (json['variables'] as List)
          .map((v) => EnvironmentVariable.fromJson(v as Map<String, dynamic>))
          .toList();
    }

    return profile;
  }
}

@embedded
class EnvironmentVariable {
  String? key;
  String? value;

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'value': value,
    };
  }

  static EnvironmentVariable fromJson(Map<String, dynamic> json) {
    return EnvironmentVariable()
      ..key = json['key'] as String?
      ..value = json['value'] as String?;
  }
}
