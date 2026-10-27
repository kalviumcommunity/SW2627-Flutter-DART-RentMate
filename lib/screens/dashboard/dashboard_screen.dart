import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/routes/app_routes.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/booking_repository.dart';
import '../../core/services/inventory_repository.dart';
import '../../core/services/seed_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/rentflow_button.dart';
import '../bookings/booking_details_screen.dart';
import '../bookings/bookings_list_screen.dart';
import '../bookings/create_booking_screen.dart';
import '../dispatch/dispatch_screen.dart';
import '../inventory/inventory_screen.dart';

/// Coordinator Dashboard screen (RentFlow Operations Cockpit).
///
/// Visual Structure:
/// 1. Editorial Header: `GOOD MORNING, MAYANK` + date & squad context + sign out action.
/// 2. Primary Operational Panel: Large dominant card with 12 ACTIVE BOOKINGS
///    and "4 dispatches require attention" status callout.
/// 3. Secondary Operational Status Metrics: 148 EQUIPMENT UNITS & 02 CONFLICTS.
/// 4. LIVE OPERATIONS Timeline: Today's event dispatch schedule (Sharma Wedding, TechCorp, Mehta Sangeet).
/// 5. Quick Commands: Compact industrial command strip (+ New Booking, Inventory, Dispatch, Availability).
/// 6. Bottom Navigation: Industrial Atelier dock with copper indicators.
class DashboardScreen extends StatefulWidget {
  final String? userName;
  final String? userRole;
  final int? initialNavIndex;

  const DashboardScreen({
    super.key,
    this.userName,
    this.userRole,
    this.initialNavIndex,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentNavIndex = 0;
  bool _hasEvaluatedInitialRole = false;
  bool _isSeeding = false;
  late String _activeRole;

  @override
  void initState() {
    super.initState();
    _activeRole = widget.userRole ?? AuthService().currentUser?.role ?? 'coordinator';
    if (widget.initialNavIndex != null) {
      _currentNavIndex = widget.initialNavIndex!;
      _hasEvaluatedInitialRole = true;
    } else {
      final role = _activeRole.toLowerCase();
      if (role == 'warehouse') {
        _currentNavIndex = 3; // Direct warehouse operators straight to Dispatch
        _hasEvaluatedInitialRole = true;
      }
    }
  }

  String get _currentFormattedDate {
    final now = DateTime.now();
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final weekday = days[now.weekday - 1];
    final month = months[now.month - 1];
    return '$weekday, ${now.day} $month';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasEvaluatedInitialRole) {
      final dynamic routeArgs = ModalRoute.of(context)?.settings.arguments;
      if (routeArgs is Map<String, dynamic>) {
        final role = routeArgs['role']?.toString().toLowerCase();
        if (role != null) {
          _activeRole = role;
        }
        if (role == 'warehouse') {
          _currentNavIndex = (routeArgs['initialTab'] as int?) ?? 3;
        } else if (routeArgs['initialTab'] != null) {
          _currentNavIndex = routeArgs['initialTab'] as int;
        }
      }
      _hasEvaluatedInitialRole = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dynamic routeArgs = ModalRoute.of(context)?.settings.arguments;
    final String displayName = widget.userName ??
        (routeArgs is String && routeArgs.isNotEmpty
            ? routeArgs
            : (routeArgs is Map<String, dynamic> && routeArgs['userName'] != null
                ? routeArgs['userName'].toString()
                : AppConstants.coordinatorName));

    return Scaffold(
      backgroundColor: AppColors.bone,
      body: _currentNavIndex == 1
          ? BookingsListScreen(
              isEmbedded: true,
              onBackToOverview: () {
                setState(() => _currentNavIndex = 0);
              },
            )
          : _currentNavIndex == 2
              ? InventoryScreen(
                  isEmbedded: true,
                  onBackToOverview: () {
                    setState(() => _currentNavIndex = 0);
                  },
                )
              : _currentNavIndex == 3
                  ? DispatchScreen(
                      isEmbedded: true,
                      onBackToOverview: () {
                        setState(() => _currentNavIndex = 0);
                      },
                    )
                  : _currentNavIndex == 4
                      ? _buildMoreView(displayName)
                      : SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.screenPaddingH,
                      vertical: 22.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Bar with left-aligned greeting & logout action
                        _buildTopHeader(displayName),
                        const SizedBox(height: 22),

                        // Large Primary Operational Panel
                        _buildPrimaryOperationalPanel(),
                        const SizedBox(height: 14),

                        // Secondary Metrics Row (148 Equipment Units & 02 Conflicts)
                        _buildSecondaryMetricsRow(),
                        const SizedBox(height: 26),

                        // Live Operations Section (Event Schedule Timeline)
                        _buildLiveOperationsSection(context),
                        const SizedBox(height: 26),

                        // Compact Quick Commands Strip
                        _buildQuickCommandsSection(context),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }


  /// Top Bar with left-aligned greeting and sign-out action
  Widget _buildTopHeader(String displayName) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello $displayName',
                style: AppTextStyles.brandTitle.copyWith(
                  fontSize: 24,
                  letterSpacing: -0.4,
                  fontWeight: FontWeight.w800,
                  color: AppColors.inkBlack,
                ),
              ),
              const SizedBox(height: 4),
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
                    'Operations Cockpit • Squad 124 • $_currentFormattedDate',
                    style: AppTextStyles.monoLabel.copyWith(
                      color: AppColors.slate,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Profile / Sign Out Action
        Container(
          decoration: BoxDecoration(
            color: AppColors.paper,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.softStone, width: 1),
          ),
          child: IconButton(
            onPressed: () async {
              await AuthService().signOut();
              if (mounted) {
                Navigator.of(context).pushReplacementNamed(AppRoutes.login);
              }
            },
            icon: const Icon(
              Icons.logout_rounded,
              size: 20,
              color: AppColors.inkBlack,
            ),
            tooltip: 'Sign Out',
          ),
        ),
      ],
    );
  }

  /// Dominant Primary Operational Card
  Widget _buildPrimaryOperationalPanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.inkBlack,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0x4DB86A45),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "TODAY'S OPERATIONS",
                style: AppTextStyles.monoLabel.copyWith(
                  color: AppColors.agedBrass,
                  letterSpacing: 1.2,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0x33B86A45),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'LIVE FLEET',
                  style: AppTextStyles.monoLabel.copyWith(
                    color: AppColors.burntCopper,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '12',
                style: AppTextStyles.monoMetric.copyWith(
                  color: AppColors.paper,
                  fontSize: 38,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Active Bookings',
                style: AppTextStyles.brandTitle.copyWith(
                  fontSize: 16,
                  letterSpacing: 0.3,
                  color: AppColors.bone,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0x26C8893D),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: const Color(0x66C8893D),
                width: 0.8,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 15,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 6),
                Text(
                  '4 dispatches require attention',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.bone,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Secondary Metrics (148 Equipment Units, 02 Conflicts)
  Widget _buildSecondaryMetricsRow() {
    return Row(
      children: [
        // Equipment Units
        Expanded(
          child: InkWell(
            onTap: () => setState(() => _currentNavIndex = 2),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.paper,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.softStone, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'EQUIPMENT UNITS',
                        style: AppTextStyles.monoLabel.copyWith(
                          fontSize: 10,
                          color: AppColors.slate,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Icon(
                        Icons.inventory_2_outlined,
                        size: 16,
                        color: AppColors.slate,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ValueListenableBuilder<List<Map<String, dynamic>>>(
                    valueListenable: InventoryRepository().itemsNotifier,
                    builder: (context, items, child) {
                      final totalAssets = InventoryRepository().totalAssetsCount;
                      final maintCount = InventoryRepository().maintenanceCount;
                      final operationalPct = totalAssets > 0
                          ? (((totalAssets - maintCount) / totalAssets) * 100).round()
                          : 100;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$totalAssets',
                            style: AppTextStyles.monoMetric.copyWith(
                              fontSize: 26,
                              color: AppColors.inkBlack,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$operationalPct% operational capacity',
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: 11,
                              color: AppColors.slate,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Conflicts
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.paper,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.softStone, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'CONFLICTS',
                      style: AppTextStyles.monoLabel.copyWith(
                        fontSize: 10,
                        color: AppColors.slate,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Icon(
                      Icons.crisis_alert_rounded,
                      size: 16,
                      color: AppColors.danger,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '02',
                  style: AppTextStyles.monoMetric.copyWith(
                    fontSize: 26,
                    color: AppColors.danger,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Overlapping stage rigs',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 11,
                    color: AppColors.danger,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Live Operations Event Schedule Timeline
  Widget _buildLiveOperationsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 3,
                  height: 16,
                  color: AppColors.burntCopper,
                ),
                const SizedBox(width: 8),
                Text(
                  'LIVE OPERATIONS',
                  style: AppTextStyles.brandTitle.copyWith(
                    fontSize: 16,
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            Text(
              'TODAY',
              style: AppTextStyles.monoLabel.copyWith(
                fontSize: 11,
                color: AppColors.slate,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Timeline Items
        _buildTimelineItem(
          time: '10:00',
          title: 'SHARMA WEDDING',
          tag: 'STAGE-RIG 04',
          status: 'Loading',
          progressText: '6 / 12 items',
          progressRatio: 0.5,
          statusColor: AppColors.warning,
          statusBg: AppColors.warningSubtle,
        ),
        const SizedBox(height: 10),
        _buildTimelineItem(
          time: '13:00',
          title: 'TECHCORP CONFERENCE',
          tag: 'AV-SUITE 02',
          status: 'Packing',
          progressText: '18 / 25 items',
          progressRatio: 0.72,
          statusColor: AppColors.burntCopper,
          statusBg: AppColors.copperSubtle,
        ),
        const SizedBox(height: 10),
        _buildTimelineItem(
          time: '16:00',
          title: 'MEHTA SANGEET',
          tag: 'DOCK-BAY 01',
          status: 'Ready',
          progressText: 'Staged at dock 02',
          progressRatio: 1.0,
          statusColor: AppColors.success,
          statusBg: AppColors.successSubtle,
        ),
      ],
    );
  }

  Widget _buildTimelineItem({
    required String time,
    required String title,
    required String tag,
    required String status,
    required String progressText,
    required double progressRatio,
    required Color statusColor,
    required Color statusBg,
  }) {
    return InkWell(
      onTap: () {
        // Resolve booking from repository or use dynamic event fields
        final cleanTitle = title.toLowerCase().replaceAll(' ', '');
        final matchedBooking = BookingRepository().bookings.cast<BookingItem?>().firstWhere(
          (b) => b != null && (b.eventTitle.toLowerCase().replaceAll(' ', '').contains(cleanTitle) ||
                 cleanTitle.contains(b.eventTitle.toLowerCase().replaceAll(' ', ''))),
          orElse: () => null,
        );

        if (matchedBooking != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookingDetailsScreen(
                bookingId: matchedBooking.id,
                eventTitle: matchedBooking.eventTitle,
                clientName: matchedBooking.clientName,
                clientPhone: matchedBooking.phoneNumber ?? '+91 98765 43210',
                venue: matchedBooking.venue,
                dates: matchedBooking.date,
                status: matchedBooking.status,
                totalItems: matchedBooking.unitsCount,
                grandTotal: matchedBooking.totalAmount,
                category: matchedBooking.category,
                manifestItems: matchedBooking.items,
              ),
            ),
          );
        } else {
          final idSuffix = title.hashCode.abs() % 9000 + 1000;
          final fallbackCategory = title.toLowerCase().contains('conference') || title.toLowerCase().contains('tech')
              ? 'Corporate'
              : (title.toLowerCase().contains('sangeet') ? 'Sangeet' : 'Wedding');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookingDetailsScreen(
                bookingId: 'BK-$idSuffix',
                eventTitle: title,
                status: status.toUpperCase(),
                category: fallbackCategory,
              ),
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.paper,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.softStone, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Time badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.bone,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.softStone, width: 0.8),
                  ),
                  child: Text(
                    time,
                    style: AppTextStyles.monoData.copyWith(
                      fontSize: 12,
                      color: AppColors.inkBlack,
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Title & Operational Tag
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.cardTitle.copyWith(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.1,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: AppColors.bone,
                              borderRadius: BorderRadius.circular(3),
                              border: Border.all(color: AppColors.softStone, width: 0.6),
                            ),
                            child: Text(
                              tag,
                              style: AppTextStyles.monoLabel.copyWith(
                                fontSize: 8.5,
                                color: AppColors.slate,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        progressText,
                        style: AppTextStyles.monoLabel.copyWith(
                          fontSize: 11,
                          color: AppColors.slate,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    status,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 11,
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.slate),
              ],
            ),
            const SizedBox(height: 8),

            // Tactical Progress Track
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: progressRatio,
                minHeight: 2.5,
                backgroundColor: AppColors.softStone.withValues(alpha: 0.5),
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Compact Quick Commands Section
  Widget _buildQuickCommandsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 16,
              color: AppColors.burntCopper,
            ),
            const SizedBox(width: 8),
            Text(
              'QUICK COMMANDS',
              style: AppTextStyles.brandTitle.copyWith(
                fontSize: 16,
                letterSpacing: 0.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildCommandChip(
              context: context,
              icon: Icons.add_rounded,
              label: 'New Booking',
              isPrimary: true,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CreateBookingScreen()),
                );
              },
            ),
            const SizedBox(width: 8),
            _buildCommandChip(
              context: context,
              icon: Icons.inventory_2_outlined,
              label: 'Inventory',
              onTap: () => setState(() => _currentNavIndex = 2),
            ),
            const SizedBox(width: 8),
            _buildCommandChip(
              context: context,
              icon: Icons.local_shipping_outlined,
              label: 'Dispatch',
              onTap: () {
                setState(() => _currentNavIndex = 3);
              },
            ),
            const SizedBox(width: 8),
            _buildCommandChip(
              context: context,
              icon: Icons.event_available_outlined,
              label: 'Availability',
              onTap: () {
                setState(() => _currentNavIndex = 2);
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCommandChip({
    required BuildContext context,
    required IconData icon,
    required String label,
    bool isPrimary = false,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap ??
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$label command queued.'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          decoration: BoxDecoration(
            color: isPrimary ? AppColors.burntCopper : AppColors.paper,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isPrimary ? AppColors.burntCopper : AppColors.softStone,
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: isPrimary ? Colors.white : AppColors.inkBlack,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isPrimary ? Colors.white : AppColors.inkBlack,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  /// Bottom Navigation (Industrial Atelier Dock)
  Widget _buildBottomNavigation() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.inkBlack,
        border: Border(
          top: BorderSide(color: Color(0xFF232B29), width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.dashboard_rounded, 'Overview'),
              _buildNavItem(1, Icons.calendar_today_rounded, 'Bookings'),
              _buildNavItem(2, Icons.inventory_2_rounded, 'Inventory'),
              _buildNavItem(3, Icons.local_shipping_rounded, 'Dispatch'),
              _buildNavItem(4, Icons.more_horiz_rounded, 'More'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentNavIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentNavIndex = index),
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppColors.burntCopper : AppColors.slate,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.monoLabel.copyWith(
                fontSize: 10,
                color: isSelected ? AppColors.bone : AppColors.slate,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Container(
              height: 2,
              width: 14,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.burntCopper : Colors.transparent,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreView(String displayName) {
    final currentUser = AuthService().currentUser;
    final email = currentUser?.email.isNotEmpty == true
        ? currentUser!.email
        : '${displayName.toLowerCase().replaceAll(' ', '.')}@rentflow.ops';

    final normalizedRole = AuthService.normalizeRole(_activeRole);
    final String roleBadgeText;
    final Color roleBadgeColor;
    final Color roleBadgeBg;
    if (normalizedRole == 'admin') {
      roleBadgeText = 'ADMINISTRATOR';
      roleBadgeColor = AppColors.inkBlack;
      roleBadgeBg = AppColors.bone;
    } else if (normalizedRole == 'warehouse') {
      roleBadgeText = 'WAREHOUSE LEAD';
      roleBadgeColor = AppColors.warning;
      roleBadgeBg = AppColors.warningSubtle;
    } else {
      roleBadgeText = 'EVENT COORDINATOR';
      roleBadgeColor = AppColors.burntCopper;
      roleBadgeBg = AppColors.copperSubtle;
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.screenPaddingH,
          vertical: 20.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'OPERATIONS CONFIG',
                      style: AppTextStyles.brandTitle.copyWith(
                        fontSize: 20,
                        letterSpacing: -0.2,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Squad 124 • Regional Warehouse Settings',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.slate),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.inkBlack),
                  onPressed: () => setState(() => _currentNavIndex = 0),
                  tooltip: 'Back to Overview',
                ),
              ],
            ),
            const SizedBox(height: 18),

            // User Profile Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.paper,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.softStone),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.burntCopper,
                    child: Text(
                      displayName.isNotEmpty ? displayName[0].toUpperCase() : 'O',
                      style: AppTextStyles.cardTitle.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              displayName,
                              style: AppTextStyles.cardTitle.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: roleBadgeBg,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                roleBadgeText,
                                style: AppTextStyles.monoLabel.copyWith(
                                  fontSize: 8.5,
                                  color: roleBadgeColor,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          email,
                          style: AppTextStyles.monoLabel.copyWith(
                            fontSize: 11,
                            color: AppColors.slate,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'North Zone Dispatch • Station #04',
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 10.5,
                            color: AppColors.inkBlack,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Interactive Examiner Role Switcher
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.inkBlack,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.swap_horiz_rounded, color: AppColors.burntCopper, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'EXAMINER DEMO: SWITCH ACTIVE ROLE',
                        style: AppTextStyles.monoLabel.copyWith(
                          color: AppColors.bone,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Toggle operational persona to test role-specific landing and access. (Sandbox Mode: Firestore security rules validate production privileges)',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.slate,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildRoleSwitchChip('Coordinator', 'coordinator', Icons.event_note_rounded),
                      const SizedBox(width: 8),
                      _buildRoleSwitchChip('Warehouse', 'warehouse', Icons.local_shipping_rounded),
                      const SizedBox(width: 8),
                      _buildRoleSwitchChip('Admin', 'admin', Icons.admin_panel_settings_rounded),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'FACILITY CONFIGURATION',
              style: AppTextStyles.monoLabel.copyWith(
                fontSize: 10.5,
                color: AppColors.slate,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            _buildConfigOption(Icons.warehouse_outlined, 'Warehouse Fleet & Bays', 'Manage loading dock bays, rack coordinates, and cases'),
            _buildConfigOption(Icons.handyman_outlined, 'Maintenance & Bench Checks', 'Equipment inspection schedules, test reports, and repairs'),
            _buildConfigOption(Icons.badge_outlined, 'Staff Access & Crew Roles', 'Permissions for Coordinators, Dispatchers, and Leads'),
            _buildConfigOption(Icons.cloud_sync_outlined, 'Cloud Sync & Offline Manifests', 'Synchronize field manifests with central operations DB'),
            const SizedBox(height: 14),
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.paper,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.burntCopper.withAlpha(128)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.copperSubtle,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.dataset_linked_outlined, color: AppColors.burntCopper, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Seed Operations Dataset',
                              style: AppTextStyles.brandTitle.copyWith(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Populate Cloud Firestore and local fleet with 10 equipment assets, 7 bookings, and allocation ledgers.',
                              style: AppTextStyles.bodySmall.copyWith(color: AppColors.slate),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  RentFlowButton(
                    label: _isSeeding ? 'Seeding Operations Fleet...' : 'Seed Database & Fleet',
                    icon: Icons.cloud_upload_outlined,
                    backgroundColor: AppColors.burntCopper,
                    textColor: AppColors.paper,
                    onPressed: _isSeeding
                        ? null
                        : () async {
                            setState(() => _isSeeding = true);
                            final result = await SeedService().seedDatabase(force: true);
                            if (mounted) {
                              setState(() => _isSeeding = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(result.message),
                                  backgroundColor: result.firestoreSeeded || result.localSeeded
                                      ? AppColors.success
                                      : AppColors.danger,
                                  duration: const Duration(seconds: 4),
                                ),
                              );
                            }
                          },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            RentFlowButton(
              label: 'Sign Out of Session',
              icon: Icons.logout_rounded,
              backgroundColor: AppColors.paper,
              textColor: AppColors.danger,
              onPressed: () async {
                await AuthService().signOut();
                if (mounted) {
                  Navigator.of(context).pushReplacementNamed(AppRoutes.login);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleSwitchChip(String label, String roleKey, IconData icon) {
    final isSelected = AuthService.normalizeRole(_activeRole) == roleKey;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _activeRole = roleKey;
            final currentUser = AuthService().currentUser;
            if (currentUser != null) {
              AuthService().setCurrentUser(currentUser.copyWith(role: roleKey));
            }
            AuthService().setUserRole(currentUser?.id ?? 'active_user', roleKey);
            if (roleKey == 'warehouse') {
              _currentNavIndex = 3; // Direct warehouse operators straight to Dispatch
            } else {
              _currentNavIndex = 0; // Direct coordinator / admin to Overview
            }
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.inkBlack,
              content: Text(
                'Switched role to $label (${roleKey == 'warehouse' ? 'Landed on Dispatch' : 'Landed on Overview'})',
                style: const TextStyle(color: AppColors.bone),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.burntCopper : AppColors.inkBlack,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.burntCopper : AppColors.softStone.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              Icon(icon, size: 16, color: isSelected ? Colors.white : AppColors.bone),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTextStyles.monoLabel.copyWith(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : AppColors.bone,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfigOption(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.softStone),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.bone,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.burntCopper, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.cardTitle.copyWith(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(fontSize: 11, color: AppColors.slate),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.slate),
        ],
      ),
    );
  }
}
