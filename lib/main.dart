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
import 'features/home/presentation/top_menu_bar.dart'; // Importar TopMenuBar

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();

  // Opções de Janela para Linux
  WindowOptions windowOptions = const WindowOptions(
    size: Size(1200, 800),
    center: true,
    backgroundColor: Color(0xFF1E1E1E), // Cor sólida idêntica ao tema (Sem transparência)
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden, // Mantém sem barra nativa
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const ProviderScope(child: EchoApp()));
}

class EchoApp extends StatelessWidget {
  const EchoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Echo',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        // Fundo Sólido para evitar artefatos no Linux
        scaffoldBackgroundColor: const Color(0xFF1E1E1E),

        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6C63FF),
          secondary: Color(0xFF00E5FF),
          surface: Color(0xFF2D2D2D), // Ligeiramente mais claro que o fundo
          background: Color(0xFF1E1E1E),
        ),
      ),
      home: const SplashScreen(), // Inicia pela Splash Screen
    );
  }
}

class EchoHome extends StatelessWidget {
  const EchoHome({super.key});

  @override
  Widget build(BuildContext context) {
    // Controlador para o divisor principal (vertical)
    final mainSplitController = MultiSplitViewController(
      areas: [
        Area(size: 250, minimalSize: 200), // Sidebar
        Area(minimalSize: 400), // Conteúdo Principal
      ],
    );

    // Controlador para o divisor de conteúdo (horizontal)
    final contentSplitController = MultiSplitViewController(
      areas: [
        Area(weight: 0.6, minimalSize: 300), // Editor de Requisição
        Area(weight: 0.4, minimalSize: 200), // Painel de Resposta
      ],
    );

    return Scaffold(
      // Topbar customizada que permite arrastar a janela
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(40), // Altura padrão da barra de título
        child: WindowCaption(
          brightness: Brightness.dark,
          backgroundColor: const Color(0xFF1E1E1E), // Mesma cor do fundo
          title: const TopMenuBar(), // A nova barra de menu sem o texto Echo
        ),
      ),
      body: MultiSplitViewTheme(
        data: MultiSplitViewThemeData(
          dividerThickness: 6,
          dividerPainter: DividerPainters.grooved1(
            color: Theme.of(context).colorScheme.surface,
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
