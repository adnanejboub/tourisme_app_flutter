import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/routes/app_routes.dart';
import '../../../../../config/theme/app_theme.dart';
import '../../../../../core/utils/validators.dart';
import '../../widgets/custom_button_widget.dart';
import '../../widgets/custom_text_field_widget.dart';
import '../../widgets/social_login_buttons_widget.dart';
import '../../../../../core/services/localization_service.dart';
import '../../../../../core/services/guest_mode_service.dart';
import '../../bloc/auth_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

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
  bool _rememberMe = false;

  final LocalizationService _localizationService = LocalizationService();
  final GuestModeService _guestModeService = GuestModeService();

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _localizationService.addListener(_onLanguageChanged);
  }

  void _onLanguageChanged() {
    setState(() {});
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
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
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _animationController.forward();
  }

  double _getScaleFactor(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return 0.85;
    if (width < 414) return 0.95;
    if (width < 480) return 1.0;
    return 1.1;
  }

  double _getTextScaleFactor(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    if (height < 600) return 0.8;
    if (height < 700) return 0.9;
    if (width < 360) return 0.85;
    if (width < 414) return 0.95;
    return 1.0;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          // Connexion réussie, naviguer vers la page principale
          Navigator.of(context).pushReplacementNamed(AppRoutes.home);
        } else if (state is AuthAuthenticated) {
          // Utilisateur déjà authentifié, naviguer vers la page principale
          Navigator.of(context).pushReplacementNamed(AppRoutes.home);
        } else if (state is AuthFailure) {
          // Afficher l'erreur
          _showErrorDialog(context, state.message);
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final screenHeight = MediaQuery.of(context).size.height;
          final screenWidth = MediaQuery.of(context).size.width;
          final scaleFactor = _getScaleFactor(context);
          final textScaleFactor = _getTextScaleFactor(context);
          final padding = EdgeInsets.all(24.0 * scaleFactor);

          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                        padding: padding,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: screenHeight - MediaQuery.of(context).padding.top - kToolbarHeight - padding.vertical,
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 20 * scaleFactor),

                                _buildHeader(textScaleFactor),
                                SizedBox(height: 32 * scaleFactor),

                                _buildEmailField(),
                                SizedBox(height: 20 * scaleFactor),

                                _buildPasswordField(),
                                SizedBox(height: 16 * scaleFactor),

                                _buildRememberMeRow(textScaleFactor),
                                SizedBox(height: 32 * scaleFactor),

                                _buildLoginButton(),
                                SizedBox(height: 32 * scaleFactor),

                                _buildDivider(textScaleFactor),
                                SizedBox(height: 24 * scaleFactor),

                                SocialLoginButtonsWidget(
                                  onGooglePressed: _handleGoogleLogin,
                                  onApplePressed: _handleAppleLogin,
                                  onFacebookPressed: _handleFacebookLogin,
                                ),

                                SizedBox(height: 40 * scaleFactor),

                                _buildSignUpLink(textScaleFactor),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : AppTheme.textPrimaryColor,
          size: 20,
        ),
        onPressed: () => AppRoutes.goBack(context),
      ),
      systemOverlayStyle: Theme.of(context).brightness == Brightness.dark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
    );
  }

  Widget _buildHeader(double textScaleFactor) {
    final screenWidth = MediaQuery.of(context).size.width;
    final titleSize = screenWidth < 360 ? 28.0 : 32.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: screenWidth * 0.9),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              _localizationService.translate('login_title'),
              style: TextStyle(
                fontSize: titleSize * textScaleFactor,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : AppTheme.textPrimaryColor,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _localizationService.translate('login_subtitle'),
          style: TextStyle(
            fontSize: 16 * textScaleFactor,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[400]
                : AppTheme.textSecondaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return CustomTextFieldWidget(
      controller: _emailController,
      label: _localizationService.translate('username_email_label'),
      hintText: _localizationService.translate('username_email_hint'),
      prefixIcon: Icons.person_outline,
      keyboardType: TextInputType.text,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return _localizationService.translate('username_email_error');
        }

        // Allow both username and email formats
        // Username: at least 3 characters, alphanumeric and underscore
        // Email: valid email format
        final isEmail = Validators.isValidEmail(value);
        final isUsername = RegExp(r'^[a-zA-Z0-9_]{3,}$').hasMatch(value);
        
        if (!isEmail && !isUsername) {
          return _localizationService.translate('username_email_invalid');
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return CustomTextFieldWidget(
      controller: _passwordController,
      label: _localizationService.translate('password_label'),
      hintText: _localizationService.translate('password_hint'),
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
          return _localizationService.translate('password_error');
        }
        return null;
      },
    );
  }

  Widget _buildRememberMeRow(double textScaleFactor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Row(
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
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  _localizationService.translate('remember_me'),
                  style: TextStyle(
                    fontSize: 14 * textScaleFactor,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[400]
                        : AppTheme.textSecondaryColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        Flexible(
          child: TextButton(
            onPressed: () => AppRoutes.navigateToForgotPassword(context),
            child: Text(
              _localizationService.translate('forgot_password'),
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontSize: 14 * textScaleFactor,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return CustomButtonWidget(
          text: _localizationService.translate('login_button'),
          onPressed: isLoading ? null : _handleLogin,
          isLoading: isLoading,
          buttonType: ButtonType.primary,
        );
      },
    );
  }

  Widget _buildDivider(double textScaleFactor) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[800]
                : AppTheme.dividerColor,
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            _localizationService.translate('or_continue_with'),
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[400]
                  : AppTheme.textSecondaryColor,
              fontSize: 14 * textScaleFactor,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[800]
                : AppTheme.dividerColor,
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpLink(double textScaleFactor) {
    return Center(
      child: TextButton(
        onPressed: () => AppRoutes.navigateToSignup(context),
        child: RichText(
          text: TextSpan(
            text: _localizationService.translate('no_account'),
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[400]
                  : AppTheme.textSecondaryColor,
              fontSize: 14 * textScaleFactor,
            ),
            children: [
              TextSpan(
                text: _localizationService.translate('sign_up'),
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
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Désactiver le mode invité lors de la connexion
    _guestModeService.disableGuestMode();

    // Déclencher l'événement de connexion via le BLoC
    context.read<AuthBloc>().add(
      LoginRequested(
        identifier: _emailController.text.trim(), // Use identifier instead of username
        password: _passwordController.text,
      ),
    );
  }

  Future<void> _handleGoogleLogin() async {
    debugPrint('Google Login pressed');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_localizationService.translate('google_login_todo'))),
    );
  }

  Future<void> _handleAppleLogin() async {
    debugPrint('Apple Login pressed');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_localizationService.translate('apple_login_todo'))),
    );
  }

  Future<void> _handleFacebookLogin() async {
    debugPrint('Facebook Login pressed');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_localizationService.translate('facebook_login_todo'))),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    final scaleFactor = _getScaleFactor(context);
    final textScaleFactor = _getTextScaleFactor(context);
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16 * scaleFactor),
          ),
          backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
          title: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 28 * scaleFactor,
              ),
              SizedBox(width: 12 * scaleFactor),
              Expanded(
                child: Text(
                  _localizationService.translate('error'),
                  style: TextStyle(
                    fontSize: 18 * textScaleFactor,
                    fontWeight: isIOS ? FontWeight.w600 : FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: TextStyle(
              fontSize: 16 * textScaleFactor,
              color: isDarkMode ? Colors.white70 : Colors.black87,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                _localizationService.translate('ok'),
                style: TextStyle(
                  fontSize: 16 * textScaleFactor,
                  color: AppTheme.primaryColor,
                  fontWeight: isIOS ? FontWeight.w600 : FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _localizationService.removeListener(_onLanguageChanged);
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}