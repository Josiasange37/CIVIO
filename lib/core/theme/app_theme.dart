import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Airbnb-inspired premium token system for EKEMA v2.
class EkemaColors {
  EkemaColors._();

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

class EkemaSpacing {
  EkemaSpacing._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

class EkemaRadius {
  EkemaRadius._();
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double pill = 999;
}

class EkemaShadows {
  EkemaShadows._();

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
}

class EkemaTheme {
  static TextTheme get _textTheme {
    final base = GoogleFonts.plusJakartaSansTextTheme();
    return base.copyWith(
      displayLarge: GoogleFonts.plusJakartaSans(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: EkemaColors.textPrimary,
        letterSpacing: -0.5,
      ),
      headlineMedium: GoogleFonts.plusJakartaSans(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: EkemaColors.textPrimary,
      ),
      titleLarge: GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: EkemaColors.textPrimary,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: EkemaColors.textPrimary,
      ),
      bodyLarge: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: EkemaColors.textPrimary,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: EkemaColors.textPrimary,
        height: 1.45,
      ),
      labelSmall: GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: EkemaColors.textSecondary,
        letterSpacing: 0.5,
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: EkemaColors.canvas,
      colorScheme: ColorScheme.fromSeed(
        seedColor: EkemaColors.brand,
        primary: EkemaColors.brand,
        onPrimary: EkemaColors.textInverse,
        surface: EkemaColors.canvas,
        onSurface: EkemaColors.textPrimary,
        outline: EkemaColors.border,
      ),
      textTheme: _textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: EkemaColors.canvas,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: EkemaColors.textPrimary,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: EkemaColors.textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: EkemaColors.canvas,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(EkemaRadius.md),
        ),
        shadowColor: Colors.black.withValues(alpha: 0.08),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: EkemaColors.subtle,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(EkemaRadius.sm),
          borderSide: const BorderSide(color: EkemaColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(EkemaRadius.sm),
          borderSide: const BorderSide(color: EkemaColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(EkemaRadius.sm),
          borderSide: const BorderSide(color: EkemaColors.brand, width: 1.5),
        ),
        hintStyle: GoogleFonts.plusJakartaSans(
          color: EkemaColors.textSecondary,
          fontSize: 15,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: EkemaColors.brand,
          foregroundColor: EkemaColors.textInverse,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(EkemaRadius.sm),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: EkemaColors.textPrimary,
          side: const BorderSide(color: EkemaColors.textPrimary, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(EkemaRadius.sm),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return EkemaColors.brand;
          return EkemaColors.textSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return EkemaColors.brand.withValues(alpha: 0.35);
          }
          return EkemaColors.border;
        }),
      ),
      dividerTheme: const DividerThemeData(
        color: EkemaColors.border,
        thickness: 1,
      ),
    );
  }
}

/// Legacy alias — migrate imports to [EkemaColors].
@Deprecated('Use EkemaColors instead')
typedef AppColors = EkemaColors;

/// Legacy alias — migrate imports to [EkemaTheme].
@Deprecated('Use EkemaTheme instead')
typedef AppTheme = EkemaTheme;
