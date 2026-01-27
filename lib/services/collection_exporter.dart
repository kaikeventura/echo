import 'dart:convert';
import 'package:echo/models/collection_model.dart';

class CollectionExporter {
  Future<String> export(CollectionModel collection) async {
    // Converte a coleção e seus dados relacionados para um mapa
    final collectionMap = await collection.toJson();

    // Adiciona metadados de exportação para facilitar a importação no futuro
    final exportData = {
      'exporter': 'Echo App',
      'version': '1.0.0', // Pode ser a versão do seu app
      'timestamp': DateTime.now().toIso8601String(),
      'collections': [collectionMap], // Exporta como uma lista, pensando em exportar múltiplas coleções no futuro
    };

    // Converte o mapa para uma string JSON formatada (com indentação)
    const jsonEncoder = JsonEncoder.withIndent('  ');
    return jsonEncoder.convert(exportData);
  }
}
