import 'package:flutter/material.dart';
import '../../screens/bookings/booking_details_screen.dart';
import '../../screens/bookings/bookings_list_screen.dart';
import '../../screens/bookings/create_booking_screen.dart';
import '../../screens/dashboard/dashboard_screen.dart';
import '../../screens/dispatch/dispatch_screen.dart';
import '../../screens/inventory/inventory_screen.dart';
import '../../screens/login/login_screen.dart';
import '../../screens/signup/signup_screen.dart';

/// Arguments model for typed navigation to [BookingDetailsScreen].
class BookingDetailsArgs {
  final String? bookingId;
  final String? eventTitle;
  final String? clientName;
  final String? clientPhone;
  final String? venue;
  final String? dates;
  final String? status;
  final int? totalItems;
  final double? grandTotal;
  final String? category;
  final List<Map<String, dynamic>>? manifestItems;

  const BookingDetailsArgs({
    this.bookingId,
    this.eventTitle,
    this.clientName,
    this.clientPhone,
    this.venue,
    this.dates,
    this.status,
    this.totalItems,
    this.grandTotal,
    this.category,
    this.manifestItems,
  });
}

/// Centralized route definitions for RentFlow.
final class AppRoutes {
  AppRoutes._();

  static const String login = '/';
  static const String signUp = '/signup';
  static const String dashboard = '/dashboard';
  static const String inventory = '/inventory';
  static const String bookings = '/bookings';
  static const String dispatch = '/dispatch';
  static const String createBooking = '/create-booking';
  static const String bookingDetails = '/booking-details';

  /// Table of available application routes.
  static Map<String, WidgetBuilder> get routes => {
        login: (context) => const LoginScreen(),
        signUp: (context) => const SignUpScreen(),
        dashboard: (context) => const DashboardScreen(),
        inventory: (context) => const InventoryScreen(),
        bookings: (context) => const BookingsListScreen(),
        dispatch: (context) => const DispatchScreen(),
        createBooking: (context) => const CreateBookingScreen(),
        bookingDetails: (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is BookingDetailsArgs) {
            return BookingDetailsScreen(
              bookingId: args.bookingId ?? 'BK-8942',
              eventTitle: args.eventTitle ?? 'Sharma Royal Wedding & Sangeet',
              clientName: args.clientName ?? 'Rajesh Sharma',
              clientPhone: args.clientPhone ?? '+91 98765 43210',
              venue: args.venue ?? 'The Oberoi Rajvilas, Jaipur',
              dates: args.dates ?? '14 Oct 2026, 10:00 AM — 15 Oct 2026, 11:30 PM',
              status: args.status ?? 'READY',
              totalItems: args.totalItems ?? 24,
              grandTotal: args.grandTotal ?? 48500.0,
              category: args.category ?? 'Wedding',
              manifestItems: args.manifestItems,
            );
          } else if (args is Map<String, dynamic>) {
            return BookingDetailsScreen(
              bookingId: args['bookingId']?.toString() ?? 'BK-8942',
              eventTitle: args['eventTitle']?.toString() ?? 'Sharma Royal Wedding & Sangeet',
              clientName: args['clientName']?.toString() ?? 'Rajesh Sharma',
              clientPhone: args['clientPhone']?.toString() ?? '+91 98765 43210',
              venue: args['venue']?.toString() ?? 'The Oberoi Rajvilas, Jaipur',
              dates: args['dates']?.toString() ?? '14 Oct 2026, 10:00 AM — 15 Oct 2026, 11:30 PM',
              status: args['status']?.toString() ?? 'READY',
              totalItems: args['totalItems'] is int ? args['totalItems'] as int : 24,
              grandTotal: args['grandTotal'] is num ? (args['grandTotal'] as num).toDouble() : 48500.0,
              category: args['category']?.toString() ?? 'Wedding',
            );
          }
          return const BookingDetailsScreen();
        },
      };
}
