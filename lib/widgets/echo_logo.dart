import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EchoLogo extends StatelessWidget {
  final double size;
  final bool withText;

  const EchoLogo({
    super.key,
    this.size = 48,
    this.withText = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Ícone com Gradiente
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF6C63FF), Color(0xFF00E5FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: Icon(
            Icons.graphic_eq, // Ondas sonoras representam "Echo"
            size: size,
            color: Colors.white, // Necessário para o ShaderMask funcionar
          ),
        ),
        
        if (withText) ...[
          SizedBox(width: size * 0.25),
          // Texto com Gradiente
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF6C63FF), Color(0xFF00E5FF)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ).createShader(bounds),
            child: Text(
              'Echo',
              style: GoogleFonts.jetBrainsMono(
                fontSize: size * 0.8,
                fontWeight: FontWeight.bold,
                letterSpacing: -1.5,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
