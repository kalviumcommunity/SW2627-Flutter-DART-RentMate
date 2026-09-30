import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Progress visualizer showing packed equipment completion percentage for warehouse staff.
class DispatchProgressBar extends StatelessWidget {
  final int packedCount;
  final int totalCount;

  const DispatchProgressBar({
    super.key,
    required this.packedCount,
    required this.totalCount,
  });

  double get fraction => totalCount > 0 ? (packedCount / totalCount).clamp(0.0, 1.0) : 0.0;
  int get percentage => (fraction * 100).round();
  bool get isCompleted => totalCount > 0 && packedCount >= totalCount;

  @override
  Widget build(BuildContext context) {
    final statusColor =
        isCompleted ? AppColors.successGreen : AppColors.industrialAmber;

    return Container(
      padding: const EdgeInsets.all(14),
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
              Text(
                'Loading Dock Progress',
                style: AppTextStyles.cardTitle.copyWith(fontSize: 13),
              ),
              Row(
                children: [
                  Text(
                    '$packedCount of $totalCount packed',
                    style: AppTextStyles.monoLabel.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppColors.successSubtle
                          : AppColors.amberSubtle,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '$percentage%',
                      style: AppTextStyles.monoLabel.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 8,
              backgroundColor: AppColors.surfaceMuted,
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ),
        ],
      ),
    );
  }
}
