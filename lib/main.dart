import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:window_manager/window_manager.dart';
import 'features/home/presentation/sidebar_widget.dart';
import 'features/home/presentation/request_tabs_widget.dart';
import 'features/home/presentation/splash_screen.dart';
import 'features/request/presentation/request_editor_widget.dart';
import 'features/request/presentation/response_panel_widget.dart';
import 'features/home/presentation/top_menu_bar.dart';
import 'features/settings/providers/settings_provider.dart';
import 'models/app_settings_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();

  // Opções de Janela para Linux
  WindowOptions windowOptions = const WindowOptions(
    size: Size(1200, 800),
    center: true,
    backgroundColor: Colors.transparent, // Deixar transparente para o app controlar o fundo
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      await windowManager.setIcon('assets/images/echo_logo.png');
    }
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const ProviderScope(child: EchoApp()));
}

class EchoApp extends ConsumerWidget {
  const EchoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    final themeMode = settingsAsync.when(
      data: (settings) {
        switch (settings.themeMode) {
          case AppThemeMode.light:
            return ThemeMode.light;
          case AppThemeMode.dark:
            return ThemeMode.dark;
          case AppThemeMode.system:
          default:
            return ThemeMode.system;
        }
      },
      loading: () => ThemeMode.system,
      error: (_, __) => ThemeMode.system,
    );

    return MaterialApp(
      title: 'Echo',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5), // Fundo claro
        textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF6C63FF),
          secondary: Color(0xFF00E5FF),
          surface: Colors.white, // Superfícies brancas
          background: Color(0xFFF5F5F5),
          onSurface: Color(0xFF1E1E1E), // Texto escuro
        ),
        dividerColor: Colors.grey.shade300,
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Color(0xFF6C63FF), // Cor do cursor (Primary)
          selectionColor: Color(0x4D6C63FF), // Cor da seleção (Primary com opacidade)
          selectionHandleColor: Color(0xFF6C63FF),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF1E1E1E),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6C63FF),
          secondary: Color(0xFF00E5FF),
          surface: Color(0xFF2D2D2D),
          background: Color(0xFF1E1E1E),
          onSurface: Colors.white,
        ),
        dividerColor: Colors.white10,
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Color(0xFF6C63FF), // Cor do cursor (Primary)
          selectionColor: Color(0x4D6C63FF), // Cor da seleção
          selectionHandleColor: Color(0xFF6C63FF),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class EchoHome extends StatelessWidget {
  const EchoHome({super.key});

  @override
  Widget build(BuildContext context) {
    final mainSplitController = MultiSplitViewController(
      areas: [
        Area(size: 250, minimalSize: 200),
        Area(minimalSize: 400),
      ],
    );

    final contentSplitController = MultiSplitViewController(
      areas: [
        Area(weight: 0.6, minimalSize: 300),
        Area(weight: 0.4, minimalSize: 200),
      ],
    );

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(40),
        child: WindowCaption(
          brightness: Theme.of(context).brightness,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: const TopMenuBar(),
        ),
      ),
      body: MultiSplitViewTheme(
        data: MultiSplitViewThemeData(
          dividerThickness: 6,
          dividerPainter: DividerPainters.grooved1(
            color: Theme.of(context).dividerColor,
            highlightedColor: Theme.of(context).colorScheme.primary,
          ),
        ),
        child: MultiSplitView(
          axis: Axis.horizontal,
          controller: mainSplitController,
          children: [
            const SidebarWidget(),
            Column(
              children: [
                const RequestTabsWidget(),
                Expanded(
                  child: MultiSplitView(
                    axis: Axis.vertical,
                    controller: contentSplitController,
                    children: const [
                      RequestEditorWidget(),
                      ResponsePanelWidget(),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
