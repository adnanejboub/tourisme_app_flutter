import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../../../core/constants/constants.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../shared/widgets/guest_mode_mixin.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/domain/entities/auth_entities.dart';
import '../bloc/profile_bloc.dart';
import '../widgets/profile_avatar.dart';
import '../../../../core/services/profile_image_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with GuestModeMixin {
  bool _isRefreshing = false;
  File? _selectedProfileImage;
  final ProfileImageService _profileImageService = ProfileImageService();

  @override
  void initState() {
    super.initState();
    // Charger l'image de profil existante
    _profileImageService.loadProfileImage();
    // Écouter les changements
    _profileImageService.addListener(_onProfileImageChanged);
    
    // Charger le profil utilisateur au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserProfile();
    });
  }

  @override
  void dispose() {
    _profileImageService.removeListener(_onProfileImageChanged);
    super.dispose();
  }

  void _onProfileImageChanged() {
    if (mounted) {
      setState(() {
        _selectedProfileImage = _profileImageService.currentProfileImage;
      });
    }
  }

  void _loadUserProfile() {
    context.read<AuthBloc>().add(GetCurrentUserRequested());
    // Profile will be loaded automatically when user becomes authenticated
    // via the AuthBloc listener
  }

  void _refreshProfile() {
    setState(() => _isRefreshing = true);
    context.read<AuthBloc>().add(GetCurrentUserRequested());
    // Only refresh profile for authenticated users
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<ProfileBloc>().add(RefreshProfile());
    }
  }

  void _onImageSelected(File? image) {
    setState(() {
      _selectedProfileImage = image;
    });
    
    // Sauvegarder dans le service partagé pour synchronisation
    if (image != null) {
      _profileImageService.saveProfileImage(image);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile image updated successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _saveProfileImage(File image) {
    // TODO: Implémenter la sauvegarde de l'image
    // Vous pouvez utiliser SharedPreferences pour sauvegarder le chemin
    // ou uploader l'image vers un serveur
    print('Saving profile image: ${image.path}');
  }

  void _showLogoutDialog(BuildContext context, LocalizationService localizationService) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: colorScheme.surface,
          title: Text(
            localizationService.translate('logout'),
            style: TextStyle(color: colorScheme.onSurface),
          ),
          content: Text(
            'Are you sure you want to logout?', // Add translation if needed
            style: TextStyle(color: colorScheme.onSurface),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel', // Add translation if needed
                style: TextStyle(color: colorScheme.onSurface),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Déclencher la déconnexion via le BLoC
                context.read<AuthBloc>().add(LogoutRequested());
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, AppRoutes.welcome);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(localizationService.translate('logout')),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              setState(() => _isRefreshing = false);
              // Load profile when user becomes authenticated
              context.read<ProfileBloc>().add(LoadCompleteProfile());
            } else if (state is AuthFailure) {
              setState(() => _isRefreshing = false);
              
              // Only show authentication errors for authenticated users
              // For unauthenticated users, don't show token expired messages
              if (state.message.contains('401') ||
                  state.message.contains('Token') ||
                  state.message.contains('Unauthorized')) {
                // Don't show token expired message for unauthenticated users
                return;
              } else {
                // Show other errors
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 4),
                    action: SnackBarAction(
                      label: 'Réessayer',
                      textColor: Colors.white,
                      onPressed: () {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        _refreshProfile();
                      },
                    ),
                  ),
                );
              }
            }
          },
        ),
        BlocListener<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state is ProfileUpdated) {
              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 3),
                ),
              );
            } else if (state is ProfileError) {
              // Show error message only for authenticated users
              final authState = context.read<AuthBloc>().state;
              if (authState is AuthAuthenticated) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 4),
                  ),
                );
              }
            }
          },
        ),
      ],
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          return BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, profileState) {
              return Consumer<LocalizationService>(
                builder: (context, localizationService, child) {
                  return Scaffold(
                    backgroundColor: colorScheme.background,
                    body: RefreshIndicator(
                      onRefresh: () async {
                        _refreshProfile();
                      },
                      child: SafeArea(
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 24),
                                // Header
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      localizationService.translate('profile'),
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.onBackground,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        // Bouton de rafraîchissement
                                        if (authState is AuthAuthenticated || authState is AuthLoading)
                                          IconButton(
                                            icon: _isRefreshing 
                                              ? SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    color: colorScheme.primary,
                                                  ),
                                                )
                                              : Icon(Icons.refresh, color: colorScheme.primary, size: 26),
                                            onPressed: _isRefreshing ? null : _refreshProfile,
                                          ),
                                        // Bouton d'édition (seulement pour les utilisateurs authentifiés)
                                        if (authState is AuthAuthenticated)
                                          IconButton(
                                            icon: Icon(Icons.edit, color: colorScheme.primary, size: 26),
                                            onPressed: () => executeWithGuestCheck('edit_profile', () {
                                              Navigator.pushNamed(context, '/edit_profile');
                                            }),
                                          ),
                                        // Boutons d'authentification pour les utilisateurs invités
                                        if (authState is! AuthAuthenticated) ...[
                                          IconButton(
                                            icon: Icon(Icons.login, color: colorScheme.primary, size: 26),
                                            onPressed: () {
                                              Navigator.pushNamed(context, AppRoutes.login);
                                            },
                                            tooltip: localizationService.translate('guest_login'),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.person_add, color: colorScheme.secondary, size: 26),
                                            onPressed: () {
                                              Navigator.pushNamed(context, AppRoutes.signup);
                                            },
                                            tooltip: localizationService.translate('guest_signup'),
                                          ),
                                        ],
                                        // Bouton de déconnexion (seulement pour les utilisateurs authentifiés)
                                        if (authState is AuthAuthenticated)
                                          IconButton(
                                            icon: Icon(Icons.logout, color: Colors.red, size: 26),
                                            onPressed: () => _showLogoutDialog(context, localizationService),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                // Avatar
                                Center(
                                  child: ProfileAvatar(
                                    imageUrl: null,
                                    onImageSelected: _onImageSelected,
                                    isGuest: authState is! AuthAuthenticated, // Passer true si c'est un Guest
                                  ),
                                ),
                                const SizedBox(height: 18),
                                // Name & info
                                Center(
                                  child: Column(
                                    children: [
                                      if (profileState is ProfileLoaded || profileState is ProfileUpdated) ...[
                                        Builder(
                                          builder: (context) {
                                            final profile = profileState is ProfileLoaded 
                                                ? profileState.profile 
                                                : (profileState as ProfileUpdated).profile;
                                            
                                            return Column(
                                              children: [
                                                Text(
                                                  '${profile.firstName} ${profile.lastName}',
                                                  style: TextStyle(
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.bold,
                                                    color: colorScheme.onBackground,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  profile.email,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: colorScheme.onSurface,
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      ] else if (authState is AuthAuthenticated && authState.user != null) ...[
                                        Text(
                                          '${authState.user.firstName} ${authState.user.lastName}',
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: colorScheme.onBackground,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          authState.user.email,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: colorScheme.onSurface,
                                          ),
                                        ),
                                      ] else ...[
                                        // Guest user display
                                        Text(
                                          'Guest',
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: colorScheme.onBackground,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Not signed in',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: colorScheme.onSurface.withOpacity(0.6),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        // Authentication buttons for guest users
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: ElevatedButton.icon(
                                                onPressed: () {
                                                  Navigator.pushNamed(context, AppRoutes.login);
                                                },
                                                icon: Icon(Icons.login, size: 20),
                                                label: Text(
                                                  localizationService.translate('guest_login'),
                                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: colorScheme.primary,
                                                  foregroundColor: Colors.white,
                                                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 12),
                                            Expanded(
                                              child: OutlinedButton.icon(
                                                onPressed: () {
                                                  Navigator.pushNamed(context, AppRoutes.signup);
                                                },
                                                icon: Icon(Icons.person_add, size: 20),
                                                label: Text(
                                                  localizationService.translate('guest_signup'),
                                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                                ),
                                                style: OutlinedButton.styleFrom(
                                                  foregroundColor: colorScheme.primary,
                                                  side: BorderSide(color: colorScheme.primary, width: 2),
                                                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                      const SizedBox(height: 8),
                                      if (authState is AuthAuthenticated && (profileState is ProfileLoaded || profileState is ProfileUpdated))
                                        Builder(
                                          builder: (context) {
                                            final profile = profileState is ProfileLoaded 
                                                ? profileState.profile 
                                                : (profileState as ProfileUpdated).profile;
                                            
                                            if (profile.role != null) {
                                              return Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: colorScheme.primary.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                                child: Text(
                                                  profile.role!,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: colorScheme.primary,
                                                  ),
                                                ),
                                              );
                                            }
                                            return const SizedBox.shrink();
                                          },
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                                // Description
                                Text(
                                  localizationService.translate('tell_about_yourself'),
                                  style: TextStyle(color: colorScheme.onBackground, fontSize: 15),
                                ),
                                const SizedBox(height: 16),
                                // City
                                Row(
                                  children: [
                                    Icon(Icons.location_on, color: colorScheme.onBackground.withOpacity(0.6), size: 20),
                                    const SizedBox(width: 8),
                                    Text(localizationService.translate('no_city_selected'), style: TextStyle(color: colorScheme.onBackground.withOpacity(0.6))),
                                  ],
                                ),
                                const SizedBox(height: 28),
                                // Guest benefits section (only for unauthenticated users)
                                if (authState is! AuthAuthenticated) ...[
                                  Container(
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: colorScheme.primary.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.star,
                                              color: colorScheme.primary,
                                              size: 24,
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              localizationService.translate('guest_unlock_features'),
                                              style: TextStyle(
                                                color: colorScheme.primary,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        _GuestBenefitRow(
                                          icon: Icons.edit,
                                          text: localizationService.translate('guest_edit_profile'),
                                          colorScheme: colorScheme,
                                        ),
                                        _GuestBenefitRow(
                                          icon: Icons.calendar_today,
                                          text: localizationService.translate('guest_manage_reservations'),
                                          colorScheme: colorScheme,
                                        ),
                                        _GuestBenefitRow(
                                          icon: Icons.favorite,
                                          text: localizationService.translate('guest_save_destinations'),
                                          colorScheme: colorScheme,
                                        ),
                                        _GuestBenefitRow(
                                          icon: Icons.rate_review,
                                          text: localizationService.translate('guest_write_reviews'),
                                          colorScheme: colorScheme,
                                        ),
                                        _GuestBenefitRow(
                                          icon: Icons.photo_camera,
                                          text: localizationService.translate('guest_share_photos'),
                                          colorScheme: colorScheme,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  // Call to action for guest users
                                  Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          colorScheme.primary,
                                          colorScheme.primary.withOpacity(0.8),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          localizationService.translate('guest_ready_to_travel'),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          localizationService.translate('guest_create_account_description'),
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.9),
                                            fontSize: 14,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(height: 16),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: OutlinedButton(
                                                onPressed: () {
                                                  Navigator.pushNamed(context, AppRoutes.login);
                                                },
                                                style: OutlinedButton.styleFrom(
                                                  backgroundColor: Colors.white,
                                                  foregroundColor: colorScheme.primary,
                                                  side: BorderSide(color: Colors.white, width: 2),
                                                  padding: EdgeInsets.symmetric(vertical: 12),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                ),
                                                child: Text(
                                                  localizationService.translate('guest_login'),
                                                  style: TextStyle(fontWeight: FontWeight.w600),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 12),
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  Navigator.pushNamed(context, AppRoutes.signup);
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.white,
                                                  foregroundColor: colorScheme.primary,
                                                  padding: EdgeInsets.symmetric(vertical: 12),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                ),
                                                child: Text(
                                                  localizationService.translate('guest_signup'),
                                                  style: TextStyle(fontWeight: FontWeight.w600),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 28),
                                ],
                                // Profile Information Section (only for authenticated users)
                                if (authState is AuthAuthenticated && (profileState is ProfileLoaded || profileState is ProfileUpdated)) ...[
                                  Container(
                                    decoration: BoxDecoration(
                                      color: colorScheme.surface,
                                      borderRadius: BorderRadius.circular(18),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 10,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    padding: const EdgeInsets.all(18),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Informations du profil',
                                          style: TextStyle(
                                            color: colorScheme.onSurface,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 17,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Builder(
                                          builder: (context) {
                                            final profile = profileState is ProfileLoaded 
                                                ? profileState.profile 
                                                : (profileState as ProfileUpdated).profile;
                                            
                                            return Column(
                                              children: [
                                                if (profile.telephone != null && profile.telephone!.isNotEmpty)
                                                  _ProfileInfoRow(
                                                    icon: Icons.phone,
                                                    label: 'Téléphone',
                                                    value: profile.telephone!,
                                                    colorScheme: colorScheme,
                                                  ),
                                                if (profile.adresse != null && profile.adresse!.isNotEmpty)
                                                  _ProfileInfoRow(
                                                    icon: Icons.location_on,
                                                    label: 'Adresse',
                                                    value: profile.adresse!,
                                                    colorScheme: colorScheme,
                                                  ),
                                                if (profile.dateNaissance != null)
                                                  _ProfileInfoRow(
                                                    icon: Icons.calendar_today,
                                                    label: 'Date de naissance',
                                                    value: profile.dateNaissance!.toString().split(' ')[0],
                                                    colorScheme: colorScheme,
                                                  ),
                                                if (profile.nationalite != null && profile.nationalite!.isNotEmpty)
                                                  _ProfileInfoRow(
                                                    icon: Icons.flag,
                                                    label: 'Nationalité',
                                                    value: profile.nationalite!,
                                                    colorScheme: colorScheme,
                                                  ),
                                                if (profile.passeport != null && profile.passeport!.isNotEmpty)
                                                  _ProfileInfoRow(
                                                    icon: Icons.credit_card,
                                                    label: 'Passeport',
                                                    value: profile.passeport!,
                                                    colorScheme: colorScheme,
                                                  ),
                                                if (profile.budgetMax != null)
                                                  _ProfileInfoRow(
                                                    icon: Icons.euro,
                                                    label: 'Budget maximum',
                                                    value: '${profile.budgetMax!.toStringAsFixed(2)} €',
                                                    colorScheme: colorScheme,
                                                  ),
                                              ],
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 28),
                                ],
                                // Accomplishments
                                Container(
                                  decoration: BoxDecoration(
                                    color: colorScheme.surface,
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(18),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(localizationService.translate('your_achievements'), style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 17)),
                                          Text(localizationService.translate('show_all'), style: TextStyle(color: colorScheme.primary, decoration: TextDecoration.underline)),
                                        ],
                                      ),
                                      Divider(color: colorScheme.onSurface.withOpacity(0.2), height: 24),
                                      Row(
                                        children: [
                                          Icon(Icons.lock, color: colorScheme.onSurface.withOpacity(0.6), size: 36),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(localizationService.translate('write_first_review'), style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w600)),
                                                Text(localizationService.translate('unlock_levels_reviews'), style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6), fontSize: 13)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 18),
                                      Row(
                                        children: [
                                          Icon(Icons.lock, color: colorScheme.onSurface.withOpacity(0.6), size: 36),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(localizationService.translate('upload_first_photo'), style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w600)),
                                                Text(localizationService.translate('unlock_levels_photos'), style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6), fontSize: 13)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 32),
                                // ListTiles
                                _ProfileTile(
                                  icon: Icons.calendar_today,
                                  title: localizationService.translate('reservations'),
                                  onTap: () => executeWithGuestCheck('view_reservations', () {
                                    Navigator.pushNamed(context, '/reservations');
                                  }),
                                  isRestricted: isFeatureRestricted('view_reservations'),
                                ),
                                const SizedBox(height: 12),
                                _ProfileTile(
                                  icon: Icons.settings,
                                  title: localizationService.translate('preferences'),
                                  onTap: () => executeWithGuestCheck('modify_preferences', () {
                                    Navigator.pushNamed(context, '/preferences');
                                  }),
                                  isRestricted: isFeatureRestricted('modify_preferences'),
                                ),
                                const SizedBox(height: 12),
                                const _ThemeSelectorTile(),
                                const SizedBox(height: 12),
                                // Only show logout button for authenticated users
                                if (authState is AuthAuthenticated) ...[
                                  const SizedBox(height: 32),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ColorScheme colorScheme;

  const _ProfileInfoRow({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
    required this.colorScheme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            color: colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurface.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isRestricted;

  const _ProfileTile({
    Key? key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.isRestricted = false,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(14),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(
                icon, 
                color: isRestricted ? colorScheme.onSurface.withOpacity(0.6) : colorScheme.primary, 
                size: 24
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Text(
                  title, 
                  style: TextStyle(
                    color: isRestricted ? colorScheme.onSurface.withOpacity(0.6) : colorScheme.onSurface, 
                    fontWeight: FontWeight.w500, 
                    fontSize: 16
                  )
                ),
              ),
              Icon(
                isRestricted ? Icons.lock : Icons.chevron_right, 
                color: isRestricted ? colorScheme.onSurface.withOpacity(0.6) : colorScheme.onSurface.withOpacity(0.6), 
                size: 24
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeSelectorTile extends StatelessWidget {
  const _ThemeSelectorTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Consumer<LocalizationService>(
          builder: (context, localizationService, child) {
            return Material(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              elevation: 2,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  _showThemeDialog(context, themeProvider, localizationService);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Icon(
                        Icons.palette, 
                        color: colorScheme.primary, 
                        size: 24
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Text(
                          localizationService.translate('theme'), 
                          style: TextStyle(
                            color: colorScheme.onSurface, 
                            fontWeight: FontWeight.w500, 
                            fontSize: 16
                          )
                        ),
                      ),
                      Text(
                        _getThemeModeText(themeProvider.themeMode, localizationService),
                        style: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.6),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.chevron_right, 
                        color: colorScheme.onSurface.withOpacity(0.6), 
                        size: 24
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _getThemeModeText(ThemeMode mode, LocalizationService localizationService) {
    switch (mode) {
      case ThemeMode.light:
        return localizationService.translate('light');
      case ThemeMode.dark:
        return localizationService.translate('dark');
      case ThemeMode.system:
        return localizationService.translate('system');
    }
  }

  void _showThemeDialog(BuildContext context, ThemeProvider themeProvider, LocalizationService localizationService) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: colorScheme.surface,
          title: Text(
            localizationService.translate('choose_theme'),
            style: TextStyle(color: colorScheme.onSurface),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ThemeOptionTile(
                title: localizationService.translate('light'),
                subtitle: localizationService.translate('always_use_light'),
                icon: Icons.wb_sunny,
                isSelected: themeProvider.themeMode == ThemeMode.light,
                onTap: () {
                  themeProvider.setThemeMode(ThemeMode.light);
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: 8),
              _ThemeOptionTile(
                title: localizationService.translate('dark'),
                subtitle: localizationService.translate('always_use_dark'),
                icon: Icons.nightlight_round,
                isSelected: themeProvider.themeMode == ThemeMode.dark,
                onTap: () {
                  themeProvider.setThemeMode(ThemeMode.dark);
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: 8),
              _ThemeOptionTile(
                title: localizationService.translate('system'),
                subtitle: localizationService.translate('follow_system_theme'),
                icon: Icons.settings_system_daydream,
                isSelected: themeProvider.themeMode == ThemeMode.system,
                onTap: () {
                  themeProvider.setThemeMode(ThemeMode.system);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ThemeOptionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOptionTile({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.2),
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.6),
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: colorScheme.primary,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuestBenefitRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final ColorScheme colorScheme;

  const _GuestBenefitRow({
    Key? key,
    required this.icon,
    required this.text,
    required this.colorScheme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            color: colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.primary.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

