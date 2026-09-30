import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Centralized bottom navigation bar for RentFlow.
///
/// Flutter & Dart Concepts:
/// - `currentIndex`: Controls active tab highlighting.
/// - `ValueChanged<int> onTap`: Callback fired when a tab icon is pressed.
/// - Clear boundary: Prateek's upcoming screens (Inventory, Dispatch) can plug
///   straight into this navigation bar without rewriting navigation UI.
class RentFlowBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const RentFlowBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.pureWhite,
        border: Border(
          top: BorderSide(color: AppColors.borderSubtle, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                label: 'Dashboard',
                icon: Icons.dashboard_rounded,
                activeIcon: Icons.dashboard_rounded,
              ),
              _buildNavItem(
                index: 1,
                label: 'Bookings',
                icon: Icons.calendar_month_outlined,
                activeIcon: Icons.calendar_month_rounded,
              ),
              _buildNavItem(
                index: 2,
                label: 'Inventory',
                icon: Icons.inventory_2_outlined,
                activeIcon: Icons.inventory_2_rounded,
              ),
              _buildNavItem(
                index: 3,
                label: 'Dispatch',
                icon: Icons.local_shipping_outlined,
                activeIcon: Icons.local_shipping_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String label,
    required IconData icon,
    required IconData activeIcon,
  }) {
    final isSelected = currentIndex == index;
    final color = isSelected ? AppColors.alpineEvergreen : AppColors.textSecondary;

    return InkWell(
      onTap: () => onTap(index),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: color,
              size: 22,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
