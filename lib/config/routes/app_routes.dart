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
import 'package:tourisme_app_flutter/features/home/presentation/pages/main_navigation_page.dart';
import 'package:tourisme_app_flutter/features/home/presentation/pages/home_page.dart';
import 'package:tourisme_app_flutter/features/explore/presentation/pages/explore_page.dart';
import 'package:tourisme_app_flutter/features/explore/presentation/pages/details_explore.dart';
import 'package:tourisme_app_flutter/features/explore/presentation/pages/search_explore_page.dart';
import 'package:tourisme_app_flutter/features/explore/presentation/pages/filter_explore_page.dart';
import 'package:tourisme_app_flutter/features/explore/presentation/pages/events_explore_page.dart';
import 'package:tourisme_app_flutter/features/explore/presentation/pages/itinerary_planning_page.dart';
import 'package:tourisme_app_flutter/features/products/presentation/pages/products_page.dart';
import 'package:tourisme_app_flutter/features/saved/presentation/pages/saved_page.dart';
import 'package:tourisme_app_flutter/features/profile/presentation/pages/profile_page.dart';

class AppRoutes {

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
  static const String mainNavigation = '/main-navigation';
  static const String explore = '/explore';
  static const String detailsExplore = '/details-explore';
  static const String searchExplore = '/search-explore';
  static const String filterExplore = '/filter-explore';
  static const String eventsExplore = '/events-explore';
  static const String itineraryPlanning = '/itinerary-planning';
  static const String products = '/products';
  static const String saved = '/saved';
  static const String profile = '/profile';


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
      case home:
        return _buildRoute(const MainNavigationPage(), settings);

      case mainNavigation:
        return _buildRoute(const MainNavigationPage(), settings);

      case explore:
        return _buildRoute(const ExplorePage(), settings);

      case detailsExplore:
        final args = settings.arguments as Map<String, dynamic>?;
        final destination = args?['destination'] as Map<String, dynamic>? ?? {};
        return _buildRoute(DetailsExplorePage(destination: destination), settings);

      case searchExplore:
        return _buildRoute(const SearchExplorePage(), settings);

      case filterExplore:
        final args = settings.arguments as Map<String, dynamic>?;
        final currentFilters = args?['currentFilters'] as Map<String, dynamic>?;
        final onFiltersApplied = args?['onFiltersApplied'] as Function(Map<String, dynamic>)?;
        return _buildRoute(FilterExplorePage(
          currentFilters: currentFilters,
          onFiltersApplied: onFiltersApplied ?? (filters) {},
        ), settings);

      case eventsExplore:
        return _buildRoute(const EventsExplorePage(), settings);

      case itineraryPlanning:
        final args = settings.arguments as Map<String, dynamic>?;
        final destination = args?['destination'] as Map<String, dynamic>?;
        return _buildRoute(ItineraryPlanningPage(destination: destination), settings);

      case products:
        return _buildRoute(const ProductsPage(), settings);

      case saved:
        return _buildRoute(const SavedPage(), settings);

      case profile:
        return _buildRoute(const ProfilePage(), settings);


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
  static Widget _buildSearchPage() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.blue),
            SizedBox(height: 16),
            Text(
              'Search Page',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text('Coming soon...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  static Widget _buildDestinationDetailPage(Map<String, dynamic>? destination) {
    return Scaffold(
      appBar: AppBar(
        title: Text(destination?['name'] ?? 'Destination'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.place, size: 64, color: Colors.blue),
            const SizedBox(height: 16),
            Text(
              destination?['name'] ?? 'Destination Detail',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text('Detail page coming soon...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  static Widget _buildActivityDetailPage(Map<String, dynamic>? activity) {
    return Scaffold(
      appBar: AppBar(
        title: Text(activity?['title'] ?? 'Activity'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.local_activity, size: 64, color: Colors.blue),
            const SizedBox(height: 16),
            Text(
              activity?['title'] ?? 'Activity Detail',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text('Detail page coming soon...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }


  static Widget _buildProductDetailPage(Map<String, dynamic>? product) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product?['name'] ?? 'Product'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shopping_bag, size: 64, color: Colors.blue),
            const SizedBox(height: 16),
            Text(
              product?['name'] ?? 'Product Detail',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text('Detail page coming soon...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  static Widget _buildSeasonalCollectionPage(Map<String, dynamic>? collection) {
    return Scaffold(
      appBar: AppBar(
        title: Text(collection?['title'] ?? 'Collection'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.collections, size: 64, color: Colors.blue),
            const SizedBox(height: 16),
            Text(
              collection?['title'] ?? 'Seasonal Collection',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text('Collection page coming soon...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  static Widget _buildCartPage() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart, size: 64, color: Colors.blue),
            SizedBox(height: 16),
            Text(
              'Shopping Cart',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text('Cart functionality coming soon...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  static Widget _buildSettingsPage() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.settings, size: 64, color: Colors.blue),
            SizedBox(height: 16),
            Text(
              'Settings',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text('Settings page coming soon...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  static Widget _buildHelpPage() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.help, size: 64, color: Colors.blue),
            SizedBox(height: 16),
            Text(
              'Help & Support',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text('Help page coming soon...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }




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
