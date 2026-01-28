import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:window_manager/window_manager.dart';
import 'about_dialog.dart';
import '../../settings/presentation/settings_dialog.dart';
import 'dialogs.dart';

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
    if (_overlayEntry != null) return;

    final RenderBox? button = context.findRenderObject() as RenderBox?;
    if (button == null) return;

    final RenderBox? overlay = Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (overlay == null) return;

    final Offset position = button.localToGlobal(
      const Offset(0, 30),
      ancestor: overlay,
    );

    final colorScheme = Theme.of(context).colorScheme;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: _removeMenu,
                child: Container(color: Colors.transparent),
              ),
            ),
            Positioned(
              top: position.dy,
              left: position.dx,
              child: Material(
                color: colorScheme.surface,
                elevation: 8.0,
                borderRadius: BorderRadius.circular(4.0),
                child: IntrinsicWidth(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: _buildMenuItems(colorScheme),
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

  List<Widget> _buildMenuItems(ColorScheme colorScheme) {
    final List<Widget> menuItems = [];
    for (final item in widget.items) {
      if (item is PopupMenuItem) {
        // Extrair o texto do item se for um Text widget para aplicar estilo
        Widget child = item.child!;
        if (child is Text) {
          child = Text(
            child.data!,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: item.value == 'exit' ? Colors.redAccent : colorScheme.onSurface,
            ),
          );
        }

        menuItems.add(
          InkWell(
            onTap: () {
              _removeMenu();
              if (mounted) {
                widget.onSelected(item.value);
              }
            },
            hoverColor: colorScheme.primary.withOpacity(0.1),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: child,
            ),
          ),
        );
      } else if (item is PopupMenuDivider) {
        menuItems.add(Divider(height: 1, thickness: 1, color: colorScheme.onSurface.withOpacity(0.1)));
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
    final colorScheme = Theme.of(context).colorScheme;
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
              color: colorScheme.onSurface.withOpacity(0.8),
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class TopMenuBar extends ConsumerWidget {
  const TopMenuBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        HoverMenuButton(
          title: 'File',
          items: [
            const PopupMenuItem(value: 'new_collection', child: Text('New Collection')),
            const PopupMenuItem(value: 'new_request', child: Text('New Request')),
            const PopupMenuDivider(),
            const PopupMenuItem(value: 'settings', child: Text('Settings')),
            const PopupMenuDivider(),
            const PopupMenuItem(value: 'exit', child: Text('Exit')),
          ],
          onSelected: (value) {
            if (value == 'new_collection') {
              HomeDialogs.showCreateCollectionDialog(context, ref);
            } else if (value == 'new_request') {
              HomeDialogs.showCreateRequestDialog(context, ref);
            } else if (value == 'settings') {
              showDialog(
                context: context,
                builder: (context) => const SettingsDialog(),
              );
            } else if (value == 'exit') {
              windowManager.close();
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
