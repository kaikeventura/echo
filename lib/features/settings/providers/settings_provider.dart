import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:isar/isar.dart';
import '../../../models/app_settings_model.dart';
import '../../../services/isar_service.dart';

part 'settings_provider.g.dart';

@riverpod
class Settings extends _$Settings {
  late Isar _isar;

  @override
  Future<AppSettingsModel> build() async {
    _isar = await IsarService().db;
    return _fetchSettings();
  }

  Future<AppSettingsModel> _fetchSettings() async {
    final settings = await _isar.appSettingsModels.where().findFirst();
    
    if (settings != null) {
      return settings;
    } else {
      // Criar configuração padrão se não existir
      final defaultSettings = AppSettingsModel();
      await _isar.writeTxn(() async {
        await _isar.appSettingsModels.put(defaultSettings);
      });
      return defaultSettings;
    }
  }

  Future<void> updateThemeMode(AppThemeMode mode) async {
    final currentSettings = state.value;
    if (currentSettings != null) {
      final updatedSettings = currentSettings..themeMode = mode;
      await _saveSettings(updatedSettings);
    }
  }

  Future<void> updateEditorSettings({double? fontSize, bool? wordWrap}) async {
    final currentSettings = state.value;
    if (currentSettings != null) {
      if (fontSize != null) currentSettings.editorFontSize = fontSize;
      if (wordWrap != null) currentSettings.editorWordWrap = wordWrap;
      await _saveSettings(currentSettings);
    }
  }

  Future<void> updateNetworkSettings({bool? validateSSL, int? connectTimeout, String? proxyUrl}) async {
    final currentSettings = state.value;
    if (currentSettings != null) {
      if (validateSSL != null) currentSettings.validateSSL = validateSSL;
      if (connectTimeout != null) currentSettings.connectTimeout = connectTimeout;
      // Permitir limpar o proxy passando uma string vazia ou null explicitamente se a lógica de UI suportar
      if (proxyUrl != null) {
        currentSettings.proxyUrl = proxyUrl.isEmpty ? null : proxyUrl;
      }
      await _saveSettings(currentSettings);
    }
  }

  Future<void> _saveSettings(AppSettingsModel settings) async {
    await _isar.writeTxn(() async {
      await _isar.appSettingsModels.put(settings);
    });
    state = AsyncValue.data(settings);
  }
}
