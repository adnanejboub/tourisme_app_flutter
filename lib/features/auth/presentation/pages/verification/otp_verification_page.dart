import 'package:flutter/material.dart';
import '../../../../../core/services/localization_service.dart';
import 'package:tourisme_app_flutter/config/routes/app_routes.dart';

class OtpVerificationPage extends StatefulWidget {
  final String email;
  final String type;

  const OtpVerificationPage({super.key, required this.email, required this.type});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final TextEditingController _otpController = TextEditingController();

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
                'Vérification OTP',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey[800],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Veuillez entrer le code à 6 chiffres envoyé à votre adresse e-mail: ${widget.email}.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 40),

              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 6,
                decoration: InputDecoration(
                  hintText: LocalizationService().translate('otp_hint'),
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

              ElevatedButton(
                onPressed: () {
                  print('Code OTP: ${_otpController.text}');
                  print('Type de vérification: ${widget.type}');
                  Navigator.pushReplacementNamed(context, AppRoutes.travelPreferences);
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
                  'Vérifier le compte',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text("Vous n'avez pas reçu le code ? "),
                  GestureDetector(
                    onTap: () {
                      print('Renvoyer le code OTP pour ${widget.email}');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Code OTP renvoyé !')),
                      );
                    },
                    child: const Text(
                      'Renvoyer le code',
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