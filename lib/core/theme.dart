import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color purple = Color(0xFF7C3AED);
  static const Color purpleLight = Color(0xFFEDE9FE);
  static const Color warmOrange = Color(0xFFF59E0B);
  static const Color bg = Color(0xFFFAFAF5);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1C1917);
  static const Color textSecondary = Color(0xFF78716C);
  static const Color textMuted = Color(0xFFA8A29E);

  // Mood Colors
  static const Color moodGreat = Color(0xFF10B981);
  static const Color moodOkay = Color(0xFFF59E0B);
  static const Color moodBad = Color(0xFFEF4444);
  static const Color moodAngry = Color(0xFFF97316);
  static const Color moodAnxious = Color(0xFF8B5CF6);
  static const Color moodSad = Color(0xFF3B82F6);

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme.light(
        primary: purple,
        onPrimary: Colors.white,
        primaryContainer: purpleLight,
        onPrimaryContainer: purple,
        secondary: warmOrange,
        onSecondary: Colors.white,
        surface: cardBg,
        onSurface: textPrimary,
        surfaceContainerHighest: const Color(0xFFF5F5F0),
      ),
      textTheme: GoogleFonts.notoSansHkTextTheme().apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppTheme.cardBg,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        indicatorColor: purpleLight,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.notoSansHk(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: purple,
            );
          }
          return GoogleFonts.notoSansHk(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: textMuted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: purple, size: 24);
          }
          return const IconThemeData(color: textMuted, size: 24);
        }),
      ),
    );
  }
}
