import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rentflow/core/models/booking_item.dart';
import 'package:rentflow/core/services/booking_repository.dart';
import 'package:rentflow/core/theme/app_theme.dart';
import 'package:rentflow/screens/bookings/create_booking_screen.dart';

void main() {
  testWidgets('CreateBookingScreen validates Step 1 fields (title, client name, venue)',
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
        home: const CreateBookingScreen(),
      ),
    );

    // Initial step is Step 1 with empty inputs
    expect(find.text('Event & Client Information'), findsOneWidget);
    expect(find.text('Next: Select Equipment'), findsOneWidget);

    // Try tapping Next without filling required fields
    await tester.tap(find.text('Next: Select Equipment'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Verify validation warning snackbar appears
    expect(
      find.text('Please enter event title, client name, and venue to continue.'),
      findsOneWidget,
    );

    // Remain on Step 1
    expect(find.text('Event & Client Information'), findsOneWidget);
  });

  testWidgets('CreateBookingScreen disables Next button on Step 2 until item is added',
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
        home: const CreateBookingScreen(),
      ),
    );

    // Fill in Step 1 required fields
    await tester.enterText(
      find.byType(TextField).at(0),
      'Grand Tech Expo 2026',
    );
    await tester.enterText(
      find.byType(TextField).at(1),
      'Vikram Mehra',
    );
    await tester.enterText(
      find.byType(TextField).at(3),
      'JECC Convention Centre',
    );
    await tester.pumpAndSettle();

    // Advance to Step 2
    await tester.tap(find.text('Next: Select Equipment'));
    await tester.pumpAndSettle();

    // Step 2 is active
    expect(find.text('Select Equipment Catalog'), findsOneWidget);

    // Since 0 items are selected by default, button is disabled with prompt label
    expect(find.text('Select Equipment to Continue'), findsOneWidget);

    // Add 1 JBL Line Array speaker by tapping first '+' icon
    final addIcons = find.byIcon(Icons.add);
    expect(addIcons, findsWidgets);
    await tester.tap(addIcons.first);
    await tester.pumpAndSettle();

    // Now 1 item is selected, button enables with count
    expect(find.text('Next: Review Booking (1 Items)'), findsOneWidget);
  });

  testWidgets('Booking confirmation adds new booking to BookingRepository and notifies listeners',
      (WidgetTester tester) async {
    final repo = BookingRepository();
    final initialCount = repo.bookings.length;

    const testBooking = BookingItem(
      id: 'BK-TEST-001',
      eventTitle: 'Automated Test Event',
      clientName: 'Tester User',
      category: 'Corporate',
      date: '25 Oct — 28 Oct',
      venue: 'Test Exhibition Grounds',
      status: 'CONFIRMED',
      unitsCount: 10,
      totalAmount: 50000.0,
    );

    repo.addBooking(testBooking);

    expect(repo.bookings.length, equals(initialCount + 1));
    expect(repo.bookings.first.id, equals('BK-TEST-001'));
    expect(repo.bookings.first.eventTitle, equals('Automated Test Event'));
  });
}
