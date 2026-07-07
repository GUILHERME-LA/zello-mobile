import 'package:flutter/material.dart';

class ZelloColors {
  static const primaryDark = Color(0xFF0D47A1);
  static const primary = Color(0xFF1565C0);
  static const primaryLight = Color(0xFF1E88E5);
  static const secondary = Color(0xFF42A5F5);
  static const accent = Color(0xFF2196F3);
  static const surfaceLight = Color(0xFFE3F2FD);
  static const surfaceLighter = Color(0xFFF5F9FF);
  static const background = Color(0xFFF5F9FF);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF1A1A2E);
  static const textSecondary = Color(0xFF6B7280);
  static const border = Color(0xFFE5E7EB);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFEF4444);
  static const success = Color(0xFF10B981);
  static const medical = Color(0xFF3B82F6);
  static const psychology = Color(0xFF8B5CF6);
  static const online = Color(0xFF10B981);
  static const busy = Color(0xFFF59E0B);
  static const offline = Color(0xFF9CA3AF);
  static const gradientStart = Color(0xFF1565C0);
  static const gradientEnd = Color(0xFF0D47A1);
}

class ZelloTheme {
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: ZelloColors.primary,
        brightness: Brightness.light,
        primary: ZelloColors.primary,
        onPrimary: Colors.white,
        primaryContainer: ZelloColors.surfaceLight,
        secondary: ZelloColors.secondary,
        surface: ZelloColors.surface,
        error: ZelloColors.danger,
      ),
      scaffoldBackgroundColor: ZelloColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: ZelloColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0.5,
      ),
      cardTheme: CardTheme(
        color: ZelloColors.surface,
        elevation: 0,
        shadowColor: ZelloColors.primary.withAlpha(13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: ZelloColors.border.withAlpha(76)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ZelloColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ZelloColors.surfaceLighter,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: ZelloColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: ZelloColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ZelloColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: ZelloColors.danger),
        ),
        labelStyle: const TextStyle(color: ZelloColors.textSecondary, fontWeight: FontWeight.w500),
        hintStyle: const TextStyle(color: ZelloColors.textSecondary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        prefixIconColor: ZelloColors.textSecondary,
        suffixIconColor: ZelloColors.textSecondary,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: ZelloColors.primary,
        unselectedItemColor: ZelloColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 11),
      ),
      dividerTheme: DividerThemeData(
        color: ZelloColors.border.withAlpha(76),
        thickness: 1,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: ZelloColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: ZelloColors.surfaceLight,
        labelStyle: const TextStyle(fontSize: 13, color: ZelloColors.primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return ZelloColors.primary;
          return ZelloColors.textSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return ZelloColors.primary.withAlpha(76);
          return ZelloColors.border;
        }),
      ),
    );
  }
}
