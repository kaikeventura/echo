import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:window_manager/window_manager.dart';

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
          Container(
            width: 250,
            // Borda sutil à direita para separar do conteúdo
            decoration: const BoxDecoration(
                color: Color(0xFF252526), // Um tom levemente diferente para contraste
                border: Border(right: BorderSide(color: Colors.white10))
            ),
            child: Column(
              children: [
                const SizedBox(height: 10),
                _buildSidebarItem(Icons.flash_on, 'New Request', true),
                _buildSidebarItem(Icons.folder_open, 'Collections', false),
                _buildSidebarItem(Icons.history, 'History', false),
              ],
            ),
          ),
          // Área Principal
          Expanded(
            child: Container(
              color: const Color(0xFF1E1E1E),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bolt, size: 64, color: Colors.white10),
                    const SizedBox(height: 16),
                    Text(
                      'Select a request to start',
                      style: GoogleFonts.inter(color: Colors.white38),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(IconData icon, String label, bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF6C63FF).withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: isActive ? const Color(0xFF6C63FF) : Colors.white54),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              color: isActive ? const Color(0xFFFFFFFF) : Colors.white54,
              fontSize: 13,
              fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}