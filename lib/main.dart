import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'config/routes/app_routes.dart';
import 'config/theme/app_theme.dart';
import '/shared/widgets/global_localization_widget.dart';
import '/shared/widgets/theme_aware_widget.dart';
import '/core/services/localization_service.dart';
import '/core/providers/theme_provider.dart';
import 'features/auth/presentation/pages/onboarding/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  // Initialiser le service de localisation
  final localizationService = LocalizationService();
  await localizationService.initializeLanguage();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: localizationService),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: const TourismApp(),
    ),
  );
}

class TourismApp extends StatelessWidget {
  const TourismApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LocalizationService>(
      builder: (context, themeProvider, localizationService, child) {
        return ThemeAwareWidget(
          child: MaterialApp(
            title: 'Marhaba Explorer',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.themeMode,
            home: SplashScreen(),
            onGenerateRoute: AppRoutes.generateRoute,
            // Ajouter la direction du texte basée sur la langue
            builder: (context, child) {
              return Directionality(
                textDirection: localizationService.textDirection,
                child: child!,
              );
            },
          ),
        );
      },
    );
  }
}

