import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'config/routes/app_routes.dart';
import 'config/theme/app_theme.dart';
import '/shared/widgets/global_localization_widget.dart';
import '/shared/widgets/theme_aware_widget.dart';
import '/core/services/localization_service.dart';
import '/core/providers/theme_provider.dart';
import '/core/services/guest_mode_service.dart';
import '/core/network/dio_client.dart';
import 'features/auth/presentation/pages/onboarding/splash_screen.dart';
import 'features/auth/di/auth_injection.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  // Nettoyer les tokens expirés au démarrage de l'app
  await DioClient.clearExpiredTokens();

  // Initialiser le service de localisation
  final localizationService = LocalizationService();
  await localizationService.initializeLanguage();

  // Initialiser le service de mode invité
  final guestModeService = GuestModeService();
  await guestModeService.loadGuestModeState();

  // Initialiser l'injection de dépendances pour l'authentification
  AuthInjection.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: localizationService),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => GuestModeService()),
      ],
      child: BlocProvider<AuthBloc>(
        create: (_) {
          final authBloc = AuthInjection.getAuthBloc();
          // Check if user is in guest mode first
          if (guestModeService.isGuestMode) {
            // If in guest mode, don't request current user
            return authBloc;
          } else {
            // Otherwise, try to get current user
            authBloc.add(GetCurrentUserRequested());
            return authBloc;
          }
        },
        child: const TourismApp(),
      ),
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

