import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/rentflow_button.dart';
import '../../widgets/rentflow_text_field.dart';

/// Coordinator Authentication screen (Industrial Atelier).
///
/// Hierarchy:
/// 1. Cinematic atmospheric header in Ink Black with amber/copper lighting accents.
/// 2. Brand Identity: RENTFLOW • EQUIPMENT. EVENTS. EXECUTED.
/// 3. Bone/Paper form surface with Burnt Copper primary action.
/// 4. Secondary workspace authentication actions (Google & Apple).
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

        final enteredText = _emailController.text.trim();
        String userName = AppConstants.coordinatorName;
        if (enteredText.isNotEmpty) {
          if (enteredText.contains('@')) {
            final part = enteredText.split('@').first;
            userName = part.isNotEmpty
                ? part[0].toUpperCase() + part.substring(1)
                : AppConstants.coordinatorName;
          } else {
            userName = enteredText;
          }
        }

        Navigator.of(context).pushReplacementNamed(
          AppRoutes.dashboard,
          arguments: userName,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.inkBlack,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Atmospheric Brand Header (Ink Black + Warm Lighting)
              _buildAtmosphericHeader(),

              // Elevated Paper/Bone Form Container
              Container(
                decoration: const BoxDecoration(
                  color: AppColors.bone,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.screenPaddingH,
                  vertical: 28.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Heading & Subtitle
                    Text(
                      'Welcome Back',
                      style: AppTextStyles.screenTitle.copyWith(
                        fontSize: 24,
                        color: AppColors.inkBlack,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Sign in to coordinate event equipment, dispatch schedules, and inventory.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.slate,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Inputs Section inside Paper Container
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.paper,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.softStone,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Work Email
                          RentFlowTextField(
                            label: 'Work Email',
                            hintText: 'name@company.com',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: Icons.email_outlined,
                          ),
                          const SizedBox(height: 16),

                          // Password with Visibility Toggle
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
                                color: AppColors.slate,
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
                                    height: 22,
                                    width: 22,
                                    child: Checkbox(
                                      value: _rememberMe,
                                      activeColor: AppColors.burntCopper,
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
                                      color: AppColors.inkBlack,
                                      fontWeight: FontWeight.w500,
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
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  'Forgot password?',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.burntCopper,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Primary Sign In Button (Burnt Copper)
                    RentFlowButton(
                      label: 'Sign In to Operations',
                      isLoading: _isLoading,
                      onPressed: _handleSignIn,
                      icon: Icons.arrow_forward_rounded,
                    ),
                    const SizedBox(height: 22),

                    // Section Divider
                    Row(
                      children: [
                        const Expanded(
                          child: Divider(color: AppColors.softStone),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'OR',
                            style: AppTextStyles.monoLabel.copyWith(
                              color: AppColors.slate,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Divider(color: AppColors.softStone),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Secondary Social Logins (Google & Apple)
                    RentFlowSecondaryButton(
                      label: 'Continue with Google Workspace',
                      leading: const Icon(
                        Icons.g_mobiledata_rounded,
                        size: 24,
                        color: AppColors.inkBlack,
                      ),
                      onPressed: _handleSignIn,
                    ),
                    const SizedBox(height: 10),
                    RentFlowSecondaryButton(
                      label: 'Continue with Apple ID',
                      leading: const Icon(
                        Icons.apple_rounded,
                        size: 20,
                        color: AppColors.inkBlack,
                      ),
                      onPressed: _handleSignIn,
                    ),
                    const SizedBox(height: 26),

                    // Sign Up Entry Link
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.slate,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushNamed(AppRoutes.signUp);
                            },
                            child: Text(
                              'Sign Up',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.burntCopper,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the atmospheric event-production brand header
  Widget _buildAtmosphericHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 26),
      decoration: const BoxDecoration(
        color: AppColors.inkBlack,
        gradient: RadialGradient(
          center: Alignment(0.85, -0.7),
          radius: 1.2,
          colors: [
            Color(0x28B86A45), // Subtle Burnt Copper stage glow
            Color(0x15C59A5A), // Aged brass ambient fill
            AppColors.inkBlack,
          ],
          stops: [0.0, 0.45, 1.0],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand Emblem + Name Row
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.burntCopper,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33B86A45),
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.layers_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'RENTFLOW',
                    style: AppTextStyles.brandTitle.copyWith(
                      fontSize: 18,
                      letterSpacing: 2.0,
                      color: AppColors.bone,
                    ),
                  ),
                  Text(
                    'OPERATIONS OS',
                    style: AppTextStyles.monoLabel.copyWith(
                      fontSize: 10,
                      color: AppColors.agedBrass,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Editorial Display Tagline (Playfair Display)
          Text(
            'EQUIPMENT.\nEVENTS.\nEXECUTED.',
            style: AppTextStyles.displayTagline.copyWith(
              fontSize: 27,
              height: 1.12,
              color: AppColors.paper,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.burntCopper,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Live logistics & warehouse fleet orchestration',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.softStone,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
