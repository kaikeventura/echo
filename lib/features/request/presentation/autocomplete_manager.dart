import 'package:flutter/material.dart';
import 'package:code_text_field/code_text_field.dart';
import 'package:google_fonts/google_fonts.dart';

class AutocompleteManager {
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  void showSuggestions(
    BuildContext context,
    CodeController controller,
    List<String> options,
    Function(String) onSelected,
  ) {
    hide();

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    // Calculate cursor position to place overlay near it
    // This is tricky with CodeField, so for simplicity we place it below the field
    // Ideally we would calculate exact cursor coordinates.
    
    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          width: 200, // Fixed width for suggestions
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: const Offset(0, 24), // Offset below the cursor line (approx)
            child: Material(
              elevation: 8,
              color: const Color(0xFF2D2D2D),
              borderRadius: BorderRadius.circular(8),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final option = options[index];
                    return ListTile(
                      dense: true,
                      title: Text(
                        option,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                      hoverColor: Colors.white10,
                      onTap: () {
                        onSelected(option);
                        hide();
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  LayerLink get layerLink => _layerLink;
}
