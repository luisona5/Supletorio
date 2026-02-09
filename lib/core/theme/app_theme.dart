import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tema visual de ElVeciReporta
class AppTheme {
  // ========== COLORES PRINCIPALES ==========
  static const Color primary = Color(0xFF1976D2); // Azul municipio
  static const Color secondary = Color(0xFF0288D1);
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Colors.white;
  
  // ========== ESTADOS DE REPORTE ==========
  static const Color pendiente = Color(0xFFF57C00); // Naranja
  static const Color enProceso = Color(0xFF1976D2); // Azul
  static const Color resuelto = Color(0xFF388E3C); // Verde
  
  // ========== CATEGORÍAS ==========
  static const Color baches = Color(0xFF5D4037); // Marrón
  static const Color luminarias = Color(0xFFFDD835); // Amarillo
  static const Color basura = Color(0xFF7B1FA2); // Morado
  static const Color otro = Color(0xFF616161); // Gris
  
  // ========== TEXTO ==========
  static const Color textDark = Color(0xFF212121);
  static const Color textGrey = Color(0xFF757575);
  static const Color textLight = Color(0xFFBDBDBD);
  
  // ========== ESTADOS VISUALES ==========
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFD32F2F);
  static const Color warning = Color(0xFFFFA726);
  static const Color info = Color(0xFF29B6F6);
  
  /// Tema principal de la aplicación
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primary,
        secondary: secondary,
        surface: surface,
        error: error,
      ),
      scaffoldBackgroundColor: background,
      
      // ========== TIPOGRAFÍA ==========
      textTheme: GoogleFonts.robotoTextTheme().copyWith(
        headlineLarge: GoogleFonts.roboto(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        headlineMedium: GoogleFonts.roboto(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        bodyLarge: GoogleFonts.roboto(
          fontSize: 16,
          color: textDark,
        ),
        bodyMedium: GoogleFonts.roboto(
          fontSize: 14,
          color: textGrey,
        ),
      ),
      
      // ========== APP BAR ==========
      appBarTheme: AppBarTheme(
        backgroundColor: primary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.roboto(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      
      // ========== BOTONES ==========
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          textStyle: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // ========== INPUTS ==========
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error, width: 2),
        ),
        contentPadding: const EdgeInsets.all(16),
        hintStyle: GoogleFonts.roboto(
          color: textGrey,
          fontSize: 14,
        ),
      ),
      
      // ========== CARDS ==========
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: surface,
      ),
    );
  }
  
  /// Obtener color según estado del reporte
  static Color getColorForEstado(String estado) {
    switch (estado) {
      case 'pendiente':
        return pendiente;
      case 'en_proceso':
        return enProceso;
      case 'resuelto':
        return resuelto;
      default:
        return textGrey;
    }
  }
  
  /// Obtener color según categoría
  static Color getColorForCategoria(String categoria) {
    switch (categoria) {
      case 'baches':
        return baches;
      case 'luminarias':
        return luminarias;
      case 'basura':
        return basura;
      case 'otro':
        return otro;
      default:
        return textGrey;
    }
  }
  
  /// Obtener icono según categoría
  static IconData getIconForCategoria(String categoria) {
    switch (categoria) {
      case 'baches':
        return Icons.warning_rounded;
      case 'luminarias':
        return Icons.lightbulb_outline;
      case 'basura':
        return Icons.delete_outline;
      case 'otro':
        return Icons.report_problem_outlined;
      default:
        return Icons.help_outline;
    }
  }
}