import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Reusable search bar with clear button and trailing filter action.
class RentFlowSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterTap;
  final String hintText;

  const RentFlowSearchBar({
    super.key,
    this.controller,
    this.onChanged,
    this.onFilterTap,
    this.hintText = 'Search bookings, venues, equipment...',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.pureWhite,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.structuralBorder, width: 1),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                const Icon(
                  Icons.search_rounded,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: controller,
                    onChanged: onChanged,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: hintText,
                      hintStyle: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textMuted,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (onFilterTap != null) ...[
          const SizedBox(width: 8),
          Material(
            color: AppColors.pureWhite,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              onTap: onFilterTap,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.structuralBorder,
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  color: AppColors.forestObsidian,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
