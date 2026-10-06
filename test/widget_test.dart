import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rentflow/main.dart';
import 'package:rentflow/screens/login/login_screen.dart';
import 'package:rentflow/screens/signup/signup_screen.dart';
import 'package:rentflow/core/theme/app_theme.dart';

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

  testWidgets('Navigation between Login and SignUp works correctly',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const RentFlowApp());

    // Click Sign Up on Login page
    await tester.ensureVisible(find.text('Sign Up'));
    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();

    // Verify on Sign Up screen
    expect(find.text('Create Account'), findsNWidgets(2));

    // Click Sign In on Sign Up page
    await tester.ensureVisible(find.text('Sign In'));
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    // Verify back on Login screen
    expect(find.text('Welcome Back'), findsOneWidget);
  });
}
