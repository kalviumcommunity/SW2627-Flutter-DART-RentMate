import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/equipment_item.dart';

/// Presentation card for equipment items in the Inventory screen.
///
/// Flutter & Dart Concepts:
/// - Visual stock proportion bar (Available vs Total).
/// - JetBrains Mono typography for technical identifiers and numbers.
/// - Clear operational statuses: Available, Limited, Booked, Out of Stock.
class InventoryCard extends StatelessWidget {
  final EquipmentItem item;
  final VoidCallback? onTap;

  const InventoryCard({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final stockFraction = item.totalQuantity > 0
        ? (item.availableQuantity / item.totalQuantity).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Icon, Title, SKU, and Status Badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: item.statusBgColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: Center(
                        child: Icon(
                          _getCategoryIcon(item.category),
                          color: item.statusColor,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.name,
                                  style: AppTextStyles.cardTitle.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              _buildStatusBadge(),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Text(
                                item.sku,
                                style: AppTextStyles.monoLabel.copyWith(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text('•', style: AppTextStyles.bodySmall),
                              const SizedBox(width: 8),
                              Text(
                                item.category,
                                style: AppTextStyles.bodySmall.copyWith(
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Description
                Text(
                  item.description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // Stock Availability Bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Stock Availability',
                          style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
                        ),
                        Row(
                          children: [
                            Text(
                              '${item.availableQuantity}',
                              style: AppTextStyles.monoLabel.copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: item.statusColor,
                              ),
                            ),
                            Text(
                              ' / ${item.totalQuantity} Units',
                              style: AppTextStyles.monoLabel.copyWith(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: stockFraction,
                        minHeight: 6,
                        backgroundColor: AppColors.surfaceMuted,
                        valueColor: AlwaysStoppedAnimation<Color>(item.statusColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(height: 1, color: AppColors.borderSubtle),
                const SizedBox(height: 10),

                // Bottom Meta: Rate & Warehouse Bay
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item.location,
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '₹${item.dailyRate.toStringAsFixed(0)} / day',
                      style: AppTextStyles.monoLabel.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.forestObsidian,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: item.statusBgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: item.statusColor.withValues(alpha: 0.3),
          width: 0.75,
        ),
      ),
      child: Text(
        item.status.toUpperCase(),
        style: AppTextStyles.badgeText.copyWith(
          fontSize: 9,
          color: item.statusColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Sound Systems':
        return Icons.speaker_group_rounded;
      case 'Stage Lighting':
        return Icons.light_mode_rounded;
      case 'Video & Screens':
        return Icons.tv_rounded;
      case 'Staging':
        return Icons.grid_view_rounded;
      case 'Event Furniture':
        return Icons.chair_rounded;
      case 'Cables & Distro':
      default:
        return Icons.cable_rounded;
    }
  }
}
