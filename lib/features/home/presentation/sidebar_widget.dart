import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isar/isar.dart';
import '../../../models/collection_model.dart';
import '../../../models/request_model.dart';
import '../../../providers/active_request_provider.dart';
import '../../../providers/collections_provider.dart';
import '../../../providers/open_requests_provider.dart';
import '../../../utils/http_colors.dart';

// Helper class to carry drag data
class RequestDragData {
  final RequestModel request;
  final Id sourceCollectionId;
  RequestDragData(this.request, this.sourceCollectionId);
}

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
    return DragTarget<RequestDragData>(
      onWillAccept: (data) => data?.sourceCollectionId != collection.id,
      onAccept: (data) {
        ref.read(collectionsProvider.notifier).moveRequestToCollection(
              data.request.id,
              collection.id,
              data.sourceCollectionId,
            );
      },
      builder: (context, candidateData, rejectedData) {
        final isTarget = candidateData.isNotEmpty;
        return Container(
          decoration: BoxDecoration(
            color: isTarget ? Theme.of(context).colorScheme.primary.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Theme(
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
              trailing: _buildCollectionMenu(context, ref, collection),
              children: collection.requests.map((request) {
                return _buildRequestTile(context, ref, request, collection.id);
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCollectionMenu(BuildContext context, WidgetRef ref, CollectionModel collection) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 16, color: Colors.white38),
      splashRadius: 16,
      tooltip: 'Options',
      onSelected: (value) {
        if (value == 'rename') {
          _showRenameCollectionDialog(context, ref, collection);
        } else if (value == 'delete') {
          _showDeleteCollectionDialog(context, ref, collection);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'rename',
          height: 32,
          child: Text('Rename', style: TextStyle(fontSize: 13)),
        ),
        const PopupMenuItem(
          value: 'delete',
          height: 32,
          child: Text('Delete', style: TextStyle(fontSize: 13, color: Colors.redAccent)),
        ),
      ],
    );
  }

  Widget _buildRequestTile(
      BuildContext context, WidgetRef ref, RequestModel request, Id sourceCollectionId) {
    final activeRequest = ref.watch(activeRequestProvider);
    final isActive = activeRequest?.id == request.id;

    final tileContent = Container(
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
        contentPadding: const EdgeInsets.only(left: 28, right: 8),
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
        trailing: _buildRequestMenu(context, ref, request),
        onTap: () {
          ref.read(openRequestsProvider.notifier).openRequest(request);
        },
      ),
    );

    return LongPressDraggable<RequestDragData>(
      data: RequestDragData(request, sourceCollectionId),
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          width: 220,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(request.name, style: GoogleFonts.inter(color: Colors.white)),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.4, child: tileContent),
      child: tileContent,
    );
  }

  Widget _buildRequestMenu(BuildContext context, WidgetRef ref, RequestModel request) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 16, color: Colors.white24),
      splashRadius: 16,
      tooltip: 'Options',
      onSelected: (value) {
        if (value == 'rename') {
          _showRenameRequestDialog(context, ref, request);
        } else if (value == 'delete') {
          _showDeleteRequestDialog(context, ref, request);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'rename',
          height: 32,
          child: Text('Rename', style: TextStyle(fontSize: 13)),
        ),
        const PopupMenuItem(
          value: 'delete',
          height: 32,
          child: Text('Delete', style: TextStyle(fontSize: 13, color: Colors.redAccent)),
        ),
      ],
    );
  }

  // --- Dialogs ---

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

  Future<void> _showRenameCollectionDialog(
      BuildContext context, WidgetRef ref, CollectionModel collection) async {
    final controller = TextEditingController(text: collection.name);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Collection'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'New Name'),
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
                    .renameCollection(collection.id, controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteCollectionDialog(
      BuildContext context, WidgetRef ref, CollectionModel collection) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Collection'),
        content: Text('Are you sure you want to delete "${collection.name}" and all its requests?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            onPressed: () {
              ref.read(collectionsProvider.notifier).deleteCollection(collection.id);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
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
                  
                  await ref.read(collectionsProvider.notifier).addRequestToCollection(
                        selectedCollection!.id,
                        newRequest,
                      );
                  
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

  Future<void> _showRenameRequestDialog(
      BuildContext context, WidgetRef ref, RequestModel request) async {
    final controller = TextEditingController(text: request.name);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Request'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'New Name'),
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
                request.name = controller.text;
                ref.read(collectionsProvider.notifier).updateRequest(request);
                Navigator.pop(context);
              }
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteRequestDialog(
      BuildContext context, WidgetRef ref, RequestModel request) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Request'),
        content: Text('Are you sure you want to delete "${request.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            onPressed: () {
              // Close tab if open
              ref.read(openRequestsProvider.notifier).closeRequest(request);
              // Delete from DB
              ref.read(collectionsProvider.notifier).deleteRequest(request.id);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
