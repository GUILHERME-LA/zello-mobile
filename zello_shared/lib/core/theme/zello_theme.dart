import 'package:flutter/material.dart';
import 'zello_text_styles.dart';
import 'zello_shadows.dart';

// ═══════════════════════════════════════════════════════════
//  DESIGN TOKENS
// ═══════════════════════════════════════════════════════════

/// Consistent spacing scale (multiples of 4).
class ZelloSpacing {
  ZelloSpacing._();
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double base = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;
  static const double huge = 48;
}

/// Consistent border radius scale.
class ZelloRadius {
  ZelloRadius._();
  static const double xs = 6;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double pill = 100;

  static BorderRadius get cardRadius => BorderRadius.circular(lg);
  static BorderRadius get buttonRadius => BorderRadius.circular(md);
  static BorderRadius get inputRadius => BorderRadius.circular(md);
  static BorderRadius get sheetRadius =>
      const BorderRadius.vertical(top: Radius.circular(24));
  static BorderRadius get headerRadius =>
      const BorderRadius.only(
        bottomLeft: Radius.circular(32),
        bottomRight: Radius.circular(32),
      );
}

// ═══════════════════════════════════════════════════════════
//  COLOR PALETTE
// ═══════════════════════════════════════════════════════════

class ZelloColors {
  ZelloColors._();

  // ── Primary (Blue) ────────────────────────────────────
  static const primaryDark = Color(0xFF0D47A1);
  static const primary = Color(0xFF1565C0);
  static const primaryLight = Color(0xFF1E88E5);
  static const primaryLighter = Color(0xFF42A5F5);

  // ── Accent (Blue) ─────────────────────────────────────
  static const accent = Color(0xFF42A5F5);
  static const accentLight = Color(0xFFBBDEFB);
  static const accentDark = Color(0xFF1565C0);

  // ── Surfaces (Light) ──────────────────────────────────
  static const background = Color(0xFFF6F8FA);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceLight = Color(0xFFE8F0FE);
  static const surfaceLighter = Color(0xFFF1F5F9);
  static const surfaceElevated = Color(0xFFFFFFFF);

  // ── Surfaces (Dark) ───────────────────────────────────
  static const darkBackground = Color(0xFF0F172A);
  static const darkSurface = Color(0xFF1E293B);
  static const darkSurfaceLight = Color(0xFF334155);
  static const darkSurfaceElevated = Color(0xFF1E293B);

  // ── Text ──────────────────────────────────────────────
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF64748B);
  static const textTertiary = Color(0xFF94A3B8);
  static const textOnPrimary = Color(0xFFFFFFFF);
  static const textOnDark = Color(0xFFF1F5F9);
  static const textOnDarkSecondary = Color(0xFF94A3B8);

  // ── Borders ───────────────────────────────────────────
  static const border = Color(0xFFE2E8F0);
  static const borderLight = Color(0xFFF1F5F9);
  static const darkBorder = Color(0xFF334155);

  // ── Semantic ──────────────────────────────────────────
  static const success = Color(0xFF10B981);
  static const successLight = Color(0xFFD1FAE5);
  static const warning = Color(0xFFF59E0B);
  static const warningLight = Color(0xFFFEF3C7);
  static const danger = Color(0xFFEF4444);
  static const dangerLight = Color(0xFFFEE2E2);
  static const info = Color(0xFF3B82F6);
  static const infoLight = Color(0xFFDBEAFE);

  // ── Specialty ─────────────────────────────────────────
  static const medical = Color(0xFF3B82F6);
  static const psychology = Color(0xFF1E88E5);
  static const psychologyLight = Color(0xFFE3F2FD);
  static const online = Color(0xFF10B981);
  static const busy = Color(0xFFF59E0B);
  static const offline = Color(0xFF94A3B8);
}

// ═══════════════════════════════════════════════════════════
//  GRADIENTS
// ═══════════════════════════════════════════════════════════

class ZelloGradients {
  ZelloGradients._();

  /// Premium header gradient with 3 stops for depth.
  static const LinearGradient header = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1E88E5),
      Color(0xFF1565C0),
      Color(0xFF0D47A1),
    ],
    stops: [0.0, 0.5, 1.0],
  );

  /// Accent gradient for CTAs and highlights.
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF42A5F5),
      Color(0xFF1565C0),
    ],
  );

  /// Button gradient for primary CTAs.
  static const LinearGradient button = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1E88E5),
      Color(0xFF1565C0),
    ],
  );

  /// Subtle card background gradient.
  static const LinearGradient cardSubtle = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFF8FAFC),
    ],
  );

  /// Background gradient for screens.
  static const LinearGradient screenBackground = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFF8FAFC),
      Color(0xFFFFFFFF),
    ],
  );

  /// Dark header gradient.
  static const LinearGradient darkHeader = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1E3A5F),
      Color(0xFF0F172A),
    ],
  );

  /// Section header bar gradient.
  static const LinearGradient sectionBar = LinearGradient(
    colors: [Color(0xFF42A5F5), Color(0xFF1565C0)],
  );

  /// Avatar gradient.
  static const LinearGradient avatar = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1E88E5),
      Color(0xFF1565C0),
    ],
  );
}

// ═══════════════════════════════════════════════════════════
//  GLASSMORPHISM UTILITY
// ═══════════════════════════════════════════════════════════

/// Glassmorphism surface — frosted-glass effect for premium overlays.
/// Apply as [BoxDecoration] to containers that should feel elevated & translucent.
class ZelloGlass {
  ZelloGlass._();

  /// Light-theme glass surface.
  static BoxDecoration light({
    double opacity = 0.6,
    double blur = 20,
    double radius = 16,
    Color? tint,
  }) =>
      BoxDecoration(
        color: (tint ?? ZelloColors.surface).withAlpha((255 * opacity).round()),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: ZelloColors.surface.withAlpha(80),
          width: 1,
        ),
        boxShadow: ZelloShadows.sm,
      );

  /// Dark-theme glass surface.
  static BoxDecoration dark({
    double opacity = 0.5,
    double blur = 20,
    double radius = 16,
    Color? tint,
  }) =>
      BoxDecoration(
        color: (tint ?? ZelloColors.darkSurface)
            .withAlpha((255 * opacity).round()),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: ZelloColors.darkSurfaceLight.withAlpha(60),
          width: 1,
        ),
        boxShadow: ZelloShadows.darkSm,
      );

  /// Adaptive glass (auto light/dark based on current brightness).
  static BoxDecoration adaptive(BuildContext context, {
    double opacity = 0.6,
    double radius = 16,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? dark(opacity: opacity, radius: radius) : light(opacity: opacity, radius: radius);
  }
}

// ═══════════════════════════════════════════════════════════
//  THEME
// ═══════════════════════════════════════════════════════════

class ZelloTheme {
  ZelloTheme._();

  // ────────────────────────────────────────────────────────
  //  LIGHT THEME
  // ────────────────────────────────────────────────────────
  static ThemeData lightTheme() {
    final textTheme = ZelloTextStyles.textTheme.apply(
      bodyColor: ZelloColors.textPrimary,
      displayColor: ZelloColors.textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      textTheme: textTheme,

      colorScheme: ColorScheme.fromSeed(
        seedColor: ZelloColors.primary,
        brightness: Brightness.light,
        primary: ZelloColors.primary,
        onPrimary: ZelloColors.textOnPrimary,
        primaryContainer: ZelloColors.surfaceLight,
        onPrimaryContainer: ZelloColors.primaryDark,
        secondary: ZelloColors.accent,
        onSecondary: ZelloColors.textOnPrimary,
        secondaryContainer: ZelloColors.accentLight.withAlpha(60),
        tertiary: ZelloColors.psychology,
        surface: ZelloColors.surface,
        onSurface: ZelloColors.textPrimary,
        onSurfaceVariant: ZelloColors.textSecondary,
        outline: ZelloColors.border,
        outlineVariant: ZelloColors.borderLight,
        error: ZelloColors.danger,
        onError: ZelloColors.textOnPrimary,
      ),

      scaffoldBackgroundColor: ZelloColors.background,

      // ── AppBar ──────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: ZelloColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0.5,
        titleTextStyle: textTheme.headlineMedium,
      ),

      // ── Card ────────────────────────────────────────────
      cardTheme: CardTheme(
        color: ZelloColors.surface,
        elevation: 0,
        shadowColor: ZelloColors.primary.withAlpha(13),
        shape: RoundedRectangleBorder(
          borderRadius: ZelloRadius.cardRadius,
          side: BorderSide(color: ZelloColors.border.withAlpha(100)),
        ),
        margin: EdgeInsets.zero,
      ),

      // ── Elevated Button ─────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ZelloColors.primary,
          foregroundColor: ZelloColors.textOnPrimary,
          padding: const EdgeInsets.symmetric(
            horizontal: ZelloSpacing.xxl,
            vertical: ZelloSpacing.base,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: ZelloRadius.buttonRadius,
          ),
          elevation: 0,
          textStyle: textTheme.labelLarge,
        ),
      ),

      // ── Outlined Button ─────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ZelloColors.primary,
          side: const BorderSide(color: ZelloColors.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(
            horizontal: ZelloSpacing.xl,
            vertical: ZelloSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: ZelloRadius.buttonRadius,
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),

      // ── Text Button ─────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ZelloColors.primary,
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: ZelloRadius.buttonRadius,
          ),
        ),
      ),

      // ── Input Decoration ────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ZelloColors.surfaceLighter,
        border: OutlineInputBorder(
          borderRadius: ZelloRadius.inputRadius,
          borderSide: const BorderSide(color: ZelloColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: ZelloRadius.inputRadius,
          borderSide: const BorderSide(color: ZelloColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: ZelloRadius.inputRadius,
          borderSide: const BorderSide(
            color: ZelloColors.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: ZelloRadius.inputRadius,
          borderSide: const BorderSide(color: ZelloColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: ZelloRadius.inputRadius,
          borderSide: const BorderSide(
            color: ZelloColors.danger,
            width: 2,
          ),
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: ZelloColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: ZelloColors.textTertiary,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: ZelloSpacing.base,
          vertical: ZelloSpacing.md + 2,
        ),
        prefixIconColor: ZelloColors.textSecondary,
        suffixIconColor: ZelloColors.textSecondary,
      ),

      // ── Navigation Bar ──────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: ZelloColors.surface,
        indicatorColor: ZelloColors.primary.withAlpha(25),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 68,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              color: ZelloColors.primary,
              size: 24,
            );
          }
          return const IconThemeData(
            color: ZelloColors.textTertiary,
            size: 22,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return textTheme.labelSmall?.copyWith(
              color: ZelloColors.primary,
              fontWeight: FontWeight.w600,
            );
          }
          return textTheme.labelSmall?.copyWith(
            color: ZelloColors.textTertiary,
          );
        }),
      ),

      // ── Bottom Navigation Bar (legacy) ──────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: ZelloColors.surface,
        selectedItemColor: ZelloColors.primary,
        unselectedItemColor: ZelloColors.textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: textTheme.labelSmall,
      ),

      // ── Bottom Sheet ────────────────────────────────────
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: ZelloColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        showDragHandle: true,
        dragHandleColor: ZelloColors.border,
        dragHandleSize: Size(40, 4),
      ),

      // ── Dialog ──────────────────────────────────────────
      dialogTheme: DialogTheme(
        backgroundColor: ZelloColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ZelloRadius.xl),
        ),
        titleTextStyle: textTheme.headlineSmall,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: ZelloColors.textSecondary,
        ),
      ),

      // ── Snack Bar ───────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: ZelloColors.textPrimary,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: ZelloColors.textOnPrimary,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ZelloRadius.md),
        ),
        insetPadding: const EdgeInsets.symmetric(
          horizontal: ZelloSpacing.lg,
          vertical: ZelloSpacing.sm,
        ),
      ),

      // ── Divider ─────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: ZelloColors.borderLight,
        thickness: 1,
        space: 1,
      ),

      // ── FAB ─────────────────────────────────────────────
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: ZelloColors.primary,
        foregroundColor: ZelloColors.textOnPrimary,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ZelloRadius.lg),
        ),
      ),

      // ── Chip ────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: ZelloColors.surfaceLight,
        labelStyle: textTheme.labelMedium?.copyWith(
          color: ZelloColors.primary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ZelloRadius.pill),
        ),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(
          horizontal: ZelloSpacing.md,
          vertical: ZelloSpacing.xs,
        ),
      ),

      // ── Switch ──────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return ZelloColors.primary;
          }
          return ZelloColors.textTertiary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return ZelloColors.primary.withAlpha(60);
          }
          return ZelloColors.border;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          return Colors.transparent;
        }),
      ),

      // ── Popup Menu ──────────────────────────────────────
      popupMenuTheme: PopupMenuThemeData(
        color: ZelloColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ZelloRadius.md),
        ),
        textStyle: textTheme.bodyMedium,
      ),

      // ── ListTile ────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: ZelloSpacing.base,
          vertical: ZelloSpacing.xs,
        ),
        titleTextStyle: textTheme.titleSmall,
        subtitleTextStyle: textTheme.bodySmall?.copyWith(
          color: ZelloColors.textSecondary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ZelloRadius.md),
        ),
      ),

      // ── TabBar ──────────────────────────────────────────
      tabBarTheme: TabBarTheme(
        labelColor: ZelloColors.primary,
        unselectedLabelColor: ZelloColors.textTertiary,
        labelStyle: textTheme.labelLarge,
        unselectedLabelStyle: textTheme.labelMedium,
        indicatorColor: ZelloColors.primary,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.label,
      ),
    );
  }

  // ────────────────────────────────────────────────────────
  //  DARK THEME
  // ────────────────────────────────────────────────────────
  static ThemeData darkTheme() {
    final textTheme = ZelloTextStyles.textTheme.apply(
      bodyColor: ZelloColors.textOnDark,
      displayColor: ZelloColors.textOnDark,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      textTheme: textTheme,

      colorScheme: ColorScheme.fromSeed(
        seedColor: ZelloColors.primary,
        brightness: Brightness.dark,
        primary: ZelloColors.primaryLight,
        onPrimary: ZelloColors.textOnPrimary,
        primaryContainer: ZelloColors.primaryDark.withAlpha(80),
        onPrimaryContainer: ZelloColors.primaryLighter,
        secondary: ZelloColors.accentLight,
        onSecondary: ZelloColors.darkBackground,
        tertiary: ZelloColors.psychology,
        surface: ZelloColors.darkSurface,
        onSurface: ZelloColors.textOnDark,
        onSurfaceVariant: ZelloColors.textOnDarkSecondary,
        outline: ZelloColors.darkBorder,
        outlineVariant: ZelloColors.darkSurfaceLight,
        error: ZelloColors.danger,
        onError: ZelloColors.textOnPrimary,
      ),

      scaffoldBackgroundColor: ZelloColors.darkBackground,

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: ZelloColors.textOnDark,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0.5,
        titleTextStyle: textTheme.headlineMedium,
      ),

      cardTheme: CardTheme(
        color: ZelloColors.darkSurface,
        elevation: 0,
        shadowColor: Colors.black.withAlpha(40),
        shape: RoundedRectangleBorder(
          borderRadius: ZelloRadius.cardRadius,
          side: BorderSide(color: ZelloColors.darkBorder.withAlpha(120)),
        ),
        margin: EdgeInsets.zero,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ZelloColors.primaryLight,
          foregroundColor: ZelloColors.textOnPrimary,
          padding: const EdgeInsets.symmetric(
            horizontal: ZelloSpacing.xxl,
            vertical: ZelloSpacing.base,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: ZelloRadius.buttonRadius,
          ),
          elevation: 0,
          textStyle: textTheme.labelLarge,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ZelloColors.primaryLighter,
          side: const BorderSide(color: ZelloColors.primaryLight, width: 1.5),
          padding: const EdgeInsets.symmetric(
            horizontal: ZelloSpacing.xl,
            vertical: ZelloSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: ZelloRadius.buttonRadius,
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ZelloColors.primaryLighter,
          textStyle: textTheme.labelLarge,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ZelloColors.darkSurfaceLight.withAlpha(80),
        border: OutlineInputBorder(
          borderRadius: ZelloRadius.inputRadius,
          borderSide: const BorderSide(color: ZelloColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: ZelloRadius.inputRadius,
          borderSide: const BorderSide(color: ZelloColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: ZelloRadius.inputRadius,
          borderSide: const BorderSide(
            color: ZelloColors.primaryLight,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: ZelloRadius.inputRadius,
          borderSide: const BorderSide(color: ZelloColors.danger),
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: ZelloColors.textOnDarkSecondary,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: ZelloColors.textOnDarkSecondary,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: ZelloSpacing.base,
          vertical: ZelloSpacing.md + 2,
        ),
        prefixIconColor: ZelloColors.textOnDarkSecondary,
        suffixIconColor: ZelloColors.textOnDarkSecondary,
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: ZelloColors.darkSurface,
        indicatorColor: ZelloColors.primaryLight.withAlpha(30),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 68,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              color: ZelloColors.primaryLighter,
              size: 24,
            );
          }
          return const IconThemeData(
            color: ZelloColors.textOnDarkSecondary,
            size: 22,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return textTheme.labelSmall?.copyWith(
              color: ZelloColors.primaryLighter,
              fontWeight: FontWeight.w600,
            );
          }
          return textTheme.labelSmall?.copyWith(
            color: ZelloColors.textOnDarkSecondary,
          );
        }),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: ZelloColors.darkSurface,
        selectedItemColor: ZelloColors.primaryLighter,
        unselectedItemColor: ZelloColors.textOnDarkSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: textTheme.labelSmall,
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: ZelloColors.darkSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        showDragHandle: true,
        dragHandleColor: ZelloColors.darkBorder,
        dragHandleSize: Size(40, 4),
      ),

      dialogTheme: DialogTheme(
        backgroundColor: ZelloColors.darkSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ZelloRadius.xl),
        ),
        titleTextStyle: textTheme.headlineSmall,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: ZelloColors.textOnDarkSecondary,
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: ZelloColors.darkSurfaceLight,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: ZelloColors.textOnDark,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ZelloRadius.md),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: ZelloColors.darkBorder,
        thickness: 1,
        space: 1,
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: ZelloColors.primaryLight,
        foregroundColor: ZelloColors.textOnPrimary,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ZelloRadius.lg),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: ZelloColors.darkSurfaceLight,
        labelStyle: textTheme.labelMedium?.copyWith(
          color: ZelloColors.primaryLighter,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ZelloRadius.pill),
        ),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(
          horizontal: ZelloSpacing.md,
          vertical: ZelloSpacing.xs,
        ),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return ZelloColors.primaryLight;
          }
          return ZelloColors.textOnDarkSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return ZelloColors.primaryLight.withAlpha(60);
          }
          return ZelloColors.darkBorder;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          return Colors.transparent;
        }),
      ),

      popupMenuTheme: PopupMenuThemeData(
        color: ZelloColors.darkSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ZelloRadius.md),
        ),
        textStyle: textTheme.bodyMedium,
      ),

      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: ZelloSpacing.base,
          vertical: ZelloSpacing.xs,
        ),
        titleTextStyle: textTheme.titleSmall?.copyWith(
          color: ZelloColors.textOnDark,
        ),
        subtitleTextStyle: textTheme.bodySmall?.copyWith(
          color: ZelloColors.textOnDarkSecondary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ZelloRadius.md),
        ),
      ),

      tabBarTheme: TabBarTheme(
        labelColor: ZelloColors.primaryLighter,
        unselectedLabelColor: ZelloColors.textOnDarkSecondary,
        labelStyle: textTheme.labelLarge,
        unselectedLabelStyle: textTheme.labelMedium,
        indicatorColor: ZelloColors.primaryLighter,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.label,
      ),
    );
  }
}
