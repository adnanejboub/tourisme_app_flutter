import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'localization_service.dart';

class GuestModeService extends ChangeNotifier {
  static final GuestModeService _instance = GuestModeService._internal();
  factory GuestModeService() => _instance;
  GuestModeService._internal();

  bool _isGuestMode = false;
  bool get isGuestMode => _isGuestMode;
  
  static const String _guestModeKey = 'guest_mode_enabled';

  // Fonctionnalités autorisées en mode invité
  static const List<String> _allowedFeatures = [
    'explore_destinations',
    'view_activities',
    'view_cities',
    'view_products',
    'search',
    'view_details',
  ];

  // Fonctionnalités nécessitant une authentification
  static const List<String> _restrictedFeatures = [
    'plan_trip',
    'book_activity',
    'purchase_product',
    'edit_profile',
    'save_items',
    'view_reservations',
    'modify_preferences',
    'add_to_cart',
    'checkout',
  ];

  void enableGuestMode() {
    _isGuestMode = true;
    _saveGuestModeState();
    notifyListeners();
  }

  void disableGuestMode() {
    _isGuestMode = false;
    _saveGuestModeState();
    notifyListeners();
  }
  
  Future<void> loadGuestModeState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isGuestMode = prefs.getBool(_guestModeKey) ?? false;
      notifyListeners();
    } catch (e) {
      print('Error loading guest mode state: $e');
    }
  }
  
  Future<void> _saveGuestModeState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_guestModeKey, _isGuestMode);
    } catch (e) {
      print('Error saving guest mode state: $e');
    }
  }

  bool isFeatureAllowed(String feature) {
    if (!_isGuestMode) return true; // Si pas en mode invité, tout est autorisé
    return _allowedFeatures.contains(feature);
  }

  bool isFeatureRestricted(String feature) {
    if (!_isGuestMode) return false; // Si pas en mode invité, rien n'est restreint
    return _restrictedFeatures.contains(feature);
  }

  void showLoginRequiredDialog(BuildContext context, String feature) {
    final localizationService = LocalizationService();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizationService.translate('login_required')),
          content: Text(localizationService.translate('login_required_message')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(localizationService.translate('cancel')),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Naviguer vers la page de login
                Navigator.pushNamed(context, '/login');
              },
              child: Text(localizationService.translate('login')),
            ),
          ],
        );
      },
    );
  }

  void showGuestModeInfo(BuildContext context) {
    final localizationService = LocalizationService();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(localizationService.translate('guest_mode_description')),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
