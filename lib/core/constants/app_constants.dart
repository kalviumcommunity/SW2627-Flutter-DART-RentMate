/// Application-wide constants for RentFlow.
///
/// Dart Concept:
/// - `abstract final class`: Pure static utility container; prevents instantiation.
/// - `static const`: Compile-time constants that save runtime memory.
abstract final class AppConstants {
  AppConstants._();

  // Application Identity
  static const String appName = 'RentFlow';
  static const String appTagline = 'Event Equipment Operations';
  static const String appMotto = 'Equipment. Events. Effortless.';
  static const String appVersion = 'v1.0-alpha';

  // Team & Project Details
  static const String squadNumber = 'Squad 124';
  static const String teamNumber = 'Team 04';
  static const String campusName = 'JECRC';
  static const String coordinatorName = 'Mayank Sharma';
  static const String coordinatorRole = 'Lead Event Coordinator';

  // Booking & Inventory Statuses
  static const String statusConfirmed = 'Confirmed';
  static const String statusInProgress = 'In Progress';
  static const String statusPacking = 'Packing';
  static const String statusPending = 'Pending';
  static const String statusCompleted = 'Completed';
  static const String statusConflict = 'Conflict';

  // Equipment Categories handled by RentFlow (Canonical List)
  static const List<String> equipmentCategories = [
    'All',
    'Sound',
    'Lighting',
    'Visuals',
    'Staging',
    'Power',
  ];

  /// Canonical normalization for equipment categories across all screens.
  static String normalizeCategory(String category) {
    final lower = category.toLowerCase().trim();
    if (lower.contains('sound') || lower.contains('audio')) return 'Sound';
    if (lower.contains('light')) return 'Lighting';
    if (lower.contains('visual') || lower.contains('video') || lower.contains('led')) return 'Visuals';
    if (lower.contains('stag') || lower.contains('rig')) return 'Staging';
    if (lower.contains('power') || lower.contains('ctrl') || lower.contains('control')) return 'Power';
    return category;
  }

  /// Checks whether an item category matches a selected filter category.
  static bool categoryMatches(String itemCategory, String selectedCategory) {
    if (selectedCategory == 'All') return true;
    return normalizeCategory(itemCategory) == normalizeCategory(selectedCategory);
  }

  // Spacing & Layout Tokens (Responsive standards)
  static const double screenPaddingH = 16.0;
  static const double screenPaddingV = 16.0;
  static const double cardRadius = 14.0;
  static const double inputRadius = 10.0;
  static const double buttonRadius = 10.0;
}
