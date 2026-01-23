import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/request_model.dart';
import '../../../providers/active_request_provider.dart';
import '../../../providers/request_execution_provider.dart';
import '../../../providers/collections_provider.dart';

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
      return const Center(
        child: Text('Select a request to start'),
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
        TabBar(
          controller: _tabController,
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
              const Center(child: Text('Params (Not implemented yet)')),
              _buildHeadersTab(activeRequest),
              _buildBodyTab(activeRequest),
            ],
          ),
        ),
        const Divider(),
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
          DropdownButton<String>(
            value: request.method,
            items: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH']
                .map((m) => DropdownMenuItem(
                      value: m,
                      child: Text(
                        m,
                        style: TextStyle(
                            color: _getMethodColor(m),
                            fontWeight: FontWeight.bold),
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
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                hintText: 'Enter request URL',
                border: OutlineInputBorder(),
              ),
              onChanged: (val) {
                request.url = val;
                _saveRequest(request);
              },
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: () {
              ref.read(requestExecutionProvider.notifier).execute();
            },
            icon: const Icon(Icons.send),
            label: const Text('Send'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeadersTab(RequestModel request) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (request.headers != null)
          ...request.headers!.asMap().entries.map((entry) {
            final index = entry.key;
            final header = entry.value;
            return Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: header.key,
                    decoration: const InputDecoration(labelText: 'Key'),
                    onChanged: (val) {
                      header.key = val;
                      _saveRequest(request);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: header.value,
                    decoration: const InputDecoration(labelText: 'Value'),
                    onChanged: (val) {
                      header.value = val;
                      _saveRequest(request);
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    request.headers!.removeAt(index);
                    _saveRequest(request);
                  },
                ),
              ],
            );
          }),
        TextButton.icon(
          onPressed: () {
            request.headers ??= [];
            request.headers!.add(RequestHeader());
            _saveRequest(request);
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Header'),
        ),
      ],
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
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Request Body (JSON, Text, etc.)',
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
            return const Center(child: Text('No response yet'));
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      'Status: ${response.statusCode}',
                      style: TextStyle(
                        color: response.statusCode >= 200 && response.statusCode < 300
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text('Time: ${response.executionTimeMs}ms'),
                    const SizedBox(width: 16),
                    Text('Size: ${response.responseSizeBytes} B'),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: SelectableText(response.body.toString()),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
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

  void _saveRequest(RequestModel request) {
    ref.read(collectionsProvider.notifier).updateRequest(request);
  }
}
