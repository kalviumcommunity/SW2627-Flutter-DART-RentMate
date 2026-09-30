import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Event summary card and dock assignment header for the warehouse dispatch view.
class DispatchEventHeader extends StatelessWidget {
  final String eventName;
  final String venue;
  final String schedule;
  final String loadingDock;
  final VoidCallback? onSwitchEvent;

  const DispatchEventHeader({
    super.key,
    required this.eventName,
    required this.venue,
    required this.schedule,
    required this.loadingDock,
    this.onSwitchEvent,
  });

  @override
  Widget build(BuildContext context) {
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.evergreenSubtle,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  loadingDock.toUpperCase(),
                  style: AppTextStyles.badgeText.copyWith(
                    fontSize: 10,
                    color: AppColors.alpineEvergreen,
                  ),
                ),
              ),
              if (onSwitchEvent != null)
                InkWell(
                  onTap: onSwitchEvent,
                  child: Row(
                    children: [
                      Text(
                        'Change Event',
                        style: AppTextStyles.badgeText.copyWith(
                          color: AppColors.alpineEvergreen,
                          fontSize: 11,
                        ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: AppColors.alpineEvergreen,
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          Text(
            eventName,
            style: AppTextStyles.cardTitle.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),

          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  venue,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          Row(
            children: [
              const Icon(
                Icons.access_time_rounded,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                schedule,
                style: AppTextStyles.monoLabel.copyWith(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
