import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rentflow/main.dart';
import 'package:rentflow/screens/login/login_screen.dart';
import 'package:rentflow/screens/signup/signup_screen.dart';
import 'package:rentflow/core/services/auth_service.dart';
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

    // Enter valid registration details across all required fields
    await tester.enterText(find.byType(TextField).at(0), 'Alex Rivera');
    await tester.enterText(find.byType(TextField).at(1), 'alex.rivera@rentflow.ops');
    await tester.enterText(find.byType(TextField).at(2), 'securePass123');
    await tester.enterText(find.byType(TextField).at(3), 'securePass123');
    await tester.pumpAndSettle();

    // Tap Create Account
    await tester.ensureVisible(find.text('Create Account').last);
    await tester.tap(find.text('Create Account').last);
    await tester.pumpAndSettle(const Duration(milliseconds: 700));

    expect(find.text('Hello Alex Rivera'), findsOneWidget);
  });

  testWidgets('SignUp screen prevents blank submission and shows validation errors',
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

    // Tap Create Account without typing any input
    await tester.ensureVisible(find.text('Create Account').last);
    await tester.tap(find.text('Create Account').last);
    await tester.pumpAndSettle();

    // Assert that validation errors appear and user stays on SignUp screen
    expect(find.text('Full name is required'), findsOneWidget);
    expect(find.text('Work email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
    expect(find.text('Please confirm your password'), findsOneWidget);
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

  testWidgets('Tapping Inventory tab on Dashboard switches to Inventory view',
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
        home: const DashboardScreen(userName: 'Mayank'),
      ),
    );

    // Initial Overview Dashboard is visible
    expect(find.text('Active Bookings'), findsOneWidget);

    // Tap Inventory in bottom navigation
    await tester.tap(find.text('Inventory').last);
    await tester.pumpAndSettle();

    // Inventory screen content is now rendered
    expect(find.text('INVENTORY FLEET'), findsOneWidget);
    expect(find.text('TOTAL ASSETS'), findsOneWidget);
    expect(find.text('Robe Robin Pointe Moving Beam'), findsOneWidget);

    // Tap back button in header to return to Overview
    await tester.tap(find.byTooltip('Back to Overview'));
    await tester.pumpAndSettle();

    expect(find.text('Active Bookings'), findsOneWidget);
  });

  test('AuthUser correctly parses user info and defaults name from email', () {
    final user = AuthUser.fromGoogleUserInfo({
      'id': '123456789',
      'email': 'coordinator@rentflow.ops',
      'name': '',
      'picture': 'https://example.com/avatar.png',
    }, 'sample_access_token');

    expect(user.id, '123456789');
    expect(user.email, 'coordinator@rentflow.ops');
    expect(user.displayName, 'coordinator');
    expect(user.photoUrl, 'https://example.com/avatar.png');
    expect(user.accessToken, 'sample_access_token');
  });

  test('AuthService maintains singleton instance and initial unauthenticated state', () {
    final auth1 = AuthService();
    final auth2 = AuthService();

    expect(identical(auth1, auth2), isTrue);
    auth1.signOut();
    expect(auth1.isAuthenticated, isFalse);
    expect(auth1.currentUser, isNull);
  });

  testWidgets('Tapping Dispatch and More tabs renders dedicated operational views',
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
        home: const DashboardScreen(userName: 'Mayank'),
      ),
    );

    // Tap Dispatch tab
    await tester.tap(find.text('Dispatch').last);
    await tester.pumpAndSettle();
    expect(find.text('DISPATCH & LOGISTICS'), findsOneWidget);

    // Tap More tab
    await tester.tap(find.text('More').last);
    await tester.pumpAndSettle();
    expect(find.text('OPERATIONS CONFIG'), findsOneWidget);
  });
}
