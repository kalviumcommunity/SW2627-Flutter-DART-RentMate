import 'package:flutter/material.dart';
import '../../screens/home_screen.dart';

/// Centralized route definitions for RentFlow.
///
/// Flutter & Dart Concepts:
/// - `Map<String, WidgetBuilder>`: A key-value lookup where each route string
///   (like '/') points to a builder function that returns a Widget.
/// - `WidgetBuilder`: A Dart function typedef `Widget Function(BuildContext context)`.
///   Flutter calls this builder when navigating to the given route name.
final class AppRoutes {
  AppRoutes._();

  static const String home = '/';

  /// Table of available application routes.
  static Map<String, WidgetBuilder> get routes => {
        home: (context) => const HomeScreen(),
      };
}
