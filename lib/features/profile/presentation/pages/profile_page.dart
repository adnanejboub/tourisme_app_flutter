import 'package:flutter/material.dart';
import '../../../../core/constants/constants.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
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
                    const Text(
                      'Profile',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit, color: Color(AppConstants.primaryColor), size: 26),
                      onPressed: () => Navigator.pushNamed(context, '/edit_profile'),
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
                        backgroundImage: AssetImage('assets/images/profile_default.jpg'), // Replace with user image if available
                        backgroundColor: Colors.grey[200],
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {},
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(6),
                            child: Icon(Icons.camera_alt, size: 20, color: Color(AppConstants.primaryColor)),
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
                    children: const [
                      Text('adnane', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
                      SizedBox(height: 4),
                      Text('Member since 2025', style: TextStyle(fontSize: 16, color: Colors.grey)),
                      SizedBox(height: 2),
                      Text('0 contribution', style: TextStyle(fontSize: 14, color: Colors.grey)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Description
                const Text(
                  'Tell other travelers a bit about yourself.',
                  style: TextStyle(color: Colors.black87, fontSize: 15),
                ),
                const SizedBox(height: 16),
                // City & website
                Row(
                  children: const [
                    Icon(Icons.location_on, color: Colors.grey, size: 20),
                    SizedBox(width: 8),
                    Text('No city selected.', style: TextStyle(color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 8),
                // (Website removed)
                const SizedBox(height: 28),
                // Accomplishments
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
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
                          const Text('Your Achievements', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 17)),
                          Text('Show all', style: TextStyle(color: Color(AppConstants.primaryColor), decoration: TextDecoration.underline)),
                        ],
                      ),
                      const Divider(color: Colors.grey, height: 24),
                      Row(
                        children: const [
                          Icon(Icons.lock, color: Colors.grey, size: 36),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Write your first review', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
                                Text('Unlock levels with reviews', style: TextStyle(color: Colors.grey, fontSize: 13)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: const [
                          Icon(Icons.lock, color: Colors.grey, size: 36),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Upload your first photo', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
                                Text('Unlock levels with photos', style: TextStyle(color: Colors.grey, fontSize: 13)),
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
                  onTap: () => Navigator.pushNamed(context, '/reservations'),
                ),
                const SizedBox(height: 12),
                _ProfileTile(
                  icon: Icons.settings,
                  title: 'Preferences',
                  onTap: () => Navigator.pushNamed(context, '/preferences'),
                ),
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
  const _ProfileTile({Key? key, required this.icon, required this.title, required this.onTap}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: Color(AppConstants.primaryColor), size: 24),
              const SizedBox(width: 18),
              Expanded(
                child: Text(title, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500, fontSize: 16)),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}