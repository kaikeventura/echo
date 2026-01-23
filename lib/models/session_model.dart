import 'package:isar/isar.dart';

part 'session_model.g.dart';

@collection
class SessionModel {
  Id id = 1; // Singleton ID

  List<int> openRequestIds = [];

  int? activeRequestId;
}
