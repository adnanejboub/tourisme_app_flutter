import '../../domain/entities/social_auth_entities.dart';

/// Modèle pour l'authentification sociale
class SocialAuthModel extends SocialAuthEntity {
  const SocialAuthModel({
    required super.accessToken,
    super.refreshToken,
    super.idToken,
    required super.provider,
    required super.providerId,
    required super.email,
    super.displayName,
    super.photoUrl,
    super.expiresAt,
  });

  factory SocialAuthModel.fromJson(Map<String, dynamic> json) {
    return SocialAuthModel(
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'],
      idToken: json['id_token'],
      provider: json['provider'] ?? '',
      providerId: json['provider_id'] ?? '',
      email: json['email'] ?? '',
      displayName: json['display_name'],
      photoUrl: json['photo_url'],
      expiresAt: json['expires_at'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['expires_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'id_token': idToken,
      'provider': provider,
      'provider_id': providerId,
      'email': email,
      'display_name': displayName,
      'photo_url': photoUrl,
      'expires_at': expiresAt?.millisecondsSinceEpoch,
    };
  }

  factory SocialAuthModel.fromEntity(SocialAuthEntity entity) {
    return SocialAuthModel(
      accessToken: entity.accessToken,
      refreshToken: entity.refreshToken,
      idToken: entity.idToken,
      provider: entity.provider,
      providerId: entity.providerId,
      email: entity.email,
      displayName: entity.displayName,
      photoUrl: entity.photoUrl,
      expiresAt: entity.expiresAt,
    );
  }
}

/// Modèle pour les paramètres d'authentification sociale
class SocialAuthParamsModel extends SocialAuthParams {
  const SocialAuthParamsModel({
    required super.provider,
    required super.accessToken,
    super.idToken,
    required super.email,
    super.displayName,
    super.photoUrl,
  });

  factory SocialAuthParamsModel.fromEntity(SocialAuthParams entity) {
    return SocialAuthParamsModel(
      provider: entity.provider,
      accessToken: entity.accessToken,
      idToken: entity.idToken,
      email: entity.email,
      displayName: entity.displayName,
      photoUrl: entity.photoUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'provider': provider,
      'access_token': accessToken,
      'id_token': idToken,
      'email': email,
      'display_name': displayName,
      'photo_url': photoUrl,
    };
  }
}
