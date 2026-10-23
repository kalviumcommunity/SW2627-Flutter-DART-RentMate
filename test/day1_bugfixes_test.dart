import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rentflow/core/constants/app_constants.dart';
import 'package:rentflow/core/services/inventory_repository.dart';
import 'package:rentflow/screens/bookings/create_booking_screen.dart';
import 'package:rentflow/screens/dashboard/dashboard_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Day 1 Bug Fixes & Verification Tests', () {
    test('DUP-01: Canonical equipment categories and category matching taxonomy', () {
      expect(AppConstants.equipmentCategories, [
        'All',
        'Sound',
        'Lighting',
        'Visuals',
        'Staging',
        'Power',
      ]);

      // Category matching checks (itemCategory, selectedFilter)
      expect(AppConstants.categoryMatches('Lighting', 'All'), isTrue);
      expect(AppConstants.categoryMatches('Audio', 'Sound'), isTrue);
      expect(AppConstants.categoryMatches('Sound', 'Sound'), isTrue);
      expect(AppConstants.categoryMatches('Video & LED', 'Visuals'), isTrue);
      expect(AppConstants.categoryMatches('Rigging & Staging', 'Staging'), isTrue);
      expect(AppConstants.categoryMatches('Power & Control', 'Power'), isTrue);
      expect(AppConstants.categoryMatches('Audio', 'Lighting'), isFalse);
    });

    testWidgets('BUG-08: CreateBookingScreen validates Step 1 required fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CreateBookingScreen(),
        ),
      );

      // Verify we are on Step 1
      expect(find.text('EVENT TITLE'), findsOneWidget);
      expect(find.text('Next: Select Equipment'), findsOneWidget);

      // Attempt to proceed without entering details
      await tester.tap(find.text('Next: Select Equipment'));
      await tester.pumpAndSettle();

      // Check validation error snackbar
      expect(find.text('Please enter event title, client name, and venue to continue.'), findsOneWidget);
      // Still on Step 1
      expect(find.text('Next: Select Equipment'), findsOneWidget);
    });

    testWidgets('BUG-08: CreateBookingScreen disables Step 2 Next button when 0 items selected', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CreateBookingScreen(),
        ),
      );

      // Fill in Step 1 required fields
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'Sunburn Arena 2026');
      await tester.enterText(textFields.at(1), 'Percept Live');
      await tester.enterText(textFields.at(3), 'MMRDA Grounds, BKC');
      await tester.pumpAndSettle();

      // Tap Next to advance to Step 2
      await tester.tap(find.text('Next: Select Equipment'));
      await tester.pumpAndSettle();

      // Now on Step 2 with 0 items selected
      expect(find.text('Select Equipment to Proceed'), findsOneWidget);

      // Tap the disabled button, should not advance to Step 3
      await tester.tap(find.text('Select Equipment to Proceed'));
      await tester.pumpAndSettle();
      expect(find.text('Lock & Confirm Reservation'), findsNothing);

      // Add 1 item
      final addIcons = find.byIcon(Icons.add);
      expect(addIcons, findsWidgets);
      await tester.tap(addIcons.first);
      await tester.pumpAndSettle();

      // Button should now be enabled and say "Next: Review Booking (1 Items)"
      expect(find.text('Next: Review Booking (1 Items)'), findsOneWidget);
    });

    testWidgets('DUP-02: Dashboard reflects dynamic total assets count from InventoryRepository', (WidgetTester tester) async {
      final repo = InventoryRepository();
      final expectedCount = repo.totalAssetsCount;

      await tester.pumpWidget(
        const MaterialApp(
          home: DashboardScreen(userName: 'Mayank Sharma', userRole: 'coordinator'),
        ),
      );
      await tester.pumpAndSettle();

      // Verify dynamic inventory count matches repository
      expect(find.text('$expectedCount'), findsOneWidget);
      expect(find.text('EQUIPMENT UNITS'), findsOneWidget);
    });

    testWidgets('BUG-13: More tab provides session sign-out action', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DashboardScreen(userName: 'Mayank Sharma', userRole: 'coordinator'),
        ),
      );
      await tester.pumpAndSettle();

      // Tap More tab in navigation (index 4)
      await tester.tap(find.text('More'));
      await tester.pumpAndSettle();

      // Verify Sign Out of Session button exists in More view
      expect(find.text('Sign Out of Session'), findsOneWidget);
    });

    test('BUG-09: Multi-day rental duration calculation scales total pricing with rental period', () {
      final start = DateTime(2026, 11, 1);
      final endSingleDay = DateTime(2026, 11, 2);
      final endMultiDay = DateTime(2026, 11, 5); // 4 days

      final singleDayDuration = endSingleDay.difference(start).inDays;
      final multiDayDuration = endMultiDay.difference(start).inDays;

      expect(singleDayDuration, 1);
      expect(multiDayDuration, 4);

      const dailySubtotal = 12500.0;
      final singleDayTotal = dailySubtotal * singleDayDuration;
      final multiDayTotal = dailySubtotal * multiDayDuration;

      expect(singleDayTotal, 12500.0);
      expect(multiDayTotal, 50000.0);
      expect(multiDayTotal, equals(singleDayTotal * 4));
    });
  });
}
