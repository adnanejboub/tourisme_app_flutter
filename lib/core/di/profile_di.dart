import 'package:get_it/get_it.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/auth_usecases.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';

/// Dependency injection setup for profile functionality
class ProfileDI {
  static final GetIt _getIt = GetIt.instance;

  static void setup() {
    print('Setting up ProfileDI...');
    
    // Register use cases
    _getIt.registerLazySingleton<GetCompleteProfileUseCase>(
      () => GetCompleteProfileUseCase(_getIt<AuthRepository>()),
    );
    print('Registered GetCompleteProfileUseCase');
    
    _getIt.registerLazySingleton<UpdateProfileUseCase>(
      () => UpdateProfileUseCase(_getIt<AuthRepository>()),
    );
    print('Registered UpdateProfileUseCase');

    // Register ProfileBloc
    _getIt.registerFactory<ProfileBloc>(
      () => ProfileBloc(
        getCompleteProfileUseCase: _getIt<GetCompleteProfileUseCase>(),
        updateProfileUseCase: _getIt<UpdateProfileUseCase>(),
      ),
    );
    print('Registered ProfileBloc');
    
    print('ProfileDI setup complete');
  }

  static void reset() {
    _getIt.reset();
  }

  /// Get ProfileBloc instance
  static ProfileBloc getProfileBloc() {
    try {
      return _getIt<ProfileBloc>();
    } catch (e) {
      print('Error getting ProfileBloc: $e');
      rethrow;
    }
  }
}
