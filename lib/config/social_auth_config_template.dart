/// Template de configuration pour l'authentification sociale
/// Copiez ce fichier vers social_auth_config.dart et remplacez les valeurs

class SocialAuthConfig {
  // Google Sign-In Configuration
  // Obtenez ces valeurs depuis Google Cloud Console
  static const String googleClientId = 'YOUR_GOOGLE_CLIENT_ID.apps.googleusercontent.com';
  static const String googleWebClientId = 'YOUR_GOOGLE_WEB_CLIENT_ID.apps.googleusercontent.com';
  
  // Facebook Configuration
  // Obtenez ces valeurs depuis Facebook Developers
  static const String facebookAppId = 'YOUR_FACEBOOK_APP_ID';
  static const String facebookClientToken = 'YOUR_FACEBOOK_CLIENT_TOKEN';
  
  // Apple Sign-In Configuration
  // Obtenez ces valeurs depuis Apple Developer Portal
  static const String appleServiceId = 'com.tourismeApp.tourisme_app_flutter.social';
  static const String appleTeamId = 'YOUR_APPLE_TEAM_ID';
  static const String appleKeyId = 'YOUR_APPLE_KEY_ID';
  
  // URLs de validation des tokens
  static const String googleTokenValidationUrl = 'https://www.googleapis.com/oauth2/v1/userinfo';
  static const String facebookTokenValidationUrl = 'https://graph.facebook.com/me';
  static const String appleTokenValidationUrl = 'https://appleid.apple.com/auth/keys';
  
  // Configuration des scopes
  static const List<String> googleScopes = ['email', 'profile'];
  static const List<String> facebookPermissions = ['email', 'public_profile'];
  static const List<String> appleScopes = ['email', 'name'];
}

/// Instructions de configuration:
/// 
/// 1. Google Sign-In:
///    - Allez sur https://console.cloud.google.com/
///    - Créez un projet ou sélectionnez un projet existant
///    - Activez l'API Google+ et l'API Google Sign-In
///    - Créez des identifiants OAuth 2.0 pour Android, iOS et Web
///    - Téléchargez google-services.json pour Android
///    - Configurez les URL schemes pour iOS
/// 
/// 2. Facebook Login:
///    - Allez sur https://developers.facebook.com/
///    - Créez une nouvelle application
///    - Ajoutez le produit "Facebook Login"
///    - Configurez les plateformes Android et iOS
///    - Obtenez l'App ID et le Client Token
/// 
/// 3. Apple Sign-In:
///    - Allez sur https://developer.apple.com/
///    - Configurez "Sign In with Apple" dans votre App ID
///    - Créez un Service ID pour l'authentification
///    - Obtenez le Team ID et configurez les clés
/// 
/// 4. Backend:
///    - Mettez à jour application-social.properties
///    - Configurez Keycloak pour l'authentification sociale
///    - Déployez les changements
/// 
/// 5. Test:
///    - Exécutez: flutter pub get
///    - Testez: flutter run
///    - Vérifiez les logs en cas d'erreur
