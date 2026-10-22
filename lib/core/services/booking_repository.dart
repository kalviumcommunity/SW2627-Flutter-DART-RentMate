import 'package:flutter/foundation.dart';
import '../models/booking_item.dart';

/// Centralized in-memory booking repository for RentFlow session state.
class BookingRepository {
  static final BookingRepository _instance = BookingRepository._internal();
  factory BookingRepository() => _instance;

  BookingRepository._internal() {
    bookingsNotifier = ValueNotifier<List<BookingItem>>(List.unmodifiable(_initialBookings));
  }

  static const List<BookingItem> _initialBookings = [
    BookingItem(
      id: 'BK-8942',
      eventTitle: 'Sharma Royal Wedding & Sangeet',
      clientName: 'Rajesh Sharma',
      category: 'Wedding',
      date: 'Today, 14:00 — 23:30',
      venue: 'The Oberoi Rajvilas, Jaipur',
      status: 'READY',
      unitsCount: 24,
      totalAmount: 48500.0,
    ),
    BookingItem(
      id: 'BK-8941',
      eventTitle: 'TechCorp Global Product Launch 2026',
      clientName: 'Priya Mehra',
      category: 'Corporate',
      date: 'Tomorrow, 08:30 — 18:00',
      venue: 'JECC Exhibition Hall B, Jaipur',
      status: 'PACKING',
      unitsCount: 42,
      totalAmount: 76000.0,
    ),
    BookingItem(
      id: 'BK-8939',
      eventTitle: 'Mehta Destination Sangeet Evening',
      clientName: 'Vikram Mehta',
      category: 'Wedding',
      date: '12 Oct, 18:00 — 02:00',
      venue: 'Fairmont Jaipur, Grand Ballroom',
      status: 'CONFIRMED',
      unitsCount: 18,
      totalAmount: 34000.0,
    ),
    BookingItem(
      id: 'BK-8935',
      eventTitle: 'Indigo Autumn Fashion Gala',
      clientName: 'Sunita Singhania',
      category: 'Private',
      date: '15 Oct, 17:00 — 23:00',
      venue: 'Rambagh Palace Lawn',
      status: 'CONFIRMED',
      unitsCount: 30,
      totalAmount: 62000.0,
    ),
    BookingItem(
      id: 'BK-8930',
      eventTitle: 'Saffron Heritage Sangeet & Reception',
      clientName: 'Rohan Mehra',
      category: 'Wedding',
      date: 'Today, 11:00 — 23:00',
      venue: 'Jai Mahal Palace Lawn, Jaipur',
      status: 'DISPATCHED',
      unitsCount: 28,
      totalAmount: 52000.0,
    ),
    BookingItem(
      id: 'BK-8928',
      eventTitle: 'Rajasthan Tech Expo & Keynote',
      clientName: 'Kavita Joshi',
      category: 'Corporate',
      date: 'Yesterday — Today, 18:00',
      venue: 'JECC Convention Center, Jaipur',
      status: 'AWAITING RETURN',
      unitsCount: 36,
      totalAmount: 68000.0,
    ),
    BookingItem(
      id: 'BK-8920',
      eventTitle: 'Innovate Summit Keynote & Stage',
      clientName: 'Anand Verma',
      category: 'Corporate',
      date: '08 Oct, 09:00 — 17:00',
      venue: 'ITC Rajputana Jaipur',
      status: 'COMPLETED',
      unitsCount: 16,
      totalAmount: 29500.0,
    ),
  ];

  late final ValueNotifier<List<BookingItem>> bookingsNotifier;

  List<BookingItem> get bookings => bookingsNotifier.value;

  void addBooking(BookingItem item) {
    bookingsNotifier.value = [item, ...bookingsNotifier.value];
  }

  void updateBookingStatus(String id, String newStatus) {
    final list = bookingsNotifier.value.map((b) {
      if (b.id == id) {
        return BookingItem(
          id: b.id,
          eventTitle: b.eventTitle,
          clientName: b.clientName,
          category: b.category,
          date: b.date,
          venue: b.venue,
          status: newStatus,
          unitsCount: b.unitsCount,
          totalAmount: b.totalAmount,
        );
      }
      return b;
    }).toList();
    bookingsNotifier.value = list;
  }
}
