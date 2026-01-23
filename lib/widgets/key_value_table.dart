import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class KeyValueTable extends StatefulWidget {
  final Map<String, String> items;
  final Function(String key, String value, String oldKey) onChanged;
  final Function(String key) onDeleted;

  const KeyValueTable({
    super.key,
    required this.items,
    required this.onChanged,
    required this.onDeleted,
  });

  @override
  State<KeyValueTable> createState() => _KeyValueTableState();
}

class _KeyValueTableState extends State<KeyValueTable> {
  // Controladores para a linha de "novo item"
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
        // Cabeçalho da Tabela
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
              const SizedBox(width: 40), // Espaço para o botão de delete
            ],
          ),
        ),
        
        // Lista de Itens Existentes
        Expanded(
          child: ListView.builder(
            itemCount: entries.length + 1, // +1 para a linha de adição
            itemBuilder: (context, index) {
              if (index == entries.length) {
                return _buildAddRow();
              }
              
              final entry = entries[index];
              return _buildRow(entry.key, entry.value);
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

  Widget _buildRow(String key, String value) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white10)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              initialValue: key,
              style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
              ),
              onChanged: (newKey) {
                // Se a chave mudar, precisamos remover a antiga e adicionar a nova
                // Isso é delicado com Maps, idealmente usaríamos IDs ou índices
                // Mas seguindo a spec de Map<String, String>:
                if (newKey.isNotEmpty) {
                   widget.onChanged(newKey, value, key);
                }
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextFormField(
              initialValue: value,
              style: GoogleFonts.inter(fontSize: 13, color: Colors.white70),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
              ),
              onChanged: (newValue) {
                widget.onChanged(key, newValue, key);
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 16, color: Colors.white24),
            onPressed: () => widget.onDeleted(key),
            splashRadius: 20,
          ),
        ],
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

    if (key.isNotEmpty) {
      widget.onChanged(key, value, ''); // '' indica que não havia chave antiga
      _newKeyController.clear();
      _newValueController.clear();
    }
  }
}
