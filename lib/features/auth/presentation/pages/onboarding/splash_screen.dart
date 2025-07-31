import 'package:flutter/material.dart';
import '../../../../../config/routes/app_routes.dart';
import '../../../../../config/theme/app_theme.dart';
import '../../widgets/animated_logo_widget.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _navigateToNext();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 2500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.0, 0.8, curve: Curves.elasticOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.4, 1.0, curve: Curves.easeOutBack),
    ));

    _animationController.forward();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(Duration(milliseconds: 3500));

    if (mounted) {
      AppRoutes.navigateToWelcome(context);
    }
  }

  DeviceType _getDeviceType(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final shortestSide = MediaQuery.of(context).size.shortestSide;

    if (shortestSide < 600) {
      return DeviceType.mobile;
    } else if (shortestSide < 900) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }


  ResponsiveDimensions _getResponsiveDimensions(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final deviceType = _getDeviceType(context);
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;

    switch (deviceType) {
      case DeviceType.mobile:
        return ResponsiveDimensions(
          titleFontSize: isLandscape ? size.width * 0.06 : size.width * 0.08,
          subtitleFontSize: isLandscape ? size.width * 0.035 : size.width * 0.045,
          logoSize: isLandscape ? size.height * 0.3 : size.width * 0.4,
          spacing: isLandscape ? size.height * 0.03 : size.height * 0.03,
          loadingSize: isLandscape ? size.height * 0.08 : size.width * 0.08,
          horizontalPadding: size.width * 0.05,
          bottomSpacing: isLandscape ? size.height * 0.08 : size.height * 0.1,
        );
      case DeviceType.tablet:
        return ResponsiveDimensions(
          titleFontSize: isLandscape ? size.width * 0.04 : size.width * 0.06,
          subtitleFontSize: isLandscape ? size.width * 0.025 : size.width * 0.035,
          logoSize: isLandscape ? size.height * 0.25 : size.width * 0.3,
          spacing: isLandscape ? size.height * 0.025 : size.height * 0.025,
          loadingSize: isLandscape ? size.height * 0.06 : size.width * 0.06,
          horizontalPadding: size.width * 0.08,
          bottomSpacing: isLandscape ? size.height * 0.1 : size.height * 0.12,
        );
      case DeviceType.desktop:
        return ResponsiveDimensions(
          titleFontSize: size.width * 0.03,
          subtitleFontSize: size.width * 0.018,
          logoSize: size.height * 0.2,
          spacing: size.height * 0.02,
          loadingSize: size.height * 0.05,
          horizontalPadding: size.width * 0.1,
          bottomSpacing: size.height * 0.15,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final dimensions = _getResponsiveDimensions(context);
          final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

          return Container(
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
            ),
            child: SafeArea(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: dimensions.horizontalPadding,
                ),
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    if (isLandscape) {

                      return Row(
                        children: [

                          Expanded(
                            flex: 1,
                            child: Center(
                              child: FadeTransition(
                                opacity: _fadeAnimation,
                                child: ScaleTransition(
                                  scale: _scaleAnimation,
                                  child: SizedBox(
                                    width: dimensions.logoSize,
                                    height: dimensions.logoSize,
                                    child: AnimatedLogoWidget(),
                                  ),
                                ),
                              ),
                            ),
                          ),


                          Expanded(
                            flex: 1,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                _buildTitleSection(dimensions),
                                SizedBox(height: dimensions.spacing * 2),
                                _buildLoadingSection(dimensions),
                              ],
                            ),
                          ),
                        ],
                      );
                    } else {
                      // Layout vertical pour le mode portrait
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Spacer du haut
                          SizedBox(height: constraints.maxHeight * 0.1),


                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [

                                FadeTransition(
                                  opacity: _fadeAnimation,
                                  child: ScaleTransition(
                                    scale: _scaleAnimation,
                                    child: SizedBox(
                                      width: dimensions.logoSize,
                                      height: dimensions.logoSize,
                                      child: AnimatedLogoWidget(),
                                    ),
                                  ),
                                ),

                                SizedBox(height: dimensions.spacing),


                                _buildTitleSection(dimensions),
                              ],
                            ),
                          ),


                          _buildLoadingSection(dimensions),

                          SizedBox(height: dimensions.bottomSpacing),
                        ],
                      );
                    }
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTitleSection(ResponsiveDimensions dimensions) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Titre principal
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'Marhaba Explorer',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: dimensions.titleFontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      offset: Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: dimensions.spacing * 0.5),

            // Sous-titre
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'Discover Morocco',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: dimensions.subtitleFontSize,
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w300,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingSection(ResponsiveDimensions dimensions) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: EdgeInsets.all(dimensions.spacing),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: dimensions.loadingSize,
              height: dimensions.loadingSize,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.white.withOpacity(0.8),
                ),
                strokeWidth: 2,
              ),
            ),
            SizedBox(height: dimensions.spacing),
            Text(
              'Loading...',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: dimensions.subtitleFontSize * 0.7,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}


enum DeviceType {
  mobile,
  tablet,
  desktop,
}

class ResponsiveDimensions {
  final double titleFontSize;
  final double subtitleFontSize;
  final double logoSize;
  final double spacing;
  final double loadingSize;
  final double horizontalPadding;
  final double bottomSpacing;

  ResponsiveDimensions({
    required this.titleFontSize,
    required this.subtitleFontSize,
    required this.logoSize,
    required this.spacing,
    required this.loadingSize,
    required this.horizontalPadding,
    required this.bottomSpacing,
  });
}