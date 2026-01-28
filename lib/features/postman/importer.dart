
import 'dart:convert';

import 'package:echo/models/collection_model.dart';
import 'package:echo/models/folder_model.dart';
import 'package:echo/models/request_model.dart';

class PostmanImporter {
  CollectionModel import(String postmanJson) {
    final postmanData = json.decode(postmanJson);
    final collectionName = postmanData['info']['name'];
    final items = postmanData['item'] as List;

    final collection = CollectionModel()..name = collectionName;

    for (var item in items) {
      _parseItem(item, collection);
    }

    return collection;
  }

  void _parseItem(Map<String, dynamic> item, CollectionModel collection) {
    if (item.containsKey('item')) {
      // It's a folder
      final folder = FolderModel()..name = item['name'];
      collection.folders.add(folder);

      for (var subItem in item['item']) {
        _parseSubItem(subItem, folder);
      }
    } else {
      // It's a request at the root
      final request = _parseRequest(item);
      if (request != null) {
        collection.requests.add(request);
      }
    }
  }

  void _parseSubItem(Map<String, dynamic> item, FolderModel folder) {
    if (item.containsKey('item')) {
      final subFolder = FolderModel()..name = item['name'];
      // Note: This creates a flat structure of folders for simplicity.
      // A recursive approach would be needed for nested folders.
      for (var subItem in item['item']) {
        final request = _parseRequest(subItem);
        if (request != null) {
          subFolder.requests.add(request);
        }
      }
    } else {
      final request = _parseRequest(item);
      if (request != null) {
        folder.requests.add(request);
      }
    }
  }

  RequestModel? _parseRequest(Map<String, dynamic> item) {
    if (!item.containsKey('request')) {
      return null;
    }

    final requestData = item['request'];
    final url = requestData['url']['raw'];
    final method = requestData['method'];
    final name = item['name'];
    final body = requestData['body']?['raw'];

    final request = RequestModel()
      ..name = name
      ..url = url
      ..method = method
      ..body = body ?? '';

    return request;
  }
}
