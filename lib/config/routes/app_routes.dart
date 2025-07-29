import 'package:flutter/material.dart';
import 'package:tourisme_app_flutter/features/auth/presentation/pages/onboarding/splash_screen.dart';
import 'package:tourisme_app_flutter/features/auth/presentation/pages/onboarding/welcome_screen.dart';
import 'package:tourisme_app_flutter/features/auth/presentation/pages/authentification/login_screen.dart';
import 'package:tourisme_app_flutter/features/auth/presentation/pages/authentification/signup_page.dart';
import 'package:tourisme_app_flutter/features/auth/presentation/pages/password_recovery/forgot_password_page.dart';
import 'package:tourisme_app_flutter/features/auth/presentation/pages/password_recovery/reset_password_page.dart';
import 'package:tourisme_app_flutter/features/auth/presentation/pages/password_recovery/reset_password_confirmation_page.dart';
import 'package:tourisme_app_flutter/features/auth/presentation/pages/verification/otp_verification_page.dart';
import 'package:tourisme_app_flutter/features/auth/presentation/pages/verification/two_factor_auth_page.dart';
import 'package:tourisme_app_flutter/features/auth/presentation/pages/authentification/logout_screen.dart';
import 'package:tourisme_app_flutter/features/auth/presentation/pages/onboarding/travel_preferences_page.dart';

class AppRoutes {
  // Route names
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String resetPasswordConfirmation = '/reset-password-confirmation';
  static const String otpVerification = '/otp-verification';
  static const String twoFactorAuth = '/two-factor-auth';
  static const String travelPreferences = '/travel-preferences';
  static const String logout = '/logout';
  static const String home = '/home';

  // Route generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _buildRoute(SplashScreen(), settings);

      case welcome:
        return _buildRoute(const WelcomeScreen(), settings);

      case login:
        return _buildRoute(const LoginScreen(), settings);

      case signup:
        return _buildRoute(const SignUpPage(), settings);

      case forgotPassword:
        return _buildRoute(const ForgotPasswordPage(), settings);

      case resetPassword:
        final args = settings.arguments as Map<String, dynamic>?;
        final email = args?['email'] as String?;
        return _buildRoute(ResetPasswordPage(email: email), settings);

      case resetPasswordConfirmation:
        return _buildRoute(const ResetPasswordConfirmationPage(), settings);

      case otpVerification:
        final args = settings.arguments as Map<String, dynamic>;
        final email = args['email'] as String;
        final type = args['type'] as String;
        return _buildRoute(OtpVerificationPage(email: email, type: type), settings);

      case twoFactorAuth:
        return _buildRoute(const TwoFactorAuthPage(), settings);

      case travelPreferences:
        return _buildRoute(const TravelPreferencesPage(), settings);

      case logout:
        return _buildRoute(const LogoutPage(), settings);

      default:
        return _buildRoute(
          Scaffold(
            body: Center(
              child: Text('Route not found: ${settings.name}'),
            ),
          ),
          settings,
        );
    }
  }

  // Helper method to build routes with animations
  static PageRouteBuilder _buildRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  // Navigation helpers
  static void navigateToWelcome(BuildContext context) {
    Navigator.pushReplacementNamed(context, welcome);
  }

  static void navigateToLogin(BuildContext context) {
    Navigator.pushNamed(context, login);
  }

  static void navigateToSignup(BuildContext context) {
    Navigator.pushNamed(context, signup);
  }

  static void navigateToForgotPassword(BuildContext context) {
    Navigator.pushNamed(context, forgotPassword);
  }

  static void navigateToResetPassword(BuildContext context, String email) {
    Navigator.pushNamed(
      context,
      resetPassword,
      arguments: {'email': email},
    );
  }

  static void navigateToOtpVerification(
      BuildContext context,
      String email,
      String type
      ) {
    Navigator.pushNamed(
      context,
      otpVerification,
      arguments: {
        'email': email,
        'type': type,
      },
    );
  }

  static void navigateToTravelPreferences(BuildContext context) {
    Navigator.pushReplacementNamed(context, travelPreferences);
  }

  static void navigateToHome(BuildContext context) {
    Navigator.pushReplacementNamed(context, home);
  }

  static void goBack(BuildContext context) {
    Navigator.pop(context);
  }
}