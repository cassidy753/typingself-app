import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ═══════════════════════════════════════════════════════════════════════
// Edition 5 — Official Brand Guideline Color System
// Core Palette: Mindful Blue #73A5C5 + Organic Cream #F5F1E8 + TypingSelf Charcoal #2A2D34
// Source: Official TypingSelf Brand System v1.0
// ═══════════════════════════════════════════════════════════════════════

class AppColors {
  // ─── Light Mode — warm neutrals ───
  static const background = Color(0xFFFAFAFA);    // Neutral Background
  static const surface = Color(0xFFF5F1E8);       // Organic Cream — card bg, menus
  static const elevated = Color(0xFFFFFFFF);      // White cards
  static const border = Color(0xFFE0DBCC);        // Input border default
  static const divider = Color(0xFFE0DBCC);

  // Text — TypingSelf Charcoal
  static const textPrimary = Color(0xFF2A2D34);   // Charcoal — primary text
  static const textSecondary = Color(0xFF6B7280); // Gray
  static const textMuted = Color(0xFF9CA3AF);     // Light gray
  static const textOnPrimary = Color(0xFFFFFFFF); // White text on colored bg

  // ─── PRIMARY ACCENT — Mindful Blue ───
  static const primary = Color(0xFF73A5C5);        // Mindful Blue — CTA, links, focus
  static const primaryDark = Color(0xFF4A5A75);   // Focus Slate — focus states
  static const primaryLight = Color(0xFFB8D4E3);  // Light tint for bg states

  // ─── SEMANTIC COLORS ───
  static const cta = Color(0xFF73A5C5);            // Mindful Blue (alias)
  static const success = Color(0xFF82C991);        // Growth Green
  static const error = Color(0xFFE65A6D);          // Cautionary Red
  static const warning = Color(0xFFE65A6D);

  // Accent / secondary palette
  static const accentTeal = Color(0xFF66B2B2);     // Active Teal
  static const accentLavender = Color(0xFFA5A7C5); // Calm Lavender
  static const accentAmber = Color(0xFFF8E8C6);    // Soft Amber

  // Achievement badges (content-specific)
  static const badgeSage = Color(0xFF82C991);
  static const badgeGold = Color(0xFFF8E8C6);
  static const badgeLavender = Color(0xFFA5A7C5);

  // ─── DARK MODE — #121212 base（非純黑）───
  static const darkBackground = Color(0xFF121212);  // Material Design 建議 dark bg
  static const darkSurface = Color(0xFF1E1E1E);     // Card surface
  static const darkElevated = Color(0xFF2A2D34);    // Elevated surface
  static const darkBorder = Color(0xFF2A2A2A);      // 1px divider
  static const darkTextPrimary = Color(0xFFE0E0E0); // 非純白主文字
  static const darkTextSecondary = Color(0xFF9CA3AF);
  static const darkTextMuted = Color(0xFF6B7280);
  static const darkDivider = Color(0xFF2A2A2A);

  // Dark mode accent (slightly desaturated for dark bg)
  static const darkPrimary = Color(0xFF8EC4E0);     // Mindful Blue lightened
  static const darkSuccess = Color(0xFF82C991);
  static const darkError = Color(0xFFE65A6D);
  static const darkAccentTeal = Color(0xFF66B2B2);

  // ─── BACKWARD COMPAT ALIASES (for existing screen references) ───
  // Edition 4 color names → map to new official palette
  static const accentEarth = primary;           // was #8B7355, now Mindful Blue
  static const accentCoral = cta;               // was #D4735E, now Mindful Blue
  static const accentSage = badgeSage;          // was #7A9E7E, now Growth Green
  static const accentDusty = badgeLavender;     // was #B8A9C9, now Calm Lavender
  static const accentGold = Color(0xFFC9A84C);  // keep gold for badges
  static const purple = badgeLavender;
  static const sage = badgeSage;
  static const mustard = accentGold;
  static const disabled = Color(0xFFE0DBCC);
  static const disabledText = Color(0xFF9CA3AF);
  static const darkAccentEarth = darkPrimary;
  static const darkAccentCoral = darkError;
  static const darkAccentSage = darkSuccess;
  static const darkAccentDusty = Color(0xFFA5A7C5);
  static const darkAccentGold = Color(0xFFC9A84C);
  static const darkDisabled = Color(0xFF3A4055);
  static const darkDisabledText = Color(0xFF6B7280);
}

// ─── SPACING ───
class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;
}

// ─── RADIUS ───
class AppRadius {
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double xxl = 28.0;
}

// ─── SHADOWS ───
class AppShadows {
  static List<BoxShadow> get card => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get elevated => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 20,
      offset: const Offset(0, 6),
    ),
  ];
}

// ─── THEME ───
class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.light(
        primary: AppColors.accentEarth,
        onPrimary: Colors.white,
        primaryContainer: AppColors.accentEarth.withValues(alpha: 0.1),
        secondary: AppColors.accentCoral,
        onSecondary: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: const Color(0xFFEF4444),
      ),
      textTheme: GoogleFonts.notoSansTcTextTheme().apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accentEarth,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          textStyle: GoogleFonts.notoSansTc(
            fontSize: 17, fontWeight: FontWeight.w700,
          ),
          disabledBackgroundColor: AppColors.disabled,
          disabledForegroundColor: AppColors.disabledText,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: ColorScheme.dark(
        primary: AppColors.darkAccentEarth,
        onPrimary: AppColors.darkBackground,
        primaryContainer: AppColors.darkAccentEarth.withValues(alpha: 0.1),
        secondary: AppColors.darkAccentCoral,
        onSecondary: Colors.white,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkTextPrimary,
        error: const Color(0xFFEF4444),
      ),
      textTheme: GoogleFonts.notoSansTcTextTheme().apply(
        bodyColor: AppColors.darkTextPrimary,
        displayColor: AppColors.darkTextPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.darkAccentEarth,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          textStyle: GoogleFonts.notoSansTc(
            fontSize: 17, fontWeight: FontWeight.w700,
          ),
          disabledBackgroundColor: AppColors.darkDisabled,
          disabledForegroundColor: AppColors.darkDisabledText,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}
