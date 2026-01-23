import 'package:flutter/material.dart';

class HttpColors {
  static Color getMethodColor(String method) {
    switch (method.toUpperCase()) {
      case 'GET':
        return const Color(0xFF6C63FF); // Roxo/Azul
      case 'POST':
        return const Color(0xFFFFB74D); // Laranja
      case 'PUT':
        return const Color(0xFF4FC3F7); // Azul Claro
      case 'PATCH':
        return const Color(0xFFAED581); // Verde Claro
      case 'DELETE':
        return const Color(0xFFE57373); // Vermelho
      case 'HEAD':
        return const Color(0xFF90A4AE); // Cinza Azulado
      case 'OPTIONS':
        return const Color(0xFFBA68C8); // Roxo
      default:
        return Colors.grey;
    }
  }

  static Color getStatusCodeColor(int statusCode) {
    if (statusCode >= 200 && statusCode < 300) {
      return const Color(0xFF81C784); // Verde (Sucesso)
    } else if (statusCode >= 300 && statusCode < 400) {
      return const Color(0xFF64B5F6); // Azul (Redirecionamento)
    } else if (statusCode >= 400 && statusCode < 500) {
      return const Color(0xFFFFB74D); // Laranja (Erro Cliente)
    } else if (statusCode >= 500) {
      return const Color(0xFFE57373); // Vermelho (Erro Servidor)
    } else {
      return Colors.grey;
    }
  }
}
