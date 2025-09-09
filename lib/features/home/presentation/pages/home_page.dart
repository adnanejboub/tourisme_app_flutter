import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  String? _userDisplayName;

  // New user suggestions
  rec.Destination? _suggestedDestination;
  List<rec.Activity> _suggestedActivities = [];

  // Notification drawer
  bool _showNotificationDrawer = false;

  bool _isMonumentActivity(ActivityModel activity) {
    final category = (activity.categorie ?? '').toLowerCase();
    final name = activity.nom.toLowerCase();
    return category.contains('monument') ||
        category.contains('culture') ||
        category.contains('historique') ||
        category.contains('patrimoine') ||
        category.contains('mosquée') ||
        category.contains('palais') ||
        category.contains('médina') ||
        name.contains('mosquée') ||
        name.contains('quartier des habous') ||
        name.contains('médina') ||
        name.contains('kasbah');
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

  Future<void> _bootstrap() async {
    try {
      // Detect mode (guest or authenticated/new user) and populate data accordingly
      await _guestMode.loadGuestModeState();

      if (_guestMode.isGuestMode) {
        await _loadGuestData();
      } else {
        await _loadAuthenticatedUserName();
        final shouldShowPrefs =
            await NewUserService.shouldShowPreferencesQuestionnaire();
        final hasCompleted = await NewUserService.hasCompletedPreferences();
        if (hasCompleted && !shouldShowPrefs) {
          await _loadNewUserSuggestions();
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

      final cityActivities = match == null
          ? <ActivityModel>[]
          : activities
                .where(
                  (a) =>
                      (a.ville ?? '').toLowerCase() == match!.nom.toLowerCase(),
                )
                .toList();

      if (mounted) {
        setState(() {
          _locationInfo = location;
          _guestCity = match;
          _guestCityActivities = cityActivities.take(6).toList();
        });
      }
    } catch (_) {}
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

        // Seasonal Highlights -> monuments of guest city
        final List<Map<String, dynamic>> seasonalHighlights = (() {
          final monuments = _guestCityActivities.where(_isMonumentActivity).toList();
          return monuments.map((m) {
            final img = (m.imageUrl != null && m.imageUrl!.isNotEmpty)
                ? m.imageUrl!
                : ImageService.getActivityImage(m.categorie, m.nom);
            return {
              'title': m.nom,
              'subtitle': (m.description ?? ''),
              'image': img,
            };
          }).toList();
        })();

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
                      
                      if (_guestMode.isGuestMode && _guestCity != null) ...[
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
                      if (!_guestMode.isGuestMode &&
                          _suggestedDestination != null) ...[
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
                      _buildSection(
                        localizationService.translate('home_seasonal_title'),
                        seasonalHighlights,
                        (item) => _buildSeasonalHighlightCard(
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
                // Naviguer vers la page des activités
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
          height: 260,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
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
                          150,
                          colorScheme,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activity.nom,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onSurface,
                                fontSize: 16,
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
                            SizedBox(height: 8),
                            if ((activity.categorie ?? '').isNotEmpty)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  activity.categorie!,
                                  style: TextStyle(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
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
    // Filter activities that are monuments or cultural sites
    final monuments = _guestCityActivities.where(_isMonumentActivity).toList();

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
                // Naviguer vers la page des monuments
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
          height: 240,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: monuments.length,
            separatorBuilder: (_, __) => SizedBox(width: 12),
            itemBuilder: (context, index) {
              final monument = monuments[index];
              final image =
                  (monument.imageUrl != null && monument.imageUrl!.isNotEmpty)
                  ? monument.imageUrl!
                  : ImageService.getActivityImage(
                      monument.categorie,
                      monument.nom,
                    );
              return InkWell(
                onTap: () => _openActivityDetails(monument),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 280,
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
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              monument.nom,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onSurface,
                                fontSize: 16,
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
                            SizedBox(height: 8),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Monument historique',
                                style: TextStyle(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
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

    return Container(
      width: cardWidth,
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
    );
  }

  Widget _buildSeasonalHighlightCard(
    Map<String, dynamic> highlight,
    double screenWidth,
    bool isTablet,
    bool isDesktop,
    ColorScheme colorScheme,
  ) {
    final cardWidth = isDesktop ? 240.0 : (isTablet ? 220.0 : 200.0);
    final titleSize = isDesktop ? 18.0 : (isTablet ? 17.0 : 16.0);
    final subtitleSize = isDesktop ? 13.0 : (isTablet ? 12.5 : 12.0);

    return Container(
      width: cardWidth,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: NetworkImage(highlight['image']),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(isDesktop ? 16 : 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                highlight['title'],
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4),
              Text(
                highlight['subtitle'],
                style: TextStyle(
                  fontSize: subtitleSize,
                  color: Colors.white.withOpacity(0.9),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
