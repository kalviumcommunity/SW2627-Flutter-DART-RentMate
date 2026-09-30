import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/booking_model.dart';
import 'status_badge.dart';

/// Professional operational card displaying an equipment booking.
///
/// Flutter Concepts:
/// - Reusable card displaying complex business entities.
/// - Conditional widget rendering (e.g. conflict warning banner).
/// - JetBrains Mono for alphanumeric tracking tags (e.g. 'RF-8421').
class BookingCard extends StatelessWidget {
  final BookingItem booking;
  final VoidCallback? onTap;

  const BookingCard({
    super.key,
    required this.booking,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isConflict = booking.status == AppConstants.statusConflict;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        border: Border.all(
          color: isConflict ? AppColors.hazardCrimson.withValues(alpha: 0.5) : AppColors.borderSubtle,
          width: isConflict ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppConstants.cardRadius),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: ID and Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        booking.id,
                        style: AppTextStyles.monoLabel.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.forestObsidian,
                        ),
                      ),
                    ),
                    StatusBadge(status: booking.status),
                  ],
                ),
                const SizedBox(height: 10),

                // Event Title
                Text(
                  booking.eventName,
                  style: AppTextStyles.cardTitle.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 6),

                // Venue Line
                Row(
                  children: [
                    const Icon(
                      Icons.place_outlined,
                      size: 15,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        booking.venue,
                        style: AppTextStyles.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Schedule Line
                Row(
                  children: [
                    const Icon(
                      Icons.event_outlined,
                      size: 15,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        booking.dateSchedule,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),

                const Divider(height: 20),

                // Equipment manifest summary
                Row(
                  children: [
                    const Icon(
                      Icons.inventory_2_outlined,
                      size: 15,
                      color: AppColors.alpineEvergreen,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        booking.equipmentSummary,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.evergreenSubtle,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${booking.totalUnits} Units',
                        style: AppTextStyles.monoLabel.copyWith(
                          fontSize: 11,
                          color: AppColors.alpineEvergreen,
                        ),
                      ),
                    ),
                  ],
                ),

                // Conflict Banner (if applicable)
                if (isConflict && booking.conflictDetails != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.crimsonSubtle,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.hazardCrimson.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: AppColors.hazardCrimson,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            booking.conflictDetails!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.hazardCrimson,
                              fontWeight: FontWeight.w600,
                              height: 1.3,
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
        ),
      ),
    );
  }
}
