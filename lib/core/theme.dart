import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 型得你 — Design Tokens
/// Source: Design Standards.md (Jul 2026)
/// Material Design 3 + Apple HIG + WCAG 2.2

// ─── Colors ───
class AppColors {
  static const primary = Color(0xFF1B3A5C);
  static const secondary = Color(0xFFFF7E67);
  static const background = Color(0xFFF5F0EB);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF1C1917);
  static const textSecondary = Color(0xFF78716C);
  static const textMuted = Color(0xFFA8A29E);
  static const border = Color(0xFFE5E0DB);

  // Semantic
  static const success = Color(0xFF34D399);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);

  // Mood
  static const moodGreat = Color(0xFF34D399);
  static const moodOkay = Color(0xFFF59E0B);
  static const moodBad = Color(0xFFEF4444);
  static const moodAngry = Color(0xFFF97316);
  static const moodAnxious = Color(0xFF8B5CF6);
  static const moodSad = Color(0xFF3B82F6);

  // Component states
  static const disabled = Color(0xFFD1D5DB);
  static const disabledText = Color(0xFF9CA3AF);
  static const skeleton = Color(0xFFE5E7EB);
}

// ─── Spacing (4px grid) ───
class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;
}

// ─── Radius ───
class AppRadius {
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
}

// ─── Theme ───
class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        primaryContainer: AppColors.primary.withValues(alpha: 0.1),
        secondary: AppColors.secondary,
        onSecondary: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
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
          backgroundColor: AppColors.secondary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: GoogleFonts.notoSansTc(
            fontSize: 17, fontWeight: FontWeight.w700,
          ),
          disabledBackgroundColor: AppColors.disabled,
          disabledForegroundColor: AppColors.disabledText,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          minimumSize: const Size(double.infinity, 50),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          side: BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          textStyle: GoogleFonts.notoSansTc(
            fontSize: 15, fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
