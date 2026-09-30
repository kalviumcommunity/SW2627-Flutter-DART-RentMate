import 'package:flutter/material.dart';

/// Centralized application theme for RentFlow.
///
/// Flutter Concept:
/// - `ThemeData`: Defines the visual look and feel (colors, typography, shapes)
///   for all Material widgets in the app.
/// - `ColorScheme.fromSeed`: Automatically derives a harmonious tonal palette
///   from a single primary seed color adhering to Material 3 design rules.
/// - `final class`: Ensures this class cannot be extended or implemented outside
///   this library, maintaining architectural boundaries.
final class AppTheme {
  AppTheme._();

  // Brand Palette: Deep Industrial Navy & Energetic Teal
  static const Color primarySeed = Color(0xFF1E3A8A); // Deep Slate Navy
  static const Color accentTeal = Color(0xFF0D9488); // Professional Teal
  static const Color surfaceLight = Color(0xFFF8FAFC); // Crisp Off-White
  static const Color cardLight = Colors.white;

  /// Light theme definition used throughout RentFlow.
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primarySeed,
        brightness: Brightness.light,
        primary: primarySeed,
        secondary: accentTeal,
        surface: surfaceLight,
      ),
      scaffoldBackgroundColor: surfaceLight,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: primarySeed,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(
            color: Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
      ),
    );
  }
}
