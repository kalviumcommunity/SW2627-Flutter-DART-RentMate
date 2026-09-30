import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Centralized typographic scale for RentFlow.
///
/// Typography Direction:
/// - **Plus Jakarta Sans**: Primary UI text, headings, buttons, and navigation.
/// - **JetBrains Mono**: Technical numbers, status metrics, and inventory quantities.
///
/// Flutter Concept:
/// Using [GoogleFonts] provides pre-calibrated font metrics. If the device is
/// offline during first launch, it gracefully falls back to the system sans-serif.
abstract final class AppTextStyles {
  AppTextStyles._();

  // Headings & Brand Text (Plus Jakarta Sans)
  static TextStyle get brandTitle => GoogleFonts.plusJakartaSans(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.6,
        color: AppColors.forestObsidian,
      );

  static TextStyle get screenTitle => GoogleFonts.plusJakartaSans(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        color: AppColors.textPrimary,
      );

  static TextStyle get sectionHeading => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        color: AppColors.textPrimary,
      );

  static TextStyle get cardTitle => GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        color: AppColors.textPrimary,
      );

  // Body & Supporting Text
  static TextStyle get bodyLarge => GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.45,
      );

  static TextStyle get bodyMedium => GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.4,
      );

  static TextStyle get bodySmall => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      );

  static TextStyle get buttonLabel => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      );

  // Technical & Numeric Data (JetBrains Mono)
  static TextStyle get metricNumber => GoogleFonts.jetBrainsMono(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: AppColors.textPrimary,
      );

  static TextStyle get monoLabel => GoogleFonts.jetBrainsMono(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: AppColors.textSecondary,
      );

  static TextStyle get badgeText => GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
      );
}
