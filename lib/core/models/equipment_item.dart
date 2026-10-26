import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Central domain model for equipment inventory and booking manifests in RentFlow / RentMate.
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
  final int maintenance;
  final double dailyRate;
  final String status;
  final String specs;
  final IconData? icon;
  final DateTime? createdAt;
  final DateTime? updatedAt;

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
    this.maintenance = 0,
    required this.dailyRate,
    required this.status,
    required this.specs,
    this.icon,
    this.createdAt,
    this.updatedAt,
  });

  double get progressRatio => total > 0 ? (deployed / total).clamp(0.0, 1.0) : 0.0;

  /// Effective physical rentable capacity (excluding broken/damaged units).
  int get rentableCapacity => (total - maintenance).clamp(0, total);

  factory EquipmentItem.fromMap(Map<String, dynamic> map, {String? id}) {
    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      if (val is Timestamp) return val.toDate();
      if (val is DateTime) return val;
      if (val is String) return DateTime.tryParse(val);
      return null;
    }

    final total = (map['totalQuantity'] as num?)?.toInt() ??
        (map['total'] as num?)?.toInt() ??
        0;
    final available = (map['rentableQuantity'] as num?)?.toInt() ??
        (map['available'] as num?)?.toInt() ??
        0;
    final deployed = (map['deployed'] as num?)?.toInt() ?? 0;
    final maintenance = (map['maintenance'] as num?)?.toInt() ??
        (total - (available + deployed)).clamp(0, total);

    return EquipmentItem(
      id: id ?? map['id']?.toString() ?? map['sku']?.toString() ?? '',
      sku: map['sku']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      category: map['category']?.toString() ?? 'Sound',
      flightCase: map['flightCase']?.toString() ?? 'FC-GEN-01',
      rackBay: map['rackBay']?.toString() ?? 'BAY-01-A',
      total: total,
      available: available,
      deployed: deployed,
      maintenance: maintenance,
      dailyRate: (map['dailyRate'] as num?)?.toDouble() ?? 1000.0,
      status: map['status']?.toString().toUpperCase() ?? 'IN WAREHOUSE',
      specs: map['specs']?.toString() ?? '',
      createdAt: parseDate(map['createdAt']),
      updatedAt: parseDate(map['updatedAt']),
    );
  }

  factory EquipmentItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return EquipmentItem.fromMap(data, id: doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sku': sku,
      'name': name,
      'category': category,
      'flightCase': flightCase,
      'rackBay': rackBay,
      'totalQuantity': total,
      'total': total,
      'rentableQuantity': available,
      'available': available,
      'deployed': deployed,
      'maintenance': maintenance,
      'dailyRate': dailyRate,
      'status': status.toUpperCase(),
      'specs': specs,
      'active': true,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  EquipmentItem copyWith({
    String? id,
    String? sku,
    String? name,
    String? category,
    String? flightCase,
    String? rackBay,
    int? total,
    int? available,
    int? deployed,
    int? maintenance,
    double? dailyRate,
    String? status,
    String? specs,
    IconData? icon,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EquipmentItem(
      id: id ?? this.id,
      sku: sku ?? this.sku,
      name: name ?? this.name,
      category: category ?? this.category,
      flightCase: flightCase ?? this.flightCase,
      rackBay: rackBay ?? this.rackBay,
      total: total ?? this.total,
      available: available ?? this.available,
      deployed: deployed ?? this.deployed,
      maintenance: maintenance ?? this.maintenance,
      dailyRate: dailyRate ?? this.dailyRate,
      status: status ?? this.status,
      specs: specs ?? this.specs,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
