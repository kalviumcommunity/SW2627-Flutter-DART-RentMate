import 'package:flutter/material.dart';
import 'core/constants/app_constants.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';

/// Entry point of the RentFlow application.
///
/// Flutter & Dart Concepts Taught:
/// - `void main()`: The standard entry point function for any Dart program.
///   Execution starts right here when the app is launched.
/// - `runApp(Widget app)`: A Flutter framework function that attaches the given
///   widget to the screen, creating the root of the widget tree.
/// - `const RentFlowApp()`: Uses Dart's `const` constructor to optimize memory
///   by reusing the same instance whenever possible.
void main() {
  runApp(const RentFlowApp());
}

/// Root widget of the RentFlow application.
///
/// Flutter Concepts Taught:
/// - `StatelessWidget`: A widget that never changes after being built.
///   It does not hold mutable state.
/// - `MaterialApp`: The foundational wrapper for Material Design apps. It
///   provides navigation, themes, localization, and high-level routing.
/// - `BuildContext`: A handle to the location of this widget in the widget tree.
///   Used by Flutter to look up themes, media queries, and navigator state.
class RentFlowApp extends StatelessWidget {
  const RentFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.home,
      routes: AppRoutes.routes,
    );
  }
}
