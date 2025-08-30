/// Entité pour les informations d'authentification
class AuthEntity {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final String tokenType;

  AuthEntity({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.tokenType,
  });
}

/// Entité pour le profil utilisateur
class UserProfileEntity {
  final String keycloakId;
  final String email;
  final String firstName;
  final String lastName;
  final String? realmAccess;
  final Map<String, dynamic>? backendUser;
  final bool tokenVerified;

  UserProfileEntity({
    required this.keycloakId,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.realmAccess,
    this.backendUser,
    required this.tokenVerified,
  });
}

/// Entité pour les paramètres d'inscription
class RegisterParams {
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

  RegisterParams({
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
}

/// Entité pour les paramètres de connexion
class LoginParams {
  final String username;
  final String password;



  LoginParams({
    required this.username,
    required this.password,
  });

  @override
  String toString() {
    return 'LoginParams{username: $username, password: $password}';
  }
}
