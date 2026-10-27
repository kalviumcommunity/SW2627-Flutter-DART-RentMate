import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/booking_item.dart';
import 'auth_service.dart';

/// Centralized booking repository for RentFlow / RentMate operations.
///
/// Features:
/// - Reactive state management via [bookingsNotifier] for immediate UI reactivity.
/// - Live two-way synchronization with Cloud Firestore collection `bookings`.
/// - Offline/in-memory fallback ensuring zero crashes in test suites and local setups.
/// - Robust cancellation, status transitions, and booking query methods.
class BookingRepository {
  static final BookingRepository _instance = BookingRepository._internal();
  factory BookingRepository() => _instance;

  /// Explicit flag to toggle demo fixtures for testing or local sandboxing.
  /// When false and Firebase is initialized, authoritative cloud data is required.
  static bool isDemoMode = false;

  bool isLoading = false;
  bool hasReceivedRemoteSnapshot = false;
  String? errorMessage;

  StreamSubscription<QuerySnapshot>? _firestoreSubscription;

  BookingRepository._internal() {
    final useInitial = !AuthService().isFirebaseInitialized || isDemoMode;
    bookingsNotifier = ValueNotifier<List<BookingItem>>(
      useInitial ? List.from(_initialBookings) : const [],
    );
    isLoading = AuthService().isFirebaseInitialized && !isDemoMode;
    _initFirestoreListener();
  }

  void resetToInitial() {
    bookingsNotifier.value = List.from(_initialBookings);
    isLoading = false;
    errorMessage = null;
  }

  void _initFirestoreListener() {
    if (AuthService().isFirebaseInitialized) {
      try {
        _firestoreSubscription = FirebaseFirestore.instance
            .collection('bookings')
            .orderBy('createdAt', descending: true)
            .snapshots()
            .listen(
          (snapshot) {
            // Authoritative: replace collection with actual remote docs even if empty
            final remoteBookings = snapshot.docs.map((doc) {
              try {
                return BookingItem.fromFirestore(doc);
              } catch (_) {
                final data = doc.data() as Map<String, dynamic>? ?? {};
                return BookingItem.fromMap(data, id: doc.id);
              }
            }).toList();

            bookingsNotifier.value = remoteBookings;
            hasReceivedRemoteSnapshot = true;
            isLoading = false;
            errorMessage = null;
          },
          onError: (e) {
            isLoading = false;
            errorMessage = e.toString();
            if (bookingsNotifier.value.isEmpty) {
              bookingsNotifier.value = List.from(_initialBookings);
            }
            debugPrint('Firestore bookings subscription notice: $e');
          },
        );
      } catch (e) {
        isLoading = false;
        errorMessage = e.toString();
        debugPrint('Could not initialize Firestore bookings listener: $e');
      }
    }
  }

  static final List<BookingItem> _initialBookings = [
    BookingItem(
      id: 'BK-8942',
      eventTitle: 'Sharma Royal Wedding & Sangeet',
      clientName: 'Rajesh Sharma',
      category: 'Wedding',
      date: 'Today, 14:00 — 23:30',
      venue: 'The Oberoi Rajvilas, Jaipur',
      status: 'READY',
      unitsCount: 24,
      totalAmount: 48500.0,
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 1)),
      items: [
        {'sku': 'SND-JBL-VRX932', 'name': 'JBL VRX932LA Line Array Speaker', 'quantity': 4, 'dailyRate': 1500.0},
        {'sku': 'LGT-SHARPY-230', 'name': 'Sharpy 230W 7R Beam Moving Head', 'quantity': 6, 'dailyRate': 850.0},
        {'sku': 'VIS-LED-P391', 'name': 'P3.91 High-Res LED Video Wall Panel', 'quantity': 8, 'dailyRate': 1200.0},
        {'sku': 'STG-TRS-3M', 'name': 'Heavy Duty Aluminum Box Truss', 'quantity': 4, 'dailyRate': 600.0},
        {'sku': 'SND-SHURE-ULXD', 'name': 'Shure ULXD4 Wireless Dual Mic Set', 'quantity': 2, 'dailyRate': 950.0},
      ],
    ),
    BookingItem(
      id: 'BK-8941',
      eventTitle: 'TechCorp Global Product Launch 2026',
      clientName: 'Priya Mehra',
      category: 'Corporate',
      date: 'Tomorrow, 08:30 — 18:00',
      venue: 'JECC Exhibition Hall B, Jaipur',
      status: 'PACKING',
      unitsCount: 42,
      totalAmount: 76000.0,
      startDate: DateTime.now().add(const Duration(days: 1)),
      endDate: DateTime.now().add(const Duration(days: 2)),
      items: [
        {'sku': 'AU-K2-LARR', 'name': 'L-Acoustics K2 Line Array Module', 'quantity': 4, 'dailyRate': 3000.0},
        {'sku': 'LT-PNT-700', 'name': 'Robe Robin Pointe Moving Beam', 'quantity': 8, 'dailyRate': 1800.0},
        {'sku': 'VD-PL25-LED', 'name': 'Absen PL2.5 Pro Outdoor LED Panel', 'quantity': 16, 'dailyRate': 1400.0},
        {'sku': 'PWR-GEN-62KVA', 'name': '62.5 kVA Silent Diesel Generator Unit', 'quantity': 1, 'dailyRate': 4500.0},
      ],
    ),
    BookingItem(
      id: 'BK-8939',
      eventTitle: 'Mehta Destination Sangeet Evening',
      clientName: 'Vikram Mehta',
      category: 'Wedding',
      date: '12 Oct, 18:00 — 02:00',
      venue: 'Fairmont Jaipur, Grand Ballroom',
      status: 'CONFIRMED',
      unitsCount: 18,
      totalAmount: 34000.0,
      startDate: DateTime.now().add(const Duration(days: 3)),
      endDate: DateTime.now().add(const Duration(days: 4)),
      items: [
        {'sku': 'SND-JBL-VRX932', 'name': 'JBL VRX932LA Line Array Speaker', 'quantity': 4, 'dailyRate': 1500.0},
        {'sku': 'AU-PWR-X8', 'name': 'Powersoft X8 Touring 8-Ch Amplifier', 'quantity': 2, 'dailyRate': 2500.0},
        {'sku': 'LGT-SHARPY-230', 'name': 'Sharpy 230W 7R Beam Moving Head', 'quantity': 4, 'dailyRate': 850.0},
      ],
    ),
    BookingItem(
      id: 'BK-8935',
      eventTitle: 'Indigo Autumn Fashion Gala',
      clientName: 'Sunita Singhania',
      category: 'Private',
      date: '15 Oct, 17:00 — 23:00',
      venue: 'Rambagh Palace Lawn',
      status: 'CONFIRMED',
      unitsCount: 30,
      totalAmount: 62000.0,
      startDate: DateTime.now().add(const Duration(days: 5)),
      endDate: DateTime.now().add(const Duration(days: 6)),
      items: [
        {'sku': 'LT-PNT-700', 'name': 'Robe Robin Pointe Moving Beam', 'quantity': 8, 'dailyRate': 1800.0},
        {'sku': 'VIS-LED-P391', 'name': 'P3.91 High-Res LED Video Wall Panel', 'quantity': 12, 'dailyRate': 1200.0},
      ],
    ),
    BookingItem(
      id: 'BK-8930',
      eventTitle: 'Saffron Heritage Sangeet & Reception',
      clientName: 'Rohan Mehra',
      category: 'Wedding',
      date: 'Today, 11:00 — 23:00',
      venue: 'Jai Mahal Palace Lawn, Jaipur',
      status: 'DISPATCHED',
      unitsCount: 28,
      totalAmount: 52000.0,
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 1)),
      items: [
        {'sku': 'SND-JBL-VRX932', 'name': 'JBL VRX932LA Line Array Speaker', 'quantity': 4, 'dailyRate': 1500.0},
        {'sku': 'LGT-SHARPY-230', 'name': 'Sharpy 230W 7R Beam Moving Head', 'quantity': 8, 'dailyRate': 850.0},
      ],
    ),
    BookingItem(
      id: 'BK-8928',
      eventTitle: 'Rajasthan Tech Expo & Keynote',
      clientName: 'Kavita Joshi',
      category: 'Corporate',
      date: 'Yesterday — Today, 18:00',
      venue: 'JECC Convention Center, Jaipur',
      status: 'AWAITING RETURN',
      unitsCount: 36,
      totalAmount: 68000.0,
      startDate: DateTime.now().subtract(const Duration(days: 1)),
      endDate: DateTime.now(),
      items: [
        {'sku': 'AU-K2-LARR', 'name': 'L-Acoustics K2 Line Array Module', 'quantity': 4, 'dailyRate': 3000.0},
      ],
    ),
    BookingItem(
      id: 'BK-8920',
      eventTitle: 'Innovate Summit Keynote & Stage',
      clientName: 'Anand Verma',
      category: 'Corporate',
      date: '08 Oct, 09:00 — 17:00',
      venue: 'ITC Rajputana Jaipur',
      status: 'COMPLETED',
      unitsCount: 16,
      totalAmount: 29500.0,
      startDate: DateTime.now().subtract(const Duration(days: 5)),
      endDate: DateTime.now().subtract(const Duration(days: 4)),
      items: [],
    ),
  ];

  late final ValueNotifier<List<BookingItem>> bookingsNotifier;

  List<BookingItem> get bookings => bookingsNotifier.value;

  /// Adds a new booking to session state and optionally persists to Firestore when connected.
  /// Set [persistToRemote] to false when called after an authoritative atomic transaction write.
  Future<void> addBooking(BookingItem item, {bool persistToRemote = true}) async {
    // Prevent duplicate entries in local notifier
    final existingIndex = bookingsNotifier.value.indexWhere((b) => b.id == item.id);
    if (existingIndex != -1) {
      final updated = List<BookingItem>.from(bookingsNotifier.value);
      updated[existingIndex] = item;
      bookingsNotifier.value = updated;
    } else {
      bookingsNotifier.value = [item, ...bookingsNotifier.value];
    }

    if (persistToRemote && AuthService().isFirebaseInitialized) {
      try {
        await FirebaseFirestore.instance
            .collection('bookings')
            .doc(item.id)
            .set(item.toMap(), SetOptions(merge: true));
      } catch (e) {
        debugPrint('Firestore addBooking error: $e');
        rethrow;
      }
    }
  }

  /// Updates booking status (e.g. READY, DISPATCHED, COMPLETED, CANCELLED).
  Future<void> updateBookingStatus(String id, String newStatus) async {
    final list = bookingsNotifier.value.map((b) {
      if (b.id == id) {
        return b.copyWith(status: newStatus, updatedAt: DateTime.now());
      }
      return b;
    }).toList();
    bookingsNotifier.value = list;

    if (AuthService().isFirebaseInitialized) {
      try {
        await FirebaseFirestore.instance
            .collection('bookings')
            .doc(id)
            .update({
          'status': newStatus.toUpperCase(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        debugPrint('Firestore updateBookingStatus notice: $e');
        rethrow;
      }
    }
  }

  /// Persists warehouse manifest flight case checklist progress across sessions.
  Future<void> updateBookingChecklist(String id, List<String> packedSkus) async {
    final list = bookingsNotifier.value.map((b) {
      if (b.id == id) {
        return b.copyWith(packedSkus: packedSkus, updatedAt: DateTime.now());
      }
      return b;
    }).toList();
    bookingsNotifier.value = list;

    if (AuthService().isFirebaseInitialized) {
      try {
        await FirebaseFirestore.instance
            .collection('bookings')
            .doc(id)
            .update({
          'packedSkus': packedSkus,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        debugPrint('Firestore updateBookingChecklist notice: $e');
      }
    }
  }

  /// Authoritatively commits a dispatch record and transitions booking to DISPATCHED.
  Future<void> persistDispatchRecord({
    required String bookingId,
    required String recordedBy,
    required List<Map<String, dynamic>> items,
  }) async {
    final currentBooking = getBookingById(bookingId);
    if (currentBooking == null) {
      throw Exception('Booking #$bookingId not found.');
    }
    if (currentBooking.status.toUpperCase() == 'CANCELLED') {
      throw Exception('Cannot dispatch cancelled booking #$bookingId.');
    }
    if (currentBooking.status.toUpperCase() == 'DISPATCHED') {
      return; // Idempotent no-op
    }

    if (AuthService().isFirebaseInitialized) {
      final firestore = FirebaseFirestore.instance;
      final batch = firestore.batch();

      final dispatchRef = firestore.collection('dispatches').doc(bookingId);
      final bookingRef = firestore.collection('bookings').doc(bookingId);

      batch.set(dispatchRef, {
        'bookingId': bookingId,
        'status': 'DISPATCHED',
        'items': items,
        'dispatchedAt': FieldValue.serverTimestamp(),
        'recordedBy': recordedBy,
      }, SetOptions(merge: true));

      batch.update(bookingRef, {
        'status': 'DISPATCHED',
        'dispatchedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
    }

    await updateBookingStatus(bookingId, 'DISPATCHED');
  }

  /// Replaces an existing booking with updated metadata and syncs to Firestore.
  Future<void> updateBooking(BookingItem item) async {
    final list = bookingsNotifier.value.map((b) {
      if (b.id == item.id) return item;
      return b;
    }).toList();
    bookingsNotifier.value = list;

    if (AuthService().isFirebaseInitialized) {
      try {
        await FirebaseFirestore.instance
            .collection('bookings')
            .doc(item.id)
            .set(item.toMap(), SetOptions(merge: true));
      } catch (e) {
        debugPrint('Firestore updateBooking notice: $e');
        rethrow;
      }
    }
  }

  /// Cancels a booking, setting status to CANCELLED and freeing reserved stock.
  Future<void> cancelBooking(String id) async {
    await updateBookingStatus(id, 'CANCELLED');
  }

  /// Retrieves a booking by its identifier.
  BookingItem? getBookingById(String id) {
    try {
      return bookings.firstWhere((b) => b.id.toUpperCase() == id.trim().toUpperCase());
    } catch (_) {
      return null;
    }
  }

  void dispose() {
    _firestoreSubscription?.cancel();
  }
}
