import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/auth_model.dart';
import '../models/social_auth_model.dart';
import '../../domain/entities/auth_entities.dart';
import '../../domain/entities/social_auth_entities.dart';

/// Interface pour la source de données d'authentification
abstract class AuthRemoteDataSource {
  Future<AuthModel> login(LoginParams params);
  Future<AuthModel> register(RegisterParams params);
  Future<UserProfileModel> getCurrentUser();
  Future<void> logout();
  Future<Map<String, dynamic>> testConnection();
  
  // New profile management methods
  Future<UserProfileModel> getCompleteProfile();
  Future<UserProfileModel> updateProfile(ProfileUpdateParams params);
  
  // Social authentication methods
  Future<AuthModel> loginWithSocialAuth(SocialAuthParamsModel params);
  Future<AuthModel> registerWithSocialAuth(SocialAuthParamsModel params);
}

/// Implémentation de la source de données d'authentification
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio = DioClient.instance;

  @override
  Future<AuthModel> login(LoginParams params) async {
    try {
      final loginRequest = LoginRequestModel.fromEntity(params);
      
      final response = await _dio.post(
        '/auth/login',
        data: loginRequest.toJson(),
      );

      if (response.statusCode == 200) {
        final authModel = AuthModel.fromJson(response.data);
        
        // Stocker le token automatiquement via l'extension Dio
        await _dio.updateAuthToken(authModel.accessToken);
        
        return authModel;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Nom d\'utilisateur ou mot de passe incorrect');
      } else if (e.response?.statusCode == 400) {
        final errorData = e.response?.data;
        if (errorData is Map<String, dynamic> && errorData['message'] != null) {
          throw Exception(errorData['message']);
        }
        throw Exception('Données de connexion invalides');
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Délai de connexion dépassé. Vérifiez votre connexion internet.');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Délai de réception dépassé. Le serveur met trop de temps à répondre.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('Impossible de se connecter au serveur. Vérifiez votre connexion internet.');
      } else {
        throw Exception('Erreur de connexion: ${e.message}');
      }
    } catch (e) {
      throw Exception('Erreur inattendue: $e');
    }
  }

  @override
  Future<AuthModel> register(RegisterParams params) async {
    try {
      final registerRequest = RegisterRequestModel.fromEntity(params);
      
      print('🔗 Making registration request to: ${_dio.options.baseUrl}/auth/register');
      print('📦 Request data: ${registerRequest.toJson()}');
      
      final response = await _dio.post(
        '/auth/register',
        data: registerRequest.toJson(),
      );

      print('✅ Registration response status: ${response.statusCode}');
      print('📦 Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // La réponse d'inscription peut contenir des tokens si l'utilisateur est automatiquement connecté
        if (response.data['access_token'] != null) {
          final authModel = AuthModel.fromJson(response.data);
          await _dio.updateAuthToken(authModel.accessToken);
          return authModel;
        } else {
          // Pas de token: effectuer une connexion automatique avec les mêmes identifiants
          final loginParams = LoginParams(identifier: params.username.isNotEmpty ? params.username : params.email, password: params.password);
          final loginModel = await login(loginParams);
          return loginModel;
        }
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }
    } on DioException catch (e) {
      print('❌ DioException during registration:');
      print('   Status: ${e.response?.statusCode}');
      print('   Message: ${e.message}');
      print('   Response data: ${e.response?.data}');
      
      if (e.response?.statusCode == 400) {
        final errorData = e.response?.data;
        if (errorData is Map<String, dynamic> && errorData['message'] != null) {
          throw Exception(errorData['message']);
        }
        throw Exception('Veuillez vérifier les informations saisies et réessayer');
      } else if (e.response?.statusCode == 409) {
        throw Exception('Un compte avec cet email ou nom d\'utilisateur existe déjà');
      } else if (e.response?.statusCode == 500) {
        final errorData = e.response?.data;
        if (errorData is Map<String, dynamic> && errorData['message'] != null) {
          throw Exception(errorData['message']);
        }
        throw Exception('Le serveur rencontre actuellement des difficultés. Veuillez réessayer dans quelques minutes.');
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('La connexion au serveur a pris trop de temps. Vérifiez votre connexion internet.');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Le serveur met trop de temps à répondre. Veuillez réessayer.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('Impossible de se connecter au serveur. Vérifiez votre connexion internet.');
      } else {
        throw Exception('Erreur d\'inscription: ${e.message}');
      }
    } catch (e) {
      print('❌ Unexpected error during registration: $e');
      throw Exception('Erreur inattendue: $e');
    }
  }

  @override
  Future<UserProfileModel> getCurrentUser() async {
    try {
      final response = await _dio.get('/auth/me');

      if (response.statusCode == 200) {
        return UserProfileModel.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Token d\'authentification invalide ou expiré');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Accès refusé');
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Délai de connexion dépassé. Vérifiez votre connexion internet.');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Délai de réception dépassé. Le serveur met trop de temps à répondre.');
      } else {
        throw Exception('Erreur de récupération du profil: ${e.message}');
      }
    } catch (e) {
      throw Exception('Erreur inattendue: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      // Appeler l'endpoint de déconnexion du backend
      await _dio.post('/auth/logout');
    } catch (e) {
      // Ignorer les erreurs de déconnexion côté serveur
      print('Erreur lors de la déconnexion côté serveur: $e');
    } finally {
      // Toujours nettoyer le token local
      await _dio.clearAuthToken();
    }
  }

  @override
  Future<Map<String, dynamic>> testConnection() async {
    try {
      print('🔗 Testing connection to: ${_dio.options.baseUrl}/auth/test/connection');
      
      final response = await _dio.get('/auth/test/connection');
      
      print('✅ Connection test response: ${response.data}');
      
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data);
      } else {
        throw Exception('Connection test failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ Connection test failed:');
      print('   Status: ${e.response?.statusCode}');
      print('   Message: ${e.message}');
      throw Exception('Erreur lors du test de connexion: $e');
    } catch (e) {
      print('❌ Unexpected error during connection test: $e');
      throw Exception('Erreur lors du test de connexion: $e');
    }
  }

  @override
  Future<UserProfileModel> getCompleteProfile() async {
    try {
      print('AuthRemoteDataSource: Calling /api/profile/complete endpoint...');
      final response = await _dio.get('/api/profile/complete');
      
      print('AuthRemoteDataSource: Response status: ${response.statusCode}');
      print('AuthRemoteDataSource: Response data: ${response.data}');
      
      if (response.statusCode == 200) {
        print('AuthRemoteDataSource: Successfully parsed profile data');
        return UserProfileModel.fromJson(response.data);
      } else {
        print('AuthRemoteDataSource: Bad response status: ${response.statusCode}');
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }
    } on DioException catch (e) {
      print('AuthRemoteDataSource: DioException occurred: ${e.message}');
      print('AuthRemoteDataSource: Response status: ${e.response?.statusCode}');
      print('AuthRemoteDataSource: Response data: ${e.response?.data}');
      
      if (e.response?.statusCode == 401) {
        throw Exception('Token d\'authentification invalide ou expiré');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Profil utilisateur non trouvé');
      } else {
        throw Exception('Erreur lors de la récupération du profil: ${e.message}');
      }
    } catch (e) {
      print('AuthRemoteDataSource: Unexpected error: $e');
      throw Exception('Erreur lors de la récupération du profil: $e');
    }
  }

  @override
  Future<UserProfileModel> updateProfile(ProfileUpdateParams params) async {
    try {
      print('AuthRemoteDataSource: Updating profile with data: ${params.toJson()}');
      
      final response = await _dio.put(
        '/api/profile/update',
        data: params.toJson(),
      );
      
      print('AuthRemoteDataSource: Update response status: ${response.statusCode}');
      print('AuthRemoteDataSource: Update response data: ${response.data}');
      
      if (response.statusCode == 200) {
        print('AuthRemoteDataSource: Profile updated successfully, fetching updated profile...');
        // After update, get the updated profile
        return await getCompleteProfile();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }
    } on DioException catch (e) {
      print('AuthRemoteDataSource: DioException during profile update: ${e.message}');
      print('AuthRemoteDataSource: Response status: ${e.response?.statusCode}');
      print('AuthRemoteDataSource: Response data: ${e.response?.data}');
      
      if (e.response?.statusCode == 401) {
        throw Exception('Token d\'authentification invalide ou expiré');
      } else if (e.response?.statusCode == 400) {
        final errorData = e.response?.data;
        if (errorData is Map<String, dynamic> && errorData['message'] != null) {
          throw Exception(errorData['message']);
        }
        throw Exception('Données de profil invalides');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Profil utilisateur non trouvé');
      } else if (e.response?.statusCode == 500) {
        final errorData = e.response?.data;
        if (errorData is Map<String, dynamic> && errorData['message'] != null) {
          throw Exception(errorData['message']);
        }
        throw Exception('Erreur serveur lors de la mise à jour du profil');
      } else {
        throw Exception('Erreur lors de la mise à jour du profil: ${e.message}');
      }
    } catch (e) {
      print('AuthRemoteDataSource: Unexpected error during profile update: $e');
      throw Exception('Erreur lors de la mise à jour du profil: $e');
    }
  }

  @override
  Future<AuthModel> loginWithSocialAuth(SocialAuthParamsModel params) async {
    try {
      print('🔗 Making social login request to: ${_dio.options.baseUrl}/auth/social/login');
      print('📦 Request data: ${params.toJson()}');
      
      final response = await _dio.post(
        '/auth/social/login',
        data: params.toJson(),
      );

      print('✅ Social login response status: ${response.statusCode}');
      print('📦 Response data: ${response.data}');

      if (response.statusCode == 200) {
        final authModel = AuthModel.fromJson(response.data);
        await _dio.updateAuthToken(authModel.accessToken);
        return authModel;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }
    } on DioException catch (e) {
      print('❌ DioException during social login:');
      print('   Status: ${e.response?.statusCode}');
      print('   Message: ${e.message}');
      print('   Response data: ${e.response?.data}');
      
      if (e.response?.statusCode == 401) {
        throw Exception('Échec de l\'authentification sociale');
      } else if (e.response?.statusCode == 400) {
        final errorData = e.response?.data;
        if (errorData is Map<String, dynamic> && errorData['message'] != null) {
          throw Exception(errorData['message']);
        }
        throw Exception('Données d\'authentification sociale invalides');
      } else {
        throw Exception('Erreur lors de la connexion sociale: ${e.message}');
      }
    } catch (e) {
      print('❌ Unexpected error during social login: $e');
      throw Exception('Erreur lors de la connexion sociale: $e');
    }
  }

  @override
  Future<AuthModel> registerWithSocialAuth(SocialAuthParamsModel params) async {
    try {
      print('🔗 Making social register request to: ${_dio.options.baseUrl}/auth/social/register');
      print('📦 Request data: ${params.toJson()}');
      
      final response = await _dio.post(
        '/auth/social/register',
        data: params.toJson(),
      );

      print('✅ Social register response status: ${response.statusCode}');
      print('📦 Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final authModel = AuthModel.fromJson(response.data);
        await _dio.updateAuthToken(authModel.accessToken);
        return authModel;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }
    } on DioException catch (e) {
      print('❌ DioException during social register:');
      print('   Status: ${e.response?.statusCode}');
      print('   Message: ${e.message}');
      print('   Response data: ${e.response?.data}');
      
      if (e.response?.statusCode == 400) {
        final errorData = e.response?.data;
        if (errorData is Map<String, dynamic> && errorData['message'] != null) {
          throw Exception(errorData['message']);
        }
        throw Exception('Données d\'enregistrement social invalides');
      } else if (e.response?.statusCode == 409) {
        throw Exception('Un compte avec cet email existe déjà');
      } else {
        throw Exception('Erreur lors de l\'enregistrement social: ${e.message}');
      }
    } catch (e) {
      print('❌ Unexpected error during social register: $e');
      throw Exception('Erreur lors de l\'enregistrement social: $e');
    }
  }
}
