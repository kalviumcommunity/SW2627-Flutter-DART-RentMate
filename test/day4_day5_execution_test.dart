import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rentflow/core/models/booking_item.dart';
import 'package:rentflow/core/services/booking_repository.dart';
import 'package:rentflow/core/services/inventory_repository.dart';
import 'package:rentflow/core/theme/app_theme.dart';
import 'package:rentflow/screens/bookings/booking_details_screen.dart';
import 'package:rentflow/screens/dashboard/dashboard_screen.dart';
import 'package:rentflow/screens/dispatch/return_intake_sheet.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    BookingRepository();
    InventoryRepository();
  });

  Widget buildTestApp(Widget child) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: child,
    );
  }

  group('Day 4: Dispatch & Return Inventory Reconciler Tests', () {
    testWidgets('Dynamic 5-step status timeline renders all stages', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        buildTestApp(
          const BookingDetailsScreen(
            bookingId: 'BK-TIMELINE-TEST',
            eventTitle: 'Timeline Verification Event',
            status: 'CONFIRMED',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify the 5-step timeline labels are present
      expect(find.text('DISPATCH LIFECYCLE'), findsOneWidget);
      expect(find.text('Confirmed'), findsOneWidget);
      expect(find.text('Packing'), findsOneWidget);
      expect(find.text('Ready'), findsOneWidget);
      expect(find.text('Dispatched'), findsOneWidget);
      expect(find.text('Returned'), findsOneWidget);
    });

    testWidgets('Interactive flight case checklist advances CONFIRMED to PACKING and READY', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      const testId = 'BK-STATUS-TRANSITION-TEST';
      final testBooking = BookingItem(
        id: testId,
        eventTitle: 'Status Transition Event',
        clientName: 'Acme Corp',
        category: 'Corporate',
        date: 'Today',
        venue: 'Exhibition Hall',
        status: 'CONFIRMED',
        unitsCount: 2,
        totalAmount: 15000.0,
      );
      BookingRepository().addBooking(testBooking);

      await tester.pumpWidget(
        buildTestApp(
          BookingDetailsScreen(
            bookingId: testId,
            eventTitle: 'Status Transition Event',
            clientName: 'Acme Corp',
            venue: 'Exhibition Hall',
            status: 'CONFIRMED',
            manifestItems: const [
              {'name': 'Case 1', 'sku': 'SKU-001', 'flightCase': 'FC-01', 'qty': 1, 'rate': 1000.0},
              {'name': 'Case 2', 'sku': 'SKU-002', 'flightCase': 'FC-02', 'qty': 1, 'rate': 1000.0},
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      final checkboxes = find.byType(Checkbox);
      expect(checkboxes, findsNWidgets(2));

      // Checking the first flight case should advance to PACKING
      await tester.ensureVisible(checkboxes.at(0));
      await tester.tap(checkboxes.at(0));
      await tester.pumpAndSettle();

      expect(BookingRepository().getBookingById(testId)?.status, 'PACKING');

      // Checking the second flight case should advance to READY
      await tester.ensureVisible(checkboxes.at(1));
      await tester.tap(checkboxes.at(1));
      await tester.pumpAndSettle();

      expect(BookingRepository().getBookingById(testId)?.status, 'READY');

      // Unchecking should step back to PACKING
      await tester.tap(checkboxes.at(1));
      await tester.pumpAndSettle();

      expect(BookingRepository().getBookingById(testId)?.status, 'PACKING');

      // Unchecking all should revert to CONFIRMED
      await tester.tap(checkboxes.at(0));
      await tester.pumpAndSettle();

      expect(BookingRepository().getBookingById(testId)?.status, 'CONFIRMED');
    });

    testWidgets('ReturnIntakeSheet batch reconciliation updates inventory and completes booking', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      const testId = 'BK-RECONCILE-TEST';
      final testBooking = BookingItem(
        id: testId,
        eventTitle: 'Return Reconcile Event',
        clientName: 'Client Reconcile',
        category: 'Corporate',
        date: 'Today',
        venue: 'Grand Ballroom',
        status: 'DISPATCHED',
        unitsCount: 4,
        totalAmount: 12000.0,
      );
      BookingRepository().addBooking(testBooking);

      await tester.pumpWidget(
        buildTestApp(
          Scaffold(
            body: ReturnIntakeSheet(
              bookingId: testId,
              eventTitle: 'Return Reconcile Event',
              clientName: 'Client Reconcile',
              manifestItems: const [
                {'name': 'L-Acoustics K2 Module', 'sku': 'AU-K2-LARR', 'qty': 4},
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('RETURN INTAKE & RECONCILIATION'), findsOneWidget);

      final submitBtn = find.text('Submit Return & Reconcile Stock');
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      // Booking status must be updated to COMPLETED
      expect(BookingRepository().getBookingById(testId)?.status, 'COMPLETED');
    });
  });

  group('Day 5: Role-Based Access Control (RBAC) & Profile View Tests', () {
    testWidgets('Warehouse role lands directly on Dispatch view (Tab 3)', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        buildTestApp(
          const DashboardScreen(
            userName: 'Prateek',
            userRole: 'warehouse',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Direct landing on Dispatch queues
      expect(find.text('Pending Loading'), findsOneWidget);
      expect(find.text('In Transit / On Stage'), findsOneWidget);
      expect(find.text('Awaiting Return'), findsOneWidget);
    });

    testWidgets('Coordinator role lands on Overview dashboard (Tab 0)', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        buildTestApp(
          const DashboardScreen(
            userName: 'Mayank',
            userRole: 'coordinator',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Hello Mayank'), findsOneWidget);
      expect(find.text('Active Bookings'), findsOneWidget);
    });

    testWidgets('More tab renders active user profile, role badge, and examiner role switcher', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        buildTestApp(
          const DashboardScreen(
            userName: 'Mayank Sharma',
            userRole: 'coordinator',
            initialNavIndex: 4, // More tab
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Header & Profile Card
      expect(find.text('OPERATIONS CONFIG'), findsOneWidget);
      expect(find.text('Mayank Sharma'), findsOneWidget);
      expect(find.text('EVENT COORDINATOR'), findsOneWidget);
      expect(find.text('mayank.sharma@rentflow.ops'), findsOneWidget);

      // Verify Examiner Demo Role Switcher
      expect(find.text('EXAMINER DEMO: SWITCH ACTIVE ROLE'), findsOneWidget);
      expect(find.text('Coordinator'), findsOneWidget);
      expect(find.text('Warehouse'), findsOneWidget);
      expect(find.text('Admin'), findsOneWidget);

      // Tap Warehouse role chip to switch persona
      await tester.tap(find.text('Warehouse'));
      await tester.pumpAndSettle();

      // Switching to warehouse immediately redirects to Dispatch screen!
      expect(find.text('Pending Loading'), findsOneWidget);
      expect(find.text('In Transit / On Stage'), findsOneWidget);
      expect(find.text('Awaiting Return'), findsOneWidget);
    });
  });
}
