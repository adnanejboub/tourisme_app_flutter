// lib/features/presentation/widgets/social_login_buttons_widget.dart
import 'package:flutter/material.dart';
import '../../../../../config/theme/app_theme.dart';
import 'custom_button_widget.dart';

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
    return Column(
      children: [
        // Google Login Button
        _buildGoogleButton(),

        if (showApple) ...[
          SizedBox(height: 12),
          _buildAppleButton(),
        ],

        if (showFacebook) ...[
          SizedBox(height: 12),
          _buildFacebookButton(),
        ],
      ],
    );
  }

  Widget _buildGoogleButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: onGooglePressed,
        icon: _buildGoogleIcon(),
        label: Text(
          'Continue with Google',
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

  Widget _buildAppleButton() {
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
          'Continue with Apple',
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

  Widget _buildFacebookButton() {
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
          'Continue with Facebook',
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

// Alternative compact social buttons for limited space
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