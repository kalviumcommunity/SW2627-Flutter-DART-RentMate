import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rentflow/main.dart';
import 'package:rentflow/screens/login/login_screen.dart';
import 'package:rentflow/screens/signup/signup_screen.dart';
import 'package:rentflow/core/theme/app_theme.dart';
import 'package:rentflow/screens/dashboard/dashboard_screen.dart';
import 'package:rentflow/screens/inventory/inventory_screen.dart';

void main() {
  testWidgets('RentFlowApp launches with Login screen as initial route',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const RentFlowApp());

    // Verify Login screen elements appear as initial route
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Sign In to Operations'), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);
  });

  testWidgets('Login screen renders authentication controls',
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
        home: const LoginScreen(),
      ),
    );

    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Work Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Remember me'), findsOneWidget);
    expect(find.text('Sign In to Operations'), findsOneWidget);
    expect(find.text('Continue with Google Workspace'), findsOneWidget);
    expect(find.text('Continue with Apple ID'), findsOneWidget);
  });

  testWidgets('SignUp screen renders registration controls in reference to Login',
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
        home: const SignUpScreen(),
      ),
    );

    expect(find.text('Create Account'), findsNWidgets(2)); // Title & Button
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Work Email'), findsOneWidget);
    expect(find.text('Operational Role'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Confirm Password'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });

  testWidgets('Dashboard renders Hello {user name} at left corner',
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
        home: const DashboardScreen(userName: 'Mayank Sharma'),
      ),
    );

    expect(find.text('Hello Mayank Sharma'), findsOneWidget);
    expect(find.text('Active Bookings'), findsOneWidget);
  });

  testWidgets('Signing in navigates to dashboard and displays Hello {user name}',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const RentFlowApp());

    await tester.ensureVisible(find.text('Sign In to Operations'));
    await tester.tap(find.text('Sign In to Operations'));
    await tester.pumpAndSettle(const Duration(milliseconds: 600));

    expect(find.text('Hello Mayank'), findsOneWidget);
  });

  testWidgets('Signing up navigates to dashboard and displays Hello {user name}',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const RentFlowApp());

    // Navigate to Sign Up
    await tester.ensureVisible(find.text('Sign Up'));
    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();

    // Enter name in first text field (Full Name)
    await tester.enterText(find.byType(TextField).first, 'Alex Rivera');
    await tester.pumpAndSettle();

    // Tap Create Account
    await tester.ensureVisible(find.text('Create Account').last);
    await tester.tap(find.text('Create Account').last);
    await tester.pumpAndSettle(const Duration(milliseconds: 700));

    expect(find.text('Hello Alex Rivera'), findsOneWidget);
  });

  testWidgets('Inventory screen renders fleet metrics and equipment roster',
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

    expect(find.text('INVENTORY FLEET'), findsOneWidget);
    expect(find.text('TOTAL ASSETS'), findsOneWidget);
    expect(find.text('EQUIPMENT ROSTER'), findsOneWidget);
    expect(find.text('Robe Robin Pointe Moving Beam'), findsOneWidget);
  });
}
