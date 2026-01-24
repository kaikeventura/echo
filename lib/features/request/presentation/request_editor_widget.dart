import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isar/isar.dart';
import '../../../models/collection_model.dart';
import '../../../models/environment_profile_model.dart';
import '../../../models/request_model.dart';
import '../../../providers/active_request_provider.dart';
import '../../../providers/collections_provider.dart';
import '../../../providers/request_execution_provider.dart';
import '../../../utils/http_colors.dart';
import '../../../widgets/key_value_table.dart';

class RequestEditorWidget extends ConsumerStatefulWidget {
  const RequestEditorWidget({super.key});

  @override
  ConsumerState<RequestEditorWidget> createState() => _RequestEditorWidgetState();
}

class _RequestEditorWidgetState extends ConsumerState<RequestEditorWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _urlController;
  late TextEditingController _bodyController;

  // Estado de validação
  String? _bodyError;

  final Map<String, String> _contentTypes = {
    'No Body': '',
    'JSON': 'application/json',
    'Text': 'text/plain',
    'XML': 'application/xml',
    'Form URL Encoded': 'application/x-www-form-urlencoded',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _urlController = TextEditingController();
    _bodyController = TextEditingController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _urlController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeRequest = ref.watch(activeRequestProvider);

    if (activeRequest == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bolt, size: 64, color: Colors.white10),
            const SizedBox(height: 16),
            Text(
              'Select a request to start',
              style: GoogleFonts.inter(color: Colors.white38),
            ),
          ],
        ),
      );
    }

    // Update controllers if request changed
    if (_urlController.text != activeRequest.url) {
      _urlController.text = activeRequest.url;
    }
    // Only update body controller if it's different to avoid cursor jumping
    if (_bodyController.text != (activeRequest.body ?? '')) {
      _bodyController.text = activeRequest.body ?? '';
      // Re-validate on load
      _validateBody(activeRequest.body ?? '', _getCurrentContentType(activeRequest));
    }

    return Column(
      children: [
        _buildTopBar(context, ref, activeRequest),
        Container(
          height: 1,
          color: Colors.white10,
        ),
        TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Colors.white54,
          indicatorColor: Theme.of(context).colorScheme.primary,
          dividerColor: Colors.transparent,
          labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
          tabs: const [
            Tab(text: 'Params'),
            Tab(text: 'Headers'),
            Tab(text: 'Body'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildParamsTab(activeRequest),
              _buildHeadersTab(activeRequest),
              _buildBodyTab(activeRequest),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar(
      BuildContext context, WidgetRef ref, RequestModel request) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: request.method,
                dropdownColor: const Color(0xFF2D2D2D),
                items: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH']
                    .map((m) => DropdownMenuItem(
                          value: m,
                          child: Text(
                            m,
                            style: GoogleFonts.inter(
                                color: HttpColors.getMethodColor(m),
                                fontWeight: FontWeight.bold,
                                fontSize: 13),
                          ),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    request.method = val;
                    _saveRequest(request);
                  }
                },
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: _urlController,
              style: GoogleFonts.inter(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'https://api.example.com/v1/users',
                hintStyle: GoogleFonts.inter(color: Colors.white24),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                prefixIcon: const Icon(Icons.link, color: Colors.white24, size: 18),
              ),
              onChanged: (val) {
                request.url = val;
                _saveRequest(request);
              },
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.code, color: Colors.white54),
            tooltip: 'Collection Environment',
            onPressed: () => _showEnvironmentDialog(context, ref),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                ref.read(requestExecutionProvider.notifier).execute();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24),
              ),
              icon: const Icon(Icons.send, size: 18),
              label: Text('Send', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParamsTab(RequestModel request) {
    Map<String, String> params = {};
    try {
      if (request.url.isNotEmpty) {
        final uri = Uri.parse(request.url);
        params = Map.from(uri.queryParameters);
      }
    } catch (e) {
      // Ignore parse errors
    }

    return KeyValueTable(
      items: params,
      onChanged: (key, value, oldKey) {
        try {
          final uri = request.url.isNotEmpty ? Uri.parse(request.url) : Uri();
          final currentParams = Map<String, String>.from(uri.queryParameters);

          if (oldKey.isNotEmpty && oldKey != key) {
            currentParams.remove(oldKey);
          }
          
          if (key.isNotEmpty) {
            currentParams[key] = value;
          }

          final newUri = uri.replace(queryParameters: currentParams);
          request.url = newUri.toString();
          _saveRequest(request);
        } catch (e) {
          // Handle error
        }
      },
      onDeleted: (key) {
        try {
          final uri = request.url.isNotEmpty ? Uri.parse(request.url) : Uri();
          final currentParams = Map<String, String>.from(uri.queryParameters);
          currentParams.remove(key);
          
          final newUri = uri.replace(queryParameters: currentParams);
          request.url = newUri.toString();
          _saveRequest(request);
        } catch (e) {
          // Handle error
        }
      },
    );
  }

  Widget _buildHeadersTab(RequestModel request) {
    final headersMap = <String, String>{};
    if (request.headers != null) {
      for (var h in request.headers!) {
        if (h.key != null && h.key!.isNotEmpty) {
          headersMap[h.key!] = h.value ?? '';
        }
      }
    }

    return KeyValueTable(
      items: headersMap,
      onChanged: (key, value, oldKey) {
        final newHeaders = request.headers != null 
            ? List<RequestHeader>.from(request.headers!) 
            : <RequestHeader>[];
        
        if (oldKey.isEmpty) {
          newHeaders.add(RequestHeader()..key = key..value = value);
        } else {
          final index = newHeaders.indexWhere((h) => h.key == oldKey);
          if (index != -1) {
            newHeaders[index].key = key;
            newHeaders[index].value = value;
          } else {
             newHeaders.add(RequestHeader()..key = key..value = value);
          }
        }
        
        request.headers = newHeaders;
        _saveRequest(request);
      },
      onDeleted: (key) {
        if (request.headers != null) {
          final newHeaders = List<RequestHeader>.from(request.headers!);
          newHeaders.removeWhere((h) => h.key == key);
          request.headers = newHeaders;
          _saveRequest(request);
        }
      },
    );
  }

  Widget _buildBodyTab(RequestModel request) {
    final currentType = _getCurrentContentType(request);

    return Column(
      children: [
        // Body Toolbar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.white10)),
          ),
          child: Row(
            children: [
              DropdownButton<String>(
                value: _contentTypes.containsKey(currentType) ? currentType : 'No Body',
                dropdownColor: const Color(0xFF2D2D2D),
                underline: Container(),
                style: GoogleFonts.inter(fontSize: 12, color: Colors.white),
                items: _contentTypes.keys.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    _updateContentType(request, _contentTypes[val]!);
                  }
                },
              ),
              const Spacer(),
              if (currentType == 'JSON' || currentType == 'XML')
                TextButton.icon(
                  onPressed: () => _prettifyBody(request, currentType),
                  icon: const Icon(Icons.auto_fix_high, size: 14),
                  label: Text('Prettify', style: GoogleFonts.inter(fontSize: 12)),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                ),
            ],
          ),
        ),
        // Validation Error Banner
        if (_bodyError != null && currentType != 'No Body' && currentType != 'Form URL Encoded')
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            color: Colors.red.withOpacity(0.1),
            child: Row(
              children: [
                const Icon(Icons.error_outline, size: 14, color: Colors.redAccent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _bodyError!,
                    style: GoogleFonts.inter(fontSize: 11, color: Colors.redAccent),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        
        // Editor Content
        Expanded(
          child: _buildBodyContent(request, currentType),
        ),
      ],
    );
  }

  Widget _buildBodyContent(RequestModel request, String type) {
    switch (type) {
      case 'No Body':
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.block, size: 48, color: Colors.white10),
              const SizedBox(height: 16),
              Text(
                'This request has no body',
                style: GoogleFonts.inter(color: Colors.white24),
              ),
            ],
          ),
        );
      
      case 'Form URL Encoded':
        return _buildUrlEncodedEditor(request);

      default:
        return _buildCodeEditor(request, type);
    }
  }

  Widget _buildUrlEncodedEditor(RequestModel request) {
    // Parse body string "key=value&a=b" to Map
    Map<String, String> formData = {};
    try {
      if (request.body != null && request.body!.isNotEmpty) {
        // Use Uri to parse query string
        final uri = Uri(query: request.body);
        formData = Map.from(uri.queryParameters);
      }
    } catch (e) {
      // If parse fails, start empty
    }

    return KeyValueTable(
      items: formData,
      onChanged: (key, value, oldKey) {
        final currentData = Map<String, String>.from(formData);
        
        if (oldKey.isNotEmpty && oldKey != key) {
          currentData.remove(oldKey);
        }
        if (key.isNotEmpty) {
          currentData[key] = value;
        }

        // Convert back to query string
        final newUri = Uri(queryParameters: currentData);
        request.body = newUri.query;
        _saveRequest(request);
      },
      onDeleted: (key) {
        final currentData = Map<String, String>.from(formData);
        currentData.remove(key);
        final newUri = Uri(queryParameters: currentData);
        request.body = newUri.query;
        _saveRequest(request);
      },
    );
  }

  Widget _buildCodeEditor(RequestModel request, String type) {
    String hint = '';
    if (type == 'JSON') hint = '{\n  "key": "value"\n}';
    else if (type == 'XML') hint = '<root>\n  <key>value</key>\n</root>';
    else hint = 'Enter text content here...';

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _bodyController,
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        style: GoogleFonts.jetBrainsMono(fontSize: 13, height: 1.5),
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.white10),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: _bodyError != null ? Colors.red.withOpacity(0.5) : Colors.white10
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: _bodyError != null 
                  ? Colors.redAccent 
                  : Theme.of(context).colorScheme.primary.withOpacity(0.5)
            ),
          ),
          filled: true,
          fillColor: const Color(0xFF1E1E1E),
          hintText: hint,
          hintStyle: GoogleFonts.jetBrainsMono(color: Colors.white24),
        ),
        onChanged: (val) {
          request.body = val;
          _validateBody(val, type);
          _saveRequest(request);
        },
      ),
    );
  }

  void _saveRequest(RequestModel request) {
    ref.read(collectionsProvider.notifier).updateRequest(request);
    setState(() {});
  }

  String _getCurrentContentType(RequestModel request) {
    final contentTypeHeader = request.headers?.firstWhere(
      (h) => h.key?.toLowerCase() == 'content-type',
      orElse: () => RequestHeader(),
    );
    
    if (contentTypeHeader?.value != null) {
      final val = contentTypeHeader!.value!.toLowerCase();
      if (val.contains('json')) return 'JSON';
      if (val.contains('xml')) return 'XML';
      if (val.contains('text')) return 'Text';
      if (val.contains('urlencoded')) return 'Form URL Encoded';
    }
    return 'No Body';
  }

  void _updateContentType(RequestModel request, String mimeType) {
    final newHeaders = request.headers != null 
        ? List<RequestHeader>.from(request.headers!) 
        : <RequestHeader>[];
    
    final index = newHeaders.indexWhere((h) => h.key?.toLowerCase() == 'content-type');
    
    if (mimeType.isEmpty) {
      if (index != -1) {
        newHeaders.removeAt(index);
      }
      request.body = ''; // Clear body if No Body selected
      _bodyController.clear();
      _bodyError = null;
    } else {
      if (index != -1) {
        newHeaders[index].value = mimeType;
      } else {
        newHeaders.add(RequestHeader()..key = 'Content-Type'..value = mimeType);
      }
    }

    request.headers = newHeaders;
    _saveRequest(request);
  }

  void _validateBody(String text, String type) {
    if (text.isEmpty) {
      setState(() => _bodyError = null);
      return;
    }

    if (type == 'JSON') {
      try {
        json.decode(text);
        setState(() => _bodyError = null);
      } catch (e) {
        setState(() => _bodyError = 'Invalid JSON: ${e.toString()}');
      }
    } else if (type == 'XML') {
      // Basic XML validation (check for root element)
      if (!text.trim().startsWith('<') || !text.trim().endsWith('>')) {
         setState(() => _bodyError = 'Invalid XML format');
      } else {
         setState(() => _bodyError = null);
      }
    } else {
      setState(() => _bodyError = null);
    }
  }

  void _prettifyBody(RequestModel request, String type) {
    final text = _bodyController.text;
    if (text.isEmpty) return;

    String formatted = text;
    if (type == 'JSON') {
      formatted = _tryFormatJson(text);
    } else if (type == 'XML') {
      formatted = _tryFormatXml(text);
    }

    if (formatted != text) {
      request.body = formatted;
      _bodyController.text = formatted;
      _saveRequest(request);
      _validateBody(formatted, type);
    }
  }

  String _tryFormatJson(String text) {
    try {
      final dynamic parsed = json.decode(text);
      final encoder = const JsonEncoder.withIndent('  ');
      return encoder.convert(parsed);
    } catch (e) {
      return text;
    }
  }

  String _tryFormatXml(String text) {
    // Simple XML indenter without external dependencies
    try {
      var xml = text.trim();
      // Remove existing newlines and extra spaces between tags
      xml = xml.replaceAll(RegExp(r'>\s+<'), '><');
      
      var indent = 0;
      var result = StringBuffer();
      
      for (var i = 0; i < xml.length; i++) {
        var char = xml[i];
        
        if (char == '<') {
          // Check if closing tag
          if (i + 1 < xml.length && xml[i + 1] == '/') {
            indent--;
            if (indent < 0) indent = 0;
            result.write('\n${'  ' * indent}');
          } else {
             // Open tag
             if (result.isNotEmpty) result.write('\n${'  ' * indent}');
             indent++;
          }
        }
        
        result.write(char);
        
        if (char == '>') {
           // Check if self-closing
           if (i - 1 >= 0 && xml[i - 1] == '/') {
             indent--;
           }
        }
      }
      return result.toString().trim();
    } catch (e) {
      return text;
    }
  }

  Future<void> _showEnvironmentDialog(BuildContext context, WidgetRef ref) async {
    final activeRequest = ref.read(activeRequestProvider);
    if (activeRequest == null) return;

    final collections = ref.read(collectionsProvider).valueOrNull ?? [];
    final parentCollection = collections.firstWhere(
      (c) => c.requests.any((r) => r.id == activeRequest.id),
      orElse: () => CollectionModel(),
    );

    if (parentCollection.id == 0) return; // Not found

    await showDialog(
      context: context,
      builder: (context) => EnvironmentDialog(collectionId: parentCollection.id),
    );
  }
}

class EnvironmentDialog extends ConsumerStatefulWidget {
  final Id collectionId;
  const EnvironmentDialog({super.key, required this.collectionId});

  @override
  ConsumerState<EnvironmentDialog> createState() => _EnvironmentDialogState();
}

class _EnvironmentDialogState extends ConsumerState<EnvironmentDialog> {
  @override
  Widget build(BuildContext context) {
    final collections = ref.watch(collectionsProvider).valueOrNull ?? [];
    final collection = collections.firstWhere(
      (c) => c.id == widget.collectionId,
      orElse: () => CollectionModel(),
    );

    if (collection.id == 0) {
      return const SizedBox.shrink(); // Collection deleted or not found
    }

    // Ensure links are loaded
    if (!collection.environmentProfiles.isLoaded) {
      collection.environmentProfiles.loadSync();
    }
    if (!collection.activeEnvironment.isLoaded) {
      collection.activeEnvironment.loadSync();
    }

    final profiles = collection.environmentProfiles;
    final activeProfile = collection.activeEnvironment.value;

    return AlertDialog(
      title: Text('Environment: ${collection.name}'),
      content: SizedBox(
        width: 600,
        height: 450,
        child: Column(
          children: [
            // Toolbar
            Row(
              children: [
                const Text('Active Environment:'),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButton<int?>(
                    value: activeProfile?.id,
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('None'),
                      ),
                      ...profiles.map((p) => DropdownMenuItem(
                            value: p.id,
                            child: Text(p.name),
                          )),
                    ],
                    onChanged: (profileId) {
                      ref.read(collectionsProvider.notifier).setActiveEnvironment(collection.id, profileId);
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_note),
                  tooltip: 'Bulk Edit',
                  onPressed: activeProfile == null ? null : () => _showBulkEditDialog(activeProfile),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: 'New Environment',
                  onPressed: () => _addNewProfile(collection.id),
                ),
              ],
            ),
            const Divider(),
            // Key-Value Editor
            Expanded(
              child: activeProfile == null
                  ? const Center(child: Text('No environment selected'))
                  : KeyValueTable(
                      key: ValueKey(activeProfile.id), // Force rebuild when profile changes
                      items: _getVariablesMap(activeProfile),
                      onChanged: (key, value, oldKey) {
                        final newVars = activeProfile.variables != null
                            ? List<EnvironmentVariable>.from(activeProfile.variables!)
                            : <EnvironmentVariable>[];
                        
                        if (oldKey.isEmpty) {
                          newVars.add(EnvironmentVariable()..key = key..value = value);
                        } else {
                          final index = newVars.indexWhere((v) => v.key == oldKey);
                          if (index != -1) {
                            newVars[index].key = key;
                            newVars[index].value = value;
                          } else {
                            newVars.add(EnvironmentVariable()..key = key..value = value);
                          }
                        }
                        ref.read(collectionsProvider.notifier).updateEnvironmentVariables(activeProfile.id, newVars);
                      },
                      onDeleted: (key) {
                        final newVars = List<EnvironmentVariable>.from(activeProfile.variables!);
                        newVars.removeWhere((v) => v.key == key);
                        ref.read(collectionsProvider.notifier).updateEnvironmentVariables(activeProfile.id, newVars);
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Map<String, String> _getVariablesMap(EnvironmentProfile profile) {
    final map = <String, String>{};
    if (profile.variables != null) {
      for (var v in profile.variables!) {
        if (v.key != null && v.key!.isNotEmpty) {
          map[v.key!] = v.value ?? '';
        }
      }
    }
    return map;
  }

  Future<void> _addNewProfile(Id collectionId) async {
    final controller = TextEditingController();
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Environment Profile'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'e.g., DEV, PROD'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty && mounted) {
      await ref.read(collectionsProvider.notifier).addEnvironmentProfile(collectionId, newName);
    }
  }

  Future<void> _showBulkEditDialog(EnvironmentProfile profile) async {
    final currentVars = profile.variables ?? [];
    final text = currentVars.map((v) => '${v.key}:${v.value}').join('\n');
    final controller = TextEditingController(text: text);

    final newText = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Bulk Edit: ${profile.name}'),
        content: SizedBox(
          width: 500,
          child: TextField(
            controller: controller,
            maxLines: 15,
            autofocus: true,
            style: GoogleFonts.jetBrainsMono(fontSize: 13),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'KEY:VALUE\nANOTHER_KEY:ANOTHER_VALUE',
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newText != null && mounted) {
      final newVars = <EnvironmentVariable>[];
      final lines = newText.split('\n');
      for (var line in lines) {
        if (line.trim().isEmpty) continue;
        final parts = line.split(':');
        if (parts.length >= 2) {
          final key = parts.first.trim();
          final value = parts.sublist(1).join(':').trim();
          if (key.isNotEmpty) {
            newVars.add(EnvironmentVariable()..key = key..value = value);
          }
        }
      }
      await ref.read(collectionsProvider.notifier).updateEnvironmentVariables(profile.id, newVars);
    }
  }
}
