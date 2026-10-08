import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

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

  const DashboardScreen({super.key, this.userName});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    final dynamic routeArgs = ModalRoute.of(context)?.settings.arguments;
    final String displayName = widget.userName ??
        (routeArgs is String && routeArgs.isNotEmpty
            ? routeArgs
            : AppConstants.coordinatorName);

    return Scaffold(
      backgroundColor: AppColors.bone,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.screenPaddingH,
            vertical: 22.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar with left-aligned greeting & logout action
              _buildTopHeader(context, displayName),
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
  Widget _buildTopHeader(BuildContext context, String displayName) {
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
                    'Operations Cockpit • Squad 124 • Mon, 30 Sep',
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
            onPressed: () {
              Navigator.of(context).pushReplacementNamed(AppRoutes.login);
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
                Text(
                  '148',
                  style: AppTextStyles.monoMetric.copyWith(
                    fontSize: 26,
                    color: AppColors.inkBlack,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '98% operational capacity',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 11,
                    color: AppColors.slate,
                  ),
                ),
              ],
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
          status: 'Loading',
          progressText: '6 / 12 items',
          statusColor: AppColors.warning,
          statusBg: AppColors.warningSubtle,
        ),
        const SizedBox(height: 10),
        _buildTimelineItem(
          time: '13:00',
          title: 'TECHCORP CONFERENCE',
          status: 'Packing',
          progressText: '18 / 25 items',
          statusColor: AppColors.burntCopper,
          statusBg: AppColors.copperSubtle,
        ),
        const SizedBox(height: 10),
        _buildTimelineItem(
          time: '16:00',
          title: 'MEHTA SANGEET',
          status: 'Ready',
          progressText: 'Staged at dock 02',
          statusColor: AppColors.success,
          statusBg: AppColors.successSubtle,
        ),
      ],
    );
  }

  Widget _buildTimelineItem({
    required String time,
    required String title,
    required String status,
    required String progressText,
    required Color statusColor,
    required Color statusBg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.softStone, width: 1),
      ),
      child: Row(
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
          const SizedBox(width: 12),

          // Title & Progress
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.cardTitle.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.1,
                  ),
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

          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: statusColor.withAlpha(100),
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
        ],
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
            ),
            const SizedBox(width: 8),
            _buildCommandChip(
              context: context,
              icon: Icons.inventory_2_outlined,
              label: 'Inventory',
            ),
            const SizedBox(width: 8),
            _buildCommandChip(
              context: context,
              icon: Icons.local_shipping_outlined,
              label: 'Dispatch',
            ),
            const SizedBox(width: 8),
            _buildCommandChip(
              context: context,
              icon: Icons.event_available_outlined,
              label: 'Availability',
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
  }) {
    return Expanded(
      child: InkWell(
        onTap: () {
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
}
