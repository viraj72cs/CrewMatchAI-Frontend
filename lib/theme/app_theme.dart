import 'package:flutter/material.dart';

class AppTheme {
  // Brand Lavender & Violet Palette
  static const Color primary = Color(0xFF6C5CE7);
  static const Color primaryLight = Color(0xFFA29BFE);
  static const Color primarySurface = Color(0xFFF0EDFF);
  
  // Backgrounds & Surface
  static const Color darkBackground = Color(0xFF0F0C20);
  static const Color darkCard = Color(0xFF1B1736);
  static const Color lightBackground = Color(0xFFF8F7FF);
  static const Color lightCard = Color(0xFFFFFFFF);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);
  static const Color textDarkPrimary = Color(0xFFF5F6FA);
  static const Color textDarkSecondary = Color(0xFFB2BEC3);
  
  // Semantic Colors
  static const Color success = Color(0xFF00B894);     // Green -> Available / Confirmed
  static const Color warning = Color(0xFFFDCB6E);     // Amber -> Pending / Backup
  static const Color error = Color(0xFFFF7675);       // Red -> Cancelled / Excluded
  static const Color info = Color(0xFF0984E3);        // Blue -> Info

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: primaryLight,
        surface: darkCard,
        background: darkBackground,
        error: error,
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF2E2A50), width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textDarkPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
