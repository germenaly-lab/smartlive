import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Light Logo-Inspired Color Palette
  static const Color bgLight = Color(0xFFE8F1FD); // Soft logo light blue
  static const Color bgGradientStart = Color(0xFFDEEAF8); // Top blue tint
  static const Color bgGradientMid = Color(0xFFEFF5FC);   // Soft transition
  static const Color bgGradientEnd = Color(0xFFF8FAFC);   // Pure soft white

  static const Color surfaceLight = Color(0xFFF1F5F9);
  static const Color cardLight = Colors.white;
  static const Color borderLight = Color(0xFFCBD5E1);

  static const Color primary = Color(0xFF2563EB); // Royal Blue
  static const Color primaryGlow = Color(0xFF3B82F6);
  static const Color accentGreen = Color(0xFF10B981); // Emerald
  static const Color accentAmber = Color(0xFFF59E0B); // Amber
  static const Color accentBlue = Color(0xFF0284C7);
  static const Color accentRose = Color(0xFFF43F5E);
  static const Color accentPurple = Color(0xFF8B5CF6);

  static const Color textPrimary = Color(0xFF0F172A); // Dark slate
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF94A3B8);

  // Deprecated dark color aliases maintained for backwards compatibility
  static const Color bgDark = bgLight;
  static const Color surfaceDark = surfaceLight;
  static const Color cardDark = cardLight;
  static const Color borderDark = borderLight;

  /// Main background gradient matching the 3D modern house logo
  static const BoxDecoration logoBackgroundDecoration = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        bgGradientStart,
        bgGradientMid,
        bgGradientEnd,
      ],
      stops: [0.0, 0.45, 1.0],
    ),
  );

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: bgLight,
    colorScheme: const ColorScheme.light(
      primary: primary,
      secondary: accentGreen,
      surface: cardLight,
      onPrimary: Colors.white,
      onSurface: textPrimary,
    ),
    textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme).copyWith(
      displayLarge: const TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
      titleLarge: const TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
      bodyLarge: const TextStyle(color: textPrimary),
      bodyMedium: const TextStyle(color: textSecondary),
    ),
    cardTheme: CardThemeData(
      color: cardLight,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      foregroundColor: textPrimary,
    ),
  );

  // Keep darkTheme alias returning lightTheme for consistent global app look matching the logo
  static ThemeData get darkTheme => lightTheme;
}
