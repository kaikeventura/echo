import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/collection_model.dart';
import '../../../models/request_model.dart';
import '../../../providers/active_request_provider.dart';
import '../../../providers/collections_provider.dart';

class SidebarWidget extends ConsumerWidget {
  const SidebarWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionsAsync = ref.watch(collectionsProvider);

    return Container(
      width: 250,
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          _buildHeader(context, ref),
          Expanded(
            child: collectionsAsync.when(
              data: (collections) => ListView.builder(
                itemCount: collections.length,
                itemBuilder: (context, index) {
                  final collection = collections[index];
                  return _buildCollectionTile(context, ref, collection);
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Collections',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.create_new_folder_outlined, size: 20),
                tooltip: 'New Collection',
                onPressed: () => _showCreateCollectionDialog(context, ref),
              ),
              IconButton(
                icon: const Icon(Icons.note_add_outlined, size: 20),
                tooltip: 'New Request',
                onPressed: () => _showCreateRequestDialog(context, ref),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionTile(
      BuildContext context, WidgetRef ref, CollectionModel collection) {
    return ExpansionTile(
      title: Text(
        collection.name,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      children: collection.requests.map((request) {
        return _buildRequestTile(context, ref, request);
      }).toList(),
    );
  }

  Widget _buildRequestTile(
      BuildContext context, WidgetRef ref, RequestModel request) {
    final activeRequest = ref.watch(activeRequestProvider);
    final isActive = activeRequest?.id == request.id;

    return ListTile(
      dense: true,
      selected: isActive,
      selectedTileColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.2),
      contentPadding: const EdgeInsets.only(left: 32, right: 16),
      title: Text(
        request.name,
        style: TextStyle(
          fontSize: 13,
          color: isActive ? Theme.of(context).colorScheme.primary : null,
        ),
      ),
      subtitle: Text(
        request.method,
        style: TextStyle(
          fontSize: 10,
          color: _getMethodColor(request.method),
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: () {
        ref.read(activeRequestProvider.notifier).state = request;
      },
    );
  }

  Color _getMethodColor(String method) {
    switch (method.toUpperCase()) {
      case 'GET':
        return Colors.green;
      case 'POST':
        return Colors.orange;
      case 'PUT':
        return Colors.blue;
      case 'DELETE':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _showCreateCollectionDialog(
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

  Future<void> _showCreateRequestDialog(
      BuildContext context, WidgetRef ref) async {
    final collections = ref.read(collectionsProvider).valueOrNull ?? [];
    if (collections.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Create a collection first')),
      );
      return;
    }

    final nameController = TextEditingController();
    CollectionModel? selectedCollection = collections.first;
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
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    selectedCollection != null) {
                  final newRequest = RequestModel()
                    ..name = nameController.text
                    ..method = selectedMethod
                    ..url = ''
                    ..savedAt = DateTime.now();
                  
                  ref.read(collectionsProvider.notifier).addRequestToCollection(
                        selectedCollection!.id,
                        newRequest,
                      );
                  Navigator.pop(context);
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
