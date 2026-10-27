import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rentflow/core/models/booking_item.dart';
import 'package:rentflow/core/services/availability_service.dart';
import 'package:rentflow/core/services/booking_repository.dart';
import 'package:rentflow/core/services/inventory_repository.dart';
import 'package:rentflow/core/theme/app_theme.dart';
import 'package:rentflow/screens/bookings/booking_details_screen.dart';
import 'package:rentflow/screens/dispatch/dispatch_screen.dart';
import 'package:rentflow/screens/dispatch/return_intake_sheet.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    BookingRepository();
    InventoryRepository();
  });

  Widget buildApp(Widget child) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: child,
    );
  }

  group('Day 6 Integration Test Suite: Full Operational Flow', () {
    test('1. Multi-Day Pricing & Capacity Reservation Integrity', () async {
      final availabilityService = AvailabilityService();
      final startDate = DateTime(2026, 11, 15);
      final endDate = DateTime(2026, 11, 18); // 4 days inclusive (15, 16, 17, 18)

      final days = AvailabilityService.generateRentalDays(startDate, endDate);
      expect(days.length, 4);

      const unitRate = 1500.0;
      const qty = 4;
      final expectedTotal = days.length * unitRate * qty;
      expect(expectedTotal, 24000.0);

      // Verify availability before reservation
      final check = availabilityService.checkAvailability(
        startDate: startDate,
        endDate: endDate,
        requestedItems: [
          {'sku': 'SND-JBL-VRX932', 'name': 'JBL Speaker', 'quantity': qty}
        ],
      );
      expect(check.isAvailable, isTrue);

      // Create and persist reservation
      final bookingId = 'BK-E2E-${DateTime.now().millisecondsSinceEpoch}';
      final booking = BookingItem(
        id: bookingId,
        eventTitle: 'Kalvium Annual Summit',
        clientName: 'Kalvium Tech',
        category: 'Corporate',
        date: '15 Nov — 18 Nov 2026',
        venue: 'Convention Center Hall A',
        status: 'CONFIRMED',
        unitsCount: qty,
        totalAmount: expectedTotal,
        startDate: startDate,
        endDate: endDate,
        items: [
          {'sku': 'SND-JBL-VRX932', 'name': 'JBL Speaker', 'quantity': qty, 'dailyRate': unitRate}
        ],
      );

      final createdBooking = await availabilityService.reserveAndCreateBooking(newBooking: booking);
      expect(createdBooking, isNotNull);

      final retrieved = BookingRepository().getBookingById(bookingId);
      expect(retrieved, isNotNull);
      expect(retrieved!.status, 'CONFIRMED');
      expect(retrieved.totalAmount, 24000.0);
    });

    testWidgets('2. Dispatch Queue Categorization & Staging Transition', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      const bookingId = 'BK-DISPATCH-E2E';
      final testBooking = BookingItem(
        id: bookingId,
        eventTitle: 'Festival of Lights Showcase',
        clientName: 'City Council',
        category: 'Concert',
        date: 'Tonight',
        venue: 'Riverfront Arena',
        status: 'CONFIRMED',
        unitsCount: 2,
        totalAmount: 18000.0,
      );
      BookingRepository().addBooking(testBooking);

      await tester.pumpWidget(buildApp(const DispatchScreen()));
      await tester.pumpAndSettle();

      // Ensure booking appears in Pending Loading
      expect(find.text('Pending Loading'), findsOneWidget);
      expect(find.text('Festival of Lights Showcase'), findsOneWidget);
    });

    testWidgets('3. Warehouse Flight Case Loading Checklist & Vehicle Departure', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      const bookingId = 'BK-DEPARTURE-E2E';
      final testBooking = BookingItem(
        id: bookingId,
        eventTitle: 'Rajasthan Heritage Gala',
        clientName: 'Royal Events',
        category: 'Wedding',
        date: 'Today',
        venue: 'Palace Grounds',
        status: 'CONFIRMED',
        unitsCount: 2,
        totalAmount: 16000.0,
      );
      BookingRepository().addBooking(testBooking);

      await tester.pumpWidget(
        buildApp(
          BookingDetailsScreen(
            bookingId: bookingId,
            eventTitle: 'Rajasthan Heritage Gala',
            clientName: 'Royal Events',
            venue: 'Palace Grounds',
            status: 'CONFIRMED',
            manifestItems: const [
              {'name': 'Case A', 'sku': 'AU-DB-V8', 'flightCase': 'FC-A1', 'qty': 2, 'rate': 1200.0},
              {'name': 'Case B', 'sku': 'VIS-LED-P391', 'flightCase': 'FC-V1', 'qty': 4, 'rate': 800.0},
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      final checkboxes = find.byType(Checkbox);
      expect(checkboxes, findsNWidgets(2));

      // 1st case loaded -> moves to PACKING
      await tester.ensureVisible(checkboxes.first);
      await tester.tap(checkboxes.first);
      await tester.pumpAndSettle();
      expect(BookingRepository().getBookingById(bookingId)?.status, 'PACKING');

      // 2nd case loaded -> moves to READY
      await tester.ensureVisible(checkboxes.last);
      await tester.tap(checkboxes.last);
      await tester.pumpAndSettle();
      expect(BookingRepository().getBookingById(bookingId)?.status, 'READY');

      // Tap Confirm and Mark Ready button or Dispatch Vehicle
      final readyButton = find.text('Confirm All Loaded & Mark Ready for Dispatch');
      if (readyButton.evaluate().isNotEmpty) {
        await tester.ensureVisible(readyButton);
        await tester.tap(readyButton);
        await tester.pumpAndSettle();
      }

      // Tap Dispatch Vehicle (Departure)
      final dispatchBtn = find.text('Dispatch Vehicle (Departure)');
      expect(dispatchBtn, findsOneWidget);
      await tester.ensureVisible(dispatchBtn);
      await tester.tap(dispatchBtn);
      await tester.pumpAndSettle();

      expect(BookingRepository().getBookingById(bookingId)?.status, 'DISPATCHED');
    });

    testWidgets('4. Return Intake Reconciliation & Atomic Stock Restock', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final inventoryRepo = InventoryRepository();
      const sku = 'LT-PNT-700';
      final initialItem = inventoryRepo.findBySku(sku)!;
      final initialAvailable = (initialItem['available'] as num).toInt();

      const bookingId = 'BK-RETURNS-RECON-E2E';
      final testBooking = BookingItem(
        id: bookingId,
        eventTitle: 'Concert Return',
        clientName: 'Live Nation',
        category: 'Concert',
        date: 'Yesterday',
        venue: 'Stadium',
        status: 'DISPATCHED',
        unitsCount: 4,
        totalAmount: 18000.0,
      );
      BookingRepository().addBooking(testBooking);

      await tester.pumpWidget(
        buildApp(
          Scaffold(
            body: ReturnIntakeSheet(
              bookingId: bookingId,
              eventTitle: 'Concert Return',
              clientName: 'Live Nation',
              manifestItems: const [
                {'name': 'Robe Robin Pointe Beam', 'sku': sku, 'qty': 4},
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Submit return with all 4 in good condition
      final submitButton = find.text('Submit Return & Reconcile Stock');
      expect(submitButton, findsOneWidget);
      await tester.ensureVisible(submitButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Verify booking is COMPLETED
      final completedBooking = BookingRepository().getBookingById(bookingId);
      expect(completedBooking?.status, 'COMPLETED');

      // Verify available stock increased
      final updatedItem = inventoryRepo.findBySku(sku)!;
      expect((updatedItem['available'] as num).toInt(), initialAvailable + 4);
    });
  });
}
