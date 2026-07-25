import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ═══════════════════════════════════════════════════════════════════════
// 經典·心靈·悟 — 型得你 Official Design System
// Core: 舊紙 #F5F0E8 · 墨 #2C2416 · 硃砂紅 #A04030 · 金 #B8944B
// Philosophy: Borderless Cards · Typography as Ornament
// ═══════════════════════════════════════════════════════════════════════

class AppColors {
  // ─── Light Mode ───
  static const background = Color(0xFFF5F0E8);       // 舊紙 — warm vintage paper
  static const surface = Color(0xFFF5F0E8);          // same as bg — borderless
  static const elevated = Color(0xFFF9F5ED);         // slightly lighter for subtle lift
  static const border = Color(0xFFE5E0D8);           // subtle warm border (rare use)
  static const divider = Color(0xFFE5E0D8);          // 1px divider
  static const gap = Color(0xFFF0EBE3);              // section gap

  // ─── Text ───
  static const textPrimary = Color(0xFF2C2416);      // 墨 — deep ink
  static const textSecondary = Color(0xFF6B6253);    // faded ink
  static const textMuted = Color(0xFF9C9484);        // light ink
  static const textOnPrimary = Color(0xFFF5F0E8);    // old paper on dark

  // ─── Accents (Minimal — typography is the ornament) ───
  static const primary = Color(0xFFA04030);           // 硃砂紅 — cinnabar red (CTA only)
  static const accent = Color(0xFFA04030);            // alias
  static const accentLight = Color(0x20A04030);      // 12.5% alpha
  static const gold = Color(0xFFB8944B);              // 金 — warm gold (subtle accents)
  static const ink = Color(0xFF2C2416);               // 墨 — primary text color
  static const success = Color(0xFF7A9E6D);           // muted sage green
  static const error = Color(0xFFA04030);             // cinnabar = error too

  // ─── Special ───
  static const accentTeal = Color(0xFF6B8F8F);       // muted teal for variety
  static const accentWarm = Color(0xFFD4C4A8);        // warm sand

  // ─── Backward Compat Aliases ───
  static const cta = primary;
  static const accentCoral = primary;
  static const accentDusty = Color(0xFFB8A9C9);
  static const accentSage = success;
  static const accentGold = gold;
  static const accentTealAlt = accentTeal;
  static const badgeSage = success;
  static const badgeGold = gold;
  static const badgeLavender = accentDusty;
  static const disabled = Color(0xFFE5E0D8);
  static const disabledText = textMuted;

  // ─── Cross-file Compatibility (pointing to design-system equivalents) ───
  static const purple = primary;          // 硃砂紅 replaces purple accents
  static const sage = success;            //  sage green
  static const mustard = gold;             // 暖金 replaces mustard accents

  // ─── Background Gradient (subtle warmth) ───
  static LinearGradient backgroundGradient() => const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF5F0E8), Color(0xFFF0EBE3)],
  );

  // ─── Dark Mode — 墨硯 ───
  static const darkBackground = Color(0xFF1A1510);    // 墨硯 — ink stone
  static const darkSurface = Color(0xFF221D17);       // slightly lighter
  static const darkElevated = Color(0xFF2A251E);
  static const darkTextPrimary = Color(0xFFF5F0E8);  // old paper on dark
  static const darkTextSecondary = Color(0xFFA09888);
  static const darkTextMuted = Color(0xFF6B6253);
  static const darkPrimary = Color(0xFFC05545);       // lighter cinnabar for dark
  static const darkGold = Color(0xFFD4B85C);
  static const darkBorder = Color(0xFF2A251E);
  static const darkDisabled = Color(0xFF2A251E);
  static const darkDisabledText = Color(0xFF6B6253);
  static const darkDivider = Color(0xFF2A251E);
  static const darkSuccess = Color(0xFF7A9E6D);
  static const darkError = Color(0xFFC05545);
  static const darkAccentTeal = Color(0xFF6B8F8F);
  static const darkSurfaceAlt = Color(0xFF28231D);
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

// ─── RADIUS (subtle — never fully rounded) ───
class AppRadius {
  static const double sm = 4.0;
  static const double md = 8.0;
  static const double lg = 12.0;
  static const double xl = 16.0;
  static const double xxl = 20.0;
}

// ─── SHADOWS (NONE by design — borderless philosophy) ───
// Cards have NO shadows. Use Divider + background gaps for separation.
class AppShadows {
  static List<BoxShadow> get card => [];
  static List<BoxShadow> get elevated => [];
}

// ─── BORDERLESS HELPERS ───
class AppBorderless {
  /// Card surface — no shadow, no border. Pure content.
  static BoxDecoration card({bool isDark = false}) => BoxDecoration(
    color: isDark ? AppColors.darkSurfaceAlt : Colors.transparent,
    borderRadius: BorderRadius.circular(AppRadius.md),
  );

  /// Subtle section gap
  static Widget gap({bool isDark = false}) => Container(
    height: 8,
    color: isDark ? AppColors.darkBackground : AppColors.gap,
  );

  /// 1px divider
  static Widget divider({bool isDark = false}) => Divider(
    height: 1, thickness: 1,
    color: isDark ? AppColors.darkDivider : AppColors.divider,
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
      textTheme: GoogleFonts.notoSansTcTextTheme().apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ).copyWith(
        // H1
        headlineLarge: GoogleFonts.notoSerifTc(
          fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
        ),
        // H2
        headlineMedium: GoogleFonts.notoSansTc(
          fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary,
        ),
        // H3
        headlineSmall: GoogleFonts.notoSansTc(
          fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary,
        ),
        // Body
        bodyLarge: GoogleFonts.notoSansTc(
          fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.textPrimary, height: 1.6,
        ),
        // Caption
        bodySmall: GoogleFonts.notoSansTc(
          fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.textSecondary,
        ),
        // Quote
        titleLarge: GoogleFonts.notoSerifTc(
          fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 1.5,
        ),
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
          textStyle: GoogleFonts.notoSansTc(
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
      textTheme: GoogleFonts.notoSansTcTextTheme().apply(
        bodyColor: AppColors.darkTextPrimary,
        displayColor: AppColors.darkTextPrimary,
      ).copyWith(
        headlineLarge: GoogleFonts.notoSerifTc(
          fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.darkTextPrimary,
        ),
        headlineMedium: GoogleFonts.notoSansTc(
          fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.darkTextPrimary,
        ),
        headlineSmall: GoogleFonts.notoSansTc(
          fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.darkTextPrimary,
        ),
        bodyLarge: GoogleFonts.notoSansTc(
          fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.darkTextPrimary, height: 1.6,
        ),
        bodySmall: GoogleFonts.notoSansTc(
          fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.darkTextSecondary,
        ),
        titleLarge: GoogleFonts.notoSerifTc(
          fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.darkTextPrimary, height: 1.5,
        ),
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
          textStyle: GoogleFonts.notoSansTc(
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
