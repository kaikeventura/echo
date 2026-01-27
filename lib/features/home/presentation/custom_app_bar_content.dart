import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'top_menu_bar.dart';

class CustomAppBarContent extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBarContent({super.key});

  // A altura da TopMenuBar é 30. A altura padrão do WindowCaption é geralmente 30-40.
  // Vamos definir uma altura total de 70 para acomodar ambos.
  static const double _topMenuBarHeight = 30;
  static const double _windowCaptionHeight = 40; // Altura padrão do WindowCaption

  @override
  Size get preferredSize => const Size.fromHeight(_topMenuBarHeight + _windowCaptionHeight);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const TopMenuBar(),
        SizedBox(
          height: _windowCaptionHeight,
          child: WindowCaption(
            brightness: Brightness.dark,
            backgroundColor: const Color(0xFF1E1E1E),
            title: Text(
              'Echo',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white54),
            ),
          ),
        ),
      ],
    );
  }
}
