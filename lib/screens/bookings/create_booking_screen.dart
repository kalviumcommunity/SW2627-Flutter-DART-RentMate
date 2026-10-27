import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/booking_item.dart';
import '../../core/models/equipment_item.dart';
import '../../core/services/availability_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/rentflow_button.dart';
import '../../widgets/rentflow_text_field.dart';
import 'booking_conflict_sheet.dart';

/// Equipment Catalog item model for pure UI state demonstration
class EquipmentCatalogItem {
  final String id;
  final String name;
  final String sku;
  final String category;
  final int totalQty;
  final int availableQty;
  final double dailyRate;
  final IconData icon;
  int selectedQty;

  EquipmentCatalogItem({
    required this.id,
    required this.name,
    required this.sku,
    required this.category,
    required this.totalQty,
    required this.availableQty,
    required this.dailyRate,
    required this.icon,
    this.selectedQty = 0,
  });

  factory EquipmentCatalogItem.fromEquipmentItem(EquipmentItem item, {int selectedQty = 0}) {
    return EquipmentCatalogItem(
      id: item.id,
      name: item.name,
      sku: item.sku,
      category: item.category,
      totalQty: item.total,
      availableQty: item.available,
      dailyRate: item.dailyRate,
      icon: item.icon ?? Icons.inventory_2_outlined,
      selectedQty: selectedQty,
    );
  }

  EquipmentItem toEquipmentItem() {
    return EquipmentItem(
      id: id,
      sku: sku,
      name: name,
      category: category,
      total: totalQty,
      available: availableQty,
      deployed: 0,
      dailyRate: dailyRate,
      status: 'IN WAREHOUSE',
      specs: '',
      icon: icon,
    );
  }
}

/// Create Booking Multi-Step Wizard (RentFlow Section 5.5 - 5.8).
///
/// Features:
/// - Step 1: Event & Customer Details (Venue, Dates, Type, Logistics notes).
/// - Step 2: Equipment Selection with Category filters, Stock indicators, and Conflict preview.
/// - Step 3: Booking Review, Cost Breakdown & Reservation Confirmation.
class CreateBookingScreen extends StatefulWidget {
  const CreateBookingScreen({super.key});

  @override
  State<CreateBookingScreen> createState() => _CreateBookingScreenState();
}

class _CreateBookingScreenState extends State<CreateBookingScreen> {
  int _currentStep = 1; // 1: Details, 2: Equipment, 3: Review
  bool _isSubmitting = false;

  // Step 1 Controllers & State
  final _eventNameController = TextEditingController();
  final _clientNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _venueController = TextEditingController();
  final _notesController = TextEditingController();
  
  String _selectedEventType = 'Wedding';
  DateTime _startDate = DateTime.now().add(const Duration(days: 3));
  DateTime _endDate = DateTime.now().add(const Duration(days: 4));
  TimeOfDay _dispatchTime = const TimeOfDay(hour: 10, minute: 0);
  TimeOfDay _returnTime = const TimeOfDay(hour: 23, minute: 30);

  // Step 2 Catalog State
  String _selectedCategory = 'All';
  String _equipmentSearchQuery = '';

  late List<EquipmentCatalogItem> _catalog;

  @override
  void initState() {
    super.initState();
    _catalog = [
      EquipmentCatalogItem(
        id: 'eq-1',
        name: 'JBL VRX932LA Line Array Speaker',
        sku: 'SND-JBL-VRX932',
        category: 'Audio',
        totalQty: 16,
        availableQty: 8,
        dailyRate: 1500.0,
        icon: Icons.speaker_rounded,
        selectedQty: 0,
      ),
      EquipmentCatalogItem(
        id: 'eq-2',
        name: 'Sharpy 230W 7R Beam Moving Head',
        sku: 'LGT-SHARPY-230',
        category: 'Lighting',
        totalQty: 24,
        availableQty: 12,
        dailyRate: 850.0,
        icon: Icons.highlight_rounded,
        selectedQty: 0,
      ),
      EquipmentCatalogItem(
        id: 'eq-3',
        name: 'P3.91 High-Res LED Video Wall Panel (500x500mm)',
        sku: 'VIS-LED-P391',
        category: 'Video & LED',
        totalQty: 40,
        availableQty: 20,
        dailyRate: 1200.0,
        icon: Icons.tv_rounded,
        selectedQty: 0,
      ),
      EquipmentCatalogItem(
        id: 'eq-4',
        name: 'Heavy Duty Aluminum Box Truss (3m x 290mm)',
        sku: 'STG-TRS-3M',
        category: 'Rigging & Staging',
        totalQty: 30,
        availableQty: 14,
        dailyRate: 600.0,
        icon: Icons.grid_view_rounded,
        selectedQty: 0,
      ),
      EquipmentCatalogItem(
        id: 'eq-5',
        name: 'Shure ULXD4 Wireless Dual Mic Set',
        sku: 'SND-SHURE-ULXD',
        category: 'Audio',
        totalQty: 10,
        availableQty: 5,
        dailyRate: 950.0,
        icon: Icons.mic_rounded,
        selectedQty: 0,
      ),
      EquipmentCatalogItem(
        id: 'eq-6',
        name: '62.5 kVA Silent Diesel Generator Unit',
        sku: 'PWR-GEN-62KVA',
        category: 'Power & Control',
        totalQty: 4,
        availableQty: 2,
        dailyRate: 4500.0,
        icon: Icons.bolt_rounded,
        selectedQty: 0,
      ),
    ];
  }

  @override
  void dispose() {
    _eventNameController.dispose();
    _clientNameController.dispose();
    _phoneController.dispose();
    _venueController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // Calculation helpers
  int get _rentalDays {
    final start = DateTime(_startDate.year, _startDate.month, _startDate.day);
    final end = DateTime(_endDate.year, _endDate.month, _endDate.day);
    if (end.isBefore(start)) return 1;
    return end.difference(start).inDays + 1;
  }

  int get _totalSelectedItems =>
      _catalog.fold(0, (sum, item) => sum + item.selectedQty);

  double get _totalDailyRental =>
      _catalog.fold(0.0, (sum, item) => sum + (item.selectedQty * item.dailyRate)) *
      _rentalDays;

  double get _securityDeposit => _totalDailyRental * 0.25;
  double get _logisticsFee => 2500.0;
  double get _grandTotal => _totalDailyRental + _securityDeposit + _logisticsFee;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bone,
      appBar: AppBar(
        backgroundColor: AppColors.bone,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppColors.inkBlack),
          onPressed: () {
            if (_currentStep > 1) {
              setState(() => _currentStep--);
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create New Booking',
              style: AppTextStyles.cardTitle.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 17,
              ),
            ),
            Text(
              'STEP $_currentStep OF 3: ${_getStepTitle()}',
              style: AppTextStyles.monoLabel.copyWith(
                fontSize: 10,
                color: AppColors.burntCopper,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded, color: AppColors.slate),
            onPressed: () => Navigator.pop(context),
            tooltip: 'Close Wizard',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: _buildProgressBar(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: _buildCurrentStepView(),
              ),
            ),
            _buildBottomActionBar(),
          ],
        ),
      ),
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 1:
        return 'EVENT DETAILS';
      case 2:
        return 'EQUIPMENT SELECTION';
      case 3:
        return 'REVIEW & CONFIRM';
      default:
        return '';
    }
  }

  Widget _buildProgressBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 3,
            color: _currentStep >= 1 ? AppColors.burntCopper : AppColors.softStone,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Container(
            height: 3,
            color: _currentStep >= 2 ? AppColors.burntCopper : AppColors.softStone,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Container(
            height: 3,
            color: _currentStep >= 3 ? AppColors.burntCopper : AppColors.softStone,
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentStepView() {
    switch (_currentStep) {
      case 1:
        return _buildStep1EventDetails();
      case 2:
        return _buildStep2EquipmentSelection();
      case 3:
        return _buildStep3Review();
      default:
        return const SizedBox.shrink();
    }
  }

  // ===========================================================================
  // STEP 1: EVENT DETAILS
  // ===========================================================================
  Widget _buildStep1EventDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: Icons.event_note_rounded,
          title: 'Event & Client Information',
          subtitle: 'Specify primary client and venue parameters for schedule mapping.',
        ),
        const SizedBox(height: 18),

        // Event Name
        RentFlowTextField(
          label: 'EVENT TITLE',
          hintText: 'e.g. Royal Palace Wedding Reception',
          controller: _eventNameController,
          prefixIcon: Icons.celebration_outlined,
        ),
        const SizedBox(height: 14),

        // Event Type Selector
        Text(
          'EVENT CATEGORY',
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.inkBlack,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['Wedding', 'Corporate', 'Private Party', 'Concert / Festival', 'Exhibition'].map((type) {
            final isSelected = _selectedEventType == type;
            return ChoiceChip(
              label: Text(type),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) setState(() => _selectedEventType = type);
              },
              backgroundColor: AppColors.paper,
              selectedColor: AppColors.inkBlack,
              labelStyle: AppTextStyles.bodySmall.copyWith(
                color: isSelected ? AppColors.bone : AppColors.inkBlack,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
                side: BorderSide(
                  color: isSelected ? AppColors.inkBlack : AppColors.softStone,
                ),
              ),
              showCheckmark: false,
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        // Customer Details Row
        Row(
          children: [
            Expanded(
              child: RentFlowTextField(
                label: 'CLIENT NAME',
                hintText: 'e.g. Rajesh Sharma',
                controller: _clientNameController,
                prefixIcon: Icons.person_outline_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: RentFlowTextField(
                label: 'CONTACT NUMBER',
                hintText: '+91 98765 43210',
                controller: _phoneController,
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Venue Address
        RentFlowTextField(
          label: 'VENUE / DESTINATION',
          hintText: 'e.g. The Oberoi Rajvilas, Jaipur',
          controller: _venueController,
          prefixIcon: Icons.location_on_outlined,
        ),
        const SizedBox(height: 18),

        // Schedule & Date Selection Card
        _buildSchedulePickerCard(),
        const SizedBox(height: 18),

        // Logistics Notes
        RentFlowTextField(
          label: 'OPERATIONAL NOTES & SPECIAL INSTRUCTIONS',
          hintText: 'Enter setup requirements, gate entry passes or sound limits...',
          controller: _notesController,
          prefixIcon: Icons.notes_rounded,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSchedulePickerCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.softStone),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_month_outlined, size: 18, color: AppColors.burntCopper),
              const SizedBox(width: 8),
              Text(
                'RENTAL DATES & DISPATCH TIMELINE',
                style: AppTextStyles.monoLabel.copyWith(
                  fontSize: 11,
                  color: AppColors.inkBlack,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Date selection row
          Row(
            children: [
              Expanded(
                child: _buildDateTimePickerTile(
                  label: 'DISPATCH / START',
                  dateText: '${_startDate.day} ${_getMonthName(_startDate.month)} ${_startDate.year}',
                  timeText: _dispatchTime.format(context),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _startDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null && mounted) {
                      final pickedTime = await showTimePicker(
                        context: context,
                        initialTime: _dispatchTime,
                      );
                      if (!mounted) return;
                      setState(() {
                        _startDate = picked;
                        if (pickedTime != null) _dispatchTime = pickedTime;
                        // Auto-adjust end date if start date is picked after end date
                        if (_startDate.isAfter(_endDate)) {
                          _endDate = _startDate.add(const Duration(days: 1));
                        }
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDateTimePickerTile(
                  label: 'RETURN / END',
                  dateText: '${_endDate.day} ${_getMonthName(_endDate.month)} ${_endDate.year}',
                  timeText: _returnTime.format(context),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _endDate,
                      firstDate: _startDate,
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null && mounted) {
                      final pickedTime = await showTimePicker(
                        context: context,
                        initialTime: _returnTime,
                      );
                      if (!mounted) return;
                      setState(() {
                        _endDate = picked;
                        if (pickedTime != null) _returnTime = pickedTime;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimePickerTile({
    required String label,
    required String dateText,
    required String timeText,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.bone,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.softStone),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.monoLabel.copyWith(fontSize: 9, color: AppColors.slate),
            ),
            const SizedBox(height: 6),
            Text(
              dateText,
              style: AppTextStyles.cardTitle.copyWith(fontSize: 13, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(Icons.access_time_rounded, size: 12, color: AppColors.burntCopper),
                const SizedBox(width: 4),
                Text(
                  timeText,
                  style: AppTextStyles.monoData.copyWith(fontSize: 11, color: AppColors.slate),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // STEP 2: EQUIPMENT SELECTION & INVENTORY CATALOG
  // ===========================================================================
  Widget _buildStep2EquipmentSelection() {
    final filteredCatalog = _catalog.where((item) {
      final matchesCategory = AppConstants.categoryMatches(item.category, _selectedCategory);
      final matchesSearch = _equipmentSearchQuery.isEmpty ||
          item.name.toLowerCase().contains(_equipmentSearchQuery.toLowerCase()) ||
          item.sku.toLowerCase().contains(_equipmentSearchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: Icons.inventory_2_outlined,
          title: 'Select Equipment Catalog',
          subtitle: 'Available inventory calculated for ${_startDate.day} ${_getMonthName(_startDate.month)} — ${_endDate.day} ${_getMonthName(_endDate.month)}.',
        ),
        const SizedBox(height: 14),

        // Search Bar
        Container(
          decoration: BoxDecoration(
            color: AppColors.paper,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.softStone),
          ),
          child: TextField(
            onChanged: (val) => setState(() => _equipmentSearchQuery = val),
            style: AppTextStyles.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Search equipment name or SKU...',
              prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.slate),
              suffixIcon: _equipmentSearchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      onPressed: () => setState(() => _equipmentSearchQuery = ''),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Category Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: AppConstants.equipmentCategories.map((cat) {
              final isSelected = _selectedCategory == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (val) => setState(() => _selectedCategory = cat),
                  backgroundColor: AppColors.paper,
                  selectedColor: AppColors.burntCopper,
                  labelStyle: AppTextStyles.bodySmall.copyWith(
                    color: isSelected ? Colors.white : AppColors.inkBlack,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                    side: BorderSide(
                      color: isSelected ? AppColors.burntCopper : AppColors.softStone,
                    ),
                  ),
                  showCheckmark: false,
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 14),

        // Conflict Simulation Demo Banner
        InkWell(
          onTap: () {
            BookingConflictSheet.show(
              context,
              equipmentName: 'JBL VRX932LA Line Array Speaker',
              sku: 'SND-JBL-VRX932',
              requestedQty: 14,
              availableQty: 8,
              conflictingEvent: 'Apex Tech Annual Summit (BK-4091)',
              onReduceQuantity: () {
                setState(() {
                  final item = _catalog.firstWhere((e) => e.sku == 'SND-JBL-VRX932');
                  item.selectedQty = item.availableQty;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Quantity reduced to available limit (8 Units).')),
                );
              },
            );
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.warningSubtle,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.agedBrass.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.science_outlined, size: 18, color: AppColors.agedBrass),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Preview Conflict Engine UI (Click to test shortage modal)',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.inkBlack,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.agedBrass),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Equipment List Cards
        ...filteredCatalog.map((item) => _buildEquipmentCatalogCard(item)),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildEquipmentCatalogCard(EquipmentCatalogItem item) {
    final isSelected = item.selectedQty > 0;
    final isMaxReached = item.selectedQty >= item.availableQty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected ? AppColors.burntCopper : AppColors.softStone,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Container
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.copperSubtle : AppColors.bone,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              item.icon,
              color: isSelected ? AppColors.burntCopper : AppColors.inkBlack,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),

          // Details Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: AppTextStyles.cardTitle.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.bone,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.sku,
                        style: AppTextStyles.monoLabel.copyWith(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '₹${item.dailyRate.toInt()}/day',
                      style: AppTextStyles.monoData.copyWith(
                        fontSize: 12,
                        color: AppColors.burntCopper,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Availability Badge & Qty Stepper
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isMaxReached ? AppColors.warningSubtle : AppColors.successSubtle,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isMaxReached ? AppColors.warning : AppColors.success,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${item.availableQty} Avail / ${item.totalQty} Total',
                            style: AppTextStyles.monoLabel.copyWith(
                              fontSize: 9,
                              color: isMaxReached ? AppColors.warning : AppColors.success,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Counter Stepper Controls
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.bone,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.softStone),
                      ),
                      child: Row(
                        children: [
                          _buildStepperButton(
                            icon: Icons.remove,
                            onTap: item.selectedQty > 0
                                ? () => setState(() => item.selectedQty--)
                                : null,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              '${item.selectedQty}',
                              style: AppTextStyles.monoData.copyWith(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: isSelected ? AppColors.burntCopper : AppColors.inkBlack,
                              ),
                            ),
                          ),
                          _buildStepperButton(
                            icon: Icons.add,
                            onTap: () {
                              final check = AvailabilityService().checkAvailability(
                                startDate: _startDate,
                                endDate: _endDate,
                                requestedItems: [
                                  {
                                    'id': item.id,
                                    'sku': item.sku,
                                    'name': item.name,
                                    'quantity': item.selectedQty + 1,
                                    'totalQty': item.totalQty,
                                    'availableQty': item.availableQty,
                                  }
                                ],
                              );

                              if (check.isAvailable) {
                                setState(() => item.selectedQty++);
                              } else {
                                final conflict = check.conflicts.first;
                                BookingConflictSheet.show(
                                  context,
                                  equipmentName: item.name,
                                  sku: item.sku,
                                  requestedQty: item.selectedQty + 1,
                                  availableQty: conflict.availableQty,
                                  conflictingEvent: conflict.conflictingEvent,
                                  onReduceQuantity: () {
                                    setState(() {
                                      item.selectedQty = conflict.availableQty;
                                    });
                                  },
                                  onChangeTime: () {
                                    setState(() {
                                      _currentStep = 1;
                                    });
                                  },
                                  onJoinWaitlist: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: AppColors.inkBlack,
                                        content: Text(
                                          'Waitlist request logged for ${item.name} (${item.sku}). Operations notified.',
                                          style: const TextStyle(color: AppColors.bone),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepperButton({required IconData icon, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.all(6),
        child: Icon(
          icon,
          size: 14,
          color: onTap != null ? AppColors.inkBlack : AppColors.softStone,
        ),
      ),
    );
  }

  // ===========================================================================
  // STEP 3: BOOKING REVIEW & ESTIMATE CONFIRMATION
  // ===========================================================================
  Widget _buildStep3Review() {
    final selectedItems = _catalog.where((item) => item.selectedQty > 0).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: Icons.verified_rounded,
          title: 'Review & Verify Reservation',
          subtitle: 'Verify schedule parameters, equipment manifest, and pricing breakdown before final locking.',
        ),
        const SizedBox(height: 16),

        // Availability Verified Badge
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.successSubtle,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AVAILABILITY VERIFIED FOR $_rentalDays ${_rentalDays == 1 ? "DAY" : "DAYS"}',
                      style: AppTextStyles.monoLabel.copyWith(
                        fontSize: 10,
                        color: AppColors.success,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'All $_totalSelectedItems units confirmed available from ${_startDate.day}/${_startDate.month} to ${_endDate.day}/${_endDate.month}.',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 11,
                        color: AppColors.inkBlack,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Event Summary Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.paper,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.softStone),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'EVENT PARAMETERS',
                    style: AppTextStyles.monoLabel.copyWith(
                      fontSize: 10,
                      color: AppColors.slate,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  InkWell(
                    onTap: () => setState(() => _currentStep = 1),
                    child: Text(
                      'EDIT',
                      style: AppTextStyles.monoLabel.copyWith(
                        fontSize: 10,
                        color: AppColors.burntCopper,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                _eventNameController.text,
                style: AppTextStyles.cardTitle.copyWith(fontWeight: FontWeight.w800, fontSize: 16),
              ),
              const SizedBox(height: 6),
              _buildReviewInfoRow(Icons.person_rounded, 'Client', _clientNameController.text),
              _buildReviewInfoRow(Icons.phone_rounded, 'Phone', _phoneController.text),
              _buildReviewInfoRow(Icons.location_on_rounded, 'Venue', _venueController.text),
              _buildReviewInfoRow(
                Icons.calendar_month_rounded,
                'Schedule',
                '${_startDate.day} ${_getMonthName(_startDate.month)} — ${_endDate.day} ${_getMonthName(_endDate.month)} (${_dispatchTime.format(context)} to ${_returnTime.format(context)})',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Reserved Equipment Manifest Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.paper,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.softStone),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'RESERVED EQUIPMENT (${selectedItems.length} ITEMS)',
                    style: AppTextStyles.monoLabel.copyWith(
                      fontSize: 10,
                      color: AppColors.slate,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  InkWell(
                    onTap: () => setState(() => _currentStep = 2),
                    child: Text(
                      'MODIFY',
                      style: AppTextStyles.monoLabel.copyWith(
                        fontSize: 10,
                        color: AppColors.burntCopper,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...selectedItems.map((item) {
                final itemSubtotal = item.selectedQty * item.dailyRate * _rentalDays;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.copperSubtle,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${item.selectedQty}x',
                          style: AppTextStyles.monoLabel.copyWith(
                            fontSize: 11,
                            color: AppColors.burntCopper,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.inkBlack,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (_rentalDays > 1)
                              Text(
                                '₹${item.dailyRate.toInt()}/day × $_rentalDays days',
                                style: AppTextStyles.bodySmall.copyWith(
                                  fontSize: 10,
                                  color: AppColors.slate,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Text(
                        '₹${itemSubtotal.toInt()}',
                        style: AppTextStyles.monoData.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Financial Breakdown Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.inkBlack,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ESTIMATED BILLING SUMMARY',
                style: AppTextStyles.monoLabel.copyWith(
                  fontSize: 10,
                  color: AppColors.bone.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              _buildDarkPriceRow(
                _rentalDays > 1
                    ? 'Base Equipment Rental ($_rentalDays Days)'
                    : 'Base Equipment Daily Rental',
                '₹${_totalDailyRental.toInt()}',
              ),
              _buildDarkPriceRow('Logistics, Rigging & Crew', '₹${_logisticsFee.toInt()}'),
              _buildDarkPriceRow('Refundable Security Deposit (25%)', '₹${_securityDeposit.toInt()}'),
              const Divider(color: Color(0xFF333D3A), height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'TOTAL ESTIMATE',
                    style: AppTextStyles.cardTitle.copyWith(
                      color: AppColors.bone,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '₹${_grandTotal.toInt()}',
                    style: AppTextStyles.monoMetric.copyWith(
                      fontSize: 22,
                      color: AppColors.burntCopper,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildReviewInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: AppColors.slate),
          const SizedBox(width: 8),
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: AppTextStyles.monoLabel.copyWith(fontSize: 10, color: AppColors.slate),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.inkBlack,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDarkPriceRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.bone.withValues(alpha: 0.8),
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.monoData.copyWith(
              color: AppColors.bone,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // BOTTOM FLOATING ACTION BAR
  // ===========================================================================
  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: const BoxDecoration(
        color: AppColors.paper,
        border: Border(
          top: BorderSide(color: AppColors.softStone, width: 1),
        ),
      ),
      child: Row(
        children: [
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
          Expanded(
            flex: 2,
            child: RentFlowButton(
              label: _currentStep == 1
                  ? 'Next: Select Equipment'
                  : _currentStep == 2
                      ? (_totalSelectedItems == 0
                          ? 'Select Equipment to Proceed'
                          : 'Next: Review Booking ($_totalSelectedItems Items)')
                      : (_isSubmitting ? 'Locking Reservation...' : 'Lock & Confirm Reservation'),
              icon: _currentStep == 3 ? Icons.lock_outline_rounded : Icons.arrow_forward_rounded,
              onPressed: ((_currentStep == 2 && _totalSelectedItems == 0) || _isSubmitting)
                  ? null
                  : () {
                      if (_currentStep == 1) {
                        final title = _eventNameController.text.trim();
                        final client = _clientNameController.text.trim();
                        final venue = _venueController.text.trim();
                        if (title.isEmpty || client.isEmpty || venue.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter event title, client name, and venue to continue.'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                          return;
                        }

                        final startCal = DateTime(_startDate.year, _startDate.month, _startDate.day);
                        final endCal = DateTime(_endDate.year, _endDate.month, _endDate.day);
                        if (endCal.isBefore(startCal)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Return date cannot be earlier than dispatch date.'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                          return;
                        }
                        setState(() => _currentStep = 2);
                      } else if (_currentStep == 2) {
                        if (_totalSelectedItems <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please select at least 1 equipment item to proceed.'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                          return;
                        }

                        final selectedItems = _catalog
                            .where((i) => i.selectedQty > 0)
                            .map((i) => {
                                  'id': i.id,
                                  'sku': i.sku,
                                  'name': i.name,
                                  'quantity': i.selectedQty,
                                })
                            .toList();

                        final check = AvailabilityService().checkAvailability(
                          startDate: _startDate,
                          endDate: _endDate,
                          requestedItems: selectedItems,
                        );

                        if (!check.isAvailable) {
                          final conflict = check.conflicts.first;
                          BookingConflictSheet.show(
                            context,
                            equipmentName: conflict.equipmentName,
                            sku: conflict.sku,
                            requestedQty: conflict.requestedQty,
                            availableQty: conflict.availableQty,
                            conflictingEvent: conflict.conflictingEvent,
                            onReduceQuantity: () {
                              final match = _catalog.firstWhere((i) => i.sku == conflict.sku);
                              setState(() => match.selectedQty = conflict.availableQty);
                            },
                            onChangeTime: () => setState(() => _currentStep = 1),
                          );
                          return;
                        }

                        setState(() => _currentStep = 3);
                      } else {
                        if (!_isSubmitting) {
                          _handleConfirmBooking();
                        }
                      }
                    },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleConfirmBooking() async {
    setState(() => _isSubmitting = true);

    final newId = 'BK-${(1000 + DateTime.now().millisecondsSinceEpoch % 9000)}';
    final selectedItems = _catalog
        .where((item) => item.selectedQty > 0)
        .map((item) => {
              'id': item.id,
              'sku': item.sku,
              'name': item.name,
              'category': item.category,
              'quantity': item.selectedQty,
              'dailyRate': item.dailyRate,
            })
        .toList();

    final newBooking = BookingItem(
      id: newId,
      eventTitle: _eventNameController.text.trim(),
      clientName: _clientNameController.text.trim().isNotEmpty
          ? _clientNameController.text.trim()
          : 'Event Client',
      category: _selectedEventType,
      date: '${_startDate.day} ${_getMonthName(_startDate.month)} — ${_endDate.day} ${_getMonthName(_endDate.month)}',
      venue: _venueController.text.trim(),
      status: 'CONFIRMED',
      unitsCount: _totalSelectedItems,
      totalAmount: _grandTotal,
      phoneNumber: _phoneController.text.trim(),
      startDate: _startDate,
      endDate: _endDate,
      items: selectedItems,
    );

    try {
      // Authoritative atomic reservation: validates inventory & allocations in Firestore
      await AvailabilityService().reserveAndCreateBooking(newBooking: newBooking);

      if (mounted) {
        setState(() => _isSubmitting = false);
        _showSuccessDialog(newId);
      }
    } on AvailabilityConflictException catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        final conflict = e.checkResult.conflicts.isNotEmpty ? e.checkResult.conflicts.first : null;
        if (conflict != null) {
          BookingConflictSheet.show(
            context,
            equipmentName: conflict.equipmentName,
            sku: conflict.sku,
            requestedQty: conflict.requestedQty,
            availableQty: conflict.availableQty,
            conflictingEvent: conflict.conflictingEvent,
            onReduceQuantity: () {
              final match = _catalog.firstWhere((i) => i.sku == conflict.sku);
              setState(() {
                match.selectedQty = conflict.availableQty;
                _currentStep = 2; // Jump back to catalog so they can review updated selection
              });
            },
            onChangeTime: () => setState(() => _currentStep = 1),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.danger,
              content: Text(e.message),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.danger,
            content: Text('Reservation failed: ${e.toString()}'),
          ),
        );
      }
    }
  }

  void _showSuccessDialog(String newId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.paper,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.successSubtle,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 48,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Booking Confirmed!',
              style: AppTextStyles.screenTitle.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Reservation #$newId has been locked and added to warehouse dispatch manifests.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.slate),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.bone,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.softStone),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('STATUS', style: AppTextStyles.monoLabel.copyWith(fontSize: 10)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'CONFIRMED',
                      style: AppTextStyles.monoLabel.copyWith(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            RentFlowButton(
              label: 'View Bookings List',
              onPressed: () {
                Navigator.pop(context); // close dialog
                Navigator.pop(context); // close wizard
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.copperSubtle,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: AppColors.burntCopper),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.sectionHeading.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.slate,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}
