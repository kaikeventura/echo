import 'dart:convert';

import 'package:echo/models/collection_model.dart';
import 'package:echo/models/folder_model.dart';
import 'package:echo/models/request_model.dart';

class PostmanImporter {
  CollectionModel import(String postmanJson) {
    final postmanData = json.decode(postmanJson);
    final info = postmanData['info'];
    final collectionName = (info is Map ? info['name'] : null) ?? 'Imported Collection';
    final items = postmanData['item'] as List? ?? [];

    final collection = CollectionModel()..name = collectionName;

    for (var item in items) {
      if (item is Map<String, dynamic>) {
        _parseItem(item, collection, null);
      }
    }

    return collection;
  }

  void _parseItem(Map<String, dynamic> itemData, CollectionModel collection, FolderModel? parentFolder) {
    if (itemData.containsKey('item') && itemData['item'] is List) {
      final folder = FolderModel()..name = itemData['name'] as String? ?? 'Unnamed Folder';
      
      if (parentFolder != null) {
        collection.importedFolders.add(folder);
      } else {
        collection.importedFolders.add(folder);
      }

      for (var subItemData in (itemData['item'] as List)) {
        if (subItemData is Map<String, dynamic>) {
          _parseItem(subItemData, collection, folder);
        }
      }
    } 
    else if (itemData.containsKey('request')) {
      final request = _parseRequest(itemData);
      if (request != null) {
        if (parentFolder != null) {
          parentFolder.importedRequests.add(request);
        } else {
          collection.importedRequests.add(request);
        }
      }
    }
  }

  RequestModel? _parseRequest(Map<String, dynamic> item) {
    final requestData = item['request'];
    if (requestData is! Map<String, dynamic>) {
      return null;
    }

    final name = item['name'] as String? ?? 'Unnamed Request';
    
    String url = '';
    final urlData = requestData['url'];
    if (urlData is String) {
      url = urlData;
    } else if (urlData is Map) {
      url = urlData['raw'] as String? ?? '';
    }

    final method = requestData['method'] as String? ?? 'GET';
    
    String body = '';
    final bodyData = requestData['body'];
    if (bodyData is Map) {
      body = bodyData['raw'] as String? ?? '';
    }

    final request = RequestModel()
      ..name = name
      ..url = url
      ..method = method
      ..body = body
      ..savedAt = DateTime.now(); // <-- FIX: Add the current timestamp

    return request;
  }
}
