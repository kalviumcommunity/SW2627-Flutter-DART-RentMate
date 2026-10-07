import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Coordinator Dashboard screen.
///
/// Displays the greeting `Hello {user name}` at the top-left corner
/// along with operational summaries and quick actions.
class DashboardScreen extends StatelessWidget {
  final String? userName;

  const DashboardScreen({super.key, this.userName});

  @override
  Widget build(BuildContext context) {
    // Retrieve user name passed through route arguments or constructor fallback
    final dynamic routeArgs = ModalRoute.of(context)?.settings.arguments;
    final String displayName = userName ??
        (routeArgs is String && routeArgs.isNotEmpty
            ? routeArgs
            : AppConstants.coordinatorName);

    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.screenPaddingH,
            vertical: 24.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar with left-aligned greeting & logout action
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left corner: Hello {user name}
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello $displayName',
                          style: AppTextStyles.brandTitle.copyWith(
                            fontSize: 26,
                            color: AppColors.forestObsidian,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Operations Dashboard • ${AppConstants.squadNumber}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Profile / Logout Button
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
                    },
                    icon: const Icon(
                      Icons.logout_rounded,
                      color: AppColors.textSecondary,
                    ),
                    tooltip: 'Sign Out',
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Operational Status Cards
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Active Bookings',
                      value: '12',
                      subtitle: '4 pending dispatch',
                      icon: Icons.calendar_today_rounded,
                      accentColor: AppColors.alpineEvergreen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Equipment Units',
                      value: '148',
                      subtitle: '98% operational',
                      icon: Icons.inventory_2_outlined,
                      accentColor: AppColors.industrialAmber,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Quick Actions Section
              Text(
                'Quick Actions',
                style: AppTextStyles.sectionHeading,
              ),
              const SizedBox(height: 12),
              _buildActionTile(
                icon: Icons.add_circle_outline_rounded,
                title: 'New Equipment Booking',
                description: 'Reserve sound, stage lighting, and furniture',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Equipment booking flow coming soon!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              _buildActionTile(
                icon: Icons.local_shipping_outlined,
                title: 'Dispatch & Packing Checklist',
                description: 'Review equipment dispatch and return queues',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Dispatch checklist flow coming soon!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              _buildActionTile(
                icon: Icons.category_outlined,
                title: 'Inventory Categories',
                description: 'Sound Systems, Stage Lighting, Event Furniture',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Inventory catalog coming soon!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        border: Border.all(color: AppColors.structuralBorder, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(icon, size: 20, color: accentColor),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.metricNumber.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textMuted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.cardRadius),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.circular(AppConstants.cardRadius),
          border: Border.all(color: AppColors.structuralBorder, width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.evergreenSubtle,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: AppColors.alpineEvergreen,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.cardTitle,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
