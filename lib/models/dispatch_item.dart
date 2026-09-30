import 'package:flutter/material.dart';

/// Item in a warehouse dispatch checklist manifest.
///
/// Flutter & Dart Concepts:
/// - Immutable presentation model representing physical warehouse packing status.
/// - Used by warehouse staff for item-by-item verification prior to truck departure.
class DispatchItem {
  final String id;
  final String equipmentName;
  final String category;
  final String sku;
  final int quantity;
  final bool isPacked;
  final String stagingLocation;
  final String caseIdentifier;

  const DispatchItem({
    required this.id,
    required this.equipmentName,
    required this.category,
    required this.sku,
    required this.quantity,
    required this.isPacked,
    required this.stagingLocation,
    required this.caseIdentifier,
  });

  DispatchItem copyWith({
    String? id,
    String? equipmentName,
    String? category,
    String? sku,
    int? quantity,
    bool? isPacked,
    String? stagingLocation,
    String? caseIdentifier,
  }) {
    return DispatchItem(
      id: id ?? this.id,
      equipmentName: equipmentName ?? this.equipmentName,
      category: category ?? this.category,
      sku: sku ?? this.sku,
      quantity: quantity ?? this.quantity,
      isPacked: isPacked ?? this.isPacked,
      stagingLocation: stagingLocation ?? this.stagingLocation,
      caseIdentifier: caseIdentifier ?? this.caseIdentifier,
    );
  }

  /// Icon based on equipment category.
  IconData get iconData {
    switch (category) {
      case 'Sound Systems':
        return Icons.speaker_group_rounded;
      case 'Stage Lighting':
        return Icons.light_mode_rounded;
      case 'Video & Screens':
        return Icons.tv_rounded;
      case 'Staging':
        return Icons.grid_view_rounded;
      case 'Event Furniture':
        return Icons.chair_rounded;
      case 'Cables & Distro':
      default:
        return Icons.cable_rounded;
    }
  }

  /// Sample manifest for the prompt reference:
  /// JBL Line Array, Moving Head Light, Truss, Wireless Mic, LED Screen, Cables & Accessories
  static List<DispatchItem> get sampleManifest => const [
        DispatchItem(
          id: 'DSP-01',
          equipmentName: 'JBL Line Array VRX932',
          category: 'Sound Systems',
          sku: 'SKU-SND-101',
          quantity: 4,
          isPacked: true,
          stagingLocation: 'Loading Dock 2',
          caseIdentifier: 'Flight Cases #1 - #4',
        ),
        DispatchItem(
          id: 'DSP-02',
          equipmentName: 'Moving Head Light Beam 230W',
          category: 'Stage Lighting',
          sku: 'SKU-LGT-204',
          quantity: 8,
          isPacked: true,
          stagingLocation: 'Loading Dock 2',
          caseIdentifier: 'Road Trunk #A1, #A2',
        ),
        DispatchItem(
          id: 'DSP-03',
          equipmentName: 'Truss (2m) Section',
          category: 'Stage Lighting',
          sku: 'SKU-TRS-301',
          quantity: 6,
          isPacked: true,
          stagingLocation: 'Bay R-08 Pallet',
          caseIdentifier: 'Bundles #T-01, #T-02',
        ),
        DispatchItem(
          id: 'DSP-04',
          equipmentName: 'Wireless Mic Dual Handheld',
          category: 'Sound Systems',
          sku: 'SKU-SND-105',
          quantity: 4,
          isPacked: false,
          stagingLocation: 'Audio Locker C',
          caseIdentifier: 'Peli Case #MIC-2',
        ),
        DispatchItem(
          id: 'DSP-05',
          equipmentName: 'LED Screen Panels (P3.91)',
          category: 'Video & Screens',
          sku: 'SKU-VID-401',
          quantity: 12,
          isPacked: false,
          stagingLocation: 'Video Dock 1',
          caseIdentifier: 'Flight Cases #V1 - #V3',
        ),
        DispatchItem(
          id: 'DSP-06',
          equipmentName: 'Cables & Accessories Trunk',
          category: 'Cables & Distro',
          sku: 'SKU-PWR-701',
          quantity: 2,
          isPacked: false,
          stagingLocation: 'Loading Dock 2',
          caseIdentifier: 'Heavy Trunk #CAB-8',
        ),
      ];
}
