import 'dart:io';
import 'package:echo/features/postman/importer.dart';
import 'package:echo/providers/collections_provider.dart';
import 'package:echo/services/collection_importer.dart';
import 'package:echo/services/collection_service.dart';
import 'package:echo/services/isar_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class ImportCollectionDialog extends ConsumerStatefulWidget {
  const ImportCollectionDialog({super.key});

  @override
  ConsumerState<ImportCollectionDialog> createState() => _ImportCollectionDialogState();
}

class _ImportCollectionDialogState extends ConsumerState<ImportCollectionDialog> {
  String _selectedType = 'Echo Collection';
  String? _selectedFilePath;
  String? _fileName;
  bool _isImporting = false;
  String? _error;

  final List<String> _importTypes = [
    'Echo Collection',
    'Postman Collection',
  ];

  Future<void> _pickFile() async {
    setState(() {
      _error = null;
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        setState(() {
          _selectedFilePath = result.files.single.path;
          _fileName = result.files.single.name;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error picking file: $e';
      });
    }
  }

  Future<void> _import() async {
    if (_selectedFilePath == null) return;

    setState(() {
      _isImporting = true;
      _error = null;
    });

    try {
      final file = File(_selectedFilePath!);
      final content = await file.readAsString();
      final isar = await IsarService().db;

      if (_selectedType == 'Echo Collection') {
        final importer = CollectionImporter();
        await importer.import(content);
      } else if (_selectedType == 'Postman Collection') {
        final importer = PostmanImporter();
        final collection = importer.import(content);
        final collectionService = CollectionService(isar);
        await collectionService.saveCollection(collection);
      }

      // Atualiza a lista de coleções
      ref.invalidate(collectionsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Collection imported successfully!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _error = 'Import failed: $e';
        _isImporting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return AlertDialog(
      title: const Text('Import Collection'),
      content: SizedBox(
        width: 450,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Import From', style: GoogleFonts.inter(color: colorScheme.onSurface.withOpacity(0.7), fontSize: 12)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withOpacity(0.05),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: colorScheme.onSurface.withOpacity(0.1)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedType,
                  isExpanded: true,
                  dropdownColor: colorScheme.surface,
                  items: _importTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type, style: GoogleFonts.inter(fontSize: 13, color: colorScheme.onSurface)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedType = val);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Select File', style: GoogleFonts.inter(color: colorScheme.onSurface.withOpacity(0.7), fontSize: 12)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: colorScheme.onSurface.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: colorScheme.onSurface.withOpacity(0.1)),
                    ),
                    child: Text(
                      _fileName ?? 'No file selected',
                      style: GoogleFonts.inter(
                        color: _fileName != null ? colorScheme.onSurface : colorScheme.onSurface.withOpacity(0.4),
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _pickFile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.onSurface.withOpacity(0.1),
                    foregroundColor: colorScheme.onSurface,
                    elevation: 0,
                  ),
                  child: const Text('Browse'),
                ),
              ],
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.redAccent, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: GoogleFonts.inter(color: Colors.redAccent, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isImporting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: (_selectedFilePath == null || _isImporting) ? null : _import,
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: Colors.white,
          ),
          child: _isImporting 
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Import'),
        ),
      ],
    );
  }
}
