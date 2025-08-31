import 'dart:convert';

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

  factory RegisterRequestModel.fromJson(Map<String, dynamic> json) {
    return RegisterRequestModel(
      username: json['username'],
      email: json['email'],
      password: json['password'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      telephone: json['telephone'],
      adresse: json['adresse'],
      dateNaissance: json['dateNaissance'],
      nationalite: json['nationalite'],
      passeport: json['passeport'],
      cin: json['cin'],
    );
  }
}

/// Modèle pour la requête de connexion
class LoginRequestModel {
  final String identifier; // username or email
  final String password;

  LoginRequestModel({
    required this.identifier,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'identifier': identifier,
      'password': password,
    };
  }

  factory LoginRequestModel.fromJson(Map<String, dynamic> json) {
    return LoginRequestModel(
      identifier: json['identifier'] ?? json['username'] ?? '',
      password: json['password'],
    );
  }
}

/// Modèle pour la réponse de connexion (tokens)
class LoginResponseModel {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final String tokenType;

  LoginResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.tokenType,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      expiresIn: json['expires_in'],
      tokenType: json['token_type'],
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

/// Modèle pour les informations utilisateur
class UserProfileModel {
  final String keycloakId;
  final String email;
  final String firstName;
  final String lastName;
  final String? realmAccess;
  final Map<String, dynamic>? backendUser;
  final bool tokenVerified;

  UserProfileModel({
    required this.keycloakId,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.realmAccess,
    this.backendUser,
    required this.tokenVerified,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      keycloakId: json['keycloakId'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      realmAccess: json['realmAccess'],
      backendUser: json['backendUser'],
      tokenVerified: json['tokenVerified'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'keycloakId': keycloakId,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      if (realmAccess != null) 'realmAccess': realmAccess,
      if (backendUser != null) 'backendUser': backendUser,
      'tokenVerified': tokenVerified,
    };
  }
}

/// Modèle pour les erreurs d'API
class ApiErrorModel {
  final String error;
  final String message;

  ApiErrorModel({
    required this.error,
    required this.message,
  });

  factory ApiErrorModel.fromJson(Map<String, dynamic> json) {
    return ApiErrorModel(
      error: json['error'] ?? 'unknown_error',
      message: json['message'] ?? 'Une erreur inconnue s\'est produite',
    );
  }
}
