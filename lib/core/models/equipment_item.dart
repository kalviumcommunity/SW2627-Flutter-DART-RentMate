import 'package:flutter/material.dart';

/// Central domain model for equipment inventory and booking manifests in RentFlow.
class EquipmentItem {
  final String id;
  final String sku;
  final String name;
  final String category;
  final String flightCase;
  final String rackBay;
  final int total;
  final int available;
  final int deployed;
  final double dailyRate;
  final String status;
  final String specs;
  final IconData? icon;

  const EquipmentItem({
    required this.id,
    required this.sku,
    required this.name,
    required this.category,
    this.flightCase = 'FC-GEN-01',
    this.rackBay = 'BAY-01-A',
    required this.total,
    required this.available,
    required this.deployed,
    required this.dailyRate,
    required this.status,
    required this.specs,
    this.icon,
  });

  double get progressRatio => total > 0 ? (deployed / total).clamp(0.0, 1.0) : 0.0;
}
