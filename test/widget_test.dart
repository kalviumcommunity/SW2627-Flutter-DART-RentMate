import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rentflow/core/constants/app_constants.dart';
import 'package:rentflow/main.dart';
import 'package:rentflow/screens/bookings/bookings_screen.dart';
import 'package:rentflow/screens/dashboard/dashboard_screen.dart';
import 'package:rentflow/screens/login/login_screen.dart';
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
}
