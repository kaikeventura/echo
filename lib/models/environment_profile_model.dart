import 'package:isar/isar.dart';

part 'environment_profile_model.g.dart';

@collection
class EnvironmentProfile {
  Id id = Isar.autoIncrement;

  late String name;

  List<EnvironmentVariable>? variables;
}

@embedded
class EnvironmentVariable {
  String? key;
  String? value;
}
