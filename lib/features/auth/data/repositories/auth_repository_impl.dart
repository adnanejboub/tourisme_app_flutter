import '../../domain/entities/auth_entities.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/auth_model.dart';
import '../../../../core/network/dio_client.dart';

/// Implémentation du repository d'authentification
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<AuthEntity> login(LoginParams params) async {
    try {
      final authModel = await _remoteDataSource.login(params);
      return authModel; // AuthModel hérite de AuthEntity
    } catch (e) {
      throw Exception('Erreur lors de la connexion: $e');
    }
  }

  @override
  Future<AuthEntity> register(RegisterParams params) async {
    try {
      final authModel = await _remoteDataSource.register(params);
      return authModel; // AuthModel hérite de AuthEntity
    } catch (e) {
      throw Exception('Erreur lors de l\'inscription: $e');
    }
  }

  @override
  Future<UserProfileEntity> getCurrentUser() async {
    try {
      final userProfileModel = await _remoteDataSource.getCurrentUser();
      return userProfileModel; // UserProfileModel hérite de UserProfileEntity
    } catch (e) {
      throw Exception('Erreur lors de la récupération du profil: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _remoteDataSource.logout();
    } catch (e) {
      throw Exception('Erreur lors de la déconnexion: $e');
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      // Vérifier si un token existe
      final hasToken = await DioClient.instance.hasAuthToken();
      if (!hasToken) return false;
      
      // Essayer de récupérer le profil utilisateur
      await _remoteDataSource.getCurrentUser();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>> testConnection() async {
    try {
      return await _remoteDataSource.testConnection();
    } catch (e) {
      throw Exception('Erreur lors du test de connexion: $e');
    }
  }
}
