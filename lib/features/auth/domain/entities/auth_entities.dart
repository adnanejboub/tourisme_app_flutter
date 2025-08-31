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
  
  // Additional profile fields from backend
  final int? id;
  final String? telephone;
  final String? adresse;
  final DateTime? dateNaissance;
  final String? cin;
  final DateTime? dateInscription;
  final String? role;
  
  // Tourist-specific fields
  final int? touristeId;
  final String? nationalite;
  final String? passeport;
  final DateTime? dateEntree;
  final DateTime? dateSortie;
  final String? preferences;
  final String? niveauLangue;
  final double? budgetMax;

  UserProfileEntity({
    required this.keycloakId,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.realmAccess,
    this.backendUser,
    required this.tokenVerified,
    this.id,
    this.telephone,
    this.adresse,
    this.dateNaissance,
    this.cin,
    this.dateInscription,
    this.role,
    this.touristeId,
    this.nationalite,
    this.passeport,
    this.dateEntree,
    this.dateSortie,
    this.preferences,
    this.niveauLangue,
    this.budgetMax,
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
  final String identifier; // username or email
  final String password;

  LoginParams({
    required this.identifier,
    required this.password,
  });

  @override
  String toString() {
    return 'LoginParams{identifier: $identifier, password: $password}';
  }
}

/// Entité pour les paramètres de mise à jour du profil
class ProfileUpdateParams {
  final String? firstName;
  final String? lastName;
  final String? telephone;
  final String? adresse;
  final DateTime? dateNaissance;
  final String? cin;
  final String? nationalite;
  final String? passeport;
  final String? preferences;
  final String? niveauLangue;
  final double? budgetMax;

  ProfileUpdateParams({
    this.firstName,
    this.lastName,
    this.telephone,
    this.adresse,
    this.dateNaissance,
    this.cin,
    this.nationalite,
    this.passeport,
    this.preferences,
    this.niveauLangue,
    this.budgetMax,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    
    if (firstName != null) data['firstName'] = firstName;
    if (lastName != null) data['lastName'] = lastName;
    if (telephone != null) data['telephone'] = telephone;
    if (adresse != null) data['adresse'] = adresse;
    if (dateNaissance != null) data['dateNaissance'] = dateNaissance!.toIso8601String();
    if (cin != null) data['cin'] = cin;
    if (nationalite != null) data['nationalite'] = nationalite;
    if (passeport != null) data['passeport'] = passeport;
    if (preferences != null) data['preferences'] = preferences;
    if (niveauLangue != null) data['niveauLangue'] = niveauLangue;
    if (budgetMax != null) data['budgetMax'] = budgetMax;
    
    return data;
  }
}
