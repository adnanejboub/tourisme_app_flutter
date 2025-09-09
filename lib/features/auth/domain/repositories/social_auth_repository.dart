import '../entities/social_auth_entities.dart';
import '../entities/auth_entities.dart';

/// Repository pour l'authentification sociale
abstract class SocialAuthRepository {
  /// Authentification avec Google
  Future<AuthEntity> signInWithGoogle();
  
  /// Authentification avec Apple
  Future<AuthEntity> signInWithApple();
  
  /// Authentification avec Facebook
  Future<AuthEntity> signInWithFacebook();
  
  /// Enregistrement automatique dans Keycloak avec authentification sociale
  Future<AuthEntity> registerWithSocialAuth(SocialAuthParams params);
  
  /// Connexion avec authentification sociale
  Future<AuthEntity> loginWithSocialAuth(SocialAuthParams params);
}
