import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/collection_model.dart';
import '../../../models/request_model.dart';
import '../../../providers/active_request_provider.dart';
import '../../../providers/collections_provider.dart';
import '../../../providers/open_requests_provider.dart';
import '../../../utils/http_colors.dart';

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
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.create_new_folder_outlined, size: 18),
                tooltip: 'New Collection',
                splashRadius: 20,
                onPressed: () => _showCreateCollectionDialog(context, ref),
              ),
              IconButton(
                icon: const Icon(Icons.note_add_outlined, size: 18),
                tooltip: 'New Request',
                splashRadius: 20,
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
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text(
          collection.name,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
          ),
        ),
        iconColor: Colors.white54,
        collapsedIconColor: Colors.white38,
        children: collection.requests.map((request) {
          return _buildRequestTile(context, ref, request);
        }).toList(),
      ),
    );
  }

  Widget _buildRequestTile(
      BuildContext context, WidgetRef ref, RequestModel request) {
    final activeRequest = ref.watch(activeRequestProvider);
    final isActive = activeRequest?.id == request.id;

    return Container(
      decoration: BoxDecoration(
        color: isActive ? Theme.of(context).colorScheme.primary.withOpacity(0.15) : Colors.transparent,
        border: Border(
          left: BorderSide(
            color: isActive ? Theme.of(context).colorScheme.primary : Colors.transparent,
            width: 3,
          ),
        ),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.only(left: 28, right: 16),
        visualDensity: const VisualDensity(vertical: -2),
        title: Text(
          request.name,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            color: isActive ? Colors.white : Colors.white70,
          ),
        ),
        subtitle: Text(
          request.method,
          style: GoogleFonts.inter(
            fontSize: 10,
            color: HttpColors.getMethodColor(request.method),
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () {
          ref.read(openRequestsProvider.notifier).openRequest(request);
        },
      ),
    );
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
              onPressed: () async {
                if (nameController.text.isNotEmpty &&
                    selectedCollection != null) {
                  final newRequest = RequestModel()
                    ..name = nameController.text
                    ..method = selectedMethod
                    ..url = ''
                    ..savedAt = DateTime.now();
                  
                  // 1. Adiciona a request ao banco
                  await ref.read(collectionsProvider.notifier).addRequestToCollection(
                        selectedCollection!.id,
                        newRequest,
                      );
                  
                  // 2. Abre a request imediatamente em uma nova aba
                  // Como o objeto newRequest agora tem um ID (gerado pelo Isar), podemos usá-lo
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
