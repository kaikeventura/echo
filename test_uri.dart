void main() {
  final params = {'teste': '{{valorTeste}}'};
  final uri = Uri(queryParameters: params);
  print('Query: ${uri.query}');
  
  String queryString = uri.query;
  queryString = queryString.replaceAll('%7B%7B', '{{').replaceAll('%7D%7D', '}}');
  print('Restored: $queryString');
}
