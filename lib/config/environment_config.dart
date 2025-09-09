/// Configuration des variables d'environnement pour l'authentification sociale
class EnvironmentConfig {
  // Google OAuth
  static const String googleClientId = String.fromEnvironment(
    'GOOGLE_CLIENT_ID',
    defaultValue: 'YOUR_GOOGLE_CLIENT_ID',
  );
  
  static const String googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue: 'YOUR_GOOGLE_WEB_CLIENT_ID',
  );
  
  static const String googleClientSecret = String.fromEnvironment(
    'GOOGLE_CLIENT_SECRET',
    defaultValue: 'YOUR_GOOGLE_CLIENT_SECRET',
  );

  // Facebook OAuth
  static const String facebookAppId = String.fromEnvironment(
    'FACEBOOK_APP_ID',
    defaultValue: 'YOUR_FACEBOOK_APP_ID',
  );
  
  static const String facebookClientToken = String.fromEnvironment(
    'FACEBOOK_CLIENT_TOKEN',
    defaultValue: 'YOUR_FACEBOOK_CLIENT_TOKEN',
  );
  
  static const String facebookAppSecret = String.fromEnvironment(
    'FACEBOOK_APP_SECRET',
    defaultValue: 'YOUR_FACEBOOK_APP_SECRET',
  );

  // Apple OAuth
  static const String appleServiceId = String.fromEnvironment(
    'APPLE_SERVICE_ID',
    defaultValue: 'YOUR_APPLE_SERVICE_ID',
  );
  
  static const String appleTeamId = String.fromEnvironment(
    'APPLE_TEAM_ID',
    defaultValue: 'YOUR_APPLE_TEAM_ID',
  );
  
  static const String appleKeyId = String.fromEnvironment(
    'APPLE_KEY_ID',
    defaultValue: 'YOUR_APPLE_KEY_ID',
  );
  
  static const String applePrivateKey = String.fromEnvironment(
    'APPLE_PRIVATE_KEY',
    defaultValue: 'YOUR_APPLE_PRIVATE_KEY',
  );

  // Backend Configuration
  static const String backendUrl = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: 'http://localhost:8080',
  );
  
  static const String keycloakUrl = String.fromEnvironment(
    'KEYCLOAK_URL',
    defaultValue: 'http://localhost:8080/auth',
  );
  
  static const String keycloakRealm = String.fromEnvironment(
    'KEYCLOAK_REALM',
    defaultValue: 'your_realm',
  );
  
  static const String keycloakClientId = String.fromEnvironment(
    'KEYCLOAK_CLIENT_ID',
    defaultValue: 'your_client_id',
  );
  
  static const String keycloakClientSecret = String.fromEnvironment(
    'KEYCLOAK_CLIENT_SECRET',
    defaultValue: 'your_client_secret',
  );

  // Configuration de l'application
  static const String appName = String.fromEnvironment(
    'APP_NAME',
    defaultValue: 'Tourisme App',
  );
  
  static const String appVersion = String.fromEnvironment(
    'APP_VERSION',
    defaultValue: '1.0.0',
  );
  
  static const bool debugMode = bool.fromEnvironment(
    'DEBUG_MODE',
    defaultValue: true,
  );
}

/// Instructions d'utilisation:
/// 
/// 1. Pour définir des variables d'environnement au moment de l'exécution:
///    flutter run --dart-define=GOOGLE_CLIENT_ID=your_actual_client_id
/// 
/// 2. Pour définir plusieurs variables:
///    flutter run --dart-define=GOOGLE_CLIENT_ID=your_id --dart-define=FACEBOOK_APP_ID=your_fb_id
/// 
/// 3. Pour la production, utilisez des variables d'environnement système:
///    export GOOGLE_CLIENT_ID=your_actual_client_id
///    flutter run --release
/// 
/// 4. Pour Android, vous pouvez aussi utiliser des variables dans build.gradle:
///    android {
///        defaultConfig {
///            buildConfigField "String", "GOOGLE_CLIENT_ID", "\"${System.getenv('GOOGLE_CLIENT_ID')}\""
///        }
///    }
