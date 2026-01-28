import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart'; // Importação necessária para o tipo Id
import '../../../models/collection_model.dart';
import '../../../models/folder_model.dart';
import '../../../models/request_model.dart';
import '../../../providers/collections_provider.dart';
import '../../../providers/open_requests_provider.dart';

class HomeDialogs {
  static Future<void> showCreateCollectionDialog(
      BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Collection'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Collection Name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref
                    .read(collectionsProvider.notifier)
                    .addCollection(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  static Future<void> showCreateRequestDialog(
      BuildContext context, WidgetRef ref, {CollectionModel? preSelectedCollection, Id? preSelectedCollectionId, FolderModel? preSelectedFolder}) async {
    final collections = ref.read(collectionsProvider).valueOrNull ?? [];
    if (collections.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Create a collection first')),
      );
      return;
    }

    final nameController = TextEditingController();
    
    CollectionModel? selectedCollection;
    if (preSelectedCollection != null) {
      selectedCollection = preSelectedCollection;
    } else if (preSelectedCollectionId != null) {
      selectedCollection = collections.firstWhere((c) => c.id == preSelectedCollectionId, orElse: () => collections.first);
    } else {
      selectedCollection = collections.first;
    }

    String selectedMethod = 'GET';

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('New Request'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(hintText: 'Request Name'),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              if (preSelectedFolder == null)
                DropdownButtonFormField<CollectionModel>(
                  value: selectedCollection,
                  decoration: const InputDecoration(labelText: 'Collection'),
                  items: collections.map((c) {
                    return DropdownMenuItem(value: c, child: Text(c.name));
                  }).toList(),
                  onChanged: (val) => setState(() => selectedCollection = val),
                ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedMethod,
                decoration: const InputDecoration(labelText: 'Method'),
                items: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'].map((m) {
                  return DropdownMenuItem(value: m, child: Text(m));
                }).toList(),
                onChanged: (val) => setState(() => selectedMethod = val!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty &&
                    selectedCollection != null) {
                  final newRequest = RequestModel()
                    ..name = nameController.text
                    ..method = selectedMethod
                    ..url = ''
                    ..savedAt = DateTime.now();
                  
                  if (preSelectedFolder != null) {
                    await ref.read(collectionsProvider.notifier).addRequestToFolder(
                      preSelectedFolder.id,
                      newRequest,
                    );
                  } else {
                    await ref.read(collectionsProvider.notifier).addRequestToCollection(
                          selectedCollection!.id,
                          newRequest,
                        );
                  }
                  
                  if (context.mounted) {
                    ref.read(openRequestsProvider.notifier).openRequest(newRequest);
                    Navigator.pop(context);
                  }
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}
