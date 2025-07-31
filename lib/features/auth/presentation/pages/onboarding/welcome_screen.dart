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

  // Méthode pour déterminer le type d'appareil
  DeviceType _getDeviceType(BuildContext context) {
    final MediaQueryData data = MediaQuery.of(context);
    final double shortSide = data.size.shortestSide;
    final double longestSide = data.size.longestSide;
    final double aspectRatio = longestSide / shortSide;

    // Système de voiture (écran très large)
    if (aspectRatio > 2.5 && shortSide > 400) {
      return DeviceType.car;
    }
    // Tablette
    else if (shortSide >= 600) {
      return DeviceType.tablet;
    }
    // Desktop/PC
    else if (shortSide >= 400 && aspectRatio < 1.5) {
      return DeviceType.desktop;
    }
    // Téléphone
    else {
      return DeviceType.phone;
    }
  }

  // Méthode pour obtenir les dimensions responsives
  ResponsiveDimensions _getResponsiveDimensions(BuildContext context) {
    final deviceType = _getDeviceType(context);
    final size = MediaQuery.of(context).size;
    final shortSide = size.shortestSide;
    final isLandscape = size.width > size.height;

    switch (deviceType) {
      case DeviceType.phone:
        return ResponsiveDimensions(
          horizontalPadding: shortSide * 0.06, // 6% de la largeur
          titleFontSize: shortSide * 0.07, // 7% pour le titre
          subtitleFontSize: shortSide * 0.04, // 4% pour le sous-titre
          bodyFontSize: shortSide * 0.035, // 3.5% pour le texte normal
          heroImageSize: shortSide * 0.35, // 35% de la largeur
          buttonFontSize: shortSide * 0.04,
          spacingSmall: shortSide * 0.02,
          spacingMedium: shortSide * 0.04,
          spacingLarge: shortSide * 0.06,
          maxWidth: double.infinity,
        );

      case DeviceType.tablet:
        return ResponsiveDimensions(
          horizontalPadding: isLandscape ? size.width * 0.1 : shortSide * 0.08,
          titleFontSize: shortSide * 0.05,
          subtitleFontSize: shortSide * 0.03,
          bodyFontSize: shortSide * 0.025,
          heroImageSize: shortSide * 0.25,
          buttonFontSize: shortSide * 0.03,
          spacingSmall: shortSide * 0.015,
          spacingMedium: shortSide * 0.03,
          spacingLarge: shortSide * 0.05,
          maxWidth: isLandscape ? size.width * 0.8 : double.infinity,
        );

      case DeviceType.desktop:
        return ResponsiveDimensions(
          horizontalPadding: 80,
          titleFontSize: 32,
          subtitleFontSize: 18,
          bodyFontSize: 16,
          heroImageSize: 200,
          buttonFontSize: 16,
          spacingSmall: 12,
          spacingMedium: 24,
          spacingLarge: 40,
          maxWidth: 800,
        );

      case DeviceType.car:
        return ResponsiveDimensions(
          horizontalPadding: size.width * 0.05,
          titleFontSize: shortSide * 0.06,
          subtitleFontSize: shortSide * 0.035,
          bodyFontSize: shortSide * 0.03,
          heroImageSize: shortSide * 0.3,
          buttonFontSize: shortSide * 0.035,
          spacingSmall: shortSide * 0.02,
          spacingMedium: shortSide * 0.04,
          spacingLarge: shortSide * 0.06,
          maxWidth: size.width * 0.9,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final dimensions = _getResponsiveDimensions(context);
    final deviceType = _getDeviceType(context);
    final isLandscape = MediaQuery.of(context).size.width > MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: _getBackgroundGradient(isDarkMode),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: dimensions.maxWidth,
              ),
              child: _buildResponsiveLayout(context, dimensions, deviceType, isDarkMode, isLandscape),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResponsiveLayout(BuildContext context, ResponsiveDimensions dimensions,
      DeviceType deviceType, bool isDarkMode, bool isLandscape) {

    // Layout spécial pour les systèmes de voiture et paysage
    if (deviceType == DeviceType.car || (isLandscape && deviceType == DeviceType.tablet)) {
      return _buildLandscapeLayout(dimensions, isDarkMode);
    }

    // Layout vertical standard
    return _buildPortraitLayout(dimensions, isDarkMode);
  }

  Widget _buildLandscapeLayout(ResponsiveDimensions dimensions, bool isDarkMode) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: dimensions.horizontalPadding),
      child: Column(
        children: [
          // Header
          _buildHeader(dimensions, isDarkMode),

          // Contenu principal en landscape
          Expanded(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Row(
                      children: [
                        // Image et titre à gauche
                        Expanded(
                          flex: 1,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildHeroImage(isDarkMode, dimensions),
                              SizedBox(height: dimensions.spacingMedium),
                              _buildWelcomeText(dimensions),
                            ],
                          ),
                        ),

                        SizedBox(width: dimensions.spacingLarge),

                        // Sélecteur de langue et boutons à droite
                        Expanded(
                          flex: 1,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildLanguageSelector(dimensions),
                              SizedBox(height: dimensions.spacingLarge),
                              _buildActionButtons(dimensions, isDarkMode),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortraitLayout(ResponsiveDimensions dimensions, bool isDarkMode) {
    return Column(
      children: [
        // Header
        Padding(
          padding: EdgeInsets.fromLTRB(
              dimensions.horizontalPadding,
              dimensions.spacingMedium,
              dimensions.horizontalPadding,
              0
          ),
          child: _buildHeader(dimensions, isDarkMode),
        ),

        // Contenu principal
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: dimensions.horizontalPadding),
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      children: [
                        SizedBox(height: dimensions.spacingLarge),
                        _buildHeroImage(isDarkMode, dimensions),
                        SizedBox(height: dimensions.spacingLarge),
                        _buildWelcomeText(dimensions),
                        SizedBox(height: dimensions.spacingLarge),
                        _buildLanguageSelector(dimensions),
                        SizedBox(height: dimensions.spacingLarge),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // Boutons d'action
        Padding(
          padding: EdgeInsets.all(dimensions.horizontalPadding),
          child: _buildActionButtons(dimensions, isDarkMode),
        ),
      ],
    );
  }

  Widget _buildHeader(ResponsiveDimensions dimensions, bool isDarkMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ThemeToggleButton(),
        TextButton(
          onPressed: () => AppRoutes.navigateToLogin(context),
          child: Text(
            _localizationService.translate('skip'),
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
              fontSize: dimensions.bodyFontSize,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
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

  Widget _buildHeroImage(bool isDarkMode, ResponsiveDimensions dimensions) {
    return Hero(
      tag: 'welcome_image',
      child: Container(
        width: dimensions.heroImageSize,
        height: dimensions.heroImageSize,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(dimensions.heroImageSize * 0.15),
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
          borderRadius: BorderRadius.circular(dimensions.heroImageSize * 0.15),
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
                      Icon(
                        Icons.explore,
                        size: dimensions.heroImageSize * 0.3,
                        color: Colors.white,
                      ),
                      SizedBox(height: dimensions.spacingSmall),
                      Text(
                        _localizationService.translate('morocco'),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: dimensions.bodyFontSize,
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

  Widget _buildWelcomeText(ResponsiveDimensions dimensions) {
    return Column(
      children: [
        Text(
          _localizationService.translate('welcome_title'),
          style: TextStyle(
            fontSize: dimensions.titleFontSize,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onBackground,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: dimensions.spacingMedium),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: dimensions.spacingMedium),
          child: Text(
            _localizationService.translate('welcome_subtitle'),
            style: TextStyle(
              fontSize: dimensions.subtitleFontSize,
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageSelector(ResponsiveDimensions dimensions) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _localizationService.translate('select_language'),
            style: TextStyle(
              fontSize: dimensions.bodyFontSize * 1.1,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ),
          SizedBox(height: dimensions.spacingSmall),
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

  Widget _buildActionButtons(ResponsiveDimensions dimensions, bool isDarkMode) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          child: CustomButtonWidget(
            text: _localizationService.translate('get_started'),
            onPressed: () => AppRoutes.navigateToLogin(context),
            isLoading: false,
            buttonType: ButtonType.primary,
          ),
        ),
        SizedBox(height: dimensions.spacingMedium),
        TextButton(
          onPressed: () => AppRoutes.navigateToLogin(context),
          child: RichText(
            text: TextSpan(
              text: _localizationService.translate('already_account'),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                fontSize: dimensions.bodyFontSize * 0.9,
              ),
              children: [
                TextSpan(
                  text: ' ${_localizationService.translate('log_in')}',
                  style: TextStyle(
                    color: _getPrimaryColor(isDarkMode),
                    fontWeight: FontWeight.w600,
                    fontSize: dimensions.bodyFontSize * 0.9,
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

// Énumération pour les types d'appareils
enum DeviceType {
  phone,
  tablet,
  desktop,
  car,
}

// Classe pour gérer les dimensions responsives
class ResponsiveDimensions {
  final double horizontalPadding;
  final double titleFontSize;
  final double subtitleFontSize;
  final double bodyFontSize;
  final double heroImageSize;
  final double buttonFontSize;
  final double spacingSmall;
  final double spacingMedium;
  final double spacingLarge;
  final double maxWidth;

  ResponsiveDimensions({
    required this.horizontalPadding,
    required this.titleFontSize,
    required this.subtitleFontSize,
    required this.bodyFontSize,
    required this.heroImageSize,
    required this.buttonFontSize,
    required this.spacingSmall,
    required this.spacingMedium,
    required this.spacingLarge,
    required this.maxWidth,
  });
}