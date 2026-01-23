import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/response_model.dart';
import '../services/http_service.dart';
import 'active_request_provider.dart';

part 'request_execution_provider.g.dart';

@riverpod
class RequestExecution extends _$RequestExecution {
  @override
  FutureOr<ResponseModel?> build() {
    return null;
  }

  Future<void> execute() async {
    final activeRequest = ref.read(activeRequestProvider);
    
    if (activeRequest == null) {
      return;
    }

    state = const AsyncValue.loading();

    try {
      final httpService = HttpService();
      final response = await httpService.executeRequest(activeRequest);
      state = AsyncValue.data(response);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
