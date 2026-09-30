import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/dispatch_item.dart';

/// Touch-friendly checklist item row designed for warehouse loading crew.
///
/// Flutter & Dart Concepts:
/// - High-contrast checkbox state with immediate visual feedback.
/// - Clear typography for piece count and physical flight case identifiers.
class DispatchChecklistTile extends StatelessWidget {
  final DispatchItem item;
  final ValueChanged<bool> onTogglePacked;

  const DispatchChecklistTile({
    super.key,
    required this.item,
    required this.onTogglePacked,
  });

  @override
  Widget build(BuildContext context) {
    final isPacked = item.isPacked;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isPacked ? const Color(0xFFF9FDFB) : AppColors.pureWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPacked ? AppColors.alpineEvergreen : AppColors.borderSubtle,
          width: isPacked ? 1.5 : 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTogglePacked(!isPacked),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Custom Large Touch Checkbox
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isPacked
                        ? AppColors.alpineEvergreen
                        : AppColors.pureWhite,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isPacked
                          ? AppColors.alpineEvergreen
                          : AppColors.structuralBorder,
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: isPacked
                        ? const Icon(
                            Icons.check_rounded,
                            size: 18,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 14),

                // Equipment Thumbnail / Category Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isPacked
                        ? AppColors.evergreenSubtle
                        : AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Icon(
                      item.iconData,
                      size: 20,
                      color: isPacked
                          ? AppColors.alpineEvergreen
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Name & Flight Case Identifier
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.equipmentName,
                        style: AppTextStyles.cardTitle.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          decoration:
                              isPacked ? TextDecoration.lineThrough : null,
                          color: isPacked
                              ? AppColors.textSecondary
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Text(
                            item.caseIdentifier,
                            style: AppTextStyles.monoLabel.copyWith(
                              fontSize: 11,
                              color: isPacked
                                  ? AppColors.textMuted
                                  : AppColors.forestObsidian,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text('•', style: AppTextStyles.bodySmall),
                          const SizedBox(width: 6),
                          Text(
                            item.stagingLocation,
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Quantity & Status Chip
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isPacked
                            ? AppColors.evergreenSubtle
                            : AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${item.quantity} Units',
                        style: AppTextStyles.monoLabel.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isPacked
                              ? AppColors.alpineEvergreen
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isPacked ? 'PACKED' : 'PENDING',
                      style: AppTextStyles.badgeText.copyWith(
                        fontSize: 9,
                        color: isPacked
                            ? AppColors.successGreen
                            : AppColors.industrialAmber,
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
}
