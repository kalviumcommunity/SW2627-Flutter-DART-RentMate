import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/booking_model.dart';
import '../../widgets/app_shell/section_header.dart';
import '../../widgets/bookings/booking_card.dart';
import '../../widgets/dashboard/conflict_alert_card.dart';
import '../../widgets/dashboard/metric_card.dart';
import '../../widgets/dashboard/quick_action_card.dart';
import '../../widgets/navigation/rentflow_bottom_nav.dart';

/// Coordinator operations home dashboard.
///
/// Flutter & Dart Concepts Taught:
/// - Screen composition with specialized dashboard widgets.
/// - Navigation between tabs: Switches tab index or pushes routes cleanly.
/// - Data separation: Displays [BookingItem.sampleBookings] through clean presentation widgets.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentNavIndex = 0;

  void _onNavTap(int index) {
    if (index == 1) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.bookings);
    } else if (index == 2) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.inventory);
    } else if (index == 3) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.dispatch);
    } else {
      setState(() => _currentNavIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sampleBookings = BookingItem.sampleBookings;
    final conflictBookings = sampleBookings
        .where((b) => b.status == AppConstants.statusConflict)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      bottomNavigationBar: RentFlowBottomNav(
        currentIndex: _currentNavIndex,
        onTap: _onNavTap,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.screenPaddingH,
            vertical: 16.0,
          ),
          children: [
            // Top App Bar: Greeting, Avatar & Notifications
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // Coordinator Avatar
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.alpineEvergreen,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.structuralBorder,
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'MS',
                          style: AppTextStyles.monoLabel.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Good morning, Mayank',
                          style: AppTextStyles.cardTitle.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Wednesday, 30 Sep • ${AppConstants.squadNumber}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Notification Bell with Unread Conflict Indicator
                Stack(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.pureWhite,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.notifications_outlined,
                          size: 20,
                          color: AppColors.forestObsidian,
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('1 critical double-booking alert requires attention.'),
                            ),
                          );
                        },
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.hazardCrimson,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Critical Conflict Alert (Directly addresses problem statement)
            if (conflictBookings.isNotEmpty)
              ConflictAlertCard(
                conflictCount: conflictBookings.length,
                description:
                    '${conflictBookings.first.eventName}: ${conflictBookings.first.conflictDetails ?? "Equipment double-booked across overlapping dates."}',
                onResolveTap: () {
                  Navigator.of(context).pushNamed(
                    AppRoutes.bookings,
                    arguments: AppConstants.statusConflict,
                  );
                },
              ),

            // Metrics Grid (Today's Key Stats)
            Row(
              children: [
                MetricCard(
                  label: 'Active Bookings',
                  value: '14',
                  subtitle: '4 today',
                  icon: Icons.event_available_rounded,
                  accentColor: AppColors.alpineEvergreen,
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.bookings),
                ),
                const SizedBox(width: 10),
                MetricCard(
                  label: 'Dispatches Due',
                  value: '6',
                  subtitle: '2 packing now',
                  icon: Icons.local_shipping_rounded,
                  accentColor: AppColors.industrialAmber,
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.dispatch),
                ),
                const SizedBox(width: 10),
                MetricCard(
                  label: 'Conflicts',
                  value: '${conflictBookings.length}',
                  subtitle: 'Action required',
                  icon: Icons.warning_amber_rounded,
                  accentColor: AppColors.hazardCrimson,
                  onTap: () => Navigator.of(context).pushNamed(
                    AppRoutes.bookings,
                    arguments: AppConstants.statusConflict,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Quick Actions Bar
            const SectionHeader(title: 'Quick Operations'),
            Row(
              children: [
                QuickActionCard(
                  label: 'All Bookings',
                  icon: Icons.calendar_today_rounded,
                  color: AppColors.alpineEvergreen,
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.bookings),
                ),
                const SizedBox(width: 10),
                QuickActionCard(
                  label: 'Check Stock',
                  icon: Icons.inventory_2_rounded,
                  color: AppColors.forestObsidian,
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.inventory),
                ),
                const SizedBox(width: 10),
                QuickActionCard(
                  label: 'Dispatch Doc',
                  icon: Icons.receipt_long_rounded,
                  color: AppColors.industrialAmber,
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.dispatch),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Today's Operational Schedule
            SectionHeader(
              title: "Today's Schedule & Manifests",
              subtitle: 'Active events committing warehouse inventory',
              trailing: TextButton(
                onPressed: () => Navigator.of(context).pushNamed(AppRoutes.bookings),
                child: Text(
                  'View All (${sampleBookings.length})',
                  style: AppTextStyles.buttonLabel.copyWith(
                    color: AppColors.alpineEvergreen,
                    fontSize: 13,
                  ),
                ),
              ),
            ),

            ...sampleBookings.take(3).map(
                  (booking) => BookingCard(
                    booking: booking,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Selected booking: ${booking.eventName}'),
                        ),
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
