// lib/features/auth/presentation/pages/logout_page.dart
import 'package:flutter/material.dart';
import 'package:tourisme_app_flutter/config/routes/app_routes.dart';

class LogoutPage extends StatelessWidget {
  const LogoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Déconnexion'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Êtes-vous sûr de vouloir vous déconnecter ?',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // Logout logic here
                print('Déconnexion de l\'utilisateur');
                // Navigate to the login page after logout
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.login,
                      (Route<dynamic> route) => false, // Remove all previous routes
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent, // Red button for logout
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
              ),
              child: const Text(
                'Se déconnecter',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Go back to the previous page
              },
              child: const Text(
                'Annuler',
                style: TextStyle(color: Colors.blueAccent, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
