import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ═══════════════════════════════════════════════════════════════════════
// Edition 4 — Professional Mobile Reading App Color System
// Inspired by 微信讀書 × Apple Books
// ═══════════════════════════════════════════════════════════════════════

class AppColors {
  // ─── Light Mode — warm neutrals ───
  static const background = Color(0xFFF8F6F3);   // warm off-white
  static const surface = Color(0xFFFFFFFF);       // white cards
  static const border = Color(0xFFE8E6E1);        // subtle border
  static const divider = Color(0xFFE8E6E1);

  // Text
  static const textPrimary = Color(0xFF2D2D2D);   // near black
  static const textSecondary = Color(0xFF8E8E93);  // gray
  static const textMuted = Color(0xFFAEAEB2);      // light gray

  // New Edition 4 accent palette
  static const accentEarth = Color(0xFF8B7355);   // warm brown
  static const accentSage = Color(0xFF7A9E7E);    // muted green
  static const accentDusty = Color(0xFFB8A9C9);   // muted purple
  static const accentCoral = Color(0xFFD4735E);   // warm coral
  static const accentGold = Color(0xFFC9A84C);    // muted gold

  // Legacy aliases (referenced by other screens)
  static const primary = accentEarth;
  static const cta = accentCoral;
  static const purple = accentDusty;
  static const mustard = accentGold;
  static const sage = accentSage;

  // States
  static const disabled = Color(0xFFE8E6E1);
  static const disabledText = Color(0xFFAEAEB2);

  // ─── Dark Mode — deep charcoal ───
  static const darkBackground = Color(0xFF1C1C1E);
  static const darkSurface = Color(0xFF2C2C2E);
  static const darkBorder = Color(0xFF3A3A3C);
  static const darkTextPrimary = Color(0xFFF5F5F0);
  static const darkTextSecondary = Color(0xFF8E8E93);
  static const darkTextMuted = Color(0xFF636366);
  static const darkDivider = Color(0xFF3A3A3C);
  static const darkDisabled = Color(0xFF3A3A3C);
  static const darkDisabledText = Color(0xFF636366);

  // Dark mode accents (slightly desaturated for dark bg)
  static const darkAccentEarth = Color(0xFFA08565);
  static const darkAccentSage = Color(0xFF8AB08E);
  static const darkAccentDusty = Color(0xFFC9B8D9);
  static const darkAccentCoral = Color(0xFFE0836E);
  static const darkAccentGold = Color(0xFFD4B85C);
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
