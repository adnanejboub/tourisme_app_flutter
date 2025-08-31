import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../auth/domain/entities/auth_entities.dart';
import '../../../auth/domain/usecases/auth_usecases.dart';

// Events
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadCompleteProfile extends ProfileEvent {}

class UpdateProfile extends ProfileEvent {
  final ProfileUpdateParams params;

  const UpdateProfile(this.params);

  @override
  List<Object?> get props => [params];
}

class RefreshProfile extends ProfileEvent {}

// States
abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserProfileEntity profile;

  const ProfileLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

class ProfileUpdating extends ProfileState {
  final UserProfileEntity currentProfile;

  const ProfileUpdating(this.currentProfile);

  @override
  List<Object?> get props => [currentProfile];
}

class ProfileUpdated extends ProfileState {
  final UserProfileEntity profile;
  final String message;

  const ProfileUpdated(this.profile, this.message);

  @override
  List<Object?> get props => [profile, message];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetCompleteProfileUseCase _getCompleteProfileUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;

  ProfileBloc({
    required GetCompleteProfileUseCase getCompleteProfileUseCase,
    required UpdateProfileUseCase updateProfileUseCase,
  })  : _getCompleteProfileUseCase = getCompleteProfileUseCase,
        _updateProfileUseCase = updateProfileUseCase,
        super(ProfileInitial()) {
    
    on<LoadCompleteProfile>(_onLoadCompleteProfile);
    on<UpdateProfile>(_onUpdateProfile);
    on<RefreshProfile>(_onRefreshProfile);
  }

  Future<void> _onLoadCompleteProfile(
    LoadCompleteProfile event,
    Emitter<ProfileState> emit,
  ) async {
    print('ProfileBloc: Loading complete profile...');
    emit(ProfileLoading());

    try {
      print('ProfileBloc: Calling getCompleteProfileUseCase...');
      final profile = await _getCompleteProfileUseCase(null);
      print('ProfileBloc: Profile loaded successfully: ${profile.toString()}');
      emit(ProfileLoaded(profile));
    } catch (e) {
      print('ProfileBloc: Error loading profile: $e');
      String errorMessage = e.toString();
      if (e is AuthException) {
        errorMessage = e.message;
      }
      print('ProfileBloc: Emitting ProfileError: $errorMessage');
      emit(ProfileError(errorMessage));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is ProfileLoaded) {
      emit(ProfileUpdating(currentState.profile));
    }

    try {
      final updatedProfile = await _updateProfileUseCase(event.params);
      emit(ProfileUpdated(updatedProfile, 'Profil mis à jour avec succès'));
      
      // Automatically refresh the profile to ensure we have the latest data
      print('ProfileBloc: Automatically refreshing profile after update...');
      final refreshedProfile = await _getCompleteProfileUseCase(null);
      emit(ProfileLoaded(refreshedProfile));
    } catch (e) {
      String errorMessage = e.toString();
      if (e is AuthException) {
        errorMessage = e.message;
      }
      emit(ProfileError(errorMessage));
    }
  }

  Future<void> _onRefreshProfile(
    RefreshProfile event,
    Emitter<ProfileState> emit,
  ) async {
    add(LoadCompleteProfile());
  }
}
