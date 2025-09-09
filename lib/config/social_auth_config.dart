/// Configuration pour l'authentification sociale
class SocialAuthConfig {
  // Google Sign-In Configuration
  static const String googleClientId = 'YOUR_GOOGLE_CLIENT_ID';
  static const String googleWebClientId = 'YOUR_GOOGLE_WEB_CLIENT_ID';
  
  // Facebook Configuration
  static const String facebookAppId = 'YOUR_FACEBOOK_APP_ID';
  static const String facebookClientToken = 'YOUR_FACEBOOK_CLIENT_TOKEN';
  
  // Apple Sign-In Configuration
  static const String appleServiceId = 'YOUR_APPLE_SERVICE_ID';
  static const String appleTeamId = 'YOUR_APPLE_TEAM_ID';
  static const String appleKeyId = 'YOUR_APPLE_KEY_ID';
  
  // URLs de validation des tokens
  static const String googleTokenValidationUrl = 'https://www.googleapis.com/oauth2/v1/userinfo';
  static const String facebookTokenValidationUrl = 'https://graph.facebook.com/me';
  static const String appleTokenValidationUrl = 'https://appleid.apple.com/auth/keys';
}
