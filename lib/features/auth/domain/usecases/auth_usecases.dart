import 'dart:math';

import 'package:logger/logger.dart';

import '../entities/auth_entities.dart';
import '../repositories/auth_repository.dart';
import '../../../../core/usecases/usecase.dart';

/// Erreurs typées pour l'authentification
class AuthException implements Exception {
  final String message;
  final AuthErrorType type;

  AuthException(this.message, this.type);

  @override
  String toString() => 'AuthException: $message (Type: $type)';
}

enum AuthErrorType {
  network,
  validation,
  unauthorized,
  forbidden,
  serverError,
  unknown,
}

/// Use case pour l'inscription d'un utilisateur
class RegisterUseCase implements UseCase<AuthEntity, RegisterParams> {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  @override
  Future<AuthEntity> call(RegisterParams params) async {
    try {
      // Validation des paramètres
      _validateRegisterParams(params);
      
      return await repository.register(params);
    } on AuthException {
      rethrow;
    } catch (e) {
      final errorMessage = e.toString().toLowerCase();
      
      // Validation errors
      if (errorMessage.contains('validation_error') || errorMessage.contains('données d\'inscription invalides')) {
        throw AuthException(_extractValidationMessage(e.toString()), AuthErrorType.validation);
      }
      
      // Duplicate user error
      if (errorMessage.contains('409') || errorMessage.contains('existe déjà')) {
        throw AuthException('Un compte avec cet email ou nom d\'utilisateur existe déjà. Veuillez utiliser des informations différentes.', AuthErrorType.validation);
      }
      
      // Network errors
      if (errorMessage.contains('timeout') || errorMessage.contains('délai')) {
        throw AuthException('La connexion au serveur a pris trop de temps. Veuillez vérifier votre connexion internet et réessayer.', AuthErrorType.network);
      }
      
      if (errorMessage.contains('connection') || errorMessage.contains('réseau')) {
        throw AuthException('Impossible de se connecter au serveur. Veuillez vérifier votre connexion internet et réessayer.', AuthErrorType.network);
      }
      
      // Server errors
      if (errorMessage.contains('500') || errorMessage.contains('serveur')) {
        throw AuthException('Le serveur rencontre actuellement des difficultés. Veuillez réessayer dans quelques minutes.', AuthErrorType.serverError);
      }
      
      // Unknown errors
      throw AuthException('Une erreur inattendue s\'est produite lors de l\'inscription. Veuillez réessayer.', AuthErrorType.unknown);
    }
  }

  void _validateRegisterParams(RegisterParams params) {
    if (params.username.isEmpty || params.username.length < 3) {
      throw AuthException('Le nom d\'utilisateur doit contenir au moins 3 caractères', AuthErrorType.validation);
    }
    if (params.email.isEmpty || !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(params.email)) {
      throw AuthException('Veuillez saisir une adresse email valide', AuthErrorType.validation);
    }
    if (params.password.isEmpty || params.password.length < 6) {
      throw AuthException('Le mot de passe doit contenir au moins 6 caractères', AuthErrorType.validation);
    }
    if (params.firstName.isEmpty || params.firstName.length < 2) {
      throw AuthException('Le prénom doit contenir au moins 2 caractères', AuthErrorType.validation);
    }
    if (params.lastName.isEmpty || params.lastName.length < 2) {
      throw AuthException('Le nom doit contenir au moins 2 caractères', AuthErrorType.validation);
    }
  }

  /// Extrait le message d'erreur de validation depuis la réponse du serveur
  String _extractValidationMessage(String errorString) {
    // Essayer d'extraire le message du serveur
    if (errorString.contains('message')) {
      final regex = RegExp(r'message["\s]*:["\s]*([^"]+)');
      final match = regex.firstMatch(errorString);
      if (match != null && match.group(1) != null) {
        return match.group(1)!.trim();
      }
    }
    
    // Fallback vers des messages génériques
    if (errorString.contains('validation')) {
      return 'Veuillez vérifier les informations saisies et réessayer.';
    }
    
    return 'Une erreur de validation s\'est produite. Veuillez vérifier vos informations.';
  }
}

/// Use case pour la connexion d'un utilisateur
class LoginUseCase implements UseCase<AuthEntity, LoginParams> {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  @override
  Future<AuthEntity> call(LoginParams params) async {
    try {
      // Validation des paramètres
      _validateLoginParams(params);
      var logger = Logger();
      logger.e("LoginParams reçus : ${params.toString()}");
      return await repository.login(params);
    } on AuthException {
      rethrow;
    } catch (e) {
      final errorMessage = e.toString().toLowerCase();
      
      // Authentication errors
      if (errorMessage.contains('401') || 
          errorMessage.contains('incorrect') || 
          errorMessage.contains('invalid username or password')) {
        throw AuthException('Nom d\'utilisateur ou mot de passe incorrect. Veuillez vérifier vos informations de connexion.', AuthErrorType.unauthorized);
      }
      
      // Validation errors
      if (errorMessage.contains('validation') || errorMessage.contains('invalides')) {
        throw AuthException('Veuillez remplir tous les champs requis correctement.', AuthErrorType.validation);
      }
      
      // Network errors
      if (errorMessage.contains('timeout') || errorMessage.contains('délai')) {
        throw AuthException('La connexion au serveur a pris trop de temps. Veuillez vérifier votre connexion internet et réessayer.', AuthErrorType.network);
      }
      
      if (errorMessage.contains('connection') || errorMessage.contains('réseau')) {
        throw AuthException('Impossible de se connecter au serveur. Veuillez vérifier votre connexion internet et réessayer.', AuthErrorType.network);
      }
      
      // Server errors
      if (errorMessage.contains('500') || errorMessage.contains('serveur')) {
        throw AuthException('Le serveur rencontre actuellement des difficultés. Veuillez réessayer dans quelques minutes.', AuthErrorType.serverError);
      }
      
      // Unknown errors
      throw AuthException('Une erreur inattendue s\'est produite lors de la connexion. Veuillez réessayer.', AuthErrorType.unknown);
    }
  }

  void _validateLoginParams(LoginParams params) {
    if (params.username.isEmpty) {
      throw AuthException('Veuillez saisir votre nom d\'utilisateur ou email', AuthErrorType.validation);
    }
    if (params.password.isEmpty) {
      throw AuthException('Veuillez saisir votre mot de passe', AuthErrorType.validation);
    }
  }
}

/// Use case pour récupérer le profil utilisateur
class GetCurrentUserUseCase implements UseCase<UserProfileEntity, void> {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  @override
  Future<UserProfileEntity> call(void params) async {
    try {
      return await repository.getCurrentUser();
    } on AuthException {
      rethrow;
    } catch (e) {
      if (e.toString().contains('401') || e.toString().contains('Token')) {
        throw AuthException('Token d\'authentification invalide ou expiré', AuthErrorType.unauthorized);
      } else if (e.toString().contains('403')) {
        throw AuthException('Accès refusé', AuthErrorType.forbidden);
      } else if (e.toString().contains('timeout')) {
        throw AuthException('Délai de connexion dépassé', AuthErrorType.network);
      } else if (e.toString().contains('connection')) {
        throw AuthException('Erreur de connexion réseau', AuthErrorType.network);
      } else {
        throw AuthException('Erreur de récupération du profil: $e', AuthErrorType.unknown);
      }
    }
  }
}

/// Use case pour la déconnexion
class LogoutUseCase implements UseCase<void, void> {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  @override
  Future<void> call(void params) async {
    try {
      await repository.logout();
    } on AuthException {
      rethrow;
    } catch (e) {
      // Pour la déconnexion, on ignore les erreurs côté serveur
      // mais on peut logger l'erreur
      print('Erreur lors de la déconnexion côté serveur: $e');
    }
  }
}

/// Use case pour vérifier si l'utilisateur est connecté
class IsLoggedInUseCase implements UseCase<bool, void> {
  final AuthRepository repository;

  IsLoggedInUseCase(this.repository);

  @override
  Future<bool> call(void params) async {
    try {
      // Essayer de récupérer le profil utilisateur
      await repository.getCurrentUser();
      return true;
    } catch (e) {
      return false;
    }
  }
}
