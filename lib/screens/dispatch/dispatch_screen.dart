import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/booking_item.dart';
import '../../core/services/booking_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/equipment_scan_dialog.dart';
import '../bookings/booking_details_screen.dart';
import 'return_intake_sheet.dart';

/// Dedicated Warehouse Dispatch and Mobile Operations Screen (Resolves BUG-01 & BUG-02).
///
/// Features:
/// - Categorizes confirmed event bookings ready for dispatch into:
///   1. Pending Loading / Manifest Checklist
///   2. In Transit / On Stage
///   3. Awaiting Return Inspection
/// - Real-time vehicle loading & flight case packing progress trackers.
/// - Direct optical barcode scanning & equipment intake integration (GLITCH-09).
/// - Launchpad for returns reconciliation (Phase 6).
class DispatchScreen extends StatefulWidget {
  final bool isEmbedded;
  final VoidCallback? onBackToOverview;

  const DispatchScreen({
    super.key,
    this.isEmbedded = false,
    this.onBackToOverview,
  });

  @override
  State<DispatchScreen> createState() => _DispatchScreenState();
}

class _DispatchScreenState extends State<DispatchScreen> {
  int _selectedCategoryIndex = 0; // 0: Pending Loading, 1: In Transit, 2: Awaiting Return
  final TextEditingController _searchController = TextEditingController();
  final BookingRepository _bookingRepository = BookingRepository();

  final List<String> _categories = [
    'Pending Loading',
    'In Transit / On Stage',
    'Awaiting Return',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<BookingItem> _filterBookings(List<BookingItem> all) {
    final query = _searchController.text.trim().toLowerCase();

    return all.where((b) {
      final matchesQuery = query.isEmpty ||
          b.eventTitle.toLowerCase().contains(query) ||
          b.id.toLowerCase().contains(query) ||
          b.clientName.toLowerCase().contains(query) ||
          b.venue.toLowerCase().contains(query);

      if (!matchesQuery) return false;

      final status = b.status.toUpperCase();
      switch (_selectedCategoryIndex) {
        case 0:
          // Pending Loading / Manifest Checklist
          return status == 'CONFIRMED' || status == 'PACKING' || status == 'READY';
        case 1:
          // In Transit / On Stage
          return status == 'DISPATCHED' || status == 'ON STAGE';
        case 2:
          // Awaiting Return Inspection
          return status == 'AWAITING RETURN' ||
              status == 'COMPLETED' ||
              status == 'RETURN_INSPECTION';
        default:
          return true;
      }
    }).toList();
  }

  void _openBarcodeScanner(BuildContext context, [String? bookingId]) {
    EquipmentScanDialog.show(
      context,
      title: 'DISPATCH SCANNER',
      subtitle: bookingId != null
          ? 'Scan flight case for #$bookingId'
          : 'Scan flight case or equipment barcode',
      onScanned: (code) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.inkBlack,
            content: Text(
              'Scanned & Verified asset: $code',
              style: const TextStyle(color: AppColors.bone),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      },
    );
  }

  void _openReturnIntake(BuildContext context, BookingItem booking) {
    // Generate default manifest items based on category
    final List<Map<String, dynamic>> items;
    final cat = booking.category.toLowerCase();
    if (cat.contains('corporate')) {
      items = [
        {'name': 'd&b audiotechnik V-Series Array Module', 'sku': 'AU-DB-V8', 'qty': 4},
        {'name': 'P3.91 High-Res LED Video Wall (500x500mm)', 'sku': 'VIS-LED-P391', 'qty': 16},
        {'name': 'Shure Axient Digital Wireless Podium Kit', 'sku': 'SND-SHURE-AXD', 'qty': 4},
      ];
    } else {
      items = [
        {'name': 'Robe Robin Pointe Moving Beam', 'sku': 'LT-PNT-700', 'qty': 6},
        {'name': 'L-Acoustics K2 Line Array Module', 'sku': 'AU-K2-LARR', 'qty': 4},
        {'name': 'Heavy Duty Aluminum Box Truss (3m)', 'sku': 'TR-H30V-3M', 'qty': 4},
      ];
    }

    ReturnIntakeSheet.show(
      context,
      bookingId: booking.id,
      eventTitle: booking.eventTitle,
      clientName: booking.clientName,
      manifestItems: items,
      onReconciled: () {
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = ValueListenableBuilder<List<BookingItem>>(
      valueListenable: _bookingRepository.bookingsNotifier,
      builder: (context, allBookings, _) {
        final pendingCount = allBookings.where((b) {
          final s = b.status.toUpperCase();
          return s == 'CONFIRMED' || s == 'PACKING' || s == 'READY';
        }).length;

        final inTransitCount = allBookings.where((b) {
          final s = b.status.toUpperCase();
          return s == 'DISPATCHED' || s == 'ON STAGE';
        }).length;

        final returnCount = allBookings.where((b) {
          final s = b.status.toUpperCase();
          return s == 'AWAITING RETURN' || s == 'COMPLETED';
        }).length;

        final filtered = _filterBookings(allBookings);

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.screenPaddingH,
            vertical: 18.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              _buildHeader(context),
              const SizedBox(height: 16),

              // Tactical Metrics Strip
              _buildMetricsStrip(pendingCount, inTransitCount, returnCount),
              const SizedBox(height: 18),

              // Search Bar with Scanner Quick Action
              _buildSearchAndScanBar(context),
              const SizedBox(height: 16),

              // Category Segmented Tabs
              _buildCategoryTabs(pendingCount, inTransitCount, returnCount),
              const SizedBox(height: 16),

              // Dispatches List or Empty State
              if (filtered.isEmpty)
                _buildEmptyState()
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 14),
                  itemBuilder: (ctx, index) {
                    final booking = filtered[index];
                    return _buildDispatchCard(ctx, booking);
                  },
                ),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );

    if (widget.isEmbedded) {
      return SafeArea(child: content);
    }

    return Scaffold(
      backgroundColor: AppColors.bone,
      appBar: AppBar(
        backgroundColor: AppColors.bone,
        elevation: 0,
        title: Text(
          'DISPATCH & LOGISTICS',
          style: AppTextStyles.brandTitle.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.burntCopper),
            onPressed: () => _openBarcodeScanner(context),
            tooltip: 'Scan Barcode',
          ),
        ],
      ),
      body: SafeArea(child: content),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'DISPATCH & LOGISTICS',
              style: AppTextStyles.brandTitle.copyWith(
                fontSize: 22,
                letterSpacing: -0.3,
                fontWeight: FontWeight.w800,
                color: AppColors.inkBlack,
              ),
            ),
            const SizedBox(height: 3),
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.burntCopper,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Warehouse Fleet Operations • Dock Bays 01–04',
                  style: AppTextStyles.monoLabel.copyWith(
                    color: AppColors.slate,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
        if (widget.onBackToOverview != null)
          Container(
            decoration: BoxDecoration(
              color: AppColors.paper,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.softStone),
            ),
            child: IconButton(
              icon: const Icon(Icons.close_rounded, color: AppColors.inkBlack, size: 20),
              onPressed: widget.onBackToOverview,
              tooltip: 'Back to Overview',
            ),
          ),
      ],
    );
  }

  Widget _buildMetricsStrip(int pending, int inTransit, int returns) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricTile(
            label: 'PENDING LOADING',
            count: '$pending',
            subtext: 'Bays 01 & 02',
            color: AppColors.warning,
            bgColor: AppColors.warningSubtle,
            icon: Icons.local_shipping_outlined,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricTile(
            label: 'IN TRANSIT',
            count: '$inTransit',
            subtext: 'On Stage runs',
            color: AppColors.burntCopper,
            bgColor: AppColors.copperSubtle,
            icon: Icons.alt_route_rounded,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricTile(
            label: 'AWAITING RETURN',
            count: '$returns',
            subtext: 'Dock Intake',
            color: AppColors.success,
            bgColor: AppColors.successSubtle,
            icon: Icons.inventory_2_outlined,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String count,
    required String subtext,
    required Color color,
    required Color bgColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
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
                count,
                style: AppTextStyles.monoMetric.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              Icon(icon, size: 16, color: color),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.monoLabel.copyWith(
              fontSize: 8.5,
              fontWeight: FontWeight.w700,
              color: AppColors.inkBlack,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            subtext,
            style: AppTextStyles.monoLabel.copyWith(
              fontSize: 8,
              color: AppColors.slate,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndScanBar(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.paper,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.softStone),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              style: AppTextStyles.bodyMedium.copyWith(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search dispatch, booking # or client...',
                hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.slate),
                prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.slate),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 16, color: AppColors.slate),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        InkWell(
          onTap: () => _openBarcodeScanner(context),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.inkBlack,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.qr_code_scanner_rounded, size: 18, color: AppColors.burntCopper),
                const SizedBox(width: 6),
                Text(
                  'SCAN',
                  style: AppTextStyles.monoLabel.copyWith(
                    color: AppColors.bone,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryTabs(int pending, int inTransit, int returns) {
    final counts = [pending, inTransit, returns];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_categories.length, (index) {
          final isSelected = _selectedCategoryIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_categories[index]),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : AppColors.softStone,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${counts[index]}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: isSelected ? AppColors.burntCopper : AppColors.inkBlack,
                      ),
                    ),
                  ),
                ],
              ),
              selected: isSelected,
              onSelected: (val) {
                if (val) setState(() => _selectedCategoryIndex = index);
              },
              backgroundColor: AppColors.paper,
              selectedColor: AppColors.burntCopper,
              labelStyle: AppTextStyles.monoLabel.copyWith(
                color: isSelected ? Colors.white : AppColors.inkBlack,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                fontSize: 11,
              ),
              side: BorderSide(
                color: isSelected ? AppColors.burntCopper : AppColors.softStone,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDispatchCard(BuildContext context, BookingItem booking) {
    final status = booking.status.toUpperCase();
    final isPending = status == 'CONFIRMED' || status == 'PACKING' || status == 'READY';
    final isInTransit = status == 'DISPATCHED' || status == 'ON STAGE';
    final isReturn = status == 'AWAITING RETURN' || status == 'COMPLETED';

    Color statusColor = AppColors.burntCopper;
    Color statusBg = AppColors.copperSubtle;
    if (status == 'READY' || status == 'COMPLETED') {
      statusColor = AppColors.success;
      statusBg = AppColors.successSubtle;
    } else if (status == 'PACKING' || status == 'CONFIRMED') {
      statusColor = AppColors.warning;
      statusBg = AppColors.warningSubtle;
    }

    final double progress = status == 'READY'
        ? 1.0
        : status == 'PACKING'
            ? 0.65
            : status == 'DISPATCHED'
                ? 1.0
                : 0.35;

    final String bayAssign = status == 'READY'
        ? 'DOCK-BAY 02 • TRUCK RJ-14-GA-9021'
        : status == 'PACKING'
            ? 'STAGING BAY 01 • FORKLIFT RUN 3'
            : isInTransit
                ? 'EN ROUTE TO VENUE • DRIVER ASSIGNED'
                : 'RETURN DOCK 01 • INTAKE QUEUE';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.softStone),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Booking ID + Category + Status Chip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.bone,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.softStone),
                    ),
                    child: Text(
                      booking.id,
                      style: AppTextStyles.monoLabel.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.burntCopper,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    booking.category.toUpperCase(),
                    style: AppTextStyles.monoLabel.copyWith(
                      fontSize: 9,
                      color: AppColors.slate,
                      fontWeight: FontWeight.w700,
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
                  booking.status,
                  style: AppTextStyles.monoLabel.copyWith(
                    fontSize: 9,
                    color: statusColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Event Title
          Text(
            booking.eventTitle,
            style: AppTextStyles.cardTitle.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),

          // Venue & Date Row
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 14, color: AppColors.slate),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  booking.venue,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.inkBlack,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.schedule_rounded, size: 14, color: AppColors.slate),
              const SizedBox(width: 4),
              Text(
                booking.date,
                style: AppTextStyles.monoLabel.copyWith(
                  color: AppColors.slate,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Dock Bay Assignment Strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.bone,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                const Icon(Icons.forklift, size: 14, color: AppColors.burntCopper),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    bayAssign,
                    style: AppTextStyles.monoLabel.copyWith(
                      fontSize: 9.5,
                      color: AppColors.inkBlack,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Loading Progress Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isPending
                    ? 'Flight Case Loading Progress'
                    : isInTransit
                        ? 'Active Stage Deployment'
                        : 'Returns Reconciliation Progress',
                style: AppTextStyles.monoLabel.copyWith(fontSize: 9.5, color: AppColors.slate),
              ),
              Text(
                '${(progress * 100).toInt()}% Verified',
                style: AppTextStyles.monoLabel.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: AppColors.burntCopper,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.softStone,
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              minHeight: 5,
            ),
          ),
          const SizedBox(height: 16),

          // Action Buttons
          Row(
            children: [
              if (isPending) ...[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookingDetailsScreen(
                            bookingId: booking.id,
                            eventTitle: booking.eventTitle,
                            clientName: booking.clientName,
                            venue: booking.venue,
                            dates: booking.date,
                            status: booking.status,
                            totalItems: booking.unitsCount,
                            grandTotal: booking.totalAmount,
                            category: booking.category,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.checklist_rounded, size: 16),
                    label: const Text('Open Manifest Checklist'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.burntCopper,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  onPressed: () => _openBarcodeScanner(context, booking.id),
                  icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.bone,
                    foregroundColor: AppColors.inkBlack,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  tooltip: 'Scan Case',
                ),
              ] else if (isInTransit) ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _bookingRepository.updateBookingStatus(booking.id, 'AWAITING RETURN');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Dispatched #${booking.id} marked as Awaiting Return')),
                      );
                      setState(() {});
                    },
                    icon: const Icon(Icons.transit_enterexit_rounded, size: 16),
                    label: const Text('Mark Stage Completed / Await Return'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.inkBlack,
                      side: const BorderSide(color: AppColors.softStone),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
                    ),
                  ),
                ),
              ] else if (isReturn) ...[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _openReturnIntake(context, booking),
                    icon: const Icon(Icons.assignment_turned_in_outlined, size: 16),
                    label: const Text('Open Return Intake Sheet'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.burntCopper,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.softStone),
      ),
      child: Column(
        children: [
          const Icon(Icons.inventory_2_outlined, size: 40, color: AppColors.slate),
          const SizedBox(height: 10),
          Text(
            'No Active Dispatches',
            style: AppTextStyles.cardTitle.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'No confirmed bookings match the selected queue filter.',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.slate),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
