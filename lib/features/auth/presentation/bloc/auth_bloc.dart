import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/auth_entities.dart';
import '../../domain/usecases/auth_usecases.dart';
import '../../../../core/services/guest_mode_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String identifier; // username or email
  final String password;

  const LoginRequested({required this.identifier, required this.password});

  @override
  List<Object?> get props => [identifier, password];
}

class RegisterRequested extends AuthEvent {
  final RegisterParams params;

  const RegisterRequested(this.params);

  @override
  List<Object?> get props => [params];
}

class LogoutRequested extends AuthEvent {}

class GetCurrentUserRequested extends AuthEvent {}

// States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserProfileEntity user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthGuestMode extends AuthState {}

class AuthSuccess extends AuthState {
  final AuthEntity auth;

  const AuthSuccess(this.auth);

  @override
  List<Object?> get props => [auth];
}

class AuthFailure extends AuthState {
  final String message;

  const AuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;

  //ysser code:
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'access_token';

  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  AuthBloc({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required LogoutUseCase logoutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
  }) : _loginUseCase = loginUseCase,
       _registerUseCase = registerUseCase,
       _logoutUseCase = logoutUseCase,
       _getCurrentUserUseCase = getCurrentUserUseCase,
       super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<GetCurrentUserRequested>(_onGetCurrentUserRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final params = LoginParams(
        identifier: event.identifier, // Use identifier (username or email)
        password: event.password,
      );

      final auth = await _loginUseCase(params);

      //yasser code:
      // ✅ Save the token as soon as login succeeds
      await saveToken(auth.accessToken);
      emit(AuthSuccess(auth));

      // Récupérer automatiquement le profil utilisateur
      try {
        final user = await _getCurrentUserUseCase(null);
        emit(AuthAuthenticated(user));
      } catch (e) {
        // Si on ne peut pas récupérer le profil, on reste en AuthSuccess
        print('Impossible de récupérer le profil utilisateur: $e');
      }
    } catch (e) {
      // Extract the actual error message from AuthException
      String errorMessage = e.toString();
      if (e is AuthException) {
        errorMessage = e.message;
      } else if (e.toString().contains('AuthException:')) {
        // Extract message from AuthException string representation
        final regex = RegExp(r'AuthException: (.+?) \(Type:');
        final match = regex.firstMatch(e.toString());
        if (match != null && match.group(1) != null) {
          errorMessage = match.group(1)!.trim();
        }
      }
      emit(AuthFailure(errorMessage));
    }
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final auth = await _registerUseCase(event.params);
      emit(AuthSuccess(auth));

      // Récupérer automatiquement le profil utilisateur si l'inscription inclut une connexion
      if (auth.accessToken.isNotEmpty) {
        try {
          final user = await _getCurrentUserUseCase(null);
          emit(AuthAuthenticated(user));
        } catch (e) {
          // Si on ne peut pas récupérer le profil, on reste en AuthSuccess
          print('Impossible de récupérer le profil utilisateur: $e');
        }
      }
    } catch (e) {
      // Extract the actual error message from AuthException
      String errorMessage = e.toString();
      if (e is AuthException) {
        errorMessage = e.message;
      } else if (e.toString().contains('AuthException:')) {
        // Extract message from AuthException string representation
        final regex = RegExp(r'AuthException: (.+?) \(Type:');
        final match = regex.firstMatch(e.toString());
        if (match != null && match.group(1) != null) {
          errorMessage = match.group(1)!.trim();
        }
      }
      emit(AuthFailure(errorMessage));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      await _logoutUseCase(null);
      emit(AuthUnauthenticated());
    } catch (e) {
      // Même en cas d'erreur, on déconnecte localement
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onGetCurrentUserRequested(
    GetCurrentUserRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final user = await _getCurrentUserUseCase(null);
      emit(AuthAuthenticated(user));
    } catch (e) {
      // Check if user is in guest mode
      final guestModeService = GuestModeService();
      if (guestModeService.isGuestMode) {
        // If in guest mode, emit guest mode state
        emit(AuthGuestMode());
        return;
      }

      // Extract the actual error message from AuthException
      String errorMessage = e.toString();
      if (e is AuthException) {
        errorMessage = e.message;
      } else if (e.toString().contains('AuthException:')) {
        // Extract message from AuthException string representation
        final regex = RegExp(r'AuthException: (.+?) \(Type:');
        final match = regex.firstMatch(e.toString());
        if (match != null && match.group(1) != null) {
          errorMessage = match.group(1)!.trim();
        }
      }
      emit(AuthFailure(errorMessage));
    }
  }
}
