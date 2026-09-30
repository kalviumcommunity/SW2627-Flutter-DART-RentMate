import 'package:flutter/material.dart';

/// Reusable informational card component for RentFlow.
///
/// Flutter & Dart Concepts Taught:
/// - `StatelessWidget`: A lightweight widget that has no internal mutable state.
///   Its appearance depends only on the parameters passed into its constructor.
/// - `const InfoCard({super.key, ...})`: The `const` constructor tells Flutter
///   that instances with constant arguments can be canonicalized (reused in
///   memory), avoiding unnecessary widget rebuilds.
/// - `required this.title`: Named parameter that cannot be null. Dart enforces
///   this at compile time.
/// - `Theme.of(context)`: InheritedWidget lookup pattern. Retrieves the nearest
///   Theme data up the widget tree so this widget automatically matches brand colors.
class InfoCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color? iconColor;
  final Widget? trailing;

  const InfoCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.iconColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = iconColor ?? theme.colorScheme.primary;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 14.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF475569),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8.0),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}
