import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/request_model.dart';
import '../../../providers/active_request_provider.dart';
import '../../../providers/request_execution_provider.dart';
import '../../../providers/collections_provider.dart';
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
    if (_bodyController.text != (activeRequest.body ?? '')) {
      _bodyController.text = activeRequest.body ?? '';
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
        Container(
          height: 1,
          color: Colors.white10,
        ),
        _buildResponsePanel(ref),
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
      // Ignore parse errors for now, or show empty params
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
          } else if (oldKey.isNotEmpty && key.isEmpty) {
             // Case where key is cleared? KeyValueTable usually handles this by not calling onChanged with empty key unless it's a new row.
             // But if user clears key, we might want to remove it?
             // The KeyValueTable implementation calls onChanged with empty key if we clear it?
             // Let's assume if key is empty, we don't add it to params map.
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
    // Convert List<RequestHeader> to Map<String, String> for the widget
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
        // Create a new list instead of modifying the existing one directly
        final newHeaders = request.headers != null 
            ? List<RequestHeader>.from(request.headers!) 
            : <RequestHeader>[];
        
        if (oldKey.isEmpty) {
          // Add new
          newHeaders.add(RequestHeader()..key = key..value = value);
        } else {
          // Update
          final index = newHeaders.indexWhere((h) => h.key == oldKey);
          if (index != -1) {
            newHeaders[index].key = key;
            newHeaders[index].value = value;
          } else {
            // Fallback: add if not found
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
            borderSide: const BorderSide(color: Colors.white10),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
          ),
          filled: true,
          fillColor: const Color(0xFF1E1E1E),
          hintText: '{\n  "key": "value"\n}',
          hintStyle: GoogleFonts.jetBrainsMono(color: Colors.white24),
        ),
        onChanged: (val) {
          request.body = val;
          _saveRequest(request);
        },
      ),
    );
  }

  Widget _buildResponsePanel(WidgetRef ref) {
    final executionState = ref.watch(requestExecutionProvider);

    return SizedBox(
      height: 300,
      child: executionState.when(
        data: (response) {
          if (response == null) {
            return Center(
              child: Text(
                'Ready to send request',
                style: GoogleFonts.inter(color: Colors.white24),
              ),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: const Color(0xFF252526),
                child: Row(
                  children: [
                    _buildStatusBadge(response.statusCode),
                    const SizedBox(width: 24),
                    _buildMetric(Icons.timer_outlined, '${response.executionTimeMs}ms'),
                    const SizedBox(width: 24),
                    _buildMetric(Icons.data_usage, '${response.responseSizeBytes} B'),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: const Color(0xFF1E1E1E),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      response.body.toString(),
                      style: GoogleFonts.jetBrainsMono(fontSize: 12, height: 1.5),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
      ),
    );
  }

  Widget _buildStatusBadge(int statusCode) {
    final color = HttpColors.getStatusCodeColor(statusCode);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$statusCode',
            style: GoogleFonts.inter(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.white54),
        const SizedBox(width: 6),
        Text(
          text,
          style: GoogleFonts.inter(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  void _saveRequest(RequestModel request) {
    ref.read(collectionsProvider.notifier).updateRequest(request);
    setState(() {});
  }
}
