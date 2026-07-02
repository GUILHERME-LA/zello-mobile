import 'package:flutter/material.dart';

class ZelloColors {
  static const primary = Color(0xFF1B7A6E);
  static const primaryDark = Color(0xFF15635A);
  static const primaryLight = Color(0xFF2A9D8F);
  static const secondary = Color(0xFF2D9CDB);
  static const accent = Color(0xFF27AE60);
  static const accentDark = Color(0xFF1E8449);
  static const warning = Color(0xFFF39C12);
  static const danger = Color(0xFFE74C3C);
  static const background = Color(0xFFF5F7FA);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF2D3436);
  static const textSecondary = Color(0xFF636E72);
  static const border = Color(0xFFE0E0E0);
  static const medical = Color(0xFF2D9CDB);
  static const psychology = Color(0xFF9B59B6);
  static const online = Color(0xFF27AE60);
  static const busy = Color(0xFFF39C12);
  static const offline = Color(0xFF95A5A6);
}

class ZelloTheme {
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: ZelloColors.primary,
        brightness: Brightness.light,
        primary: ZelloColors.primary,
        secondary: ZelloColors.secondary,
        surface: ZelloColors.surface,
        error: ZelloColors.danger,
      ),
      scaffoldBackgroundColor: ZelloColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: ZelloColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardTheme(
        color: ZelloColors.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ZelloColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: ZelloColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: ZelloColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: ZelloColors.primary, width: 2),
        ),
      ),
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: ZelloColors.primary,
        brightness: Brightness.dark,
        primary: ZelloColors.primaryLight,
        secondary: ZelloColors.secondary,
        surface: const Color(0xFF1E1E2E),
        error: ZelloColors.danger,
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E2E),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}
