import 'package:echo/providers/collections_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExportCollectionDialog extends ConsumerWidget {
  const ExportCollectionDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionsAsync = ref.watch(collectionsProvider);

    return AlertDialog(
      title: const Text('Export Collection'),
      backgroundColor: const Color(0xFF2D2D2D),
      content: SizedBox(
        width: 400,
        height: 300,
        child: collectionsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
          data: (collections) {
            if (collections.isEmpty) {
              return const Center(child: Text('No collections to export.'));
            }
            return ListView.builder(
              itemCount: collections.length,
              itemBuilder: (context, index) {
                final collection = collections[index];
                return ListTile(
                  title: Text(collection.name),
                  subtitle: Text('${collection.requests.length} requests'),
                  trailing: ElevatedButton(
                    onPressed: () {
                      // A lógica de exportação real virá aqui
                      print('Exporting ${collection.name}');
                      Navigator.of(context).pop(); // Fecha o diálogo após a ação
                    },
                    child: const Text('Export'),
                  ),
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
