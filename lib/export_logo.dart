import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:echo/widgets/echo_logo.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final boundaryKey = GlobalKey();
  
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: RepaintBoundary(
            key: boundaryKey,
            child: EchoLogo(size: 256), // Reduzido o tamanho para evitar overflow
          ),
        ),
      ),
    ),
  );

  await Future.delayed(const Duration(seconds: 1));

  try {
    RenderRepaintBoundary boundary = boundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 3.0); // Mantém alta resolução
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();

    final directory = await getDownloadsDirectory();
    if (directory != null) {
      final filePath = '${directory.path}/echo_logo.png';
      final file = File(filePath);
      await file.writeAsBytes(pngBytes);
      print('✅ Logo successfully saved to: $filePath');
    } else {
      print('❌ Could not find downloads directory.');
    }
  } catch (e) {
    print('❌ An error occurred: $e');
  }
  
  exit(0);
}
