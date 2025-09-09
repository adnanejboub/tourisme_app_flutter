import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../../domain/entities/social_auth_entities.dart';
import '../../../../config/social_auth_config.dart';

/// Service pour l'authentification sociale
class SocialAuthService {
  // Configuration Google Sign-In
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: Platform.isIOS ? SocialAuthConfig.googleClientId : null,
    scopes: ['email', 'profile'],
  );

  /// Authentification avec Google
  static Future<SocialAuthEntity?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      return SocialAuthEntity(
        accessToken: googleAuth.accessToken ?? '',
        idToken: googleAuth.idToken,
        provider: 'google',
        providerId: googleUser.id,
        email: googleUser.email,
        displayName: googleUser.displayName,
        photoUrl: googleUser.photoUrl,
      );
    } catch (e) {
      debugPrint('Erreur Google Sign-In: $e');
      return null;
    }
  }

  /// Authentification avec Apple
  static Future<SocialAuthEntity?> signInWithApple() async {
    try {
      // Générer un nonce pour la sécurité
      final rawNonce = _generateNonce();
      final hashedNonce = _sha256ofString(rawNonce);

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      return SocialAuthEntity(
        accessToken: credential.identityToken ?? '',
        idToken: credential.identityToken,
        provider: 'apple',
        providerId: credential.userIdentifier ?? '',
        email: credential.email ?? '',
        displayName:
            credential.givenName != null && credential.familyName != null
            ? '${credential.givenName} ${credential.familyName}'
            : null,
        photoUrl: null, // Apple ne fournit pas de photo de profil
      );
    } catch (e) {
      debugPrint('Erreur Apple Sign-In: $e');
      return null;
    }
  }

  /// Authentification avec Facebook
  static Future<SocialAuthEntity?> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success) {
        final userData = await FacebookAuth.instance.getUserData();

        return SocialAuthEntity(
          accessToken: result.accessToken?.token ?? '',
          provider: 'facebook',
          providerId: userData['id'] ?? '',
          email: userData['email'] ?? '',
          displayName: userData['name'] ?? '',
          photoUrl: userData['picture']?['data']?['url'],
        );
      }
      return null;
    } catch (e) {
      debugPrint('Erreur Facebook Sign-In: $e');
      return null;
    }
  }

  /// Déconnexion de tous les services
  static Future<void> signOut() async {
    try {
      await Future.wait([
        _googleSignIn.signOut(),
        FacebookAuth.instance.logOut(),
      ]);
    } catch (e) {
      debugPrint('Erreur lors de la déconnexion: $e');
    }
  }

  /// Génération d'un nonce pour Apple Sign-In
  static String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  /// Hash SHA256 pour Apple Sign-In
  static String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
