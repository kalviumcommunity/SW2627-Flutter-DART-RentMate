import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/equipment_item.dart';

/// Equipment card used in Step 2: Select Equipment.
///
/// Flutter & Dart Concepts:
/// - Clear hierarchy conveying TOTAL, AVAILABLE, and REQUESTED stock metrics.
/// - Distinct visual states: Normal, Selected, Limited Stock, Out of Stock, and CONFLICT.
/// - Micro-interactions on quantity stepper (- / +).
class EquipmentSelectorTile extends StatelessWidget {
  final EquipmentItem item;
  final int requestedQuantity;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback? onResolveConflictTap;

  const EquipmentSelectorTile({
    super.key,
    required this.item,
    required this.requestedQuantity,
    required this.onQuantityChanged,
    this.onResolveConflictTap,
  });

  bool get hasConflict => requestedQuantity > item.availableQuantity;
  bool get isSelected => requestedQuantity > 0;
  bool get isOutOfStock => item.availableQuantity <= 0;

  @override
  Widget build(BuildContext context) {
    // Dynamic border and surface color reflecting allocation state
    final Color borderColor;
    final Color cardBackground;

    if (hasConflict) {
      borderColor = AppColors.hazardCrimson;
      cardBackground = const Color(0xFFFFF5F5);
    } else if (isSelected) {
      borderColor = AppColors.alpineEvergreen;
      cardBackground = const Color(0xFFF4F9F6);
    } else {
      borderColor = AppColors.borderSubtle;
      cardBackground = AppColors.pureWhite;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
          width: hasConflict || isSelected ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Equipment Icon / Thumbnail
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: isOutOfStock
                        ? AppColors.surfaceMuted
                        : AppColors.evergreenSubtle,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Center(
                    child: Icon(
                      _getCategoryIcon(item.category),
                      color: isOutOfStock
                          ? AppColors.textMuted
                          : AppColors.alpineEvergreen,
                      size: 26,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Name, SKU, Category, and Rate
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
                            style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
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
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.borderSubtle),

          // Operational Inventory Metrics Strip: TOTAL vs AVAILABLE vs REQUESTED
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Total and Available Metrics
                Row(
                  children: [
                    _buildMetricPill(
                      label: 'TOTAL',
                      value: '${item.totalQuantity}',
                      color: AppColors.textSecondary,
                      bgColor: AppColors.surfaceMuted,
                    ),
                    const SizedBox(width: 8),
                    _buildMetricPill(
                      label: 'AVAILABLE',
                      value: '${item.availableQuantity}',
                      color: item.availableQuantity > 0
                          ? AppColors.alpineEvergreen
                          : AppColors.hazardCrimson,
                      bgColor: item.availableQuantity > 0
                          ? AppColors.evergreenSubtle
                          : AppColors.crimsonSubtle,
                    ),
                  ],
                ),

                // Quantity Stepper
                _buildStepper(context),
              ],
            ),
          ),

          // Visual Conflict Warning Banner (if requested exceeds available)
          if (hasConflict)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: const BoxDecoration(
                color: AppColors.crimsonSubtle,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
                border: Border(
                  top: BorderSide(color: Color(0xFFFCA5A5), width: 1),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    size: 18,
                    color: AppColors.hazardCrimson,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Shortage of ${requestedQuantity - item.availableQuantity} unit(s)! Exceeds stock.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.hazardCrimson,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  if (onResolveConflictTap != null)
                    InkWell(
                      onTap: onResolveConflictTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.hazardCrimson,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Resolve',
                          style: AppTextStyles.badgeText.copyWith(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMetricPill({
    required String label,
    required String value,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: AppTextStyles.badgeText.copyWith(
              fontSize: 10,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.monoLabel.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepper(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Decrement button
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: requestedQuantity > 0
                ? () => onQuantityChanged(requestedQuantity - 1)
                : null,
            borderRadius: BorderRadius.circular(6),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: requestedQuantity > 0
                    ? AppColors.pureWhite
                    : AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: requestedQuantity > 0
                      ? AppColors.structuralBorder
                      : AppColors.borderSubtle,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.remove_rounded,
                  size: 16,
                  color: requestedQuantity > 0
                      ? AppColors.forestObsidian
                      : AppColors.textMuted,
                ),
              ),
            ),
          ),
        ),

        // Requested Count display
        Container(
          constraints: const BoxConstraints(minWidth: 40),
          alignment: Alignment.center,
          child: Text(
            '$requestedQuantity',
            style: AppTextStyles.monoLabel.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: hasConflict
                  ? AppColors.hazardCrimson
                  : (isSelected
                      ? AppColors.alpineEvergreen
                      : AppColors.textPrimary),
            ),
          ),
        ),

        // Increment button
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isOutOfStock
                ? null
                : () => onQuantityChanged(requestedQuantity + 1),
            borderRadius: BorderRadius.circular(6),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isOutOfStock
                    ? AppColors.surfaceMuted
                    : AppColors.alpineEvergreen,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Icon(
                  Icons.add_rounded,
                  size: 16,
                  color: isOutOfStock ? AppColors.textMuted : Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    if (isOutOfStock) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.crimsonSubtle,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          'OUT OF STOCK',
          style: AppTextStyles.badgeText.copyWith(
            fontSize: 9,
            color: AppColors.hazardCrimson,
          ),
        ),
      );
    }

    if (item.isLimited) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.amberSubtle,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          'LIMITED (${item.availableQuantity} LEFT)',
          style: AppTextStyles.badgeText.copyWith(
            fontSize: 9,
            color: AppColors.industrialAmber,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.evergreenSubtle,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'AVAILABLE',
        style: AppTextStyles.badgeText.copyWith(
          fontSize: 9,
          color: AppColors.alpineEvergreen,
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
      default:
        return Icons.inventory_2_outlined;
    }
  }
}
