import 'dart:collection';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isar/isar.dart';
import 'package:code_text_field/code_text_field.dart';
import 'package:highlight/languages/json.dart' as highlight_json;
import 'package:highlight/languages/xml.dart' as highlight_xml;
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import '../../../models/collection_model.dart';
import '../../../models/environment_profile_model.dart';
import '../../../models/request_model.dart';
import '../../../providers/active_request_provider.dart';
import '../../../providers/collections_provider.dart';
import '../../../providers/request_execution_provider.dart';
import '../../../utils/http_colors.dart';
import '../../../widgets/key_value_table.dart';
import 'autocomplete_manager.dart';
import '../../settings/providers/settings_provider.dart';

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
  
  final FocusNode _urlFocusNode = FocusNode();
  final FocusNode _bodyFocusNode = FocusNode();

  final AutocompleteManager _urlAutocompleteManager = AutocompleteManager();
  final AutocompleteManager _bodyAutocompleteManager = AutocompleteManager();
  List<String> _currentEnvKeys = [];

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
    _tabController = TabController(length: 4, vsync: this);
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
    _urlAutocompleteManager.hide();
    _bodyAutocompleteManager.hide();
    super.dispose();
  }

  bool _areListsEqual(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  CollectionModel? _findParentCollection(List<CollectionModel> collections, RequestModel request) {
    for (var col in collections) {
      if (col.requests.any((r) => r.id == request.id)) return col;
      for (var folder in col.folders) {
        if (folder.requests.any((r) => r.id == request.id)) return col;
      }
    }
    return null;
  }

  void _updateCodeControllers(RequestModel activeRequest) {
    final collections = ref.read(collectionsProvider).valueOrNull ?? [];
    final parentCollection = _findParentCollection(collections, activeRequest);

    List<String> newEnvKeys = [];
    if (parentCollection != null) {
      try {
        parentCollection.activeEnvironment.loadSync();
        final activeProfile = parentCollection.activeEnvironment.value;
        if (activeProfile != null) {
          activeProfile.variables?.forEach((v) {
            if (v.key != null) newEnvKeys.add(v.key!);
          });
        }
      } catch (e) {
        print('Error loading environment: $e');
      }
    }
    
    bool envKeysChanged = !_areListsEqual(_currentEnvKeys, newEnvKeys);
    _currentEnvKeys = newEnvKeys;
    
    if (_urlController == null || envKeysChanged || _urlController!.text != activeRequest.url) {
      final oldUrlSelection = _urlController?.selection;
      _urlController?.dispose();
      _urlController = _createCodeController(activeRequest.url, _currentEnvKeys);
      _urlController?.addListener(_handleAutocomplete);
      if (oldUrlSelection != null) _urlController?.selection = oldUrlSelection;
    }

    final contentType = _getCurrentContentType(activeRequest);
    dynamic language;
    if (contentType == 'JSON') language = highlight_json.json;
    if (contentType == 'XML') language = highlight_xml.xml;

    bool languageChanged = _bodyController?.language != language;

    if (_bodyController == null || envKeysChanged || _bodyController!.text != (activeRequest.body ?? '') || languageChanged) {
      if (_bodyController != null && !envKeysChanged && _bodyController!.text == (activeRequest.body ?? '')) {
         _bodyController!.language = language;
      } else {
         final oldBodySelection = _bodyController?.selection;
         _bodyController?.dispose();
         _bodyController = _createCodeController(activeRequest.body ?? '', _currentEnvKeys, language: language);
         _bodyController?.addListener(_handleAutocomplete);
         if (oldBodySelection != null) _bodyController?.selection = oldBodySelection;
      }
    }
  }

  void _clearCodeControllers() {
    _urlController?.dispose();
    _bodyController?.dispose();
    _urlController = _createCodeController('', []);
    _bodyController = _createCodeController('', []);
    _addListeners();
  }

  CodeController _createCodeController(String text, List<String> envKeys, {dynamic language}) {
    final patternMap = LinkedHashMap<String, TextStyle>();
    if (envKeys.isNotEmpty) {
      final escapedKeys = envKeys.map((k) => RegExp.escape(k)).toList();
      final validKeysPattern = r'\{\{(?:' + escapedKeys.join('|') + r')\}\}';
      patternMap[validKeysPattern] = const TextStyle(color: Colors.green, fontWeight: FontWeight.bold);
    }
    patternMap[r'\{\{[^}]*\}\}'] = const TextStyle(color: Colors.redAccent);
    return CodeController(text: text, patternMap: patternMap, language: language, modifiers: const []);
  }
  
  void _handleAutocomplete() {
    // ... (código existente)
  }

  @override
  Widget build(BuildContext context) {
    final activeRequest = ref.watch(activeRequestProvider);
    final settingsAsync = ref.watch(settingsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    ref.listen(collectionsProvider, (previous, next) {
       if (activeRequest != null) setState(() => _updateCodeControllers(activeRequest));
    });

    ref.listen(activeRequestProvider, (previous, next) {
      if (previous?.id != next?.id) {
        setState(() {
          if (next != null) _updateCodeControllers(next);
          else _clearCodeControllers();
        });
      }
    });

    if (activeRequest == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bolt, size: 64, color: colorScheme.onSurface.withOpacity(0.1)),
            const SizedBox(height: 16),
            Text('Select a request to start', style: GoogleFonts.inter(color: colorScheme.onSurface.withOpacity(0.4))),
          ],
        ),
      );
    }

    if (_urlController?.text != activeRequest.url) {
       if (_urlController == null) {
          _urlController = _createCodeController(activeRequest.url, _currentEnvKeys);
          _urlController?.addListener(_handleAutocomplete);
       } else if (_urlController!.text != activeRequest.url) {
          _urlController!.text = activeRequest.url;
       }
    }
    
    if (_bodyController?.text != (activeRequest.body ?? '')) {
       if (_bodyController == null) {
          final contentType = _getCurrentContentType(activeRequest);
          dynamic language;
          if (contentType == 'JSON') language = highlight_json.json;
          if (contentType == 'XML') language = highlight_xml.xml;
          _bodyController = _createCodeController(activeRequest.body ?? '', _currentEnvKeys, language: language);
          _bodyController?.addListener(_handleAutocomplete);
       } else if (_bodyController!.text != (activeRequest.body ?? '')) {
          _bodyController!.text = activeRequest.body ?? '';
       }
    }

    return Column(
      children: [
        _buildTopBar(context, ref, activeRequest),
        Container(height: 1, color: Theme.of(context).dividerColor),
        TabBar(
          controller: _tabController,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurface.withOpacity(0.6),
          indicatorColor: colorScheme.primary,
          dividerColor: Colors.transparent,
          labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
          tabs: [
            _buildTabHeader("Params"),
            _buildTabHeader("Auth"),
            _buildTabHeader("Headers"),
            _buildTabHeader("Body"),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildParamsTab(activeRequest),
              _buildAuthTab(activeRequest),
              _buildHeadersTab(activeRequest),
              _buildBodyTab(activeRequest, settingsAsync.value?.editorFontSize ?? 14.0, settingsAsync.value?.editorWordWrap ?? false),
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

  Widget _buildTopBar(BuildContext context, WidgetRef ref, RequestModel request) {
    final collections = ref.watch(collectionsProvider).valueOrNull ?? [];
    final parentCollection = _findParentCollection(collections, request);
    final colorScheme = Theme.of(context).colorScheme;
    
    EnvironmentProfile? activeProfile;
    if (parentCollection != null) {
      try {
        parentCollection.activeEnvironment.loadSync();
        activeProfile = parentCollection.activeEnvironment.value;
      } catch (e) {
        // Ignore
      }
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: request.method,
                dropdownColor: colorScheme.surface,
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
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CompositedTransformTarget(
                link: _urlAutocompleteManager.layerLink,
                child: CodeField(
                  controller: _urlController!,
                  focusNode: _urlFocusNode,
                  textStyle: GoogleFonts.inter(fontSize: 14, color: colorScheme.onSurface),
                  background: Colors.transparent,
                  cursorColor: colorScheme.primary,
                  onChanged: (val) {
                    request.url = val;
                    _saveRequest(request);
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          if (activeProfile != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                activeProfile.name,
                style: GoogleFonts.inter(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          IconButton(
            icon: Icon(Icons.code, color: colorScheme.onSurface.withOpacity(0.6)),
            tooltip: 'Collection Environment',
            onPressed: () => _showEnvironmentDialog(context, ref),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () => ref.read(requestExecutionProvider.notifier).execute(),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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

  Widget _buildAuthTab(RequestModel request) {
    request.auth ??= RequestAuth();
    final auth = request.auth!;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Authentication Type', style: GoogleFonts.inter(color: colorScheme.onSurface.withOpacity(0.7))),
              const SizedBox(width: 16),
              DropdownButton<String>(
                value: auth.type,
                dropdownColor: colorScheme.surface,
                style: GoogleFonts.inter(color: colorScheme.onSurface),
                items: const [
                  DropdownMenuItem(value: 'no_auth', child: Text('No Auth')),
                  DropdownMenuItem(value: 'basic', child: Text('Basic Auth')),
                  DropdownMenuItem(value: 'bearer', child: Text('Bearer Token')),
                  DropdownMenuItem(value: 'api_key', child: Text('API Key')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() => auth.type = val);
                    _saveRequest(request);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (auth.type == 'basic') ..._buildBasicAuthFields(request),
          if (auth.type == 'bearer') ..._buildBearerTokenFields(request),
          if (auth.type == 'api_key') ..._buildApiKeyFields(request),
        ],
      ),
    );
  }

  List<Widget> _buildBasicAuthFields(RequestModel request) {
    return [
      _buildAuthTextField(
        label: 'Username',
        initialValue: request.auth!.basicUsername ?? '',
        onChanged: (val) {
          request.auth!.basicUsername = val;
          _saveRequest(request);
        },
      ),
      const SizedBox(height: 16),
      _buildAuthTextField(
        label: 'Password',
        initialValue: request.auth!.basicPassword ?? '',
        obscureText: true,
        onChanged: (val) {
          request.auth!.basicPassword = val;
          _saveRequest(request);
        },
      ),
    ];
  }

  List<Widget> _buildBearerTokenFields(RequestModel request) {
    return [
      _buildAuthTextField(
        label: 'Token',
        initialValue: request.auth!.bearerToken ?? '',
        onChanged: (val) {
          request.auth!.bearerToken = val;
          _saveRequest(request);
        },
      ),
    ];
  }

  List<Widget> _buildApiKeyFields(RequestModel request) {
    final colorScheme = Theme.of(context).colorScheme;
    return [
      _buildAuthTextField(
        label: 'Key',
        initialValue: request.auth!.apiKeyKey ?? '',
        onChanged: (val) {
          request.auth!.apiKeyKey = val;
          _saveRequest(request);
        },
      ),
      const SizedBox(height: 16),
      _buildAuthTextField(
        label: 'Value',
        initialValue: request.auth!.apiKeyValue ?? '',
        onChanged: (val) {
          request.auth!.apiKeyValue = val;
          _saveRequest(request);
        },
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          Text('Add to', style: GoogleFonts.inter(color: colorScheme.onSurface.withOpacity(0.7))),
          const SizedBox(width: 16),
          DropdownButton<String>(
            value: request.auth!.apiKeyLocation ?? 'header',
            dropdownColor: colorScheme.surface,
            style: GoogleFonts.inter(color: colorScheme.onSurface),
            items: const [
              DropdownMenuItem(value: 'header', child: Text('Header')),
              DropdownMenuItem(value: 'query', child: Text('Query Params')),
            ],
            onChanged: (val) {
              if (val != null) {
                setState(() => request.auth!.apiKeyLocation = val);
                _saveRequest(request);
              }
            },
          ),
        ],
      ),
    ];
  }

  Widget _buildAuthTextField({
    required String label,
    required String initialValue,
    required ValueChanged<String> onChanged,
    bool obscureText = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return TextFormField(
      initialValue: initialValue,
      obscureText: obscureText,
      style: GoogleFonts.inter(fontSize: 13, color: colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      onChanged: onChanged,
    );
  }

  Map<String, String> _parseParamsFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return Map.from(uri.queryParameters);
    } catch (e) {
      return {};
    }
  }

  void _updateUrlWithParams(RequestModel request, Map<String, String> params) {
    try {
      var uri = Uri.parse(request.url);
      uri = uri.replace(queryParameters: params);
      request.url = uri.toString();
      _saveRequest(request);
      if (_urlController?.text != request.url) {
        _urlController?.text = request.url;
      }
    } catch (e) {
      // Ignore invalid URL
    }
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

  Widget _buildBodyTab(RequestModel request, double fontSize, bool wordWrap) {
    final currentType = _getCurrentContentType(request);
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
          ),
          child: Row(
            children: [
              DropdownButton<String>(
                value: _contentTypes.containsKey(currentType) ? currentType : 'No Body',
                dropdownColor: colorScheme.surface,
                underline: Container(),
                style: GoogleFonts.inter(fontSize: 12, color: colorScheme.onSurface),
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
                    foregroundColor: colorScheme.secondary,
                  ),
                ),
            ],
          ),
        ),
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
        Expanded(
          child: _buildBodyContent(request, currentType, fontSize, wordWrap),
        ),
      ],
    );
  }

  Widget _buildBodyContent(RequestModel request, String type, double fontSize, bool wordWrap) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (type) {
      case 'No Body':
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.block, size: 48, color: colorScheme.onSurface.withOpacity(0.1)),
              const SizedBox(height: 16),
              Text(
                'This request has no body',
                style: GoogleFonts.inter(color: colorScheme.onSurface.withOpacity(0.3)),
              ),
            ],
          ),
        );
      case 'Form URL Encoded':
        return _buildUrlEncodedEditor(request);
      default:
        return _buildCodeEditor(request, type, fontSize, wordWrap);
    }
  }

  Widget _buildUrlEncodedEditor(RequestModel request) {
    Map<String, String> formData = {};
    try {
      if (request.body != null && request.body!.isNotEmpty) {
        final uri = Uri(query: request.body);
        formData = Map.from(uri.queryParameters);
      }
    } catch (e) {
      // Ignore
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

  Widget _buildCodeEditor(RequestModel request, String type, double fontSize, bool wordWrap) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: CompositedTransformTarget(
        link: _bodyAutocompleteManager.layerLink,
        child: CodeTheme(
          data: CodeThemeData(styles: atomOneDarkTheme),
          child: CodeField(
            controller: _bodyController!,
            focusNode: _bodyFocusNode,
            textStyle: GoogleFonts.jetBrainsMono(fontSize: fontSize, height: 1.5),
            lineNumbers: true,
            wrap: wordWrap,
            lineNumberStyle: LineNumberStyle(
              textStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.4), fontSize: 12),
              width: 48,
              margin: 0,
            ),
            background: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5),
            cursorColor: colorScheme.primary,
            onChanged: (val) {
              request.body = val;
              _validateBody(val, type);
              _saveRequest(request);
            },
          ),
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
    _urlAutocompleteManager.hide();
    _bodyAutocompleteManager.hide();

    final newHeaders = request.headers != null 
        ? List<RequestHeader>.from(request.headers!) 
        : <RequestHeader>[];
    
    final index = newHeaders.indexWhere((h) => h.key?.toLowerCase() == 'content-type');
    
    if (mimeType.isEmpty) {
      if (index != -1) {
        newHeaders.removeAt(index);
      }
      request.body = '';
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
    
    _updateCodeControllers(request);
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
    try {
      var xml = text.trim();
      xml = xml.replaceAll(RegExp(r'>\s+<'), '><');
      var indent = 0;
      var result = StringBuffer();
      for (var i = 0; i < xml.length; i++) {
        var char = xml[i];
        if (char == '<') {
          if (i + 1 < xml.length && xml[i + 1] == '/') {
            indent--;
            if (indent < 0) indent = 0;
            result.write('\n${'  ' * indent}');
          } else {
             if (result.isNotEmpty) result.write('\n${'  ' * indent}');
             indent++;
          }
        }
        result.write(char);
        if (char == '>') {
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
    final parentCollection = _findParentCollection(collections, activeRequest);

    if (parentCollection == null || parentCollection.id == 0) return;

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
    final colorScheme = Theme.of(context).colorScheme;
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Bulk Edit: $title'),
        backgroundColor: colorScheme.surface,
        content: SizedBox(
          width: 500,
          child: TextField(
            controller: controller,
            maxLines: 15,
            autofocus: true,
            style: GoogleFonts.jetBrainsMono(fontSize: 13, color: colorScheme.onSurface),
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: 'KEY:VALUE\nANOTHER_KEY:ANOTHER_VALUE',
              hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.4)),
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
      return const SizedBox.shrink();
    }

    if (!collection.environmentProfiles.isLoaded) {
      collection.environmentProfiles.loadSync();
    }
    if (!collection.activeEnvironment.isLoaded) {
      collection.activeEnvironment.loadSync();
    }

    final profiles = collection.environmentProfiles;
    final activeProfile = collection.activeEnvironment.value;
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Text('Environment: ${collection.name}'),
      backgroundColor: colorScheme.surface,
      content: SizedBox(
        width: 600,
        height: 450,
        child: Column(
          children: [
            Row(
              children: [
                Text('Active Environment:', style: TextStyle(color: colorScheme.onSurface)),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButton<int?>(
                    value: activeProfile?.id,
                    dropdownColor: colorScheme.surface,
                    style: GoogleFonts.inter(color: colorScheme.onSurface),
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text('None', style: TextStyle(color: colorScheme.onSurface)),
                      ),
                      ...profiles.map((p) => DropdownMenuItem(
                            value: p.id,
                            child: Text(p.name, style: TextStyle(color: colorScheme.onSurface)),
                          )),
                    ],
                    onChanged: (profileId) {
                      ref.read(collectionsProvider.notifier).setActiveEnvironment(collection.id, profileId);
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit_note, color: colorScheme.onSurface.withOpacity(0.6)),
                  tooltip: 'Bulk Edit',
                  onPressed: activeProfile == null ? null : () => _showBulkEditDialogForEnv(activeProfile),
                ),
                IconButton(
                  icon: Icon(Icons.add, color: colorScheme.onSurface.withOpacity(0.6)),
                  tooltip: 'New Environment',
                  onPressed: () => _addNewProfile(collection.id),
                ),
              ],
            ),
            Divider(height: 1, color: Theme.of(context).dividerColor),
            Expanded(
              child: activeProfile == null
                  ? Center(child: Text('No environment selected', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6))))
                  : KeyValueTable(
                      key: ValueKey(activeProfile.id),
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
    final colorScheme = Theme.of(context).colorScheme;
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Bulk Edit: $title'),
        backgroundColor: colorScheme.surface,
        content: SizedBox(
          width: 500,
          child: TextField(
            controller: controller,
            maxLines: 15,
            autofocus: true,
            style: GoogleFonts.jetBrainsMono(fontSize: 13, color: colorScheme.onSurface),
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: 'KEY:VALUE\nANOTHER_KEY:ANOTHER_VALUE',
              hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.4)),
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
