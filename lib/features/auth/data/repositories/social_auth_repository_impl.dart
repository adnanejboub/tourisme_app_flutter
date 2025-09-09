import '../../domain/entities/social_auth_entities.dart';
import '../../domain/entities/auth_entities.dart';
import '../../domain/repositories/social_auth_repository.dart';
import '../services/social_auth_service.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/social_auth_model.dart';

/// Implémentation du repository d'authentification sociale
class SocialAuthRepositoryImpl implements SocialAuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  SocialAuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<AuthEntity> signInWithGoogle() async {
    try {
      final socialAuth = await SocialAuthService.signInWithGoogle();
      if (socialAuth == null) {
        throw Exception('Échec de l\'authentification Google');
      }

      final params = SocialAuthParams(
        provider: socialAuth.provider,
        accessToken: socialAuth.accessToken,
        idToken: socialAuth.idToken,
        email: socialAuth.email,
        displayName: socialAuth.displayName,
        photoUrl: socialAuth.photoUrl,
      );

      return await _authenticateWithSocialProvider(params);
    } catch (e) {
      throw Exception('Erreur lors de l\'authentification Google: $e');
    }
  }

  @override
  Future<AuthEntity> signInWithApple() async {
    try {
      final socialAuth = await SocialAuthService.signInWithApple();
      if (socialAuth == null) {
        throw Exception('Échec de l\'authentification Apple');
      }

      final params = SocialAuthParams(
        provider: socialAuth.provider,
        accessToken: socialAuth.accessToken,
        idToken: socialAuth.idToken,
        email: socialAuth.email,
        displayName: socialAuth.displayName,
        photoUrl: socialAuth.photoUrl,
      );

      return await _authenticateWithSocialProvider(params);
    } catch (e) {
      throw Exception('Erreur lors de l\'authentification Apple: $e');
    }
  }

  @override
  Future<AuthEntity> signInWithFacebook() async {
    try {
      final socialAuth = await SocialAuthService.signInWithFacebook();
      if (socialAuth == null) {
        throw Exception('Échec de l\'authentification Facebook');
      }

      final params = SocialAuthParams(
        provider: socialAuth.provider,
        accessToken: socialAuth.accessToken,
        idToken: socialAuth.idToken,
        email: socialAuth.email,
        displayName: socialAuth.displayName,
        photoUrl: socialAuth.photoUrl,
      );

      return await _authenticateWithSocialProvider(params);
    } catch (e) {
      throw Exception('Erreur lors de l\'authentification Facebook: $e');
    }
  }

  @override
  Future<AuthEntity> registerWithSocialAuth(SocialAuthParams params) async {
    try {
      final socialAuthModel = SocialAuthParamsModel.fromEntity(params);
      return await _remoteDataSource.registerWithSocialAuth(socialAuthModel);
    } catch (e) {
      throw Exception('Erreur lors de l\'enregistrement avec authentification sociale: $e');
    }
  }

  @override
  Future<AuthEntity> loginWithSocialAuth(SocialAuthParams params) async {
    try {
      final socialAuthModel = SocialAuthParamsModel.fromEntity(params);
      return await _remoteDataSource.loginWithSocialAuth(socialAuthModel);
    } catch (e) {
      throw Exception('Erreur lors de la connexion avec authentification sociale: $e');
    }
  }

  /// Méthode privée pour authentifier avec un fournisseur social
  Future<AuthEntity> _authenticateWithSocialProvider(SocialAuthParams params) async {
    try {
      // Essayer d'abord la connexion
      return await loginWithSocialAuth(params);
    } catch (e) {
      // Si la connexion échoue, essayer l'enregistrement
      try {
        return await registerWithSocialAuth(params);
      } catch (registerError) {
        throw Exception('Impossible de se connecter ou de s\'enregistrer: $e');
      }
    }
  }
}
