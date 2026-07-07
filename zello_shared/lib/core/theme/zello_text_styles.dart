import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Premium typography system using Inter via Google Fonts.
/// Provides a complete type scale for consistent, professional text rendering.
class ZelloTextStyles {
  ZelloTextStyles._();

  static String get _fontFamily => GoogleFonts.inter().fontFamily!;

  // ── Display ──────────────────────────────────────────────
  static TextStyle get displayLarge => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 34,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.0,
        height: 1.15,
      );

  static TextStyle get displayMedium => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        height: 1.2,
      );

  static TextStyle get displaySmall => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.25,
      );

  // ── Headline ─────────────────────────────────────────────
  static TextStyle get headlineLarge => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        height: 1.27,
      );

  static TextStyle get headlineMedium => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        height: 1.3,
      );

  static TextStyle get headlineSmall => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        height: 1.33,
      );

  // ── Title ────────────────────────────────────────────────
  static TextStyle get titleLarge => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.35,
      );

  static TextStyle get titleMedium => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.4,
      );

  static TextStyle get titleSmall => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.4,
      );

  // ── Body ─────────────────────────────────────────────────
  static TextStyle get bodyLarge => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
        height: 1.5,
      );

  static TextStyle get bodyMedium => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
        height: 1.5,
      );

  static TextStyle get bodySmall => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.2,
        height: 1.5,
      );

  // ── Label ────────────────────────────────────────────────
  static TextStyle get labelLarge => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.4,
      );

  static TextStyle get labelMedium => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
        height: 1.4,
      );

  static TextStyle get labelSmall => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.4,
        height: 1.4,
      );

  // ── Complete TextTheme ───────────────────────────────────
  static TextTheme get textTheme => TextTheme(
        displayLarge: displayLarge,
        displayMedium: displayMedium,
        displaySmall: displaySmall,
        headlineLarge: headlineLarge,
        headlineMedium: headlineMedium,
        headlineSmall: headlineSmall,
        titleLarge: titleLarge,
        titleMedium: titleMedium,
        titleSmall: titleSmall,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: labelLarge,
        labelMedium: labelMedium,
        labelSmall: labelSmall,
      );
}
