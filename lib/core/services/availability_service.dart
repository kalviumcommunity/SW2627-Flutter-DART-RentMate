import 'dart:async';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/booking_item.dart';
import 'auth_service.dart';
import 'booking_repository.dart';
import 'inventory_repository.dart';

/// Detailed information on an equipment shortage during a booking window.
class AvailabilityConflict {
  final String equipmentName;
  final String sku;
  final int requestedQty;
  final int availableQty;
  final int shortage;
  final String conflictingEvent;
  final DateTime conflictingDate;

  const AvailabilityConflict({
    required this.equipmentName,
    required this.sku,
    required this.requestedQty,
    required this.availableQty,
    required this.shortage,
    required this.conflictingEvent,
    required this.conflictingDate,
  });

  @override
  String toString() =>
      'AvailabilityConflict(sku: $sku, requested: $requestedQty, available: $availableQty, conflictingEvent: $conflictingEvent)';
}

/// The outcome of an equipment availability check across a date range.
class AvailabilityCheckResult {
  final bool isAvailable;
  final List<AvailabilityConflict> conflicts;
  final Map<String, int> minAvailablePerSku;

  const AvailabilityCheckResult({
    required this.isAvailable,
    this.conflicts = const [],
    this.minAvailablePerSku = const {},
  });

  bool get hasConflicts => !isAvailable || conflicts.isNotEmpty;

  String get summary {
    if (isAvailable) return 'All requested equipment is available for the full schedule.';
    final primary = conflicts.first;
    return 'Shortage of ${primary.shortage}x ${primary.equipmentName} (${primary.sku}) on ${primary.conflictingDate.day}/${primary.conflictingDate.month} due to overlap with ${primary.conflictingEvent}.';
  }
}

/// Exception thrown when a booking reservation is rejected due to concurrent or capacity conflicts.
class AvailabilityConflictException implements Exception {
  final AvailabilityCheckResult checkResult;
  final String message;

  AvailabilityConflictException(this.checkResult, [String? message])
      : message = message ?? checkResult.summary;

  @override
  String toString() => 'AvailabilityConflictException: $message';
}

/// Exception thrown when attempting to create a booking with an ID that already exists.
class DuplicateBookingException implements Exception {
  final String message;
  DuplicateBookingException(this.message);

  @override
  String toString() => 'DuplicateBookingException: $message';
}

/// Authoritative Date-Aware Availability & Distributed Reservation Engine for RentMate.
///
/// Features:
/// 1. Evaluates multi-day inclusive date overlap against active bookings and physical stock.
/// 2. Enforces non-negative rentable capacity ($Total - Maintenance$).
/// 3. Distributed Concurrency: Executes Firestore transactions reading physical equipment
///    and per-equipment per-day allocation documents (`allocations/{sku}_{yyyy-MM-dd}`)
///    before atomically writing reservations.
/// 4. All-or-Nothing Guarantee: If any item or calendar day has a shortage, the entire
///    transaction is rejected without leaving partial allocations.
/// 5. Safe Cancellation & Rescheduling: Concurrency-safe capacity release and atomic reallocations.
class AvailabilityService {
  static final AvailabilityService _instance = AvailabilityService._internal();
  factory AvailabilityService() => _instance;
  AvailabilityService._internal();

  final BookingRepository _bookingRepo = BookingRepository();
  final InventoryRepository _inventoryRepo = InventoryRepository();

  /// Explicit flag to enable test/mock persistence mode (used when Firebase is disabled or in unit tests).
  static bool useMockPersistence = false;

  /// Internal in-memory allocation ledger for mock/test execution.
  /// Key: `${sku}_${dateKey}` -> Map with 'allocatedQuantity' and 'bookings'.
  final Map<String, Map<String, dynamic>> _mockAllocations = {};

  /// Clears in-memory allocation ledger and seeds from current active bookings.
  void resetAndSeedAllocations() {
    _mockAllocations.clear();
    _allocationsReconciled = false;
    for (final b in _bookingRepo.bookings) {
      if (b.status.toUpperCase() == 'CANCELLED' || b.status.toUpperCase() == 'COMPLETED') {
        continue;
      }
      final sDate = b.startDate ?? b.normalizedStartDate;
      final eDate = b.endDate ?? b.normalizedEndDate;
      final days = generateRentalDays(sDate, eDate);

      for (final item in b.items) {
        final sku = (item['sku'] ?? item['id'] ?? '').toString().trim().toUpperCase();
        final qty = (item['quantity'] ?? item['selectedQty'] ?? item['qty'] ?? 0) as int;
        if (sku.isEmpty || qty <= 0) continue;

        for (final day in days) {
          final key = '${sku}_${formatDateKey(day)}';
          final current = _mockAllocations[key] ?? {'allocatedQuantity': 0, 'bookings': <String, int>{}};
          current['allocatedQuantity'] = ((current['allocatedQuantity'] as int?) ?? 0) + qty;
          (current['bookings'] as Map<String, int>)[b.id] = qty;
          _mockAllocations[key] = current;
        }
      }
    }
  }

  /// Lock for in-memory serialization during tests.
  Future<void>? _inMemoryLock;

  bool _allocationsReconciled = false;

  /// Normalizes a DateTime to midnight (00:00:00) local calendar day.
  static DateTime normalizeDate(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  /// Formats a DateTime into a deterministic YYYY-MM-DD key.
  static String formatDateKey(DateTime dt) =>
      '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  /// Generates the list of calendar days covered by the rental interval [startDate, endDate] inclusive.
  static List<DateTime> generateRentalDays(DateTime startDate, DateTime endDate) {
    final start = normalizeDate(startDate);
    final end = normalizeDate(endDate);

    if (end.isBefore(start)) {
      return [start];
    }

    final daysCount = end.difference(start).inDays + 1;
    return List.generate(
      daysCount,
      (i) => start.add(Duration(days: i)),
    );
  }

  Future<T> _synchronized<T>(Future<T> Function() action) async {
    final previousLock = _inMemoryLock;
    final completer = Completer<void>();
    _inMemoryLock = completer.future;

    if (previousLock != null) {
      await previousLock;
    }

    try {
      return await action();
    } finally {
      completer.complete();
      if (_inMemoryLock == completer.future) {
        _inMemoryLock = null;
      }
    }
  }

  /// Reconciles existing active Firestore bookings with the allocations collection.
  /// Ensures pre-existing bookings reserve their capacity before any new booking is accepted.
  Future<void> ensureAllocationsReconciled() async {
    if (_allocationsReconciled || !AuthService().isFirebaseInitialized || useMockPersistence) {
      return;
    }

    try {
      final firestore = FirebaseFirestore.instance;
      final activeSnapshots = await firestore
          .collection('bookings')
          .where('status', whereNotIn: ['CANCELLED', 'COMPLETED'])
          .get();

      if (activeSnapshots.docs.isEmpty) {
        _allocationsReconciled = true;
        return;
      }

      final Map<String, int> aggregateAllocations = {};
      final Map<String, Map<String, int>> bookingContributors = {};

      for (final doc in activeSnapshots.docs) {
        final b = BookingItem.fromFirestore(doc);
        final days = generateRentalDays(b.normalizedStartDate, b.normalizedEndDate);

        for (final item in b.items) {
          final sku = (item['sku'] ?? item['id'] ?? '').toString().trim().toUpperCase();
          final qty = (item['quantity'] ?? item['selectedQty'] ?? item['qty'] ?? 0) as int;
          if (sku.isEmpty || qty <= 0) continue;

          for (final day in days) {
            final key = '${sku}_${formatDateKey(day)}';
            aggregateAllocations[key] = (aggregateAllocations[key] ?? 0) + qty;
            bookingContributors.putIfAbsent(key, () => {})[b.id] = qty;
          }
        }
      }

      final batch = firestore.batch();
      for (final entry in aggregateAllocations.entries) {
        final allocRef = firestore.collection('allocations').doc(entry.key);
        final parts = entry.key.split('_');
        final sku = parts.first;
        final date = parts.length > 1 ? parts.sublist(1).join('_') : '';

        batch.set(allocRef, {
          'sku': sku,
          'date': date,
          'allocatedQuantity': entry.value,
          'bookings': bookingContributors[entry.key] ?? {},
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      await batch.commit();
      _allocationsReconciled = true;
    } catch (e) {
      debugPrint('Allocations reconciliation notice: $e');
    }
  }

  /// Informational availability check across requested items and dates.
  /// Useful for live UI feedback, form validation, and conflict warnings.
  AvailabilityCheckResult checkAvailability({
    required DateTime startDate,
    required DateTime endDate,
    required List<Map<String, dynamic>> requestedItems,
    String? excludeBookingId,
  }) {
    final rentalDays = generateRentalDays(startDate, endDate);
    final normStart = normalizeDate(startDate);
    final normEnd = normalizeDate(endDate);

    final activeBookings = _bookingRepo.bookings.where((b) {
      if (b.status.toUpperCase() == 'CANCELLED') return false;
      if (excludeBookingId != null && b.id == excludeBookingId) return false;
      return b.overlapsWith(normStart, normEnd);
    }).toList();

    final List<AvailabilityConflict> conflicts = [];
    final Map<String, int> minAvailableMap = {};

    for (final item in requestedItems) {
      final sku = (item['sku'] ?? item['id'] ?? '').toString().trim().toUpperCase();
      final name = (item['name'] ?? item['equipmentName'] ?? sku).toString();
      final requestedQty = (item['quantity'] ?? item['selectedQty'] ?? item['qty'] ?? 0) as int;

      if (requestedQty <= 0) continue;

      // Authoritative lookup: physical capacity must exist in inventory repository
      final invItem = _inventoryRepo.findBySku(sku);
      if (invItem == null) {
        // Missing equipment record must be rejected
        final conflict = AvailabilityConflict(
          equipmentName: name,
          sku: sku,
          requestedQty: requestedQty,
          availableQty: 0,
          shortage: requestedQty,
          conflictingEvent: 'Unregistered Equipment Record (Missing in Inventory)',
          conflictingDate: startDate,
        );
        conflicts.add(conflict);
        minAvailableMap[sku] = 0;
        continue;
      }

      final int totalStock = (invItem['total'] as num?)?.toInt() ?? 0;
      final int maintStock = (invItem['status'] == 'MAINTENANCE')
          ? math.max(1, totalStock - ((invItem['available'] as num?)?.toInt() ?? totalStock))
          : ((invItem['maintenance'] as num?)?.toInt() ?? 0);
      final int rentableCapacity = math.max(0, totalStock - maintStock);

      int minAvailable = rentableCapacity;
      AvailabilityConflict? worstConflict;

      for (final day in rentalDays) {
        final dayBookings = activeBookings.where((b) {
          final bStart = b.normalizedStartDate;
          final bEnd = b.normalizedEndDate;
          return !bStart.isAfter(day) && !bEnd.isBefore(day);
        }).toList();

        int bookedOnDay = 0;
        String? collidingEventTitle;

        for (final b in dayBookings) {
          final q = b.quantityForSku(sku);
          if (q > 0) {
            bookedOnDay += q;
            collidingEventTitle ??= '${b.eventTitle} (${b.id})';
          }
        }

        final int availableOnDay = math.max(0, rentableCapacity - bookedOnDay);
        if (availableOnDay < minAvailable) {
          minAvailable = availableOnDay;
        }

        if (requestedQty > availableOnDay) {
          final shortage = requestedQty - availableOnDay;
          if (worstConflict == null || shortage > worstConflict.shortage) {
            worstConflict = AvailabilityConflict(
              equipmentName: name,
              sku: sku,
              requestedQty: requestedQty,
              availableQty: availableOnDay,
              shortage: shortage,
              conflictingEvent: collidingEventTitle ?? 'Overlapping Regional Operations',
              conflictingDate: day,
            );
          }
        }
      }

      minAvailableMap[sku] = minAvailable;
      if (worstConflict != null) {
        conflicts.add(worstConflict);
      }
    }

    return AvailabilityCheckResult(
      isAvailable: conflicts.isEmpty,
      conflicts: conflicts,
      minAvailablePerSku: minAvailableMap,
    );
  }

  /// Authoritatively commits a rental reservation using distributed concurrency controls.
  ///
  /// In Production: Reads physical stock and daily allocation documents inside a Cloud Firestore
  /// transaction before writing. If stock is insufficient on any day or SKU, aborts atomically.
  /// In Mock/Test: Runs serialized inside an async mutual exclusion lock and updates allocation ledgers.
  Future<BookingItem> reserveAndCreateBooking({
    required BookingItem newBooking,
    String? idempotencyKey,
  }) async {
    final sDate = newBooking.startDate ?? newBooking.normalizedStartDate;
    final eDate = newBooking.endDate ?? newBooking.normalizedEndDate;
    final rentalDays = generateRentalDays(sDate, eDate);

    if (newBooking.items.isEmpty) {
      throw Exception('Cannot reserve a booking with 0 equipment items.');
    }

    // 1. Initial Informational Pre-Check
    final preCheck = checkAvailability(
      startDate: sDate,
      endDate: eDate,
      requestedItems: newBooking.items,
    );
    if (!preCheck.isAvailable) {
      throw AvailabilityConflictException(preCheck);
    }

    // 2. Production Distributed Reservation Engine (Firestore Transactions)
    if (AuthService().isFirebaseInitialized && !useMockPersistence) {
      await ensureAllocationsReconciled();

      final firestore = FirebaseFirestore.instance;
      final bookingRef = firestore.collection('bookings').doc(newBooking.id);

      await firestore.runTransaction((transaction) async {
        // Step A: All Reads First
        final bookingSnap = await transaction.get(bookingRef);
        if (bookingSnap.exists) {
          final existingData = bookingSnap.data() ?? {};
          if (existingData['status'] == 'CONFIRMED' || existingData['status'] == 'READY') {
            // Idempotent duplicate submission protection
            return;
          }
          throw DuplicateBookingException('Booking ID #${newBooking.id} already exists.');
        }

        // Read physical equipment stock for all requested items
        final Map<String, DocumentSnapshot> eqSnaps = {};
        for (final item in newBooking.items) {
          final sku = (item['sku'] ?? item['id'] ?? '').toString().trim().toUpperCase();
          if (sku.isEmpty) continue;
          final eqRef = firestore.collection('equipment').doc(sku);
          eqSnaps[sku] = await transaction.get(eqRef);
        }

        // Read allocation documents for all requested items across all rental days
        final Map<String, DocumentSnapshot> allocSnaps = {};
        for (final item in newBooking.items) {
          final sku = (item['sku'] ?? item['id'] ?? '').toString().trim().toUpperCase();
          if (sku.isEmpty) continue;

          for (final day in rentalDays) {
            final key = '${sku}_${formatDateKey(day)}';
            final allocRef = firestore.collection('allocations').doc(key);
            allocSnaps[key] = await transaction.get(allocRef);
          }
        }

        // Step B: Authoritative Validation Phase
        final List<AvailabilityConflict> conflicts = [];
        final Map<String, int> minAvailMap = {};

        for (final item in newBooking.items) {
          final sku = (item['sku'] ?? item['id'] ?? '').toString().trim().toUpperCase();
          final name = (item['name'] ?? item['equipmentName'] ?? sku).toString();
          final requestedQty = (item['quantity'] ?? item['selectedQty'] ?? item['qty'] ?? 0) as int;
          if (sku.isEmpty || requestedQty <= 0) continue;

          final eqSnap = eqSnaps[sku];
          if (eqSnap == null || !eqSnap.exists) {
            throw AvailabilityConflictException(
              AvailabilityCheckResult(
                isAvailable: false,
                conflicts: [
                  AvailabilityConflict(
                    equipmentName: name,
                    sku: sku,
                    requestedQty: requestedQty,
                    availableQty: 0,
                    shortage: requestedQty,
                    conflictingEvent: 'Unregistered Equipment Record in Firestore',
                    conflictingDate: sDate,
                  )
                ],
              ),
              'Equipment record for SKU $sku does not exist in inventory registry.',
            );
          }

          final eqData = eqSnap.data() as Map<String, dynamic>? ?? {};
          final totalStock = (eqData['totalQuantity'] ?? eqData['total'] ?? 0) as int;
          final maintStock = (eqData['status'] == 'MAINTENANCE')
              ? math.max(1, totalStock - ((eqData['rentableQuantity'] ?? eqData['available'] ?? totalStock) as int))
              : ((eqData['maintenanceQuantity'] ?? eqData['maintenance'] ?? 0) as int);
          final rentableCapacity = math.max(0, totalStock - maintStock);

          int minAvail = rentableCapacity;
          AvailabilityConflict? worstConflict;

          for (final day in rentalDays) {
            final key = '${sku}_${formatDateKey(day)}';
            final allocSnap = allocSnaps[key];
            final allocData = allocSnap != null && allocSnap.exists
                ? (allocSnap.data() as Map<String, dynamic>? ?? {})
                : <String, dynamic>{};

            final currentAlloc = (allocData['allocatedQuantity'] ?? 0) as int;
            final availableOnDay = math.max(0, rentableCapacity - currentAlloc);

            if (availableOnDay < minAvail) {
              minAvail = availableOnDay;
            }

            if (requestedQty > availableOnDay) {
              final shortage = requestedQty - availableOnDay;
              final bookingsMap = allocData['bookings'] as Map<String, dynamic>? ?? {};
              final collidingEvent = bookingsMap.isNotEmpty
                  ? 'Active Booking #${bookingsMap.keys.first}'
                  : 'Concurrent Event Allocation';

              if (worstConflict == null || shortage > worstConflict.shortage) {
                worstConflict = AvailabilityConflict(
                  equipmentName: name,
                  sku: sku,
                  requestedQty: requestedQty,
                  availableQty: availableOnDay,
                  shortage: shortage,
                  conflictingEvent: collidingEvent,
                  conflictingDate: day,
                );
              }
            }
          }

          minAvailMap[sku] = minAvail;
          if (worstConflict != null) {
            conflicts.add(worstConflict);
          }
        }

        // If any item or day fails, abort transaction (All-or-Nothing guarantee)
        if (conflicts.isNotEmpty) {
          throw AvailabilityConflictException(
            AvailabilityCheckResult(
              isAvailable: false,
              conflicts: conflicts,
              minAvailablePerSku: minAvailMap,
            ),
          );
        }

        // Step C: All Writes Phase
        for (final item in newBooking.items) {
          final sku = (item['sku'] ?? item['id'] ?? '').toString().trim().toUpperCase();
          final requestedQty = (item['quantity'] ?? item['selectedQty'] ?? item['qty'] ?? 0) as int;
          if (sku.isEmpty || requestedQty <= 0) continue;

          for (final day in rentalDays) {
            final dateStr = formatDateKey(day);
            final key = '${sku}_$dateStr';
            final allocRef = firestore.collection('allocations').doc(key);
            final allocSnap = allocSnaps[key];
            final allocData = allocSnap != null && allocSnap.exists
                ? Map<String, dynamic>.from(allocSnap.data() as Map<String, dynamic>? ?? {})
                : <String, dynamic>{};

            final currentAlloc = (allocData['allocatedQuantity'] ?? 0) as int;
            final bookingsMap = allocData['bookings'] != null
                ? Map<String, dynamic>.from(allocData['bookings'] as Map)
                : <String, dynamic>{};

            bookingsMap[newBooking.id] = requestedQty;

            transaction.set(allocRef, {
              'sku': sku,
              'date': dateStr,
              'allocatedQuantity': currentAlloc + requestedQty,
              'bookings': bookingsMap,
              'updatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
          }
        }

        // Create the booking document in Firestore
        transaction.set(bookingRef, newBooking.toMap());
      });

      // Update local state without duplicate Firestore write
      await _bookingRepo.addBooking(newBooking, persistToRemote: false);
      return newBooking;
    }

    // 3. In-Memory Atomic Reservation (Synchronized for local testing & mock persistence)
    return await _synchronized(() async {
      // Re-validate against current repository state
      final authoritativeCheck = checkAvailability(
        startDate: sDate,
        endDate: eDate,
        requestedItems: newBooking.items,
      );

      if (!authoritativeCheck.isAvailable) {
        throw AvailabilityConflictException(authoritativeCheck);
      }

      // Commit to in-memory allocation ledger
      for (final item in newBooking.items) {
        final sku = (item['sku'] ?? item['id'] ?? '').toString().trim().toUpperCase();
        final requestedQty = (item['quantity'] ?? item['selectedQty'] ?? item['qty'] ?? 0) as int;
        if (sku.isEmpty || requestedQty <= 0) continue;

        for (final day in rentalDays) {
          final key = '${sku}_${formatDateKey(day)}';
          final existing = _mockAllocations[key] ?? {'allocatedQuantity': 0, 'bookings': <String, int>{}};
          final currentAlloc = (existing['allocatedQuantity'] as int?) ?? 0;
          final bookingsMap = Map<String, int>.from(existing['bookings'] as Map? ?? {});

          bookingsMap[newBooking.id] = requestedQty;
          _mockAllocations[key] = {
            'allocatedQuantity': currentAlloc + requestedQty,
            'bookings': bookingsMap,
          };
        }
      }

      await _bookingRepo.addBooking(newBooking, persistToRemote: false);
      return newBooking;
    });
  }

  /// Cancels a booking, releasing reserved capacity at most once.
  /// Rejects cancellation of bookings that are already dispatched or completed.
  Future<bool> cancelBooking(String bookingId) async {
    final booking = _bookingRepo.bookings.firstWhere(
      (b) => b.id == bookingId,
      orElse: () => throw Exception('Booking #$bookingId not found.'),
    );

    final status = booking.status.toUpperCase();
    if (status == 'CANCELLED') {
      return false; // Idempotent no-op
    }
    if (status == 'DISPATCHED' || status == 'ON STAGE' || status == 'COMPLETED') {
      throw Exception('Cannot cancel booking #$bookingId because it is already $status.');
    }

    final sDate = booking.startDate ?? booking.normalizedStartDate;
    final eDate = booking.endDate ?? booking.normalizedEndDate;
    final rentalDays = generateRentalDays(sDate, eDate);

    if (AuthService().isFirebaseInitialized && !useMockPersistence) {
      final firestore = FirebaseFirestore.instance;
      final bookingRef = firestore.collection('bookings').doc(bookingId);

      await firestore.runTransaction((transaction) async {
        final bookingSnap = await transaction.get(bookingRef);
        if (!bookingSnap.exists) {
          throw Exception('Booking #$bookingId not found in Firestore.');
        }

        final bData = bookingSnap.data() ?? {};
        final curStatus = (bData['status'] ?? '').toString().toUpperCase();
        if (curStatus == 'CANCELLED') return;
        if (curStatus == 'DISPATCHED' || curStatus == 'COMPLETED') {
          throw Exception('Cannot cancel booking #$bookingId in status $curStatus.');
        }

        // Release allocation records
        for (final item in booking.items) {
          final sku = (item['sku'] ?? item['id'] ?? '').toString().trim().toUpperCase();
          final bookedQty = (item['quantity'] ?? item['selectedQty'] ?? item['qty'] ?? 0) as int;
          if (sku.isEmpty || bookedQty <= 0) continue;

          for (final day in rentalDays) {
            final key = '${sku}_${formatDateKey(day)}';
            final allocRef = firestore.collection('allocations').doc(key);
            final allocSnap = await transaction.get(allocRef);

            if (allocSnap.exists) {
              final allocData = allocSnap.data() ?? {};
              final currentAlloc = (allocData['allocatedQuantity'] ?? 0) as int;
              final bookingsMap = allocData['bookings'] != null
                  ? Map<String, dynamic>.from(allocData['bookings'] as Map)
                  : <String, dynamic>{};

              bookingsMap.remove(bookingId);
              final newAlloc = math.max(0, currentAlloc - bookedQty);

              transaction.set(allocRef, {
                'allocatedQuantity': newAlloc,
                'bookings': bookingsMap,
                'updatedAt': FieldValue.serverTimestamp(),
              }, SetOptions(merge: true));
            }
          }
        }

        transaction.update(bookingRef, {
          'status': 'CANCELLED',
          'cancelledAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    } else {
      // In-Memory release
      await _synchronized(() async {
        for (final item in booking.items) {
          final sku = (item['sku'] ?? item['id'] ?? '').toString().trim().toUpperCase();
          final bookedQty = (item['quantity'] ?? item['selectedQty'] ?? item['qty'] ?? 0) as int;
          if (sku.isEmpty || bookedQty <= 0) continue;

          for (final day in rentalDays) {
            final key = '${sku}_${formatDateKey(day)}';
            final existing = _mockAllocations[key];
            if (existing != null) {
              final currentAlloc = (existing['allocatedQuantity'] as int?) ?? 0;
              final bookingsMap = Map<String, int>.from(existing['bookings'] as Map? ?? {});
              bookingsMap.remove(bookingId);
              _mockAllocations[key] = {
                'allocatedQuantity': math.max(0, currentAlloc - bookedQty),
                'bookings': bookingsMap,
              };
            }
          }
        }
      });
    }

    await _bookingRepo.cancelBooking(bookingId);
    return true;
  }

  /// Reschedules a booking atomically to a new date window.
  /// Validates availability on the new range, releases previous allocations, and updates the booking.
  /// If the new window has conflicts, the original booking and allocations remain untouched.
  Future<bool> rescheduleBooking({
    required String bookingId,
    required DateTime newStartDate,
    required DateTime newEndDate,
  }) async {
    final booking = _bookingRepo.bookings.firstWhere(
      (b) => b.id == bookingId,
      orElse: () => throw Exception('Booking #$bookingId not found.'),
    );

    final status = booking.status.toUpperCase();
    if (status == 'CANCELLED' || status == 'DISPATCHED' || status == 'COMPLETED') {
      throw Exception('Cannot reschedule booking #$bookingId in status $status.');
    }

    // Pre-check excluding current booking allocations
    final check = checkAvailability(
      startDate: newStartDate,
      endDate: newEndDate,
      requestedItems: booking.items,
      excludeBookingId: bookingId,
    );
    if (!check.isAvailable) {
      throw AvailabilityConflictException(check);
    }

    final sDateStr = '${newStartDate.day}/${newStartDate.month}/${newStartDate.year}';
    final eDateStr = '${newEndDate.day}/${newEndDate.month}/${newEndDate.year}';
    final updated = booking.copyWith(
      startDate: newStartDate,
      endDate: newEndDate,
      date: '$sDateStr — $eDateStr',
      updatedAt: DateTime.now(),
    );

    if (AuthService().isFirebaseInitialized && !useMockPersistence) {
      final firestore = FirebaseFirestore.instance;
      final bookingRef = firestore.collection('bookings').doc(bookingId);
      final oldDays = generateRentalDays(booking.normalizedStartDate, booking.normalizedEndDate);
      final newDays = generateRentalDays(newStartDate, newEndDate);

      await firestore.runTransaction((transaction) async {
        final bookingSnap = await transaction.get(bookingRef);
        if (!bookingSnap.exists) {
          throw Exception('Booking #$bookingId not found in Firestore.');
        }

        // Validate availability of new days inside transaction
        for (final item in booking.items) {
          final sku = (item['sku'] ?? item['id'] ?? '').toString().trim().toUpperCase();
          final requestedQty = (item['quantity'] ?? item['selectedQty'] ?? item['qty'] ?? 0) as int;
          if (sku.isEmpty || requestedQty <= 0) continue;

          final eqRef = firestore.collection('equipment').doc(sku);
          final eqSnap = await transaction.get(eqRef);
          if (!eqSnap.exists) {
            throw Exception('Equipment $sku does not exist in registry.');
          }

          final eqData = eqSnap.data() ?? {};
          final totalStock = (eqData['totalQuantity'] ?? eqData['total'] ?? 0) as int;
          final maintStock = (eqData['maintenanceQuantity'] ?? eqData['maintenance'] ?? 0) as int;
          final rentableCapacity = math.max(0, totalStock - maintStock);

          for (final day in newDays) {
            final key = '${sku}_${formatDateKey(day)}';
            final allocRef = firestore.collection('allocations').doc(key);
            final allocSnap = await transaction.get(allocRef);

            int currentAlloc = 0;
            if (allocSnap.exists) {
              final allocData = allocSnap.data() ?? {};
              currentAlloc = (allocData['allocatedQuantity'] ?? 0) as int;
              final bookingsMap = allocData['bookings'] as Map<String, dynamic>? ?? {};
              // If this booking is already counted on this day, discount it from collision
              if (bookingsMap.containsKey(bookingId)) {
                currentAlloc = math.max(0, currentAlloc - (bookingsMap[bookingId] as int? ?? 0));
              }
            }

            final available = rentableCapacity - currentAlloc;
            if (requestedQty > available) {
              throw AvailabilityConflictException(
                AvailabilityCheckResult(
                  isAvailable: false,
                  conflicts: [
                    AvailabilityConflict(
                      equipmentName: (item['name'] ?? sku).toString(),
                      sku: sku,
                      requestedQty: requestedQty,
                      availableQty: available,
                      shortage: requestedQty - available,
                      conflictingEvent: 'Concurrent Reservation Overlap',
                      conflictingDate: day,
                    )
                  ],
                ),
              );
            }
          }
        }

        // Release old days
        for (final item in booking.items) {
          final sku = (item['sku'] ?? item['id'] ?? '').toString().trim().toUpperCase();
          final bookedQty = (item['quantity'] ?? item['selectedQty'] ?? item['qty'] ?? 0) as int;
          if (sku.isEmpty || bookedQty <= 0) continue;

          for (final day in oldDays) {
            final key = '${sku}_${formatDateKey(day)}';
            final allocRef = firestore.collection('allocations').doc(key);
            final allocSnap = await transaction.get(allocRef);
            if (allocSnap.exists) {
              final allocData = allocSnap.data() ?? {};
              final currentAlloc = (allocData['allocatedQuantity'] ?? 0) as int;
              final bookingsMap = allocData['bookings'] != null
                  ? Map<String, dynamic>.from(allocData['bookings'] as Map)
                  : <String, dynamic>{};
              bookingsMap.remove(bookingId);
              transaction.set(allocRef, {
                'allocatedQuantity': math.max(0, currentAlloc - bookedQty),
                'bookings': bookingsMap,
                'updatedAt': FieldValue.serverTimestamp(),
              }, SetOptions(merge: true));
            }
          }
        }

        // Apply new days
        for (final item in booking.items) {
          final sku = (item['sku'] ?? item['id'] ?? '').toString().trim().toUpperCase();
          final bookedQty = (item['quantity'] ?? item['selectedQty'] ?? item['qty'] ?? 0) as int;
          if (sku.isEmpty || bookedQty <= 0) continue;

          for (final day in newDays) {
            final key = '${sku}_${formatDateKey(day)}';
            final allocRef = firestore.collection('allocations').doc(key);
            final allocSnap = await transaction.get(allocRef);
            int currentAlloc = 0;
            final bookingsMap = <String, dynamic>{};
            if (allocSnap.exists) {
              final allocData = allocSnap.data() ?? {};
              currentAlloc = (allocData['allocatedQuantity'] ?? 0) as int;
              if (allocData['bookings'] != null) {
                bookingsMap.addAll(Map<String, dynamic>.from(allocData['bookings'] as Map));
              }
            }
            bookingsMap[bookingId] = bookedQty;
            transaction.set(allocRef, {
              'sku': sku,
              'date': formatDateKey(day),
              'allocatedQuantity': currentAlloc + bookedQty,
              'bookings': bookingsMap,
              'updatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
          }
        }

        // Commit updated booking
        transaction.set(bookingRef, updated.toMap(), SetOptions(merge: true));
      });
    }

    await _bookingRepo.updateBooking(updated);
    return true;
  }
}
