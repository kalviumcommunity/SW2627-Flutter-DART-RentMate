import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Equipment Conflict Resolution Bottom Sheet (RentFlow Section 5.7).
///
/// Explains shortages when requested equipment exceeds real-time available stock
/// and offers immediate resolution choices:
/// 1. Reduce quantity to feasible amount
/// 2. Change event time / date
/// 3. Request Waitlist / Cross-rental
class BookingConflictSheet extends StatelessWidget {
  final String equipmentName;
  final String sku;
  final int requestedQty;
  final int availableQty;
  final String? conflictingEvent;
  final VoidCallback? onReduceQuantity;
  final VoidCallback? onChangeTime;
  final VoidCallback? onJoinWaitlist;

  const BookingConflictSheet({
    super.key,
    this.equipmentName = 'JBL VRX932LA Line Array Speaker',
    this.sku = 'SND-JBL-VRX932',
    this.requestedQty = 12,
    this.availableQty = 8,
    this.conflictingEvent = 'Apex Tech Annual Summit (BK-4091)',
    this.onReduceQuantity,
    this.onChangeTime,
    this.onJoinWaitlist,
  });

  static Future<void> show(
    BuildContext context, {
    String equipmentName = 'JBL VRX932LA Line Array Speaker',
    String sku = 'SND-JBL-VRX932',
    int requestedQty = 12,
    int availableQty = 8,
    String? conflictingEvent = 'Apex Tech Annual Summit (BK-4091)',
    VoidCallback? onReduceQuantity,
    VoidCallback? onChangeTime,
    VoidCallback? onJoinWaitlist,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BookingConflictSheet(
        equipmentName: equipmentName,
        sku: sku,
        requestedQty: requestedQty,
        availableQty: availableQty,
        conflictingEvent: conflictingEvent,
        onReduceQuantity: onReduceQuantity,
        onChangeTime: onChangeTime,
        onJoinWaitlist: onJoinWaitlist,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int shortage = requestedQty - availableQty;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 24,
            offset: Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: AppColors.softStone,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Warning Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.dangerSubtle,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.danger,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Equipment Conflict Detected',
                        style: AppTextStyles.screenTitle.copyWith(
                          fontSize: 18,
                          color: AppColors.danger,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Insufficient stock for requested event schedule',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.slate,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Equipment details & Metrics Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bone,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.softStone),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          equipmentName,
                          style: AppTextStyles.cardTitle.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.paper,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.softStone),
                        ),
                        child: Text(
                          sku,
                          style: AppTextStyles.monoLabel.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.inkBlack,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // 3-Metric Comparative Row
                  Row(
                    children: [
                      _buildMetricCell('REQUESTED', '$requestedQty', AppColors.inkBlack),
                      _buildDivider(),
                      _buildMetricCell('AVAILABLE', '$availableQty', AppColors.success),
                      _buildDivider(),
                      _buildMetricCell('SHORTAGE', '-$shortage', AppColors.danger),
                    ],
                  ),

                  if (conflictingEvent != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.warningSubtle,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, size: 16, color: AppColors.warning),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Overlapping with: $conflictingEvent',
                              style: AppTextStyles.bodySmall.copyWith(
                                fontSize: 11,
                                color: AppColors.inkBlack,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Resolution Options Title
            Text(
              'RESOLUTION CHOICES',
              style: AppTextStyles.monoLabel.copyWith(
                fontSize: 11,
                color: AppColors.slate,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),

            // Choice 1: Reduce quantity
            _buildResolutionOption(
              icon: Icons.tune_rounded,
              title: 'Reduce Quantity to $availableQty Units',
              subtitle: 'Proceed immediately with currently available warehouse stock.',
              isRecommended: true,
              onTap: () {
                Navigator.pop(context);
                if (onReduceQuantity != null) onReduceQuantity!();
              },
            ),
            const SizedBox(height: 8),

            // Choice 2: Change event time
            _buildResolutionOption(
              icon: Icons.edit_calendar_rounded,
              title: 'Change Event Dates / Time',
              subtitle: 'Select an alternate date interval when full stock is free.',
              isRecommended: false,
              onTap: () {
                Navigator.pop(context);
                if (onChangeTime != null) onChangeTime!();
              },
            ),
            const SizedBox(height: 8),

            // Choice 3: Waitlist / Cross-rental
            _buildResolutionOption(
              icon: Icons.alt_route_rounded,
              title: 'Cross-Rent / Partner Sourcing',
              subtitle: 'Source $shortage additional units from our partner network.',
              isRecommended: false,
              onTap: () {
                Navigator.pop(context);
                if (onJoinWaitlist != null) onJoinWaitlist!();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCell(String label, String value, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: AppTextStyles.monoLabel.copyWith(
              fontSize: 9,
              color: AppColors.slate,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.monoMetric.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 36,
      color: AppColors.softStone,
    );
  }

  Widget _buildResolutionOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isRecommended,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isRecommended ? AppColors.copperSubtle : AppColors.bone,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isRecommended ? AppColors.burntCopper : AppColors.softStone,
            width: isRecommended ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isRecommended ? AppColors.burntCopper : AppColors.paper,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 18,
                color: isRecommended ? Colors.white : AppColors.inkBlack,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: AppTextStyles.cardTitle.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.inkBlack,
                          ),
                        ),
                      ),
                      if (isRecommended) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.burntCopper,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'RECOMMENDED',
                            style: AppTextStyles.monoLabel.copyWith(
                              fontSize: 8,
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 11,
                      color: AppColors.slate,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.slate,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
