import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Airbnb-inspired premium token system for Civio v2.
class CivioColors {
  CivioColors._();

  static const Color brand = Color(0xFFFF385C);
  static const Color brandHover = Color(0xFFE31C5F);
  static const Color brandLight = Color(0xFFFFF0F3);

  static const Color canvas = Color(0xFFFFFFFF);
  static const Color subtle = Color(0xFFF7F7F7);
  static const Color border = Color(0xFFDDDDDD);

  static const Color textPrimary = Color(0xFF222222);
  static const Color textSecondary = Color(0xFF717171);
  static const Color textInverse = Color(0xFFFFFFFF);

  static const Color success = Color(0xFF008A05);
  static const Color successLight = Color(0xFFE8F5EE);
  static const Color warning = Color(0xFFE07912);
  static const Color warningLight = Color(0xFFFFF8E8);
  static const Color info = Color(0xFF004CC4);
  static const Color infoLight = Color(0xFFE8F4FF);

  static const Color categoryCni = Color(0xFFFFE8EC);
  static const Color categoryCivil = Color(0xFFE8F4FF);
  static const Color categoryBusiness = Color(0xFFFFF8E8);
  static const Color categorySchool = Color(0xFFF3E8FF);
  static const Color categoryLegal = Color(0xFFE8F5EE);
  static const Color categoryWrite = Color(0xFFF5F5F5);
}

class CivioSpacing {
  CivioSpacing._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

class CivioRadius {
  CivioRadius._();
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double pill = 999;
}

class CivioShadows {
  CivioShadows._();

  static List<BoxShadow> get sm => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get md => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.12),
          blurRadius: 20,
          offset: const Offset(0, 6),
        ),
      ];

  static List<BoxShadow> get lg => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.18),
          blurRadius: 32,
          offset: const Offset(0, 12),
        ),
      ];
}

class CivioTheme {
  static TextTheme get _textTheme {
    final base = GoogleFonts.plusJakartaSansTextTheme();
    return base.copyWith(
      displayLarge: GoogleFonts.plusJakartaSans(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: CivioColors.textPrimary,
        letterSpacing: -0.5,
      ),
      headlineMedium: GoogleFonts.plusJakartaSans(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: CivioColors.textPrimary,
      ),
      titleLarge: GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: CivioColors.textPrimary,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: CivioColors.textPrimary,
      ),
      bodyLarge: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: CivioColors.textPrimary,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: CivioColors.textPrimary,
        height: 1.45,
      ),
      labelSmall: GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: CivioColors.textSecondary,
        letterSpacing: 0.5,
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: CivioColors.canvas,
      colorScheme: ColorScheme.fromSeed(
        seedColor: CivioColors.brand,
        primary: CivioColors.brand,
        onPrimary: CivioColors.textInverse,
        surface: CivioColors.canvas,
        onSurface: CivioColors.textPrimary,
        outline: CivioColors.border,
      ),
      textTheme: _textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: CivioColors.canvas,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: CivioColors.textPrimary,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: CivioColors.textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: CivioColors.canvas,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CivioRadius.md),
        ),
        shadowColor: Colors.black.withValues(alpha: 0.08),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: CivioColors.subtle,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CivioRadius.sm),
          borderSide: const BorderSide(color: CivioColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CivioRadius.sm),
          borderSide: const BorderSide(color: CivioColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CivioRadius.sm),
          borderSide: const BorderSide(color: CivioColors.brand, width: 1.5),
        ),
        hintStyle: GoogleFonts.plusJakartaSans(
          color: CivioColors.textSecondary,
          fontSize: 15,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: CivioColors.brand,
          foregroundColor: CivioColors.textInverse,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(CivioRadius.sm),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: CivioColors.textPrimary,
          side: const BorderSide(color: CivioColors.textPrimary, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(CivioRadius.sm),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return CivioColors.brand;
          return CivioColors.textSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return CivioColors.brand.withValues(alpha: 0.35);
          }
          return CivioColors.border;
        }),
      ),
      dividerTheme: const DividerThemeData(
        color: CivioColors.border,
        thickness: 1,
      ),
    );
  }
}

/// Legacy alias — migrate imports to [CivioColors].
@Deprecated('Use CivioColors instead')
typedef AppColors = CivioColors;

/// Legacy alias — migrate imports to [CivioTheme].
@Deprecated('Use CivioTheme instead')
typedef AppTheme = CivioTheme;
