import 'package:shared_preferences/shared_preferences.dart';

class NewUserService {
  static const String _isNewUserKey = 'is_new_user';
  static const String _hasCompletedPreferencesKey = 'has_completed_preferences';
  static const String _userPreferencesKey = 'user_preferences';

  /// Vérifie si l'utilisateur est un nouvel utilisateur
  static Future<bool> isNewUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isNewUserKey) ?? true;
  }

  /// Marque l'utilisateur comme nouvel utilisateur
  static Future<void> markAsNewUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isNewUserKey, true);
    await prefs.setBool(_hasCompletedPreferencesKey, false);
  }

  /// Marque l'utilisateur comme utilisateur existant
  static Future<void> markAsExistingUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isNewUserKey, false);
  }

  /// Vérifie si l'utilisateur a complété ses préférences
  static Future<bool> hasCompletedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasCompletedPreferencesKey) ?? false;
  }

  /// Marque que l'utilisateur a complété ses préférences
  static Future<void> markPreferencesCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasCompletedPreferencesKey, true);
    await prefs.setBool(_isNewUserKey, false);
  }

  /// Sauvegarde les préférences de l'utilisateur
  static Future<void> saveUserPreferences(Map<String, dynamic> preferences) async {
    final prefs = await SharedPreferences.getInstance();
    final preferencesJson = preferences.entries
        .map((e) => '${e.key}:${e.value}')
        .join('|');
    await prefs.setString(_userPreferencesKey, preferencesJson);
  }

  /// Récupère les préférences de l'utilisateur
  static Future<Map<String, dynamic>> getUserPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final preferencesString = prefs.getString(_userPreferencesKey);
    
    if (preferencesString == null) return {};
    
    final Map<String, dynamic> preferences = {};
    final pairs = preferencesString.split('|');
    
    for (final pair in pairs) {
      final parts = pair.split(':');
      if (parts.length == 2) {
        final key = parts[0];
        final value = parts[1];
        
        // Essayer de convertir en nombre si possible
        if (value.contains('.')) {
          preferences[key] = double.tryParse(value) ?? value;
        } else if (RegExp(r'^\d+$').hasMatch(value)) {
          preferences[key] = int.tryParse(value) ?? value;
        } else {
          preferences[key] = value;
        }
      }
    }
    
    return preferences;
  }

  /// Vérifie si l'utilisateur doit voir le questionnaire
  static Future<bool> shouldShowPreferencesQuestionnaire() async {
    final isNew = await isNewUser();
    final hasCompleted = await hasCompletedPreferences();
    return isNew && !hasCompleted;
  }

  /// Réinitialise le statut de nouvel utilisateur (pour les tests)
  static Future<void> resetNewUserStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isNewUserKey);
    await prefs.remove(_hasCompletedPreferencesKey);
    await prefs.remove(_userPreferencesKey);
  }

  /// Force l'affichage du questionnaire (pour les tests)
  static Future<void> forceShowQuestionnaire() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isNewUserKey, true);
    await prefs.setBool(_hasCompletedPreferencesKey, false);
  }
}
