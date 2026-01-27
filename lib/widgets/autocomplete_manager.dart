import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AutocompleteManager {
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  void showSuggestions(
    BuildContext context,
    TextEditingController controller,
    List<String> options,
    Function(String) onSelected,
  ) {
    hide();

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          width: 200,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: const Offset(0, 24),
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
