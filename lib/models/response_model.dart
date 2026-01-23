class ResponseModel {
  final int statusCode;
  final dynamic body;
  final Map<String, List<String>> headers;
  final int executionTimeMs;
  final int responseSizeBytes;

  ResponseModel({
    required this.statusCode,
    required this.body,
    required this.headers,
    required this.executionTimeMs,
    required this.responseSizeBytes,
  });
}
