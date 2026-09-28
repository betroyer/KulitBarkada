import 'package:flutter/material.dart';

/// LearnUp-inspired soft lavender system for Kulit Barkada.
class AppColors {
  static const primary = Color(0xFF2B1B6B);
  static const primaryDark = Color(0xFF1A1248);
  static const accent = Color(0xFF7C5CFC);
  static const pink = Color(0xFFFF6B9D);
  static const sky = Color(0xFF6EC1FF);
  static const gold = Color(0xFFFFC857);
  static const background = Color(0xFFF2F0FF);
  static const surface = Color(0xFFFFFFFF);
  static const ink = Color(0xFF1A1248);
  static const muted = Color(0xFF7A7599);
  static const success = Color(0xFF16A34A);
  static const danger = Color(0xFFE11D48);

  static const members = Color(0xFF4F7CFF);
  static const food = Color(0xFFFF6B9D);
  static const places = Color(0xFF2DD4BF);
  static const activities = Color(0xFF7C5CFC);
  static const decide = Color(0xFFFF6B9D);
  static const expenses = Color(0xFF2B1B6B);
  static const plan = Color(0xFF4F7CFF);
  static const summary = Color(0xFFFFC857);
  static const games = Color(0xFFBE185D);

  static const heroGradient = LinearGradient(
    colors: [Color(0xFFE9E2FF), Color(0xFFD6CCFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: const Color(0xFF1A1248).withValues(alpha: 0.07),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ];
}

class AppTheme {
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.accent,
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.surface,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.ink,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.ink,
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.accent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primaryDark,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(54),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          foregroundColor: AppColors.primaryDark,
          side: BorderSide(color: AppColors.primaryDark.withValues(alpha: 0.18)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.accent.withValues(alpha: 0.15),
        labelStyle: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        side: BorderSide.none,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primaryDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      dividerTheme: DividerThemeData(color: AppColors.ink.withValues(alpha: 0.06)),
    );
  }
}
