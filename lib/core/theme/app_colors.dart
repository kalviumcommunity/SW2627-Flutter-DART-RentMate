import 'package:flutter/material.dart';

/// Central design tokens and color palette for RentFlow.
///
/// Flutter & Dart Concepts:
/// - `abstract final class`: Pure namespace container; cannot be instantiated or extended.
/// - `static const Color`: Compile-time constant colors. `0xFF` represents the alpha
///   channel (100% opacity) followed by the 6-character hex code.
/// - Centralization Rule: Never hardcode hex codes directly inside screen widgets.
///   Referencing [AppColors] guarantees consistency across the entire application.
abstract final class AppColors {
  AppColors._();

  // Primary Brand Identity
  static const Color forestObsidian = Color(0xFF121816); // Deep near-black forest
  static const Color alpineEvergreen = Color(0xFF154D38); // Main brand/action green
  static const Color evergreenHover = Color(0xFF1C6349); // Subtle interactive hover/focus
  static const Color evergreenSubtle = Color(0xFFE8F2EC); // Light tinted badge fill

  // Surface & Neutral Backgrounds
  static const Color warmIvory = Color(0xFFFBF9F6); // Warm operational canvas
  static const Color pureWhite = Color(0xFFFFFFFF); // High-contrast card surfaces
  static const Color surfaceMuted = Color(0xFFF1EFEA); // Nested sections & inputs

  // Functional & Semantic Accents
  static const Color industrialAmber = Color(0xFFB45309); // Warnings, packing, review
  static const Color amberSubtle = Color(0xFFFEF3C7); // Amber badge background
  static const Color hazardCrimson = Color(0xFFA92A2A); // Overlaps, double-booking conflicts
  static const Color crimsonSubtle = Color(0xFFFEE2E2); // Conflict banner background
  static const Color successGreen = Color(0xFF16A34A); // Confirmed, completed
  static const Color successSubtle = Color(0xFFDCFCE7); // Success badge background

  // Typography & Structural Borders
  static const Color slateSteel = Color(0xFF475569); // Slate steel for secondary elements
  static const Color textPrimary = Color(0xFF0F172A); // High-contrast slate navy
  static const Color textSecondary = Color(0xFF475569); // Slate steel for labels
  static const Color textMuted = Color(0xFF94A3B8); // Placeholders and disabled text
  static const Color structuralBorder = Color(0xFFCBD5E1); // Crisp 1px container borders
  static const Color borderSubtle = Color(0xFFE2E8F0); // Hairline divider borders
}
