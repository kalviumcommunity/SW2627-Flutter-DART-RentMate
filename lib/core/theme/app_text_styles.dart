import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Centralized typographic scale for RentFlow (Industrial Atelier).
///
/// Typography Direction:
/// - **Manrope**: Primary UI text, headings, buttons, and navigation.
/// - **IBM Plex Mono**: Technical numbers, status metrics, and operational SKUs.
abstract final class AppTextStyles {
  AppTextStyles._();

  // Primary Editorial Headings (Manrope)
  static TextStyle get brandTitle => GoogleFonts.manrope(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.6,
        color: AppColors.inkBlack,
      );

  static TextStyle get screenTitle => GoogleFonts.manrope(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        color: AppColors.inkBlack,
      );

  static TextStyle get sectionHeading => GoogleFonts.manrope(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        color: AppColors.inkBlack,
      );

  static TextStyle get cardTitle => GoogleFonts.manrope(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        color: AppColors.inkBlack,
      );

  // Body & Supporting Text (Manrope)
  static TextStyle get bodyLarge => GoogleFonts.manrope(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.inkBlack,
        height: 1.45,
      );

  static TextStyle get bodyMedium => GoogleFonts.manrope(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.slate,
        height: 1.4,
      );

  static TextStyle get bodySmall => GoogleFonts.manrope(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.slate,
      );

  static TextStyle get labelSmall => GoogleFonts.manrope(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        color: AppColors.slate,
      );

  static TextStyle get buttonText => GoogleFonts.manrope(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.1,
        color: Colors.white,
      );

  // Technical & Operational Numbers (IBM Plex Mono)
  static TextStyle get monoMetric => GoogleFonts.ibmPlexMono(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.0,
        color: AppColors.inkBlack,
      );

  static TextStyle get monoData => GoogleFonts.ibmPlexMono(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: AppColors.inkBlack,
      );

  static TextStyle get monoLabel => GoogleFonts.ibmPlexMono(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: AppColors.slate,
      );
}
