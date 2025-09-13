import 'package:flutter/material.dart';
import 'package:tourisme_app_flutter/features/auth/presentation/pages/onboarding/splash_screen.dart';
import 'package:tourisme_app_flutter/features/auth/presentation/pages/onboarding/welcome_screen.dart';
import 'package:tourisme_app_flutter/features/auth/presentation/pages/onboarding/enhanced_welcome_screen.dart';
import 'package:tourisme_app_flutter/features/auth/presentation/pages/authentification/login_screen.dart';
import 'package:tourisme_app_flutter/features/auth/presentation/pages/authentification/signup_page.dart';
import 'package:tourisme_app_flutter/features/auth/presentation/pages/password_recovery/forgot_password_page.dart';
import 'package:tourisme_app_flutter/features/auth/presentation/pages/password_recovery/reset_password_page.dart';
import 'package:tourisme_app_flutter/features/auth/presentation/pages/password_recovery/reset_password_confirmation_page.dart';
import 'package:tourisme_app_flutter/features/auth/presentation/pages/verification/otp_verification_page.dart';
import 'package:tourisme_app_flutter/features/auth/presentation/pages/verification/two_factor_auth_page.dart';
import 'package:tourisme_app_flutter/features/auth/presentation/pages/authentification/logout_screen.dart';
import 'package:tourisme_app_flutter/features/auth/presentation/pages/onboarding/travel_preferences_page.dart';
import 'package:tourisme_app_flutter/features/auth/presentation/pages/onboarding/new_user_preferences_page.dart';
import 'package:tourisme_app_flutter/features/home/presentation/pages/main_navigation_page.dart';
import 'package:tourisme_app_flutter/features/home/presentation/pages/home_page.dart';
import 'package:tourisme_app_flutter/features/explore/presentation/pages/explore_page.dart';
import 'package:tourisme_app_flutter/features/explore/presentation/pages/details_explore.dart';
import 'package:tourisme_app_flutter/features/explore/presentation/pages/city_details_page.dart';
import 'package:tourisme_app_flutter/features/explore/presentation/pages/search_explore_page.dart';
import 'package:tourisme_app_flutter/features/explore/presentation/pages/filter_explore_page.dart';
import 'package:tourisme_app_flutter/features/explore/presentation/pages/events_explore_page.dart';
// import 'package:tourisme_app_flutter/features/explore/presentation/pages/itinerary_planning_page.dart'; // Page supprimée
import 'package:tourisme_app_flutter/features/explore/presentation/pages/city_selection_page.dart';
import 'package:tourisme_app_flutter/features/saved/presentation/pages/saved_page.dart';
import 'package:tourisme_app_flutter/features/products/presentation/pages/products_page.dart';
import 'package:tourisme_app_flutter/features/profile/presentation/pages/profile_page.dart';
import 'package:tourisme_app_flutter/features/profile/presentation/pages/reservations_page.dart';
import 'package:tourisme_app_flutter/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:tourisme_app_flutter/features/profile/presentation/pages/preferences_page.dart';
import 'package:tourisme_app_flutter/core/services/localization_service.dart';

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
  static const String newUserPreferences = '/new-user-preferences';
  static const String logout = '/logout';
  static const String home = '/home';
  static const String mainNavigation = '/main-navigation';
  static const String explore = '/explore';
  static const String detailsExplore = '/details-explore';
  static const String cityDetails = '/city-details';
  static const String searchExplore = '/search-explore';
  static const String filterExplore = '/filter-explore';
  static const String eventsExplore = '/events-explore';
  static const String itineraryPlanning = '/itinerary-planning';
  static const String citySelection = '/city-selection';
  static const String products = '/products';
  static const String saved = '/saved';
  static const String profile = '/profile';
  static const String reservations = '/reservations';
  static const String editProfile = '/edit_profile';
  static const String preferences = '/preferences';


  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _buildRoute(SplashScreen(), settings);

      case welcome:
        return _buildRoute(const EnhancedWelcomeScreen(), settings);

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

      case newUserPreferences:
        return _buildRoute(const NewUserPreferencesPage(), settings);

      case logout:
        return _buildRoute(const LogoutPage(), settings);
      case home:
        return _buildRoute(const MainNavigationPage(), settings);

      case mainNavigation:
        return _buildRoute(const MainNavigationPage(), settings);

      case explore:
        final args = settings.arguments as Map<String, dynamic>?;
        final initialTab = args?['initialTab'] as String?;
        return _buildRoute(ExplorePage(initialTab: initialTab), settings);

      case detailsExplore:
        final args = settings.arguments as Map<String, dynamic>?;
        final destination = args?['destination'] as Map<String, dynamic>? ?? {};
        return _buildRoute(DetailsExplorePage(destination: destination), settings);

      case cityDetails:
        final args = settings.arguments as Map<String, dynamic>?;
        final city = args?['city'] as Map<String, dynamic>?;
        return _buildRoute(CityDetailsPage(city: city ?? {}), settings);

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
        // Page supprimée - rediriger vers la page de création de trip
        return _buildRoute(const SavedPage(), settings);
        // final args = settings.arguments as Map<String, dynamic>?;
        // final destination = args?['destination'] as Map<String, dynamic>?;
        // return _buildRoute(ItineraryPlanningPage(destination: destination), settings);

      case citySelection:
        return _buildRoute(const CitySelectionPage(), settings);

      case products:
        return _buildRoute(const ProductsPage(), settings);

      case saved:
        return _buildRoute(const SavedPage(), settings);

      case profile:
        return _buildRoute(const ProfilePage(), settings);

      case reservations:
        return _buildRoute(const ReservationsPage(), settings);
              case editProfile:
          return _buildRoute(const EditProfilePage(), settings);
      case preferences:
        return _buildRoute(const PreferencesPage(), settings);


      default:
        return _buildRoute(
          Scaffold(
            body: Center(
              child: Text(
                '${LocalizationService().translate('route_not_found')}: ${settings.name}',
              ),
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
        title: Text(LocalizationService().translate('search_title')),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search, size: 64, color: Colors.blue),
            const SizedBox(height: 16),
            Text(
              LocalizationService().translate('search_page_title'),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              LocalizationService().translate('coming_soon'),
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildDestinationDetailPage(Map<String, dynamic>? destination) {
    return Scaffold(
      appBar: AppBar(
        title: Text(destination?['name'] ?? LocalizationService().translate('destination')),
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
              destination?['name'] ?? LocalizationService().translate('destination_detail'),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              LocalizationService().translate('detail_page_coming_soon'),
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildActivityDetailPage(Map<String, dynamic>? activity) {
    return Scaffold(
      appBar: AppBar(
        title: Text(activity?['title'] ?? LocalizationService().translate('activity')),
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
              activity?['title'] ?? LocalizationService().translate('activity_detail'),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              LocalizationService().translate('detail_page_coming_soon'),
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }


  static Widget _buildProductDetailPage(Map<String, dynamic>? product) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product?['name'] ?? LocalizationService().translate('product')),
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
              product?['name'] ?? LocalizationService().translate('product_detail'),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              LocalizationService().translate('detail_page_coming_soon'),
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildSeasonalCollectionPage(Map<String, dynamic>? collection) {
    return Scaffold(
      appBar: AppBar(
        title: Text(collection?['title'] ?? LocalizationService().translate('collection')),
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
              collection?['title'] ?? LocalizationService().translate('seasonal_collection'),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              LocalizationService().translate('collection_page_coming_soon'),
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildCartPage() {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationService().translate('shopping_cart')),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shopping_cart, size: 64, color: Colors.blue),
            const SizedBox(height: 16),
            Text(
              LocalizationService().translate('shopping_cart'),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              LocalizationService().translate('cart_functionality_coming_soon'),
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildSettingsPage() {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationService().translate('settings')),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.settings, size: 64, color: Colors.blue),
            const SizedBox(height: 16),
            Text(
              LocalizationService().translate('settings'),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              LocalizationService().translate('settings_page_coming_soon'),
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildHelpPage() {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationService().translate('help_support')),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.help, size: 64, color: Colors.blue),
            const SizedBox(height: 16),
            Text(
              LocalizationService().translate('help_support'),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              LocalizationService().translate('help_page_coming_soon'),
              style: const TextStyle(color: Colors.grey),
            ),
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

  static void navigateToNewUserPreferences(BuildContext context) {
    Navigator.pushReplacementNamed(context, newUserPreferences);
  }

  static void navigateToHome(BuildContext context) {
    Navigator.pushReplacementNamed(context, home);
  }

  static void navigateToProfile(BuildContext context) {
    Navigator.pushNamed(context, profile);
  }

  static void navigateToReservations(BuildContext context) {
    Navigator.pushNamed(context, reservations);
  }

  static void navigateToEditProfile(BuildContext context) {
    Navigator.pushNamed(context, editProfile);
  }

  static void navigateToPreferences(BuildContext context) {
    Navigator.pushNamed(context, preferences);
  }

  static void goBack(BuildContext context) {
    Navigator.pop(context);
  }
}
