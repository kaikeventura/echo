import 'package:isar/isar.dart';

part 'environment_profile_model.g.dart';

@collection
class EnvironmentProfile {
  Id id = Isar.autoIncrement;

  late String name;

  List<EnvironmentVariable>? variables;

  Map<String, dynamic> toJson() {
    return {
      'id': id, // Manter o ID para possível uso na importação
      'name': name,
      'variables': variables?.map((v) => v.toJson()).toList(),
    };
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
}
