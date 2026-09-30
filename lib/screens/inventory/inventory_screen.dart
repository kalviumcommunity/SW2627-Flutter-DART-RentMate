import 'package:flutter/material.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/equipment_item.dart';
import '../../widgets/bookings/rentflow_search_bar.dart';
import '../../widgets/inventory/add_equipment_dialog.dart';
import '../../widgets/inventory/inventory_card.dart';
import '../../widgets/navigation/rentflow_bottom_nav.dart';

/// Screen 5: Warehouse & Coordinator Inventory Management.
///
/// Flutter & Dart Concepts:
/// - Reactive search, multi-faceted category and status filtering.
/// - Dynamic stock KPI calculations over local state.
/// - Clean bottom navigation tab switching with standard RentFlow shell.
class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final _searchController = TextEditingController();
  late List<EquipmentItem> _inventory;

  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedStatus = 'All';
  int _currentNavIndex = 2;

  final List<String> _categories = const [
    'All',
    'Sound Systems',
    'Stage Lighting',
    'Video & Screens',
    'Staging',
    'Event Furniture',
    'Cables & Distro',
  ];

  final List<String> _statuses = const [
    'All',
    'Available',
    'Limited',
    'Out of Stock',
  ];

  @override
  void initState() {
    super.initState();
    _inventory = List.of(EquipmentItem.sampleCatalog);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    if (index == 0) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
    } else if (index == 1) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.bookings);
    } else if (index == 3) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.dispatch);
    } else {
      setState(() => _currentNavIndex = index);
    }
  }

  List<EquipmentItem> get _filteredList {
    return _inventory.where((item) {
      final matchesQuery = _searchQuery.isEmpty ||
          item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.sku.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.category.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCategory =
          _selectedCategory == 'All' || item.category == _selectedCategory;

      final matchesStatus =
          _selectedStatus == 'All' || item.status == _selectedStatus;

      return matchesQuery && matchesCategory && matchesStatus;
    }).toList();
  }

  void _openAddEquipmentModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return AddEquipmentDialog(
          onEquipmentAdded: (newItem) {
            setState(() {
              _inventory.insert(0, newItem);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: AppColors.alpineEvergreen,
                content: Text('Added "${newItem.name}" to inventory.'),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredList;
    final totalUnits =
        _inventory.fold(0, (sum, it) => sum + it.totalQuantity);
    final availableUnits =
        _inventory.fold(0, (sum, it) => sum + it.availableQuantity);
    final limitedCount = _inventory.where((it) => it.isLimited).length;
    final outOfStockCount = _inventory.where((it) => it.isOutOfStock).length;

    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      appBar: AppBar(
        title: Text(
          'Inventory Management',
          style: AppTextStyles.screenTitle.copyWith(fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, size: 22),
            tooltip: 'Add Equipment',
            onPressed: _openAddEquipmentModal,
          ),
        ],
      ),
      bottomNavigationBar: RentFlowBottomNav(
        currentIndex: _currentNavIndex,
        onTap: _onNavTap,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddEquipmentModal,
        backgroundColor: AppColors.alpineEvergreen,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          'Add Asset',
          style: AppTextStyles.buttonLabel.copyWith(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // KPI Stock Metrics Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  _buildMetricTile(
                    label: 'Total Stock',
                    value: '$totalUnits',
                    accentColor: AppColors.textPrimary,
                  ),
                  const SizedBox(width: 8),
                  _buildMetricTile(
                    label: 'Available',
                    value: '$availableUnits',
                    accentColor: AppColors.alpineEvergreen,
                  ),
                  const SizedBox(width: 8),
                  _buildMetricTile(
                    label: 'Limited',
                    value: '$limitedCount',
                    accentColor: AppColors.industrialAmber,
                  ),
                  const SizedBox(width: 8),
                  _buildMetricTile(
                    label: 'Out of Stock',
                    value: '$outOfStockCount',
                    accentColor: AppColors.hazardCrimson,
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: RentFlowSearchBar(
                controller: _searchController,
                hintText: 'Search inventory by name, SKU, or category...',
                onChanged: (val) => setState(() => _searchQuery = val),
                onFilterTap: () {
                  setState(() {
                    _searchController.clear();
                    _searchQuery = '';
                    _selectedCategory = 'All';
                    _selectedStatus = 'All';
                  });
                },
              ),
            ),

            // Category Filter Chips Carousel
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
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

            // Status Filter Chips Row
            SizedBox(
              height: 32,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _statuses.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final st = _statuses[index];
                  final isSelected = _selectedStatus == st;
                  return FilterChip(
                    label: Text(st),
                    selected: isSelected,
                    selectedColor: AppColors.evergreenSubtle,
                    checkmarkColor: AppColors.alpineEvergreen,
                    backgroundColor: AppColors.pureWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.alpineEvergreen
                            : AppColors.borderSubtle,
                      ),
                    ),
                    labelStyle: AppTextStyles.badgeText.copyWith(
                      fontSize: 10,
                      color: isSelected
                          ? AppColors.alpineEvergreen
                          : AppColors.textSecondary,
                    ),
                    onSelected: (selected) {
                      setState(() {
                        _selectedStatus = selected ? st : 'All';
                      });
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 8),

            // Inventory List
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: const BoxDecoration(
                              color: AppColors.surfaceMuted,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.inventory_2_outlined,
                              size: 36,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No inventory items match filter',
                            style: AppTextStyles.cardTitle,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Try resetting search or adjusting category filters.',
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        return InventoryCard(
                          item: item,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${item.name} (${item.sku}) • Available: ${item.availableQuantity} of ${item.totalQuantity}',
                                ),
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

  Widget _buildMetricTile({
    required String label,
    required String value,
    required Color accentColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: AppTextStyles.badgeText.copyWith(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: AppTextStyles.monoLabel.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: accentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
