// main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Nécessaire pour SystemChrome
import 'config/routes/app_routes.dart';
import 'config/theme/app_theme.dart';
// Note: SplashScreen n'est plus importé ici directement car il est géré par AppRoutes.generateRoute
// et n'est pas utilisé via la propriété 'home'.

void main() {
  // Assurez-vous que les bindings Flutter sont initialisés avant de configurer le style de la barre système
  WidgetsFlutterBinding.ensureInitialized();
  // Configuration de la barre de statut pour un look moderne et transparent
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // Rendre la barre de statut transparente
    statusBarIconBrightness: Brightness.dark, // Icônes sombres pour un fond clair
  ));

  runApp(const TourismApp()); // Utilisation de TourismApp comme défini par l'utilisateur
}

class TourismApp extends StatelessWidget {
  const TourismApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Morocco Tourism', // Titre de l'application
      debugShowCheckedModeBanner: false, // Masquer la bannière de débogage
      theme: AppTheme.lightTheme, // Thème clair par défaut
      darkTheme: AppTheme.darkTheme, // Thème sombre
      themeMode: ThemeMode.system, // Utiliser le thème du système (clair/sombre)
      initialRoute: AppRoutes.splash, // Démarrer avec l'écran de splash
      onGenerateRoute: AppRoutes.generateRoute, // Utiliser la méthode de génération de route
      // IMPORTANT: La propriété 'home' est supprimée car elle est redondante
      // avec 'initialRoute' et 'onGenerateRoute', ce qui causait le problème.
    );
  }
}