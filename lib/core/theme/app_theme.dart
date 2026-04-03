import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primary = Color(0xFF0B6B4A);
  static const Color primaryDark = Color(0xFF053D2B);
  static const Color primaryLight = Color(0xFFDCF2E8);
  static const Color mediumGreen = Color(0xFF1DB872);
  static const Color lightGreen = Color(0xFFF0FAF5);
  static const Color amber = Color(0xFFD97706);
  static const Color lightAmber = Color(0xFFFEF3C7);
  static const Color coral = Color(0xFFDC2626);
  static const Color lightCoral = Color(0xFFFEE2E2);
  static const Color indigo = Color(0xFF4F46E5);
  static const Color lightIndigo = Color(0xFFEEF2FF);
  static const Color background = Color(0xFFF5F7F6);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color text = Color(0xFF0F1A14);
  static const Color muted = Color(0xFF6B7280);
  static const Color border = Color(0x12000000); // 0.07 alpha
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.mediumGreen,
        background: AppColors.background,
        surface: AppColors.surface,
        onPrimary: Colors.white,
        onBackground: AppColors.text,
        onSurface: AppColors.text,
      ),
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        displayLarge: GoogleFonts.fraunces(
          fontWeight: FontWeight.w800,
          color: AppColors.text,
        ),
        headlineMedium: GoogleFonts.fraunces(
          fontWeight: FontWeight.w700,
          color: AppColors.text,
        ),
        titleLarge: GoogleFonts.poppins(
          fontWeight: FontWeight.w700,
          color: AppColors.text,
        ),
        bodyLarge: GoogleFonts.poppins(
          fontSize: 14,
          color: AppColors.text,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 12,
          color: AppColors.text,
        ),
        labelSmall: GoogleFonts.poppins(
          fontSize: 10,
          color: AppColors.muted,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1),
        ),
        hintStyle: const TextStyle(color: AppColors.muted, fontSize: 13),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
        ),
      ),
    );
  }
}
