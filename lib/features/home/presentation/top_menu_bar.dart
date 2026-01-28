import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'export_collection_dialog.dart';
import 'import_collection_dialog.dart';
import 'about_dialog.dart';
import '../../settings/presentation/settings_dialog.dart'; // Importar SettingsDialog

class HoverMenuButton extends StatefulWidget {
  final String title;
  final List<PopupMenuEntry> items;
  final ValueChanged<dynamic> onSelected;

  const HoverMenuButton({
    super.key,
    required this.title,
    required this.items,
    required this.onSelected,
  });

  @override
  State<HoverMenuButton> createState() => _HoverMenuButtonState();
}

class _HoverMenuButtonState extends State<HoverMenuButton> {
  Timer? _hoverTimer;
  OverlayEntry? _overlayEntry;

  void _startHoverTimer() {
    _hoverTimer?.cancel();
    _hoverTimer = Timer(const Duration(seconds: 1), _showMenu);
  }

  void _cancelHoverTimer() {
    _hoverTimer?.cancel();
    _hoverTimer = null;
  }

  void _removeMenu() {
    _hoverTimer?.cancel();
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showMenu() {
    _cancelHoverTimer();
    if (_overlayEntry != null) return; // Menu já está visível

    final RenderBox? button = context.findRenderObject() as RenderBox?;
    if (button == null) return;

    final RenderBox? overlay = Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (overlay == null) return;

    final Offset position = button.localToGlobal(
      const Offset(0, 30), // Posiciona o menu abaixo do botão
      ancestor: overlay,
    );

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            // Barreira para fechar o menu ao clicar fora
            Positioned.fill(
              child: GestureDetector(
                onTap: _removeMenu,
                child: Container(color: Colors.transparent),
              ),
            ),
            // O conteúdo do menu
            Positioned(
              top: position.dy,
              left: position.dx,
              child: Material(
                color: const Color(0xFF2D2D2D),
                elevation: 8.0,
                borderRadius: BorderRadius.circular(4.0),
                child: IntrinsicWidth(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: _buildMenuItems(),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  List<Widget> _buildMenuItems() {
    final List<Widget> menuItems = [];
    for (final item in widget.items) {
      if (item is PopupMenuItem) {
        menuItems.add(
          InkWell(
            onTap: () {
              _removeMenu();
              if (mounted) {
                widget.onSelected(item.value);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: item.child,
            ),
          ),
        );
      } else if (item is PopupMenuDivider) {
        menuItems.add(const Divider(height: 1, thickness: 1));
      }
    }
    return menuItems;
  }

  @override
  void dispose() {
    _removeMenu();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _startHoverTimer(),
      onExit: (_) => _cancelHoverTimer(),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: _showMenu,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            widget.title,
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class TopMenuBar extends StatelessWidget {
  const TopMenuBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        HoverMenuButton(
          title: 'File',
          items: [
            const PopupMenuItem(value: 'import', child: Text('Import Collection')),
            const PopupMenuItem(value: 'export', child: Text('Export Collection')),
            const PopupMenuDivider(),
            const PopupMenuItem(value: 'settings', child: Text('Settings')),
          ],
          onSelected: (value) {
            if (value == 'export') {
              showDialog(
                context: context,
                builder: (context) => const ExportCollectionDialog(),
              );
            } else if (value == 'import') {
              showDialog(
                context: context,
                builder: (context) => const ImportCollectionDialog(),
              );
            } else if (value == 'settings') {
              showDialog(
                context: context,
                builder: (context) => const SettingsDialog(),
              );
            } else {
              print('Selected: $value');
            }
          },
        ),
        HoverMenuButton(
          title: 'Help',
          items: [
            const PopupMenuItem(value: 'github', child: Text('GitHub')),
            const PopupMenuItem(value: 'about', child: Text('About')),
          ],
          onSelected: (value) async {
            if (value == 'github') {
              final Uri url = Uri.parse('https://github.com/kaikeventura/echo');
              if (!await launchUrl(url)) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Could not launch GitHub URL')),
                  );
                }
              }
            } else if (value == 'about') {
              showDialog(
                context: context,
                builder: (context) => const EchoAboutDialog(),
              );
            }
          },
        ),
      ],
    );
  }
}
