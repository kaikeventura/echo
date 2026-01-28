import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class EchoAboutDialog extends StatelessWidget {
  const EchoAboutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF2D2D2D),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bolt, size: 48, color: Color(0xFF6C63FF)),
          const SizedBox(height: 16),
          Text(
            'Echo',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Version 1.0.0',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white54,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'A modern API client built with Flutter.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 24),
          InkWell(
            onTap: () => launchUrl(Uri.parse('https://github.com/kaikeventura/echo')),
            child: Text(
              'github.com/kaikeventura/echo',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Theme.of(context).colorScheme.primary,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Built with ❤️ by Kaike',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.white38,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
