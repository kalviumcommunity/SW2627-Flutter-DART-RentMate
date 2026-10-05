import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rentflow/core/constants/app_constants.dart';
import 'package:rentflow/main.dart';
import 'package:rentflow/screens/bookings/bookings_screen.dart';
import 'package:rentflow/screens/create_booking/create_booking_screen.dart';
import 'package:rentflow/screens/dashboard/dashboard_screen.dart';
import 'package:rentflow/screens/login/login_screen.dart';
import 'package:rentflow/widgets/dashboard/conflict_alert_card.dart';
import 'package:rentflow/core/theme/app_theme.dart';

void main() {
  testWidgets('Splash screen launches with RentFlow brand identity',
      (WidgetTester tester) async {
    await tester.pumpWidget(const RentFlowApp());

    // Verify brand title and motto appear on splash
    expect(find.text(AppConstants.appName), findsOneWidget);
    expect(find.text(AppConstants.appMotto), findsOneWidget);
  });

  testWidgets('Login screen renders authentication controls',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const LoginScreen(),
      ),
    );

    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Work Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Sign In to Operations'), findsOneWidget);
  });

  testWidgets('Dashboard renders coordinator greeting, KPIs, and conflicts',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const DashboardScreen(),
      ),
    );

    expect(find.text('Good morning, Mayank'), findsOneWidget);
    expect(find.text('Active Bookings'), findsOneWidget);
    expect(find.text('Dispatches Due'), findsOneWidget);
    expect(find.text('Conflicts'), findsOneWidget);
    expect(find.text('Quick Operations'), findsOneWidget);
  });

  testWidgets('Bookings screen renders search bar, filters, and booking cards',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const BookingsScreen(),
      ),
    );

    expect(find.text('Event Bookings'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('New Booking'), findsOneWidget);
    expect(find.text('Royal Heritage Wedding Sangeet'), findsOneWidget);
  });

  testWidgets('Bookings screen respects initialFilter argument (Conflict pre-filtered)',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const BookingsScreen(initialFilter: AppConstants.statusConflict),
      ),
    );

    expect(find.text('Event Bookings'), findsOneWidget);
    expect(find.text('Royal Heritage Wedding Sangeet'), findsOneWidget);
    // Booking with status Packing should NOT be present when filtered by Conflict
    expect(find.text('National FinTech Conclave 2026'), findsNothing);
  });

  testWidgets('ConflictAlertCard pluralizes correctly and invokes resolve callback',
      (WidgetTester tester) async {
    bool resolved = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: ConflictAlertCard(
            conflictCount: 2,
            description: '2 equipment items double booked.',
            onResolveTap: () => resolved = true,
          ),
        ),
      ),
    );

    expect(find.text('2 Equipment Conflicts Detected'), findsOneWidget);
    expect(find.text('CRITICAL'), findsOneWidget);

    await tester.tap(find.text('Resolve Conflict'));
    expect(resolved, isTrue);
  });

  testWidgets('CreateBookingScreen Fill Sample populates form and advances to Step 2',
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

    // Tap "Fill Sample" in AppBar
    await tester.tap(find.text('Fill Sample'));
    await tester.pumpAndSettle();

    // Verify fields populated via didUpdateWidget
    expect(find.text('Starlight Gala Evening'), findsOneWidget);
    expect(find.text('Aarav Mehta'), findsOneWidget);

    // Clear SnackBar to unblock bottom action bar hit testing
    ScaffoldMessenger.of(tester.element(find.byType(CreateBookingScreen)))
        .clearSnackBars();
    await tester.pumpAndSettle();

    // Proceed to Step 2
    await tester.tap(find.text('Next: Select Equipment'));
    await tester.pumpAndSettle();

    // Successfully transitioned to Step 2 without validation errors
    expect(find.text('JBL Line Array VRX932'), findsOneWidget);
  });
}
