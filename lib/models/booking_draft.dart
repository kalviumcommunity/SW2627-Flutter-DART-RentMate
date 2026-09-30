import 'package:flutter/material.dart';
import 'equipment_item.dart';

/// Transient state holder for creating a new booking across the 3-step wizard.
///
/// Flutter & Dart Concepts:
/// - Clean separation between input form state, equipment selection, and review.
/// - Unidirectional data flow enables seamless back-and-forth step navigation
///   without losing entered operational data.
class BookingDraft {
  final String eventName;
  final String customerName;
  final String phoneNumber;
  final String venue;
  final DateTime eventDate;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String eventType;
  final String notes;
  final Map<String, int> selectedQuantities;
  final Set<String> waitlistedItemIds;

  const BookingDraft({
    required this.eventName,
    required this.customerName,
    required this.phoneNumber,
    required this.venue,
    required this.eventDate,
    required this.startTime,
    required this.endTime,
    required this.eventType,
    required this.notes,
    required this.selectedQuantities,
    required this.waitlistedItemIds,
  });

  /// Factory providing default starting values for a new booking.
  factory BookingDraft.initial() {
    final now = DateTime.now();
    return BookingDraft(
      eventName: '',
      customerName: '',
      phoneNumber: '',
      venue: '',
      eventDate: now.add(const Duration(days: 1)),
      startTime: const TimeOfDay(hour: 10, minute: 0),
      endTime: const TimeOfDay(hour: 18, minute: 0),
      eventType: 'Corporate',
      notes: '',
      selectedQuantities: const {},
      waitlistedItemIds: const {},
    );
  }

  /// Sample pre-populated draft for instant demo and testing.
  factory BookingDraft.sample() {
    return BookingDraft(
      eventName: 'Starlight Gala Evening',
      customerName: 'Aarav Mehta',
      phoneNumber: '+91 98290 44556',
      venue: 'Fairmont Palace Ballroom, Jaipur',
      eventDate: DateTime.now().add(const Duration(days: 2)),
      startTime: const TimeOfDay(hour: 14, minute: 0),
      endTime: const TimeOfDay(hour: 23, minute: 0),
      eventType: 'Corporate',
      notes: 'Loading dock access via Gate 3. Sound check at 12:00 PM.',
      selectedQuantities: {
        'EQ-001': 2, // JBL Line Array (Available: 3)
        'EQ-003': 6, // Truss (Available: 18)
        'EQ-004': 4, // Wireless Mic (Available: 10)
      },
      waitlistedItemIds: const {},
    );
  }

  /// Total count of physical equipment pieces requested.
  int get totalItemCount {
    return selectedQuantities.values.fold(0, (sum, count) => sum + count);
  }

  /// Total number of unique equipment lines selected.
  int get distinctLineItemCount {
    return selectedQuantities.entries.where((e) => e.value > 0).length;
  }

  /// Compute total equipment rental amount based on catalog daily rates.
  double calculateSubtotal(List<EquipmentItem> catalog) {
    double subtotal = 0.0;
    for (final entry in selectedQuantities.entries) {
      if (entry.value <= 0) continue;
      final item = catalog.cast<EquipmentItem?>().firstWhere(
            (it) => it?.id == entry.key,
            orElse: () => null,
          );
      if (item != null) {
        subtotal += item.dailyRate * entry.value;
      }
    }
    return subtotal;
  }

  /// Warehouse handling and dispatch surcharge.
  double get logisticsFee => 150.0;

  /// Full estimated invoice amount.
  double calculateTotal(List<EquipmentItem> catalog) {
    return calculateSubtotal(catalog) + (totalItemCount > 0 ? logisticsFee : 0);
  }

  /// Detect if any requested quantity exceeds available warehouse stock.
  bool hasConflict(List<EquipmentItem> catalog) {
    for (final entry in selectedQuantities.entries) {
      if (entry.value <= 0) continue;
      final item = catalog.cast<EquipmentItem?>().firstWhere(
            (it) => it?.id == entry.key,
            orElse: () => null,
          );
      if (item != null && entry.value > item.availableQuantity) {
        return true;
      }
    }
    return false;
  }

  /// Retrieve the list of items that have stock shortages.
  List<({EquipmentItem item, int requested, int shortage})> getConflictingItems(
      List<EquipmentItem> catalog) {
    final conflicts = <({EquipmentItem item, int requested, int shortage})>[];
    for (final entry in selectedQuantities.entries) {
      if (entry.value <= 0) continue;
      final item = catalog.cast<EquipmentItem?>().firstWhere(
            (it) => it?.id == entry.key,
            orElse: () => null,
          );
      if (item != null && entry.value > item.availableQuantity) {
        conflicts.add((
          item: item,
          requested: entry.value,
          shortage: entry.value - item.availableQuantity,
        ));
      }
    }
    return conflicts;
  }

  BookingDraft copyWith({
    String? eventName,
    String? customerName,
    String? phoneNumber,
    String? venue,
    DateTime? eventDate,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    String? eventType,
    String? notes,
    Map<String, int>? selectedQuantities,
    Set<String>? waitlistedItemIds,
  }) {
    return BookingDraft(
      eventName: eventName ?? this.eventName,
      customerName: customerName ?? this.customerName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      venue: venue ?? this.venue,
      eventDate: eventDate ?? this.eventDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      eventType: eventType ?? this.eventType,
      notes: notes ?? this.notes,
      selectedQuantities: selectedQuantities ?? this.selectedQuantities,
      waitlistedItemIds: waitlistedItemIds ?? this.waitlistedItemIds,
    );
  }
}
