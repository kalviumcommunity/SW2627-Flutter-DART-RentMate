import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/dispatch_item.dart';
import '../../widgets/dispatch/dispatch_checklist_tile.dart';
import '../../widgets/dispatch/dispatch_event_header.dart';
import '../../widgets/dispatch/dispatch_progress_bar.dart';
import '../../widgets/navigation/rentflow_bottom_nav.dart';
import '../../widgets/rentflow_button.dart';

/// Screen 6: Warehouse Dispatch Checklist & Manifest Loading Dock.
///
/// Flutter & Dart Concepts:
/// - Reactive checklist state: Toggling packed state immediately updates progress calculation.
/// - Segmented filter tabs (All Items, Packed, Pending).
/// - Multi-event switching for busy warehouse dock supervisors.
/// - Modal verification workflow before committing "Mark as Loaded".
class DispatchScreen extends StatefulWidget {
  const DispatchScreen({super.key});

  @override
  State<DispatchScreen> createState() => _DispatchScreenState();
}

class _DispatchScreenState extends State<DispatchScreen> {
  int _currentNavIndex = 3;
  String _selectedTab = 'All Items';
  late List<DispatchItem> _items;

  // Active event state
  int _selectedEventIndex = 0;
  final List<Map<String, String>> _events = const [
    {
      'name': 'Royal Heritage Wedding Sangeet',
      'venue': 'Fairmont Palace Ballroom, Jaipur',
      'schedule': 'Departure: 02:00 PM Today • Event: 04:00 PM',
      'dock': 'Loading Dock #2',
    },
    {
      'name': 'National FinTech Conclave 2026',
      'venue': 'JECC Convention Hall A, Sitapura',
      'schedule': 'Departure: 06:00 AM Tomorrow • Event: 08:00 AM',
      'dock': 'Loading Dock #1',
    },
  ];

  @override
  void initState() {
    super.initState();
    _items = List.of(DispatchItem.sampleManifest);
  }

  void _onNavTap(int index) {
    if (index == 0) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
    } else if (index == 1) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.bookings);
    } else if (index == 2) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.inventory);
    } else {
      setState(() => _currentNavIndex = index);
    }
  }

  void _togglePacked(String itemId, bool newValue) {
    setState(() {
      final index = _items.indexWhere((it) => it.id == itemId);
      if (index != -1) {
        _items[index] = _items[index].copyWith(isPacked: newValue);
      }
    });
  }

  List<DispatchItem> get _filteredItems {
    if (_selectedTab == 'Packed') {
      return _items.where((it) => it.isPacked).toList();
    } else if (_selectedTab == 'Pending') {
      return _items.where((it) => !it.isPacked).toList();
    }
    return _items;
  }

  void _showEventPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.pureWhite,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.structuralBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Select Active Dispatch Dock',
                style: AppTextStyles.brandTitle.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 12),
              ...List.generate(_events.length, (idx) {
                final ev = _events[idx];
                final isCurrent = _selectedEventIndex == idx;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: isCurrent
                        ? AppColors.evergreenSubtle
                        : AppColors.surfaceMuted,
                    child: Icon(
                      Icons.local_shipping_rounded,
                      color: isCurrent
                          ? AppColors.alpineEvergreen
                          : AppColors.textSecondary,
                    ),
                  ),
                  title: Text(ev['name']!, style: AppTextStyles.cardTitle),
                  subtitle: Text('${ev['dock']} • ${ev['schedule']}',
                      style: AppTextStyles.bodySmall),
                  trailing: isCurrent
                      ? const Icon(Icons.check_circle_rounded,
                          color: AppColors.alpineEvergreen)
                      : null,
                  onTap: () {
                    setState(() => _selectedEventIndex = idx);
                    Navigator.of(context).pop();
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _markAsLoaded() {
    final packedCount = _items.where((it) => it.isPacked).length;
    final totalCount = _items.length;
    final allPacked = packedCount == totalCount;

    if (!allPacked) {
      showDialog(
        context: context,
        builder: (context) {
          final pendingCount = totalCount - packedCount;
          return AlertDialog(
            backgroundColor: AppColors.pureWhite,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.industrialAmber,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Incomplete Manifest',
                  style: AppTextStyles.cardTitle.copyWith(fontSize: 16),
                ),
              ],
            ),
            content: Text(
              '$pendingCount item(s) are still marked as PENDING in the warehouse staging area.\n\nDo you want to confirm a Partial Dispatch or finish packing all items?',
              style: AppTextStyles.bodyMedium,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Back to Checklist'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showDispatchSuccessDialog(isPartial: true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.industrialAmber,
                ),
                child: const Text('Confirm Partial Dispatch'),
              ),
            ],
          );
        },
      );
    } else {
      _showDispatchSuccessDialog(isPartial: false);
    }
  }

  void _showDispatchSuccessDialog({required bool isPartial}) {
    showDialog(
      context: context,
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
                decoration: BoxDecoration(
                  color: isPartial
                      ? AppColors.amberSubtle
                      : AppColors.successSubtle,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPartial
                      ? Icons.local_shipping_rounded
                      : Icons.check_circle_rounded,
                  size: 40,
                  color: isPartial
                      ? AppColors.industrialAmber
                      : AppColors.successGreen,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isPartial ? 'Partial Dispatch Confirmed' : 'Truck Loaded & Dispatched!',
                style: AppTextStyles.brandTitle.copyWith(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Manifest #${_selectedEventIndex == 0 ? "DSP-8421" : "DSP-8419"}',
                style: AppTextStyles.monoLabel.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.alpineEvergreen,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${_events[_selectedEventIndex]['name']}\nEquipment transferred to carrier vehicle at ${_events[_selectedEventIndex]['dock']}.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              RentFlowButton(
                label: 'Return to Operations Dashboard',
                onPressed: () {
                  Navigator.of(context).pop();
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
    final currentEvent = _events[_selectedEventIndex];
    final packedCount = _items.where((it) => it.isPacked).length;
    final totalCount = _items.length;
    final filtered = _filteredItems;

    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      appBar: AppBar(
        title: Text(
          'Warehouse Dispatch',
          style: AppTextStyles.screenTitle.copyWith(fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync_rounded, size: 20),
            tooltip: 'Refresh Manifest',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Manifest refreshed from warehouse stock dock.'),
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: RentFlowBottomNav(
        currentIndex: _currentNavIndex,
        onTap: _onNavTap,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppConstants.screenPaddingH),
                children: [
                  // Event Header
                  DispatchEventHeader(
                    eventName: currentEvent['name']!,
                    venue: currentEvent['venue']!,
                    schedule: currentEvent['schedule']!,
                    loadingDock: currentEvent['dock']!,
                    onSwitchEvent: _showEventPicker,
                  ),
                  const SizedBox(height: 12),

                  // Progress Bar
                  DispatchProgressBar(
                    packedCount: packedCount,
                    totalCount: totalCount,
                  ),
                  const SizedBox(height: 16),

                  // Tabs: All Items / Packed / Pending
                  Row(
                    children: [
                      _buildTabChip('All Items', totalCount),
                      const SizedBox(width: 8),
                      _buildTabChip('Packed', packedCount),
                      const SizedBox(width: 8),
                      _buildTabChip('Pending', totalCount - packedCount),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Checklist Items List
                  if (filtered.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: Text(
                          'No items in this category.',
                          style: AppTextStyles.bodyMedium,
                        ),
                      ),
                    )
                  else
                    ...List.generate(filtered.length, (idx) {
                      final item = filtered[idx];
                      return DispatchChecklistTile(
                        item: item,
                        onTogglePacked: (val) => _togglePacked(item.id, val),
                      );
                    }),
                ],
              ),
            ),

            // Bottom CTA: Mark as Loaded
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: AppColors.pureWhite,
                border: Border(
                  top: BorderSide(color: AppColors.borderSubtle, width: 1),
                ),
              ),
              child: SafeArea(
                top: false,
                child: RentFlowButton(
                  label: packedCount == totalCount
                      ? 'Mark as Loaded & Dispatch'
                      : 'Mark as Loaded ($packedCount/$totalCount Packed)',
                  icon: Icons.local_shipping_rounded,
                  backgroundColor: packedCount == totalCount
                      ? AppColors.alpineEvergreen
                      : AppColors.industrialAmber,
                  onPressed: _markAsLoaded,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabChip(String label, int count) {
    final isSelected = _selectedTab == label;

    return ChoiceChip(
      label: Text('$label ($count)'),
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
        fontSize: 11,
        color: isSelected ? Colors.white : AppColors.textPrimary,
      ),
      onSelected: (selected) {
        if (selected) setState(() => _selectedTab = label);
      },
    );
  }
}
