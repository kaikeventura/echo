import 'dart:convert';
import 'dart:typed_data';
import 'package:echo/providers/collections_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_saver/file_saver.dart';
import 'package:echo/models/collection_model.dart';
import 'package:echo/services/collection_exporter.dart';

class ExportCollectionDialog extends ConsumerWidget {
  const ExportCollectionDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionsAsync = ref.watch(collectionsProvider);
    final CollectionExporter exporter = CollectionExporter();
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: const Text('Export Collection'),
      // backgroundColor removido
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
                
                int totalRequests = collection.requests.length;
                for (var folder in collection.folders) {
                  totalRequests += folder.requests.length;
                }

                return ListTile(
                  title: Text(collection.name, style: TextStyle(color: colorScheme.onSurface)),
                  subtitle: Text('$totalRequests requests', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7))),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      final String jsonContent = await exporter.export(collection);
                      print('JSON Content to export: $jsonContent');

                      if (jsonContent.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Export content is empty. Nothing to save.')),
                        );
                        Navigator.of(context).pop();
                        return;
                      }

                      final now = DateTime.now();
                      final formattedDate = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
                      final fileName = 'echo-collection-$formattedDate';

                      try {
                        final bytes = Uint8List.fromList(utf8.encode(jsonContent));

                        final String? filePath = await FileSaver.instance.saveFile(
                          name: fileName,
                          ext: 'json',
                          bytes: bytes,
                          mimeType: MimeType.json,
                        );

                        if (filePath != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Collection "${collection.name}" exported successfully to $filePath!')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Export cancelled by user or failed to open save dialog.')),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error exporting collection: $e')),
                        );
                      } finally {
                        Navigator.of(context).pop();
                      }
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
