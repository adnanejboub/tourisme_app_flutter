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

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LocalizationService()),
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
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return ThemeAwareWidget(
          child: MaterialApp(
            title: 'Marhaba Explorer',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.themeMode,
            home: SplashScreen(),
            onGenerateRoute: AppRoutes.generateRoute,
          ),
        );
      },
    );
  }
}

