import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/rentflow_button.dart';
import '../../widgets/rentflow_text_field.dart';

/// Coordinator & Staff Registration / Sign Up screen.
///
/// Designed in reference to [LoginScreen] with matching typography,
/// color palette, input styling, and responsive layout.
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

  String _selectedRole = 'Event Coordinator';
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = true;
  bool _isLoading = false;

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

      // Controlled registration transition into dashboard
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Account created for ${_nameController.text.isNotEmpty ? _nameController.text : "Coordinator"}! Please sign in.'),
              backgroundColor: AppColors.alpineEvergreen,
              duration: const Duration(seconds: 3),
            ),
          );
          Navigator.of(context).pushReplacementNamed(AppRoutes.login);
        }
      });
    }
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Brand Mark & Back Button Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
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
                          color: AppColors.textSecondary,
                        ),
                        tooltip: 'Back to Sign In',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Screen Heading
                  Text(
                    'Create Account',
                    style: AppTextStyles.screenTitle.copyWith(fontSize: 24),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Register your staff account to coordinate bookings, equipment, and dispatch schedules.',
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 24),

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
                  const SizedBox(height: 16),

                  // Operational Role Selector
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Operational Role',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.structuralBorder,
                            width: 1,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedRole,
                            isExpanded: true,
                            icon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: AppColors.textSecondary,
                            ),
                            items: _roles.map((role) {
                              return DropdownMenuItem<String>(
                                value: role,
                                child: Text(
                                  role,
                                  style: AppTextStyles.bodyLarge,
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedRole = val);
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

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
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Terms & Conditions Checkbox
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: Checkbox(
                          value: _agreeToTerms,
                          activeColor: AppColors.alpineEvergreen,
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
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Primary Sign Up Button
                  RentFlowButton(
                    label: 'Create Account',
                    isLoading: _isLoading,
                    onPressed: _handleSignUp,
                    icon: Icons.person_add_rounded,
                  ),
                  const SizedBox(height: 24),

                  // Divider with "or register with"
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'OR REGISTER WITH',
                          style: AppTextStyles.monoLabel.copyWith(
                            color: AppColors.textMuted,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Social Signups
                  RentFlowSecondaryButton(
                    label: 'Sign up with Google Workspace',
                    leading: const Icon(
                      Icons.g_mobiledata_rounded,
                      size: 24,
                      color: AppColors.textPrimary,
                    ),
                    onPressed: _handleSignUp,
                  ),
                  const SizedBox(height: 12),
                  RentFlowSecondaryButton(
                    label: 'Sign up with Apple ID',
                    leading: const Icon(
                      Icons.apple_rounded,
                      size: 20,
                      color: AppColors.textPrimary,
                    ),
                    onPressed: _handleSignUp,
                  ),
                  const SizedBox(height: 28),

                  // Navigation back to Sign In
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: AppTextStyles.bodySmall,
                        ),
                        GestureDetector(
                          onTap: () {
                            if (Navigator.of(context).canPop()) {
                              Navigator.of(context).pop();
                            } else {
                              Navigator.of(context).pushReplacementNamed(AppRoutes.login);
                            }
                          },
                          child: Text(
                            'Sign In',
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
      ),
    );
  }
}
