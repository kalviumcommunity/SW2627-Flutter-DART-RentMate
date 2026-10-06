import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/rentflow_button.dart';
import '../../widgets/rentflow_text_field.dart';

/// Coordinator Authentication screen.
///
/// Flutter & Dart Concepts Taught:
/// - Form handling & `TextEditingController`: Manages text input state.
/// - Password visibility toggle: Demonstrates local state updates with `setState()`.
/// - Keyboard responsiveness: `SingleChildScrollView` prevents render overflow
///   when the software keyboard slides up on Android/iOS.
/// - Social Auth placeholders: Outlined secondary buttons following HIG guidelines.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(text: 'mayank@rentflow.ops');
  final _passwordController = TextEditingController(text: '••••••••');
  bool _obscurePassword = true;
  bool _rememberMe = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignIn() {
    setState(() => _isLoading = true);

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Welcome back! Signed in as ${_emailController.text.isNotEmpty ? _emailController.text : "Coordinator"}.',
            ),
            backgroundColor: AppColors.alpineEvergreen,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.screenPaddingH,
              vertical: 24.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Brand Mark
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.alpineEvergreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.event_available_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(height: 20),

                // Screen Heading
                Text(
                  'Welcome Back',
                  style: AppTextStyles.screenTitle.copyWith(fontSize: 24),
                ),
                const SizedBox(height: 6),
                Text(
                  'Sign in to coordinate event equipment, dispatch schedules, and inventory.',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 28),

                // Email Input
                RentFlowTextField(
                  label: 'Work Email',
                  hintText: 'name@company.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                ),
                const SizedBox(height: 16),

                // Password Input with Visibility Toggle
                RentFlowTextField(
                  label: 'Password',
                  hintText: 'Enter your password',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  prefixIcon: Icons.lock_outline_rounded,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 12),

                // Remember Me & Forgot Password Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          height: 24,
                          width: 24,
                          child: Checkbox(
                            value: _rememberMe,
                            activeColor: AppColors.alpineEvergreen,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            onChanged: (val) {
                              setState(() {
                                _rememberMe = val ?? false;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Remember me',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Password reset link will be sent to your administrator.',
                            ),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Text(
                        'Forgot password?',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.alpineEvergreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Primary Sign In Button
                RentFlowButton(
                  label: 'Sign In to Operations',
                  isLoading: _isLoading,
                  onPressed: _handleSignIn,
                  icon: Icons.login_rounded,
                ),
                const SizedBox(height: 24),

                // Divider with "or continue with"
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'OR',
                        style: AppTextStyles.monoLabel.copyWith(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 20),

                // Social Logins (Google & Apple)
                RentFlowSecondaryButton(
                  label: 'Continue with Google Workspace',
                  leading: const Icon(
                    Icons.g_mobiledata_rounded,
                    size: 24,
                    color: AppColors.textPrimary,
                  ),
                  onPressed: _handleSignIn,
                ),
                const SizedBox(height: 12),
                RentFlowSecondaryButton(
                  label: 'Continue with Apple ID',
                  leading: const Icon(
                    Icons.apple_rounded,
                    size: 20,
                    color: AppColors.textPrimary,
                  ),
                  onPressed: _handleSignIn,
                ),
                const SizedBox(height: 28),

                // Sign Up Entry Point
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: AppTextStyles.bodySmall,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushNamed(AppRoutes.signUp);
                        },
                        child: Text(
                          'Sign Up',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.alpineEvergreen,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
