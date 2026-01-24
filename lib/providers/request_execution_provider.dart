import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/collection_model.dart';
import '../models/environment_profile_model.dart';
import '../models/request_model.dart';
import '../models/response_model.dart';
import '../services/http_service.dart';
import 'active_request_provider.dart';
import 'collections_provider.dart';

part 'request_execution_provider.g.dart';

@riverpod
class RequestExecution extends _$RequestExecution {
  @override
  FutureOr<ResponseModel?> build() {
    return null;
  }

  Future<void> execute() async {
    final activeRequest = ref.read(activeRequestProvider);
    if (activeRequest == null) return;

    final collections = ref.read(collectionsProvider).valueOrNull ?? [];
    if (collections.isEmpty) return;

    // Find the collection this request belongs to
    CollectionModel? parentCollection;
    for (var col in collections) {
      if (col.requests.any((req) => req.id == activeRequest.id)) {
        parentCollection = col;
        break;
      }
    }

    state = const AsyncValue.loading();

    try {
      // Create a clone of the request to avoid modifying the original
      final requestToSend = await _cloneAndInterpolate(activeRequest, parentCollection);
      
      final httpService = HttpService();
      final response = await httpService.executeRequest(requestToSend);
      state = AsyncValue.data(response);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<RequestModel> _cloneAndInterpolate(RequestModel original, CollectionModel? collection) async {
    // Create a deep copy to avoid side effects
    final clone = RequestModel()
      ..id = original.id
      ..name = original.name
      ..method = original.method
      ..url = original.url
      ..body = original.body
      ..savedAt = original.savedAt;

    if (original.headers != null) {
      clone.headers = original.headers!
          .map((h) => RequestHeader()
            ..key = h.key
            ..value = h.value)
          .toList();
    }

    if (collection == null) return clone;

    // Get active environment
    await collection.activeEnvironment.load();
    final activeProfile = collection.activeEnvironment.value;
    if (activeProfile == null) return clone;

    final env = activeProfile.variables ?? [];
    if (env.isEmpty) return clone;

    // Interpolate URL
    clone.url = _interpolateString(clone.url, env);

    // Interpolate Headers
    if (clone.headers != null) {
      for (var header in clone.headers!) {
        header.value = _interpolateString(header.value, env);
      }
    }

    // Interpolate Body
    clone.body = _interpolateString(clone.body, env);

    return clone;
  }

  String _interpolateString(String? text, List<EnvironmentVariable> env) {
    if (text == null) return '';
    String result = text;
    for (var variable in env) {
      if (variable.key != null && variable.value != null) {
        result = result.replaceAll('{{${variable.key}}}', variable.value!);
      }
    }
    return result;
  }
}
