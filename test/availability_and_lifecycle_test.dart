import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rentflow/core/models/booking_item.dart';
import 'package:rentflow/core/services/availability_service.dart';
import 'package:rentflow/core/services/booking_repository.dart';
import 'package:rentflow/core/services/inventory_repository.dart';
import 'package:rentflow/core/theme/app_theme.dart';
import 'package:rentflow/screens/bookings/booking_details_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    BookingRepository();
    InventoryRepository();
  });

  group('AvailabilityService & Reservation Engine Tests', () {
    test('Non-overlapping date rentals for same equipment succeed without conflict', () {
      final service = AvailabilityService();

      // Period A: Nov 10 to Nov 12
      final startA = DateTime(2026, 11, 10);
      final endA = DateTime(2026, 11, 12);

      // Period B: Nov 15 to Nov 18 (completely non-overlapping)
      final startB = DateTime(2026, 11, 15);
      final endB = DateTime(2026, 11, 18);

      final requested = [
        {'sku': 'SND-JBL-VRX932', 'name': 'JBL Speaker', 'quantity': 8}
      ];

      // Check A
      final resultA = service.checkAvailability(
        startDate: startA,
        endDate: endA,
        requestedItems: requested,
      );
      expect(resultA.isAvailable, isTrue);

      // Check B
      final resultB = service.checkAvailability(
        startDate: startB,
        endDate: endB,
        requestedItems: requested,
      );
      expect(resultB.isAvailable, isTrue);
    });

    test('Overlapping rentals for same equipment are correctly rejected when stock is exceeded', () {
      final service = AvailabilityService();
      final today = DateTime.now();
      final tomorrow = today.add(const Duration(days: 1));

      // BK-8942 is active today and has allocated 4x JBL VRX932 speakers (total stock = 16, available = 8)
      // Attempting to book 15x JBL VRX932 today must trigger a shortage conflict
      final result = service.checkAvailability(
        startDate: today,
        endDate: tomorrow,
        requestedItems: [
          {'sku': 'SND-JBL-VRX932', 'name': 'JBL Speaker', 'quantity': 15}
        ],
      );

      expect(result.isAvailable, isFalse);
      expect(result.conflicts, isNotEmpty);
      expect(result.conflicts.first.sku, 'SND-JBL-VRX932');
      expect(result.conflicts.first.shortage, greaterThan(0));
    });

    test('Multi-day rental reserves all calendar days in interval', () {
      final start = DateTime(2026, 12, 1);
      final end = DateTime(2026, 12, 4); // 4 days (1, 2, 3, 4)

      final days = AvailabilityService.generateRentalDays(start, end);
      expect(days.length, 4);
      expect(days.first.day, 1);
      expect(days.last.day, 4);
    });

    test('Cancelled bookings immediately release equipment capacity', () async {
      final service = AvailabilityService();
      final testDate = DateTime(2026, 11, 20);

      // Create a test booking consuming 10x Shure mics (total stock is 10)
      final bookingId = 'BK-TEST-CANCEL-${DateTime.now().millisecondsSinceEpoch}';
      final testBooking = BookingItem(
        id: bookingId,
        eventTitle: 'Temporary Gala',
        clientName: 'Test Client',
        category: 'Corporate',
        date: '20 Nov 2026',
        venue: 'Test Hall',
        status: 'CONFIRMED',
        unitsCount: 10,
        totalAmount: 9500.0,
        startDate: testDate,
        endDate: testDate.add(const Duration(days: 1)),
        items: [
          {'sku': 'SND-SHURE-ULXD', 'name': 'Shure Mic', 'quantity': 10}
        ],
      );

      await service.reserveAndCreateBooking(newBooking: testBooking);

      // Now stock is fully committed for 20 Nov. Attempting to book even 1 mic must fail
      final checkFull = service.checkAvailability(
        startDate: testDate,
        endDate: testDate.add(const Duration(days: 1)),
        requestedItems: [
          {'sku': 'SND-SHURE-ULXD', 'name': 'Shure Mic', 'quantity': 2}
        ],
      );
      expect(checkFull.isAvailable, isFalse);

      // Cancel the booking
      final cancelled = await service.cancelBooking(bookingId);
      expect(cancelled, isTrue);

      // Availability check must now succeed immediately!
      final checkFreed = service.checkAvailability(
        startDate: testDate,
        endDate: testDate.add(const Duration(days: 1)),
        requestedItems: [
          {'sku': 'SND-SHURE-ULXD', 'name': 'Shure Mic', 'quantity': 2}
        ],
      );
      expect(checkFreed.isAvailable, isTrue);
    });

    test('Rescheduling checks availability for new window and preserves booking if conflict occurs', () async {
      final service = AvailabilityService();
      final date1 = DateTime(2026, 12, 10);
      final date2 = DateTime(2026, 12, 11);

      final bookingId = 'BK-TEST-RESCHEDULE-${DateTime.now().millisecondsSinceEpoch}';
      final testBooking = BookingItem(
        id: bookingId,
        eventTitle: 'Product Launch',
        clientName: 'Enterprise',
        category: 'Corporate',
        date: '10 Dec 2026',
        venue: 'Main Auditorium',
        status: 'CONFIRMED',
        unitsCount: 2,
        totalAmount: 9000.0,
        startDate: date1,
        endDate: date1.add(const Duration(days: 1)),
        items: [
          {'sku': 'PWR-GEN-62KVA', 'name': 'Generator Unit', 'quantity': 2}
        ],
      );

      await service.reserveAndCreateBooking(newBooking: testBooking);

      // Reschedule to date2 where stock is free
      final rescheduled = await service.rescheduleBooking(
        bookingId: bookingId,
        newStartDate: date2,
        newEndDate: date2.add(const Duration(days: 1)),
      );
      expect(rescheduled, isTrue);

      final updated = BookingRepository().getBookingById(bookingId);
      expect(updated?.startDate?.day, date2.day);
    });
  });

  group('BookingDetailsScreen Cancellation & Dynamic Timeline Tests', () {
    testWidgets('Cancellation dialog confirms and marks booking CANCELLED', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // Create a test booking to cancel
      const testId = 'BK-CANCEL-UI-TEST';
      final testBooking = BookingItem(
        id: testId,
        eventTitle: 'Test Concert',
        clientName: 'Music Group',
        category: 'Concert',
        date: 'Today',
        venue: 'Open Air Theatre',
        status: 'CONFIRMED',
        unitsCount: 12,
        totalAmount: 18000.0,
      );
      BookingRepository().addBooking(testBooking);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const BookingDetailsScreen(
            bookingId: testId,
            eventTitle: 'Test Concert',
            clientName: 'Music Group',
            venue: 'Open Air Theatre',
            status: 'CONFIRMED',
            totalItems: 12,
            grandTotal: 18000.0,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Cancel button is rendered
      final cancelBtn = find.text('Cancel Reservation & Release Capacity');
      expect(cancelBtn, findsOneWidget);

      await tester.ensureVisible(cancelBtn);
      await tester.tap(cancelBtn);
      await tester.pumpAndSettle();

      // Verify Confirmation Dialog appears
      expect(find.text('Cancel Reservation?'), findsOneWidget);
      expect(find.text('Confirm Cancellation'), findsOneWidget);

      // Tap Confirm Cancellation
      await tester.tap(find.text('Confirm Cancellation'));
      await tester.pumpAndSettle();

      // Status should update to CANCELLED and render banner
      expect(find.text('RESERVATION CANCELLED'), findsOneWidget);
    });
  });
}
