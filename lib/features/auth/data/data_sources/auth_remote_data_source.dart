import 'dart:io';
import 'package:dio/dio.dart';
import '../models/auth_models.dart';

/// Source de données distante pour l'authentification
abstract class AuthRemoteDataSource {
  Future<LoginResponseModel> login(LoginRequestModel request);
  Future<Map<String, dynamic>> register(RegisterRequestModel request);
  Future<UserProfileModel> getCurrentUser();
  Future<void> logout();
}

/// Implémentation de la source de données distante
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;
  final String baseUrl;

  AuthRemoteDataSourceImpl({
    required this.dio,
    this.baseUrl = 'http://10.0.2.2:8080', // Pour l'émulateur Android
  });

  @override
  Future<LoginResponseModel> login(LoginRequestModel request) async {
    try {
      final response = await dio.post(
        '$baseUrl/auth/login',
        data: request.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return LoginResponseModel.fromJson(response.data);
      } else {
        throw _handleErrorResponse(response);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> register(RegisterRequestModel request) async {
    try {
      final response = await dio.post(
        '$baseUrl/auth/register',
        data: request.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw _handleErrorResponse(response);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<UserProfileModel> getCurrentUser() async {
    try {
      final response = await dio.get(
        '$baseUrl/auth/me',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            // Le token sera ajouté automatiquement par l'intercepteur
          },
        ),
      );

      if (response.statusCode == 200) {
        return UserProfileModel.fromJson(response.data);
      } else {
        throw _handleErrorResponse(response);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await dio.post(
        '$baseUrl/auth/logout',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
    } on DioException catch (e) {
      // On ne lance pas d'erreur pour la déconnexion
      // car même si l'appel échoue, on veut déconnecter localement
      print('Logout API call failed: ${e.message}');
    }
  }

  /// Gestion des erreurs de réponse HTTP
  Exception _handleErrorResponse(Response response) {
    try {
      final errorData = response.data;
      if (errorData is Map<String, dynamic>) {
        final apiError = ApiErrorModel.fromJson(errorData);
        
        switch (response.statusCode) {
          case 400:
            return AuthException(apiError.message, AuthErrorType.validation);
          case 401:
            return AuthException(apiError.message, AuthErrorType.unauthorized);
          case 403:
            return AuthException(apiError.message, AuthErrorType.forbidden);
          case 409:
            return AuthException(apiError.message, AuthErrorType.conflict);
          case 500:
            return AuthException(apiError.message, AuthErrorType.server);
          default:
            return AuthException(apiError.message, AuthErrorType.unknown);
        }
      }
    } catch (e) {
      // Si on ne peut pas parser l'erreur, on utilise le message par défaut
    }
    
    return AuthException(
      'Une erreur s\'est produite (${response.statusCode})',
      AuthErrorType.unknown,
    );
  }

  /// Gestion des erreurs Dio
  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return AuthException(
          'Délai d\'attente dépassé. Vérifiez votre connexion internet.',
          AuthErrorType.timeout,
        );
      case DioExceptionType.connectionError:
        return AuthException(
          'Impossible de se connecter au serveur. Vérifiez votre connexion internet.',
          AuthErrorType.network,
        );
      case DioExceptionType.badResponse:
        return _handleErrorResponse(e.response!);
      case DioExceptionType.cancel:
        return AuthException(
          'Requête annulée',
          AuthErrorType.cancelled,
        );
      default:
        return AuthException(
          'Une erreur inattendue s\'est produite',
          AuthErrorType.unknown,
        );
    }
  }
}

/// Types d'erreurs d'authentification
enum AuthErrorType {
  validation,
  unauthorized,
  forbidden,
  conflict,
  server,
  network,
  timeout,
  cancelled,
  unknown,
}

/// Exception personnalisée pour l'authentification
class AuthException implements Exception {
  final String message;
  final AuthErrorType type;

  AuthException(this.message, this.type);

  @override
  String toString() => 'AuthException: $message (Type: $type)';
}
