import 'package:flutter/material.dart';
import 'package:tourisme_app_flutter/config/routes/app_routes.dart';

class ResetPasswordPage extends StatefulWidget {
  final String? email;

  const ResetPasswordPage({super.key, this.email});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.email != null) {
      // Logique d'initialisation si nécessaire
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtenir les dimensions de l'écran
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    final isMediumScreen = size.width >= 600 && size.width < 1024;
    final isLargeScreen = size.width >= 1024;

    // Calculer les tailles adaptatives
    final titleFontSize = _getTitleFontSize(size.width);
    final bodyFontSize = _getBodyFontSize(size.width);
    final emailFontSize = _getEmailFontSize(size.width);
    final horizontalPadding = _getHorizontalPadding(size.width);
    final verticalSpacing = _getVerticalSpacing(size.width);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
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
                        // Titre principal adaptatif
                        Text(
                          'Réinitialiser le mot de passe',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey[800],
                            height: 1.2,
                          ),
                        ),
                        SizedBox(height: verticalSpacing * 0.7),

                        // Email conditionnel avec style adaptatif
                        if (widget.email != null)
                          Padding(
                            padding: EdgeInsets.only(bottom: verticalSpacing * 0.7),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: _getEmailContainerPadding(size.width),
                                vertical: _getEmailContainerVerticalPadding(size.width),
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.blue.shade200,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.email_outlined,
                                    color: Colors.blue.shade600,
                                    size: _getEmailIconSize(size.width),
                                  ),
                                  SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      widget.email!,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: emailFontSize,
                                        color: Colors.blue.shade700,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // Description avec style adaptatif
                        Container(
                          constraints: BoxConstraints(
                            maxWidth: _getDescriptionMaxWidth(size.width),
                          ),
                          child: Text(
                            'Entrez votre nouveau mot de passe ci-dessous.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: bodyFontSize,
                              color: Colors.grey[700],
                              height: 1.4,
                            ),
                          ),
                        ),
                        SizedBox(height: verticalSpacing * 1.3),

                        // Section pour les champs de mot de passe (à ajouter selon vos besoins)
                        Container(
                          width: _getFormWidth(size.width),
                          child: Column(
                            children: [
                              // Champ nouveau mot de passe
                              TextField(
                                controller: _newPasswordController,
                                obscureText: true,
                                style: TextStyle(fontSize: bodyFontSize),
                                decoration: InputDecoration(
                                  labelText: 'Nouveau mot de passe',
                                  labelStyle: TextStyle(
                                    fontSize: bodyFontSize * 0.9,
                                    color: Colors.grey[600],
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.blueAccent,
                                      width: 2,
                                    ),
                                  ),
                                  prefixIcon: Icon(
                                    Icons.lock_outline,
                                    size: _getFieldIconSize(size.width),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: _getFieldPadding(size.width),
                                    vertical: _getFieldVerticalPadding(size.width),
                                  ),
                                ),
                              ),
                              SizedBox(height: verticalSpacing * 0.8),

                              // Champ confirmation mot de passe
                              TextField(
                                controller: _confirmNewPasswordController,
                                obscureText: true,
                                style: TextStyle(fontSize: bodyFontSize),
                                decoration: InputDecoration(
                                  labelText: 'Confirmer le mot de passe',
                                  labelStyle: TextStyle(
                                    fontSize: bodyFontSize * 0.9,
                                    color: Colors.grey[600],
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.blueAccent,
                                      width: 2,
                                    ),
                                  ),
                                  prefixIcon: Icon(
                                    Icons.lock_outline,
                                    size: _getFieldIconSize(size.width),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: _getFieldPadding(size.width),
                                    vertical: _getFieldVerticalPadding(size.width),
                                  ),
                                ),
                              ),
                              SizedBox(height: verticalSpacing * 1.5),

                              // Bouton de validation adaptatif
                              SizedBox(
                                width: _getButtonWidth(size.width),
                                child: ElevatedButton(
                                  onPressed: () {
                                    // Logique de validation du mot de passe
                                    _resetPassword();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent,
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
                                    'Réinitialiser',
                                    style: TextStyle(
                                      fontSize: _getButtonFontSize(size.width),
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
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
            );
          },
        ),
      ),
    );
  }

  // Méthode pour gérer la réinitialisation du mot de passe
  void _resetPassword() {
    // Logique de validation et réinitialisation
    print('Réinitialisation du mot de passe...');
  }

  // Méthodes pour calculer les tailles adaptatives
  double _getTitleFontSize(double screenWidth) {
    if (screenWidth < 400) return 22;
    if (screenWidth < 600) return 24;
    if (screenWidth < 1024) return 28;
    return 32;
  }

  double _getBodyFontSize(double screenWidth) {
    if (screenWidth < 400) return 14;
    if (screenWidth < 600) return 15;
    if (screenWidth < 1024) return 16;
    return 18;
  }

  double _getEmailFontSize(double screenWidth) {
    if (screenWidth < 400) return 13;
    if (screenWidth < 600) return 14;
    if (screenWidth < 1024) return 15;
    return 16;
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
    if (screenWidth < 400) return 16;
    if (screenWidth < 600) return 20;
    if (screenWidth < 1024) return 24;
    return 28;
  }

  double _getContentWidth(double screenWidth) {
    if (screenWidth < 600) return screenWidth; // Pleine largeur sur mobile
    if (screenWidth < 1024) return screenWidth * 0.8; // 80% sur tablette
    return 500; // Largeur fixe sur desktop
  }

  double _getFormWidth(double screenWidth) {
    if (screenWidth < 400) return double.infinity;
    if (screenWidth < 600) return screenWidth * 0.9;
    if (screenWidth < 1024) return 400;
    return 450;
  }

  double _getDescriptionMaxWidth(double screenWidth) {
    if (screenWidth < 600) return screenWidth * 0.9;
    if (screenWidth < 1024) return 400;
    return 450;
  }

  double _getButtonWidth(double screenWidth) {
    if (screenWidth < 400) return double.infinity;
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
    if (screenWidth < 1024) return 16;
    return 18;
  }

  double _getEmailContainerPadding(double screenWidth) {
    if (screenWidth < 400) return 12;
    if (screenWidth < 600) return 16;
    if (screenWidth < 1024) return 20;
    return 24;
  }

  double _getEmailContainerVerticalPadding(double screenWidth) {
    if (screenWidth < 400) return 8;
    if (screenWidth < 600) return 10;
    if (screenWidth < 1024) return 12;
    return 14;
  }

  double _getEmailIconSize(double screenWidth) {
    if (screenWidth < 400) return 16;
    if (screenWidth < 600) return 18;
    if (screenWidth < 1024) return 20;
    return 22;
  }

  double _getFieldIconSize(double screenWidth) {
    if (screenWidth < 400) return 20;
    if (screenWidth < 600) return 22;
    if (screenWidth < 1024) return 24;
    return 26;
  }

  double _getFieldPadding(double screenWidth) {
    if (screenWidth < 400) return 12;
    if (screenWidth < 600) return 16;
    if (screenWidth < 1024) return 20;
    return 24;
  }

  double _getFieldVerticalPadding(double screenWidth) {
    if (screenWidth < 400) return 12;
    if (screenWidth < 600) return 14;
    if (screenWidth < 1024) return 16;
    return 18;
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }
}