import 'package:flutter/material.dart';

/// Premium shadow tokens with primary-tinted color for depth and polish.
/// Use these instead of hardcoded BoxShadow throughout the app.
class ZelloShadows {
  ZelloShadows._();

  // ── Light theme shadows ────────────────────────────────
  static List<BoxShadow> get xs => [
        BoxShadow(
          color: const Color(0xFF1565C0).withAlpha(8),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];

  static List<BoxShadow> get sm => [
        BoxShadow(
          color: const Color(0xFF1565C0).withAlpha(10),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
        BoxShadow(
          color: const Color(0xFF1565C0).withAlpha(5),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];

  static List<BoxShadow> get md => [
        BoxShadow(
          color: const Color(0xFF1565C0).withAlpha(12),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: const Color(0xFF1565C0).withAlpha(6),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get lg => [
        BoxShadow(
          color: const Color(0xFF1565C0).withAlpha(15),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: const Color(0xFF1565C0).withAlpha(8),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get xl => [
        BoxShadow(
          color: const Color(0xFF1565C0).withAlpha(20),
          blurRadius: 32,
          offset: const Offset(0, 12),
        ),
        BoxShadow(
          color: const Color(0xFF1565C0).withAlpha(10),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  // ── Colored accent shadows ─────────────────────────────
  static List<BoxShadow> accent(Color color) => [
        BoxShadow(
          color: color.withAlpha(40),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  // ── Navigation bar shadow ──────────────────────────────
  static List<BoxShadow> get navBar => [
        BoxShadow(
          color: Colors.black.withAlpha(8),
          blurRadius: 20,
          offset: const Offset(0, -4),
        ),
      ];

  // ── Inner glow (for inputs on focus) ───────────────────
  static List<BoxShadow> focusGlow(Color color) => [
        BoxShadow(
          color: color.withAlpha(20),
          blurRadius: 0,
          spreadRadius: 3,
        ),
      ];

  // ── Dark theme shadows ─────────────────────────────────
  static List<BoxShadow> get darkSm => [
        BoxShadow(
          color: Colors.black.withAlpha(40),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get darkMd => [
        BoxShadow(
          color: Colors.black.withAlpha(50),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get darkLg => [
        BoxShadow(
          color: Colors.black.withAlpha(60),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];
}
