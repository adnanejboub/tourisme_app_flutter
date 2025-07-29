import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../config/routes/app_routes.dart';
import '../../../../../config/theme/app_theme.dart';
import '../../widgets/language_selector_widget.dart';
import '../../widgets/custom_button_widget.dart';
import '../../widgets/theme_toggle_button.dart';
import '../../../../../core/services/localization_service.dart';
import '../../../../../core/providers/theme_provider.dart';

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
  final LocalizationService _localizationService = LocalizationService();

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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: _getBackgroundGradient(isDarkMode),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header avec boutons
              Padding(
                padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 0.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ThemeToggleButton(),
                    TextButton(
                      onPressed: () => AppRoutes.navigateToLogin(context),
                      child: Text(
                        _localizationService.translate('skip'),
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Contenu principal
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height -
                          MediaQuery.of(context).padding.top -
                          MediaQuery.of(context).padding.bottom - 170,
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
                                  const Flexible(child: SizedBox(height: 20)),
                                  _buildHeroImage(isDarkMode),
                                  const SizedBox(height: 40),
                                  _buildWelcomeText(),
                                  const SizedBox(height: 40),
                                  _buildLanguageSelector(),
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

              // Boutons d'action
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

  // Méthode pour obtenir le gradient de fond selon le thème
  LinearGradient _getBackgroundGradient(bool isDarkMode) {
    if (isDarkMode) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF1E1E1E),
          Color(0xFF121212),
        ],
      );
    } else {
      return AppTheme.backgroundGradient;
    }
  }

  Widget _buildHeroImage(bool isDarkMode) {
    return Hero(
      tag: 'welcome_image',
      child: Container(
        width: 160,
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: _getPrimaryGradient(isDarkMode),
          boxShadow: [
            BoxShadow(
              color: _getPrimaryShadowColor(isDarkMode),
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
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      _getPrimaryColor(isDarkMode).withOpacity(0.7),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.explore,
                        size: 48,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _localizationService.translate('morocco'),
                        style: const TextStyle(
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
          _localizationService.translate('welcome_title'),
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onBackground,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            _localizationService.translate('welcome_subtitle'),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
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
            _localizationService.translate('select_language'),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 12),
          LanguageSelectorWidget(
            selectedLanguage: selectedLanguage,
            onLanguageChanged: (String newLanguage) {
              setState(() {
                selectedLanguage = newLanguage;
              });
              _localizationService.changeLanguage(newLanguage);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomButtonWidget(
          text: _localizationService.translate('get_started'),
          onPressed: () => AppRoutes.navigateToLogin(context),
          isLoading: false,
          buttonType: ButtonType.primary,
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => AppRoutes.navigateToLogin(context),
          child: RichText(
            text: TextSpan(
              text: _localizationService.translate('already_account'),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                fontSize: 14,
              ),
              children: [
                TextSpan(
                  text: _localizationService.translate('log_in'),
                  style: TextStyle(
                    color: _getPrimaryColor(isDarkMode),
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

  // Méthodes utilitaires pour les couleurs selon le thème
  LinearGradient _getPrimaryGradient(bool isDarkMode) {
    if (isDarkMode) {
      return LinearGradient(
        colors: [
          Colors.blue.shade400,
          Colors.blue.shade600,
        ],
      );
    } else {
      return AppTheme.primaryGradient;
    }
  }

  Color _getPrimaryColor(bool isDarkMode) {
    if (isDarkMode) {
      return Colors.blue.shade400;
    } else {
      return AppTheme.primaryColor;
    }
  }

  Color _getPrimaryShadowColor(bool isDarkMode) {
    if (isDarkMode) {
      return Colors.blue.shade400.withOpacity(0.2);
    } else {
      return AppTheme.primaryColor.withOpacity(0.3);
    }
  }

  @override
  void dispose() {
    _localizationService.removeListener(_onLanguageChanged);
    _animationController.dispose();
    super.dispose();
  }
}