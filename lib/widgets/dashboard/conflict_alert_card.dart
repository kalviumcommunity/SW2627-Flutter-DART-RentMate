import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// High-priority operational alert card highlighting double-booking conflicts.
///
/// Directly addresses the core RentFlow problem statement:
/// Catching overlapping equipment commitments BEFORE warehouse loading begins.
class ConflictAlertCard extends StatelessWidget {
  final int conflictCount;
  final String description;
  final VoidCallback onResolveTap;

  const ConflictAlertCard({
    super.key,
    required this.conflictCount,
    required this.description,
    required this.onResolveTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.crimsonSubtle,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        border: Border.all(
          color: AppColors.hazardCrimson.withValues(alpha: 0.4),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppColors.hazardCrimson,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.priority_high_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '$conflictCount Equipment Conflict Detected',
                  style: AppTextStyles.cardTitle.copyWith(
                    color: AppColors.hazardCrimson,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.hazardCrimson,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'CRITICAL',
                  style: AppTextStyles.monoLabel.copyWith(
                    fontSize: 10,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textPrimary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onResolveTap,
              icon: const Icon(Icons.arrow_forward_rounded, size: 16),
              label: const Text('Resolve Conflict'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.hazardCrimson,
                textStyle: AppTextStyles.buttonLabel.copyWith(fontSize: 13),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                  side: BorderSide(
                    color: AppColors.hazardCrimson.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
