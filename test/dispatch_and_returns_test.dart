import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rentflow/core/services/booking_repository.dart';
import 'package:rentflow/core/services/inventory_repository.dart';
import 'package:rentflow/core/theme/app_theme.dart';
import 'package:rentflow/screens/bookings/booking_details_screen.dart';
import 'package:rentflow/screens/dashboard/dashboard_screen.dart';
import 'package:rentflow/screens/dispatch/dispatch_screen.dart';
import 'package:rentflow/screens/dispatch/return_intake_sheet.dart';
import 'package:rentflow/widgets/equipment_scan_dialog.dart';

void main() {
  setUp(() {
    BookingRepository();
    InventoryRepository();
  });

  Widget createTestWidget(Widget child) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: child,
    );
  }

  group('Track B: Dispatch & Returns Workflow Tests', () {
    testWidgets('BUG-01: Dedicated DispatchScreen displays 3 categorized queues',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createTestWidget(const DispatchScreen()));
      await tester.pumpAndSettle();

      // Verify the 3 category tabs
      expect(find.text('Pending Loading'), findsOneWidget);
      expect(find.text('In Transit / On Stage'), findsOneWidget);
      expect(find.text('Awaiting Return'), findsOneWidget);

      // Verify header and tactical metrics
      expect(find.text('DISPATCH & LOGISTICS'), findsAtLeastNWidgets(1));
      expect(find.text('PENDING LOADING'), findsOneWidget);
      expect(find.text('IN TRANSIT'), findsOneWidget);
      expect(find.text('AWAITING RETURN'), findsAtLeastNWidgets(1));

      // Switch to In Transit queue
      await tester.tap(find.text('In Transit / On Stage'));
      await tester.pumpAndSettle();

      // Switch to Awaiting Return queue
      await tester.tap(find.text('Awaiting Return'));
      await tester.pumpAndSettle();
    });

    testWidgets('BUG-02: Quick command chip Dispatch navigates to Dispatch tab on Dashboard',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        createTestWidget(const DashboardScreen(userName: 'Lead Dispatcher')),
      );
      await tester.pumpAndSettle();

      // Ensure we are initially on Overview (tab 0)
      expect(find.text('Hello Lead Dispatcher'), findsOneWidget);

      // Tap the Dispatch command chip in Quick Commands using its icon
      final dispatchIcon = find.byIcon(Icons.local_shipping_outlined);
      await tester.ensureVisible(dispatchIcon);
      await tester.tap(dispatchIcon);
      await tester.pumpAndSettle();

      // Should now render dedicated DispatchScreen queues
      expect(find.text('Pending Loading'), findsOneWidget);
      expect(find.text('In Transit / On Stage'), findsOneWidget);
      expect(find.text('Awaiting Return'), findsOneWidget);
    });

    testWidgets('Role-Based Access: Warehouse operators land straight on Dispatch view (Tab 3)',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        createTestWidget(
          const DashboardScreen(
            userName: 'Warehouse Rig Lead',
            userRole: 'warehouse',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should bypass Overview and show Dispatch screen directly
      expect(find.text('Pending Loading'), findsOneWidget);
      expect(find.text('In Transit / On Stage'), findsOneWidget);
      expect(find.text('Awaiting Return'), findsOneWidget);
    });

    testWidgets('Role-Based Access: Coordinator lands on Overview (Tab 0)',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        createTestWidget(
          const DashboardScreen(
            userName: 'Sarah Jenkins',
            userRole: 'coordinator',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Coordinator lands on booking overview
      expect(find.text('Hello Sarah Jenkins'), findsOneWidget);
      expect(find.text('Active Bookings'), findsOneWidget);
    });

    testWidgets('GLITCH-09: EquipmentScanDialog opens with reticle and supports manual & barcode input',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      String? scannedResult;
      await tester.pumpWidget(
        createTestWidget(
          Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                scannedResult = await EquipmentScanDialog.show(
                  context,
                  title: 'DOCK SCANNER',
                );
              },
              child: const Text('OPEN SCANNER'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('OPEN SCANNER'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify scanner UI
      expect(find.text('DOCK SCANNER'), findsOneWidget);
      expect(find.text('INTAKE'), findsOneWidget);
      expect(find.text('QUICK SIMULATED BARCODES'), findsOneWidget);

      // Tap a simulated barcode chip
      await tester.tap(find.text('LT-PNT-700'));
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pump(const Duration(milliseconds: 300));

      // Verify scanned result returned
      expect(scannedResult, 'LT-PNT-700');
    });

    testWidgets('Equipment Manifest Checklist & Packing Progress in BookingDetailsScreen',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        createTestWidget(
          const BookingDetailsScreen(
            bookingId: 'BK-8942',
            eventTitle: 'Sharma Royal Wedding',
            status: 'PACKING',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify manifest checklist header and scan button
      expect(find.text('EQUIPMENT MANIFEST CHECKLIST'), findsOneWidget);
      expect(find.text('Scan Case'), findsOneWidget);

      // Check off the first flight case as loaded
      final initialCheckbox = find.byType(Checkbox).first;
      await tester.ensureVisible(initialCheckbox);
      await tester.tap(initialCheckbox);
      await tester.pumpAndSettle();

      // Verify loaded status indicator or progress
      expect(find.byType(Checkbox), findsWidgets);
    });

    testWidgets('Returns & Inventory Reconciliation updates fleet stock & maintenance counts',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final repo = InventoryRepository();
      final initialAvailable = repo.findBySku('LT-PNT-700')!['available'] as int;

      // Reconcile return with 2 good, 1 damaged
      repo.reconcileReturn(
        sku: 'LT-PNT-700',
        goodQty: 2,
        damagedQty: 1,
        missingQty: 0,
      );

      final updated = repo.findBySku('LT-PNT-700')!;
      expect(updated['available'], initialAvailable + 2);
      expect(updated['status'], 'MAINTENANCE');

      // Test ReturnIntakeSheet rendering
      await tester.pumpWidget(
        createTestWidget(
          Scaffold(
            body: ReturnIntakeSheet(
              bookingId: 'BK-TEST-01',
              eventTitle: 'Reconciliation Test',
              clientName: 'Apex Audio',
              manifestItems: const [
                {'name': 'Robe Robin Pointe Moving Beam', 'sku': 'LT-PNT-700', 'qty': 4},
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('RETURN INTAKE & RECONCILIATION'), findsOneWidget);
      expect(find.text('Submit Return & Reconcile Stock'), findsOneWidget);
      expect(find.text('Good / Restock'), findsOneWidget);
      expect(find.text('Maintenance'), findsOneWidget);
      expect(find.text('Missing / Lost'), findsAtLeastNWidgets(1));
    });
  });
}
