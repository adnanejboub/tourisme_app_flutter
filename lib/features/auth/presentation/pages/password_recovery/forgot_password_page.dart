import 'package:flutter/material.dart';
import 'package:tourisme_app_flutter/config/routes/app_routes.dart';
import 'package:tourisme_app_flutter/features/auth/presentation/pages/password_recovery/reset_password_confirmation_page.dart';
import 'package:tourisme_app_flutter/core/services/localization_service.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();

  _DeviceInfo _getDeviceInfo(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double screenWidth = mediaQuery.size.width;
    final double screenHeight = mediaQuery.size.height;
    final double shortSide = mediaQuery.size.shortestSide;
    final double longestSide = mediaQuery.size.longestSide;
    final double aspectRatio = longestSide / shortSide;
    final bool isLandscape = screenWidth > screenHeight;
    final double devicePixelRatio = mediaQuery.devicePixelRatio;
    final double textScaleFactor = mediaQuery.textScaleFactor.clamp(0.8, 1.3);

    if (aspectRatio > 2.8) {
      return _DeviceInfo(
        type: _DeviceType.ultraWide,
        scaleFactor: (shortSide / 400).clamp(0.7, 1.5),
        textScaleFactor: textScaleFactor,
        isHighDensity: devicePixelRatio > 2.5,
        isLandscape: isLandscape,
      );
    } else if (shortSide >= 768) {
      return _DeviceInfo(
        type: _DeviceType.largeTablet,
        scaleFactor: (shortSide / 768).clamp(0.9, 1.4),
        textScaleFactor: textScaleFactor,
        isHighDensity: devicePixelRatio > 2.0,
        isLandscape: isLandscape,
      );
    } else if (shortSide >= 600) {
      return _DeviceInfo(
        type: _DeviceType.tablet,
        scaleFactor: (shortSide / 600).clamp(0.8, 1.3),
        textScaleFactor: textScaleFactor,
        isHighDensity: devicePixelRatio > 2.0,
        isLandscape: isLandscape,
      );
    } else if (shortSide >= 414) {
      return _DeviceInfo(
        type: _DeviceType.largePhone,
        scaleFactor: (shortSide / 414).clamp(0.9, 1.2),
        textScaleFactor: textScaleFactor,
        isHighDensity: devicePixelRatio > 2.5,
        isLandscape: isLandscape,
      );
    } else if (shortSide >= 375) {
      return _DeviceInfo(
        type: _DeviceType.phone,
        scaleFactor: (shortSide / 375).clamp(0.8, 1.1),
        textScaleFactor: textScaleFactor,
        isHighDensity: devicePixelRatio > 2.0,
        isLandscape: isLandscape,
      );
    } else {
      return _DeviceInfo(
        type: _DeviceType.smallPhone,
        scaleFactor: (shortSide / 320).clamp(0.7, 1.0),
        textScaleFactor: textScaleFactor,
        isHighDensity: devicePixelRatio > 1.5,
        isLandscape: isLandscape,
      );
    }
  }

  _ResponsiveDimensions _getDimensions(BuildContext context) {
    final deviceInfo = _getDeviceInfo(context);
    final double scale = deviceInfo.scaleFactor;
    final double textScale = deviceInfo.textScaleFactor;
    final bool isHighDensity = deviceInfo.isHighDensity;
    final bool isLandscape = deviceInfo.isLandscape;

    final double densityAdjustment = isHighDensity ? 1.1 : 1.0;
    final double landscapeAdjustment = isLandscape ? 0.8 : 1.0;

    switch (deviceInfo.type) {
      case _DeviceType.smallPhone:
        return _ResponsiveDimensions(
          horizontalPadding: (16 * scale).clamp(12.0, 24.0),
          verticalPadding: isLandscape ? (8 * scale).clamp(6.0, 14.0) : (16 * scale).clamp(12.0, 24.0),
          iconSize: (50 * scale * landscapeAdjustment).clamp(40.0, 70.0),
          titleFontSize: (22 * scale * textScale * landscapeAdjustment).clamp(18.0, 28.0),
          subtitleFontSize: (14 * scale * textScale * landscapeAdjustment).clamp(12.0, 18.0),
          inputHeight: (48 * scale * densityAdjustment).clamp(44.0, 60.0),
          inputFontSize: (14 * scale * textScale).clamp(12.0, 18.0),
          buttonHeight: (48 * scale * densityAdjustment).clamp(44.0, 60.0),
          buttonFontSize: (16 * scale * textScale).clamp(14.0, 20.0),
          labelFontSize: (12 * scale * textScale).clamp(10.0, 16.0),
          linkFontSize: (14 * scale * textScale).clamp(12.0, 18.0),
          borderRadius: (10 * scale).clamp(8.0, 14.0),
          spacing: (16 * scale * landscapeAdjustment).clamp(12.0, 24.0),
          maxWidth: isLandscape ? 480.0 : double.infinity,
          elevation: 4.0,
        );

      case _DeviceType.phone:
        return _ResponsiveDimensions(
          horizontalPadding: (20 * scale).clamp(16.0, 28.0),
          verticalPadding: isLandscape ? (12 * scale).clamp(8.0, 18.0) : (20 * scale).clamp(16.0, 28.0),
          iconSize: (60 * scale * landscapeAdjustment).clamp(50.0, 80.0),
          titleFontSize: (24 * scale * textScale * landscapeAdjustment).clamp(20.0, 30.0),
          subtitleFontSize: (15 * scale * textScale * landscapeAdjustment).clamp(13.0, 19.0),
          inputHeight: (52 * scale * densityAdjustment).clamp(48.0, 64.0),
          inputFontSize: (15 * scale * textScale).clamp(13.0, 19.0),
          buttonHeight: (52 * scale * densityAdjustment).clamp(48.0, 64.0),
          buttonFontSize: (17 * scale * textScale).clamp(15.0, 21.0),
          labelFontSize: (13 * scale * textScale).clamp(11.0, 17.0),
          linkFontSize: (15 * scale * textScale).clamp(13.0, 19.0),
          borderRadius: (12 * scale).clamp(10.0, 16.0),
          spacing: (20 * scale * landscapeAdjustment).clamp(16.0, 28.0),
          maxWidth: isLandscape ? 520.0 : double.infinity,
          elevation: 6.0,
        );

      case _DeviceType.largePhone:
        return _ResponsiveDimensions(
          horizontalPadding: (24 * scale).clamp(20.0, 32.0),
          verticalPadding: isLandscape ? (16 * scale).clamp(12.0, 22.0) : (24 * scale).clamp(20.0, 32.0),
          iconSize: (70 * scale * landscapeAdjustment).clamp(60.0, 90.0),
          titleFontSize: (26 * scale * textScale * landscapeAdjustment).clamp(22.0, 32.0),
          subtitleFontSize: (16 * scale * textScale * landscapeAdjustment).clamp(14.0, 20.0),
          inputHeight: (56 * scale * densityAdjustment).clamp(52.0, 68.0),
          inputFontSize: (16 * scale * textScale).clamp(14.0, 20.0),
          buttonHeight: (56 * scale * densityAdjustment).clamp(52.0, 68.0),
          buttonFontSize: (18 * scale * textScale).clamp(16.0, 22.0),
          labelFontSize: (14 * scale * textScale).clamp(12.0, 18.0),
          linkFontSize: (16 * scale * textScale).clamp(14.0, 20.0),
          borderRadius: (14 * scale).clamp(12.0, 18.0),
          spacing: (24 * scale * landscapeAdjustment).clamp(20.0, 32.0),
          maxWidth: isLandscape ? 560.0 : double.infinity,
          elevation: 8.0,
        );

      case _DeviceType.tablet:
        return _ResponsiveDimensions(
          horizontalPadding: (32 * scale).clamp(28.0, 40.0),
          verticalPadding: isLandscape ? (20 * scale).clamp(16.0, 28.0) : (32 * scale).clamp(28.0, 40.0),
          iconSize: (80 * scale * landscapeAdjustment).clamp(70.0, 100.0),
          titleFontSize: (28 * scale * textScale * landscapeAdjustment).clamp(24.0, 34.0),
          subtitleFontSize: (17 * scale * textScale * landscapeAdjustment).clamp(15.0, 21.0),
          inputHeight: (60 * scale * densityAdjustment).clamp(56.0, 72.0),
          inputFontSize: (17 * scale * textScale).clamp(15.0, 21.0),
          buttonHeight: (60 * scale * densityAdjustment).clamp(56.0, 72.0),
          buttonFontSize: (19 * scale * textScale).clamp(17.0, 23.0),
          labelFontSize: (15 * scale * textScale).clamp(13.0, 19.0),
          linkFontSize: (17 * scale * textScale).clamp(15.0, 21.0),
          borderRadius: (16 * scale).clamp(14.0, 20.0),
          spacing: (28 * scale * landscapeAdjustment).clamp(24.0, 36.0),
          maxWidth: isLandscape ? 600.0 : 480.0,
          elevation: 10.0,
        );

      case _DeviceType.largeTablet:
        return _ResponsiveDimensions(
          horizontalPadding: (40 * scale).clamp(36.0, 48.0),
          verticalPadding: isLandscape ? (24 * scale).clamp(20.0, 32.0) : (40 * scale).clamp(36.0, 48.0),
          iconSize: (90 * scale * landscapeAdjustment).clamp(80.0, 110.0),
          titleFontSize: (30 * scale * textScale * landscapeAdjustment).clamp(26.0, 36.0),
          subtitleFontSize: (18 * scale * textScale * landscapeAdjustment).clamp(16.0, 22.0),
          inputHeight: (64 * scale * densityAdjustment).clamp(60.0, 76.0),
          inputFontSize: (18 * scale * textScale).clamp(16.0, 22.0),
          buttonHeight: (64 * scale * densityAdjustment).clamp(60.0, 76.0),
          buttonFontSize: (20 * scale * textScale).clamp(18.0, 24.0),
          labelFontSize: (16 * scale * textScale).clamp(14.0, 20.0),
          linkFontSize: (18 * scale * textScale).clamp(16.0, 22.0),
          borderRadius: (18 * scale).clamp(16.0, 22.0),
          spacing: (32 * scale * landscapeAdjustment).clamp(28.0, 40.0),
          maxWidth: isLandscape ? 640.0 : 520.0,
          elevation: 12.0,
        );

      case _DeviceType.ultraWide:
        return _ResponsiveDimensions(
          horizontalPadding: (48 * scale).clamp(44.0, 56.0),
          verticalPadding: isLandscape ? (28 * scale).clamp(24.0, 36.0) : (48 * scale).clamp(44.0, 56.0),
          iconSize: (100 * scale * landscapeAdjustment).clamp(90.0, 120.0),
          titleFontSize: (32 * scale * textScale * landscapeAdjustment).clamp(28.0, 38.0),
          subtitleFontSize: (19 * scale * textScale * landscapeAdjustment).clamp(17.0, 23.0),
          inputHeight: (68 * scale * densityAdjustment).clamp(64.0, 80.0),
          inputFontSize: (19 * scale * textScale).clamp(17.0, 23.0),
          buttonHeight: (68 * scale * densityAdjustment).clamp(64.0, 80.0),
          buttonFontSize: (21 * scale * textScale).clamp(19.0, 25.0),
          labelFontSize: (17 * scale * textScale).clamp(15.0, 21.0),
          linkFontSize: (19 * scale * textScale).clamp(17.0, 23.0),
          borderRadius: (20 * scale).clamp(18.0, 24.0),
          spacing: (36 * scale * landscapeAdjustment).clamp(32.0, 44.0),
          maxWidth: isLandscape ? 680.0 : 560.0,
          elevation: 14.0,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dimensions = _getDimensions(context);
    final deviceInfo = _getDeviceInfo(context);
    final bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Theme.of(context).scaffoldBackgroundColor : Colors.white,
      appBar: AppBar(
        backgroundColor: isDarkMode ? Theme.of(context).scaffoldBackgroundColor : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            isIOS ? Icons.arrow_back_ios_rounded : Icons.arrow_back,
            color: isDarkMode ? Colors.white : Colors.black,
            size: dimensions.labelFontSize * 1.5,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: dimensions.maxWidth,
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: dimensions.horizontalPadding,
                vertical: dimensions.verticalPadding,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // Icône de mot de passe oublié
                  Container(
                    padding: EdgeInsets.all(dimensions.spacing * 0.75),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueAccent.withOpacity(0.2),
                          blurRadius: dimensions.elevation,
                          offset: Offset(0, dimensions.elevation / 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      isIOS ? Icons.lock_reset_rounded : Icons.lock_reset,
                      size: dimensions.iconSize,
                      color: Colors.blue[700],
                    ),
                  ),
                  SizedBox(height: dimensions.spacing),

                  // Titre principal
                  Text(
                    LocalizationService().translate('forgot_password_title'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: dimensions.titleFontSize,
                      fontWeight: isIOS ? FontWeight.w600 : FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.blueGrey[800],
                      letterSpacing: isIOS ? -0.5 : 0,
                    ),
                  ),
                  SizedBox(height: dimensions.spacing * 0.75),

                  // Sous-titre explicatif
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: dimensions.spacing * 0.5,
                    ),
                    child: Text(
                      LocalizationService().translate('forgot_password_subtitle'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: dimensions.subtitleFontSize,
                        color: isDarkMode ? Colors.white70 : Colors.grey[700],
                        height: 1.4,
                        letterSpacing: isIOS ? 0.2 : 0,
                      ),
                    ),
                  ),
                  SizedBox(height: dimensions.spacing * 1.5),

                  // Champ email
                  Container(
                    height: dimensions.inputHeight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(dimensions.borderRadius),
                      boxShadow: [
                        BoxShadow(
                          color: isDarkMode
                              ? Colors.black.withOpacity(0.3)
                              : Colors.black.withOpacity(0.05),
                          blurRadius: dimensions.elevation / 2,
                          offset: Offset(0, dimensions.elevation / 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(
                        fontSize: dimensions.inputFontSize,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                      decoration: InputDecoration(
                        labelText: LocalizationService().translate('email_label'),
                        hintText: LocalizationService().translate('forgot_password_email_hint'),
                        labelStyle: TextStyle(
                          fontSize: dimensions.labelFontSize,
                          color: isDarkMode ? Colors.white70 : Colors.grey[600],
                          fontWeight: isIOS ? FontWeight.w400 : FontWeight.w500,
                        ),
                        hintStyle: TextStyle(
                          fontSize: dimensions.inputFontSize * 0.9,
                          color: isDarkMode ? Colors.white38 : Colors.grey[400],
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(dimensions.borderRadius),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: isDarkMode
                            ? Colors.grey[800]?.withOpacity(0.5)
                            : Colors.grey[100],
                        prefixIcon: Icon(
                          isIOS ? Icons.email_rounded : Icons.email,
                          color: isDarkMode ? Colors.white54 : Colors.grey[600],
                          size: dimensions.labelFontSize * 1.3,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: dimensions.spacing * 0.75,
                          vertical: dimensions.spacing * 0.5,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: dimensions.spacing * 1.5),

                  // Bouton d'envoi
                  Container(
                    height: dimensions.buttonHeight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(dimensions.borderRadius),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueAccent.withOpacity(0.3),
                          blurRadius: dimensions.elevation,
                          offset: Offset(0, dimensions.elevation / 2),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        print('Envoyer le lien à: ${_emailController.text}');
                        Navigator.pushNamed(context, AppRoutes.resetPasswordConfirmation);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(dimensions.borderRadius),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isIOS ? Icons.send_rounded : Icons.send,
                            size: dimensions.buttonFontSize * 0.9,
                          ),
                          SizedBox(width: dimensions.spacing * 0.3),
                          Text(
                            LocalizationService().translate('send_reset_link'),
                            style: TextStyle(
                              fontSize: dimensions.buttonFontSize,
                              fontWeight: isIOS ? FontWeight.w600 : FontWeight.bold,
                              letterSpacing: isIOS ? 0.5 : 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: dimensions.spacing),

                  // Bouton retour à la connexion
                  Container(
                    height: dimensions.buttonHeight * 0.8,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(dimensions.borderRadius),
                        ),
                        backgroundColor: isDarkMode
                            ? Colors.blueAccent.withOpacity(0.1)
                            : Colors.blueAccent.withOpacity(0.05),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isIOS ? Icons.arrow_back_ios_rounded : Icons.arrow_back,
                            color: Colors.blueAccent,
                            size: dimensions.linkFontSize * 0.9,
                          ),
                          SizedBox(width: dimensions.spacing * 0.3),
                          Text(
                            LocalizationService().translate('back_to_login'),
                            style: TextStyle(
                              color: Colors.blueAccent,
                              fontSize: dimensions.linkFontSize,
                              fontWeight: isIOS ? FontWeight.w600 : FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Message d'aide additionnel pour les grands écrans
                  if (deviceInfo.type == _DeviceType.tablet ||
                      deviceInfo.type == _DeviceType.largeTablet ||
                      deviceInfo.type == _DeviceType.ultraWide) ...[
                    SizedBox(height: dimensions.spacing * 1.5),
                    Container(
                      padding: EdgeInsets.all(dimensions.spacing),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? Colors.blue.withOpacity(0.1)
                            : Colors.blue.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(dimensions.borderRadius),
                        border: Border.all(
                          color: Colors.blueAccent.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isIOS ? Icons.info_rounded : Icons.info,
                            color: Colors.blueAccent,
                            size: dimensions.labelFontSize * 1.2,
                          ),
                          SizedBox(width: dimensions.spacing * 0.5),
                          Expanded(
                            child: Text(
                              "Vérifiez votre dossier spam si vous ne recevez pas l'email dans les prochaines minutes.",
                              style: TextStyle(
                                fontSize: dimensions.labelFontSize,
                                color: isDarkMode ? Colors.white70 : Colors.blueGrey[700],
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}

enum _DeviceType {
  smallPhone,
  phone,
  largePhone,
  tablet,
  largeTablet,
  ultraWide
}

class _DeviceInfo {
  final _DeviceType type;
  final double scaleFactor;
  final double textScaleFactor;
  final bool isHighDensity;
  final bool isLandscape;

  _DeviceInfo({
    required this.type,
    required this.scaleFactor,
    required this.textScaleFactor,
    required this.isHighDensity,
    required this.isLandscape,
  });
}

class _ResponsiveDimensions {
  final double horizontalPadding;
  final double verticalPadding;
  final double iconSize;
  final double titleFontSize;
  final double subtitleFontSize;
  final double inputHeight;
  final double inputFontSize;
  final double buttonHeight;
  final double buttonFontSize;
  final double labelFontSize;
  final double linkFontSize;
  final double borderRadius;
  final double spacing;
  final double maxWidth;
  final double elevation;

  _ResponsiveDimensions({
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.iconSize,
    required this.titleFontSize,
    required this.subtitleFontSize,
    required this.inputHeight,
    required this.inputFontSize,
    required this.buttonHeight,
    required this.buttonFontSize,
    required this.labelFontSize,
    required this.linkFontSize,
    required this.borderRadius,
    required this.spacing,
    required this.maxWidth,
    required this.elevation,
  });
}