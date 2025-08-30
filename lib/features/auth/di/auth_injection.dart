import 'package:get_it/get_it.dart';
import '../data/datasources/auth_remote_data_source.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/usecases/auth_usecases.dart';
import '../presentation/bloc/auth_bloc.dart';

/// Configuration de l'injection de dépendances pour l'authentification
class AuthInjection {
  static final GetIt _getIt = GetIt.instance;

  /// Initialise toutes les dépendances d'authentification
  static void init() {
    // Data sources
    _getIt.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(),
    );

    // Repositories
    _getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(_getIt<AuthRemoteDataSource>()),
    );

    // Use cases
    _getIt.registerLazySingleton<LoginUseCase>(
      () => LoginUseCase(_getIt<AuthRepository>()),
    );

    _getIt.registerLazySingleton<RegisterUseCase>(
      () => RegisterUseCase(_getIt<AuthRepository>()),
    );

    _getIt.registerLazySingleton<LogoutUseCase>(
      () => LogoutUseCase(_getIt<AuthRepository>()),
    );

    _getIt.registerLazySingleton<GetCurrentUserUseCase>(
      () => GetCurrentUserUseCase(_getIt<AuthRepository>()),
    );

    // BLoC
    _getIt.registerFactory<AuthBloc>(
      () => AuthBloc(
        loginUseCase: _getIt<LoginUseCase>(),
        registerUseCase: _getIt<RegisterUseCase>(),
        logoutUseCase: _getIt<LogoutUseCase>(),
        getCurrentUserUseCase: _getIt<GetCurrentUserUseCase>(),
      ),
    );
  }

  /// Obtient une instance du BLoC d'authentification
  static AuthBloc getAuthBloc() {
    return _getIt<AuthBloc>();
  }

  /// Obtient une instance du repository d'authentification
  static AuthRepository getAuthRepository() {
    return _getIt<AuthRepository>();
  }

  /// Obtient une instance de la source de données d'authentification
  static AuthRemoteDataSource getAuthRemoteDataSource() {
    return _getIt<AuthRemoteDataSource>();
  }
}
