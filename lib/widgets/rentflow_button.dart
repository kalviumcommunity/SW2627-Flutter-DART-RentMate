import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

/// Primary action button for the RentFlow design system.
///
/// Flutter & Dart Concepts Taught:
/// - `Widget composition`: Wraps standard `ElevatedButton` with centralized
///   tokens so brand updates propagate app-wide automatically.
/// - `VoidCallback? onPressed`: Function typedef `void Function()`. If null,
///   Flutter automatically renders the button in a disabled state.
/// - `Widget? icon`: Flexible composition allowing buttons with or without icons.
class RentFlowButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final double height;

  const RentFlowButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.height = 48.0,
  });

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? AppColors.alpineEvergreen;
    final fg = textColor ?? Colors.white;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          disabledBackgroundColor: AppColors.structuralBorder,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(fg),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18, color: fg),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: AppTextStyles.buttonLabel.copyWith(color: fg),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Outlined secondary button variant.
class RentFlowSecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Widget? leading;
  final double height;

  const RentFlowSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.leading,
    this.height = 48.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.pureWhite,
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.structuralBorder, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: 10),
            ],
            Text(
              label,
              style: AppTextStyles.buttonLabel.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
