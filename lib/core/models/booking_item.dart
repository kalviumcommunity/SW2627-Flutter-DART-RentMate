/// Central Booking model for RentFlow.
class BookingItem {
  final String id;
  final String eventTitle;
  final String clientName;
  final String category;
  final String date;
  final String venue;
  final String status;
  final int unitsCount;
  final double totalAmount;

  const BookingItem({
    required this.id,
    required this.eventTitle,
    required this.clientName,
    required this.category,
    required this.date,
    required this.venue,
    required this.status,
    required this.unitsCount,
    required this.totalAmount,
  });
}
