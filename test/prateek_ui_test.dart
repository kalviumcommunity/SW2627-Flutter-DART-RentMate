import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rentflow/core/theme/app_theme.dart';
import 'package:rentflow/models/booking_draft.dart';
import 'package:rentflow/models/equipment_item.dart';
import 'package:rentflow/screens/create_booking/create_booking_screen.dart';
import 'package:rentflow/screens/create_booking/equipment_conflict_screen.dart';
import 'package:rentflow/screens/dispatch/dispatch_screen.dart';
import 'package:rentflow/screens/inventory/inventory_screen.dart';

void main() {
  testWidgets('Create Booking screen renders 3-step indicator and event details form',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const CreateBookingScreen(),
      ),
    );

    // Verify step indicator labels
    expect(find.text('Event Details'), findsOneWidget);
    expect(find.text('Equipment'), findsOneWidget);
    expect(find.text('Review'), findsOneWidget);

    // Verify Step 1 fields
    expect(find.text('EVENT TYPE'), findsOneWidget);
    expect(find.text('Wedding'), findsOneWidget);
    expect(find.text('Corporate'), findsOneWidget);
    expect(find.text('EVENT NAME *'), findsOneWidget);
    expect(find.text('CUSTOMER NAME *'), findsOneWidget);
    expect(find.text('PHONE NUMBER *'), findsOneWidget);
    expect(find.text('EVENT VENUE *'), findsOneWidget);
    expect(find.text('Next: Select Equipment'), findsOneWidget);
  });

  testWidgets('Create Booking step progression with sample data',
      (WidgetTester tester) async {
    final sampleDraft = BookingDraft.sample();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: CreateBookingScreen(initialDraft: sampleDraft),
      ),
    );

    // Navigate to Step 2: Equipment
    await tester.tap(find.text('Next: Select Equipment'));
    await tester.pumpAndSettle();

    // Verify equipment selector widgets render
    expect(find.text('JBL Line Array VRX932'), findsOneWidget);
    expect(find.text('Moving Head Light Beam 230W'), findsOneWidget);
    expect(find.text('TOTAL: '), findsWidgets);
    expect(find.text('AVAILABLE: '), findsWidgets);

    // Navigate to Step 3: Review
    final nextReviewFinder = find.widgetWithText(ElevatedButton, 'Next: Review (12 Items)');
    expect(nextReviewFinder, findsOneWidget);
    await tester.tap(nextReviewFinder);
    await tester.pumpAndSettle();

    // Verify Step 3: Review & Confirm components
    expect(find.text('Availability verified · No conflicts'), findsOneWidget);
    expect(find.text('Event & Customer Details'), findsOneWidget);
    expect(find.text('Starlight Gala Evening'), findsOneWidget);
    expect(find.text('Confirm Booking'), findsOneWidget);
  });

  testWidgets('Equipment Conflict screen renders shortage warning and 3 resolution actions',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final conflictingItem = EquipmentItem.sampleCatalog.first; // JBL Line Array (Available: 3)

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: EquipmentConflictScreen(
          item: conflictingItem,
          requestedQuantity: 6, // 6 requested vs 3 available => shortage 3
        ),
      ),
    );

    // Strong warning state
    expect(find.text('Not Enough Available'), findsOneWidget);
    expect(find.text('REQUESTED'), findsOneWidget);
    expect(find.text('AVAILABLE'), findsOneWidget);
    expect(find.text('SHORTAGE'), findsOneWidget);
    expect(find.text('+3'), findsOneWidget);

    // Conflicting booking identified
    expect(find.text('CONFLICTING RESERVATION IDENTIFIED'), findsOneWidget);
    expect(find.text('TechCorp Annual Conference'), findsOneWidget);

    // 3 resolution pathways
    expect(find.text('Reduce Quantity to 3 Units'), findsOneWidget);
    expect(find.text('Change Event Date or Time'), findsOneWidget);
    expect(find.text('Keep Shortage in Waitlist'), findsOneWidget);
  });

  testWidgets('Inventory screen renders stock KPIs, search, and equipment cards',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const InventoryScreen(),
      ),
    );

    expect(find.text('Inventory Management'), findsOneWidget);
    expect(find.text('Total Stock'), findsOneWidget);
    expect(find.text('Add Asset'), findsOneWidget);

    // Available, Limited, Out of Stock appear in both KPI cards and FilterChips
    expect(find.text('Available'), findsNWidgets(2));
    expect(find.text('Limited'), findsNWidgets(2));
    expect(find.text('Out of Stock'), findsNWidgets(2));

    // Verify catalog items
    expect(find.text('JBL Line Array VRX932'), findsOneWidget);
    expect(find.text('SKU-SND-101'), findsOneWidget);
  });

  testWidgets('Dispatch screen renders checklist items and handles item pack toggle',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const DispatchScreen(),
      ),
    );

    expect(find.text('Warehouse Dispatch'), findsOneWidget);
    expect(find.text('Royal Heritage Wedding Sangeet'), findsOneWidget);
    expect(find.text('Loading Dock Progress'), findsOneWidget);
    expect(find.text('All Items (6)'), findsOneWidget);
    expect(find.text('Packed (3)'), findsOneWidget);
    expect(find.text('Pending (3)'), findsOneWidget);

    // Verify checklist rows
    expect(find.text('JBL Line Array VRX932'), findsOneWidget);
    expect(find.text('Moving Head Light Beam 230W'), findsOneWidget);
    expect(find.text('Truss (2m) Section'), findsOneWidget);
    expect(find.text('Wireless Mic Dual Handheld'), findsOneWidget);

    // Toggle 4th item (Wireless Mic) from Pending to Packed
    await tester.tap(find.text('Wireless Mic Dual Handheld'));
    await tester.pumpAndSettle();

    // Verify progress updated from 3 to 4 packed
    expect(find.text('Packed (4)'), findsOneWidget);
    expect(find.text('Pending (2)'), findsOneWidget);
  });
}
