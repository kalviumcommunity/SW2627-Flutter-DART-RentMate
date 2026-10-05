import 'package:flutter/material.dart';
import '../../screens/bookings/bookings_screen.dart';
import '../../screens/create_booking/create_booking_screen.dart';
import '../../screens/dashboard/dashboard_screen.dart';
import '../../screens/dispatch/dispatch_screen.dart';
import '../../screens/home_screen.dart';
import '../../screens/inventory/inventory_screen.dart';
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
  static const String createBooking = '/create-booking';
  static const String inventory = '/inventory';
  static const String dispatch = '/dispatch';
  static const String scaffoldHome = '/scaffold-home';

  /// Table of available application routes.
  static Map<String, WidgetBuilder> get routes => {
        splash: (context) => const SplashScreen(),
        login: (context) => const LoginScreen(),
        dashboard: (context) => const DashboardScreen(),
        bookings: (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final initialFilter = args is String ? args : null;
          return BookingsScreen(initialFilter: initialFilter);
        },
        createBooking: (context) => const CreateBookingScreen(),
        inventory: (context) => const InventoryScreen(),
        dispatch: (context) => const DispatchScreen(),
        scaffoldHome: (context) => const HomeScreen(),
      };
}
