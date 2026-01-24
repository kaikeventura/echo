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
  
  Future<void> setActive(RequestModel request) async {
    ref.read(activeRequestProvider.notifier).state = request;
    final currentList = state.value ?? [];
    await _saveSession(currentList, request.id);
  }

  Future<void> closeAll() async {
    state = const AsyncValue.data([]);
    ref.read(activeRequestProvider.notifier).state = null;
    await _saveSession([], null);
  }

  Future<void> closeTabsToLeft(RequestModel request) async {
    final currentList = state.value ?? [];
    final index = currentList.indexWhere((r) => r.id == request.id);
    if (index <= 0) return;

    final newList = currentList.sublist(index);
    state = AsyncValue.data(newList);
    
    // Check if active request was closed
    final activeRequest = ref.read(activeRequestProvider);
    final activeStillOpen = newList.any((r) => r.id == activeRequest?.id);
    
    if (!activeStillOpen) {
      ref.read(activeRequestProvider.notifier).state = request;
    }

    await _saveSession(newList, ref.read(activeRequestProvider)?.id);
  }

  Future<void> closeTabsToRight(RequestModel request) async {
    final currentList = state.value ?? [];
    final index = currentList.indexWhere((r) => r.id == request.id);
    if (index == -1 || index == currentList.length - 1) return;

    final newList = currentList.sublist(0, index + 1);
    state = AsyncValue.data(newList);

    // Check if active request was closed
    final activeRequest = ref.read(activeRequestProvider);
    final activeStillOpen = newList.any((r) => r.id == activeRequest?.id);
    
    if (!activeStillOpen) {
      ref.read(activeRequestProvider.notifier).state = request;
    }

    await _saveSession(newList, ref.read(activeRequestProvider)?.id);
  }
}
