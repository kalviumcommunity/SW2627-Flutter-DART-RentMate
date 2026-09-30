import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/equipment_item.dart';
import '../../widgets/rentflow_button.dart';

/// Resolution outcome chosen by coordinator on the Conflict Screen.
enum ConflictAction {
  reduceQuantity,
  changeEventTime,
  joinWaitlist,
}

/// Screen 3: Equipment Conflict & Resolution workflow.
///
/// This screen directly solves the core business problem:
/// Preventing overlapping bookings and double-committing equipment in the warehouse.
/// Rather than an uninformative red error, it gives coordinators clear shortage metrics,
/// identifies the overlapping booking, and offers 3 actionable resolution pathways.
class EquipmentConflictScreen extends StatelessWidget {
  final EquipmentItem item;
  final int requestedQuantity;
  final ValueChanged<ConflictAction>? onActionSelected;

  const EquipmentConflictScreen({
    super.key,
    required this.item,
    required this.requestedQuantity,
    this.onActionSelected,
  });

  int get availableQuantity => item.availableQuantity;
  int get shortage => requestedQuantity - availableQuantity;

  @override
  Widget build(BuildContext context) {
    final conflictingName =
        item.conflictingBookingName ?? 'TechCorp Conference';
    final conflictingSchedule =
        item.conflictingSchedule ?? '14 Jan • 12 PM – 6 PM';

    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      appBar: AppBar(
        title: Text(
          'Equipment Conflict',
          style: AppTextStyles.screenTitle.copyWith(fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          children: [
            // 1. High-Impact Warning Banner Header
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.crimsonSubtle,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFFCA5A5),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.hazardCrimson,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Not Enough Available',
                              style: AppTextStyles.screenTitle.copyWith(
                                fontSize: 18,
                                color: AppColors.hazardCrimson,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Inventory shortage detected for the requested schedule.',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: const Color(0xFF7F1D1D),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Equipment Name & SKU
                  Text(
                    item.name,
                    style: AppTextStyles.cardTitle.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.forestObsidian,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${item.sku} • ${item.category}',
                    style: AppTextStyles.monoLabel.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Divider(height: 24, color: Color(0xFFFECACA)),

                  // Shortage Breakdown Metric Grid: REQUESTED vs AVAILABLE vs SHORTAGE
                  Row(
                    children: [
                      _buildStockMetric(
                        label: 'REQUESTED',
                        value: '$requestedQuantity',
                        textColor: AppColors.textPrimary,
                        bgColor: AppColors.pureWhite,
                      ),
                      const SizedBox(width: 8),
                      _buildStockMetric(
                        label: 'AVAILABLE',
                        value: '$availableQuantity',
                        textColor: availableQuantity > 0
                            ? AppColors.alpineEvergreen
                            : AppColors.hazardCrimson,
                        bgColor: AppColors.pureWhite,
                      ),
                      const SizedBox(width: 8),
                      _buildStockMetric(
                        label: 'SHORTAGE',
                        value: '+$shortage',
                        textColor: AppColors.hazardCrimson,
                        bgColor: const Color(0xFFFFE4E6),
                        isShortage: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 2. Conflicting Booking Identification
            Text(
              'CONFLICTING RESERVATION IDENTIFIED',
              style: AppTextStyles.monoLabel.copyWith(
                fontSize: 11,
                letterSpacing: 0.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.pureWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_month_outlined,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            conflictingName,
                            style: AppTextStyles.cardTitle.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.crimsonSubtle,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'CONFIRMED',
                          style: AppTextStyles.badgeText.copyWith(
                            fontSize: 9,
                            color: AppColors.hazardCrimson,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        conflictingSchedule,
                        style: AppTextStyles.monoLabel.copyWith(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.warehouse_outlined,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Committed Units: ${item.conflictingUnits ?? (item.totalQuantity - item.availableQuantity)} (Loading Dock #1)',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 3. Actionable Resolution Choices
            Text(
              'RECOMMENDED RESOLUTIONS',
              style: AppTextStyles.monoLabel.copyWith(
                fontSize: 11,
                letterSpacing: 0.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),

            // Action 1: Reduce Quantity
            _buildResolutionCard(
              context: context,
              title: 'Reduce Quantity to $availableQuantity Units',
              description:
                  'Instantly adjust the booking request to match currently available warehouse stock.',
              icon: Icons.compress_rounded,
              accentColor: AppColors.alpineEvergreen,
              isPrimary: true,
              onTap: () {
                if (onActionSelected != null) {
                  onActionSelected!(ConflictAction.reduceQuantity);
                } else {
                  Navigator.of(context).pop(ConflictAction.reduceQuantity);
                }
              },
            ),
            const SizedBox(height: 12),

            // Action 2: Change Event Time
            _buildResolutionCard(
              context: context,
              title: 'Change Event Date or Time',
              description:
                  'Return to Step 1 to choose an alternative schedule without warehouse conflicts.',
              icon: Icons.schedule_rounded,
              accentColor: AppColors.industrialAmber,
              isPrimary: false,
              onTap: () {
                if (onActionSelected != null) {
                  onActionSelected!(ConflictAction.changeEventTime);
                } else {
                  Navigator.of(context).pop(ConflictAction.changeEventTime);
                }
              },
            ),
            const SizedBox(height: 12),

            // Action 3: Keep in Waitlist
            _buildResolutionCard(
              context: context,
              title: 'Keep Shortage in Waitlist',
              description:
                  'Reserve the $availableQuantity available units now and add the $shortage shortage units to the waitlist queue.',
              icon: Icons.format_list_bulleted_add,
              accentColor: AppColors.slateSteel,
              isPrimary: false,
              onTap: () {
                if (onActionSelected != null) {
                  onActionSelected!(ConflictAction.joinWaitlist);
                } else {
                  Navigator.of(context).pop(ConflictAction.joinWaitlist);
                }
              },
            ),
            const SizedBox(height: 24),

            RentFlowSecondaryButton(
              label: 'Return to Equipment Selector',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockMetric({
    required String label,
    required String value,
    required Color textColor,
    required Color bgColor,
    bool isShortage = false,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isShortage
                ? const Color(0xFFFCA5A5)
                : AppColors.structuralBorder,
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: AppTextStyles.badgeText.copyWith(
                fontSize: 10,
                color: isShortage
                    ? AppColors.hazardCrimson
                    : AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTextStyles.monoLabel.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResolutionCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required Color accentColor,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.pureWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isPrimary ? accentColor : AppColors.structuralBorder,
              width: isPrimary ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isPrimary ? accentColor : AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: isPrimary ? Colors.white : AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.cardTitle.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isPrimary
                            ? AppColors.forestObsidian
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: isPrimary ? accentColor : AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
