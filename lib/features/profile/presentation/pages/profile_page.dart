import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../shared/widgets/guest_mode_mixin.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with GuestModeMixin {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
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
                      'Profile',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onBackground,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit, color: colorScheme.primary, size: 26),
                      onPressed: () => executeWithGuestCheck('edit_profile', () {
                        Navigator.pushNamed(context, '/edit_profile');
                      }),
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
                      Text('adnane', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colorScheme.onBackground)),
                      const SizedBox(height: 4),
                      Text('Member since 2025', style: TextStyle(fontSize: 16, color: colorScheme.onBackground.withOpacity(0.6))),
                      const SizedBox(height: 2),
                      Text('0 contribution', style: TextStyle(fontSize: 14, color: colorScheme.onBackground.withOpacity(0.6))),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Description
                Text(
                  'Tell other travelers a bit about yourself.',
                  style: TextStyle(color: colorScheme.onBackground, fontSize: 15),
                ),
                const SizedBox(height: 16),
                // City
                Row(
                  children: [
                    Icon(Icons.location_on, color: colorScheme.onBackground.withOpacity(0.6), size: 20),
                    const SizedBox(width: 8),
                    Text('No city selected.', style: TextStyle(color: colorScheme.onBackground.withOpacity(0.6))),
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
                          Text('Your Achievements', style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 17)),
                          Text('Show all', style: TextStyle(color: colorScheme.primary, decoration: TextDecoration.underline)),
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
                                Text('Write your first review', style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w600)),
                                Text('Unlock levels with reviews', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6), fontSize: 13)),
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
                                Text('Upload your first photo', style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w600)),
                                Text('Unlock levels with photos', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6), fontSize: 13)),
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
                  title: 'Reservations',
                  onTap: () => executeWithGuestCheck('view_reservations', () {
                    Navigator.pushNamed(context, '/reservations');
                  }),
                  isRestricted: isFeatureRestricted('view_reservations'),
                ),
                const SizedBox(height: 12),
                _ProfileTile(
                  icon: Icons.settings,
                  title: 'Preferences',
                  onTap: () => executeWithGuestCheck('modify_preferences', () {
                    Navigator.pushNamed(context, '/preferences');
                  }),
                  isRestricted: isFeatureRestricted('modify_preferences'),
                ),
                const SizedBox(height: 12),
                _ThemeSelectorTile(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
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
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Material(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          elevation: 2,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              _showThemeDialog(context, themeProvider);
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
                      'Theme', 
                      style: TextStyle(
                        color: colorScheme.onSurface, 
                        fontWeight: FontWeight.w500, 
                        fontSize: 16
                      )
                    ),
                  ),
                  Text(
                    _getThemeModeText(themeProvider.themeMode),
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
  }

  String _getThemeModeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  void _showThemeDialog(BuildContext context, ThemeProvider themeProvider) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: colorScheme.surface,
          title: Text(
            'Choose Theme',
            style: TextStyle(color: colorScheme.onSurface),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ThemeOptionTile(
                title: 'Light',
                subtitle: 'Always use light theme',
                icon: Icons.wb_sunny,
                isSelected: themeProvider.themeMode == ThemeMode.light,
                onTap: () {
                  themeProvider.setThemeMode(ThemeMode.light);
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: 8),
              _ThemeOptionTile(
                title: 'Dark',
                subtitle: 'Always use dark theme',
                icon: Icons.nightlight_round,
                isSelected: themeProvider.themeMode == ThemeMode.dark,
                onTap: () {
                  themeProvider.setThemeMode(ThemeMode.dark);
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: 8),
              _ThemeOptionTile(
                title: 'System',
                subtitle: 'Follow system theme',
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