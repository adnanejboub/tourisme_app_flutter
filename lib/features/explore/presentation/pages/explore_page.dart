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
  List<CityDto> _filteredCities = [];
  List<ActivityModel> _filteredActivities = [];
  Set<String> _activeCityFilters = {};
  Set<String> _activeActivityFilters = {};
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
        _filteredCities = _cities;
        _filteredActivities = _activities;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredCities = _cities.where((c) {
        if (_activeCityFilters.isEmpty) return true;
        final flags = <String, bool?>{
          'plage': c.isPlage,
          'montagne': c.isMontagne,
          'desert': c.isDesert,
          'riviera': c.isRiviera,
          'historique': c.isHistorique,
          'culturelle': c.isCulturelle,
          'moderne': c.isModerne,
        };
        return _activeCityFilters.any((f) => flags[f] == true);
      }).toList();

      _filteredActivities = _activities.where((a) {
        if (_activeActivityFilters.isEmpty) return true;
        final cat = (a.categorie ?? '').toLowerCase();
        return _activeActivityFilters.any((f) => cat.contains(f));
      }).toList();
    });
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
        _buildCityFilterChips(colorScheme, localizationService),
        SizedBox(height: 12),
        ..._filteredCities.map((city) => _buildCityCard(city, colorScheme)).toList(),
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
                  if (city.description != null && city.description!.isNotEmpty)
                  Text(
                      city.description!,
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                    ),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      if (city.isPlage == true) _buildBadge('Beach', colorScheme),
                      if (city.isMontagne == true) _buildBadge('Mountain', colorScheme),
                      if (city.isHistorique == true) _buildBadge('Historic', colorScheme),
                      if (city.isCulturelle == true) _buildBadge('Cultural', colorScheme),
                      if (city.isModerne == true) _buildBadge('Modern', colorScheme),
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
        _buildActivityFilterChips(colorScheme, localizationService),
        SizedBox(height: 12),
        ..._filteredActivities.map((activity) => _buildActivityCard(activity, colorScheme)).toList(),
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
                    Row(
                      children: [
                        if (activity.dureeMinimun != null)
                          _buildBadge('${activity.dureeMinimun}-${activity.dureeMaximun ?? ''} min', colorScheme),
                        if (activity.categorie != null)
                          Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: _buildBadge(activity.categorie!, colorScheme),
                          ),
                      ],
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

  Widget _buildCityFilterChips(ColorScheme colorScheme, LocalizationService localizationService) {
    final filters = [
      {'id': 'plage', 'label': 'Beach'},
      {'id': 'montagne', 'label': 'Mountain'},
      {'id': 'desert', 'label': 'Desert'},
      {'id': 'historique', 'label': 'Historic'},
      {'id': 'culturelle', 'label': 'Cultural'},
      {'id': 'moderne', 'label': 'Modern'},
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: filters.map((f) {
        final selected = _activeCityFilters.contains(f['id']);
        return FilterChip(
          label: Text(f['label'] as String),
          selected: selected,
          onSelected: (v) {
            setState(() {
              if (v) {
                _activeCityFilters.add(f['id'] as String);
              } else {
                _activeCityFilters.remove(f['id']);
              }
              _applyFilters();
            });
          },
          backgroundColor: colorScheme.surface,
          selectedColor: colorScheme.primary,
          checkmarkColor: Colors.white,
          side: BorderSide(color: selected ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.2)),
        );
      }).toList(),
    );
  }

  Widget _buildActivityFilterChips(ColorScheme colorScheme, LocalizationService localizationService) {
    final filters = [
      {'id': 'tours', 'label': 'Tours'},
      {'id': 'evenements', 'label': 'Events'},
      {'id': 'activites_plein_air', 'label': 'Outdoor'},
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: filters.map((f) {
        final selected = _activeActivityFilters.contains(f['id']);
        return FilterChip(
          label: Text(f['label'] as String),
          selected: selected,
          onSelected: (v) {
            setState(() {
              if (v) {
                _activeActivityFilters.add(f['id'] as String);
              } else {
                _activeActivityFilters.remove(f['id']);
              }
              _applyFilters();
            });
          },
          backgroundColor: colorScheme.surface,
          selectedColor: colorScheme.primary,
          checkmarkColor: Colors.white,
          side: BorderSide(color: selected ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.2)),
        );
      }).toList(),
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

  Widget _buildBadge(String text, ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}