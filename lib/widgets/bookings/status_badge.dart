import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Semantic status badge with color coding and indicator dot.
///
/// Flutter Concepts:
/// - Reusable tag component with automated color resolution.
/// - Demonstrates how design systems enforce consistent status indicators.
class StatusBadge extends StatelessWidget {
  final String status;
  final bool showDot;

  const StatusBadge({
    super.key,
    required this.status,
    this.showDot = true,
  });

  @override
  Widget build(BuildContext context) {
    final (textColor, bgColor) = _resolveColors(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: textColor.withValues(alpha: 0.25),
          width: 0.75,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: textColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
          ],
          Text(
            status.toUpperCase(),
            style: AppTextStyles.badgeText.copyWith(
              color: textColor,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  /// Dart 3 Record pattern matching for color tuples.
  (Color, Color) _resolveColors(String status) {
    switch (status) {
      case AppConstants.statusConflict:
        return (AppColors.hazardCrimson, AppColors.crimsonSubtle);
      case AppConstants.statusConfirmed:
        return (AppColors.successGreen, AppColors.successSubtle);
      case AppConstants.statusInProgress:
        return (AppColors.alpineEvergreen, AppColors.evergreenSubtle);
      case AppConstants.statusPacking:
      case AppConstants.statusPending:
        return (AppColors.industrialAmber, AppColors.amberSubtle);
      case AppConstants.statusCompleted:
      default:
        return (AppColors.textSecondary, AppColors.surfaceMuted);
    }
  }
}
