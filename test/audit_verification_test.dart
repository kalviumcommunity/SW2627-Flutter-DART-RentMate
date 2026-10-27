import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rentflow/core/models/booking_item.dart';
import 'package:rentflow/core/models/equipment_item.dart';
import 'package:rentflow/core/routes/app_routes.dart';
import 'package:rentflow/core/services/auth_service.dart';
import 'package:rentflow/core/services/availability_service.dart';
import 'package:rentflow/core/services/booking_repository.dart';
import 'package:rentflow/core/services/inventory_repository.dart';
import 'package:rentflow/core/theme/app_theme.dart';
import 'package:rentflow/main.dart';
import 'package:rentflow/screens/bookings/booking_details_screen.dart';
import 'package:rentflow/screens/bookings/create_booking_screen.dart';
import 'package:rentflow/screens/inventory/inventory_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 2 Bug Audit Verification & Regression Suite', () {
    test('LOGIC-01: Inclusive multi-day rental interval calculation', () {
      final start = DateTime(2026, 10, 14, 10, 0);
      final endSameDay = DateTime(2026, 10, 14, 23, 30);
      final endNextDay = DateTime(2026, 10, 15, 23, 30);
      final endThreeDays = DateTime(2026, 10, 16, 18, 0);

      final days1 = AvailabilityService.generateRentalDays(start, endSameDay);
      final days2 = AvailabilityService.generateRentalDays(start, endNextDay);
      final days3 = AvailabilityService.generateRentalDays(start, endThreeDays);

      expect(days1.length, 1, reason: 'Same day rental is 1 operational calendar day');
      expect(days2.length, 2, reason: 'Oct 14 to Oct 15 is 2 inclusive calendar days');
      expect(days3.length, 3, reason: 'Oct 14 to Oct 16 is 3 inclusive calendar days');
    });

    test('LOGIC-03: COMPLETED bookings release equipment capacity for future checks', () {
      final availabilityService = AvailabilityService();
      final inventoryRepo = InventoryRepository();

      const sku = 'AU-K2-LARR';
      final item = inventoryRepo.findBySku(sku);
      expect(item, isNotNull);
      final totalStock = (item!['totalQuantity'] ?? item['total']) as int;

      final sDate = DateTime(2026, 12, 1);
      final eDate = DateTime(2026, 12, 2);

      // Create a booking with status COMPLETED
      final completedBooking = BookingItem(
        id: 'BK-COMPLETED-TEST',
        eventTitle: 'Past Completed Event',
        clientName: 'Completed Client',
        category: 'Corporate',
        date: '1 Dec — 2 Dec 2026',
        venue: 'Hall A',
        status: 'COMPLETED',
        unitsCount: totalStock,
        totalAmount: 50000.0,
        startDate: sDate,
        endDate: eDate,
        items: [
          {'sku': sku, 'name': 'Audio Module', 'quantity': totalStock, 'dailyRate': 2200.0}
        ],
      );

      BookingRepository().bookings.add(completedBooking);

      // Check availability: completed booking should NOT block capacity
      final checkResult = availabilityService.checkAvailability(
        startDate: sDate,
        endDate: eDate,
        requestedItems: [
          {'sku': sku, 'name': 'Audio Module', 'quantity': 1}
        ],
      );

      expect(checkResult.isAvailable, isTrue,
          reason: 'COMPLETED bookings must not consume active rentable capacity');

      // Cleanup
      BookingRepository().bookings.removeWhere((b) => b.id == 'BK-COMPLETED-TEST');
    });

    test('ARCH-03: AppRoutes registers /dispatch route', () {
      expect(AppRoutes.routes.containsKey(AppRoutes.dispatch), isTrue);
      expect(AppRoutes.dispatch, '/dispatch');
    });

    test('DUP-05: EquipmentCatalogItem maps to and from EquipmentItem domain model', () {
      const eqItem = EquipmentItem(
        id: 'SND-TEST-01',
        sku: 'SND-TEST-01',
        name: 'Test Rig',
        category: 'Sound',
        total: 10,
        available: 8,
        deployed: 2,
        dailyRate: 1500.0,
        status: 'IN WAREHOUSE',
        specs: 'Specs',
      );

      final catalogItem = EquipmentCatalogItem.fromEquipmentItem(eqItem, selectedQty: 3);
      expect(catalogItem.id, 'SND-TEST-01');
      expect(catalogItem.totalQty, 10);
      expect(catalogItem.availableQty, 8);
      expect(catalogItem.selectedQty, 3);

      final backToDomain = catalogItem.toEquipmentItem();
      expect(backToDomain.sku, 'SND-TEST-01');
      expect(backToDomain.total, 10);
      expect(backToDomain.available, 8);
    });

    testWidgets('BUG-17 & GLITCH-11: BookingDetailsScreen dynamically renders passed manifest items & corrects subtotal',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final customItems = [
        {
          'sku': 'VIS-CUSTOM-01',
          'name': 'Custom LED Modular Panel',
          'quantity': 2,
          'dailyRate': 5000.0,
        }
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: BookingDetailsScreen(
            bookingId: 'BK-DYNAMIC-MANIFEST',
            eventTitle: 'Apex Global Conference',
            clientName: 'Apex Tech Corp',
            category: 'Corporate',
            grandTotal: 12500.0,
            manifestItems: customItems,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check dynamic title, client, and item
      expect(find.text('Apex Global Conference'), findsOneWidget);
      expect(find.text('Apex Tech Corp'), findsOneWidget);
      expect(find.text('Custom LED Modular Panel'), findsOneWidget);

      // Verify contract amount
      expect(find.text('₹12500'), findsWidgets);
    });

    testWidgets('BUG-18: InventoryScreen Add Equipment modal bottom sheet allows registering asset',
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
          home: const Scaffold(body: InventoryScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Tap ADD EQUIPMENT button in bottom bar
      final addBtn = find.text('ADD EQUIPMENT');
      expect(addBtn, findsOneWidget);
      await tester.tap(addBtn);
      await tester.pumpAndSettle();

      // Verify bottom sheet opened
      expect(find.text('Add Fleet Equipment'), findsOneWidget);
      expect(find.text('Add to Warehouse Fleet'), findsOneWidget);

      // Fill in required fields
      await tester.enterText(find.byType(TextFormField).at(0), 'Genelec Studio Monitor');
      await tester.enterText(find.byType(TextFormField).at(1), 'SND-GENELEC-8040');
      await tester.enterText(find.byType(TextFormField).at(2), '6');
      await tester.enterText(find.byType(TextFormField).at(3), '1500');
      await tester.pumpAndSettle();

      // Submit
      await tester.tap(find.text('Add to Warehouse Fleet'));
      await tester.pumpAndSettle();

      // Verify newly registered item is in inventory
      final found = InventoryRepository().findBySku('SND-GENELEC-8040');
      expect(found, isNotNull);
      expect(found!['name'], 'Genelec Studio Monitor');
      expect(found['total'], 6);
    });

    test('Apple ID Authentication: establishes authenticated session with Private Relay support', () async {
      final authService = AuthService();
      final user = await authService.signInWithApple(
        name: 'Mayank Sharma',
        email: 'mayank_92kx@privaterelay.appleid.com',
        role: 'coordinator',
        isPrivateRelay: true,
      );

      expect(user, isNotNull);
      expect(user!.displayName, 'Mayank Sharma');
      expect(user.email.endsWith('@privaterelay.appleid.com'), isTrue);
      expect(authService.currentUser?.email, 'mayank_92kx@privaterelay.appleid.com');
      expect(authService.isAuthenticated, isTrue);
    });

    testWidgets('Apple ID Modal: clicking Continue with Apple ID opens native Apple sheet',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const RentFlowApp());
      await tester.pumpAndSettle();

      // Tap Continue with Apple ID
      final appleBtn = find.text('Continue with Apple ID');
      expect(appleBtn, findsOneWidget);
      await tester.ensureVisible(appleBtn);
      await tester.tap(appleBtn);
      await tester.pumpAndSettle();

      // Verify Apple sheet renders
      expect(find.text('Sign in with Apple'), findsOneWidget);
      expect(find.text('Share My Email'), findsOneWidget);
      expect(find.text('Hide My Email'), findsOneWidget);
      expect(find.text('PRIVATE RELAY'), findsOneWidget);

      // Confirm with Apple
      await tester.tap(find.text('Continue with Apple'));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      // Verify navigation to dashboard
      expect(find.text('Hello Mayank'), findsOneWidget);
    });
  });
}
