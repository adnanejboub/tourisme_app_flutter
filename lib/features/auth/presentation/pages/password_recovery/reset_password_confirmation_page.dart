import 'package:flutter/material.dart';
import 'package:tourisme_app_flutter/config/routes/app_routes.dart';
import 'package:tourisme_app_flutter/core/services/localization_service.dart';

class ResetPasswordConfirmationPage extends StatelessWidget {
  const ResetPasswordConfirmationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Obtenir les dimensions de l'écran
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    final isMediumScreen = size.width >= 600 && size.width < 1024;
    final isLargeScreen = size.width >= 1024;

    // Calculer les tailles adaptatives
    final iconSize = _getIconSize(size.width);
    final titleFontSize = _getTitleFontSize(size.width);
    final bodyFontSize = _getBodyFontSize(size.width);
    final buttonFontSize = _getButtonFontSize(size.width);
    final horizontalPadding = _getHorizontalPadding(size.width);
    final verticalSpacing = _getVerticalSpacing(size.width);

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: colorScheme.onBackground,
            size: isSmallScreen ? 20 : 24,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Container(
                    width: _getContentWidth(size.width),
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: 24.0,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        // Icône adaptative
                        Icon(
                          Icons.check_circle_outline,
                          color: Colors.green,
                          size: iconSize,
                        ),
                        SizedBox(height: verticalSpacing),

                        // Titre avec taille adaptative
                        Text(
                          LocalizationService().translate('reset_link_sent'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onBackground,
                            height: 1.2,
                          ),
                        ),
                        SizedBox(height: verticalSpacing * 0.7),

                        // Description avec taille adaptative
                        Text(
                          LocalizationService().translate('reset_link_instructions'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: bodyFontSize,
                            color: colorScheme.onSurface.withOpacity(0.7),
                            height: 1.4,
                          ),
                        ),
                        SizedBox(height: verticalSpacing * 1.3),

                        // Bouton adaptatif
                        SizedBox(
                          width: _getButtonWidth(size.width),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                AppRoutes.login,
                                    (Route<dynamic> route) => false,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                              padding: EdgeInsets.symmetric(
                                horizontal: _getButtonHorizontalPadding(size.width),
                                vertical: _getButtonVerticalPadding(size.width),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 5,
                            ),
                            child: Text(
                              LocalizationService().translate('back_to_login'),
                              style: TextStyle(
                                fontSize: buttonFontSize,
                                color: colorScheme.onPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
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

  // Méthodes pour calculer les tailles adaptatives
  double _getIconSize(double screenWidth) {
    if (screenWidth < 400) return 60; // Très petits écrans
    if (screenWidth < 600) return 70; // Téléphones
    if (screenWidth < 1024) return 80; // Tablettes
    return 90; // Desktop et plus
  }

  double _getTitleFontSize(double screenWidth) {
    if (screenWidth < 400) return 20;
    if (screenWidth < 600) return 22;
    if (screenWidth < 1024) return 24;
    return 28;
  }

  double _getBodyFontSize(double screenWidth) {
    if (screenWidth < 400) return 14;
    if (screenWidth < 600) return 15;
    if (screenWidth < 1024) return 16;
    return 18;
  }

  double _getButtonFontSize(double screenWidth) {
    if (screenWidth < 400) return 16;
    if (screenWidth < 600) return 17;
    if (screenWidth < 1024) return 18;
    return 20;
  }

  double _getHorizontalPadding(double screenWidth) {
    if (screenWidth < 400) return 16;
    if (screenWidth < 600) return 24;
    if (screenWidth < 1024) return 32;
    return 48;
  }

  double _getVerticalSpacing(double screenWidth) {
    if (screenWidth < 400) return 20;
    if (screenWidth < 600) return 25;
    if (screenWidth < 1024) return 30;
    return 35;
  }

  double _getContentWidth(double screenWidth) {
    if (screenWidth < 600) return screenWidth; // Pleine largeur sur mobile
    if (screenWidth < 1024) return screenWidth * 0.8; // 80% sur tablette
    return 500; // Largeur fixe sur desktop
  }

  double _getButtonWidth(double screenWidth) {
    if (screenWidth < 400) return double.infinity; // Pleine largeur sur très petits écrans
    if (screenWidth < 600) return screenWidth * 0.8;
    if (screenWidth < 1024) return 300;
    return 350;
  }

  double _getButtonHorizontalPadding(double screenWidth) {
    if (screenWidth < 400) return 20;
    if (screenWidth < 600) return 30;
    if (screenWidth < 1024) return 40;
    return 50;
  }

  double _getButtonVerticalPadding(double screenWidth) {
    if (screenWidth < 400) return 12;
    if (screenWidth < 600) return 14;
    if (screenWidth < 1024) return 15;
    return 18;
  }
}