import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colores institucionales UTEM
  static const Color primaryColor = Color(0xFF1565C0);      // Azul UTEM principal
  static const Color primaryLight = Color(0xFF5E92F3);      // Azul claro
  static const Color primaryDark = Color(0xFF003C8F);       // Azul oscuro
  
  static const Color secondaryColor = Color(0xFF4FC3F7);    // Azul celeste
  static const Color accentColor = Color(0xFFFF6F00);       // Naranja UTEM
  static const Color accentLight = Color(0xFFFF9E40);       // Naranja claro
  static const Color textColor = Color(0xFF212121);       // Texto principal
  static const Color textLight = Color(0xFF757575);       // Texto secundario
  static const Color borderColor = Color(0xFFBDBDBD);      // Color de borde
  
  // Colores de estado
  static const Color successColor = Color(0xFF4CAF50);      // Verde éxito
  static const Color warningColor = Color(0xFFFF9800);      // Amarillo advertencia
  static const Color errorColor = Color(0xFFE53935);        // Rojo error
  static const Color infoColor = Color(0xFF2196F3);         // Azul información
  
  // Colores neutros
  static const Color backgroundColor = Color(0xFFF8F9FA);   // Fondo principal
  static const Color surfaceColor = Colors.white;           // Superficie
  static const Color cardColor = Colors.white;              // Tarjetas
  
  // Colores de texto
  static const Color textPrimary = Color(0xFF212121);       // Texto principal
  static const Color textSecondary = Color(0xFF757575);     // Texto secundario
  static const Color textHint = Color(0xFFBDBDBD);          // Texto hint
  
  // Colores específicos para biometría
  static const Color biometricPrimary = Color(0xFF6A1B9A);  // Púrpura biométrico
  static const Color facialColor = Color(0xFF4CAF50);       // Verde facial
  static const Color fingerprintColor = Color(0xFF2196F3);  // Azul huella
  
  // Colores para gradiente teal
  static const Color gradientStart = Color(0xFF33AFA0);     // Teal claro (arriba)
  static const Color gradientEnd = Color(0xFF006A70);       // Teal oscuro (abajo)
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      
      // Esquema de colores
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        primary: primaryColor,
        onPrimary: Colors.white,
        secondary: secondaryColor,
        onSecondary: Colors.white,
        tertiary: accentColor,
        onTertiary: Colors.white,
        surface: surfaceColor,
        onSurface: textPrimary,
        background: backgroundColor,
        onBackground: textPrimary,
        error: errorColor,
        onError: Colors.white,
      ),
      
      // Tipografía
      textTheme: GoogleFonts.robotoTextTheme().copyWith(
        displayLarge: GoogleFonts.roboto(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        displayMedium: GoogleFonts.roboto(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        displaySmall: GoogleFonts.roboto(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        headlineLarge: GoogleFonts.roboto(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        headlineMedium: GoogleFonts.roboto(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        headlineSmall: GoogleFonts.roboto(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleLarge: GoogleFonts.roboto(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        titleMedium: GoogleFonts.roboto(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        titleSmall: GoogleFonts.roboto(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textSecondary,
        ),
        bodyLarge: GoogleFonts.roboto(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: textPrimary,
        ),
        bodyMedium: GoogleFonts.roboto(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: textPrimary,
        ),
        bodySmall: GoogleFonts.roboto(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: textSecondary,
        ),
        labelLarge: GoogleFonts.roboto(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        labelMedium: GoogleFonts.roboto(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textSecondary,
        ),
        labelSmall: GoogleFonts.roboto(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: textHint,
        ),
      ),
      
      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        titleTextStyle: GoogleFonts.roboto(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      
      // Botones
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: const BorderSide(color: primaryColor, width: 2),
          textStyle: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: GoogleFonts.roboto(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Cards
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(8),
      ),
      
      // Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle: GoogleFonts.roboto(
          color: textHint,
          fontSize: 14,
        ),
        labelStyle: GoogleFonts.roboto(
          color: textSecondary,
          fontSize: 14,
        ),
      ),
      
      // Scaffold
      scaffoldBackgroundColor: backgroundColor,
      
      // Floating Action Button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        elevation: 6,
      ),
      
      // Bottom Navigation Bar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondary,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
      
      // Divisor
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade300,
        thickness: 1,
        space: 1,
      ),
    );
  }
}

// Extensión para facilitar el acceso a colores personalizados
extension AppThemeExtension on ThemeData {
  Color get successColor => AppTheme.successColor;
  Color get warningColor => AppTheme.warningColor;
  Color get infoColor => AppTheme.infoColor;
  Color get biometricPrimary => AppTheme.biometricPrimary;
  Color get facialColor => AppTheme.facialColor;
  Color get fingerprintColor => AppTheme.fingerprintColor;
  Color get textSecondary => AppTheme.textSecondary;
  Color get textHint => AppTheme.textHint;
  Color get gradientStart => AppTheme.gradientStart;
  Color get gradientEnd => AppTheme.gradientEnd;
  
  // Gradiente linear teal
  LinearGradient get tealGradient => const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppTheme.gradientStart, AppTheme.gradientEnd],
  );
}