import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/services/guest_mode_service.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/image_service.dart';
import '../../../explore/data/services/public_api_service.dart';
import '../../../explore/data/models/city_dto.dart';
import '../../../explore/data/models/activity.dart';
import '../../../../core/services/new_user_service.dart';
import '../../../../core/services/recommendation_service.dart' as rec;
import '../../../../core/services/personalized_recommendation_service.dart';
import '../../../auth/data/datasources/auth_remote_data_source.dart';
import '../../../explore/presentation/pages/city_details_page.dart';
import '../../../explore/presentation/pages/details_explore.dart';
import '../../../explore/presentation/pages/search_explore_page.dart';
import '../../../../shared/widgets/notification_icon.dart';
import '../../../../shared/widgets/notification_drawer.dart';
import '../../../../core/services/notification_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GuestModeService _guestMode = GuestModeService();
  final LocationService _locationService = LocationService();
  final PublicApiService _publicApi = PublicApiService();
  final NotificationService _notificationService = NotificationService();
  bool _initializing = true;
  LocationInfo? _locationInfo;
  CityDto? _guestCity;
  List<ActivityModel> _guestCityActivities = [];
  List<ActivityModel> _guestCityMonuments = [];
  String? _userDisplayName;

  // New user suggestions
  rec.Destination? _suggestedDestination;
  List<rec.Activity> _suggestedActivities = [];

  // Personalized recommendations
  final PersonalizedRecommendationService _personalizedService = PersonalizedRecommendationService();
  Map<String, dynamic>? _recommendedCity;
  List<ActivityModel> _recommendedActivities = [];
  List<ActivityModel> _recommendedMonuments = [];

  // Notification drawer
  bool _showNotificationDrawer = false;

  bool _isMonumentActivity(ActivityModel activity) {
    final category = (activity.categorie ?? '').toLowerCase();
    final name = activity.nom.toLowerCase();
    return category.contains('monument') ||
        category.contains('historique') ||
        category.contains('patrimoine') ||
        name.contains('mosquée') ||
        name.contains('quartier des habous') ||
        name.contains('médina') ||
        name.contains('kasbah');
  }

  List<ActivityModel> _createCasablancaActivities() {
    return [
      ActivityModel(
        id: 1001,
        nom: 'Shopping à Casablanca',
        description: 'Découvrez les centres commerciaux modernes et souks traditionnels de Casablanca. De Morocco Mall aux souks de la médina, explorez la diversité commerciale de la ville.',
        dureeMinimun: 120,
        dureeMaximun: 300,
        saison: 'Toute l\'année',
        niveauDificulta: 'Facile',
        categorie: 'TOURS',
        ville: 'Casablanca',
        prix: 0,
        imageUrl: 'assets/images/activities/casablanca_shopping.jpg',
      ),
      ActivityModel(
        id: 1002,
        nom: 'Restaurants de Casablanca',
        description: 'Savourez la gastronomie marocaine authentique dans les meilleurs restaurants de la ville. De la cuisine traditionnelle aux spécialités modernes.',
        dureeMinimun: 90,
        dureeMaximun: 180,
        saison: 'Toute l\'année',
        niveauDificulta: 'Facile',
        categorie: 'EVENEMENTS',
        ville: 'Casablanca',
        prix: 0,
        imageUrl: 'assets/images/activities/casablanca_restaurants.jpg',
      ),
      ActivityModel(
        id: 1003,
        nom: 'Vie nocturne à Casablanca',
        description: 'Explorez les bars, clubs et cafés de la ville moderne. Découvrez l\'ambiance nocturne dynamique de la métropole marocaine.',
        dureeMinimun: 180,
        dureeMaximun: 360,
        saison: 'Toute l\'année',
        niveauDificulta: 'Facile',
        categorie: 'EVENEMENTS',
        ville: 'Casablanca',
        prix: 0,
        imageUrl: 'assets/images/activities/casablanca_nightlife.jpg',
      ),
      ActivityModel(
        id: 1006,
        nom: 'Galerie d\'art de Casablanca',
        description: 'Découvrez l\'art contemporain marocain et international. Expositions, vernissages et rencontres avec les artistes locaux.',
        dureeMinimun: 90,
        dureeMaximun: 150,
        saison: 'Toute l\'année',
        niveauDificulta: 'Facile',
        categorie: 'EVENEMENTS',
        ville: 'Casablanca',
        prix: 0,
        imageUrl: 'assets/images/activities/casablanca_art_gallery.jpg',
      ),
      ActivityModel(
        id: 1007,
        nom: 'Business à Casablanca',
        description: 'Découvrez le centre d\'affaires de Casablanca. Tours modernes, centres de conférences et l\'économie dynamique du Maroc.',
        dureeMinimun: 120,
        dureeMaximun: 240,
        saison: 'Toute l\'année',
        niveauDificulta: 'Facile',
        categorie: 'TOURS',
        ville: 'Casablanca',
        prix: 0,
        imageUrl: 'assets/images/activities/casablanca_business.jpg',
      ),
    ];
  }

  List<ActivityModel> _createCasablancaMonuments() {
    return [
      ActivityModel(
        id: 2001,
        nom: 'Mosquée Hassan II',
        description: 'L\'une des plus grandes mosquées du monde avec un minaret de 200 mètres. Chef-d\'œuvre architectural marocain surplombant l\'océan Atlantique.',
        dureeMinimun: 90,
        dureeMaximun: 180,
        saison: 'Toute l\'année',
        niveauDificulta: 'Facile',
        categorie: 'MONUMENT',
        ville: 'Casablanca',
        prix: 120,
        imageUrl: 'assets/images/monuments/hassan_ii_mosque.jpg',
      ),
      ActivityModel(
        id: 2002,
        nom: 'Quartier des Habous',
        description: 'Quartier traditionnel avec architecture marocaine authentique. Découvrez les souks, les mosquées et l\'artisanat local dans un cadre historique préservé.',
        dureeMinimun: 120,
        dureeMaximun: 240,
        saison: 'Toute l\'année',
        niveauDificulta: 'Facile',
        categorie: 'MONUMENT',
        ville: 'Casablanca',
        prix: 0,
        imageUrl: 'assets/images/monuments/habous_quarter.jpg',
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    // Générer les notifications de démonstration
    _notificationService.generateDemoNotifications();
    _bootstrap();
  }

  void _openNotificationsPage() {
    setState(() {
      _showNotificationDrawer = true;
    });
  }

  void _closeNotificationDrawer() {
    setState(() {
      _showNotificationDrawer = false;
    });
    // Forcer la mise à jour de l'icône de notification
    Future.delayed(Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {});
      }
    });
  }

  Widget _buildCitySmartImage(CityDto city, ColorScheme colorScheme) {
    final String img = (city.imageUrl != null && city.imageUrl!.isNotEmpty)
        ? city.imageUrl!
        : ImageService.getCityImage(city.nom);
    if (ImageService.isLocalAsset(img)) {
      return Image.asset(
        img,
        height: 160,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }
    return Image.network(
      img,
      height: 160,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stack) {
        final fallback = ImageService.getCityFallbackImage();
        if (ImageService.isLocalAsset(fallback)) {
          return Image.asset(
            fallback,
            height: 160,
            width: double.infinity,
            fit: BoxFit.cover,
          );
        }
        return Container(
          height: 160,
          color: colorScheme.onSurface.withOpacity(0.06),
        );
      },
    );
  }

  Widget _buildGenericSmartImage(
    String? imageUrl,
    double width,
    double height,
    ColorScheme colorScheme,
  ) {
    final String img = (imageUrl != null && imageUrl.isNotEmpty)
        ? imageUrl
        : ImageService.getActivityFallbackImage();
    if (ImageService.isLocalAsset(img)) {
      final String assetPath = img.startsWith('images/') ? 'assets/' + img : img;
      return Image.asset(assetPath, width: width, height: height, fit: BoxFit.cover);
    }
    return Image.network(
      img,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stack) {
        final fallback = ImageService.getActivityFallbackImage();
        if (ImageService.isLocalAsset(fallback)) {
          return Image.asset(
            fallback,
            width: width,
            height: height,
            fit: BoxFit.cover,
          );
        }
        return Container(
          width: width,
          height: height,
          color: colorScheme.onSurface.withOpacity(0.06),
          child: Icon(
            Icons.image,
            color: colorScheme.onSurface.withOpacity(0.5),
          ),
        );
      },
    );
  }

  void _openCityDetails(CityDto city) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CityDetailsPage(city: city.toCityDetailsMap()),
      ),
    );
  }

  void _openActivityDetails(ActivityModel activity) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailsExplorePage(
          destination: {
            'id': activity.id,
            'title': activity.nom,
            'image':
                activity.imageUrl ??
                ImageService.getActivityImage(activity.categorie, activity.nom),
            'description': activity.description ?? '',
            'prix': activity.prix,
            'dureeMinimun': activity.dureeMinimun,
            'dureeMaximun': activity.dureeMaximun,
            'saison': activity.saison,
            'niveauDificulta': activity.niveauDificulta,
            'categorie': activity.categorie,
          },
        ),
      ),
    );
  }

  void _openPersonalizedCityDetails(Map<String, dynamic> city) async {
    try {
      // Récupérer toutes les villes depuis l'API
      final cities = await _publicApi.getAllCities();
      
      // Chercher la ville correspondante par nom
      final cityName = city['name'] as String;
      final matchingCity = cities.firstWhere(
        (c) => c.nom.toLowerCase() == cityName.toLowerCase(),
        orElse: () => CityDto(
          id: 0,
          nom: cityName,
          description: city['description'] as String? ?? '',
          imageUrl: city['image'] as String? ?? '',
          paysNom: 'Maroc',
          latitude: 0.0,
          longitude: 0.0,
          climatNom: 'Méditerranéen',
          isPlage: city['characteristics']?.contains('isPlage') ?? false,
          isMontagne: city['characteristics']?.contains('isMontagne') ?? false,
          isDesert: city['characteristics']?.contains('isDesert') ?? false,
          isRiviera: city['characteristics']?.contains('isRiviera') ?? false,
          isHistorique: city['characteristics']?.contains('isHistorique') ?? false,
          isCulturelle: city['characteristics']?.contains('isCulturelle') ?? false,
          isModerne: city['characteristics']?.contains('isModerne') ?? false,
        ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CityDetailsPage(city: matchingCity.toCityDetailsMap()),
        ),
      );
    } catch (e) {
      // En cas d'erreur, créer une ville par défaut
      final cityDto = CityDto(
        id: 0,
        nom: city['name'] as String,
        description: city['description'] as String? ?? '',
        imageUrl: city['image'] as String? ?? '',
        paysNom: 'Maroc',
        latitude: 0.0,
        longitude: 0.0,
        climatNom: 'Méditerranéen',
        isPlage: city['characteristics']?.contains('isPlage') ?? false,
        isMontagne: city['characteristics']?.contains('isMontagne') ?? false,
        isDesert: city['characteristics']?.contains('isDesert') ?? false,
        isRiviera: city['characteristics']?.contains('isRiviera') ?? false,
        isHistorique: city['characteristics']?.contains('isHistorique') ?? false,
        isCulturelle: city['characteristics']?.contains('isCulturelle') ?? false,
        isModerne: city['characteristics']?.contains('isModerne') ?? false,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CityDetailsPage(city: cityDto.toCityDetailsMap()),
        ),
      );
    }
  }

  void _openRecommendedDestinationDetails(Map<String, dynamic> destination) async {
    try {
      // Récupérer toutes les villes depuis l'API
      final cities = await _publicApi.getAllCities();
      
      // Chercher la ville correspondante par nom
      final cityName = destination['name'] ?? '';
      final matchingCity = cities.firstWhere(
        (city) => city.nom.toLowerCase() == cityName.toLowerCase(),
        orElse: () => CityDto(
          id: destination['id'] ?? 0,
          nom: cityName,
          description: destination['subtitle'] ?? destination['description'] ?? '',
          imageUrl: destination['image'] ?? '',
          paysNom: 'Maroc',
          latitude: destination['latitude'],
          longitude: destination['longitude'],
          climatNom: destination['climate'],
          isPlage: destination['isPlage'] ?? false,
          isMontagne: destination['isMontagne'] ?? false,
          isDesert: destination['isDesert'] ?? false,
          isRiviera: destination['isRiviera'] ?? false,
          isHistorique: destination['isHistorique'] ?? false,
          isCulturelle: destination['isCulturelle'] ?? false,
          isModerne: destination['isModerne'] ?? false,
        ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CityDetailsPage(city: matchingCity.toCityDetailsMap()),
        ),
      );
    } catch (e) {
      // En cas d'erreur, utiliser les données de destination
      final cityDto = CityDto(
        id: destination['id'] ?? 0,
        nom: destination['name'] ?? 'Destination',
        description: destination['subtitle'] ?? destination['description'] ?? '',
        imageUrl: destination['image'] ?? '',
        paysNom: 'Maroc',
        latitude: destination['latitude'],
        longitude: destination['longitude'],
        climatNom: destination['climate'],
        isPlage: destination['isPlage'] ?? false,
        isMontagne: destination['isMontagne'] ?? false,
        isDesert: destination['isDesert'] ?? false,
        isRiviera: destination['isRiviera'] ?? false,
        isHistorique: destination['isHistorique'] ?? false,
        isCulturelle: destination['isCulturelle'] ?? false,
        isModerne: destination['isModerne'] ?? false,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CityDetailsPage(city: cityDto.toCityDetailsMap()),
        ),
      );
    }
  }

  Future<void> _bootstrap() async {
    try {
      // Detect mode (guest or authenticated/new user) and populate data accordingly
      await _guestMode.loadGuestModeState();

      if (_guestMode.isGuestMode) {
        await _loadGuestData();
      } else {
        // Charger le nom de l'utilisateur authentifié
        await _loadAuthenticatedUserName();
        
        final shouldShowPrefs =
            await NewUserService.shouldShowPreferencesQuestionnaire();
        final hasCompleted = await NewUserService.hasCompletedPreferences();
        
        if (hasCompleted && !shouldShowPrefs) {
          // Utilisateur qui a complété le questionnaire - afficher les recommandations personnalisées
          await _loadPersonalizedRecommendations();
        } else {
          // Utilisateur qui a skip le questionnaire - afficher comme un guest mais avec son nom
          await _loadGuestData();
        }
      }
    } catch (_) {
      // Best effort; keep home usable even if any step fails
    } finally {
      if (mounted) setState(() => _initializing = false);
    }
  }

  Future<void> _loadAuthenticatedUserName() async {
    try {
      final profile = await AuthRemoteDataSourceImpl().getCurrentUser();
      final fullName = '${profile.firstName} ${profile.lastName}'.trim();
      if (mounted) {
        setState(() {
          _userDisplayName = fullName.isNotEmpty ? fullName : profile.email;
        });
      }
    } catch (_) {}
  }

  Future<void> _loadGuestData() async {
    try {
      final location = await _locationService.detectUserLocation();
      final nearestCityName = _locationService.getNearestMoroccanCity(
        location.latitude,
        location.longitude,
      );
      final cities = await _publicApi.getAllCities();
      final activities = await _publicApi.getAllActivities();

      CityDto? match;
      try {
        match = cities.firstWhere(
          (c) => c.nom.toLowerCase() == nearestCityName.toLowerCase(),
        );
      } catch (_) {
        match = cities.isNotEmpty ? cities.first : null;
      }

      List<ActivityModel> cityActivities = [];
      List<ActivityModel> filteredActivities = [];
      List<ActivityModel> monuments = [];
      
      if (match != null) {
        // Récupérer les activités de la base de données
        cityActivities = activities
            .where(
              (a) =>
                  (a.ville ?? '').toLowerCase() == match!.nom.toLowerCase(),
            )
            .toList();
        
        // Si c'est Casablanca, toujours ajouter nos activités et monuments
        if (match.nom.toLowerCase() == 'casablanca') {
          // Ajouter les activités de Casablanca
          cityActivities.addAll(_createCasablancaActivities());
          // Ajouter les monuments de Casablanca
          cityActivities.addAll(_createCasablancaMonuments());
        }
        
        // Supprimer les doublons basés sur l'ID
        final uniqueActivities = <int, ActivityModel>{};
        for (final activity in cityActivities) {
          uniqueActivities[activity.id] = activity;
        }
        final deduplicatedActivities = uniqueActivities.values.toList();
        
        // Séparer les activités et monuments
        filteredActivities = deduplicatedActivities.where((a) => !_isMonumentActivity(a)).toList();
        monuments = deduplicatedActivities.where(_isMonumentActivity).toList();
      }

      if (mounted) {
        setState(() {
          _locationInfo = location;
          _guestCity = match;
          _guestCityActivities = filteredActivities;
          _guestCityMonuments = monuments;
        });
      }
    } catch (_) {}
  }

  Future<void> _loadPersonalizedRecommendations() async {
    try {
      // Obtenir la ville recommandée basée sur les préférences
      final recommendedCity = await _personalizedService.getRecommendedCity();
      
      if (recommendedCity != null) {
        // Obtenir les activités et monuments pour cette ville
        final activities = await _personalizedService.getRecommendedActivities(
          recommendedCity['name'] as String,
        );
        final monuments = await _personalizedService.getRecommendedMonuments(
          recommendedCity['name'] as String,
        );
        
        if (mounted) {
          setState(() {
            _recommendedCity = recommendedCity;
            _recommendedActivities = activities;
            _recommendedMonuments = monuments;
          });
        }
      }
    } catch (e) {
      print('Erreur lors du chargement des recommandations personnalisées: $e');
      // Fallback vers le mode guest en cas d'erreur
      await _loadGuestData();
    }
  }

  Future<void> _loadNewUserSuggestions() async {
    try {
      final prefs = await NewUserService.getUserPreferences();
      final filter = _mapPreferencesToFilter(prefs);
      final service = rec.RecommendationService();
      final destinations = await service.getRecommendedDestinations(
        filter: filter,
        limit: 1,
      );
      rec.Destination? top = destinations.isNotEmpty
          ? destinations.first
          : null;
      List<rec.Activity> acts = [];
      if (top != null) {
        acts = await service.getRecommendedActivities(
          destinationId: top.id,
          userPreferences: filter.preferredActivities,
          budgetRange: filter.budgetRange,
          tripDuration: filter.tripDuration,
          limit: 6,
        );
      }
      if (mounted) {
        setState(() {
          _suggestedDestination = top;
          _suggestedActivities = acts;
        });
      }
    } catch (_) {}
  }

  rec.RecommendationFilter _mapPreferencesToFilter(Map<String, dynamic> prefs) {
    // Basic mapping from questionnaire keys used in NewUserPreferencesPage
    final List<String> interests = [];
    final dynamic interestsPref = prefs['interests'];
    if (interestsPref is List) {
      interests.addAll(interestsPref.map((e) => e.toString()));
    } else if (interestsPref is String && interestsPref.isNotEmpty) {
      interests.add(interestsPref);
    }

    rec.BudgetRange? budget;
    final budgetVal = prefs['budget']?.toString();
    switch (budgetVal) {
      case 'budget':
        budget = rec.BudgetRange.budget;
        break;
      case 'luxury':
        budget = rec.BudgetRange.luxury;
        break;
      default:
        budget = rec.BudgetRange.midRange;
    }

    int? duration;
    final d = prefs['duration'];
    if (d is int)
      duration = d;
    else if (d is double)
      duration = d.round();

    // Map interests to preferredActivities ids roughly
    final List<String> preferredActivities = <String>[];
    for (final it in interests) {
      final key = it.toLowerCase();
      if (key.contains('food')) preferredActivities.add('food_tour');
      if (key.contains('culture') || key.contains('history'))
        preferredActivities.add('cultural_visit');
      if (key.contains('adventure') || key.contains('nature'))
        preferredActivities.add('adventure');
      if (key.contains('relax')) preferredActivities.add('relaxation');
      if (key.contains('shopping')) preferredActivities.add('shopping');
      if (key.contains('night')) preferredActivities.add('sightseeing');
    }

    return rec.RecommendationFilter(
      interests: interests.isEmpty ? null : interests,
      budgetRange: budget,
      tripDuration: duration,
      preferredActivities: preferredActivities.isEmpty
          ? null
          : preferredActivities,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer<LocalizationService>(
      builder: (context, localizationService, child) {
        // Build Recommended Near You dynamically from guest city activities (de-duplicated)
        final List<Map<String, dynamic>> recommendationsNearYou =
            (_guestMode.isGuestMode && _guestCity != null)
                ? _guestCityActivities
                    .where((a) => (a.ville ?? '').toLowerCase() == (_guestCity!.nom.toLowerCase()))
                    .where((a) => !_isMonumentActivity(a))
                    .toSet()
                    .toList()
                    .map((a) {
                    final img = (a.imageUrl != null && a.imageUrl!.isNotEmpty)
                        ? a.imageUrl!
                        : ImageService.getActivityImage(a.categorie, a.nom);
                    return {
                      'title': a.nom,
                      'subtitle': (a.categorie ?? ''),
                      'image': img,
                      'type': (a.categorie ?? ''),
                      'rating': 4.7,
                      'distance': _guestCity?.nom ?? '',
                      'activity': a,
                    };
                  }).toList()
                : [];

        // Top Moroccan destinations using local asset images
        final List<Map<String, dynamic>> trendingDestinations = [
          {
            'name': 'Marrakech',
            'subtitle': 'La ville rouge et ses souks animés',
            'image': 'assets/images/cities/marrakech.jpg',
            'rating': 4.8,
            'reviews': '2.1K',
          },
          {
            'name': 'Agadir',
            'subtitle': 'Stations balnéaires et plages ensoleillées',
            'image': 'assets/images/cities/agadir.jpg',
            'rating': 4.7,
            'reviews': '1.4K',
          },
          {
            'name': 'Fès',
            'subtitle': 'Capitale spirituelle et médina historique',
            'image': 'assets/images/cities/fes.jpg',
            'rating': 4.6,
            'reviews': '1.2K',
          },
          {
            'name': 'Casablanca',
            'subtitle': 'Métropole moderne du Maroc',
            'image': 'assets/images/cities/casablanca.jpg',
            'rating': 4.5,
            'reviews': '3.0K',
          },
        ];


        return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: colorScheme.background,
          body: Stack(
            children: [
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final screenWidth = constraints.maxWidth;
                    final screenHeight = constraints.maxHeight;
                    final isTablet = screenWidth > 600;
                    final isDesktop = screenWidth > 900;
                    final isLandscape = screenWidth > screenHeight;

                    return SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 24 : (isTablet ? 20 : 16),
                        vertical: 8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_guestMode.isGuestMode)
                            _buildGuestBanner(colorScheme),
                          if (_initializing) LinearProgressIndicator(minHeight: 2),
                          _buildHeader(
                            localizationService,
                            screenWidth,
                            isTablet,
                            isDesktop,
                            colorScheme,
                          ),
                          SizedBox(height: isDesktop ? 24 : 16),
                          _buildSearchBar(
                            localizationService,
                            screenWidth,
                            isTablet,
                            isDesktop,
                            colorScheme,
                          ),
                          SizedBox(height: isDesktop ? 24 : 16),
                      
                      // Mode Guest ou utilisateur qui a skip le questionnaire
                      if ((_guestMode.isGuestMode && _guestCity != null) || 
                          (!_guestMode.isGuestMode && _recommendedCity == null && _guestCity != null)) ...[
                        _buildGuestCitySection(
                          colorScheme,
                          _guestCity!,
                          localizationService,
                        ),
                        SizedBox(height: isDesktop ? 24 : 16),
                        _buildGuestActivitiesSection(
                          colorScheme,
                          localizationService,
                        ),
                        SizedBox(height: isDesktop ? 24 : 16),
                        _buildGuestMonumentsSection(
                          colorScheme,
                          localizationService,
                        ),
                        SizedBox(height: isDesktop ? 24 : 16),
                      ],
                      // Utilisateur avec recommandations personnalisées
                      if (!_guestMode.isGuestMode && _recommendedCity != null) ...[
                        _buildPersonalizedCitySection(
                          colorScheme,
                          localizationService,
                        ),
                        SizedBox(height: isDesktop ? 24 : 16),
                        _buildPersonalizedActivitiesSection(
                          colorScheme,
                          localizationService,
                        ),
                        SizedBox(height: isDesktop ? 24 : 16),
                        _buildPersonalizedMonumentsSection(
                          colorScheme,
                          localizationService,
                        ),
                        SizedBox(height: isDesktop ? 24 : 16),
                      ],
                      // Ancien système de suggestions (fallback)
                      if (!_guestMode.isGuestMode &&
                          _suggestedDestination != null &&
                          _recommendedCity == null) ...[
                        _buildSuggestedDestinationSection(
                          colorScheme,
                          localizationService,
                        ),
                        SizedBox(height: isDesktop ? 24 : 16),
                        _buildSuggestedActivitiesSection(
                          colorScheme,
                          localizationService,
                        ),
                        SizedBox(height: isDesktop ? 24 : 16),
                      ],
                      _buildSection(
                        localizationService.translate(
                          'home_recommendations_title',
                        ),
                        recommendationsNearYou,
                        (item) => _buildRecommendationCard(
                          item,
                          screenWidth,
                          isTablet,
                          isDesktop,
                          colorScheme,
                        ),
                        screenWidth,
                        isTablet,
                        isDesktop,
                        colorScheme,
                      ),
                      _buildSection(
                        localizationService.translate('home_trending_title'),
                        trendingDestinations,
                        (item) => _buildTrendingDestinationCard(
                          item,
                          localizationService,
                          screenWidth,
                          isTablet,
                          isDesktop,
                          colorScheme,
                        ),
                        screenWidth,
                        isTablet,
                        isDesktop,
                        colorScheme,
                      ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // Notification Drawer
              if (_showNotificationDrawer)
                NotificationDrawer(
                  onClose: _closeNotificationDrawer,
                  initialHeight: 0.6,
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGuestBanner(ColorScheme colorScheme) {
    final city = _guestCity?.nom ?? _locationInfo?.city ?? 'Guest';
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.person_outline, color: colorScheme.primary),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Welcome guest • ${city}',
              style: TextStyle(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestCitySection(
    ColorScheme colorScheme,
    CityDto city,
    LocalizationService localizationService,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Votre ville: ${city.nom}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            TextButton(
              onPressed: () => _openCityDetails(city),
              child: Text(
                'Explorer >',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        InkWell(
          onTap: () => _openCityDetails(city),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: colorScheme.surface,
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                _buildCitySmartImage(city, colorScheme),
                // Overlay avec informations de la ville
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          city.nom,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          city.description ?? 'Découvrez cette magnifique ville',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '4.5',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 16),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${city.nom}-Settat',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGuestActivitiesSection(
    ColorScheme colorScheme,
    LocalizationService localizationService,
  ) {
    final title =
        'Activités à ${_guestCity?.nom ?? (_locationInfo?.city ?? '')}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            TextButton(
              onPressed: () {
                // Naviguer vers la page explore avec la section activités
                Navigator.pushNamed(
                  context,
                  '/explore',
                  arguments: {'initialTab': 'activities'},
                );
              },
              child: Text(
                'Voir tout',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        SizedBox(
          height: 280,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: BouncingScrollPhysics(),
            itemCount: _guestCityActivities.length,
            separatorBuilder: (_, __) => SizedBox(width: 12),
            itemBuilder: (context, index) {
              final activity = _guestCityActivities[index];
              final image =
                  (activity.imageUrl != null && activity.imageUrl!.isNotEmpty)
                  ? activity.imageUrl!
                  : ImageService.getActivityImage(
                      activity.categorie,
                      activity.nom,
                    );
              return InkWell(
                onTap: () => _openActivityDetails(activity),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 280,
                  height: 260,
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: _buildGenericSmartImage(
                          image,
                          280,
                          140,
                          colorScheme,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activity.nom,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onSurface,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 14,
                                  color: colorScheme.primary,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  _guestCity?.nom ?? 'Ville',
                                  style: TextStyle(
                                    color: colorScheme.onSurface.withOpacity(0.7),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 6),
                            if ((activity.categorie ?? '').isNotEmpty)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  activity.categorie!,
                                  style: TextStyle(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            if (activity.prix != null &&
                                activity.prix! > 0) ...[
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.attach_money,
                                    size: 14,
                                    color: colorScheme.primary,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    '${activity.prix} MAD',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.primary,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGuestMonumentsSection(
    ColorScheme colorScheme,
    LocalizationService localizationService,
  ) {
    // Use the dedicated monuments list
    final monuments = _guestCityMonuments;

    if (monuments.isEmpty) return SizedBox.shrink();

    final title =
        'Monuments à ${_guestCity?.nom ?? (_locationInfo?.city ?? '')}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            TextButton(
              onPressed: () {
                // Naviguer vers la page explore avec la section activités
                Navigator.pushNamed(
                  context,
                  '/explore',
                  arguments: {'initialTab': 'activities'},
                );
              },
              child: Text(
                'Voir tout',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        SizedBox(
          height: 280,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: BouncingScrollPhysics(),
            itemCount: monuments.length,
            separatorBuilder: (_, __) => SizedBox(width: 12),
            itemBuilder: (context, index) {
              final monument = monuments[index];
              final image =
                  (monument.imageUrl != null && monument.imageUrl!.isNotEmpty)
                  ? monument.imageUrl!
                  : ImageService.getMonumentImage(monument.nom);
              return InkWell(
                onTap: () => _openActivityDetails(monument),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 280,
                  height: 260,
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: _buildGenericSmartImage(
                          image,
                          280,
                          140,
                          colorScheme,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              monument.nom,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onSurface,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 14,
                                  color: colorScheme.primary,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  _guestCity?.nom ?? 'Ville',
                                  style: TextStyle(
                                    color: colorScheme.onSurface.withOpacity(0.7),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 6),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Monument historique',
                                style: TextStyle(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalizedCitySection(
    ColorScheme colorScheme,
    LocalizationService localizationService,
  ) {
    final city = _recommendedCity!;
    final cityName = city['name'] as String;
    final cityDescription = city['description'] as String;
    final cityImage = city['image'] as String;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recommandé pour vous: $cityName',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            TextButton(
              onPressed: () => _openPersonalizedCityDetails(city),
              child: Text(
                'Explorer >',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        InkWell(
          onTap: () => _openPersonalizedCityDetails(city),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: colorScheme.surface,
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                _buildPersonalizedCityImage(cityImage, colorScheme),
                // Overlay avec informations de la ville
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cityName,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          cityDescription,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '4.6',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 16),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Recommandé',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalizedCityImage(String imagePath, ColorScheme colorScheme) {
    if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }
    return Image.network(
      imagePath,
      height: 200,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stack) {
        return Container(
          height: 200,
          color: colorScheme.onSurface.withOpacity(0.06),
          child: Icon(
            Icons.location_city,
            size: 48,
            color: colorScheme.onSurface.withOpacity(0.5),
          ),
        );
      },
    );
  }

  Widget _buildSuggestedDestinationSection(
    ColorScheme colorScheme,
    LocalizationService localizationService,
  ) {
    final dest = _suggestedDestination!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Suggested for you: ${dest.name}',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: colorScheme.surface,
          ),
          clipBehavior: Clip.antiAlias,
          child: dest.image.isEmpty
              ? SizedBox(height: 160)
              : Image.network(
                  dest.image,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
        ),
        if (dest.description.isNotEmpty) ...[
          SizedBox(height: 8),
          Text(
            dest.description,
            style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
          ),
        ],
      ],
    );
  }

  Widget _buildPersonalizedActivitiesSection(
    ColorScheme colorScheme,
    LocalizationService localizationService,
  ) {
    final cityName = _recommendedCity?['name'] as String? ?? '';
    final title = 'Activités à $cityName';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/explore',
                  arguments: {'initialTab': 'activities'},
                );
              },
              child: Text(
                'Voir tout',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        SizedBox(
          height: 280,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: BouncingScrollPhysics(),
            itemCount: _recommendedActivities.length,
            separatorBuilder: (_, __) => SizedBox(width: 12),
            itemBuilder: (context, index) {
              final activity = _recommendedActivities[index];
              final image = (activity.imageUrl != null && activity.imageUrl!.isNotEmpty)
                  ? activity.imageUrl!
                  : ImageService.getActivityImage(activity.categorie, activity.nom);
              
              return InkWell(
                onTap: () => _openActivityDetails(activity),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 280,
                  height: 260,
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: _buildGenericSmartImage(
                          image,
                          280,
                          140,
                          colorScheme,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activity.nom,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onSurface,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 14,
                                  color: colorScheme.primary,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  cityName,
                                  style: TextStyle(
                                    color: colorScheme.onSurface.withOpacity(0.7),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 6),
                            if ((activity.categorie ?? '').isNotEmpty)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  activity.categorie!,
                                  style: TextStyle(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            if (activity.prix != null && activity.prix! > 0) ...[
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.attach_money,
                                    size: 14,
                                    color: colorScheme.primary,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    '${activity.prix} MAD',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.primary,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalizedMonumentsSection(
    ColorScheme colorScheme,
    LocalizationService localizationService,
  ) {
    final cityName = _recommendedCity?['name'] as String? ?? '';
    final monuments = _recommendedMonuments;

    if (monuments.isEmpty) return SizedBox.shrink();

    final title = 'Monuments à $cityName';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/explore',
                  arguments: {'initialTab': 'activities'},
                );
              },
              child: Text(
                'Voir tout',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        SizedBox(
          height: 280,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: BouncingScrollPhysics(),
            itemCount: monuments.length,
            separatorBuilder: (_, __) => SizedBox(width: 12),
            itemBuilder: (context, index) {
              final monument = monuments[index];
              final image = (monument.imageUrl != null && monument.imageUrl!.isNotEmpty)
                  ? monument.imageUrl!
                  : ImageService.getMonumentImage(monument.nom);
              
              return InkWell(
                onTap: () => _openActivityDetails(monument),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 280,
                  height: 260,
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: _buildGenericSmartImage(
                          image,
                          280,
                          140,
                          colorScheme,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              monument.nom,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onSurface,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 14,
                                  color: colorScheme.primary,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  cityName,
                                  style: TextStyle(
                                    color: colorScheme.onSurface.withOpacity(0.7),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 6),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Monument historique',
                                style: TextStyle(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestedActivitiesSection(
    ColorScheme colorScheme,
    LocalizationService localizationService,
  ) {
    return _buildHorizontalCards(
      title: 'Recommended activities',
      items: _suggestedActivities
          .map((a) => {'title': a.name, 'subtitle': a.description, 'image': ''})
          .toList(),
      colorScheme: colorScheme,
    );
  }

  Widget _buildHorizontalCards({
    required String title,
    required List<Map<String, dynamic>> items,
    required ColorScheme colorScheme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: BouncingScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, __) => SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                width: 260,
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: _buildGenericSmartImage(
                        item['image'] as String?,
                        260,
                        120,
                        colorScheme,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title'] as String,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          SizedBox(height: 6),
                          if ((item['subtitle'] as String).isNotEmpty)
                            Text(
                              item['subtitle'] as String,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(
    LocalizationService localizationService,
    double screenWidth,
    bool isTablet,
    bool isDesktop,
    ColorScheme colorScheme,
  ) {
    final titleSize = isDesktop ? 28.0 : (isTablet ? 26.0 : 24.0);
    final subtitleSize = isDesktop ? 22.0 : (isTablet ? 21.0 : 20.0);
    final iconSize = isDesktop ? 32.0 : (isTablet ? 30.0 : 28.0);

    return Container(
      padding: EdgeInsets.all(isDesktop ? 20 : 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                localizationService.translate('home_title'),
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              NotificationIcon(
                onTap: _openNotificationsPage,
                size: iconSize,
                color: colorScheme.onSurface,
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            _guestMode.isGuestMode
                ? 'Welcome guest'
                : 'Welcome, ${_userDisplayName ?? 'User'}',
            style: TextStyle(
              fontSize: subtitleSize,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(
    LocalizationService localizationService,
    double screenWidth,
    bool isTablet,
    bool isDesktop,
    ColorScheme colorScheme,
  ) {
    final fontSize = isDesktop ? 16.0 : (isTablet ? 15.0 : 14.0);
    final iconSize = isDesktop ? 24.0 : (isTablet ? 22.0 : 20.0);

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: localizationService.translate('home_search_hint'),
          hintStyle: TextStyle(
            color: colorScheme.onSurface.withOpacity(0.6),
            fontSize: fontSize,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: colorScheme.onSurface.withOpacity(0.6),
            size: iconSize,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 20 : 16,
            vertical: isDesktop ? 16 : 12,
          ),
        ),
        onTap: () {
          // Ouvrir la page de recherche Explore pour réutiliser les suggestions et l’affichage
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SearchExplorePage(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection(
    String title,
    List<Map<String, dynamic>> items,
    Widget Function(Map<String, dynamic>) cardBuilder,
    double screenWidth,
    bool isTablet,
    bool isDesktop,
    ColorScheme colorScheme,
  ) {
    final titleSize = isDesktop ? 22.0 : (isTablet ? 21.0 : 20.0);
    final cardHeight = isDesktop ? 280.0 : (isTablet ? 260.0 : 250.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            0,
            isDesktop ? 20 : 16,
            0,
            isDesktop ? 12 : 8,
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        SizedBox(
          height: cardHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.only(left: isDesktop ? 4 : 0),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(right: isDesktop ? 20 : 16),
                child: cardBuilder(items[index]),
              );
            },
          ),
        ),
        SizedBox(height: isDesktop ? 20 : 16),
      ],
    );
  }

  Widget _buildRecommendationCard(
    Map<String, dynamic> recommendation,
    double screenWidth,
    bool isTablet,
    bool isDesktop,
    ColorScheme colorScheme,
  ) {
    final cardWidth = isDesktop ? 320.0 : (isTablet ? 300.0 : 280.0);
    final imageHeight = isDesktop ? 120.0 : (isTablet ? 100.0 : 80.0);
    final titleSize = isDesktop ? 18.0 : (isTablet ? 17.0 : 16.0);
    final subtitleSize = isDesktop ? 15.0 : (isTablet ? 14.5 : 14.0);

    return Container(
      width: cardWidth,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: imageHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              image: DecorationImage(
                image: NetworkImage(recommendation['image']),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(isDesktop ? 16 : 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recommendation['title'],
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    recommendation['subtitle'],
                    style: TextStyle(
                      fontSize: subtitleSize,
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _openActivityDetails(recommendation['activity']),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Voir détails',
                              style: TextStyle(
                                color: colorScheme.onPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      InkWell(
                        onTap: () => _shareActivity(recommendation),
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.share,
                            size: 16,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingDestinationCard(
    Map<String, dynamic> destination,
    LocalizationService localizationService,
    double screenWidth,
    bool isTablet,
    bool isDesktop,
    ColorScheme colorScheme,
  ) {
    final cardWidth = isDesktop ? 180.0 : (isTablet ? 170.0 : 160.0);
    final imageHeight = isDesktop ? 140.0 : (isTablet ? 130.0 : 120.0);
    final titleSize = isDesktop ? 16.0 : (isTablet ? 15.0 : 14.0);
    final subtitleSize = isDesktop ? 13.0 : (isTablet ? 12.5 : 12.0);

    return InkWell(
      onTap: () => _openRecommendedDestinationDetails(destination),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: cardWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: imageHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: NetworkImage(destination['image']),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 8,
                    right: 8,
                    child: InkWell(
                      onTap: () => _shareDestination(destination),
                      child: Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.share,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: subtitleSize,
                          ),
                          SizedBox(width: 4),
                          Text(
                            destination['rating'].toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: subtitleSize,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      destination['name'],
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      destination['subtitle'],
                      style: TextStyle(
                        fontSize: subtitleSize,
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _shareDestination(Map<String, dynamic> destination) {
    final name = destination['name'] ?? 'Destination';
    final subtitle = destination['subtitle'] ?? '';
    final type = 'ville';
    
    final shareText = '''
🌟 Découvrez cette magnifique $type : $name

$subtitle

Téléchargez l'application de tourisme pour découvrir plus de destinations incroyables ! 🚀

#Tourisme #Maroc #$name
''';

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Partager $name',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildShareOption(
                  icon: Icons.share,
                  label: 'Partager',
                  onTap: () {
                    Navigator.pop(context);
                    Share.share(shareText);
                  },
                ),
                _buildShareOption(
                  icon: Icons.message,
                  label: 'WhatsApp',
                  onTap: () {
                    Navigator.pop(context);
                    Share.share(shareText, subject: 'Découvrez $name');
                  },
                ),
                _buildShareOption(
                  icon: Icons.facebook,
                  label: 'Facebook',
                  onTap: () {
                    Navigator.pop(context);
                    Share.share(shareText, subject: 'Découvrez $name');
                  },
                ),
                _buildShareOption(
                  icon: Icons.email,
                  label: 'Email',
                  onTap: () {
                    Navigator.pop(context);
                    Share.share(shareText, subject: 'Découvrez $name');
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _shareActivity(Map<String, dynamic> activity) {
    final name = activity['title'] ?? 'Activité';
    final subtitle = activity['subtitle'] ?? '';
    final type = 'activité';
    
    final shareText = '''
🌟 Découvrez cette magnifique $type : $name

$subtitle

Téléchargez l'application de tourisme pour découvrir plus d'activités incroyables ! 🚀

#Tourisme #Maroc #$name
''';

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Partager $name',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildShareOption(
                  icon: Icons.share,
                  label: 'Partager',
                  onTap: () {
                    Navigator.pop(context);
                    Share.share(shareText);
                  },
                ),
                _buildShareOption(
                  icon: Icons.message,
                  label: 'WhatsApp',
                  onTap: () {
                    Navigator.pop(context);
                    Share.share(shareText, subject: 'Découvrez $name');
                  },
                ),
                _buildShareOption(
                  icon: Icons.facebook,
                  label: 'Facebook',
                  onTap: () {
                    Navigator.pop(context);
                    Share.share(shareText, subject: 'Découvrez $name');
                  },
                ),
                _buildShareOption(
                  icon: Icons.email,
                  label: 'Email',
                  onTap: () {
                    Navigator.pop(context);
                    Share.share(shareText, subject: 'Découvrez $name');
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 32,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

}
