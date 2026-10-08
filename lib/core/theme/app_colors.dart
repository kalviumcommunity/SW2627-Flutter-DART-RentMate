import 'package:flutter/material.dart';

/// Industrial Atelier color palette for RentFlow.
///
/// Palette Direction:
/// - Ink Black & Bone/Paper form the primary high-contrast operational surfaces.
/// - Burnt Copper is the signature RentFlow action & highlight color.
/// - Aged Brass provides warm metallic operational accents.
/// - Muted Sage & Success Green communicate operational states without dominating.
abstract final class AppColors {
  AppColors._();

  // Primary Foundations
  static const Color inkBlack = Color(0xFF111514);       // Deepest foundational surface
  static const Color bone = Color(0xFFF3EEE5);           // Warm editorial canvas
  static const Color paper = Color(0xFFFAF7F0);          // Crisp elevated surface

  // Signature Brand Accents
  static const Color burntCopper = Color(0xFFB86A45);    // Signature RentFlow action color
  static const Color copperHover = Color(0xFFA35B38);    // Interactive hover / pressed
  static const Color copperSubtle = Color(0xFFF5EBE6);   // Soft tinted fill for badges/pills
  static const Color agedBrass = Color(0xFFC59A5A);      // Warm metallic highlight & warnings

  // Operational & Semantic Accents
  static const Color mutedSage = Color(0xFF849687);      // Operational neutral / standby
  static const Color slate = Color(0xFF5B6664);          // Secondary typography & metadata
  static const Color softStone = Color(0xFFD9D1C5);      // Structural dividers & fine rules
  static const Color success = Color(0xFF3F7D5A);        // Confirmed / Ready / Dispatched
  static const Color successSubtle = Color(0xFFE8F1EB);  // Success badge background
  static const Color warning = Color(0xFFC8893D);        // Packing / Attention required
  static const Color warningSubtle = Color(0xFFF9F3EA);  // Warning badge background
  static const Color danger = Color(0xFFB94A4A);         // Conflicts / Errors
  static const Color dangerSubtle = Color(0xFFF9EAEA);   // Conflict badge background

  // Compatibility Aliases for Design System consistency
  static const Color forestObsidian = inkBlack;
  static const Color alpineEvergreen = burntCopper;     // Signature action color
  static const Color warmIvory = bone;
  static const Color pureWhite = paper;
  static const Color surfaceMuted = bone;
  static const Color textPrimary = inkBlack;
  static const Color textSecondary = slate;
  static const Color textMuted = Color(0xFF8C9694);
  static const Color structuralBorder = softStone;
  static const Color borderSubtle = Color(0xFFE5DFD5);
  static const Color industrialAmber = agedBrass;
  static const Color hazardCrimson = danger;
  static const Color successGreen = success;
}
