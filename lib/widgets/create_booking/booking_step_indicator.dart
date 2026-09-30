import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Polished 3-step progress indicator for the event booking workflow.
///
/// Steps:
/// 1. Event Details
/// 2. Select Equipment
/// 3. Review & Confirm
///
/// Flutter & Dart Concepts:
/// - Reusable progress widget with state-driven visual styling.
/// - Conveys current workflow step, completed checkpoints, and upcoming gates.
class BookingStepIndicator extends StatelessWidget {
  final int currentStep; // 1, 2, or 3
  final ValueChanged<int>? onStepTapped;

  const BookingStepIndicator({
    super.key,
    required this.currentStep,
    this.onStepTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.pureWhite,
        border: Border(
          bottom: BorderSide(color: AppColors.borderSubtle, width: 1),
        ),
      ),
      child: Row(
        children: [
          _buildStepNode(
            stepNumber: 1,
            label: 'Event Details',
            isActive: currentStep == 1,
            isCompleted: currentStep > 1,
          ),
          _buildConnector(isCompleted: currentStep > 1),
          _buildStepNode(
            stepNumber: 2,
            label: 'Equipment',
            isActive: currentStep == 2,
            isCompleted: currentStep > 2,
          ),
          _buildConnector(isCompleted: currentStep > 2),
          _buildStepNode(
            stepNumber: 3,
            label: 'Review',
            isActive: currentStep == 3,
            isCompleted: false,
          ),
        ],
      ),
    );
  }

  Widget _buildStepNode({
    required int stepNumber,
    required String label,
    required bool isActive,
    required bool isCompleted,
  }) {
    final Color circleBg;
    final Color iconOrTextColor;
    final Border? border;

    if (isCompleted) {
      circleBg = AppColors.alpineEvergreen;
      iconOrTextColor = Colors.white;
      border = null;
    } else if (isActive) {
      circleBg = AppColors.alpineEvergreen;
      iconOrTextColor = Colors.white;
      border = Border.all(color: AppColors.evergreenHover, width: 2);
    } else {
      circleBg = AppColors.surfaceMuted;
      iconOrTextColor = AppColors.textSecondary;
      border = Border.all(color: AppColors.structuralBorder, width: 1);
    }

    return InkWell(
      onTap: onStepTapped != null && isCompleted
          ? () => onStepTapped!(stepNumber)
          : null,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: circleBg,
                shape: BoxShape.circle,
                border: border,
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                    : Text(
                        '$stepNumber',
                        style: AppTextStyles.monoLabel.copyWith(
                          color: iconOrTextColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? AppColors.forestObsidian : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnector({required bool isCompleted}) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        color: isCompleted ? AppColors.alpineEvergreen : AppColors.borderSubtle,
      ),
    );
  }
}
