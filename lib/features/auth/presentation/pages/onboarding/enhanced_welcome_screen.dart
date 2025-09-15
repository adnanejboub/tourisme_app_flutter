import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../config/routes/app_routes.dart';
import '../../../../../config/theme/app_theme.dart';
import '../../../../../core/services/localization_service.dart';
import '../../../../../core/providers/theme_provider.dart';
import '../../../../../core/services/guest_mode_service.dart';
import '../../../../../core/services/location_service.dart';
import '../../../../explore/presentation/pages/city_details_page.dart';

class EnhancedWelcomeScreen extends StatefulWidget {
  const EnhancedWelcomeScreen({Key? key}) : super(key: key);

  @override
  _EnhancedWelcomeScreenState createState() => _EnhancedWelcomeScreenState();
}

class _EnhancedWelcomeScreenState extends State<EnhancedWelcomeScreen>
    with TickerProviderStateMixin {
  
  // Services
  final LocationService _locationService = LocationService();
  final LocalizationService _localizationService = LocalizationService();
  final GuestModeService _guestModeService = GuestModeService();

  // Animation controllers
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<double> _slideAnimation;
  late Animation<double> _pulseAnimation;
  
  String? detectedCity;
  bool isLoadingLocation = true;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _detectUserLocation();
  }

  void _initAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _slideController.forward();
    _pulseController.repeat(reverse: true);
  }

  Future<void> _detectUserLocation() async {
    try {
      setState(() => isLoadingLocation = true);
      
      final location = await _locationService.detectUserLocation();
      final nearestCity = _locationService.getNearestMoroccanCity(
        location.latitude,
        location.longitude,
      );
      
      setState(() {
        detectedCity = nearestCity;
        isLoadingLocation = false;
      });
    } catch (e) {
      setState(() {
        detectedCity = 'Casablanca';
        isLoadingLocation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _slideAnimation,
            builder: (context, child) {
              if (!_slideController.isCompleted && !_slideController.isAnimating && _slideController.value == 0.0) {
                return Container(); // Return empty container while initializing
              }
              return Transform.translate(
                offset: Offset(0, 50 * (1 - _slideAnimation.value)),
                child: Opacity(
                  opacity: _slideAnimation.value.clamp(0.0, 1.0),
                  child: _buildMainContent(colorScheme),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(ColorScheme colorScheme) {
    return Column(
      children: [
        // Header with navigation icons
        _buildHeader(colorScheme),
        
        // Main content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 40),
                
                // Welcome section
                _buildWelcomeSection(colorScheme),
                
                const SizedBox(height: 50),
                
                // Morocco card
                _buildMoroccoCard(colorScheme),
                        
                        const SizedBox(height: 40),
                
                // Action buttons
                _buildActionButtons(colorScheme),
                
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Skip button
          TextButton(
            onPressed: _handleSkip,
            child: Text(
              _localizationService.translate('skip'),
              style: TextStyle(
                color: AppTheme.textSecondaryColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSkip() {
    // Enable guest mode and navigate to main app
    _guestModeService.enableGuestMode();
    Navigator.pushReplacementNamed(context, AppRoutes.mainNavigation);
  }

  Widget _buildWelcomeSection(ColorScheme colorScheme) {
    return Column(
      children: [
        // Welcome title
        Text(
          _localizationService.translate('welcome_title'),
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            color: AppTheme.textPrimaryColor,
            fontSize: 36,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 16),
        
        // Subtitle
        Text(
          'Discover The Country Of History.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppTheme.textSecondaryColor,
            fontSize: 16,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMoroccoCard(ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Morocco icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.location_city_outlined,
              size: 40,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 20),
          
          Text(
            'Morocco',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Discover The Country\nOf History.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ColorScheme colorScheme) {
    return Column(
      children: [
        // New Trip button
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            if (!_pulseController.isAnimating && _pulseController.value == 0.0) {
              return _buildActionButton(
                icon: Icons.flight_takeoff,
                text: _localizationService.translate('new_trip'),
                isPrimary: true,
                colorScheme: colorScheme,
                onTap: _handleNewTrip,
              );
            }
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: _buildActionButton(
                icon: Icons.flight_takeoff,
                text: _localizationService.translate('new_trip'),
                isPrimary: true,
                colorScheme: colorScheme,
                onTap: _handleNewTrip,
              ),
            );
          },
        ),
        
        const SizedBox(height: 20),
        
        // Explore button
        _buildActionButton(
          icon: Icons.explore,
          text: _localizationService.translate('explore'),
          isPrimary: false,
          colorScheme: colorScheme,
          onTap: _handleExplore,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String text,
    required bool isPrimary,
    required ColorScheme colorScheme,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
        decoration: BoxDecoration(
          gradient: isPrimary ? AppTheme.primaryGradient : null,
          color: isPrimary ? null : colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: isPrimary ? null : Border.all(
            color: AppTheme.borderColor,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isPrimary 
                ? AppTheme.primaryColor.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
              blurRadius: isPrimary ? 12 : 8,
              offset: Offset(0, isPrimary ? 6 : 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon circle
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isPrimary 
                  ? Colors.white.withOpacity(0.2)
                  : AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isPrimary 
                  ? Colors.white
                  : AppTheme.primaryColor,
                size: 26,
              ),
            ),
            
            const SizedBox(width: 20),
            
            // Text
            Expanded(
              child: Text(
                text,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: isPrimary 
                    ? Colors.white
                    : AppTheme.textPrimaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            
            // Arrow
            Icon(
              Icons.arrow_forward_ios,
              color: isPrimary 
                ? Colors.white
                : AppTheme.textSecondaryColor,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  void _handleNewTrip() async {
    // Navigate directly to Casablanca details
    _guestModeService.enableGuestMode();
    final casablancaData = {
      'id': 1,
      'nom': 'Casablanca',
      'nomVille': 'Casablanca',
      'name': 'Casablanca',
      'description': 'La plus grande ville du Maroc et son centre économique, connue pour sa mosquée Hassan II et son architecture moderne.',
      'imageUrl': 'assets/images/cities/casablanca.jpg',
      'latitude': 33.5731,
      'longitude': -7.5898,
      'pays': 'Maroc',
      'region': 'Casablanca-Settat',
      'population': '3.4M',
      'superficie': '220 km²',
      'climat': 'Méditerranéen',
      'langue': 'Arabe, Français',
      'monnaie': 'Dirham marocain (MAD)',
      'fuseau_horaire': 'UTC+1',
      'code_telephonique': '+212',
      'aeroport': 'Aéroport Mohammed V',
      'gare': 'Gare Casa-Port',
      'attractions_principales': [
        'Mosquée Hassan II',
        'Place Mohammed V',
        'Corniche de Casablanca',
        'Marché Central',
        'Quartier Habous',
      ],
      'activites': [
        'Visite de la mosquée Hassan II',
        'Promenade sur la Corniche',
        'Shopping au Marché Central',
        'Découverte du quartier Habous',
        'Visite du Parc de la Ligue Arabe',
      ],
      'specialites_culinaires': [
        'Pastilla',
        'Tajine',
        'Couscous',
        'Thé à la menthe',
        'Pâtisseries marocaines',
      ],
      'conseils_voyage': [
        'Visitez la mosquée Hassan II tôt le matin',
        'Explorez le quartier Habous pour l\'artisanat',
        'Profitez du coucher de soleil sur la Corniche',
        'Goûtez aux spécialités locales au Marché Central',
      ],
      'transport': ['Tramway', 'Bus', 'Taxi', 'Location de voiture', 'Vélo'],
      'hebergement': [
        'Hôtels de luxe',
        'Riads traditionnels',
        'Auberges de jeunesse',
        'Appartements de location',
      ],
      'shopping': [
        'Marché Central',
        'Quartier Habous',
        'Centre commercial Morocco Mall',
        'Souks traditionnels',
      ],
      'vie_nocturne': ['Bars et clubs', 'Restaurants', 'Théâtres', 'Cinémas'],
      'sante_securite': [
        'Hôpitaux modernes',
        'Pharmacies',
        'Police touristique',
        'Services d\'urgence',
      ],
      'budget': [
        'Hébergement: 200-800 MAD/nuit',
        'Repas: 50-200 MAD',
        'Transport: 10-50 MAD',
        'Activités: 100-300 MAD',
      ],
      'meilleure_periode': 'Mars à Mai, Septembre à Novembre',
      'duree_recommandee': '2-3 jours',
      'niveau_budget': 'Moyen à Élevé',
      'type_voyage': 'Urbain, Culturel, Business',
      'accessibilite': 'Bonne',
      'langues_parlees': ['Arabe', 'Français', 'Anglais'],
    };

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CityDetailsPage(city: casablancaData),
      ),
    );
  }

  void _handleExplore() {
    // Enable guest mode and navigate to explore page
    _guestModeService.enableGuestMode();
    Navigator.pushNamed(context, AppRoutes.explore);
  }

  @override
  void dispose() {
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }
}