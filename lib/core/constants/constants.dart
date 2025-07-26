// lib/core/util/constants.dart
class AppConstants {
  // App Info
  static const String appName = 'Marhaba Explorer';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Discover Morocco - Tourism Guide';

  // API Configuration
  static const String baseUrl = 'https://api.banani-tourism.com';
  static const String apiVersion = 'v1';
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds

  // Authentication
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String isLoggedInKey = 'is_logged_in';
  static const String languageKey = 'selected_language';

  // Keycloak Configuration
  static const String keycloakUrl = 'https://auth.banani-tourism.com';
  static const String keycloakRealm = 'banani-realm';
  static const String keycloakClientId = 'banani-mobile-app';

  // Social Login
  static const String googleClientId = 'your-google-client-id';
  static const String facebookAppId = 'your-facebook-app-id';
  static const String appleServiceId = 'your-apple-service-id';

  // Languages
  static const List<Map<String, String>> supportedLanguages = [
    {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
    {'code': 'fr', 'name': 'Français', 'flag': '🇫🇷'},
    {'code': 'ar', 'name': 'العربية', 'flag': '🇲🇦'},
    {'code': 'es', 'name': 'Español', 'flag': '🇪🇸'},
  ];

  // Morocco Cities
  static const List<Map<String, dynamic>> moroccoCities = [
    {
      'id': 1,
      'name': 'Casablanca',
      'arabicName': 'الدار البيضاء',
      'region': 'Casablanca-Settat',
      'type': ['business', 'modern', 'coastal'],
      'imageUrl': 'https://images.unsplash.com/photo-1539650116574-75c0c6d0c889',
      'description': 'Economic capital and largest city of Morocco',
      'attractions': ['Hassan II Mosque', 'Corniche', 'Morocco Mall'],
    },
    {
      'id': 2,
      'name': 'Marrakech',
      'arabicName': 'مراكش',
      'region': 'Marrakech-Safi',
      'type': ['cultural', 'historical', 'desert'],
      'imageUrl': 'https://images.unsplash.com/photo-1517685352821-92cf88aee5a5',
      'description': 'The Red City with vibrant souks and culture',
      'attractions': ['Jemaa el-Fna', 'Koutoubia Mosque', 'Majorelle Garden'],
    },
    {
      'id': 3,
      'name': 'Fès',
      'arabicName': 'فاس',
      'region': 'Fès-Meknès',
      'type': ['cultural', 'historical', 'educational'],
      'imageUrl': 'https://images.unsplash.com/photo-1570191913384-b786dde7d9b4',
      'description': 'Imperial city with the world\'s oldest university',
      'attractions': ['Medina of Fès', 'University of Al Quaraouiyine', 'Bou Inania Madrasa'],
    },
    {
      'id': 4,
      'name': 'Rabat',
      'arabicName': 'الرباط',
      'region': 'Rabat-Salé-Kénitra',
      'type': ['capital', 'political', 'coastal'],
      'imageUrl': 'https://images.unsplash.com/photo-1578662996442-48f60103fc96',
      'description': 'Capital city with royal palaces and modern architecture',
      'attractions': ['Hassan Tower', 'Kasbah of the Udayas', 'Royal Palace'],
    },
    {
      'id': 5,
      'name': 'Agadir',
      'arabicName': 'أكادير',
      'region': 'Souss-Massa',
      'type': ['beach', 'coastal', 'resort'],
      'imageUrl': 'https://images.unsplash.com/photo-1590736969955-71cc94901144',
      'description': 'Modern beach resort city on the Atlantic coast',
      'attractions': ['Agadir Beach', 'Kasbah', 'Souk El Had'],
    },
    {
      'id': 6,
      'name': 'Essaouira',
      'arabicName': 'الصويرة',
      'region': 'Marrakech-Safi',
      'type': ['coastal', 'cultural', 'windsurfing'],
      'imageUrl': 'https://images.unsplash.com/photo-1591414646028-7b60c18c6f14',
      'description': 'Charming coastal city known for windsurfing and music',
      'attractions': ['Essaouira Medina', 'Moulay Hassan Square', 'Gnaoua Festival'],
    },
  ];

  // Activity Types
  static const List<Map<String, dynamic>> activityTypes = [
    {'id': 'beach', 'name': 'Beaches', 'icon': '🏖️', 'arabicName': 'الشواطئ'},
    {'id': 'mountains', 'name': 'Mountains', 'icon': '⛰️', 'arabicName': 'الجبال'},
    {'id': 'desert', 'name': 'Desert', 'icon': '🏜️', 'arabicName': 'الصحراء'},
    {'id': 'culture', 'name': 'Culture', 'icon': '🕌', 'arabicName': 'الثقافة'},
    {'id': 'history', 'name': 'History', 'icon': '🏛️', 'arabicName': 'التاريخ'},
    {'id': 'shopping', 'name': 'Shopping', 'icon': '🛒', 'arabicName': 'التسوق'},
    {'id': 'food', 'name': 'Food', 'icon': '🍽️', 'arabicName': 'الطعام'},
    {'id': 'adventure', 'name': 'Adventure', 'icon': '🧗', 'arabicName': 'المغامرة'},
    {'id': 'wellness', 'name': 'Wellness', 'icon': '🧘', 'arabicName': 'العافية'},
    {'id': 'nightlife', 'name': 'Nightlife', 'icon': '🌙', 'arabicName': 'الحياة الليلية'},
  ];

  // Transport Types
  static const List<Map<String, String>> transportTypes = [
    {'id': 'flight', 'name': 'Flight', 'icon': '✈️', 'arabicName': 'طيران'},
    {'id': 'car_rental', 'name': 'Car Rental', 'icon': '🚗', 'arabicName': 'تأجير سيارة'},
    {'id': 'private_driver', 'name': 'Private Driver', 'icon': '🚙', 'arabicName': 'سائق خاص'},
    {'id': 'bus', 'name': 'Bus', 'icon': '🚌', 'arabicName': 'حافلة'},
    {'id': 'train', 'name': 'Train', 'icon': '🚄', 'arabicName': 'قطار'},
  ];

  // Accommodation Types
  static const List<Map<String, String>> accommodationTypes = [
    {'id': 'hotel', 'name': 'Hotel', 'icon': '🏨', 'arabicName': 'فندق'},
    {'id': 'riad', 'name': 'Riad', 'icon': '🏛️', 'arabicName': 'رياض'},
    {'id': 'guesthouse', 'name': 'Guesthouse', 'icon': '🏠', 'arabicName': 'بيت ضيافة'},
    {'id': 'resort', 'name': 'Resort', 'icon': '🏖️', 'arabicName': 'منتجع'},
    {'id': 'hostel', 'name': 'Hostel', 'icon': '🛏️', 'arabicName': 'نزل'},
    {'id': 'apartment', 'name': 'Apartment', 'icon': '🏢', 'arabicName': 'شقة'},
  ];

  // Budget Ranges
  static const List<Map<String, dynamic>> budgetRanges = [
    {'id': 'budget', 'name': 'Budget', 'min': 0, 'max': 500, 'currency': 'MAD'},
    {'id': 'mid_range', 'name': 'Mid-range', 'min': 500, 'max': 1500, 'currency': 'MAD'},
    {'id': 'luxury', 'name': 'Luxury', 'min': 1500, 'max': 5000, 'currency': 'MAD'},
    {'id': 'ultra_luxury', 'name': 'Ultra Luxury', 'min': 5000, 'max': 99999, 'currency': 'MAD'},
  ];

  // Trip Durations
  static const List<Map<String, dynamic>> tripDurations = [
    {'id': 'weekend', 'name': 'Weekend (2-3 days)', 'days': 3},
    {'id': 'short', 'name': 'Short Trip (4-6 days)', 'days': 5},
    {'id': 'week', 'name': 'One Week (7-9 days)', 'days': 7},
    {'id': 'extended', 'name': 'Extended (10-14 days)', 'days': 12},
    {'id': 'long', 'name': 'Long Trip (15+ days)', 'days': 20},
  ];

  // Validation
  static const int minPasswordLength = 8;
  static const int otpLength = 6;
  static const int otpExpiryMinutes = 10;
  static const int maxFileUploadSize = 10 * 1024 * 1024; // 10MB

  // Images
  static const String defaultProfileImage = 'assets/images/default_profile.png';
  static const String logoImage = 'assets/images/logo.png';
  static const String splashImage = 'assets/images/splash_bg.jpg';
  static const String welcomeImage = 'assets/images/morocco_welcome.jpg';

  // Error Messages
  static const String networkError = 'Network connection error. Please check your internet connection.';
  static const String serverError = 'Server error. Please try again later.';
  static const String unknownError = 'An unknown error occurred. Please try again.';
  static const String invalidCredentials = 'Invalid email or password.';
  static const String accountNotFound = 'Account not found.';
  static const String emailAlreadyExists = 'Email already exists.';
  static const String weakPassword = 'Password is too weak.';
  static const String invalidOtp = 'Invalid OTP code.';
  static const String otpExpired = 'OTP code has expired.';

  // Success Messages
  static const String loginSuccess = 'Login successful!';
  static const String registrationSuccess = 'Registration successful!';
  static const String passwordResetSuccess = 'Password reset successful!';
  static const String otpSentSuccess = 'OTP sent successfully!';
  static const String profileUpdatedSuccess = 'Profile updated successfully!';

  // Regex Patterns
  static const String emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
  static const String phonePattern = r'^(\+212|0)[5-7][0-9]{8}$'; // Moroccan phone numbers
  static const String passwordPattern = r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d@$!%*?&]{8,}$';
}