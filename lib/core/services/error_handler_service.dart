import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class ErrorHandlerService {
  static void showErrorSnackBar(BuildContext context, dynamic error, {String? customMessage}) {
    String message = _getErrorMessage(error);
    if (customMessage != null) {
      message = customMessage;
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Fermer',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void showInfoSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static String _getErrorMessage(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return 'Délai de connexion dépassé. Vérifiez votre connexion internet.';
        case DioExceptionType.receiveTimeout:
          return 'Délai de réception dépassé. Le serveur met trop de temps à répondre.';
        case DioExceptionType.sendTimeout:
          return 'Délai d\'envoi dépassé. Vérifiez votre connexion internet.';
        case DioExceptionType.connectionError:
          return 'Erreur de connexion. Vérifiez votre connexion internet ou que le serveur est démarré.';
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          if (statusCode == 500) {
            return 'Erreur serveur. Le serveur n\'est pas disponible. Mode hors ligne activé.';
          } else if (statusCode == 404) {
            return 'Ressource non trouvée.';
          } else if (statusCode == 401) {
            return 'Non autorisé. Veuillez vous reconnecter.';
          } else if (statusCode == 403) {
            return 'Accès refusé.';
          } else {
            return 'Erreur serveur (${statusCode ?? 'inconnu'}).';
          }
        case DioExceptionType.cancel:
          return 'Requête annulée.';
        case DioExceptionType.unknown:
          return 'Erreur inconnue. Vérifiez votre connexion internet.';
        default:
          return 'Erreur de connexion. Mode hors ligne activé.';
      }
    } else if (error is Exception) {
      return 'Erreur: ${error.toString()}';
    } else {
      return 'Une erreur inattendue s\'est produite.';
    }
  }

  static bool isConnectionError(dynamic error) {
    if (error is DioException) {
      return error.type == DioExceptionType.connectionTimeout ||
             error.type == DioExceptionType.receiveTimeout ||
             error.type == DioExceptionType.sendTimeout ||
             error.type == DioExceptionType.connectionError ||
             (error.response?.statusCode != null && error.response!.statusCode! >= 500);
    }
    return false;
  }

  static bool isServerError(dynamic error) {
    if (error is DioException) {
      return error.response?.statusCode != null && error.response!.statusCode! >= 500;
    }
    return false;
  }

  static bool isAuthError(dynamic error) {
    if (error is DioException) {
      return error.response?.statusCode == 401 || error.response?.statusCode == 403;
    }
    return false;
  }
}

class ErrorRetryWidget extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onRetry;
  final Widget? child;

  const ErrorRetryWidget({
    super.key,
    required this.title,
    required this.message,
    required this.onRetry,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
          if (child != null) ...[
            const SizedBox(height: 16),
            child!,
          ],
        ],
      ),
    );
  }
}

class OfflineModeWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const OfflineModeWidget({
    super.key,
    this.message = 'Mode hors ligne - Données locales utilisées',
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.wifi_off,
            color: Colors.orange,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: Colors.orange.shade700,
              ),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: onRetry,
              child: Text(
                'Réessayer',
                style: TextStyle(
                  color: Colors.orange.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
