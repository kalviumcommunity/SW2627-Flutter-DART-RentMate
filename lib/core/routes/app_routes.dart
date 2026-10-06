import 'package:flutter/material.dart';
import '../../screens/login/login_screen.dart';
import '../../screens/signup/signup_screen.dart';

/// Centralized route definitions for RentFlow Auth.
final class AppRoutes {
  AppRoutes._();

  static const String login = '/';
  static const String signUp = '/signup';

  /// Table of available application routes.
  static Map<String, WidgetBuilder> get routes => {
        login: (context) => const LoginScreen(),
        signUp: (context) => const SignUpScreen(),
      };
}
