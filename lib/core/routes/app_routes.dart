import 'package:flutter/material.dart';
import '../../screens/bookings/bookings_screen.dart';
import '../../screens/dashboard/dashboard_screen.dart';
import '../../screens/home_screen.dart';
import '../../screens/login/login_screen.dart';
import '../../screens/splash/splash_screen.dart';

/// Centralized route definitions for RentFlow.
///
/// Flutter & Dart Concepts:
/// - `Map<String, WidgetBuilder>`: A key-value lookup where each route string
///   points to a builder function that returns a Widget.
/// - Named routes provide clear, decoupled screen navigation without hardcoding
///   screen classes throughout the widget hierarchy.
final class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String bookings = '/bookings';
  static const String scaffoldHome = '/scaffold-home';

  /// Table of available application routes.
  static Map<String, WidgetBuilder> get routes => {
        splash: (context) => const SplashScreen(),
        login: (context) => const LoginScreen(),
        dashboard: (context) => const DashboardScreen(),
        bookings: (context) => const BookingsScreen(),
        scaffoldHome: (context) => const HomeScreen(),
      };
}
