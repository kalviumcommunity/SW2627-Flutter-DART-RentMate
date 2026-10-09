import 'package:flutter/material.dart';
import '../../screens/bookings/booking_details_screen.dart';
import '../../screens/bookings/bookings_list_screen.dart';
import '../../screens/bookings/create_booking_screen.dart';
import '../../screens/dashboard/dashboard_screen.dart';
import '../../screens/login/login_screen.dart';
import '../../screens/signup/signup_screen.dart';

/// Centralized route definitions for RentFlow.
final class AppRoutes {
  AppRoutes._();

  static const String login = '/';
  static const String signUp = '/signup';
  static const String dashboard = '/dashboard';
  static const String bookings = '/bookings';
  static const String createBooking = '/create-booking';
  static const String bookingDetails = '/booking-details';

  /// Table of available application routes.
  static Map<String, WidgetBuilder> get routes => {
        login: (context) => const LoginScreen(),
        signUp: (context) => const SignUpScreen(),
        dashboard: (context) => const DashboardScreen(),
        bookings: (context) => const BookingsListScreen(),
        createBooking: (context) => const CreateBookingScreen(),
        bookingDetails: (context) => const BookingDetailsScreen(),
      };
}

