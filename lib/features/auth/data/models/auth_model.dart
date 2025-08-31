import '../../domain/entities/auth_entities.dart';
import 'auth_models.dart';

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
    super.id,
    super.telephone,
    super.adresse,
    super.dateNaissance,
    super.cin,
    super.dateInscription,
    super.role,
    super.touristeId,
    super.nationalite,
    super.passeport,
    super.dateEntree,
    super.dateSortie,
    super.preferences,
    super.niveauLangue,
    super.budgetMax,
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
      // Parse backend profile data
      id: json['id']?.toInt(),
      telephone: json['telephone'],
      adresse: json['adresse'],
      dateNaissance: json['dateNaissance'] != null 
          ? DateTime.tryParse(json['dateNaissance']) 
          : null,
      cin: json['cin'],
      dateInscription: json['dateInscription'] != null 
          ? DateTime.tryParse(json['dateInscription']) 
          : null,
      role: json['role'],
      touristeId: json['touristeId']?.toInt(),
      nationalite: json['nationalite'],
      passeport: json['passeport'],
      dateEntree: json['dateEntree'] != null 
          ? DateTime.tryParse(json['dateEntree']) 
          : null,
      dateSortie: json['dateSortie'] != null 
          ? DateTime.tryParse(json['dateSortie']) 
          : null,
      preferences: json['preferences'],
      niveauLangue: json['niveauLangue'],
      budgetMax: json['budgetMax']?.toDouble(),
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
      'id': id,
      'telephone': telephone,
      'adresse': adresse,
      'dateNaissance': dateNaissance?.toIso8601String(),
      'cin': cin,
      'dateInscription': dateInscription?.toIso8601String(),
      'role': role,
      'touristeId': touristeId,
      'nationalite': nationalite,
      'passeport': passeport,
      'dateEntree': dateEntree?.toIso8601String(),
      'dateSortie': dateSortie?.toIso8601String(),
      'preferences': preferences,
      'niveauLangue': niveauLangue,
      'budgetMax': budgetMax,
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
  final String identifier; // username or email
  final String password;

  LoginRequestModel({
    required this.identifier,
    required this.password,
  });

  factory LoginRequestModel.fromEntity(LoginParams entity) {
    return LoginRequestModel(
      identifier: entity.identifier,
      password: entity.password,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'identifier': identifier,
      'password': password,
    };
  }
}
