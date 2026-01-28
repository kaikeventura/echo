import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import '../models/request_model.dart';
import '../models/response_model.dart';
import '../models/app_settings_model.dart';

class HttpService {
  final Dio _dio;

  HttpService({AppSettingsModel? settings}) : _dio = Dio() {
    if (settings != null) {
      // Configurar Timeout
      _dio.options.connectTimeout = Duration(milliseconds: settings.connectTimeout);
      _dio.options.receiveTimeout = Duration(milliseconds: settings.connectTimeout);
      _dio.options.sendTimeout = Duration(milliseconds: settings.connectTimeout);

      // Configurar SSL e Proxy
      _dio.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () {
          final client = HttpClient();
          
          // SSL Verification
          if (!settings.validateSSL) {
            client.badCertificateCallback = (cert, host, port) => true;
          }

          // Proxy
          if (settings.proxyUrl != null && settings.proxyUrl!.isNotEmpty) {
            client.findProxy = (uri) {
              return 'PROXY ${settings.proxyUrl}';
            };
          }

          return client;
        },
      );
    }
  }

  Future<ResponseModel> executeRequest(RequestModel request) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      final options = Options(
        method: request.method,
        headers: request.headers?.fold<Map<String, dynamic>>({}, (map, header) {
          if (header.key != null && header.value != null) {
            map[header.key!] = header.value!;
          }
          return map;
        }),
        responseType: ResponseType.plain, // Get raw string to calculate size
      );

      final response = await _dio.request(
        request.url,
        data: request.body,
        options: options,
      );

      stopwatch.stop();

      final responseBody = response.data;
      int sizeBytes = 0;
      if (responseBody is String) {
        sizeBytes = utf8.encode(responseBody).length;
      }

      // Convert headers to Map<String, List<String>>
      final headersMap = <String, List<String>>{};
      response.headers.forEach((key, value) {
        headersMap[key] = value;
      });

      return ResponseModel(
        statusCode: response.statusCode ?? 0,
        body: responseBody,
        headers: headersMap,
        executionTimeMs: stopwatch.elapsedMilliseconds,
        responseSizeBytes: sizeBytes,
      );
    } on DioException catch (e) {
      stopwatch.stop();
      
      final responseBody = e.response?.data;
      int sizeBytes = 0;
      if (responseBody is String) {
        sizeBytes = utf8.encode(responseBody).length;
      }

      final headersMap = <String, List<String>>{};
      e.response?.headers.forEach((key, value) {
        headersMap[key] = value;
      });

      return ResponseModel(
        statusCode: e.response?.statusCode ?? 0,
        body: responseBody ?? e.message,
        headers: headersMap,
        executionTimeMs: stopwatch.elapsedMilliseconds,
        responseSizeBytes: sizeBytes,
      );
    } catch (e) {
      stopwatch.stop();
      return ResponseModel(
        statusCode: 0,
        body: e.toString(),
        headers: {},
        executionTimeMs: stopwatch.elapsedMilliseconds,
        responseSizeBytes: 0,
      );
    }
  }
}
