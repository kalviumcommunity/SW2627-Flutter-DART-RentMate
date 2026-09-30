import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/booking_model.dart';
import '../../widgets/bookings/booking_card.dart';
import '../../widgets/bookings/rentflow_search_bar.dart';
import '../../widgets/navigation/rentflow_bottom_nav.dart';

/// Full operational list of event equipment bookings with search and filtering.
///
/// Flutter & Dart Concepts Taught:
/// - Dynamic filtering with `setState()`: Reactive list updates based on chips and search.
/// - `ChoiceChip`: Native Flutter filtering component styled to match RentFlow brand.
/// - FloatingActionButton: Material action button with clear visual hierarchy.
/// - Empty state handling: Clean operational feedback when no results match filter.
class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  final _searchController = TextEditingController();
  String _selectedFilter = 'All';
  String _searchQuery = '';
  int _currentNavIndex = 1;

  final List<String> _filterOptions = [
    'All',
    AppConstants.statusConflict,
    AppConstants.statusConfirmed,
    AppConstants.statusPacking,
    AppConstants.statusInProgress,
    AppConstants.statusCompleted,
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    if (index == 0) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
    } else if (index == 2 || index == 3) {
      final name = index == 2 ? 'Inventory' : 'Dispatch';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$name module is owned by Prateek.')),
      );
    } else {
      setState(() => _currentNavIndex = index);
    }
  }

  List<BookingItem> get _filteredBookings {
    return BookingItem.sampleBookings.where((booking) {
      final matchesFilter = _selectedFilter == 'All' || booking.status == _selectedFilter;
      final matchesSearch = _searchQuery.isEmpty ||
          booking.eventName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          booking.venue.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          booking.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          booking.equipmentSummary.toLowerCase().contains(_searchQuery.toLowerCase());

      return matchesFilter && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredBookings;

    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      appBar: AppBar(
        title: Text(
          'Event Bookings',
          style: AppTextStyles.screenTitle.copyWith(fontSize: 20),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded, size: 20),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Date range filter will be linked with calendar.')),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: RentFlowBottomNav(
        currentIndex: _currentNavIndex,
        onTap: _onNavTap,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'New Booking wizard is part of Prateek’s create_booking feature.',
              ),
            ),
          );
        },
        backgroundColor: AppColors.alpineEvergreen,
        foregroundColor: Colors.white,
        elevation: 2,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          'New Booking',
          style: AppTextStyles.buttonLabel.copyWith(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Fixed Header Controls: Search & Filter Chips
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.screenPaddingH,
                vertical: 8.0,
              ),
              child: RentFlowSearchBar(
                controller: _searchController,
                onChanged: (val) {
                  setState(() => _searchQuery = val);
                },
                onFilterTap: () {
                  setState(() {
                    _searchController.clear();
                    _searchQuery = '';
                    _selectedFilter = 'All';
                  });
                },
              ),
            ),

            // Horizontal Filter Chips Row
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.screenPaddingH,
                ),
                itemCount: _filterOptions.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final option = _filterOptions[index];
                  final isSelected = _selectedFilter == option;
                  final isConflictOption = option == AppConstants.statusConflict;

                  return ChoiceChip(
                    label: Text(option),
                    selected: isSelected,
                    selectedColor: isConflictOption
                        ? AppColors.hazardCrimson
                        : AppColors.alpineEvergreen,
                    backgroundColor: AppColors.pureWhite,
                    labelStyle: AppTextStyles.bodySmall.copyWith(
                      color: isSelected
                          ? Colors.white
                          : (isConflictOption ? AppColors.hazardCrimson : AppColors.textPrimary),
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: isSelected
                            ? Colors.transparent
                            : (isConflictOption
                                ? AppColors.hazardCrimson.withValues(alpha: 0.4)
                                : AppColors.borderSubtle),
                      ),
                    ),
                    showCheckmark: false,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedFilter = option);
                      }
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // Results Count Indicator
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.screenPaddingH,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Showing ${filtered.length} bookings',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (_selectedFilter != 'All' || _searchQuery.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedFilter = 'All';
                          _searchQuery = '';
                          _searchController.clear();
                        });
                      },
                      child: Text(
                        'Reset Filters',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.alpineEvergreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Scrollable Bookings List
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceMuted,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.search_off_rounded,
                                size: 36,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No bookings match your filter',
                              style: AppTextStyles.cardTitle,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Try adjusting your search terms or select "All" from the status filter bar.',
                              style: AppTextStyles.bodySmall,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        AppConstants.screenPaddingH,
                        4,
                        AppConstants.screenPaddingH,
                        80, // Bottom padding to account for FAB
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final booking = filtered[index];
                        return BookingCard(
                          booking: booking,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Opening details for ${booking.id}'),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
