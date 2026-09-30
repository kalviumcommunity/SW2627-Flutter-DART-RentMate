import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Professional operational splash screen for RentFlow.
///
/// Flutter & Dart Concepts Taught:
/// - `StatefulWidget`: Manages the lifecycle of a timer and subtle entrance animation.
/// - `Timer`: Asynchronous utility in `dart:async` that executes a callback after a duration.
/// - `dispose()`: Crucial lifecycle method to cancel timers and prevent memory leaks.
/// - `Navigator.pushReplacementNamed`: Replaces the splash screen on the navigation
///   stack so pressing device 'Back' does not return to splash.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _controller.forward();

    // Subtle 1.8 second delay before smoothly transitioning to Login
    _navigationTimer = Timer(const Duration(milliseconds: 1800), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      }
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.forestObsidian,
      body: Stack(
        children: [
          // Background ambient gradient representing stage/lighting environment
          Positioned(
            top: -120,
            right: -100,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.alpineEvergreen.withValues(alpha: 0.28),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.alpineEvergreen.withValues(alpha: 0.35),
                    blurRadius: 100,
                    spreadRadius: 40,
                  ),
                ],
              ),
            ),
          ),

          // Central Brand Mark & Typography
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Brand Mark Container
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: AppColors.alpineEvergreen,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.alpineEvergreen.withValues(alpha: 0.4),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.event_available_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Brand Title
                  Text(
                    AppConstants.appName,
                    style: AppTextStyles.brandTitle.copyWith(
                      color: Colors.white,
                      fontSize: 32,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Motto
                  Text(
                    AppConstants.appMotto,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.75),
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Version & Campus Footer
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                '${AppConstants.squadNumber} • ${AppConstants.campusName}',
                style: AppTextStyles.monoLabel.copyWith(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
