import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:code_text_field/code_text_field.dart';
import 'package:highlight/languages/json.dart' as highlight_json;
import 'package:highlight/languages/xml.dart' as highlight_xml;
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import '../../../providers/request_execution_provider.dart';
import '../../../utils/http_colors.dart';
import '../../settings/providers/settings_provider.dart';

class ResponsePanelWidget extends ConsumerStatefulWidget {
  const ResponsePanelWidget({super.key});

  @override
  ConsumerState<ResponsePanelWidget> createState() => _ResponsePanelWidgetState();
}

class _ResponsePanelWidgetState extends ConsumerState<ResponsePanelWidget> {
  CodeController? _codeController;

  @override
  void dispose() {
    _codeController?.dispose();
    super.dispose();
  }

  String _tryFormatJson(String text) {
    try {
      final dynamic parsed = json.decode(text);
      final encoder = const JsonEncoder.withIndent('  ');
      return encoder.convert(parsed);
    } catch (e) {
      return text;
    }
  }

  String _tryFormatXml(String text) {
    try {
      var xml = text.trim();
      xml = xml.replaceAll(RegExp(r'>\s+<'), '><');
      var indent = 0;
      var result = StringBuffer();
      for (var i = 0; i < xml.length; i++) {
        var char = xml[i];
        if (char == '<') {
          if (i + 1 < xml.length && xml[i + 1] == '/') {
            indent--;
            if (indent < 0) indent = 0;
            result.write('\n${'  ' * indent}');
          } else {
             if (result.isNotEmpty) result.write('\n${'  ' * indent}');
             indent++;
          }
        }
        result.write(char);
        if (char == '>') {
           if (i - 1 >= 0 && xml[i - 1] == '/') {
             indent--;
           }
        }
      }
      return result.toString().trim();
    } catch (e) {
      return text;
    }
  }

  @override
  Widget build(BuildContext context) {
    final executionState = ref.watch(requestExecutionProvider);
    final settingsAsync = ref.watch(settingsProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return executionState.when(
      data: (response) {
        if (response == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.send_outlined, size: 48, color: colorScheme.onSurface.withOpacity(0.1)),
                const SizedBox(height: 16),
                Text(
                  'Ready to send request',
                  style: GoogleFonts.inter(color: colorScheme.onSurface.withOpacity(0.3)),
                ),
              ],
            ),
          );
        }

        String displayBody = response.body.toString();
        String language = 'plaintext';

        // Detect content type and format
        final contentType = response.headers['content-type']?.firstOrNull?.toLowerCase() ?? '';
        if (contentType.contains('json')) {
          displayBody = _tryFormatJson(displayBody);
          language = 'json';
        } else if (contentType.contains('xml')) {
          displayBody = _tryFormatXml(displayBody);
          language = 'xml';
        }

        // Update controller if needed
        if (_codeController?.text != displayBody) {
          _codeController?.dispose();
          _codeController = CodeController(
            text: displayBody,
            language: language == 'json' ? highlight_json.json : (language == 'xml' ? highlight_xml.xml : null),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
              ),
              child: Row(
                children: [
                  _buildStatusBadge(response.statusCode),
                  const SizedBox(width: 24),
                  _buildMetric(Icons.timer_outlined, '${response.executionTimeMs}ms', colorScheme),
                  const SizedBox(width: 24),
                  _buildMetric(Icons.data_usage, '${response.responseSizeBytes} B', colorScheme),
                  const Spacer(),
                  if (language != 'plaintext')
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: colorScheme.onSurface.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        language.toUpperCase(),
                        style: GoogleFonts.inter(fontSize: 10, color: colorScheme.onSurface.withOpacity(0.6)),
                      ),
                    ),
                ],
              ),
            ),
            
            // Response Body
            Expanded(
              child: Container(
                width: double.infinity,
                color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5),
                child: SingleChildScrollView(
                  child: CodeTheme(
                    data: CodeThemeData(styles: atomOneDarkTheme), // TODO: Adicionar tema claro
                    child: CodeField(
                      controller: _codeController!,
                      textStyle: GoogleFonts.jetBrainsMono(
                        fontSize: settingsAsync.value?.editorFontSize ?? 13, 
                        height: 1.5
                      ),
                      readOnly: true,
                      wrap: settingsAsync.value?.editorWordWrap ?? false,
                      background: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
              const SizedBox(height: 16),
              Text(
                'Request Failed',
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.redAccent),
              ),
              const SizedBox(height: 8),
              Text(
                err.toString(),
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: colorScheme.onSurface.withOpacity(0.7)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(int statusCode) {
    final color = HttpColors.getStatusCodeColor(statusCode);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
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

  Widget _buildMetric(IconData icon, String text, ColorScheme colorScheme) {
    return Row(
      children: [
        Icon(icon, size: 14, color: colorScheme.onSurface.withOpacity(0.4)),
        const SizedBox(width: 6),
        Text(
          text,
          style: GoogleFonts.inter(color: colorScheme.onSurface.withOpacity(0.7), fontSize: 12),
        ),
      ],
    );
  }
}
