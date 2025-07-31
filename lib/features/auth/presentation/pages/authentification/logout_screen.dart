import 'package:flutter/material.dart';
import 'package:tourisme_app_flutter/config/routes/app_routes.dart';

class LogoutPage extends StatelessWidget {
  const LogoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtenir les dimensions de l'écran
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    final isMediumScreen = size.width >= 600 && size.width < 1024;
    final isLargeScreen = size.width >= 1024;

    // Calculer les tailles adaptatives
    final titleFontSize = _getTitleFontSize(size.width);
    final questionFontSize = _getQuestionFontSize(size.width);
    final buttonFontSize = _getButtonFontSize(size.width);
    final cancelFontSize = _getCancelFontSize(size.width);
    final horizontalPadding = _getHorizontalPadding(size.width);
    final verticalSpacing = _getVerticalSpacing(size.width);
    final iconSize = _getIconSize(size.width);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Déconnexion',
          style: TextStyle(
            fontSize: titleFontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
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
                        // Icône d'avertissement adaptative
                        Container(
                          padding: EdgeInsets.all(_getIconContainerPadding(size.width)),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.red.shade200,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.logout_rounded,
                            color: Colors.redAccent,
                            size: iconSize,
                          ),
                        ),
                        SizedBox(height: verticalSpacing),

                        // Question de confirmation avec style adaptatif
                        Container(
                          constraints: BoxConstraints(
                            maxWidth: _getQuestionMaxWidth(size.width),
                          ),
                          child: Text(
                            'Êtes-vous sûr de vouloir vous déconnecter ?',
                            style: TextStyle(
                              fontSize: questionFontSize,
                              fontWeight: FontWeight.w500,
                              color: Colors.blueGrey[800],
                              height: 1.3,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: verticalSpacing * 0.8),

                        // Message informatif adaptatif
                        Container(
                          constraints: BoxConstraints(
                            maxWidth: _getInfoMaxWidth(size.width),
                          ),
                          child: Text(
                            'Vous devrez vous reconnecter pour accéder à votre compte.',
                            style: TextStyle(
                              fontSize: _getInfoFontSize(size.width),
                              color: Colors.grey[600],
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: verticalSpacing * 1.5),

                        // Section des boutons
                        Container(
                          width: _getButtonSectionWidth(size.width),
                          child: Column(
                            children: [
                              // Bouton de déconnexion adaptatif
                              SizedBox(
                                width: _getButtonWidth(size.width),
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    print('Déconnexion de l\'utilisateur');
                                    Navigator.pushNamedAndRemoveUntil(
                                      context,
                                      AppRoutes.login,
                                          (Route<dynamic> route) => false,
                                    );
                                  },
                                  icon: Icon(
                                    Icons.logout,
                                    size: _getButtonIconSize(size.width),
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    'Se déconnecter',
                                    style: TextStyle(
                                      fontSize: buttonFontSize,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: _getButtonHorizontalPadding(size.width),
                                      vertical: _getButtonVerticalPadding(size.width),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 5,
                                  ),
                                ),
                              ),
                              SizedBox(height: verticalSpacing * 0.8),

                              // Bouton d'annulation adaptatif
                              SizedBox(
                                width: _getButtonWidth(size.width),
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  icon: Icon(
                                    Icons.close,
                                    size: _getButtonIconSize(size.width),
                                    color: Colors.blueAccent,
                                  ),
                                  label: Text(
                                    'Annuler',
                                    style: TextStyle(
                                      fontSize: cancelFontSize,
                                      color: Colors.blueAccent,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: _getButtonHorizontalPadding(size.width),
                                      vertical: _getButtonVerticalPadding(size.width),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    side: BorderSide(
                                      color: Colors.blueAccent,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Espace de sécurité en bas pour les petits écrans
                        if (isSmallScreen)
                          SizedBox(height: verticalSpacing),
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
  double _getTitleFontSize(double screenWidth) {
    if (screenWidth < 400) return 18;
    if (screenWidth < 600) return 20;
    if (screenWidth < 1024) return 22;
    return 24;
  }

  double _getQuestionFontSize(double screenWidth) {
    if (screenWidth < 400) return 16;
    if (screenWidth < 600) return 18;
    if (screenWidth < 1024) return 20;
    return 22;
  }

  double _getButtonFontSize(double screenWidth) {
    if (screenWidth < 400) return 16;
    if (screenWidth < 600) return 17;
    if (screenWidth < 1024) return 18;
    return 20;
  }

  double _getCancelFontSize(double screenWidth) {
    if (screenWidth < 400) return 15;
    if (screenWidth < 600) return 16;
    if (screenWidth < 1024) return 17;
    return 18;
  }

  double _getInfoFontSize(double screenWidth) {
    if (screenWidth < 400) return 13;
    if (screenWidth < 600) return 14;
    if (screenWidth < 1024) return 15;
    return 16;
  }

  double _getIconSize(double screenWidth) {
    if (screenWidth < 400) return 40;
    if (screenWidth < 600) return 50;
    if (screenWidth < 1024) return 60;
    return 70;
  }

  double _getButtonIconSize(double screenWidth) {
    if (screenWidth < 400) return 18;
    if (screenWidth < 600) return 20;
    if (screenWidth < 1024) return 22;
    return 24;
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

  double _getIconContainerPadding(double screenWidth) {
    if (screenWidth < 400) return 15;
    if (screenWidth < 600) return 18;
    if (screenWidth < 1024) return 20;
    return 25;
  }

  double _getContentWidth(double screenWidth) {
    if (screenWidth < 600) return screenWidth; // Pleine largeur sur mobile
    if (screenWidth < 1024) return screenWidth * 0.8; // 80% sur tablette
    return 500; // Largeur fixe sur desktop
  }

  double _getQuestionMaxWidth(double screenWidth) {
    if (screenWidth < 600) return screenWidth * 0.9;
    if (screenWidth < 1024) return 400;
    return 450;
  }

  double _getInfoMaxWidth(double screenWidth) {
    if (screenWidth < 600) return screenWidth * 0.85;
    if (screenWidth < 1024) return 350;
    return 400;
  }

  double _getButtonSectionWidth(double screenWidth) {
    if (screenWidth < 400) return double.infinity;
    if (screenWidth < 600) return screenWidth * 0.9;
    if (screenWidth < 1024) return 350;
    return 400;
  }

  double _getButtonWidth(double screenWidth) {
    if (screenWidth < 400) return double.infinity;
    if (screenWidth < 600) return screenWidth * 0.8;
    if (screenWidth < 1024) return 280;
    return 320;
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