import 'package:flutter_test/flutter_test.dart';
import '../lib/features/auth/domain/entities/auth_entities.dart';
import '../lib/features/auth/domain/entities/social_auth_entities.dart';
import '../lib/features/auth/domain/repositories/social_auth_repository.dart';
import '../lib/features/auth/domain/usecases/social_auth_usecases.dart';

// Mock repository simple pour les tests
class MockSocialAuthRepository implements SocialAuthRepository {
  AuthEntity? _mockAuthEntity;
  Exception? _mockException;

  void setMockAuthEntity(AuthEntity authEntity) {
    _mockAuthEntity = authEntity;
    _mockException = null;
  }

  void setMockException(Exception exception) {
    _mockException = exception;
    _mockAuthEntity = null;
  }

  @override
  Future<AuthEntity> signInWithGoogle() async {
    if (_mockException != null) throw _mockException!;
    return _mockAuthEntity ?? AuthEntity(
      accessToken: 'google_token',
      refreshToken: 'google_refresh',
      expiresIn: 3600,
      tokenType: 'Bearer',
    );
  }

  @override
  Future<AuthEntity> signInWithApple() async {
    if (_mockException != null) throw _mockException!;
    return _mockAuthEntity ?? AuthEntity(
      accessToken: 'apple_token',
      refreshToken: 'apple_refresh',
      expiresIn: 3600,
      tokenType: 'Bearer',
    );
  }

  @override
  Future<AuthEntity> signInWithFacebook() async {
    if (_mockException != null) throw _mockException!;
    return _mockAuthEntity ?? AuthEntity(
      accessToken: 'facebook_token',
      refreshToken: 'facebook_refresh',
      expiresIn: 3600,
      tokenType: 'Bearer',
    );
  }

  @override
  Future<AuthEntity> registerWithSocialAuth(SocialAuthParams params) async {
    if (_mockException != null) throw _mockException!;
    return _mockAuthEntity ?? AuthEntity(
      accessToken: 'register_token',
      refreshToken: 'register_refresh',
      expiresIn: 3600,
      tokenType: 'Bearer',
    );
  }

  @override
  Future<AuthEntity> loginWithSocialAuth(SocialAuthParams params) async {
    if (_mockException != null) throw _mockException!;
    return _mockAuthEntity ?? AuthEntity(
      accessToken: 'login_token',
      refreshToken: 'login_refresh',
      expiresIn: 3600,
      tokenType: 'Bearer',
    );
  }
}

void main() {
  group('Social Auth Use Cases Tests', () {
    late MockSocialAuthRepository mockRepository;
    late SignInWithGoogleUseCase googleUseCase;
    late SignInWithAppleUseCase appleUseCase;
    late SignInWithFacebookUseCase facebookUseCase;

    setUp(() {
      mockRepository = MockSocialAuthRepository();
      googleUseCase = SignInWithGoogleUseCase(mockRepository);
      appleUseCase = SignInWithAppleUseCase(mockRepository);
      facebookUseCase = SignInWithFacebookUseCase(mockRepository);
    });

    group('Google Sign-In', () {
      test('should return AuthEntity on success', () async {
        // Arrange
        final expectedAuth = AuthEntity(
          accessToken: 'google_test_token',
          refreshToken: 'google_test_refresh',
          expiresIn: 3600,
          tokenType: 'Bearer',
        );
        mockRepository.setMockAuthEntity(expectedAuth);

        // Act
        final result = await googleUseCase();

        // Assert
        expect(result, equals(expectedAuth));
      });

      test('should throw exception on failure', () async {
        // Arrange
        mockRepository.setMockException(Exception('Google authentication failed'));

        // Act & Assert
        expect(() => googleUseCase(), throwsException);
      });
    });

    group('Apple Sign-In', () {
      test('should return AuthEntity on success', () async {
        // Arrange
        final expectedAuth = AuthEntity(
          accessToken: 'apple_test_token',
          refreshToken: 'apple_test_refresh',
          expiresIn: 3600,
          tokenType: 'Bearer',
        );
        mockRepository.setMockAuthEntity(expectedAuth);

        // Act
        final result = await appleUseCase();

        // Assert
        expect(result, equals(expectedAuth));
      });

      test('should throw exception on failure', () async {
        // Arrange
        mockRepository.setMockException(Exception('Apple authentication failed'));

        // Act & Assert
        expect(() => appleUseCase(), throwsException);
      });
    });

    group('Facebook Sign-In', () {
      test('should return AuthEntity on success', () async {
        // Arrange
        final expectedAuth = AuthEntity(
          accessToken: 'facebook_test_token',
          refreshToken: 'facebook_test_refresh',
          expiresIn: 3600,
          tokenType: 'Bearer',
        );
        mockRepository.setMockAuthEntity(expectedAuth);

        // Act
        final result = await facebookUseCase();

        // Assert
        expect(result, equals(expectedAuth));
      });

      test('should throw exception on failure', () async {
        // Arrange
        mockRepository.setMockException(Exception('Facebook authentication failed'));

        // Act & Assert
        expect(() => facebookUseCase(), throwsException);
      });
    });

    group('Use Case Integration', () {
      test('all use cases should work independently', () async {
        // Arrange
        final googleAuth = AuthEntity(
          accessToken: 'google_token',
          refreshToken: 'google_refresh',
          expiresIn: 3600,
          tokenType: 'Bearer',
        );
        
        final appleAuth = AuthEntity(
          accessToken: 'apple_token',
          refreshToken: 'apple_refresh',
          expiresIn: 3600,
          tokenType: 'Bearer',
        );
        
        final facebookAuth = AuthEntity(
          accessToken: 'facebook_token',
          refreshToken: 'facebook_refresh',
          expiresIn: 3600,
          tokenType: 'Bearer',
        );

        // Act & Assert - Google
        mockRepository.setMockAuthEntity(googleAuth);
        final googleResult = await googleUseCase();
        expect(googleResult.accessToken, equals('google_token'));

        // Act & Assert - Apple
        mockRepository.setMockAuthEntity(appleAuth);
        final appleResult = await appleUseCase();
        expect(appleResult.accessToken, equals('apple_token'));

        // Act & Assert - Facebook
        mockRepository.setMockAuthEntity(facebookAuth);
        final facebookResult = await facebookUseCase();
        expect(facebookResult.accessToken, equals('facebook_token'));
      });
    });
  });
}
