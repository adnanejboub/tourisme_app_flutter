// lib/features/presentation/pages/welcome_screen.dart
import 'package:flutter/material.dart';
import '../../../../../config/routes/app_routes.dart';
import '../../../../../config/theme/app_theme.dart';
import '../../widgets/language_selector_widget.dart';
import '../../widgets/custom_button_widget.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String selectedLanguage = 'English';

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutBack),
    ));

    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Padding(
                padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 0.0),
                child: _buildSkipButton(),
              ),

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height -
                          MediaQuery.of(context).padding.top -
                          MediaQuery.of(context).padding.bottom - 170, // Increased buffer to prevent overflow
                    ),
                    child: AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: IntrinsicHeight(
                              child: Column(
                                children: [
                                  // Spacer flexible pour centrer le contenu
                                  const Flexible(child: SizedBox(height: 20)),

                                  _buildHeroImage(),
                                  const SizedBox(height: 40),

                                  _buildWelcomeText(),
                                  const SizedBox(height: 40),

                                  _buildLanguageSelector(),

                                  // Spacer flexible pour pousser vers le bas
                                  const Flexible(child: SizedBox(height: 40)),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              // Action buttons (fixed at bottom)
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: _buildActionButtons(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkipButton() {
    return Align(
      alignment: Alignment.topRight,
      child: TextButton(
        onPressed: () => AppRoutes.navigateToLogin(context),
        child: Text(
          'Skip',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildHeroImage() {
    return Hero(
      tag: 'welcome_image',
      child: Container(
        width: 160,
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: AppTheme.primaryGradient,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.3),
              spreadRadius: 4,
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Background image
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: const NetworkImage(
                      'https://images.unsplash.com/photo-1539650116574-75c0c6d0c889?w=400',
                    ),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withAlpha((255 * 0.3).round()),
                      BlendMode.darken,
                    ),
                  ),
                ),
              ),

              // Overlay with icon
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      AppTheme.primaryColor.withOpacity(0.7),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.explore,
                        size: 48,
                        color: Colors.white,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Morocco',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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

  Widget _buildWelcomeText() {
    return Column(
      children: [
        Text(
          'Welcome to Our App',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimaryColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Discover a new way to connect and explore.\nGet started on your journey today!',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.textSecondaryColor,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageSelector() {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Select Language',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 12),

          LanguageSelectorWidget(
            selectedLanguage: selectedLanguage,
            onLanguageChanged: (String newLanguage) {
              setState(() {
                selectedLanguage = newLanguage;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Get Started Button
        CustomButtonWidget(
          text: 'Get Started',
          onPressed: () => AppRoutes.navigateToLogin(context),
          isLoading: false,
          buttonType: ButtonType.primary,
        ),

        const SizedBox(height: 16),

        // Already have account
        TextButton(
          onPressed: () => AppRoutes.navigateToLogin(context),
          child: RichText(
            text: TextSpan(
              text: 'Already have an account? ',
              style: TextStyle(
                color: AppTheme.textSecondaryColor,
                fontSize: 14,
              ),
              children: [
                TextSpan(
                  text: 'Log In',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}