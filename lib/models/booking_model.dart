import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_colors.dart';

/// Represents an event equipment booking in RentFlow.
///
/// Flutter & Dart Concepts Taught:
/// - `immutable model`: In Flutter, data models should be immutable (`final` fields)
///   to maintain unidirectional data flow and predictable widget rendering.
/// - `enum` vs String constants: Using typed classes ensures compile-time safety
///   while allowing easy mapping to UI badges and colors.
class BookingItem {
  final String id;
  final String eventName;
  final String venue;
  final String clientName;
  final String dateSchedule;
  final String equipmentSummary;
  final int totalUnits;
  final String status;
  final String? conflictDetails;

  const BookingItem({
    required this.id,
    required this.eventName,
    required this.venue,
    required this.clientName,
    required this.dateSchedule,
    required this.equipmentSummary,
    required this.totalUnits,
    required this.status,
    this.conflictDetails,
  });

  /// Helper providing semantic color token for the status.
  Color get statusColor {
    switch (status) {
      case AppConstants.statusConflict:
        return AppColors.hazardCrimson;
      case AppConstants.statusConfirmed:
        return AppColors.successGreen;
      case AppConstants.statusInProgress:
        return AppColors.alpineEvergreen;
      case AppConstants.statusPacking:
      case AppConstants.statusPending:
        return AppColors.industrialAmber;
      case AppConstants.statusCompleted:
      default:
        return AppColors.slateSteel;
    }
  }

  Color get statusBackgroundColor {
    switch (status) {
      case AppConstants.statusConflict:
        return AppColors.crimsonSubtle;
      case AppConstants.statusConfirmed:
        return AppColors.successSubtle;
      case AppConstants.statusInProgress:
        return AppColors.evergreenSubtle;
      case AppConstants.statusPacking:
      case AppConstants.statusPending:
        return AppColors.amberSubtle;
      case AppConstants.statusCompleted:
      default:
        return AppColors.surfaceMuted;
    }
  }

  /// Realistic sample data for UI demonstration and testing.
  /// (Will be replaced with Firestore collection stream in later phases).
  static List<BookingItem> get sampleBookings => const [
        BookingItem(
          id: 'RF-8421',
          eventName: 'Royal Heritage Wedding Sangeet',
          venue: 'Fairmont Palace Ballroom, Jaipur',
          clientName: 'Singhania & Co. Events',
          dateSchedule: 'Today • 04:00 PM – 11:30 PM',
          equipmentSummary: 'Line Array PA, 32 Moving Heads, Truss Rigging',
          totalUnits: 48,
          status: AppConstants.statusConflict,
          conflictDetails:
              'Overlaps with Tech Summit: 8 JBL VRX932 committed to both loading docks.',
        ),
        BookingItem(
          id: 'RF-8419',
          eventName: 'National FinTech Conclave 2026',
          venue: 'JECC Convention Hall A, Sitapura',
          clientName: 'Apex Corporate Solutions',
          dateSchedule: 'Tomorrow • 08:00 AM – 06:00 PM',
          equipmentSummary: 'Dual 4K LED Walls, Wireless Podium Mics, Staging',
          totalUnits: 64,
          status: AppConstants.statusPacking,
        ),
        BookingItem(
          id: 'RF-8415',
          eventName: 'Starlight Live Concert Tour',
          venue: 'SMS Stadium Ground, Jaipur',
          clientName: 'Aura Entertainment Group',
          dateSchedule: 'Oct 02 • 06:00 PM – Midnight',
          equipmentSummary: '3-Phase Distro Rack, Followspots, Subwoofers',
          totalUnits: 82,
          status: AppConstants.statusConfirmed,
        ),
        BookingItem(
          id: 'RF-8408',
          eventName: 'Executive Leadership Gala Dinner',
          venue: 'Rambagh Palace Lawn',
          clientName: 'Oberoi Luxe Experiences',
          dateSchedule: 'Oct 03 • 07:00 PM – 11:00 PM',
          equipmentSummary: 'Acoustic Warm Lighting, Banquet Sound Package',
          totalUnits: 28,
          status: AppConstants.statusInProgress,
        ),
        BookingItem(
          id: 'RF-8392',
          eventName: 'Youth Tech Innovation Hackathon',
          venue: 'JECRC University Auditorium',
          clientName: 'JECRC Student Council',
          dateSchedule: 'Sep 28 • 09:00 AM – 09:00 PM',
          equipmentSummary: 'PA Towers, Stage Monitors, Amber Wash Pars',
          totalUnits: 36,
          status: AppConstants.statusCompleted,
        ),
      ];
}
