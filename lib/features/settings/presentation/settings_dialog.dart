import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/app_settings_model.dart';
import '../providers/settings_provider.dart';
import '../../home/presentation/export_collection_dialog.dart';
import '../../home/presentation/import_collection_dialog.dart';

class SettingsDialog extends ConsumerStatefulWidget {
  const SettingsDialog({super.key});

  @override
  ConsumerState<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends ConsumerState<SettingsDialog> {
  int _selectedIndex = 0;
  late TextEditingController _timeoutController;
  late TextEditingController _proxyController;

  @override
  void initState() {
    super.initState();
    _timeoutController = TextEditingController();
    _proxyController = TextEditingController();
  }

  @override
  void dispose() {
    _timeoutController.dispose();
    _proxyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        width: 800,
        height: 600,
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Text(
                    'Settings',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.close, color: colorScheme.onSurface.withOpacity(0.6)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: Theme.of(context).dividerColor),
            // Body
            Expanded(
              child: Row(
                children: [
                  // Sidebar Navigation
                  Container(
                    width: 200,
                    decoration: BoxDecoration(
                      border: Border(right: BorderSide(color: Theme.of(context).dividerColor)),
                    ),
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      children: [
                        _buildNavItem(0, 'General', Icons.tune),
                        _buildNavItem(1, 'Editor', Icons.code),
                        _buildNavItem(2, 'Network', Icons.public),
                        _buildNavItem(3, 'Data', Icons.storage),
                      ],
                    ),
                  ),
                  // Content Area
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: _buildContent(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String label, IconData icon) {
    final isSelected = _selectedIndex == index;
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: ListTile(
        selected: isSelected,
        selectedTileColor: colorScheme.primary.withOpacity(0.1),
        leading: Icon(
          icon,
          color: isSelected ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.6),
          size: 20,
        ),
        title: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
        onTap: () => setState(() => _selectedIndex = index),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        dense: true,
      ),
    );
  }

  Widget _buildContent() {
    final settingsAsync = ref.watch(settingsProvider);

    return settingsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (settings) {
        if (_timeoutController.text.isEmpty && !_timeoutController.selection.isValid) {
           _timeoutController.text = settings.connectTimeout.toString();
        }
        if (_proxyController.text.isEmpty && !_proxyController.selection.isValid) {
           _proxyController.text = settings.proxyUrl ?? '';
        }

        switch (_selectedIndex) {
          case 0:
            return _buildGeneralTab(settings);
          case 1:
            return _buildEditorTab(settings);
          case 2:
            return _buildNetworkTab(settings);
          case 3:
            return _buildDataTab();
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildGeneralTab(AppSettingsModel settings) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Appearance',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        _buildSettingRow(
          label: 'Theme Mode',
          description: 'Select your preferred interface theme',
          child: DropdownButton<AppThemeMode>(
            value: settings.themeMode,
            dropdownColor: colorScheme.surface,
            style: GoogleFonts.inter(color: colorScheme.onSurface),
            underline: Container(height: 1, color: colorScheme.onSurface.withOpacity(0.2)),
            items: AppThemeMode.values.map((mode) {
              return DropdownMenuItem(
                value: mode,
                child: Text(_formatEnum(mode.name), style: TextStyle(color: colorScheme.onSurface)),
              );
            }).toList(),
            onChanged: (newMode) {
              if (newMode != null) {
                ref.read(settingsProvider.notifier).updateThemeMode(newMode);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEditorTab(AppSettingsModel settings) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Editor',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 24),
        
        _buildSettingRow(
          label: 'Font Size: ${settings.editorFontSize.toInt()}px',
          description: 'Adjust the font size of the code editor',
          child: SizedBox(
            width: 200,
            child: Slider(
              value: settings.editorFontSize,
              min: 10.0,
              max: 24.0,
              divisions: 14,
              activeColor: colorScheme.primary,
              label: settings.editorFontSize.round().toString(),
              onChanged: (val) {
                ref.read(settingsProvider.notifier).updateEditorSettings(fontSize: val);
              },
            ),
          ),
        ),

        const SizedBox(height: 24),

        _buildSettingRow(
          label: 'Word Wrap',
          description: 'Wrap long lines in the editor',
          child: Switch(
            value: settings.editorWordWrap,
            activeColor: colorScheme.primary,
            onChanged: (val) {
              ref.read(settingsProvider.notifier).updateEditorSettings(wordWrap: val);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNetworkTab(AppSettingsModel settings) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Network',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 24),
        
        _buildSettingRow(
          label: 'SSL Verification',
          description: 'Validate SSL certificates for HTTPS requests',
          child: Switch(
            value: settings.validateSSL,
            activeColor: colorScheme.primary,
            onChanged: (val) {
              ref.read(settingsProvider.notifier).updateNetworkSettings(validateSSL: val);
            },
          ),
        ),
        
        const SizedBox(height: 24),
        
        _buildSettingRow(
          label: 'Connection Timeout (ms)',
          description: 'Maximum time to wait for a connection',
          child: SizedBox(
            width: 100,
            child: TextField(
              controller: _timeoutController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: GoogleFonts.inter(fontSize: 13, color: colorScheme.onSurface),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                border: OutlineInputBorder(),
              ),
              onSubmitted: (val) {
                final timeout = int.tryParse(val);
                if (timeout != null) {
                  ref.read(settingsProvider.notifier).updateNetworkSettings(connectTimeout: timeout);
                }
              },
            ),
          ),
        ),

        const SizedBox(height: 24),

        _buildSettingRow(
          label: 'Proxy URL',
          description: 'HTTP/HTTPS proxy (e.g., http://localhost:8080)',
          child: SizedBox(
            width: 250,
            child: TextField(
              controller: _proxyController,
              style: GoogleFonts.inter(fontSize: 13, color: colorScheme.onSurface),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                border: OutlineInputBorder(),
                hintText: 'No Proxy',
              ),
              onSubmitted: (val) {
                ref.read(settingsProvider.notifier).updateNetworkSettings(proxyUrl: val);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDataTab() {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Data Management',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 24),
        
        _buildActionRow(
          label: 'Import Collection',
          description: 'Import collections from Echo JSON files',
          buttonText: 'Import',
          icon: Icons.file_upload_outlined,
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => const ImportCollectionDialog(),
            );
          },
        ),

        const SizedBox(height: 24),

        _buildActionRow(
          label: 'Export Collection',
          description: 'Export your collections to a JSON file',
          buttonText: 'Export',
          icon: Icons.file_download_outlined,
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => const ExportCollectionDialog(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSettingRow({
    required String label,
    required String description,
    required Widget child,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        child,
      ],
    );
  }

  Widget _buildActionRow({
    required String label,
    required String description,
    required String buttonText,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.onSurface.withOpacity(0.05),
            foregroundColor: colorScheme.onSurface,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          icon: Icon(icon, size: 18),
          label: Text(buttonText, style: GoogleFonts.inter(fontSize: 13)),
        ),
      ],
    );
  }

  String _formatEnum(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
}
