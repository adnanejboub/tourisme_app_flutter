import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../core/services/image_service.dart';
import '../../../../core/constants/constants.dart';
import 'details_explore.dart';
import 'city_details_page.dart';
import 'search_explore_page.dart';
import 'filter_explore_page.dart';
import 'events_explore_page.dart';
import '../../data/services/public_api_service.dart';
import '../../data/models/city_dto.dart';
import '../../data/models/activity.dart';
import '../../../saved/data/services/wishlist_service.dart';

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
  final Set<int> _favoriteCityIds = <int>{};
  final Set<int> _favoriteActivityIds = <int>{};
  Set<String> _activeCityFilters = {};
  Set<String> _activeActivityFilters = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
    WishlistService.changes.addListener(_reloadFavoritesFromStore);
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
        WishlistService().fetchFavorites().catchError((_) => <Map<String, dynamic>>[]),
      ]);
      setState(() {
        _cities = results[0] as List<CityDto>;
        _activities = results[1] as List<ActivityModel>;
        _filteredCities = _cities;
        _filteredActivities = _activities;
        // hydrate favorites sets with null safety
        final favs = results[2] as List<Map<String, dynamic>>;
        _favoriteCityIds
          ..clear()
          ..addAll(favs.where((f) => f['type'] == 'city' && f['itemId'] != null).map((f) => (f['itemId'] as num).toInt()));
        _favoriteActivityIds
          ..clear()
          ..addAll(favs.where((f) => f['type'] == 'activity' && f['itemId'] != null).map((f) => (f['itemId'] as num).toInt()));
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _reloadFavoritesFromStore() async {
    try {
      final favs = await WishlistService().fetchFavorites();
      if (!mounted) return;
      setState(() {
        _favoriteCityIds
          ..clear()
          ..addAll(favs.where((f) => f['type'] == 'city' && f['itemId'] != null).map((f) => (f['itemId'] as num).toInt()));
        _favoriteActivityIds
          ..clear()
          ..addAll(favs.where((f) => f['type'] == 'activity' && f['itemId'] != null).map((f) => (f['itemId'] as num).toInt()));
      });
    } catch (_) {}
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
                          : RefreshIndicator(
                              onRefresh: _loadData,
                  child: SingleChildScrollView(
                                physics: AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 24),
                                    _buildAllCitiesSection(colorScheme, localizationService),
                        SizedBox(height: 32),
                                    _buildAllActivitiesSection(colorScheme, localizationService),
                        SizedBox(height: 32),
                      ],
                                ),
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

  @override
  void dispose() {
    try { WishlistService.changes.removeListener(_reloadFavoritesFromStore); } catch (_) {}
    super.dispose();
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
              localizationService.translate('cities'),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colorScheme.onBackground,
          ),
            ),
            Text(
              '${_filteredCities.length}',
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
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
              child: Stack(
                children: [
                  _buildSmartImage(
                    imageUrl: city.imageUrl ?? '',
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    colorScheme: colorScheme,
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.35),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: InkWell(
                      onTap: () => _toggleCityFavorite(city),
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.35),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _favoriteCityIds.contains(city.id) ? Icons.favorite : Icons.favorite_border,
                          color: _favoriteCityIds.contains(city.id) ? Colors.redAccent : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
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
                  SizedBox(height: 6),
                  Row(
                    children: [
                      if (city.paysNom != null && city.paysNom!.isNotEmpty)
                        Row(
                          children: [
                            Icon(Icons.public, size: 14, color: colorScheme.onSurface.withOpacity(0.6)),
                            SizedBox(width: 4),
                            Text(
                              city.paysNom!,
                              style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withOpacity(0.7)),
                            ),
                          ],
                        ),
                      if ((city.latitude != null && city.longitude != null))
                        Padding(
                          padding: EdgeInsets.only(left: 12),
                          child: Row(
                            children: [
                              Icon(Icons.location_on, size: 14, color: colorScheme.onSurface.withOpacity(0.6)),
                              SizedBox(width: 4),
                              Text(
                                '${city.latitude?.toStringAsFixed(2)}, ${city.longitude?.toStringAsFixed(2)}',
                                style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withOpacity(0.7)),
                              ),
                            ],
                          ),
                        ),
                    ],
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
                      if (city.climatNom != null && city.climatNom!.isNotEmpty)
                        _buildClimateBadge(city.climatNom!, colorScheme),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
              localizationService.translate('activities'),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colorScheme.onBackground,
          ),
            ),
            Text(
              '${_filteredActivities.length}',
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: Stack(
                children: [
                  _buildSmartImage(
                    imageUrl: activity.imageUrl ?? '',
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                    colorScheme: colorScheme,
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.35),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: InkWell(
                      onTap: () => _toggleActivityFavorite(activity),
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.35),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _favoriteActivityIds.contains(activity.id) ? Icons.favorite : Icons.favorite_border,
                          color: _favoriteActivityIds.contains(activity.id) ? Colors.redAccent : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content section
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.nom,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 8),
                  if (activity.description != null && activity.description!.isNotEmpty)
                    Text(
                      activity.description!,
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  SizedBox(height: 12),
                  // Activity details row
                  Row(
                    children: [
                      if (activity.dureeMinimun != null)
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 14, color: colorScheme.onSurface.withOpacity(0.6)),
                            SizedBox(width: 4),
                            Text(
                              '${activity.dureeMinimun}-${activity.dureeMaximun ?? activity.dureeMinimun} min',
                              style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withOpacity(0.7)),
                            ),
                          ],
                        ),
                      if (activity.saison != null)
                        Padding(
                          padding: EdgeInsets.only(left: 16),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today, size: 14, color: colorScheme.onSurface.withOpacity(0.6)),
                              SizedBox(width: 4),
                              Text(
                                activity.saison!,
                                style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withOpacity(0.7)),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 8),
                  // Badges row
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      if (activity.categorie != null)
                        _buildBadge(activity.categorie!, colorScheme),
                      if (activity.niveauDificulta != null)
                        _buildBadge(activity.niveauDificulta!, colorScheme),
                      if (activity.prix != null)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${activity.prix!.toStringAsFixed(2)} MAD',
                            style: TextStyle(fontSize: 12, color: Colors.amber[800], fontWeight: FontWeight.w700),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 12),
                  // Book button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _bookActivity(activity),
                      icon: Icon(Icons.book_online, size: 18),
                      label: Text(
                        Provider.of<LocalizationService>(context, listen: false)
                            .translate('book_now'),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
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
        builder: (context) => CityDetailsPage(city: city.toCityDetailsMap()),
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
          'description': activity.description ?? '',
          'prix': activity.prix,
          'dureeMinimun': activity.dureeMinimun,
          'dureeMaximun': activity.dureeMaximun,
          'saison': activity.saison,
          'niveauDificulta': activity.niveauDificulta,
          'categorie': activity.categorie,
        }),
      ),
    );
  }

  Future<void> _bookActivity(ActivityModel activity) async {
    try {
      // Add to wishlist first
      await _toggleActivityFavorite(activity);
      
      // Show booking confirmation
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                Provider.of<LocalizationService>(context, listen: false)
                    .translate('activity_booked_title'),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Provider.of<LocalizationService>(context, listen: false)
                        .translate('activity_booked_success'),
                  ),
                  SizedBox(height: 8),
                  Text(
                    activity.nom,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (activity.prix != null) ...[
                    SizedBox(height: 4),
                    Text(
                      '${Provider.of<LocalizationService>(context, listen: false).translate('price')}: ${activity.prix!.toStringAsFixed(2)} MAD',
                    ),
                  ],
                  if (activity.dureeMinimun != null) ...[
                    SizedBox(height: 4),
                    Text(
                      '${Provider.of<LocalizationService>(context, listen: false).translate('duration')}: '
                      '${activity.dureeMinimun}-${activity.dureeMaximun ?? activity.dureeMinimun} minutes',
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    Provider.of<LocalizationService>(context, listen: false)
                        .translate('ok'),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _openActivityDetails(activity);
                  },
                  child: Text(
                    Provider.of<LocalizationService>(context, listen: false)
                        .translate('view_details'),
                  ),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${Provider.of<LocalizationService>(context, listen: false).translate('error_booking_activity')}: ${e.toString()}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleCityFavorite(CityDto city) async {
    final int cityId = city.id;
    final bool wasFav = _favoriteCityIds.contains(cityId);
    setState(() {
      if (wasFav) {
        _favoriteCityIds.remove(cityId);
      } else {
        _favoriteCityIds.add(cityId);
      }
    });
    try {
      await WishlistService.saveSnapshot(
        type: 'city',
        itemId: cityId,
        data: {
          'id': city.id,
          'name': city.nom,
          'paysNom': city.paysNom ?? '',
          'country': city.paysNom ?? '',
          'image': city.imageUrl ?? '',
          'imageUrl': city.imageUrl ?? '',
          'description': city.description ?? '',
          'climatNom': city.climatNom,
          'isPlage': city.isPlage,
          'isMontagne': city.isMontagne,
          'isDesert': city.isDesert,
          'isRiviera': city.isRiviera,
          'isHistorique': city.isHistorique,
          'isCulturelle': city.isCulturelle,
          'isModerne': city.isModerne,
        },
      );
      final res = await WishlistService().toggleFavorite(type: 'city', itemId: cityId);
      final action = res['action'] as String?;
      final added = action == 'added';
      if (mounted) {
        setState(() {
          if (added) {
            _favoriteCityIds.add(cityId);
          } else {
            _favoriteCityIds.remove(cityId);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          if (wasFav) {
            _favoriteCityIds.add(cityId);
          } else {
            _favoriteCityIds.remove(cityId);
          }
        });
      }
    }
  }

  Future<void> _toggleActivityFavorite(ActivityModel activity) async {
    if (activity.id == 0) return; // Skip invalid activities
    
    final int activityId = activity.id;
    final bool wasFav = _favoriteActivityIds.contains(activityId);
    setState(() {
      if (wasFav) {
        _favoriteActivityIds.remove(activityId);
      } else {
        _favoriteActivityIds.add(activityId);
      }
    });
    try {
      await WishlistService.saveSnapshot(
        type: 'activity',
        itemId: activityId,
        data: {
          'id': activity.id,
          'nom': activity.nom,
          'title': activity.nom,
          'image': activity.imageUrl ?? '',
          'imageUrl': activity.imageUrl ?? '',
          'prix': activity.prix,
          'dureeMinimun': activity.dureeMinimun,
          'dureeMaximun': activity.dureeMaximun,
          'saison': activity.saison,
          'niveauDificulta': activity.niveauDificulta,
          'categorie': activity.categorie,
        },
      );
      // Try server toggle; on 401 fallback to local ids
      final res = await WishlistService().toggleFavorite(type: 'activity', itemId: activityId);
      final action = res['action'] as String?;
      final added = action == 'added';
      if (mounted) {
        setState(() {
          if (added) {
            _favoriteActivityIds.add(activityId);
            WishlistService.addLocalId('activity', activityId);
          } else {
            _favoriteActivityIds.remove(activityId);
            WishlistService.removeLocalId('activity', activityId);
            WishlistService.removeSnapshot(type: 'activity', itemId: activityId);
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(added ? 'Added to wishlist' : 'Removed from wishlist'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Local fallback for guest or offline
      if (e is UnauthorizedException) {
        if (!wasFav) {
          await WishlistService.addLocalId('activity', activityId);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  Provider.of<LocalizationService>(context, listen: false)
                      .translate('added_to_wishlist'),
                ),
              ),
            );
          }
        } else {
          await WishlistService.removeLocalId('activity', activityId);
          await WishlistService.removeSnapshot(type: 'activity', itemId: activityId);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  Provider.of<LocalizationService>(context, listen: false)
                      .translate('removed_from_wishlist'),
                ),
              ),
            );
          }
        }
        return;
      }
      if (mounted) {
        setState(() {
          if (wasFav) {
            _favoriteActivityIds.add(activityId);
          } else {
            _favoriteActivityIds.remove(activityId);
          }
        });
      }
    }
  }

  Widget _buildBadge(String text, ColorScheme colorScheme) {
    final Color color = _getCategoryColor(text, colorScheme);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildClimateBadge(String climate, ColorScheme colorScheme) {
    final Color color = _getClimateColor(climate, colorScheme);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.35),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.thermostat,
            size: 14,
            color: color,
          ),
          SizedBox(width: 4),
          Text(
            climate,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String label, ColorScheme colorScheme) {
    final key = label.toLowerCase();
    if (key.contains('beach') || key.contains('plage')) return Colors.blue;
    if (key.contains('mountain') || key.contains('montagne')) return Colors.green;
    if (key.contains('historic') || key.contains('historique')) return Colors.brown;
    if (key.contains('cultural') || key.contains('culturelle')) return Colors.purple;
    if (key.contains('modern') || key.contains('moderne')) return Colors.teal;
    if (key.contains('tours')) return Colors.indigo;
    if (key.contains('events') || key.contains('evenements')) return Colors.orange;
    if (key.contains('outdoor') || key.contains('plein')) return Colors.cyan;
    return colorScheme.primary;
  }

  Color _getClimateColor(String climate, ColorScheme colorScheme) {
    final key = climate.toLowerCase();
    if (key.contains('desert') || key.contains('arid')) return Colors.amber;
    if (key.contains('mediterranean') || key.contains('méditerranéen') || key.contains('mediterranéen')) return Colors.deepOrange;
    if (key.contains('oceanic') || key.contains('océanique') || key.contains('maritime')) return Colors.blueAccent;
    if (key.contains('continental')) return Colors.indigo;
    if (key.contains('tropical')) return Colors.green;
    if (key.contains('semi-arid') || key.contains('steppe')) return Colors.lime;
    return colorScheme.secondary;
  }

  /// Smart image widget that handles both local assets and network images
  Widget _buildSmartImage({
    required String imageUrl,
    required double width,
    required double height,
    required BoxFit fit,
    required ColorScheme colorScheme,
  }) {
    if (imageUrl.isEmpty) {
      return Container(
        width: width,
        height: height,
        color: colorScheme.onSurface.withOpacity(0.1),
        child: Icon(Icons.image, size: 64, color: colorScheme.onSurface.withOpacity(0.6)),
      );
    }

    if (ImageService.isLocalAsset(imageUrl)) {
      return Image.asset(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            color: colorScheme.onSurface.withOpacity(0.1),
            child: Icon(Icons.image, size: 64, color: colorScheme.onSurface.withOpacity(0.6)),
          );
        },
      );
    } else {
      return Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            color: colorScheme.onSurface.withOpacity(0.1),
            child: Icon(Icons.image, size: 64, color: colorScheme.onSurface.withOpacity(0.6)),
          );
        },
      );
    }
  }
}