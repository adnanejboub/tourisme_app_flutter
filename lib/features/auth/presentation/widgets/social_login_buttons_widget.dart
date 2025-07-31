import 'package:flutter/material.dart';
import '../../../../../config/theme/app_theme.dart';
import 'custom_button_widget.dart';
import '../../../../../core/services/localization_service.dart';

class SocialLoginButtonsWidget extends StatelessWidget {
  final VoidCallback? onGooglePressed;
  final VoidCallback? onApplePressed;
  final VoidCallback? onFacebookPressed;
  final bool showApple;
  final bool showFacebook;

  const SocialLoginButtonsWidget({
    Key? key,
    this.onGooglePressed,
    this.onApplePressed,
    this.onFacebookPressed,
    this.showApple = true,
    this.showFacebook = true,
  }) : super(key: key);

  double _getScaleFactor(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return 0.85;
    if (width < 414) return 0.95;
    return 1.0;
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final scaleFactor = _getScaleFactor(context);
    final textScaleFactor = _getTextScaleFactor(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Use compact buttons on very small screens
    if (screenWidth < 350 || screenHeight < 600) {
      return _buildCompactButtons(context, isDark);
    }

    return ListenableBuilder(
      listenable: LocalizationService(),
      builder: (context, child) {
        final localizationService = LocalizationService();

        return Column(
          children: [
            _buildGoogleButton(localizationService, scaleFactor, textScaleFactor, isDark),

            if (showApple) ...[
              SizedBox(height: 12 * scaleFactor),
              _buildAppleButton(localizationService, scaleFactor, textScaleFactor, isDark),
            ],

            if (showFacebook) ...[
              SizedBox(height: 12 * scaleFactor),
              _buildFacebookButton(localizationService, scaleFactor, textScaleFactor, isDark),
            ],
          ],
        );
      },
    );
  }

  Widget _buildGoogleButton(LocalizationService localizationService, double scaleFactor, double textScaleFactor, bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: 56 * scaleFactor,
      child: OutlinedButton.icon(
        onPressed: onGooglePressed,
        icon: _buildGoogleIcon(),
        label: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            localizationService.translate('sign_up_google'),
            style: TextStyle(
              color: isDark ? Colors.white : AppTheme.textPrimaryColor,
              fontSize: 16 * textScaleFactor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: isDark ? Colors.grey[700]! : AppTheme.borderColor,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: isDark ? Color(0xFF1E1E1E) : Colors.white,
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.1),
          padding: EdgeInsets.symmetric(horizontal: 16 * scaleFactor),
        ),
      ),
    );
  }

  Widget _buildAppleButton(LocalizationService localizationService, double scaleFactor, double textScaleFactor, bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: 56 * scaleFactor,
      child: OutlinedButton.icon(
        onPressed: onApplePressed,
        icon: Icon(
          Icons.apple,
          color: isDark ? Colors.white : Colors.black,
          size: 24 * scaleFactor,
        ),
        label: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            localizationService.translate('sign_up_apple'),
            style: TextStyle(
              color: isDark ? Colors.white : AppTheme.textPrimaryColor,
              fontSize: 16 * textScaleFactor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: isDark ? Colors.grey[700]! : AppTheme.borderColor,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: isDark ? Color(0xFF1E1E1E) : Colors.white,
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.1),
          padding: EdgeInsets.symmetric(horizontal: 16 * scaleFactor),
        ),
      ),
    );
  }

  Widget _buildFacebookButton(LocalizationService localizationService, double scaleFactor, double textScaleFactor, bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: 56 * scaleFactor,
      child: OutlinedButton.icon(
        onPressed: onFacebookPressed,
        icon: Icon(
          Icons.facebook,
          color: Color(0xFF1877F2),
          size: 24 * scaleFactor,
        ),
        label: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            localizationService.translate('sign_up_facebook'),
            style: TextStyle(
              color: isDark ? Colors.white : AppTheme.textPrimaryColor,
              fontSize: 16 * textScaleFactor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: isDark ? Colors.grey[700]! : AppTheme.borderColor,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: isDark ? Color(0xFF1E1E1E) : Colors.white,
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.1),
          padding: EdgeInsets.symmetric(horizontal: 16 * scaleFactor),
        ),
      ),
    );
  }

  Widget _buildCompactButtons(BuildContext context, bool isDark) {
    final scaleFactor = _getScaleFactor(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildCompactButton(
          icon: _buildGoogleIcon(),
          onPressed: onGooglePressed,
          scaleFactor: scaleFactor,
          isDark: isDark,
        ),
        if (showApple) ...[
          SizedBox(width: 16 * scaleFactor),
          _buildCompactButton(
            icon: Icon(
              Icons.apple,
              size: 24 * scaleFactor,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: onApplePressed,
            scaleFactor: scaleFactor,
            isDark: isDark,
          ),
        ],
        if (showFacebook) ...[
          SizedBox(width: 16 * scaleFactor),
          _buildCompactButton(
            icon: Icon(
              Icons.facebook,
              size: 24 * scaleFactor,
              color: Color(0xFF1877F2),
            ),
            onPressed: onFacebookPressed,
            scaleFactor: scaleFactor,
            isDark: isDark,
          ),
        ],
      ],
    );
  }

  Widget _buildCompactButton({
    required Widget icon,
    VoidCallback? onPressed,
    required double scaleFactor,
    required bool isDark,
  }) {
    return Container(
      width: 60 * scaleFactor,
      height: 60 * scaleFactor,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: isDark ? Colors.grey[700]! : AppTheme.borderColor,
          ),
          shape: CircleBorder(),
          backgroundColor: isDark ? Color(0xFF1E1E1E) : Colors.white,
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.1),
          padding: EdgeInsets.zero,
        ),
        child: icon,
      ),
    );
  }

  Widget _buildGoogleIcon() {
    return Container(
      width: 24,
      height: 24,
      child: Image.network(
        'https://developers.google.com/identity/images/g-logo.png',
        width: 24,
        height: 24,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Color(0xFF4285F4),
                  Color(0xFF34A853),
                  Color(0xFFFBBC05),
                  Color(0xFFEA4335),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Text(
                'G',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}


class CompactSocialButtons extends StatelessWidget {
  final VoidCallback? onGooglePressed;
  final VoidCallback? onApplePressed;
  final VoidCallback? onFacebookPressed;

  const CompactSocialButtons({
    Key? key,
    this.onGooglePressed,
    this.onApplePressed,
    this.onFacebookPressed,
  }) : super(key: key);

  double _getScaleFactor(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return 0.85;
    if (width < 414) return 0.95;
    return 1.0;
  }

  @override
  Widget build(BuildContext context) {
    final scaleFactor = _getScaleFactor(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildCompactButton(
          icon: _buildGoogleIcon(),
          onPressed: onGooglePressed,
          scaleFactor: scaleFactor,
          isDark: isDark,
        ),
        _buildCompactButton(
          icon: Icon(
            Icons.apple,
            size: 24 * scaleFactor,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: onApplePressed,
          scaleFactor: scaleFactor,
          isDark: isDark,
        ),
        _buildCompactButton(
          icon: Icon(
            Icons.facebook,
            size: 24 * scaleFactor,
            color: Color(0xFF1877F2),
          ),
          onPressed: onFacebookPressed,
          scaleFactor: scaleFactor,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildCompactButton({
    required Widget icon,
    VoidCallback? onPressed,
    required double scaleFactor,
    required bool isDark,
  }) {
    return Container(
      width: 60 * scaleFactor,
      height: 60 * scaleFactor,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: isDark ? Colors.grey[700]! : AppTheme.borderColor,
          ),
          shape: CircleBorder(),
          backgroundColor: isDark ? Color(0xFF1E1E1E) : Colors.white,
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.1),
          padding: EdgeInsets.zero,
        ),
        child: icon,
      ),
    );
  }

  Widget _buildGoogleIcon() {
    return Container(
      width: 24,
      height: 24,
      child: Image.network(
        'https://developers.google.com/identity/images/g-logo.png',
        width: 24,
        height: 24,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Color(0xFF4285F4),
                  Color(0xFF34A853),
                  Color(0xFFFBBC05),
                  Color(0xFFEA4335),
                ],
              ),
            ),
            child: Center(
              child: Text(
                'G',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}