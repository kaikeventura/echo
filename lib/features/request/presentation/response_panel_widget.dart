import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../providers/request_execution_provider.dart';
import '../../../utils/http_colors.dart';

class ResponsePanelWidget extends ConsumerWidget {
  const ResponsePanelWidget({super.key});

  String _tryFormatJson(String text) {
    try {
      final dynamic parsed = json.decode(text);
      final encoder = const JsonEncoder.withIndent('  ');
      return encoder.convert(parsed);
    } catch (e) {
      return text;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final executionState = ref.watch(requestExecutionProvider);

    return executionState.when(
      data: (response) {
        if (response == null) {
          return Center(
            child: Text(
              'Ready to send request',
              style: GoogleFonts.inter(color: Colors.white24),
            ),
          );
        }

        String displayBody = response.body.toString();
        displayBody = _tryFormatJson(displayBody);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: const Color(0xFF252526),
              child: Row(
                children: [
                  _buildStatusBadge(response.statusCode),
                  const SizedBox(width: 24),
                  _buildMetric(Icons.timer_outlined, '${response.executionTimeMs}ms'),
                  const SizedBox(width: 24),
                  _buildMetric(Icons.data_usage, '${response.responseSizeBytes} B'),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: const Color(0xFF1E1E1E),
                child: SingleChildScrollView(
                  child: SelectableText(
                    displayBody,
                    style: GoogleFonts.jetBrainsMono(fontSize: 12, height: 1.5),
                  ),
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
    );
  }

  Widget _buildStatusBadge(int statusCode) {
    final color = HttpColors.getStatusCodeColor(statusCode);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$statusCode',
            style: GoogleFonts.inter(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.white54),
        const SizedBox(width: 6),
        Text(
          text,
          style: GoogleFonts.inter(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}
