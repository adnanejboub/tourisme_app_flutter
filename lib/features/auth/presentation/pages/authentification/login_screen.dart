// Remontée de 6 niveaux pour atteindre lib/ depuis auth/presentation/pages/authentication/
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../config/routes/app_routes.dart';
import '../../../../../config/theme/app_theme.dart';
import '../../../../../core/utils/validators.dart';
// Remontée de 2 niveaux pour atteindre presentation/ depuis pages/authentication/
import '../../widgets/custom_button_widget.dart';
import '../../widgets/custom_text_field_widget.dart';
import '../../widgets/social_login_buttons_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key); // FIX 1: Added const constructor and Key

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000), // Added const
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3), // Added const
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0), // Added const
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20), // Added const

                        // Header
                        _buildHeader(),
                        const SizedBox(height: 32), // Added const

                        // Email Field
                        _buildEmailField(),
                        const SizedBox(height: 20), // Added const

                        // Password Field
                        _buildPasswordField(),
                        const SizedBox(height: 16), // Added const

                        // Remember Me & Forgot Password
                        _buildRememberMeRow(),
                        const SizedBox(height: 32), // Added const

                        // Login Button
                        _buildLoginButton(),
                        const SizedBox(height: 32), // Added const

                        // Divider
                        _buildDivider(),
                        const SizedBox(height: 24), // Added const

                        // Social Login Buttons
                        SocialLoginButtonsWidget(
                          onGooglePressed: _handleGoogleLogin,
                          onApplePressed: _handleAppleLogin,
                          onFacebookPressed: _handleFacebookLogin,
                        ),

                        const SizedBox(height: 40), // Added const

                        // Sign Up Link
                        _buildSignUpLink(),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon( // Added const
          Icons.arrow_back_ios,
          color: AppTheme.textPrimaryColor,
          size: 20,
        ),
        onPressed: () => AppRoutes.goBack(context),
      ),
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Log In',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 8), // Added const
        Text(
          'Welcome back! Please enter your details.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppTheme.textSecondaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return CustomTextFieldWidget(
      controller: _emailController,
      label: 'Email or Phone',
      hintText: 'Enter your email or phone',
      prefixIcon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email or phone';
        }
        // Accept both email and phone formats
        if (!Validators.isValidEmail(value) && value.length < 10) {
          return 'Please enter a valid email or phone number';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return CustomTextFieldWidget(
      controller: _passwordController,
      label: 'Password',
      hintText: 'Enter your password',
      prefixIcon: Icons.lock_outlined,
      obscureText: _obscurePassword,
      suffixIcon: IconButton(
        icon: Icon(
          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: AppTheme.textHintColor,
        ),
        onPressed: () {
          setState(() {
            _obscurePassword = !_obscurePassword;
          });
        },
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        return null;
      },
    );
  }

  Widget _buildRememberMeRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Checkbox(
                value: _rememberMe,
                onChanged: (value) {
                  setState(() {
                    _rememberMe = value!;
                  });
                },
                activeColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 8), // Added const
            const Text( // Added const
              'Remember me',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: () => AppRoutes.navigateToForgotPassword(context),
          child: Text(
            'Forgot Password?',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return CustomButtonWidget( // Changed from LoadingButton to CustomButtonWidget based on common usage
      text: 'Log In',
      // loadingText: 'Logging in...', // Removed if CustomButtonWidget doesn't support it
      onPressed: _handleLogin,
      isLoading: _isLoading,
      buttonType: ButtonType.primary,
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppTheme.dividerColor, thickness: 1)), // Added const
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16), // Added const
          child: const Text( // Added const
            'Or continue with',
            style: TextStyle(
              color: AppTheme.textSecondaryColor,
              fontSize: 14,
            ),
          ),
        ),
        const Expanded(child: Divider(color: AppTheme.dividerColor, thickness: 1)), // Added const
      ],
    );
  }

  Widget _buildSignUpLink() {
    return Center(
      child: TextButton(
        onPressed: () => AppRoutes.navigateToSignup(context),
        child: RichText(
          text: TextSpan(
            text: "Don't have an account? ",
            style: TextStyle(
              color: AppTheme.textSecondaryColor,
              fontSize: 14,
            ),
            children: [
              TextSpan(
                text: 'Sign Up',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    // FIX 3: Check if widget is mounted before using context after async gap
    if (!_formKey.currentState!.validate()) {
      return; // Exit if validation fails
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2)); // Added const

      if (!mounted) return; // FIX 3: Check mounted before using context

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Login successful!'), // Added const
          backgroundColor: AppTheme.successColor,
        ),
      );

      if (!mounted) return; // FIX 3: Check mounted before using context
      // Navigate to travel preferences or home
      AppRoutes.navigateToTravelPreferences(context);

    } catch (e) {
      if (!mounted) return; // FIX 3: Check mounted before using context
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Login failed. Please try again.'), // Added const
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleGoogleLogin() async {
    // Implement Google Sign-In
    // FIX 4: Replaced print with debugPrint for production safety
    debugPrint('Google Login pressed');
    if (!mounted) return; // FIX 3: Check mounted before using context
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Google Login - À implémenter avec google_sign_in package')), // Added const
    );
  }

  Future<void> _handleAppleLogin() async {
    // Implement Apple Sign-In
    // FIX 4: Replaced print with debugPrint for production safety
    debugPrint('Apple Login pressed');
    if (!mounted) return; // FIX 3: Check mounted before using context
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Apple Login - À implémenter avec sign_in_with_apple package')), // Added const
    );
  }

  Future<void> _handleFacebookLogin() async {
    // Implement Facebook Sign-In
    // FIX 4: Replaced print with debugPrint for production safety
    debugPrint('Facebook Login pressed');
    if (!mounted) return; // FIX 3: Check mounted before using context
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Facebook Login - À implémenter avec flutter_facebook_auth package')), // Added const
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}