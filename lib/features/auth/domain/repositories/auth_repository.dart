import '../entities/auth_entities.dart';

/// Interface du repository d'authentification
abstract class AuthRepository {
  /// Connexion d'un utilisateur
  Future<AuthEntity> login(LoginParams params);
  
  /// Inscription d'un nouvel utilisateur
  Future<AuthEntity> register(RegisterParams params);
  
  /// Récupération du profil de l'utilisateur connecté
  Future<UserProfileEntity> getCurrentUser();
  
  /// Déconnexion de l'utilisateur
  Future<void> logout();
  
  /// Vérification si l'utilisateur est connecté
  Future<bool> isLoggedIn();
  
  /// Test de connexion au serveur
  Future<Map<String, dynamic>> testConnection();
  
  // New profile management methods
  Future<UserProfileEntity> getCompleteProfile();
  Future<UserProfileEntity> updateProfile(ProfileUpdateParams params);
}
