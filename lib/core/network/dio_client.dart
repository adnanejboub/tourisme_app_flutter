import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

/// Client Dio configuré pour l'application
class DioClient {
  static Dio? _instance;
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';

  // Configuration du stockage sécurisé
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  /// Singleton pour obtenir l'instance Dio
  static Dio get instance {
    _instance ??= _createDio();
    return _instance!;
  }

  /// Création de l'instance Dio avec configuration
  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: _getBaseUrl(),
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (status) {
          return status != null && status < 500;
        },
      ),
    );

    // Ajouter l'intercepteur pour les tokens
    dio.interceptors.add(_AuthInterceptor());

    // Ajouter l'intercepteur de retry pour les erreurs de connexion
    dio.interceptors.add(_RetryInterceptor());

    // Ajouter l'intercepteur pour les logs (en mode debug)
    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => debugPrint(obj as String?),
      ));
    }

    return dio;
  }

  /// Détermine l'URL de base selon la plateforme
  static String _getBaseUrl() {
    if (kIsWeb) {
      return 'http://localhost:8080';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:8080';
    } else if (Platform.isIOS) {
      return 'http://localhost:8080';
    } else {
      return 'http://localhost:8080';
    }
  }

  /// Méthode pour mettre à jour l'URL de base
  static void updateBaseUrl(String baseUrl) {
    if (_instance != null) {
      _instance!.options.baseUrl = baseUrl;
    }
  }

  /// Méthode pour nettoyer l'instance (utile pour les tests)
  static void clearInstance() {
    _instance = null;
  }

  /// Méthode pour nettoyer les tokens expirés au démarrage de l'app
  static Future<void> clearExpiredTokens() async {
    try {
      // Nettoyer automatiquement les tokens stockés
      await _secureStorage.delete(key: _tokenKey);
      await _secureStorage.delete(key: _refreshTokenKey);

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_refreshTokenKey);
      
      debugPrint('Tokens expirés nettoyés au démarrage de l\'app');
    } catch (e) {
      debugPrint('Erreur lors du nettoyage des tokens: $e');
    }
  }
}

/// Intercepteur pour gérer automatiquement les tokens d'authentification
class _AuthInterceptor extends Interceptor {
  // Liste des endpoints qui ne nécessitent PAS de token
  static const List<String> _publicEndpoints = [
    '/auth/login',
    '/auth/register',
    '/auth/password/forgot',
    '/auth/email/verify',
    '/auth/email/resend-verification',
    '/auth/test/connection',
  ];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Vérifier si c'est un endpoint public qui ne nécessite pas de token
    final isPublicEndpoint = _publicEndpoints.any((endpoint) => 
        options.path == endpoint || 
        options.path.endsWith(endpoint) || 
        options.path.startsWith('/public'));
    
    print('AuthInterceptor: Request to ${options.path}');
    print('AuthInterceptor: Is public endpoint: $isPublicEndpoint');
    
    // Ajouter le token d'authentification seulement si ce n'est pas un endpoint public
    if (!isPublicEndpoint) {
      final token = await _getStoredToken();
      print('AuthInterceptor: Token found: ${token != null ? 'Yes (${token?.substring(0, 20)}...)' : 'No'}');
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
        print('AuthInterceptor: Authorization header added');
      } else {
        print('AuthInterceptor: No token available for authenticated endpoint');
      }
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Traitement de la réponse si nécessaire
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Gestion des erreurs d'authentification
    if (err.response?.statusCode == 401) {
      // Token expiré ou invalide, nettoyer le stockage local
      await _clearStoredTokens();

      // Ici on pourrait implémenter un refresh token automatique
      // ou rediriger vers la page de connexion
      debugPrint('Token expiré ou invalide - déconnexion automatique');
    } else if (err.response?.statusCode == 403) {
      debugPrint('Accès refusé - permissions insuffisantes');
    } else if (err.type == DioExceptionType.connectionTimeout) {
      debugPrint('Délai de connexion dépassé');
    } else if (err.type == DioExceptionType.receiveTimeout) {
      debugPrint('Délai de réception dépassé');
    } else if (err.type == DioExceptionType.connectionError) {
      debugPrint('Erreur de connexion réseau');
    }

    handler.next(err);
  }

  /// Récupération du token stocké (priorité au stockage sécurisé)
  Future<String?> _getStoredToken() async {
    try {
      // Essayer d'abord le stockage sécurisé
      String? token = await DioClient._secureStorage.read(key: DioClient._tokenKey);

      // Fallback vers SharedPreferences si nécessaire
      if (token == null) {
        final prefs = await SharedPreferences.getInstance();
        token = prefs.getString(DioClient._tokenKey);
      }

      return token;
    } catch (e) {
      debugPrint('Erreur lors de la récupération du token: $e');
      return null;
    }
  }

  /// Suppression des tokens stockés
  Future<void> _clearStoredTokens() async {
    try {
      // Nettoyer le stockage sécurisé
      await DioClient._secureStorage.delete(key: DioClient._tokenKey);
      await DioClient._secureStorage.delete(key: DioClient._refreshTokenKey);

      // Nettoyer SharedPreferences aussi
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(DioClient._tokenKey);
      await prefs.remove(DioClient._refreshTokenKey);
    } catch (e) {
      debugPrint('Erreur lors de la suppression des tokens: $e');
    }
  }
}

/// Extension pour faciliter l'utilisation du client Dio
extension DioExtension on Dio {
  /// Méthode pour mettre à jour le token d'authentification
  Future<void> updateAuthToken(String token) async {
    try {
      // Stocker dans le stockage sécurisé en priorité
      await DioClient._secureStorage.write(key: DioClient._tokenKey, value: token);

      // Fallback vers SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(DioClient._tokenKey, token);
    } catch (e) {
      debugPrint('Erreur lors de la mise à jour du token: $e');
    }
  }

  /// Méthode pour mettre à jour le refresh token
  Future<void> updateRefreshToken(String refreshToken) async {
    try {
      await DioClient._secureStorage.write(key: DioClient._refreshTokenKey, value: refreshToken);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(DioClient._refreshTokenKey, refreshToken);
    } catch (e) {
      debugPrint('Erreur lors de la mise à jour du refresh token: $e');
    }
  }

  /// Méthode pour supprimer les tokens d'authentification
  Future<void> clearAuthToken() async {
    try {
      // Nettoyer le stockage sécurisé
      await DioClient._secureStorage.delete(key: DioClient._tokenKey);
      await DioClient._secureStorage.delete(key: DioClient._refreshTokenKey);

      // Nettoyer SharedPreferences aussi
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(DioClient._tokenKey);
      await prefs.remove(DioClient._refreshTokenKey);
    } catch (e) {
      debugPrint('Erreur lors de la suppression des tokens: $e');
    }
  }

  /// Méthode pour vérifier si un token existe
  Future<bool> hasAuthToken() async {
    try {
      String? token = await DioClient._secureStorage.read(key: DioClient._tokenKey);
      if (token == null) {
        final prefs = await SharedPreferences.getInstance();
        token = prefs.getString(DioClient._tokenKey);
      }
      return token != null && token.isNotEmpty;
    } catch (e) {
      debugPrint('Erreur lors de la vérification du token: $e');
      return false;
    }
  }
}

/// Intercepteur pour gérer les tentatives de reconnexion
class _RetryInterceptor extends Interceptor {
  static const int _maxRetries = 2;
  static const Duration _retryDelay = Duration(seconds: 1);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Ne pas retry pour les endpoints publics si le serveur n'est pas disponible
    if (err.requestOptions.path.startsWith('/public')) {
      debugPrint('RetryInterceptor: Public endpoint failed, not retrying: ${err.requestOptions.path}');
      handler.next(err);
      return;
    }

    // Retry seulement pour les erreurs de connexion
    if (_shouldRetry(err) && err.requestOptions.extra['retryCount'] == null) {
      final retryCount = (err.requestOptions.extra['retryCount'] as int?) ?? 0;
      
      if (retryCount < _maxRetries) {
        debugPrint('RetryInterceptor: Retrying request (${retryCount + 1}/$_maxRetries): ${err.requestOptions.path}');
        
        // Attendre avant de retry
        await Future.delayed(_retryDelay);
        
        // Mettre à jour le compteur de retry
        err.requestOptions.extra['retryCount'] = retryCount + 1;
        
        try {
          final response = await DioClient.instance.fetch(err.requestOptions);
          handler.resolve(response);
          return;
        } catch (e) {
          if (e is DioException) {
            handler.next(e);
            return;
          }
        }
      }
    }
    
    handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
           err.type == DioExceptionType.receiveTimeout ||
           err.type == DioExceptionType.connectionError ||
           (err.response?.statusCode != null && err.response!.statusCode! >= 500);
  }
}
