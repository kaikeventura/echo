import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../features/request/presentation/autocomplete_manager.dart';

class KeyValueTable extends StatefulWidget {
  final Map<String, String> items;
  final List<String> envKeys;
  final Function(String key, String value, String oldKey) onChanged;
  final Function(String key) onDeleted;

  const KeyValueTable({
    super.key,
    required this.items,
    this.envKeys = const [],
    required this.onChanged,
    required this.onDeleted,
  });

  @override
  State<KeyValueTable> createState() => _KeyValueTableState();
}

class _KeyValueTableState extends State<KeyValueTable> {
  final TextEditingController _newKeyController = TextEditingController();
  final TextEditingController _newValueController = TextEditingController();

  @override
  void dispose() {
    _newKeyController.dispose();
    _newValueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entries = widget.items.entries.toList();

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.white10)),
          ),
          child: Row(
            children: [
              Expanded(child: _buildHeaderLabel('Key')),
              const SizedBox(width: 16),
              Expanded(child: _buildHeaderLabel('Value')),
              const SizedBox(width: 40),
            ],
          ),
        ),
        
        // List
        Expanded(
          child: ListView.builder(
            itemCount: entries.length + 1,
            itemBuilder: (context, index) {
              if (index == entries.length) {
                return _buildAddRow();
              }
              
              final entry = entries[index];
              return _KeyValueRow(
                key: ValueKey(entry.key), // Stable key based on map key
                itemKey: entry.key,
                itemValue: entry.value,
                envKeys: widget.envKeys,
                onChanged: widget.onChanged,
                onDeleted: widget.onDeleted,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.white54,
      ),
    );
  }

  Widget _buildAddRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _newKeyController,
              style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'New Key',
                hintStyle: TextStyle(color: Colors.white24),
                border: InputBorder.none,
                isDense: true,
              ),
              onSubmitted: (_) => _addNewItem(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: _newValueController,
              style: GoogleFonts.inter(fontSize: 13, color: Colors.white70),
              decoration: const InputDecoration(
                hintText: 'Value',
                hintStyle: TextStyle(color: Colors.white24),
                border: InputBorder.none,
                isDense: true,
              ),
              onSubmitted: (_) => _addNewItem(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 16, color: Colors.white24),
            onPressed: _addNewItem,
            splashRadius: 20,
          ),
        ],
      ),
    );
  }

  void _addNewItem() {
    final key = _newKeyController.text.trim();
    final value = _newValueController.text.trim();

    // Allow adding if key is not empty OR if we want to add a placeholder
    // But Map keys must be unique.
    if (key.isNotEmpty) {
      widget.onChanged(key, value, '');
      _newKeyController.clear();
      _newValueController.clear();
    } else {
      // If key is empty, check if we already have an empty key
      if (!widget.items.containsKey('')) {
        widget.onChanged('', value, '');
        _newKeyController.clear();
        _newValueController.clear();
      }
    }
  }
}

class _KeyValueRow extends StatefulWidget {
  final String itemKey;
  final String itemValue;
  final List<String> envKeys;
  final Function(String key, String value, String oldKey) onChanged;
  final Function(String key) onDeleted;

  const _KeyValueRow({
    super.key,
    required this.itemKey,
    required this.itemValue,
    this.envKeys = const [],
    required this.onChanged,
    required this.onDeleted,
  });

  @override
  State<_KeyValueRow> createState() => _KeyValueRowState();
}

class _KeyValueRowState extends State<_KeyValueRow> {
  late TextEditingController _keyController;
  late TextEditingController _valueController;
  final FocusNode _keyFocusNode = FocusNode();
  final FocusNode _valueFocusNode = FocusNode();
  final AutocompleteManager _keyAutocomplete = AutocompleteManager();
  final AutocompleteManager _valueAutocomplete = AutocompleteManager();

  @override
  void initState() {
    super.initState();
    _keyController = TextEditingController(text: widget.itemKey);
    _valueController = TextEditingController(text: widget.itemValue);

    _keyController.addListener(() => _handleAutocomplete(_keyController, _keyFocusNode, _keyAutocomplete));
    _valueController.addListener(() => _handleAutocomplete(_valueController, _valueFocusNode, _valueAutocomplete));

    // Save on blur for Key
    _keyFocusNode.addListener(() async {
      if (!_keyFocusNode.hasFocus) {
        // Delay hiding to allow tap on suggestion to register
        await Future.delayed(const Duration(milliseconds: 200));
        _keyAutocomplete.hide();
        if (_keyController.text != widget.itemKey) {
           widget.onChanged(_keyController.text, widget.itemValue, widget.itemKey);
        }
      }
    });

    _valueFocusNode.addListener(() async {
      if (!_valueFocusNode.hasFocus) {
        // Delay hiding to allow tap on suggestion to register
        await Future.delayed(const Duration(milliseconds: 200));
        _valueAutocomplete.hide();
        // Value is usually updated on change, but ensure consistency on blur
        if (_valueController.text != widget.itemValue) {
           widget.onChanged(widget.itemKey, _valueController.text, widget.itemKey);
        }
      }
    });
  }

  void _handleAutocomplete(TextEditingController controller, FocusNode focusNode, AutocompleteManager manager) {
    if (!focusNode.hasFocus) return;

    final text = controller.text;
    final selection = controller.selection;
    if (!selection.isCollapsed || selection.baseOffset < 0 || selection.baseOffset > text.length) {
      manager.hide();
      return;
    }

    final beforeCursor = text.substring(0, selection.baseOffset);
    final triggerIndex = beforeCursor.lastIndexOf('{{');

    if (triggerIndex != -1) {
      final afterTrigger = beforeCursor.substring(triggerIndex + 2);
      if (!afterTrigger.contains('}}')) {
        final partial = afterTrigger;
        final suggestions = widget.envKeys
            .where((key) => key.toLowerCase().startsWith(partial.toLowerCase()))
            .toList();

        if (suggestions.isNotEmpty) {
          manager.showSuggestions(
            context,
            controller,
            suggestions,
            (selected) {
              final newText = text.substring(0, triggerIndex) +
                  '{{$selected}}' +
                  text.substring(selection.baseOffset);
              controller.text = newText;
              controller.selection = TextSelection.fromPosition(
                TextPosition(offset: triggerIndex + selected.length + 4),
              );
              
              // Trigger update immediately for value
              if (controller == _valueController) {
                widget.onChanged(widget.itemKey, newText, widget.itemKey);
              }
              // For key, we wait for blur/submit to avoid row identity change issues
            },
          );
          return;
        }
      }
    }
    manager.hide();
  }

  @override
  void didUpdateWidget(_KeyValueRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.itemValue != _valueController.text) {
       // Only update if not focused to avoid overwriting user input
       if (!_valueFocusNode.hasFocus) {
         _valueController.text = widget.itemValue;
       }
    }
  }

  @override
  void dispose() {
    _keyController.dispose();
    _valueController.dispose();
    _keyFocusNode.dispose();
    _valueFocusNode.dispose();
    _keyAutocomplete.hide();
    _valueAutocomplete.hide();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white10)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: CompositedTransformTarget(
              link: _keyAutocomplete.layerLink,
              child: TextField(
                controller: _keyController,
                focusNode: _keyFocusNode,
                style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                ),
                onSubmitted: (val) {
                  if (val != widget.itemKey) {
                    widget.onChanged(val, widget.itemValue, widget.itemKey);
                  }
                },
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: CompositedTransformTarget(
              link: _valueAutocomplete.layerLink,
              child: TextField(
                controller: _valueController,
                focusNode: _valueFocusNode,
                style: GoogleFonts.inter(fontSize: 13, color: Colors.white70),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                ),
                onChanged: (val) {
                  widget.onChanged(widget.itemKey, val, widget.itemKey);
                },
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 16, color: Colors.white24),
            onPressed: () => widget.onDeleted(widget.itemKey),
            splashRadius: 20,
          ),
        ],
      ),
    );
  }
}
