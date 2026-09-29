import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Premium party look for Truth or Dare (scoped to this feature).
class TodColors {
  static const bg = Color(0xFF0F0A1F);
  static const surface = Color(0xFF1A1230);
  static const card = Color(0xFF241B3D);
  static const purple = Color(0xFF8B5CF6);
  static const pink = Color(0xFFEC4899);
  static const indigo = Color(0xFF6366F1);
  static const truth = Color(0xFF38BDF8);
  static const dare = Color(0xFFF472B6);
  static const ink = Color(0xFFF8FAFC);
  static const muted = Color(0xFFA78BFA);

  static const gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2E1065), Color(0xFF4C1D95), Color(0xFF831843)],
  );

  static const buttonGradient = LinearGradient(
    colors: [purple, pink],
  );
}

class TodTheme {
  static ThemeData get dark {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: TodColors.bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: TodColors.purple,
        brightness: Brightness.dark,
        surface: TodColors.surface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: TodColors.ink,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontWeight: FontWeight.w900, color: TodColors.ink, letterSpacing: -0.5),
        headlineMedium: TextStyle(fontWeight: FontWeight.w800, color: TodColors.ink),
        titleLarge: TextStyle(fontWeight: FontWeight.w700, color: TodColors.ink),
        bodyLarge: TextStyle(color: TodColors.ink, height: 1.4),
        bodyMedium: TextStyle(color: TodColors.muted, height: 1.4),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: TodColors.card,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        hintStyle: const TextStyle(color: TodColors.muted),
      ),
    );
    return base;
  }
}

Future<void> todHaptic(bool enabled) async {
  if (!enabled) return;
  await HapticFeedback.lightImpact();
}

Future<void> todClick(bool enabled) async {
  if (!enabled) return;
  await SystemSound.play(SystemSoundType.click);
}
