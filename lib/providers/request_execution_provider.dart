import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/collection_model.dart';
import '../models/environment_profile_model.dart';
import '../models/request_model.dart';
import '../models/response_model.dart';
import '../services/http_service.dart';
import 'active_request_provider.dart';
import 'collections_provider.dart';
import '../features/settings/providers/settings_provider.dart';

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

    CollectionModel? parentCollection;
    for (var col in collections) {
      if (col.requests.any((req) => req.id == activeRequest.id) || 
          col.folders.any((f) => f.requests.any((r) => r.id == activeRequest.id))) {
        parentCollection = col;
        break;
      }
    }

    state = const AsyncValue.loading();

    try {
      final requestToSend = await _cloneAndApplyAuth(activeRequest, parentCollection);
      
      final settings = ref.read(settingsProvider).value;
      final httpService = HttpService(settings: settings);
      final response = await httpService.executeRequest(requestToSend);
      state = AsyncValue.data(response);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<RequestModel> _cloneAndApplyAuth(RequestModel original, CollectionModel? collection) async {
    final clone = RequestModel()
      ..id = original.id
      ..name = original.name
      ..method = original.method
      ..url = original.url
      ..body = original.body
      ..savedAt = original.savedAt
      ..auth = original.auth;

    clone.headers = original.headers?.map((h) => RequestHeader()..key = h.key..value = h.value).toList() ?? [];

    // 1. Interpolar variáveis de ambiente
    if (collection != null) {
      try {
        await collection.activeEnvironment.load();
        final activeProfile = collection.activeEnvironment.value;
        if (activeProfile != null) {
          final env = activeProfile.variables ?? [];
          if (env.isNotEmpty) {
            clone.url = _interpolateUrl(clone.url, env);
            for (var header in clone.headers!) {
              header.value = _interpolateString(header.value, env);
            }
            clone.body = _interpolateString(clone.body, env);
            
            // Interpolar campos de autenticação
            if (clone.auth != null) {
              clone.auth!.basicUsername = _interpolateString(clone.auth!.basicUsername, env);
              clone.auth!.basicPassword = _interpolateString(clone.auth!.basicPassword, env);
              clone.auth!.bearerToken = _interpolateString(clone.auth!.bearerToken, env);
              clone.auth!.apiKeyKey = _interpolateString(clone.auth!.apiKeyKey, env);
              clone.auth!.apiKeyValue = _interpolateString(clone.auth!.apiKeyValue, env);
            }
          }
        }
      } catch (e) { /* Ignore */ }
    }

    // 2. Aplicar autenticação
    final auth = clone.auth;
    if (auth == null) return clone;

    switch (auth.type) {
      case 'basic':
        if (auth.basicUsername != null && auth.basicPassword != null) {
          final credentials = base64Encode(utf8.encode('${auth.basicUsername}:${auth.basicPassword}'));
          clone.headers!.add(RequestHeader()..key = 'Authorization'..value = 'Basic $credentials');
        }
        break;
      case 'bearer':
        if (auth.bearerToken != null) {
          clone.headers!.add(RequestHeader()..key = 'Authorization'..value = 'Bearer ${auth.bearerToken}');
        }
        break;
      case 'api_key':
        if (auth.apiKeyKey != null && auth.apiKeyValue != null) {
          if (auth.apiKeyLocation == 'header') {
            clone.headers!.add(RequestHeader()..key = auth.apiKeyKey..value = auth.apiKeyValue);
          } else if (auth.apiKeyLocation == 'query') {
            final uri = Uri.parse(clone.url);
            final newParams = Map<String, dynamic>.from(uri.queryParameters);
            newParams[auth.apiKeyKey!] = auth.apiKeyValue;
            clone.url = uri.replace(queryParameters: newParams).toString();
          }
        }
        break;
    }

    return clone;
  }

  String _interpolateUrl(String url, List<EnvironmentVariable> env) {
    String result = url;
    for (var variable in env) {
      if (variable.key != null && variable.value != null) {
        final key = variable.key!;
        final value = variable.value!;
        final encodedValue = Uri.encodeComponent(value);
        result = result.replaceAll('{{$key}}', encodedValue);
      }
    }
    return result;
  }

  String _interpolateString(String? text, List<EnvironmentVariable> env) {
    if (text == null) return '';
    String result = text;
    for (var variable in env) {
      if (variable.key != null && variable.value != null) {
        final key = variable.key!;
        final value = variable.value!;
        result = result.replaceAll('{{$key}}', value);
      }
    }
    return result;
  }
}
