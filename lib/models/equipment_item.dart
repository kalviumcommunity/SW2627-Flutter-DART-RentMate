import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Equipment asset data model for RentFlow inventory and booking allocation.
///
/// Flutter & Dart Concepts:
/// - Immutable value object with copyWith for state transitions.
/// - Encapsulates inventory metrics: Total, Available, Rate, and Conflict metadata.
class EquipmentItem {
  final String id;
  final String name;
  final String category;
  final String sku;
  final int totalQuantity;
  final int availableQuantity;
  final double dailyRate;
  final String description;
  final String location;
  final String status;
  final String? conflictingBookingName;
  final String? conflictingSchedule;
  final int? conflictingUnits;

  const EquipmentItem({
    required this.id,
    required this.name,
    required this.category,
    required this.sku,
    required this.totalQuantity,
    required this.availableQuantity,
    required this.dailyRate,
    required this.description,
    required this.location,
    required this.status,
    this.conflictingBookingName,
    this.conflictingSchedule,
    this.conflictingUnits,
  });

  /// True if stock is constrained (3 or fewer available units).
  bool get isLimited => availableQuantity > 0 && availableQuantity <= 3;

  /// True if stock is completely depleted.
  bool get isOutOfStock => availableQuantity <= 0;

  /// Semantic badge foreground color.
  Color get statusColor {
    switch (status) {
      case 'Available':
        return AppColors.successGreen;
      case 'Limited':
        return AppColors.industrialAmber;
      case 'Booked':
        return AppColors.alpineEvergreen;
      case 'Out of Stock':
      default:
        return AppColors.hazardCrimson;
    }
  }

  /// Semantic badge background color.
  Color get statusBgColor {
    switch (status) {
      case 'Available':
        return AppColors.successSubtle;
      case 'Limited':
        return AppColors.amberSubtle;
      case 'Booked':
        return AppColors.evergreenSubtle;
      case 'Out of Stock':
      default:
        return AppColors.crimsonSubtle;
    }
  }

  EquipmentItem copyWith({
    String? id,
    String? name,
    String? category,
    String? sku,
    int? totalQuantity,
    int? availableQuantity,
    double? dailyRate,
    String? description,
    String? location,
    String? status,
    String? conflictingBookingName,
    String? conflictingSchedule,
    int? conflictingUnits,
  }) {
    return EquipmentItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      sku: sku ?? this.sku,
      totalQuantity: totalQuantity ?? this.totalQuantity,
      availableQuantity: availableQuantity ?? this.availableQuantity,
      dailyRate: dailyRate ?? this.dailyRate,
      description: description ?? this.description,
      location: location ?? this.location,
      status: status ?? this.status,
      conflictingBookingName:
          conflictingBookingName ?? this.conflictingBookingName,
      conflictingSchedule: conflictingSchedule ?? this.conflictingSchedule,
      conflictingUnits: conflictingUnits ?? this.conflictingUnits,
    );
  }

  /// Realistic catalog representing the rental company's inventory assets.
  static List<EquipmentItem> get sampleCatalog => const [
        EquipmentItem(
          id: 'EQ-001',
          name: 'JBL Line Array VRX932',
          category: 'Sound Systems',
          sku: 'SKU-SND-101',
          totalQuantity: 20,
          availableQuantity: 3,
          dailyRate: 250.0,
          description: 'Dual 12-inch two-way powered line array speaker system.',
          location: 'Bay A-04 • Audio Staging',
          status: 'Limited',
          conflictingBookingName: 'TechCorp Annual Conference',
          conflictingSchedule: 'Tomorrow • 12:00 PM – 06:00 PM',
          conflictingUnits: 17,
        ),
        EquipmentItem(
          id: 'EQ-002',
          name: 'Moving Head Light Beam 230W',
          category: 'Stage Lighting',
          sku: 'SKU-LGT-204',
          totalQuantity: 24,
          availableQuantity: 3,
          dailyRate: 75.0,
          description: 'High-output 7R prism beam moving head with 14 colors.',
          location: 'Bay L-02 • Rigging Rack',
          status: 'Limited',
          conflictingBookingName: 'TechCorp Conference',
          conflictingSchedule: '14 Jan • 12 PM – 6 PM',
          conflictingUnits: 21,
        ),
        EquipmentItem(
          id: 'EQ-003',
          name: 'Aluminum Box Truss (2m)',
          category: 'Stage Lighting',
          sku: 'SKU-TRS-301',
          totalQuantity: 40,
          availableQuantity: 18,
          dailyRate: 45.0,
          description: 'Global Truss F34 square box truss segment, 2.0 meter.',
          location: 'Bay R-08 • Structural Truss',
          status: 'Available',
        ),
        EquipmentItem(
          id: 'EQ-004',
          name: 'Shure Wireless Mic Dual Handheld',
          category: 'Sound Systems',
          sku: 'SKU-SND-105',
          totalQuantity: 16,
          availableQuantity: 10,
          dailyRate: 60.0,
          description: 'BLX288/PG58 dual wireless microphone transmitter kit.',
          location: 'Locker C-01 • Microphones',
          status: 'Available',
        ),
        EquipmentItem(
          id: 'EQ-005',
          name: 'LED Par Light RGBW 54x3W',
          category: 'Stage Lighting',
          sku: 'SKU-LGT-208',
          totalQuantity: 60,
          availableQuantity: 22,
          dailyRate: 35.0,
          description: 'High-intensity DMX512 architectural wash light fixture.',
          location: 'Bay L-05 • Wash Fixtures',
          status: 'Available',
        ),
        EquipmentItem(
          id: 'EQ-006',
          name: 'P3.91 High-Res LED Screen Panel',
          category: 'Video & Screens',
          sku: 'SKU-VID-401',
          totalQuantity: 48,
          availableQuantity: 16,
          dailyRate: 120.0,
          description: '500x500mm outdoor die-cast rental video wall cabinet.',
          location: 'Bay V-01 • Video Modules',
          status: 'Available',
        ),
        EquipmentItem(
          id: 'EQ-007',
          name: 'Heavy-Duty Stage Deck (2m x 1m)',
          category: 'Staging',
          sku: 'SKU-STG-501',
          totalQuantity: 30,
          availableQuantity: 12,
          dailyRate: 55.0,
          description: 'All-weather non-slip birch plywood platform with 60cm legs.',
          location: 'Bay S-03 • Heavy Staging',
          status: 'Available',
        ),
        EquipmentItem(
          id: 'EQ-008',
          name: 'Chiavari Gold Resin Chairs',
          category: 'Event Furniture',
          sku: 'SKU-FUR-608',
          totalQuantity: 200,
          availableQuantity: 0,
          dailyRate: 8.0,
          description: 'Premium stackable gold wedding banquet chairs with cushions.',
          location: 'Warehouse B • Furniture Section',
          status: 'Out of Stock',
          conflictingBookingName: 'Royal Heritage Wedding Sangeet',
          conflictingSchedule: 'Today • 04:00 PM – 11:30 PM',
          conflictingUnits: 200,
        ),
        EquipmentItem(
          id: 'EQ-009',
          name: 'Banquet Round Table (6ft)',
          category: 'Event Furniture',
          sku: 'SKU-FUR-602',
          totalQuantity: 50,
          availableQuantity: 35,
          dailyRate: 25.0,
          description: '72-inch foldable banquet table for 10-person seating.',
          location: 'Warehouse B • Furniture Section',
          status: 'Available',
        ),
        EquipmentItem(
          id: 'EQ-010',
          name: 'Master 3-Phase Power Distro Rack',
          category: 'Cables & Distro',
          sku: 'SKU-PWR-701',
          totalQuantity: 8,
          availableQuantity: 2,
          dailyRate: 95.0,
          description: '63A 3-Phase CEE power distro unit with 12 Schuko outputs.',
          location: 'Bay E-01 • Electrical Dock',
          status: 'Limited',
          conflictingBookingName: 'Starlight Live Concert Tour',
          conflictingSchedule: 'Oct 02 • 06:00 PM – Midnight',
          conflictingUnits: 6,
        ),
      ];
}
