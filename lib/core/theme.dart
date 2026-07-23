import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ═══════════════════════════════════════════════════════════════════════
// Classic Edition — 經典 · 心靈 · 悟
// Core: 舊紙 #F5F0E8 · 墨色 #2C2416 · 硃砂紅 #A04030 · 金色 #B8944B
// ═══════════════════════════════════════════════════════════════════════

class AppColors {
  static const background = Color(0xFFF5F0E8);     // 舊紙
  static const surface = Color(0xFFFFFBF5);        // 新紙
  static const elevated = Color(0xFFFFFFFF);       // 白
  static const border = Color(0xFFEDE5D8);         // 淺墨邊
  static const divider = Color(0xFFEDE5D8);
  static const gap = Color(0xFFF0EAE0);            // 自然分隔色

  // Text
  static const textPrimary = Color(0xFF2C2416);    // 濃墨
  static const textSecondary = Color(0xFF6B5E4A);  // 淡墨
  static const textMuted = Color(0xFFB8AFA0);      // 更淡墨
  static const textOnPrimary = Color(0xFFF5F0E8);  // 舊紙色 on accent bg

  // Accents
  static const primary = Color(0xFFA04030);         // 硃砂紅 — CTA/印章
  static const gold = Color(0xFFB8944B);            // 金色
  static const ink = Color(0xFF2C2416);             // 墨色
  static const success = Color(0xFF6B8F6B);         // 沉穩綠
  static const error = Color(0xFFA04030);           // 硃砂紅

  // ─── BACKWARD COMPAT ALIASES ───
  static const cta = primary;
  static const accentEarth = primary;
  static const accentCoral = primary;
  static const accentSage = success;
  static const accentDusty = Color(0xFFB8A9C9);
  static const accentGold = gold;
  static const purple = accentDusty;
  static const sage = success;
  static const mustard = gold;
  static const accentTeal = Color(0xFF66B2B2);
  static const accentLavender = accentDusty;
  static const accentAmber = Color(0xFFF8E8C6);
  static const badgeSage = success;
  static const badgeGold = gold;
  static const badgeLavender = accentDusty;
  static const disabled = border;
  static const disabledText = textMuted;

  // Dark Mode — 夜讀
  static const darkBackground = Color(0xFF1A1510);  // 墨硯
  static const darkSurface = Color(0xFF241E18);     // 深紙
  static const darkElevated = Color(0xFF2C2416);    // 濃墨
  static const darkTextPrimary = Color(0xFFD4C9B0); // 舊書頁
  static const darkTextSecondary = Color(0xFFA0907A);
  static const darkTextMuted = Color(0xFF7A6B5A);
  static const darkPrimary = Color(0xFFC06050);     // 硃砂 light
  static const darkGold = Color(0xFFD4B85C);        // 金 light

  // Dark mode backward compat
  static const darkAccentEarth = darkPrimary;
  static const darkAccentCoral = darkPrimary;
  static const darkAccentSage = Color(0xFF6B8F6B);
  static const darkAccentDusty = Color(0xFFA5A7C5);
  static const darkAccentGold = darkGold;
  static const darkBorder = Color(0xFF3A3A3C);
  static const darkDisabled = Color(0xFF3A3A3C);
  static const darkDisabledText = Color(0xFF6B7280);
  static const darkDivider = divider;
  static const darkSuccess = success;
  static const darkError = error;
  static const darkAccentTeal = Color(0xFF66B2B2);
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
  static const double sm = 4.0;
  static const double md = 8.0;
  static const double lg = 12.0;
  static const double xl = 16.0;
}

// ─── SHADOWS (Borderless = none) ───
class AppShadows {
  static List<BoxShadow> get card => [];
  static List<BoxShadow> get elevated => [];
}

// ─── APP BORDERLESS HELPERS ───
class AppBorderless {
  static BoxDecoration card({bool isDark = false}) => BoxDecoration(
    color: isDark ? null : Colors.white,
    borderRadius: BorderRadius.circular(8),
  );
  static Widget divider({bool isDark = false}) => Divider(
    height: 1, thickness: 1,
    color: isDark ? const Color(0xFF3A3A3C) : const Color(0xFFEDE5D8),
  );
  static Widget gap({bool isDark = false}) => Container(
    height: 8,
    color: isDark ? const Color(0xFF1A1510) : const Color(0xFFF0EAE0),
  );
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
        onPrimary: AppColors.textOnPrimary,
        primaryContainer: AppColors.primary.withValues(alpha: 0.1),
        secondary: AppColors.gold,
        onSecondary: AppColors.textPrimary,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
      ),
      textTheme: GoogleFonts.notoSerifTcTextTheme().apply(
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
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          minimumSize: const Size(double.infinity, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.notoSerifTc(
            fontSize: 15, fontWeight: FontWeight.w600,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
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
        primary: AppColors.darkPrimary,
        onPrimary: AppColors.darkBackground,
        primaryContainer: AppColors.darkPrimary.withValues(alpha: 0.15),
        secondary: AppColors.darkGold,
        onSecondary: AppColors.darkTextPrimary,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkTextPrimary,
        error: AppColors.error,
      ),
      textTheme: GoogleFonts.notoSerifTcTextTheme().apply(
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
          backgroundColor: AppColors.darkPrimary,
          foregroundColor: AppColors.darkBackground,
          minimumSize: const Size(double.infinity, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.notoSerifTc(
            fontSize: 15, fontWeight: FontWeight.w600,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
