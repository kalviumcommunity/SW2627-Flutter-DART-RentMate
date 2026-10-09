import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'booking_details_screen.dart';
import 'create_booking_screen.dart';

/// Booking item data for pure UI display
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

/// Bookings List Screen (RentFlow Section 5.4).
///
/// Features:
/// - Search bar for event title, client name, and booking ID.
/// - Filter chips: All, Upcoming, Ongoing, Completed.
/// - Rich event summary cards with Industrial Atelier styling.
/// - Floating Action Button for starting the 3-step Create Booking wizard.
class BookingsListScreen extends StatefulWidget {
  const BookingsListScreen({super.key});

  @override
  State<BookingsListScreen> createState() => _BookingsListScreenState();
}

class _BookingsListScreenState extends State<BookingsListScreen> {
  String _selectedFilter = 'All';
  String _searchQuery = '';

  final List<BookingItem> _bookings = const [
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

  @override
  Widget build(BuildContext context) {
    final filteredList = _bookings.where((b) {
      final matchesFilter = _selectedFilter == 'All' ||
          (_selectedFilter == 'Upcoming' && (b.status == 'CONFIRMED' || b.status == 'PACKING' || b.status == 'READY')) ||
          (_selectedFilter == 'Ongoing' && b.status == 'DISPATCHED') ||
          (_selectedFilter == 'Completed' && b.status == 'COMPLETED');

      final matchesSearch = _searchQuery.isEmpty ||
          b.eventTitle.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          b.clientName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          b.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          b.venue.toLowerCase().contains(_searchQuery.toLowerCase());

      return matchesFilter && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.bone,
      appBar: AppBar(
        backgroundColor: AppColors.bone,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Event Bookings',
          style: AppTextStyles.brandTitle.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded, color: AppColors.inkBlack),
            onPressed: () {},
            tooltip: 'Filter options',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search & Filter Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                children: [
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.paper,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.softStone),
                    ),
                    child: TextField(
                      onChanged: (val) => setState(() => _searchQuery = val),
                      style: AppTextStyles.bodyMedium,
                      decoration: InputDecoration(
                        hintText: 'Search by event, client, or #BK...',
                        prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.slate),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                onPressed: () => setState(() => _searchQuery = ''),
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('All', _bookings.length),
                        _buildFilterChip('Upcoming', 4),
                        _buildFilterChip('Ongoing', 0),
                        _buildFilterChip('Completed', 1),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Bookings List View
            Expanded(
              child: filteredList.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        return _buildBookingCard(filteredList[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateBookingScreen()),
          );
        },
        backgroundColor: AppColors.burntCopper,
        foregroundColor: Colors.white,
        elevation: 2,
        icon: const Icon(Icons.add_rounded, size: 20),
        label: Text(
          'New Booking',
          style: AppTextStyles.buttonText.copyWith(fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, int count) {
    final isSelected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text('$label ($count)'),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) setState(() => _selectedFilter = label);
        },
        backgroundColor: AppColors.paper,
        selectedColor: AppColors.inkBlack,
        labelStyle: AppTextStyles.monoLabel.copyWith(
          fontSize: 10,
          color: isSelected ? AppColors.bone : AppColors.inkBlack,
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: BorderSide(
            color: isSelected ? AppColors.inkBlack : AppColors.softStone,
          ),
        ),
        showCheckmark: false,
      ),
    );
  }

  Widget _buildBookingCard(BookingItem item) {
    Color statusBg;
    Color statusFg;

    switch (item.status) {
      case 'READY':
        statusBg = AppColors.successSubtle;
        statusFg = AppColors.success;
        break;
      case 'PACKING':
        statusBg = AppColors.warningSubtle;
        statusFg = AppColors.warning;
        break;
      case 'CONFIRMED':
        statusBg = AppColors.copperSubtle;
        statusFg = AppColors.burntCopper;
        break;
      default:
        statusBg = AppColors.bone;
        statusFg = AppColors.slate;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.softStone),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookingDetailsScreen(
                bookingId: item.id,
                eventTitle: item.eventTitle,
                clientName: item.clientName,
                venue: item.venue,
                dates: item.date,
                status: item.status,
                totalItems: item.unitsCount,
                grandTotal: item.totalAmount,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Metadata Row (Category, ID, Status)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.bone,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.category.toUpperCase(),
                          style: AppTextStyles.monoLabel.copyWith(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppColors.slate,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item.id,
                        style: AppTextStyles.monoLabel.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.inkBlack,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item.status,
                      style: AppTextStyles.monoLabel.copyWith(
                        fontSize: 9,
                        color: statusFg,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Event Title
              Text(
                item.eventTitle,
                style: AppTextStyles.cardTitle.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),

              // Venue & Schedule
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 14, color: AppColors.burntCopper),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item.venue,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.inkBlack,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.calendar_month_outlined, size: 14, color: AppColors.slate),
                  const SizedBox(width: 6),
                  Text(
                    item.date,
                    style: AppTextStyles.monoData.copyWith(
                      fontSize: 11,
                      color: AppColors.slate,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              const Divider(color: AppColors.bone, height: 1),
              const SizedBox(height: 10),

              // Bottom metrics & Client name
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person_outline_rounded, size: 14, color: AppColors.slate),
                      const SizedBox(width: 6),
                      Text(
                        item.clientName,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.inkBlack,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        '${item.unitsCount} units',
                        style: AppTextStyles.monoLabel.copyWith(
                          fontSize: 11,
                          color: AppColors.slate,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '₹${item.totalAmount.toInt()}',
                        style: AppTextStyles.monoData.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.burntCopper,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.event_busy_rounded, size: 48, color: AppColors.slate),
            const SizedBox(height: 12),
            Text(
              'No Bookings Found',
              style: AppTextStyles.screenTitle.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 4),
            Text(
              'No events matching your search or filter criteria.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.slate),
            ),
          ],
        ),
      ),
    );
  }
}
