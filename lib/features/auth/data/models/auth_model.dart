import '../../domain/entities/auth_entities.dart';

/// Modèle pour la réponse d'authentification (login/register)
class AuthModel extends AuthEntity {
  AuthModel({
    required super.accessToken,
    required super.refreshToken,
    required super.expiresIn,
    required super.tokenType,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
      expiresIn: json['expires_in'] ?? 0,
      tokenType: json['token_type'] ?? 'Bearer',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'expires_in': expiresIn,
      'token_type': tokenType,
    };
  }
}

/// Modèle pour le profil utilisateur
class UserProfileModel extends UserProfileEntity {
  UserProfileModel({
    required super.keycloakId,
    required super.email,
    required super.firstName,
    required super.lastName,
    super.realmAccess,
    super.backendUser,
    required super.tokenVerified,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      keycloakId: json['keycloakId'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      realmAccess: json['realmAccess'],
      backendUser: json['backendUser'] != null 
          ? Map<String, dynamic>.from(json['backendUser']) 
          : null,
      tokenVerified: json['tokenVerified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'keycloakId': keycloakId,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'realmAccess': realmAccess,
      'backendUser': backendUser,
      'tokenVerified': tokenVerified,
    };
  }
}

/// Modèle pour la requête d'inscription
class RegisterRequestModel {
  final String username;
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String? telephone;
  final String? adresse;
  final String? dateNaissance;
  final String? nationalite;
  final String? passeport;
  final String? cin;

  RegisterRequestModel({
    required this.username,
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    this.telephone,
    this.adresse,
    this.dateNaissance,
    this.nationalite,
    this.passeport,
    this.cin,
  });

  factory RegisterRequestModel.fromEntity(RegisterParams entity) {
    return RegisterRequestModel(
      username: entity.username,
      email: entity.email,
      password: entity.password,
      firstName: entity.firstName,
      lastName: entity.lastName,
      telephone: entity.telephone,
      adresse: entity.adresse,
      dateNaissance: entity.dateNaissance,
      nationalite: entity.nationalite,
      passeport: entity.passeport,
      cin: entity.cin,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      if (telephone != null) 'telephone': telephone,
      if (adresse != null) 'adresse': adresse,
      if (dateNaissance != null) 'dateNaissance': dateNaissance,
      if (nationalite != null) 'nationalite': nationalite,
      if (passeport != null) 'passeport': passeport,
      if (cin != null) 'cin': cin,
    };
  }
}

/// Modèle pour la requête de connexion
class LoginRequestModel {
  final String username;
  final String password;

  LoginRequestModel({
    required this.username,
    required this.password,
  });

  factory LoginRequestModel.fromEntity(LoginParams entity) {
    return LoginRequestModel(
      username: entity.username,
      password: entity.password,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
    };
  }
}
