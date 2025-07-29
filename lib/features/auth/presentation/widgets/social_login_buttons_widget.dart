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

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LocalizationService(),
      builder: (context, child) {
        final localizationService = LocalizationService();

        return Column(
          children: [

            _buildGoogleButton(localizationService),

            if (showApple) ...[
              SizedBox(height: 12),
              _buildAppleButton(localizationService),
            ],

            if (showFacebook) ...[
              SizedBox(height: 12),
              _buildFacebookButton(localizationService),
            ],
          ],
        );
      },
    );
  }

  Widget _buildGoogleButton(LocalizationService localizationService) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: onGooglePressed,
        icon: _buildGoogleIcon(),
        label: Text(
          localizationService.translate('sign_up_google'),
          style: TextStyle(
            color: AppTheme.textPrimaryColor,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppTheme.borderColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.white,
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.1),
        ),
      ),
    );
  }

  Widget _buildAppleButton(LocalizationService localizationService) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: onApplePressed,
        icon: Icon(
          Icons.apple,
          color: Colors.black,
          size: 24,
        ),
        label: Text(
          localizationService.translate('sign_up_apple'),
          style: TextStyle(
            color: AppTheme.textPrimaryColor,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppTheme.borderColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.white,
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.1),
        ),
      ),
    );
  }

  Widget _buildFacebookButton(LocalizationService localizationService) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: onFacebookPressed,
        icon: Icon(
          Icons.facebook,
          color: Color(0xFF1877F2),
          size: 24,
        ),
        label: Text(
          localizationService.translate('sign_up_facebook'),
          style: TextStyle(
            color: AppTheme.textPrimaryColor,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppTheme.borderColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.white,
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.1),
        ),
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

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildCompactButton(
          icon: _buildGoogleIcon(),
          onPressed: onGooglePressed,
        ),
        _buildCompactButton(
          icon: Icon(Icons.apple, size: 24, color: Colors.black),
          onPressed: onApplePressed,
        ),
        _buildCompactButton(
          icon: Icon(Icons.facebook, size: 24, color: Color(0xFF1877F2)),
          onPressed: onFacebookPressed,
        ),
      ],
    );
  }

  Widget _buildCompactButton({
    required Widget icon,
    VoidCallback? onPressed,
  }) {
    return Container(
      width: 60,
      height: 60,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppTheme.borderColor),
          shape: CircleBorder(),
          backgroundColor: Colors.white,
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