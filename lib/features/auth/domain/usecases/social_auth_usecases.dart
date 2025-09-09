import '../entities/auth_entities.dart';
import '../repositories/social_auth_repository.dart';

/// Cas d'usage pour l'authentification avec Google
class SignInWithGoogleUseCase {
  final SocialAuthRepository _repository;

  SignInWithGoogleUseCase(this._repository);

  Future<AuthEntity> call() async {
    return await _repository.signInWithGoogle();
  }
}

/// Cas d'usage pour l'authentification avec Apple
class SignInWithAppleUseCase {
  final SocialAuthRepository _repository;

  SignInWithAppleUseCase(this._repository);

  Future<AuthEntity> call() async {
    return await _repository.signInWithApple();
  }
}

/// Cas d'usage pour l'authentification avec Facebook
class SignInWithFacebookUseCase {
  final SocialAuthRepository _repository;

  SignInWithFacebookUseCase(this._repository);

  Future<AuthEntity> call() async {
    return await _repository.signInWithFacebook();
  }
}
