import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:window_manager/window_manager.dart';
import 'features/home/presentation/sidebar_widget.dart';
import 'features/request/presentation/request_editor_widget.dart';

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
      home: const EchoHome(),
    );
  }
}

class EchoHome extends StatelessWidget {
  const EchoHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Topbar customizada que permite arrastar a janela
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(40),
        child: WindowCaption(
          brightness: Brightness.dark,
          backgroundColor: const Color(0xFF1E1E1E), // Mesma cor do fundo
          title: Text(
              'Echo',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white54)
          ),
        ),
      ),
      body: Row(
        children: [
          // Sidebar
          const SidebarWidget(),
          // Separator
          Container(
            width: 1,
            color: Colors.white10,
          ),
          // Área Principal
          const Expanded(
            child: RequestEditorWidget(),
          ),
        ],
      ),
    );
  }
}
