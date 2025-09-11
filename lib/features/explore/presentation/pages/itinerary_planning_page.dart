import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../core/constants/constants.dart';
import '../../../saved/data/models/trip_model.dart';
import '../../../saved/data/services/trip_service.dart';
import '../../../saved/presentation/pages/create_edit_trip_page.dart';
import '../../../saved/data/services/wishlist_service.dart';
import '../../data/services/public_api_service.dart';
import '../../data/models/city_dto.dart';
import '../../../auth/data/datasources/auth_remote_data_source.dart';
import '../../../../core/services/guest_mode_service.dart';
import '../../../saved/data/services/planning_database_service.dart';
import '../../../saved/data/models/planning_journalier_model.dart';
import '../../../saved/data/models/planning_activite_model.dart';
import '../../../saved/presentation/pages/daily_planning_page.dart';
import 'itinerary_builder_page.dart';

class ItineraryPlanningPage extends StatefulWidget {
  final Map<String, dynamic>? destination;

  const ItineraryPlanningPage({super.key, this.destination});

  @override
  State<ItineraryPlanningPage> createState() => _ItineraryPlanningPageState();
}

class _ItineraryPlanningPageState extends State<ItineraryPlanningPage> {
  int _selectedDays = 3;
  String _selectedBudget = 'mid_range';
  List<String> _selectedActivities = [];
  DateTime _startDate = DateTime.now().add(const Duration(days: 7));
  bool _isGenerating = false;
  Map<String, dynamic>? _cityData;
  double _estimatedBudget = 0.0;
  final GuestModeService _guestMode = GuestModeService();
  final AuthRemoteDataSourceImpl _authService = AuthRemoteDataSourceImpl();
  final PlanningDatabaseService _planningDbService = PlanningDatabaseService();

  final List<Map<String, dynamic>> _availableActivities = [
    {
      'id': 'sightseeing',
      'name': 'Sightseeing',
      'icon': Icons.visibility,
      'duration': '2-4 hours',
      'description': 'Visit famous landmarks and attractions',
    },
    {
      'id': 'food_tour',
      'name': 'Food Tour',
      'icon': Icons.restaurant,
      'duration': '3-4 hours',
      'description': 'Explore local cuisine and traditional dishes',
    },
    {
      'id': 'shopping',
      'name': 'Shopping',
      'icon': Icons.shopping_bag,
      'duration': '2-3 hours',
      'description': 'Visit markets, souks and shopping districts',
    },
    {
      'id': 'cultural_visit',
      'name': 'Cultural Visit',
      'icon': Icons.museum,
      'duration': '1-2 hours',
      'description': 'Explore museums, historical sites and cultural centers',
    },
    {
      'id': 'adventure',
      'name': 'Adventure',
      'icon': Icons.directions_bike,
      'duration': '4-6 hours',
      'description': 'Outdoor activities and adventure sports',
    },
    {
      'id': 'relaxation',
      'name': 'Relaxation',
      'icon': Icons.spa,
      'duration': '2-3 hours',
      'description': 'Wellness activities and relaxation spots',
    },
  ];

  final Map<String, Map<String, dynamic>> _budgetRanges = {
    'budget': {
      'name': 'Budget',
      'range': '300-800 MAD/day',
      'description': 'Affordable options, hostels, local restaurants',
      'icon': Icons.account_balance_wallet,
    },
    'mid_range': {
      'name': 'Mid-Range',
      'range': '800-1500 MAD/day',
      'description': 'Comfortable hotels, good restaurants, guided tours',
      'icon': Icons.star,
    },
    'luxury': {
      'name': 'Luxury',
      'range': '1500+ MAD/day',
      'description': 'Premium hotels, fine dining, private guides',
      'icon': Icons.diamond,
    },
  };

  @override
  void initState() {
    super.initState();
    _loadCityData();
    _calculateBudget();
  }

  Future<void> _loadCityData() async {
    if (widget.destination != null) {
      try {
        // Récupérer les données complètes de la ville depuis l'API
        final publicApi = PublicApiService();
        final cities = await publicApi.getAllCities();
        final cityName =
            widget.destination!['name'] ?? widget.destination!['title'] ?? '';

        CityDto? matchingCity;
        try {
          matchingCity = cities.firstWhere(
            (city) => city.nom.toLowerCase() == cityName.toLowerCase(),
          );
        } catch (e) {
          matchingCity = null;
        }

        if (matchingCity != null) {
          setState(() {
            _cityData = {
              'name': matchingCity!.nom,
              'description': matchingCity!.description ?? 'Découvrez cette magnifique ville',
              'image': matchingCity!.imageUrl ?? '',
              'rating': 4.5, // Rating par défaut
              'country': matchingCity!.paysNom ?? 'Maroc',
            };
          });
        }
      } catch (e) {
        // En cas d'erreur, utiliser les données de destination
        setState(() {
          _cityData = widget.destination;
        });
      }
    }
  }

  void _calculateBudget() {
    // Calculer le budget estimé basé sur les activités sélectionnées
    double baseBudget = 0.0;

    // Budget de base selon la catégorie
    switch (_selectedBudget) {
      case 'budget':
        baseBudget = 500.0; // 500 MAD par jour
        break;
      case 'mid_range':
        baseBudget = 1000.0; // 1000 MAD par jour
        break;
      case 'luxury':
        baseBudget = 2000.0; // 2000 MAD par jour
        break;
    }

    // Ajouter le coût des activités
    for (String activity in _selectedActivities) {
      switch (activity) {
        case 'sightseeing':
          baseBudget += 200.0;
          break;
        case 'food_tour':
          baseBudget += 300.0;
          break;
        case 'shopping':
          baseBudget += 400.0;
          break;
        case 'cultural_visit':
          baseBudget += 150.0;
          break;
        case 'adventure':
          baseBudget += 500.0;
          break;
        case 'relaxation':
          baseBudget += 250.0;
          break;
      }
    }

    setState(() {
      _estimatedBudget = baseBudget * _selectedDays;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final localizationService = Provider.of<LocalizationService>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 900;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onBackground),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Plan Your Trip to ${widget.destination?['name'] ?? 'Morocco'}',
          style: TextStyle(
            color: colorScheme.onBackground,
            fontWeight: FontWeight.bold,
            fontSize: isDesktop ? 22 : (isTablet ? 20 : 18),
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
        padding: EdgeInsets.all(isDesktop ? 24 : (isTablet ? 20 : 16)),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildDestinationInfo(
                  colorScheme,
                  localizationService,
                  isTablet,
                  isDesktop,
                ),
            SizedBox(height: isDesktop ? 40 : 32),
                _buildTripDurationSection(
                  colorScheme,
                  localizationService,
                  isTablet,
                  isDesktop,
                ),
            SizedBox(height: isDesktop ? 40 : 32),
                _buildBudgetSection(
                  colorScheme,
                  localizationService,
                  isTablet,
                  isDesktop,
                ),
            SizedBox(height: isDesktop ? 40 : 32),
                _buildBudgetTracker(
                  colorScheme,
                  localizationService,
                  isTablet,
                  isDesktop,
                ),
            SizedBox(height: isDesktop ? 40 : 32),
                _buildStartDateSection(
                  colorScheme,
                  localizationService,
                  isTablet,
                  isDesktop,
                ),
            SizedBox(height: isDesktop ? 40 : 32),
                _buildActivitiesSection(
                  colorScheme,
                  localizationService,
                  isTablet,
                  isDesktop,
                ),
                SizedBox(height: isDesktop ? 40 : 32),
                _buildActionButton(
                  colorScheme,
                  localizationService,
                  isTablet,
                  isDesktop,
                ),
            SizedBox(height: 20),
              ]),
        ),
          ),
        ],
      ),
    );
  }

  Widget _buildDestinationInfo(
    ColorScheme colorScheme,
    LocalizationService localizationService,
    bool isTablet,
    bool isDesktop,
  ) {
    final destination = _cityData ?? widget.destination;
    if (destination == null) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : (isTablet ? 20 : 16)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withOpacity(0.1),
            colorScheme.primary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _buildSmartImage(
              imageUrl: destination['image'] ?? destination['imageUrl'] ?? '',
              width: isDesktop ? 80 : (isTablet ? 70 : 60),
              height: isDesktop ? 80 : (isTablet ? 70 : 60),
              colorScheme: colorScheme,
            ),
          ),
          SizedBox(width: isDesktop ? 24 : (isTablet ? 20 : 16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  destination['name'] as String? ?? 'Unknown Destination',
                  style: TextStyle(
                    fontSize: isDesktop ? 24 : (isTablet ? 22 : 18),
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  destination['description'] as String? ??
                      'Discover the beauty and culture of this amazing destination',
                  style: TextStyle(
                    fontSize: isDesktop ? 16 : (isTablet ? 15 : 14),
                    color: colorScheme.onSurface.withOpacity(0.7),
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: isDesktop ? 20 : 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      '${destination['rating'] ?? 4.5}/5',
                      style: TextStyle(
                        fontSize: isDesktop ? 16 : 14,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(width: 16),
                    Icon(
                      Icons.location_on,
                      color: colorScheme.primary,
                      size: isDesktop ? 20 : 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      destination['tags']?.join(', ') ?? 'Morocco',
                      style: TextStyle(
                        fontSize: isDesktop ? 16 : 14,
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripDurationSection(
    ColorScheme colorScheme,
    LocalizationService localizationService,
    bool isTablet,
    bool isDesktop,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trip Duration',
          style: TextStyle(
            fontSize: isDesktop ? 22 : (isTablet ? 20 : 18),
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'How many days do you want to spend in ${widget.destination?['name'] ?? 'Morocco'}?',
          style: TextStyle(
            fontSize: isDesktop ? 16 : 14,
            color: colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        SizedBox(height: isDesktop ? 24 : 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: isDesktop ? 4 : (isTablet ? 4 : 2),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: isDesktop ? 1.5 : 1.2,
          children: [
            _buildDurationOption(
              1,
              '1 Day',
              'Quick visit',
              colorScheme,
              isTablet,
              isDesktop,
            ),
            _buildDurationOption(
              2,
              '2 Days',
              'Weekend trip',
              colorScheme,
              isTablet,
              isDesktop,
            ),
            _buildDurationOption(
              3,
              '3 Days',
              'Short break',
              colorScheme,
              isTablet,
              isDesktop,
            ),
            _buildDurationOption(
              5,
              '5 Days',
              'Extended stay',
              colorScheme,
              isTablet,
              isDesktop,
            ),
            _buildDurationOption(
              7,
              '1 Week',
              'Full week',
              colorScheme,
              isTablet,
              isDesktop,
            ),
            _buildDurationOption(
              10,
              '10 Days',
              'Long vacation',
              colorScheme,
              isTablet,
              isDesktop,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDurationOption(
    int days,
    String label,
    String subtitle,
    ColorScheme colorScheme,
    bool isTablet,
    bool isDesktop,
  ) {
    final isSelected = _selectedDays == days;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedDays = days;
          _calculateBudget();
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(isDesktop ? 16 : 12),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outline.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected 
                ? colorScheme.primary.withOpacity(0.3)
                : colorScheme.shadow.withOpacity(0.1),
              blurRadius: isSelected ? 8 : 4,
              offset: Offset(0, isSelected ? 4 : 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: isDesktop ? 18 : (isTablet ? 16 : 14),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: isSelected
                    ? colorScheme.onPrimary.withOpacity(0.8)
                    : colorScheme.onSurface.withOpacity(0.6),
                fontSize: isDesktop ? 14 : 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetSection(
    ColorScheme colorScheme,
    LocalizationService localizationService,
    bool isTablet,
    bool isDesktop,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Budget Range',
          style: TextStyle(
            fontSize: isDesktop ? 22 : (isTablet ? 20 : 18),
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Select your preferred budget range for this trip',
          style: TextStyle(
            fontSize: isDesktop ? 16 : 14,
            color: colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        SizedBox(height: isDesktop ? 24 : 16),
        Column(
          children: _budgetRanges.entries.map((entry) {
            final budget = entry.key;
            final budgetInfo = entry.value;
            final isSelected = _selectedBudget == budget;
            
            return Container(
              margin: EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedBudget = budget;
                    _calculateBudget();
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: EdgeInsets.all(isDesktop ? 20 : 16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.outline.withOpacity(0.3),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected 
                          ? colorScheme.primary.withOpacity(0.2)
                          : colorScheme.shadow.withOpacity(0.05),
                        blurRadius: isSelected ? 8 : 4,
                        offset: Offset(0, isSelected ? 4 : 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected 
                            ? colorScheme.onPrimary.withOpacity(0.2)
                            : colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          budgetInfo['icon'] as IconData,
                          color: isSelected
                              ? colorScheme.onPrimary
                              : colorScheme.primary,
                          size: isDesktop ? 28 : 24,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              budgetInfo['name'] as String,
                              style: TextStyle(
                                color: isSelected
                                    ? colorScheme.onPrimary
                                    : colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                                fontSize: isDesktop ? 18 : 16,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              budgetInfo['range'] as String,
                              style: TextStyle(
                                color: isSelected
                                    ? colorScheme.onPrimary.withOpacity(0.9)
                                    : colorScheme.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: isDesktop ? 16 : 14,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              budgetInfo['description'] as String,
                              style: TextStyle(
                                color: isSelected
                                    ? colorScheme.onPrimary.withOpacity(0.8)
                                    : colorScheme.onSurface.withOpacity(0.7),
                                fontSize: isDesktop ? 14 : 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle,
                          color: colorScheme.onPrimary,
                          size: isDesktop ? 28 : 24,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStartDateSection(
    ColorScheme colorScheme,
    LocalizationService localizationService,
    bool isTablet,
    bool isDesktop,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Start Date',
          style: TextStyle(
            fontSize: isDesktop ? 22 : (isTablet ? 20 : 18),
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'When would you like to start your trip?',
          style: TextStyle(
            fontSize: isDesktop ? 16 : 14,
            color: colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        SizedBox(height: isDesktop ? 24 : 16),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _startDate,
              firstDate: DateTime.now().add(const Duration(days: 1)),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: colorScheme,
                    dialogBackgroundColor: colorScheme.surface,
                  ),
                  child: child!,
                );
              },
            );
            if (date != null) {
              setState(() {
                _startDate = date;
              });
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsets.all(isDesktop ? 24 : 20),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.primary.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.calendar_today,
                    color: colorScheme.primary,
                    size: isDesktop ? 28 : 24,
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected Date',
                        style: TextStyle(
                          fontSize: isDesktop ? 16 : 14,
                          color: colorScheme.onSurface.withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        DateFormat('EEEE, MMMM dd, yyyy').format(_startDate),
                        style: TextStyle(
                          fontSize: isDesktop ? 20 : 18,
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${_startDate.difference(DateTime.now()).inDays} days from now',
                        style: TextStyle(
                          fontSize: isDesktop ? 16 : 14,
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.edit_calendar,
                  color: colorScheme.primary,
                  size: isDesktop ? 28 : 24,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivitiesSection(
    ColorScheme colorScheme,
    LocalizationService localizationService,
    bool isTablet,
    bool isDesktop,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Activities & Interests',
          style: TextStyle(
            fontSize: isDesktop ? 22 : (isTablet ? 20 : 18),
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Select the activities that interest you most (select at least 2)',
          style: TextStyle(
            fontSize: isDesktop ? 16 : 14,
            color: colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        SizedBox(height: isDesktop ? 24 : 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isDesktop ? 3 : (isTablet ? 2 : 2),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: isDesktop ? 1.1 : 1.0,
          ),
          itemCount: _availableActivities.length,
          itemBuilder: (context, index) {
            final activity = _availableActivities[index];
            final isSelected = _selectedActivities.contains(
              activity['id'] as String,
            );

            return InkWell(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedActivities.remove(activity['id']);
                  } else {
                    _selectedActivities.add(activity['id'] as String);
                  }
                  _calculateBudget();
                });
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? colorScheme.primary : colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.outline.withOpacity(0.3),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected 
                        ? colorScheme.primary.withOpacity(0.2)
                        : colorScheme.shadow.withOpacity(0.1),
                      blurRadius: isSelected ? 8 : 4,
                      offset: Offset(0, isSelected ? 4 : 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected 
                          ? colorScheme.onPrimary.withOpacity(0.2)
                          : colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        activity['icon'] as IconData,
                        color: isSelected
                            ? colorScheme.onPrimary
                            : colorScheme.primary,
                        size: isDesktop ? 32 : 28,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      activity['name'] as String,
                      style: TextStyle(
                        color: isSelected
                            ? colorScheme.onPrimary
                            : colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: isDesktop ? 16 : 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 6),
                    Text(
                      activity['duration'] as String,
                      style: TextStyle(
                        color: isSelected
                            ? colorScheme.onPrimary.withOpacity(0.8)
                            : colorScheme.onSurface.withOpacity(0.7),
                        fontSize: isDesktop ? 14 : 12,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4),
                    Text(
                      activity['description'] as String,
                      style: TextStyle(
                        color: isSelected
                            ? colorScheme.onPrimary.withOpacity(0.7)
                            : colorScheme.onSurface.withOpacity(0.6),
                        fontSize: isDesktop ? 12 : 10,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButton(
    ColorScheme colorScheme,
    LocalizationService localizationService,
    bool isTablet,
    bool isDesktop,
  ) {
    final canCreateTrip = _selectedActivities.length >= 2 && !_isGenerating;
    
    return Container(
      width: double.infinity,
      height: isDesktop ? 64 : 56,
      child: ElevatedButton(
        onPressed: canCreateTrip ? _createTrip : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: canCreateTrip
              ? colorScheme.primary
              : colorScheme.onSurface.withOpacity(0.3),
          foregroundColor: canCreateTrip
              ? colorScheme.onPrimary
              : colorScheme.onSurface.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: canCreateTrip ? 4 : 0,
        ),
        child: _isGenerating
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: isDesktop ? 24 : 20,
                    height: isDesktop ? 24 : 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Text(
                    'Creating Trip...',
                    style: TextStyle(
                      fontSize: isDesktop ? 18 : 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_location_alt, size: isDesktop ? 28 : 24),
                  SizedBox(width: 12),
                  Text(
                    'Create Trip',
                    style: TextStyle(
                      fontSize: isDesktop ? 18 : 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _createTrip() async {
    // Vérifier l'authentification
    await _guestMode.loadGuestModeState();
    if (_guestMode.isGuestMode) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vous devez être connecté pour planifier un voyage'),
          backgroundColor: Colors.orange,
          action: SnackBarAction(
            label: 'Se connecter',
            textColor: Colors.white,
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
          ),
        ),
      );
      return;
    }

    if (_selectedActivities.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veuillez sélectionner au moins 2 activités pour créer un voyage'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    try {
      // Calculate end date based on selected days
      final endDate = _startDate.add(Duration(days: _selectedDays - 1));
      
      // Create trip name based on destination and activities
      final destinationName = widget.destination?['name'] ?? 'Morocco';
      final tripName = '${destinationName} Adventure';
      
      // Convert selected activities to TripActivity objects
      final List<TripActivity> tripActivities = _selectedActivities.map((
        activityId,
      ) {
        final activity = _availableActivities.firstWhere(
          (a) => a['id'] == activityId,
        );
        return TripActivity(
          id:
              DateTime.now().millisecondsSinceEpoch.toString() +
              '_${activityId}',
          name: activity['name'],
          type: 'attraction',
          description: activity['description'],
          duration: _parseDurationToMinutes(activity['duration']),
        );
      }).toList();

      // Create the trip
      final trip = TripModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: tripName,
        destination: destinationName,
        startDate: _startDate,
        endDate: endDate,
        activities: tripActivities,
        notes:
            'Budget: ${_budgetRanges[_selectedBudget]?['name']} (${_budgetRanges[_selectedBudget]?['range']})',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save trip to service
      final tripService = TripService();
      await tripService.saveTrip(trip);

      // Créer les plannings journaliers pour chaque jour
      final List<PlanningJournalierModel> dailyPlannings = [];
      final List<PlanningActiviteModel> planningActivites = [];
      
      for (int i = 0; i < _selectedDays; i++) {
        final currentDate = _startDate.add(Duration(days: i));
        final dailyPlanning = PlanningJournalierModel(
          datePlanning: currentDate,
          description: 'Jour ${i + 1} - ${destinationName}',
          duree: _calculateDailyDuration(),
          statut: 'planifie',
        );
        dailyPlannings.add(dailyPlanning);
      }

      // Créer les activités de planning
      for (int i = 0; i < _selectedDays; i++) {
        final currentDate = _startDate.add(Duration(days: i));
        final activitiesForDay = _selectedActivities.take(2).toList(); // 2 activités par jour max
        
        for (final activityId in activitiesForDay) {
          final activity = _availableActivities.firstWhere((a) => a['id'] == activityId);
          final planningActivite = PlanningActiviteModel(
            idPlanning: 0, // Sera mis à jour après sauvegarde du planning journalier
            idActivite: DateTime.now().millisecondsSinceEpoch + i,
            nomActivite: activity['name'],
            description: activity['description'],
            prix: _getActivityPrice(activityId),
            dureeMinimun: _parseDurationToMinutes(activity['duration']) ?? 60,
            dureeMaximun: (_parseDurationToMinutes(activity['duration']) ?? 60) + 30,
            saison: 'Toute l\'année',
            niveauDificulta: 'Facile',
            categorie: _getActivityCategory(activityId),
            ville: destinationName,
            imageUrl: _cityData?['image'] ?? widget.destination?['image'] ?? '',
            dateActivite: currentDate,
            statut: 'planifie',
          );
          planningActivites.add(planningActivite);
        }
      }

      // Sauvegarder dans la base de données
      try {
        await _planningDbService.saveCompleteTrip(
          trip: trip,
          planningJournalier: dailyPlannings,
          planningActivites: planningActivites,
        );
      } catch (e) {
        print('Erreur lors de la sauvegarde en base: $e');
        // Continuer même si la sauvegarde en base échoue
      }

      // Ajouter le trip à la wishlist
      await WishlistService.saveSnapshot(
        type: 'trip',
        itemId: int.parse(trip.id),
        data: {
          'id': trip.id,
          'name': trip.name,
          'destination': trip.destination,
          'startDate': trip.startDate.toIso8601String(),
          'endDate': trip.endDate.toIso8601String(),
          'budget': _estimatedBudget,
          'activities': tripActivities
              .map(
                (a) => {
                  'name': a.name,
                  'description': a.description,
                  'duration': a.duration,
                },
              )
              .toList(),
          'image': _cityData?['image'] ?? widget.destination?['image'] ?? '',
        },
      );

      // Ajouter à la wishlist locale
      await WishlistService.addLocalId('trip', int.parse(trip.id));

      setState(() {
        _isGenerating = false;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Voyage créé avec succès !'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'Voir le planning',
            textColor: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DailyPlanningPage(
                    tripId: int.parse(trip.id),
                    tripName: trip.name,
                    startDate: trip.startDate,
                    endDate: trip.endDate,
                  ),
                ),
              );
            },
          ),
        ),
      );

      // Navigate to the itinerary builder page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ItineraryBuilderPage(
            destination: widget.destination,
            existingTrip: trip,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _isGenerating = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating trip: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  int? _parseDurationToMinutes(String duration) {
    // Parse duration strings like "2-4 hours", "3-4 hours", etc.
    final regex = RegExp(r'(\d+)-?(\d+)?\s*hours?');
    final match = regex.firstMatch(duration);
    if (match != null) {
      final minHours = int.tryParse(match.group(1) ?? '0') ?? 0;
      final maxHours =
          int.tryParse(match.group(2) ?? match.group(1) ?? '0') ?? minHours;
      // Return average duration in minutes
      return ((minHours + maxHours) / 2 * 60).round();
    }
    return null;
  }

  Widget _buildBudgetTracker(
    ColorScheme colorScheme,
    LocalizationService localizationService,
    bool isTablet,
    bool isDesktop,
  ) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 20 : 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet,
                color: colorScheme.primary,
                size: 24,
              ),
              SizedBox(width: 12),
              Text(
                'Budget Estimé',
                style: TextStyle(
                  fontSize: isDesktop ? 20 : 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total estimé',
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    Text(
                      '${_estimatedBudget.toStringAsFixed(0)} MAD',
                      style: TextStyle(
                        fontSize: isDesktop ? 28 : 24,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${_selectedDays} jours',
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    Text(
                      '${(_estimatedBudget / _selectedDays).toStringAsFixed(0)} MAD/jour',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 12),
          LinearProgressIndicator(
            value: _getBudgetProgress(),
            backgroundColor: colorScheme.outline.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            minHeight: 8,
          ),
          SizedBox(height: 8),
          Text(
            _getBudgetStatus(),
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  double _getBudgetProgress() {
    // Calculer le pourcentage du budget utilisé (exemple avec un budget max de 5000 MAD)
    const double maxBudget = 5000.0;
    return (_estimatedBudget / maxBudget).clamp(0.0, 1.0);
  }

  String _getBudgetStatus() {
    if (_estimatedBudget < 1000) {
      return 'Budget économique';
    } else if (_estimatedBudget < 3000) {
      return 'Budget modéré';
    } else {
      return 'Budget élevé';
    }
  }

  Widget _buildSmartImage({
    required String imageUrl,
    required double width,
    required double height,
    required ColorScheme colorScheme,
  }) {
    if (imageUrl.isEmpty) {
      return Container(
        width: width,
        height: height,
        color: colorScheme.surfaceVariant,
        child: Icon(
          Icons.image,
          color: colorScheme.onSurfaceVariant,
          size: width * 0.4,
        ),
      );
    }

    // Vérifier si c'est une image locale (assets)
    if (imageUrl.startsWith('assets/') || imageUrl.startsWith('images/')) {
      final assetPath = imageUrl.startsWith('images/')
          ? 'assets/$imageUrl'
          : imageUrl;
      return Image.asset(
        assetPath,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            color: colorScheme.surfaceVariant,
            child: Icon(
              Icons.image,
              color: colorScheme.onSurfaceVariant,
              size: width * 0.4,
            ),
          );
        },
      );
    } else {
      // Image réseau
      return Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            color: colorScheme.surfaceVariant,
            child: Icon(
              Icons.image,
              color: colorScheme.onSurfaceVariant,
              size: width * 0.4,
            ),
          );
        },
      );
    }
  }

  int _calculateDailyDuration() {
    // Calculer la durée totale des activités sélectionnées par jour
    int totalDuration = 0;
    for (String activityId in _selectedActivities) {
      final activity = _availableActivities.firstWhere((a) => a['id'] == activityId);
      final duration = _parseDurationToMinutes(activity['duration']) ?? 60;
      totalDuration += duration;
    }
    return totalDuration;
  }

  double _getActivityPrice(String activityId) {
    // Prix par défaut selon le type d'activité
    switch (activityId) {
      case 'sightseeing':
        return 200.0;
      case 'food_tour':
        return 300.0;
      case 'shopping':
        return 400.0;
      case 'cultural_visit':
        return 150.0;
      case 'adventure':
        return 500.0;
      case 'relaxation':
        return 250.0;
      default:
        return 200.0;
    }
  }

  String _getActivityCategory(String activityId) {
    // Catégorie selon le type d'activité
    switch (activityId) {
      case 'sightseeing':
        return 'TOURS';
      case 'food_tour':
        return 'EVENEMENTS';
      case 'shopping':
        return 'TOURS';
      case 'cultural_visit':
        return 'MONUMENT';
      case 'adventure':
        return 'TOURS';
      case 'relaxation':
        return 'EVENEMENTS';
      default:
        return 'TOURS';
    }
  }
}
