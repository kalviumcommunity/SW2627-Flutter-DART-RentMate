import 'package:cloud_firestore/cloud_firestore.dart';

/// Central Booking model for RentFlow and RentMate operations.
class BookingItem {
  final String id;
  final String eventTitle;
  final String clientName;
  final String category;
  final String date;
  final String venue;
  final String status;
  final int unitsCount;
  final double totalAmount;
  final String? phoneNumber;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<Map<String, dynamic>> items;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? createdBy;

  const BookingItem({
    required this.id,
    required this.eventTitle,
    required this.clientName,
    required this.category,
    required this.date,
    required this.venue,
    required this.status,
    required this.unitsCount,
    required this.totalAmount,
    this.phoneNumber,
    this.startDate,
    this.endDate,
    this.items = const [],
    this.createdAt,
    this.updatedAt,
    this.createdBy,
  });

  /// Computes a clean normalized start date (00:00:00) for interval checks.
  DateTime get normalizedStartDate {
    if (startDate != null) {
      return DateTime(startDate!.year, startDate!.month, startDate!.day);
    }
    // Fallback: Parse or default to current date
    return DateTime.now();
  }

  /// Computes a clean normalized end date (inclusive until 23:59:59 or exclusive start of next day).
  DateTime get normalizedEndDate {
    if (endDate != null) {
      return DateTime(endDate!.year, endDate!.month, endDate!.day);
    }
    final start = normalizedStartDate;
    return start.add(const Duration(days: 1));
  }

  /// Checks if this booking overlaps with the specified date range.
  /// Convention: Both start and end dates are inclusive for event rental days.
  bool overlapsWith(DateTime start, DateTime end) {
    if (status.toUpperCase() == 'CANCELLED') return false;

    final normStart = DateTime(start.year, start.month, start.day);
    final normEnd = DateTime(end.year, end.month, end.day);
    final myStart = normalizedStartDate;
    final myEnd = normalizedEndDate;

    // Overlap condition for inclusive date intervals [start1, end1] and [start2, end2]:
    // start1 <= end2 && start2 <= end1
    return !myStart.isAfter(normEnd) && !myEnd.isBefore(normStart);
  }

  /// Quantity allocated for a specific SKU in this booking.
  int quantityForSku(String sku) {
    final clean = sku.trim().toUpperCase();
    for (final item in items) {
      if (item['sku']?.toString().toUpperCase() == clean ||
          item['id']?.toString().toUpperCase() == clean) {
        return (item['quantity'] as num?)?.toInt() ??
            (item['selectedQty'] as num?)?.toInt() ??
            (item['qty'] as num?)?.toInt() ??
            0;
      }
    }
    return 0;
  }

  factory BookingItem.fromMap(Map<String, dynamic> map, {String? id}) {
    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      if (val is Timestamp) return val.toDate();
      if (val is DateTime) return val;
      if (val is String) return DateTime.tryParse(val);
      return null;
    }

    final sDate = parseDate(map['startAt'] ?? map['startDate']);
    final eDate = parseDate(map['endAt'] ?? map['endDate']);

    List<Map<String, dynamic>> parseItems(dynamic raw) {
      if (raw is List) {
        return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      return [];
    }

    return BookingItem(
      id: id ?? map['id']?.toString() ?? '',
      eventTitle: map['eventName']?.toString() ?? map['eventTitle']?.toString() ?? '',
      clientName: map['customerName']?.toString() ?? map['clientName']?.toString() ?? '',
      category: map['eventType']?.toString() ?? map['category']?.toString() ?? 'General',
      date: map['date']?.toString() ??
          (sDate != null
              ? '${sDate.day}/${sDate.month}/${sDate.year} — ${eDate?.day ?? sDate.day}/${eDate?.month ?? sDate.month}/${eDate?.year ?? sDate.year}'
              : 'TBD'),
      venue: map['venue']?.toString() ?? '',
      status: map['status']?.toString().toUpperCase() ?? 'CONFIRMED',
      unitsCount: (map['unitsCount'] as num?)?.toInt() ??
          (map['items'] is List
              ? (map['items'] as List).fold<int>(0, (totalUnits, i) => totalUnits + ((i['quantity'] ?? i['qty'] ?? 1) as num).toInt())
              : 0),
      totalAmount: (map['estimatedTotal'] as num?)?.toDouble() ??
          (map['totalAmount'] as num?)?.toDouble() ??
          0.0,
      phoneNumber: map['phoneNumber']?.toString(),
      startDate: sDate,
      endDate: eDate,
      items: parseItems(map['items']),
      createdAt: parseDate(map['createdAt']),
      updatedAt: parseDate(map['updatedAt']),
      createdBy: map['createdBy']?.toString(),
    );
  }

  factory BookingItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return BookingItem.fromMap(data, id: doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eventName': eventTitle,
      'eventTitle': eventTitle,
      'customerName': clientName,
      'clientName': clientName,
      'phoneNumber': phoneNumber,
      'venue': venue,
      'eventType': category,
      'category': category,
      'date': date,
      'status': status.toUpperCase(),
      'unitsCount': unitsCount,
      'estimatedTotal': totalAmount,
      'totalAmount': totalAmount,
      'startAt': startDate != null ? Timestamp.fromDate(startDate!) : null,
      'endAt': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'items': items,
      'createdBy': createdBy,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  BookingItem copyWith({
    String? id,
    String? eventTitle,
    String? clientName,
    String? category,
    String? date,
    String? venue,
    String? status,
    int? unitsCount,
    double? totalAmount,
    String? phoneNumber,
    DateTime? startDate,
    DateTime? endDate,
    List<Map<String, dynamic>>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
  }) {
    return BookingItem(
      id: id ?? this.id,
      eventTitle: eventTitle ?? this.eventTitle,
      clientName: clientName ?? this.clientName,
      category: category ?? this.category,
      date: date ?? this.date,
      venue: venue ?? this.venue,
      status: status ?? this.status,
      unitsCount: unitsCount ?? this.unitsCount,
      totalAmount: totalAmount ?? this.totalAmount,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}
