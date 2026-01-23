import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:isar/isar.dart';
import '../models/request_model.dart';
import '../models/session_model.dart';
import '../services/isar_service.dart';
import 'active_request_provider.dart';

part 'open_requests_provider.g.dart';

@riverpod
class OpenRequests extends _$OpenRequests {
  late Isar _isar;

  @override
  Future<List<RequestModel>> build() async {
    _isar = await IsarService().db;
    return _loadSession();
  }

  Future<List<RequestModel>> _loadSession() async {
    final session = await _isar.sessionModels.get(1);
    if (session == null) return [];

    final requests = await _isar.requestModels
        .getAll(session.openRequestIds.cast<int>());
    
    // Filter out nulls in case a request was deleted
    final validRequests = requests.whereType<RequestModel>().toList();

    // Restore active request
    if (session.activeRequestId != null) {
      final activeRequest = validRequests
          .where((r) => r.id == session.activeRequestId)
          .firstOrNull;
      
      // We need to delay this slightly or use a listener because we are in build
      // But since this is async build, we can just set it after this returns?
      // No, we can't modify other providers inside build.
      // We will use a side effect in the UI or a listener.
      // Actually, we can just set it here if we are careful, but better to let the UI handle it
      // or use a separate logic.
      
      // However, for simplicity in this architecture:
      Future.microtask(() {
        ref.read(activeRequestProvider.notifier).state = activeRequest;
      });
    }

    return validRequests;
  }

  Future<void> _saveSession(List<RequestModel> requests, int? activeId) async {
    final session = SessionModel()
      ..id = 1
      ..openRequestIds = requests.map((r) => r.id).toList()
      ..activeRequestId = activeId;

    await _isar.writeTxn(() async {
      await _isar.sessionModels.put(session);
    });
  }

  Future<void> openRequest(RequestModel request) async {
    final currentList = state.value ?? [];
    final exists = currentList.any((r) => r.id == request.id);
    
    List<RequestModel> newList = currentList;
    if (!exists) {
      newList = [...currentList, request];
    }
    
    state = AsyncValue.data(newList);
    ref.read(activeRequestProvider.notifier).state = request;
    
    await _saveSession(newList, request.id);
  }

  Future<void> closeRequest(RequestModel request) async {
    final currentList = state.value ?? [];
    final isActive = ref.read(activeRequestProvider)?.id == request.id;
    
    final newList = currentList.where((r) => r.id != request.id).toList();
    state = AsyncValue.data(newList);

    RequestModel? newActive;
    if (isActive) {
      if (newList.isNotEmpty) {
        newActive = newList.last;
        ref.read(activeRequestProvider.notifier).state = newActive;
      } else {
        ref.read(activeRequestProvider.notifier).state = null;
      }
    } else {
      newActive = ref.read(activeRequestProvider);
    }

    await _saveSession(newList, newActive?.id);
  }
  
  // Call this when active request changes manually (e.g. clicking a tab)
  Future<void> setActive(RequestModel request) async {
    ref.read(activeRequestProvider.notifier).state = request;
    final currentList = state.value ?? [];
    await _saveSession(currentList, request.id);
  }
}
