import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../core/constants/constants.dart';
import 'details_explore.dart';
import 'search_explore_page.dart';
import 'filter_explore_page.dart';
import 'events_explore_page.dart';
import '../../data/services/public_api_service.dart';
import '../../data/models/city_dto.dart';
import '../../data/models/activity.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({Key? key}) : super(key: key);

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  String _selectedCategory = 'cities';
  Map<String, dynamic>? _currentFilters;
  final PublicApiService _api = PublicApiService();
  List<CityDto> _cities = [];
  List<ActivityModel> _activities = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _api.getAllCities(),
        _api.getAllActivities(),
      ]);
      setState(() {
        _cities = results[0] as List<CityDto>;
        _activities = results[1] as List<ActivityModel>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

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
                  child: _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : _error != null
                          ? Center(child: Text(_error!, style: TextStyle(color: colorScheme.error)))
                          : SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 24),
                        _buildCategoriesSection(colorScheme, localizationService),
                        SizedBox(height: 32),
                                  _buildAllCitiesSection(colorScheme, localizationService),
                        SizedBox(height: 32),
                                  _buildAllActivitiesSection(colorScheme, localizationService),
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

  Widget _buildAllCitiesSection(ColorScheme colorScheme, LocalizationService localizationService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizationService.translate('cities'),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colorScheme.onBackground,
          ),
        ),
        SizedBox(height: 16),
        ..._cities.map((city) => _buildCityCard(city, colorScheme)).toList(),
      ],
    );
  }

  Widget _buildCityCard(CityDto city, ColorScheme colorScheme) {
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
                city.imageUrl ?? '',
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
                    city.nom,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    city.description ?? '',
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

  Widget _buildAllActivitiesSection(ColorScheme colorScheme, LocalizationService localizationService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizationService.translate('activities'),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colorScheme.onBackground,
          ),
        ),
        SizedBox(height: 16),
        ..._activities.map((activity) => _buildActivityCard(activity, colorScheme)).toList(),
      ],
    );
  }

  Widget _buildActivityCard(ActivityModel activity, ColorScheme colorScheme) {
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
                  activity.imageUrl ?? '',
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
                      activity.nom,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 4),
                    if (activity.prix != null)
                    Text(
                        '${activity.prix!.toStringAsFixed(2)} MAD',
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

  void _openCityDetails(CityDto city) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailsExplorePage(destination: {
          'id': city.id,
          'name': city.nom,
          'description': city.description ?? '',
          'image': city.imageUrl ?? '',
        }),
      ),
    );
  }

  void _openActivityDetails(ActivityModel activity) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailsExplorePage(destination: {
          'id': activity.id,
          'title': activity.nom,
          'image': activity.imageUrl ?? '',
        }),
      ),
    );
  }

  // Events UI removed for now, pending backend real events integration
}