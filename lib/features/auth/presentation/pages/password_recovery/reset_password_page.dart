// lib/features/auth/presentation/pages/reset_password_page.dart
import 'package:flutter/material.dart';
import 'package:tourisme_app_flutter/config/routes/app_routes.dart';

class ResetPasswordPage extends StatefulWidget {
  final String? email; // Déclarer le paramètre email

  const ResetPasswordPage({super.key, this.email}); // Accepter email dans le constructeur

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Vous pouvez utiliser widget.email ici pour pré-remplir un champ si nécessaire
    if (widget.email != null) {
      // Par exemple, si vous avez un champ pour afficher l'email
      // _emailDisplayController.text = widget.email!;
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... votre code existant ...
    return Scaffold(
      // ...
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            // ...
            children: <Widget>[
              Text(
                'Réinitialiser le mot de passe',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey[800],
                ),
              ),
              const SizedBox(height: 20),
              // Vous pouvez afficher l'email ici si vous le souhaitez
              if (widget.email != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Text(
                    'Pour l\'adresse : ${widget.email}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              Text(
                'Entrez votre nouveau mot de passe ci-dessous.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 40),
              // ... le reste de vos champs et boutons ...
            ],
          ),
        ),
      ),
    );
  }
}