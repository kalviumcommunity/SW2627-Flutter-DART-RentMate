import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/routes/app_routes.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/rentflow_button.dart';
import '../../widgets/rentflow_text_field.dart';

/// Coordinator & Staff Registration / Sign Up screen (Industrial Atelier).
///
/// Features:
/// - Bone canvas & Paper form container.
/// - Tactical selectable role options (*Event Coordinator*, *Warehouse Lead*, etc.)
///   with Burnt Copper and Ink active states.
/// - Preserves exact form validators and test targets.
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();

  String _selectedRole = 'Event Coordinator';
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = true;
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  final List<String> _roles = [
    'Event Coordinator',
    'Warehouse Lead',
    'Inventory Dispatcher',
    'Operations Manager',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignUp() {
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the Terms of Service to proceed.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (_formKey.currentState?.validate() ?? true) {
      setState(() => _isLoading = true);

      // Registration transition into dashboard
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          setState(() => _isLoading = false);
          final userName = _nameController.text.trim().isNotEmpty
              ? _nameController.text.trim()
              : AppConstants.coordinatorName;

          Navigator.of(context).pushReplacementNamed(
            AppRoutes.dashboard,
            arguments: userName,
          );
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _checkRedirectAuth();
  }

  Future<void> _checkRedirectAuth() async {
    final user = await _authService.checkOAuthRedirect();
    if (user != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.inkBlack,
          content: Text(
            'Registered with Google: ${user.displayName} (${user.email})',
            style: const TextStyle(color: AppColors.bone),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
      Navigator.of(context).pushReplacementNamed(
        AppRoutes.dashboard,
        arguments: user.displayName,
      );
    }
  }

  void _handleGoogleSignUp() {
    setState(() => _isGoogleLoading = true);
    _authService.redirectToGoogleSignIn();
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
              // Top Header with Back Action
              _buildAtmosphericHeader(context),

              // Paper & Bone Form Container
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
                  vertical: 26.0,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Screen Heading
                      Text(
                        'Create Account',
                        style: AppTextStyles.screenTitle.copyWith(
                          fontSize: 24,
                          color: AppColors.inkBlack,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Register your staff account to coordinate bookings, equipment, and dispatch schedules.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.slate,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 22),

                      // Input card container
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
                            // Full Name Input
                            RentFlowTextField(
                              label: 'Full Name',
                              hintText: 'e.g. Mayank Sharma',
                              controller: _nameController,
                              keyboardType: TextInputType.name,
                              prefixIcon: Icons.person_outline_rounded,
                            ),
                            const SizedBox(height: 16),

                            // Work Email Input
                            RentFlowTextField(
                              label: 'Work Email',
                              hintText: 'name@rentflow.ops',
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              prefixIcon: Icons.email_outlined,
                            ),
                            const SizedBox(height: 18),

                            // Operational Role Section
                            Text(
                              'Operational Role',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.inkBlack,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Tactile Role Selector Grid/Chips
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _roles.map((role) {
                                final isSelected = _selectedRole == role;
                                return InkWell(
                                  onTap: () {
                                    setState(() => _selectedRole = role);
                                  },
                                  borderRadius: BorderRadius.circular(6),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.inkBlack
                                          : AppColors.bone,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.burntCopper
                                            : AppColors.softStone,
                                        width: isSelected ? 1.5 : 1.0,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (isSelected) ...[
                                          const Icon(
                                            Icons.check_circle_rounded,
                                            size: 14,
                                            color: AppColors.burntCopper,
                                          ),
                                          const SizedBox(width: 6),
                                        ],
                                        Text(
                                          role,
                                          style: AppTextStyles.bodySmall.copyWith(
                                            color: isSelected
                                                ? AppColors.paper
                                                : AppColors.inkBlack,
                                            fontWeight: isSelected
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 18),

                            // Password Input
                            RentFlowTextField(
                              label: 'Password',
                              hintText: 'Create a secure password',
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
                            const SizedBox(height: 16),

                            // Confirm Password Input
                            RentFlowTextField(
                              label: 'Confirm Password',
                              hintText: 'Re-enter your password',
                              controller: _confirmPasswordController,
                              obscureText: _obscureConfirmPassword,
                              prefixIcon: Icons.lock_reset_rounded,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppColors.slate,
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Terms Checkbox
                            Row(
                              children: [
                                SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: Checkbox(
                                    value: _agreeToTerms,
                                    activeColor: AppColors.burntCopper,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    onChanged: (val) {
                                      setState(() {
                                        _agreeToTerms = val ?? false;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'I agree to the Operations Terms & Access Policy',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.inkBlack,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Create Account Button (Burnt Copper)
                      RentFlowButton(
                        label: 'Create Account',
                        isLoading: _isLoading,
                        onPressed: _handleSignUp,
                        icon: Icons.person_add_rounded,
                      ),
                      const SizedBox(height: 22),

                      // Divider
                      Row(
                        children: [
                          const Expanded(child: Divider(color: AppColors.softStone)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'OR REGISTER WITH',
                              style: AppTextStyles.monoLabel.copyWith(
                                color: AppColors.slate,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          const Expanded(child: Divider(color: AppColors.softStone)),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Social Registration Actions
                      RentFlowSecondaryButton(
                        label: _isGoogleLoading
                            ? 'Connecting to Google...'
                            : 'Sign up with Google Workspace',
                        leading: _isGoogleLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.burntCopper,
                                ),
                              )
                            : const Icon(
                                Icons.g_mobiledata_rounded,
                                size: 24,
                                color: AppColors.inkBlack,
                              ),
                        onPressed: _isGoogleLoading ? null : _handleGoogleSignUp,
                      ),
                      const SizedBox(height: 10),
                      RentFlowSecondaryButton(
                        label: 'Sign up with Apple ID',
                        leading: const Icon(
                          Icons.apple_rounded,
                          size: 20,
                          color: AppColors.inkBlack,
                        ),
                        onPressed: _handleSignUp,
                      ),
                      const SizedBox(height: 26),

                      // Return Navigation to Sign In
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.slate,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                if (Navigator.of(context).canPop()) {
                                  Navigator.of(context).pop();
                                } else {
                                  Navigator.of(context)
                                      .pushReplacementNamed(AppRoutes.login);
                                }
                              },
                              child: Text(
                                'Sign In',
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAtmosphericHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 20, 24),
      color: AppColors.inkBlack,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.burntCopper,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.layers_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'RENTFLOW',
                style: AppTextStyles.brandTitle.copyWith(
                  fontSize: 16,
                  letterSpacing: 1.2,
                  color: AppColors.bone,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                Navigator.of(context).pushReplacementNamed(AppRoutes.login);
              }
            },
            icon: const Icon(
              Icons.close_rounded,
              color: AppColors.softStone,
            ),
            tooltip: 'Back to Sign In',
          ),
        ],
      ),
    );
  }
}
