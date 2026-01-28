import 'package:isar/isar.dart';

part 'app_settings_model.g.dart';

enum AppThemeMode {
  system,
  light,
  dark,
}

@collection
class AppSettingsModel {
  Id id = Isar.autoIncrement;

  @Enumerated(EnumType.name)
  late AppThemeMode themeMode;

  late double editorFontSize;

  late bool editorWordWrap;

  late bool validateSSL;

  late int connectTimeout;

  String? proxyUrl;

  // Construtor com valores padrão
  AppSettingsModel({
    this.themeMode = AppThemeMode.system,
    this.editorFontSize = 14.0,
    this.editorWordWrap = false,
    this.validateSSL = true,
    this.connectTimeout = 30000,
    this.proxyUrl,
  });
}
