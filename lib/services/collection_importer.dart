import 'dart:convert';
import 'package:echo/models/collection_model.dart';
import 'package:echo/models/environment_profile_model.dart';
import 'package:echo/models/request_model.dart';
import 'package:echo/services/isar_service.dart';
import 'package:isar/isar.dart';

class CollectionImporter {
  Future<void> import(String jsonContent) async {
    final Map<String, dynamic> data = jsonDecode(jsonContent);
    
    // Validação básica
    if (data['exporter'] != 'Echo App') {
      throw Exception('Invalid file format. Expected Echo App export.');
    }

    final isar = await IsarService().db;
    final List<dynamic> collectionsData = data['collections'] ?? [];

    await isar.writeTxn(() async {
      for (var colData in collectionsData) {
        // 1. Criar a Coleção
        final collection = CollectionModel.fromJson(colData);
        // O ID será auto-incrementado pelo Isar ao salvar, pois inicializamos com Isar.autoIncrement no modelo
        // Mas para garantir, podemos forçar se o fromJson tiver sobrescrito
        collection.id = Isar.autoIncrement; 
        await isar.collectionModels.put(collection);

        // 2. Criar e Vincular Requests
        if (colData['requests'] != null) {
          for (var reqData in colData['requests']) {
            final request = RequestModel.fromJson(reqData);
            request.id = Isar.autoIncrement; // Novo ID
            await isar.requestModels.put(request);
            collection.requests.add(request);
          }
          await collection.requests.save();
        }

        // 3. Criar e Vincular Environments
        if (colData['environmentProfiles'] != null) {
          for (var envData in colData['environmentProfiles']) {
            final envProfile = EnvironmentProfile.fromJson(envData);
            envProfile.id = Isar.autoIncrement; // Novo ID
            await isar.environmentProfiles.put(envProfile);
            collection.environmentProfiles.add(envProfile);
          }
          await collection.environmentProfiles.save();
        }
      }
    });
  }
}
