import 'dart:collection';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isar/isar.dart';
import 'package:code_text_field/code_text_field.dart';
import '../../../models/collection_model.dart';
import '../../../models/environment_profile_model.dart';
import '../../../models/request_model.dart';
import '../../../providers/active_request_provider.dart';
import '../../../providers/collections_provider.dart';
import '../../../providers/request_execution_provider.dart';
import '../../../utils/http_colors.dart';
import '../../../widgets/key_value_table.dart';
import 'autocomplete_manager.dart';

class RequestEditorWidget extends ConsumerStatefulWidget {
  const RequestEditorWidget({super.key});

  @override
  ConsumerState<RequestEditorWidget> createState() => _RequestEditorWidgetState();
}

class _RequestEditorWidgetState extends ConsumerState<RequestEditorWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;
  CodeController? _urlController;
  CodeController? _bodyController;
  
  // Focus Nodes
  final FocusNode _urlFocusNode = FocusNode();
  final FocusNode _bodyFocusNode = FocusNode();

  final AutocompleteManager _urlAutocompleteManager = AutocompleteManager();
  final AutocompleteManager _bodyAutocompleteManager = AutocompleteManager();
  List<String> _currentEnvKeys = [];

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
    _setupInitialControllers();
  }
  
  void _setupInitialControllers() {
    _urlController = _createCodeController('', []);
    _bodyController = _createCodeController('', []);
    _addListeners();
  }
  
  void _addListeners() {
    _urlController?.addListener(_handleAutocomplete);
    _bodyController?.addListener(_handleAutocomplete);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _urlController?.dispose();
    _bodyController?.dispose();
    _urlFocusNode.dispose();
    _bodyFocusNode.dispose();
    _urlAutocompleteManager.hide(); // Ensure overlay is removed
    _bodyAutocompleteManager.hide(); // Ensure overlay is removed
    super.dispose();
  }

  void _updateCodeControllers(RequestModel activeRequest) {
    final collections = ref.read(collectionsProvider).valueOrNull ?? [];
    final parentCollection = collections.firstWhere(
      (c) => c.requests.any((r) => r.id == activeRequest.id),
      orElse: () => CollectionModel(),
    );

    _currentEnvKeys = [];
    if (parentCollection.id != 0) {
      parentCollection.activeEnvironment.loadSync();
      final activeProfile = parentCollection.activeEnvironment.value;
      if (activeProfile != null) {
        activeProfile.variables?.forEach((v) {
          if (v.key != null) _currentEnvKeys.add(v.key!);
        });
      }
    }
    
    final oldUrlSelection = _urlController?.selection;
    final oldBodySelection = _bodyController?.selection;
    
    _urlController?.dispose();
    _bodyController?.dispose();

    _urlController = _createCodeController(activeRequest.url, _currentEnvKeys);
    _bodyController = _createCodeController(activeRequest.body ?? '', _currentEnvKeys);
    _addListeners();
    
    if (oldUrlSelection != null) _urlController?.selection = oldUrlSelection;
    if (oldBodySelection != null) _bodyController?.selection = oldBodySelection;
  }

  void _clearCodeControllers() {
    _urlController?.dispose();
    _bodyController?.dispose();
    _urlController = _createCodeController('', []);
    _bodyController = _createCodeController('', []);
    _addListeners();
  }

  CodeController _createCodeController(String text, List<String> envKeys) {
    final patternMap = LinkedHashMap<String, TextStyle>();

    if (envKeys.isNotEmpty) {
      final escapedKeys = envKeys.map((k) => RegExp.escape(k)).toList();
      final validKeysPattern = r'\{\{(?:' + escapedKeys.join('|') + r')\}\}';
      patternMap[validKeysPattern] = const TextStyle(color: Colors.green, fontWeight: FontWeight.bold);
    }

    patternMap[r'\{\{[^}]*\}\}'] = const TextStyle(color: Colors.redAccent);

    return CodeController(
      text: text,
      patternMap: patternMap,
    );
  }
  
  void _handleAutocomplete() {
    CodeController? controller;
    AutocompleteManager? currentAutocompleteManager;
    
    if (_urlFocusNode.hasFocus) {
      controller = _urlController;
      currentAutocompleteManager = _urlAutocompleteManager;
      _bodyAutocompleteManager.hide(); // Hide other autocomplete if switching focus
    } else if (_bodyFocusNode.hasFocus) {
      controller = _bodyController;
      currentAutocompleteManager = _bodyAutocompleteManager;
      _urlAutocompleteManager.hide(); // Hide other autocomplete if switching focus
    } else {
      _urlAutocompleteManager.hide(); // Hide all if no relevant focus
      _bodyAutocompleteManager.hide();
      return;
    }

    if (controller == null || currentAutocompleteManager == null) {
      _urlAutocompleteManager.hide();
      _bodyAutocompleteManager.hide();
      return;
    }

    final text = controller.text;
    final selection = controller.selection;
    if (!selection.isCollapsed || selection.baseOffset < 0 || selection.baseOffset > text.length) {
      currentAutocompleteManager.hide();
      return;
    }

    // Find the last '{{' before the cursor
    final beforeCursor = text.substring(0, selection.baseOffset);
    final triggerIndex = beforeCursor.lastIndexOf('{{');

    if (triggerIndex != -1) {
      // Check if we are inside a variable block (i.e., no closing '}}' before cursor)
      final afterTrigger = beforeCursor.substring(triggerIndex + 2);
      if (!afterTrigger.contains('}}')) {
        final partial = afterTrigger;
        final suggestions = _currentEnvKeys
            .where((key) => key.toLowerCase().startsWith(partial.toLowerCase()))
            .toList();

        if (suggestions.isNotEmpty) {
          currentAutocompleteManager.showSuggestions(
            context,
            controller,
            suggestions,
            (selected) {
              final newText = text.substring(0, triggerIndex) +
                  '{{$selected}}' +
                  text.substring(selection.baseOffset);
              controller!.text = newText;
              controller.selection = TextSelection.fromPosition(
                TextPosition(offset: triggerIndex + selected.length + 4),
              );
              // Trigger save
              final activeRequest = ref.read(activeRequestProvider);
              if (activeRequest != null) {
                if (controller == _urlController) {
                  activeRequest.url = newText;
                } else {
                  activeRequest.body = newText;
                }
                _saveRequest(activeRequest);
              }
            },
          );
          return;
        }
      }
    }
    
    currentAutocompleteManager.hide();
  }

  @override
  Widget build(BuildContext context) {
    final activeRequest = ref.watch(activeRequestProvider);

    ref.listen(collectionsProvider, (previous, next) {
       if (activeRequest != null) {
         setState(() {
           _updateCodeControllers(activeRequest);
         });
       }
    });

    ref.listen(activeRequestProvider, (previous, next) {
      if (previous?.id != next?.id) {
        setState(() {
          if (next != null) {
            _updateCodeControllers(next);
          } else {
            _clearCodeControllers();
          }
        });
      }
    });

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

    if (_urlController?.text != activeRequest.url) {
       _urlController?.text = activeRequest.url;
    }
    
    if (_bodyController?.text != (activeRequest.body ?? '')) {
      _bodyController?.text = activeRequest.body ?? '';
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
          tabs: [
            _buildTabHeader("Params"),
            _buildTabHeader("Headers"),
            _buildTabHeader("Body"),
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

  Widget _buildTabHeader(String title) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title),
          if (title == 'Params' || title == 'Headers') ...[
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.edit_note, size: 16),
              tooltip: 'Bulk Edit',
              onPressed: () {
                if (title == 'Params') {
                  _showBulkEditDialogForParams(ref.read(activeRequestProvider)!);
                } else {
                  _showBulkEditDialogForHeaders(ref.read(activeRequestProvider)!);
                }
              },
            )
          ]
        ],
      ),
    );
  }

  Widget _buildTopBar(
      BuildContext context, WidgetRef ref, RequestModel request) {
    
    final collections = ref.watch(collectionsProvider).valueOrNull ?? [];
    final parentCollection = collections.firstWhere(
      (c) => c.requests.any((r) => r.id == request.id),
      orElse: () => CollectionModel(),
    );
    
    if (parentCollection.id != 0) {
      parentCollection.activeEnvironment.loadSync();
    }
    final activeProfile = parentCollection.activeEnvironment.value;

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
            child: CompositedTransformTarget(
              link: _urlAutocompleteManager.layerLink,
              child: CodeField(
                controller: _urlController!,
                focusNode: _urlFocusNode,
                textStyle: GoogleFonts.inter(fontSize: 14),
                onChanged: (val) {
                  request.url = val;
                  _saveRequest(request);
                },
              ),
            ),
          ),
          const SizedBox(width: 16),
          if (activeProfile != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                activeProfile.name,
                style: GoogleFonts.inter(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
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

  Map<String, String> _parseParamsFromUrl(String url) {
    if (url.isEmpty) return {};
    try {
      final queryIndex = url.indexOf('?');
      if (queryIndex == -1) return {};
      
      final queryString = url.substring(queryIndex + 1);
      return Uri.splitQueryString(queryString);
    } catch (e) {
      return {};
    }
  }

  void _updateUrlWithParams(RequestModel request, Map<String, String> newParams) {
    try {
      final url = request.url;
      final queryIndex = url.indexOf('?');
      final baseUrl = queryIndex == -1 ? url : url.substring(0, queryIndex);
      
      if (newParams.isEmpty) {
        if (queryIndex != -1) {
           request.url = baseUrl;
           _saveRequest(request);
        }
        return;
      }

      // Manually build query string to control encoding
      final pairs = <String>[];
      newParams.forEach((key, value) {
        // Encode key and value, but then restore {{ and }}
        String encodedKey = Uri.encodeQueryComponent(key);
        String encodedValue = Uri.encodeQueryComponent(value);
        
        encodedKey = _restoreVariableBraces(encodedKey);
        encodedValue = _restoreVariableBraces(encodedValue);
        
        pairs.add('$encodedKey=$encodedValue');
      });
      
      final queryString = pairs.join('&');
      request.url = '$baseUrl?$queryString';
      _saveRequest(request);
    } catch (e) {
      // Ignore
    }
  }

  String _restoreVariableBraces(String text) {
    return text
      .replaceAll('%7B%7B', '{{')
      .replaceAll('%7D%7D', '}}')
      .replaceAll('%7b%7b', '{{')
      .replaceAll('%7d%7d', '}}');
  }

  Widget _buildParamsTab(RequestModel request) {
    final params = _parseParamsFromUrl(request.url);

    return KeyValueTable(
      items: params,
      envKeys: _currentEnvKeys,
      onChanged: (key, value, oldKey) {
        final currentParams = Map<String, String>.from(params);
        if (oldKey.isNotEmpty && oldKey != key) {
          currentParams.remove(oldKey);
        }
        if (key.isNotEmpty) {
          currentParams[key] = value;
        }
        _updateUrlWithParams(request, currentParams);
      },
      onDeleted: (key) {
        final currentParams = Map<String, String>.from(params);
        currentParams.remove(key);
        _updateUrlWithParams(request, currentParams);
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
      envKeys: _currentEnvKeys,
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
      envKeys: _currentEnvKeys,
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
      child: CompositedTransformTarget(
        link: _bodyAutocompleteManager.layerLink,
        child: CodeField(
          controller: _bodyController!,
          focusNode: _bodyFocusNode,
          textStyle: GoogleFonts.jetBrainsMono(fontSize: 13, height: 1.5),
          onChanged: (val) {
            request.body = val;
            _validateBody(val, type);
            _saveRequest(request);
          },
        ),
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
    _urlAutocompleteManager.hide(); // Hide any active autocomplete
    _bodyAutocompleteManager.hide(); // Hide any active autocomplete

    final newHeaders = request.headers != null 
        ? List<RequestHeader>.from(request.headers!) 
        : <RequestHeader>[];
    
    final index = newHeaders.indexWhere((h) => h.key?.toLowerCase() == 'content-type');
    
    if (mimeType.isEmpty) {
      if (index != -1) {
        newHeaders.removeAt(index);
      }
      request.body = ''; // Clear body if No Body selected
      _bodyController?.clear();
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
    final text = _bodyController?.text ?? '';
    if (text.isEmpty) return;

    String formatted = text;
    if (type == 'JSON') {
      formatted = _tryFormatJson(text);
    } else if (type == 'XML') {
      formatted = _tryFormatXml(text);
    }

    if (formatted != text) {
      request.body = formatted;
      _bodyController?.text = formatted;
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

  Future<void> _showBulkEditDialogForParams(RequestModel request) async {
    final params = _parseParamsFromUrl(request.url);
    final text = params.entries.map((e) => '${e.key}:${e.value}').join('\n');
    final newText = await _showBulkEditDialog(context, 'Params', text);

    if (newText != null) {
      final newParams = _parseBulkText(newText);
      _updateUrlWithParams(request, newParams);
    }
  }

  Future<void> _showBulkEditDialogForHeaders(RequestModel request) async {
    final text = (request.headers ?? []).map((h) => '${h.key}:${h.value}').join('\n');
    final newText = await _showBulkEditDialog(context, 'Headers', text);

    if (newText != null) {
      final newHeadersMap = _parseBulkText(newText);
      request.headers = newHeadersMap.entries
          .map((e) => RequestHeader()..key = e.key..value = e.value)
          .toList();
      _saveRequest(request);
    }
  }

  Map<String, String> _parseBulkText(String text) {
    final map = <String, String>{};
    final lines = text.split('\n');
    for (var line in lines) {
      if (line.trim().isEmpty) continue;
      final parts = line.split(':');
      if (parts.length >= 2) {
        final key = parts.first.trim();
        final value = parts.sublist(1).join(':').trim();
        if (key.isNotEmpty) {
          map[key] = value;
        }
      }
    }
    return map;
  }

  Future<String?> _showBulkEditDialog(BuildContext context, String title, String initialText) async {
    final controller = TextEditingController(text: initialText);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Bulk Edit: $title'),
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
                  onPressed: activeProfile == null ? null : () => _showBulkEditDialogForEnv(activeProfile),
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

  Future<void> _showBulkEditDialogForEnv(EnvironmentProfile profile) async {
    final currentVars = profile.variables ?? [];
    final text = currentVars.map((v) => '${v.key}:${v.value}').join('\n');
    final newText = await _showBulkEditDialog(context, 'Environment: ${profile.name}', text);

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

  Future<String?> _showBulkEditDialog(BuildContext context, String title, String initialText) async {
    final controller = TextEditingController(text: initialText);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Bulk Edit: $title'),
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
  }
}
