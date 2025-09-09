import 'package:flutter_test/flutter_test.dart';
import '../lib/features/auth/data/models/social_auth_model.dart';
import '../lib/features/auth/domain/entities/social_auth_entities.dart';

void main() {
  group('Social Auth Models Tests', () {
    test('SocialAuthModel should be created from JSON', () {
      // Arrange
      final json = {
        'access_token': 'test_token',
        'refresh_token': 'refresh_token',
        'id_token': 'id_token',
        'provider': 'google',
        'provider_id': 'test_id',
        'email': 'test@example.com',
        'display_name': 'Test User',
        'photo_url': 'https://example.com/photo.jpg',
        'expires_at': 1640995200000, // 2022-01-01 00:00:00 UTC
      };

      // Act
      final model = SocialAuthModel.fromJson(json);

      // Assert
      expect(model.accessToken, equals('test_token'));
      expect(model.refreshToken, equals('refresh_token'));
      expect(model.idToken, equals('id_token'));
      expect(model.provider, equals('google'));
      expect(model.providerId, equals('test_id'));
      expect(model.email, equals('test@example.com'));
      expect(model.displayName, equals('Test User'));
      expect(model.photoUrl, equals('https://example.com/photo.jpg'));
      expect(
        model.expiresAt,
        equals(DateTime.fromMillisecondsSinceEpoch(1640995200000)),
      );
    });

    test('SocialAuthModel should convert to JSON', () {
      // Arrange
      final model = SocialAuthModel(
        accessToken: 'test_token',
        refreshToken: 'refresh_token',
        idToken: 'id_token',
        provider: 'facebook',
        providerId: 'fb_id',
        email: 'user@facebook.com',
        displayName: 'Facebook User',
        photoUrl: 'https://facebook.com/photo.jpg',
        expiresAt: DateTime.fromMillisecondsSinceEpoch(1640995200000),
      );

      // Act
      final json = model.toJson();

      // Assert
      expect(json['access_token'], equals('test_token'));
      expect(json['refresh_token'], equals('refresh_token'));
      expect(json['id_token'], equals('id_token'));
      expect(json['provider'], equals('facebook'));
      expect(json['provider_id'], equals('fb_id'));
      expect(json['email'], equals('user@facebook.com'));
      expect(json['display_name'], equals('Facebook User'));
      expect(json['photo_url'], equals('https://facebook.com/photo.jpg'));
      expect(json['expires_at'], equals(1640995200000));
    });

    test('SocialAuthModel should be created from entity', () {
      // Arrange
      final entity = SocialAuthEntity(
        accessToken: 'test_token',
        refreshToken: 'refresh_token',
        idToken: 'id_token',
        provider: 'apple',
        providerId: 'apple_id',
        email: 'user@apple.com',
        displayName: 'Apple User',
        photoUrl: 'https://apple.com/photo.jpg',
        expiresAt: DateTime.fromMillisecondsSinceEpoch(1640995200000),
      );

      // Act
      final model = SocialAuthModel.fromEntity(entity);

      // Assert
      expect(model.accessToken, equals(entity.accessToken));
      expect(model.refreshToken, equals(entity.refreshToken));
      expect(model.idToken, equals(entity.idToken));
      expect(model.provider, equals(entity.provider));
      expect(model.providerId, equals(entity.providerId));
      expect(model.email, equals(entity.email));
      expect(model.displayName, equals(entity.displayName));
      expect(model.photoUrl, equals(entity.photoUrl));
      expect(model.expiresAt, equals(entity.expiresAt));
    });

    test('SocialAuthParamsModel should be created from entity', () {
      // Arrange
      const entity = SocialAuthParams(
        provider: 'google',
        accessToken: 'google_token',
        idToken: 'google_id_token',
        email: 'user@gmail.com',
        displayName: 'Google User',
        photoUrl: 'https://google.com/photo.jpg',
      );

      // Act
      final model = SocialAuthParamsModel.fromEntity(entity);

      // Assert
      expect(model.provider, equals(entity.provider));
      expect(model.accessToken, equals(entity.accessToken));
      expect(model.idToken, equals(entity.idToken));
      expect(model.email, equals(entity.email));
      expect(model.displayName, equals(entity.displayName));
      expect(model.photoUrl, equals(entity.photoUrl));
    });

    test('SocialAuthParamsModel should convert to JSON', () {
      // Arrange
      const model = SocialAuthParamsModel(
        provider: 'facebook',
        accessToken: 'fb_token',
        idToken: 'fb_id_token',
        email: 'user@facebook.com',
        displayName: 'Facebook User',
        photoUrl: 'https://facebook.com/photo.jpg',
      );

      // Act
      final json = model.toJson();

      // Assert
      expect(json['provider'], equals('facebook'));
      expect(json['access_token'], equals('fb_token'));
      expect(json['id_token'], equals('fb_id_token'));
      expect(json['email'], equals('user@facebook.com'));
      expect(json['display_name'], equals('Facebook User'));
      expect(json['photo_url'], equals('https://facebook.com/photo.jpg'));
    });

    test('SocialAuthModel should handle null values', () {
      // Arrange
      final json = {
        'access_token': 'test_token',
        'provider': 'google',
        'provider_id': 'test_id',
        'email': 'test@example.com',
        // Other fields are null
      };

      // Act
      final model = SocialAuthModel.fromJson(json);

      // Assert
      expect(model.accessToken, equals('test_token'));
      expect(model.provider, equals('google'));
      expect(model.providerId, equals('test_id'));
      expect(model.email, equals('test@example.com'));
      expect(model.refreshToken, isNull);
      expect(model.idToken, isNull);
      expect(model.displayName, isNull);
      expect(model.photoUrl, isNull);
      expect(model.expiresAt, isNull);
    });
  });
}
