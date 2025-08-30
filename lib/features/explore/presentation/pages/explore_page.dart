import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../core/constants/constants.dart';
import 'details_explore.dart';
import 'search_explore_page.dart';
import 'filter_explore_page.dart';
import 'events_explore_page.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({Key? key}) : super(key: key);

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  String _selectedCategory = 'cities';
  Map<String, dynamic>? _currentFilters;

  final List<Map<String, dynamic>> _popularCities = [
    {
      'id': 1,
      'name': 'Marrakech',
      'arabicName': 'مراكش',
      'description': 'The Red City, known for its vibrant souks, and historic palaces.',
      'image': 'https://images.unsplash.com/photo-1517685352821-92cf88aee5a5',
    },
    {
      'id': 2,
      'name': 'Fes',
      'arabicName': 'فاس',
      'description': 'Home to the world\'s oldest university and a labyrinthine medina.',
      'image': 'https://images.unsplash.com/photo-1570191913384-b786dde7d9b4',
    },
    {
      'id': 3,
      'name': 'Chefchaouen',
      'arabicName': 'شفشاون',
      'description': 'The famous Blue Pearl of Morocco, nestled in the Rif Mountains.',
      'image': 'https://images.unsplash.com/photo-1590736969955-71cc94901144',
    },
  ];

  final List<Map<String, dynamic>> _recommendedActivities = [
    {
      'id': 1,
      'title': 'Sahara Desert Safari',
      'location': 'Marrakech',
      'image': 'https://images.unsplash.com/photo-1591414646028-7b60c18c6f14',
    },
    {
      'id': 2,
      'title': 'Marrakech Medina Tour',
      'location': 'Marrakech',
      'image': 'https://images.unsplash.com/photo-1517685352821-92cf88aee5a5',
    },
    {
      'id': 3,
      'title': 'Moroccan Cooking Class',
      'location': 'Fes',
      'image': 'https://images.unsplash.com/photo-1570191913384-b786dde7d9b4',
    },
  ];

  final List<Map<String, dynamic>> _upcomingEvents = [
    {
      'id': 1,
      'title': 'Cinema World Music Festival',
      'date': 'June 10-15',
      'location': 'Essaouira',
      'image': 'https://images.unsplash.com/photo-1591414646028-7b60c18c6f14',
    },
    {
      'id': 2,
      'title': 'Rose Festival',
      'date': 'May 10-12',
      'location': 'Kelaat M\'Gouna',
      'image': 'https://images.unsplash.com/photo-1517685352821-92cf88aee5a5',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Consumer<LocalizationService>(
      builder: (context, localizationService, child) {
        return Scaffold(
          backgroundColor: colorScheme.background,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(colorScheme, localizationService),
                _buildSearchBar(colorScheme, localizationService),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 24),
                        _buildCategoriesSection(colorScheme, localizationService),
                        SizedBox(height: 32),
                        _buildPopularCitiesSection(colorScheme, localizationService),
                        SizedBox(height: 32),
                        _buildRecommendedActivitiesSection(colorScheme, localizationService),
                        SizedBox(height: 32),
                        _buildUpcomingEventsSection(colorScheme, localizationService),
                        SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(ColorScheme colorScheme, LocalizationService localizationService) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: colorScheme.onBackground),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              localizationService.translate('explore_morocco'),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onBackground,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: Icon(Icons.filter_list, color: colorScheme.onBackground),
            onPressed: () => _openFilters(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ColorScheme colorScheme, LocalizationService localizationService) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.onSurface.withOpacity(0.1)),
      ),
      child: InkWell(
        onTap: () => _openSearch(),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Icon(Icons.search, color: colorScheme.onSurface.withOpacity(0.6)),
              SizedBox(width: 12),
              Text(
                localizationService.translate('search_cities_activities'),
                style: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesSection(ColorScheme colorScheme, LocalizationService localizationService) {
    final categories = [
      {'id': 'cities', 'name': localizationService.translate('cities'), 'icon': Icons.location_city},
      {'id': 'culture', 'name': localizationService.translate('culture'), 'icon': Icons.book},
      {'id': 'nature', 'name': localizationService.translate('nature'), 'icon': Icons.landscape},
      {'id': 'adventure', 'name': localizationService.translate('adventure'), 'icon': Icons.directions_bike},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizationService.translate('categories'),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colorScheme.onBackground,
          ),
        ),
        SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: categories.map((category) {
              final isSelected = _selectedCategory == category['id'];
              return Container(
                margin: EdgeInsets.only(right: 12),
                child: FilterChip(
                  avatar: Icon(
                    category['icon'] as IconData,
                    color: isSelected ? Colors.white : colorScheme.onSurface.withOpacity(0.6),
                    size: 18,
                  ),
                  label: Text(
                    category['name'] as String,
                    style: TextStyle(
                      color: isSelected ? Colors.white : colorScheme.onSurface,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = selected ? category['id'] as String : _selectedCategory;
                    });
                  },
                  backgroundColor: colorScheme.surface,
                  selectedColor: colorScheme.primary,
                  checkmarkColor: Colors.white,
                  side: BorderSide(
                    color: isSelected ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPopularCitiesSection(ColorScheme colorScheme, LocalizationService localizationService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizationService.translate('popular_cities'),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colorScheme.onBackground,
          ),
        ),
        SizedBox(height: 16),
        ..._popularCities.map((city) => _buildCityCard(city, colorScheme)).toList(),
      ],
    );
  }

  Widget _buildCityCard(Map<String, dynamic> city, ColorScheme colorScheme) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
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
      child: InkWell(
        onTap: () => _openCityDetails(city),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                city['image'] as String,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: 200,
                    color: colorScheme.onSurface.withOpacity(0.1),
                    child: Icon(Icons.image, size: 64, color: colorScheme.onSurface.withOpacity(0.6)),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    city['name'] as String,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    city['description'] as String,
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendedActivitiesSection(ColorScheme colorScheme, LocalizationService localizationService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizationService.translate('recommended_activities'),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colorScheme.onBackground,
          ),
        ),
        SizedBox(height: 16),
        ..._recommendedActivities.map((activity) => _buildActivityCard(activity, colorScheme)).toList(),
      ],
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> activity, ColorScheme colorScheme) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
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
      child: InkWell(
        onTap: () => _openActivityDetails(activity),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  activity['image']!,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 60,
                      height: 60,
                      color: colorScheme.onSurface.withOpacity(0.1),
                      child: Icon(Icons.image, color: colorScheme.onSurface.withOpacity(0.6)),
                    );
                  },
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity['title']!,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      activity['location']!,
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingEventsSection(ColorScheme colorScheme, LocalizationService localizationService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              localizationService.translate('upcoming_events'),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onBackground,
              ),
            ),
            TextButton(
              onPressed: () => _openEventsPage(),
              child: Text(
                localizationService.translate('view_all'),
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        ..._upcomingEvents.map((event) => _buildEventCard(event, colorScheme)).toList(),
      ],
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event, ColorScheme colorScheme) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
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
      child: InkWell(
        onTap: () => _openEventDetails(event),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                event['image']!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: 200,
                    color: colorScheme.onSurface.withOpacity(0.1),
                    child: Icon(Icons.image, size: 64, color: colorScheme.onSurface.withOpacity(0.6)),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event['title']!,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                      SizedBox(width: 8),
                      Text(
                        event['date']!,
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                      SizedBox(width: 8),
                      Text(
                        event['location']!,
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchExplorePage(),
      ),
    );
  }

  void _openFilters() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FilterExplorePage(
          currentFilters: _currentFilters,
          onFiltersApplied: (filters) {
            setState(() {
              _currentFilters = filters;
            });
          },
        ),
      ),
    );
  }

  void _openCityDetails(Map<String, dynamic> city) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailsExplorePage(destination: city),
      ),
    );
  }

  void _openActivityDetails(Map<String, dynamic> activity) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailsExplorePage(destination: activity),
      ),
    );
  }

  void _openEventDetails(Map<String, dynamic> event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailsExplorePage(destination: event),
      ),
    );
  }

  void _openEventsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventsExplorePage(),
      ),
    );
  }
}