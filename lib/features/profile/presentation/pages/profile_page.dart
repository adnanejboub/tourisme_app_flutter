import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../shared/widgets/guest_mode_mixin.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/domain/entities/auth_entities.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with GuestModeMixin {
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    // Charger le profil utilisateur au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserProfile();
    });
  }

  void _loadUserProfile() {
    context.read<AuthBloc>().add(GetCurrentUserRequested());
  }

  void _refreshProfile() {
    setState(() => _isRefreshing = true);
    context.read<AuthBloc>().add(GetCurrentUserRequested());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure) {
          setState(() => _isRefreshing = false);
          
          // Gérer les erreurs d'authentification
          if (state.message.contains('401') ||
              state.message.contains('Token') ||
              state.message.contains('Unauthorized')) {
            // Token expiré ou invalide, rediriger vers la page de connexion
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Session expirée. Veuillez vous reconnecter.'),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 3),
                action: SnackBarAction(
                  label: 'OK',
                  textColor: Colors.white,
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    Navigator.of(context).pushReplacementNamed('/login');
                  },
                ),
              ),
            );
            // Rediriger vers la page de connexion après un délai
            Future.delayed(const Duration(seconds: 3), () {
              Navigator.of(context).pushReplacementNamed('/login');
            });
          } else {
            // Autres erreurs
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
        } else if (state is AuthAuthenticated) {
          setState(() => _isRefreshing = false);
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
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
                                    // Bouton d'édition
                                    IconButton(
                                      icon: Icon(Icons.edit, color: colorScheme.primary, size: 26),
                                      onPressed: () => executeWithGuestCheck('edit_profile', () {
                                        Navigator.pushNamed(context, '/edit_profile');
                                      }),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            // Avatar
                            Center(
                              child: Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  CircleAvatar(
                                    radius: 48,
                                    backgroundColor: colorScheme.surface,
                                    child: Icon(Icons.person, size: 60, color: colorScheme.onSurface.withOpacity(0.6)),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () {},
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: colorScheme.surface,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.1),
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                        padding: const EdgeInsets.all(6),
                                        child: Icon(Icons.camera_alt, size: 20, color: colorScheme.primary),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),
                            // Name & info
                            Center(
                              child: Column(
                                children: [
                                  if (authState is AuthAuthenticated && authState.user != null) ...[
                                    Text(
                                      '${authState.user.firstName} ${authState.user.lastName}',
                                      style: TextStyle(
                                        fontSize: 22, 
                                        fontWeight: FontWeight.bold, 
                                        color: colorScheme.onBackground
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      authState.user.email,
                                      style: TextStyle(
                                        fontSize: 14, 
                                        color: colorScheme.onBackground.withOpacity(0.6)
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${localizationService.translate('member_since')} 2025', 
                                      style: TextStyle(
                                        fontSize: 16, 
                                        color: colorScheme.onBackground.withOpacity(0.6)
                                      )
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '0 ${localizationService.translate('contribution')}', 
                                      style: TextStyle(
                                        fontSize: 14, 
                                        color: colorScheme.onBackground.withOpacity(0.6)
                                      )
                                    ),
                                  ] else if (authState is AuthLoading) ...[
                                    CircularProgressIndicator(
                                      color: colorScheme.primary,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      localizationService.translate('loading_profile'), 
                                      style: TextStyle(
                                        fontSize: 14, 
                                        color: colorScheme.onBackground.withOpacity(0.6)
                                      )
                                    ),
                                  ] else if (authState is AuthFailure) ...[
                                    Icon(
                                      Icons.error_outline,
                                      color: Colors.red,
                                      size: 48,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Erreur de chargement',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.red,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Impossible de charger le profil',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: colorScheme.onBackground.withOpacity(0.6),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    ElevatedButton.icon(
                                      onPressed: _refreshProfile,
                                      icon: Icon(Icons.refresh, size: 18),
                                      label: Text('Réessayer'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: colorScheme.primary,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ] else ...[
                                    Text(
                                      'Invité', 
                                      style: TextStyle(
                                        fontSize: 22, 
                                        fontWeight: FontWeight.bold, 
                                        color: colorScheme.onBackground
                                      )
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      localizationService.translate('guest_mode'), 
                                      style: TextStyle(
                                        fontSize: 14, 
                                        color: colorScheme.onBackground.withOpacity(0.6)
                                      )
                                    ),
                                  ],
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
                              const _LogoutTile(),
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

class _LogoutTile extends StatelessWidget {
  const _LogoutTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Consumer<LocalizationService>(
      builder: (context, localizationService, child) {
        return Material(
          color: Colors.red,
          borderRadius: BorderRadius.circular(14),
          elevation: 2,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => _showLogoutDialog(context, localizationService),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  const Icon(
                    Icons.logout, 
                    color: Colors.white, 
                    size: 24
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Text(
                      localizationService.translate('logout'), 
                      style: const TextStyle(
                        color: Colors.white, 
                        fontWeight: FontWeight.w500, 
                        fontSize: 16
                      )
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right, 
                    color: Colors.white, 
                    size: 24
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
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
}