import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Centralized typographic scale for RentFlow (Editorial Event Studio - Option B).
///
/// Typography Direction:
/// - **Cinzel / Playfair Display**: Editorial brand titles, display headlines, and screen titles.
/// - **Plus Jakarta Sans**: Primary UI text, forms, labels, buttons, and navigation.
/// - **JetBrains Mono**: Technical numbers, status metrics, and operational timestamps.
abstract final class AppTextStyles {
  AppTextStyles._();

  // Editorial Event Studio Headings (Cinzel / Playfair Display)
  static TextStyle get brandTitle => GoogleFonts.cinzel(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.5,
        color: AppColors.inkBlack,
      );

  static TextStyle get displayTagline => GoogleFonts.playfairDisplay(
        fontSize: 26,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.5,
        height: 1.15,
        color: AppColors.paper,
      );

  static TextStyle get screenTitle => GoogleFonts.playfairDisplay(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.4,
        color: AppColors.inkBlack,
      );

  static TextStyle get sectionHeading => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        color: AppColors.inkBlack,
      );

  static TextStyle get cardTitle => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.1,
        color: AppColors.inkBlack,
      );

  // Body & Supporting Text (Plus Jakarta Sans)
  static TextStyle get bodyLarge => GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.inkBlack,
        height: 1.45,
      );

  static TextStyle get bodyMedium => GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.slate,
        height: 1.4,
      );

  static TextStyle get bodySmall => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.slate,
      );

  static TextStyle get labelSmall => GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
        color: AppColors.slate,
      );

  static TextStyle get buttonText => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
        color: Colors.white,
      );

  // Technical & Operational Numbers (JetBrains Mono)
  static TextStyle get monoMetric => GoogleFonts.jetBrainsMono(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.0,
        color: AppColors.inkBlack,
      );

  static TextStyle get monoData => GoogleFonts.jetBrainsMono(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: AppColors.inkBlack,
      );

  static TextStyle get monoLabel => GoogleFonts.jetBrainsMono(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: AppColors.slate,
      );
}
