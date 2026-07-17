import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── DAEBI PALETTE ───
class AppColors {
  // Earth base
  static const background = Color(0xFFF5EDE0);  // Warm Sand
  static const surface = Color(0xFFFFF9F0);      // Warm White
  static const border = Color(0xFFE5DCCE);
  static const divider = Color(0xFFE5DCCE);

  // Text (all Dark Brown)
  // Contrast ratios on #F5EDE0 (background): 8:1, 5.65:1, 4.67:1 ✅
  static const textPrimary = Color(0xFF5C4033);
  static const textSecondary = Color(0xFF7A5540);
  static const textMuted = Color(0xFF7A6658);

  // Accents (background/decorative only, never text on light bg)
  static const primary = Color(0xFF5C4033);       // Dark Brown
  static const cta = Color(0xFFE0785A);           // Muted Coral
  static const purple = Color(0xFF9B72AA);        // Soft Purple
  static const mustard = Color(0xFFD4A843);       // Warm Mustard
  static const sage = Color(0xFF8FA87A);          // Soft Sage

  // States
  static const disabled = Color(0xFFE5DCCE);
  static const disabledText = Color(0xFFC2A48C);
  static const skeleton = Color(0xFFE5DCCE);
}

// ─── SPACING ───
class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

// ─── RADIUS ───
class AppRadius {
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
}

// ─── THEME ───
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
        secondary: AppColors.cta,
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
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.cta,
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
    );
  }
}
