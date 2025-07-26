// lib/features/auth/presentation/pages/two_factor_auth_page.dart
import 'package:flutter/material.dart';
import 'package:tourisme_app_flutter/config/routes/app_routes.dart';

class TwoFactorAuthPage extends StatefulWidget {
  const TwoFactorAuthPage({super.key});

  @override
  State<TwoFactorAuthPage> createState() => _TwoFactorAuthPageState();
}

class _TwoFactorAuthPageState extends State<TwoFactorAuthPage> {
  final TextEditingController _codeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Authentification à deux facteurs',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey[800],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Veuillez entrer le code de vérification généré par votre application d\'authentification.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 40),
              // 2FA code input field
              TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 6, // Typically 6 digits for 2FA
                decoration: InputDecoration(
                  hintText: '------',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  counterText: "",
                ),
                style: const TextStyle(fontSize: 24, letterSpacing: 10),
              ),
              const SizedBox(height: 30),
              // "Verify" button
              ElevatedButton(
                onPressed: () {
                  // 2FA verification logic
                  print('Code 2FA: ${_codeController.text}');
                  // If 2FA verified, navigate to the main application page
                  Navigator.pushReplacementNamed(context, AppRoutes.home); // Main page
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
                child: const Text(
                  'Vérifier',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              // "Problem with 2FA?" link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text("Problème avec 2FA ? "),
                  GestureDetector(
                    onTap: () {
                      // 2FA help logic (e.g., recovery options)
                      print('Problème 2FA');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Veuillez contacter le support pour l\'aide 2FA.')),
                      );
                    },
                    child: const Text(
                      'Aide',
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
