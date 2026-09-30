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

  // Equipment Categories handled by RentFlow
  static const List<String> equipmentCategories = [
    'Sound Systems',
    'Stage Lighting',
    'Event Furniture',
  ];

  // Spacing & Layout Tokens (Responsive standards)
  static const double screenPaddingH = 16.0;
  static const double screenPaddingV = 16.0;
  static const double cardRadius = 14.0;
  static const double inputRadius = 10.0;
  static const double buttonRadius = 10.0;
}
