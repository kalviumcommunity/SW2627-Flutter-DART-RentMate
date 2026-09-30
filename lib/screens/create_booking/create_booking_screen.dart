import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/booking_draft.dart';
import '../../models/equipment_item.dart';
import '../../widgets/bookings/rentflow_search_bar.dart';
import '../../widgets/create_booking/booking_step_indicator.dart';
import '../../widgets/create_booking/booking_summary_card.dart';
import '../../widgets/create_booking/equipment_selector_tile.dart';
import '../../widgets/create_booking/event_details_form.dart';
import '../../widgets/rentflow_button.dart';
import 'equipment_conflict_screen.dart';

/// Screen 1, 2 & 4: Multi-step Create Booking wizard.
///
/// Steps:
/// 1. Event Details
/// 2. Select Equipment (with live inventory metrics and conflict prevention)
/// 3. Booking Review & Confirmation
///
/// Flutter & Dart Concepts:
/// - State retention across wizard steps without losing user draft data.
/// - Integrated conflict detection preventing double-booking before submission.
/// - Responsive scrolling layouts and interactive steppers.
class CreateBookingScreen extends StatefulWidget {
  final BookingDraft? initialDraft;

  const CreateBookingScreen({super.key, this.initialDraft});

  @override
  State<CreateBookingScreen> createState() => _CreateBookingScreenState();
}

class _CreateBookingScreenState extends State<CreateBookingScreen> {
  int _currentStep = 1; // 1: Details, 2: Equipment, 3: Review
  late BookingDraft _draft;
  final _formKey = GlobalKey<FormState>();

  // Equipment selection state
  late List<EquipmentItem> _catalog;
  final TextEditingController _equipmentSearchController =
      TextEditingController();
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _isConfirming = false;

  final List<String> _categoryFilters = const [
    'All',
    'Sound Systems',
    'Stage Lighting',
    'Video & Screens',
    'Staging',
    'Event Furniture',
    'Cables & Distro',
  ];

  @override
  void initState() {
    super.initState();
    _draft = widget.initialDraft ?? BookingDraft.initial();
    _catalog = List.of(EquipmentItem.sampleCatalog);
  }

  @override
  void dispose() {
    _equipmentSearchController.dispose();
    super.dispose();
  }

  List<EquipmentItem> get _filteredEquipment {
    return _catalog.where((item) {
      final matchesCategory =
          _selectedCategory == 'All' || item.category == _selectedCategory;
      final matchesQuery = _searchQuery.isEmpty ||
          item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.sku.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesQuery;
    }).toList();
  }

  void _onQuantityChanged(String itemId, int newQuantity) {
    setState(() {
      final updated = Map<String, int>.from(_draft.selectedQuantities);
      if (newQuantity <= 0) {
        updated.remove(itemId);
      } else {
        updated[itemId] = newQuantity;
      }
      _draft = _draft.copyWith(selectedQuantities: updated);
    });
  }

  Future<void> _openConflictScreen(EquipmentItem item, int requested) async {
    final result = await Navigator.of(context).push<ConflictAction>(
      MaterialPageRoute(
        builder: (context) => EquipmentConflictScreen(
          item: item,
          requestedQuantity: requested,
        ),
      ),
    );

    if (result != null) {
      _handleConflictResolution(item.id, result, item.availableQuantity);
    }
  }

  void _handleConflictResolution(
    String itemId,
    ConflictAction action,
    int available,
  ) {
    switch (action) {
      case ConflictAction.reduceQuantity:
        setState(() {
          final updated = Map<String, int>.from(_draft.selectedQuantities);
          if (available > 0) {
            updated[itemId] = available;
          } else {
            updated.remove(itemId);
          }
          _draft = _draft.copyWith(selectedQuantities: updated);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.alpineEvergreen,
            content: Text('Quantity adjusted to available stock ($available).'),
          ),
        );
        break;

      case ConflictAction.changeEventTime:
        setState(() => _currentStep = 1);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Adjust your event date/time schedule in Step 1.'),
          ),
        );
        break;

      case ConflictAction.joinWaitlist:
        setState(() {
          final waitlisted = Set<String>.from(_draft.waitlistedItemIds)
            ..add(itemId);
          final updated = Map<String, int>.from(_draft.selectedQuantities);
          if (available > 0) {
            updated[itemId] = available;
          }
          _draft = _draft.copyWith(
            selectedQuantities: updated,
            waitlistedItemIds: waitlisted,
          );
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.industrialAmber,
            content: Text('Shortage added to warehouse priority waitlist.'),
          ),
        );
        break;
    }
  }

  void _goToStep2() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _currentStep = 2);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.hazardCrimson,
          content: Text('Please complete required event details before continuing.'),
        ),
      );
    }
  }

  void _goToStep3() {
    if (_draft.totalItemCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.industrialAmber,
          content: Text('Please select at least 1 equipment item to proceed.'),
        ),
      );
      return;
    }

    // Check for equipment conflicts
    final conflicts = _draft.getConflictingItems(_catalog);
    if (conflicts.isNotEmpty) {
      final firstConflict = conflicts.first;
      _openConflictScreen(firstConflict.item, firstConflict.requested);
      return;
    }

    setState(() => _currentStep = 3);
  }

  Future<void> _confirmBooking() async {
    setState(() => _isConfirming = true);

    // Simulate atomic warehouse verification
    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;
    setState(() => _isConfirming = false);

    // Show booking confirmed celebration modal
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.pureWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: AppColors.successSubtle,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 40,
                  color: AppColors.successGreen,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Booking Confirmed!',
                style: AppTextStyles.brandTitle.copyWith(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'Reservation #RF-8422',
                style: AppTextStyles.monoLabel.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.alpineEvergreen,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${_draft.eventName}\n${_draft.totalItemCount} equipment units reserved and locked for ${_draft.customerName}.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              RentFlowButton(
                label: 'View in Bookings List',
                onPressed: () {
                  Navigator.of(context).pop(); // close dialog
                  Navigator.of(context).pushReplacementNamed(AppRoutes.bookings);
                },
              ),
              const SizedBox(height: 8),
              RentFlowSecondaryButton(
                label: 'Go to Dashboard',
                onPressed: () {
                  Navigator.of(context).pop(); // close dialog
                  Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      appBar: AppBar(
        title: Text(
          'Create Event Booking',
          style: AppTextStyles.screenTitle.copyWith(fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () {
            if (_currentStep > 1) {
              setState(() => _currentStep--);
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        actions: [
          // Quick sample filler button for rapid testing/demo
          TextButton(
            onPressed: () {
              setState(() {
                _draft = BookingDraft.sample();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sample event and equipment loaded.'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            child: Text(
              'Fill Sample',
              style: AppTextStyles.buttonLabel.copyWith(
                color: AppColors.alpineEvergreen,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Step Progress Indicator
            BookingStepIndicator(
              currentStep: _currentStep,
              onStepTapped: (step) {
                if (step < _currentStep) {
                  setState(() => _currentStep = step);
                }
              },
            ),

            // Step Content Area
            Expanded(
              child: _buildCurrentStepContent(),
            ),

            // Step Bottom Navigation Action Bar
            _buildBottomActionBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 1:
        return ListView(
          padding: const EdgeInsets.all(AppConstants.screenPaddingH),
          children: [
            EventDetailsForm(
              draft: _draft,
              onDraftChanged: (updated) => setState(() => _draft = updated),
              formKey: _formKey,
            ),
          ],
        );

      case 2:
        final filtered = _filteredEquipment;
        final conflicts = _draft.getConflictingItems(_catalog);

        return Column(
          children: [
            // Conflict Alert Bar at top if conflicts present
            if (conflicts.isNotEmpty)
              Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.crimsonSubtle,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFCA5A5)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: AppColors.hazardCrimson,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${conflicts.length} item(s) exceed warehouse availability!',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.hazardCrimson,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        final conflict = conflicts.first;
                        _openConflictScreen(conflict.item, conflict.requested);
                      },
                      child: Text(
                        'View Conflict',
                        style: AppTextStyles.badgeText.copyWith(
                          color: AppColors.hazardCrimson,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: RentFlowSearchBar(
                controller: _equipmentSearchController,
                hintText: 'Search equipment by name or SKU...',
                onChanged: (val) => setState(() => _searchQuery = val),
              ),
            ),

            // Category Chips Carousel
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categoryFilters.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = _categoryFilters[index];
                  final isSelected = _selectedCategory == cat;
                  return ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: AppColors.alpineEvergreen,
                    backgroundColor: AppColors.pureWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.alpineEvergreen
                            : AppColors.structuralBorder,
                      ),
                    ),
                    labelStyle: AppTextStyles.badgeText.copyWith(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedCategory = cat);
                      }
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 8),

            // Equipment Items List
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        'No equipment matches your search filter.',
                        style: AppTextStyles.bodyMedium,
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        final requested =
                            _draft.selectedQuantities[item.id] ?? 0;

                        return EquipmentSelectorTile(
                          item: item,
                          requestedQuantity: requested,
                          onQuantityChanged: (qty) =>
                              _onQuantityChanged(item.id, qty),
                          onResolveConflictTap: () =>
                              _openConflictScreen(item, requested),
                        );
                      },
                    ),
            ),
          ],
        );

      case 3:
      default:
        return ListView(
          padding: const EdgeInsets.all(AppConstants.screenPaddingH),
          children: [
            BookingSummaryCard(
              draft: _draft,
              catalog: _catalog,
              onEditDetailsTap: () => setState(() => _currentStep = 1),
              onEditEquipmentTap: () => setState(() => _currentStep = 2),
            ),
            const SizedBox(height: 16),
          ],
        );
    }
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.pureWhite,
        border: Border(
          top: BorderSide(color: AppColors.borderSubtle, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Back / Cancel Button
            if (_currentStep > 1) ...[
              Expanded(
                flex: 1,
                child: RentFlowSecondaryButton(
                  label: 'Back',
                  onPressed: () => setState(() => _currentStep--),
                ),
              ),
              const SizedBox(width: 12),
            ],

            // Step Forward / Submit Button
            Expanded(
              flex: 2,
              child: _buildForwardButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForwardButton() {
    switch (_currentStep) {
      case 1:
        return RentFlowButton(
          label: 'Next: Select Equipment',
          icon: Icons.arrow_forward_rounded,
          onPressed: _goToStep2,
        );

      case 2:
        final totalCount = _draft.totalItemCount;
        final hasConflicts = _draft.hasConflict(_catalog);

        return RentFlowButton(
          label: hasConflicts
              ? 'Resolve Conflicts'
              : 'Next: Review ($totalCount Items)',
          icon: hasConflicts
              ? Icons.warning_amber_rounded
              : Icons.arrow_forward_rounded,
          backgroundColor:
              hasConflicts ? AppColors.hazardCrimson : AppColors.alpineEvergreen,
          onPressed: _goToStep3,
        );

      case 3:
      default:
        return RentFlowButton(
          label: 'Confirm Booking',
          icon: Icons.check_circle_outline_rounded,
          isLoading: _isConfirming,
          onPressed: _confirmBooking,
        );
    }
  }
}
