import 'package:equatable/equatable.dart';

/// Entité pour l'authentification sociale
class SocialAuthEntity extends Equatable {
  final String accessToken;
  final String? refreshToken;
  final String? idToken;
  final String provider;
  final String providerId;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final DateTime? expiresAt;

  const SocialAuthEntity({
    required this.accessToken,
    this.refreshToken,
    this.idToken,
    required this.provider,
    required this.providerId,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.expiresAt,
  });

  @override
  List<Object?> get props => [
        accessToken,
        refreshToken,
        idToken,
        provider,
        providerId,
        email,
        displayName,
        photoUrl,
        expiresAt,
      ];
}

/// Entité pour les paramètres d'authentification sociale
class SocialAuthParams extends Equatable {
  final String provider;
  final String accessToken;
  final String? idToken;
  final String email;
  final String? displayName;
  final String? photoUrl;

  const SocialAuthParams({
    required this.provider,
    required this.accessToken,
    this.idToken,
    required this.email,
    this.displayName,
    this.photoUrl,
  });

  @override
  List<Object?> get props => [
        provider,
        accessToken,
        idToken,
        email,
        displayName,
        photoUrl,
      ];
}
