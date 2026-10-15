import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../core/routes/app_routes.dart';
import '../../core/services/auth_service.dart';
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
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'mayank@rentflow.ops');
  final _passwordController = TextEditingController(text: '••••••••');
  final _authService = AuthService();
  bool _obscurePassword = true;
  bool _rememberMe = true;
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadRememberedPreference();
    _checkRedirectAuth();
  }

  Future<void> _loadRememberedPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final remember = prefs.getBool('rentflow_remember_me') ?? true;
      final savedEmail = prefs.getString('rentflow_saved_email');
      if (mounted) {
        setState(() {
          _rememberMe = remember;
          if (_rememberMe && savedEmail != null && savedEmail.isNotEmpty) {
            _emailController.text = savedEmail;
          }
        });
      }
    } catch (_) {}
  }

  Future<void> _persistRememberedPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('rentflow_remember_me', _rememberMe);
      if (_rememberMe) {
        await prefs.setString('rentflow_saved_email', _emailController.text.trim());
      } else {
        await prefs.remove('rentflow_saved_email');
      }
    } catch (_) {}
  }

  void _showForgotPasswordDialog() {
    final resetEmailController =
        TextEditingController(text: _emailController.text.trim());
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.paper,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Row(
            children: [
              const Icon(Icons.lock_reset_rounded, color: AppColors.burntCopper, size: 24),
              const SizedBox(width: 10),
              Text(
                'Reset Password',
                style: AppTextStyles.brandTitle.copyWith(fontSize: 18),
              ),
            ],
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter your authorized operator email address to receive password recovery instructions.',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.slate),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: resetEmailController,
                  keyboardType: TextInputType.emailAddress,
                  style: AppTextStyles.bodyMedium,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Work email is required';
                    }
                    if (!val.contains('@') || !val.contains('.')) {
                      return 'Please enter a valid work email';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Work Email',
                    hintText: 'operator@rentflow.ops',
                    prefixIcon: const Icon(Icons.email_outlined, size: 20, color: AppColors.slate),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.softStone),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.burntCopper, width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                'Cancel',
                style: AppTextStyles.buttonText.copyWith(color: AppColors.slate, fontSize: 13),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  final targetEmail = resetEmailController.text.trim();
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppColors.inkBlack,
                      content: Text(
                        'Password reset dispatch sent to $targetEmail. Please check your inbox or notify your squad coordinator.',
                        style: const TextStyle(color: AppColors.bone),
                      ),
                      duration: const Duration(seconds: 4),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.burntCopper,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                'Send Reset Link',
                style: AppTextStyles.buttonText.copyWith(fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _checkRedirectAuth() async {
    final user = await _authService.checkOAuthRedirect();
    if (user != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.inkBlack,
          content: Text(
            'Signed in with Google: ${user.displayName} (${user.email})',
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

  void _handleGoogleSignIn() {
    if (!kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Google Workspace sign-in on mobile will be enabled in next release. Please use email sign in.'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }
    setState(() => _isGoogleLoading = true);
    _authService.redirectToGoogleSignIn();
  }

  void _handleSignIn() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid work email and password (minimum 6 characters).'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    _persistRememberedPreference();
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
      backgroundColor: AppColors.bone,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Cinematic Atmospheric Stage Header
              _buildAtmosphericHeader(),

              // 2. Primary Form Surface
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.screenPaddingH,
                  vertical: 24.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Section Title
                    Text(
                      'Welcome Back',
                      style: AppTextStyles.screenTitle.copyWith(
                        fontSize: 22,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Enter your credentials to access the equipment dispatch console.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.slate,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Authentication Form
                    Form(
                      key: _formKey,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.paper,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.softStone,
                            width: 1,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0A000000),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Work Email Input
                            RentFlowTextField(
                              label: 'Work Email',
                              hintText: 'coordinator@rentflow.ops',
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              prefixIcon: Icons.alternate_email_rounded,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Work email is required';
                                }
                                final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
                                if (!emailRegex.hasMatch(val.trim())) {
                                  return 'Please enter a valid work email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Password Input
                            RentFlowTextField(
                              label: 'Password',
                              hintText: '••••••••',
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              prefixIcon: Icons.lock_outline_rounded,
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return 'Password is required';
                                }
                                if (val.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
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
                            const SizedBox(height: 14),

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
                                          final newVal = val ?? false;
                                          setState(() {
                                            _rememberMe = newVal;
                                          });
                                          SharedPreferences.getInstance().then((p) {
                                            p.setBool('rentflow_remember_me', newVal);
                                          }).catchError((_) {});
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
                                  onPressed: _showForgotPasswordDialog,
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
                      label: _isGoogleLoading
                          ? 'Connecting to Google...'
                          : 'Continue with Google Workspace',
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
                      onPressed: _isGoogleLoading ? null : _handleGoogleSignIn,
                    ),
                    const SizedBox(height: 10),
                    RentFlowSecondaryButton(
                      label: 'Continue with Apple ID',
                      leading: const Icon(
                        Icons.apple_rounded,
                        size: 20,
                        color: AppColors.inkBlack,
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Apple ID authentication is currently in development.'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
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
