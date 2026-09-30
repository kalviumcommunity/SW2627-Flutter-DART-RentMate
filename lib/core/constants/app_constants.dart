/// Application-wide constants for RentFlow.
///
/// Dart Concept:
/// - `class AppConstants`: A container class with a private constructor
///   (`AppConstants._()`) to prevent instantiation. In Dart, this is the
///   idiomatic way to create a static utility or constants namespace.
/// - `static const`: Compile-time constants. Dart allocates them once at
///   compile time, making them memory-efficient and immutable.
abstract final class AppConstants {
  // Prevent instantiation
  AppConstants._();

  // Application Identity
  static const String appName = 'RentFlow';
  static const String appTagline = 'Event Equipment Rental Management';
  static const String appVersion = '1.0.0 (Sprint 2 - Day 1)';

  // Team & Project Details
  static const String squadNumber = 'Squad 124';
  static const String teamNumber = 'Team 04';
  static const String campusName = 'JECRC';
  static const String memberMayank = 'Mayank Sharma (Flutter Scaffolding & Git)';
  static const String memberPrateek = 'Prateek (System Design & Planning)';

  // Equipment Categories handled by RentFlow
  static const List<String> equipmentCategories = [
    'Sound Systems',
    'Stage Lighting',
    'Event Furniture',
  ];

  // Current Sprint Scope Note
  static const String sprintStatus = 'Sprint 2 — Day 1: Foundation & Scaffolding';
}
