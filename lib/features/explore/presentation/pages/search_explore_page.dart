import 'package:flutter/material.dart';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../core/services/image_service.dart';
import '../../../../core/constants/constants.dart';
import 'details_explore.dart';
import 'city_details_page.dart';
import '../../data/services/public_api_service.dart';
import '../../data/models/city_dto.dart';
import '../../data/models/activity.dart';

class SearchExplorePage extends StatefulWidget {
  const SearchExplorePage({Key? key}) : super(key: key);

  @override
  State<SearchExplorePage> createState() => _SearchExplorePageState();
}

class _SearchExplorePageState extends State<SearchExplorePage> {
  final TextEditingController _searchController = TextEditingController();
  final PublicApiService _api = PublicApiService();
  String _searchQuery = '';
  int? _selectedCityId; // scope search to a city when selected
  String _activeCategory = 'all'; // all, cities, activities, events, services, attractions, products
  Timer? _debounce;
  CancelToken? _inflightToken;
  bool _isLoadingCities = false;
  List<CityDto> _allCities = [];
  List<CityDto> _cityResults = [];
  List<ActivityModel> _activityResults = [];
  List<Map<String, dynamic>> _eventResults = [];
  List<Map<String, dynamic>> _serviceResults = [];
  List<Map<String, dynamic>> _attractionResults = [];
  List<Map<String, dynamic>> _accommodationResults = [];
  bool _isSearching = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadCities();
    // Load baseline data for the default active category so lists render without a query
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchBaselineForActiveCategory();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _inflightToken?.cancel('disposed');
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() { _searchQuery = _searchController.text; });
    _debounce?.cancel();
    _debounce = Timer(Duration(milliseconds: 400), () {
      _performSearch();
    });
  }

  Future<void> _loadCities() async {
    setState(() { _isLoadingCities = true; });
    try {
      _allCities = await _api.getAllCities();
    } catch (_) {}
    if (mounted) setState(() { _isLoadingCities = false; });
  }

  Future<void> _performSearch() async {
    if (_searchQuery.trim().isEmpty) {
      setState(() {
        // Baseline loads per category when no query
        _cityResults = [];
        _activityResults = [];
        _eventResults = [];
        _serviceResults = [];
        _attractionResults = [];
        _accommodationResults = [];
        _isSearching = false;
        _error = null;
      });
      // Trigger baseline fetch right away
      await _fetchBaselineForActiveCategory();
      return;
    }

    setState(() {
      _isSearching = true;
      _error = null;
    });

    try {
      _inflightToken?.cancel('new search');
      _inflightToken = CancelToken();

      // When there's a search query, filter results by the query
      final q = _searchQuery.trim();
      List<CityDto> cities = [];
      List<ActivityModel> activities = [];
      List<Map<String, dynamic>> events = [];
      List<Map<String, dynamic>> monuments = [];
      List<Map<String, dynamic>> products = [];

      if (_activeCategory == 'all') {
        // For "All", search across all categories with the query
        final base = await _api.searchAggregated(q, cancelToken: _inflightToken);
        cities = (base['cities'] as List<CityDto>);
        activities = (base['activities'] as List<ActivityModel>);
        
        // For monuments and accommodations, search by city name if we found matching cities
        if (cities.isNotEmpty) {
          final cityName = cities.first.nom;
          monuments = await _api.getMonumentsByCity(cityName, cancelToken: _inflightToken);
          products = await _api.getProductsByCity(cityName, cancelToken: _inflightToken);
          final cityId = cities.first.id;
          events = await _api.getCityEvents(cityId, cancelToken: _inflightToken);
        } else {
          // Fallback to name-based search if no cities found
          monuments = await _api.searchMonuments(q, cancelToken: _inflightToken);
          products = await _api.getProducts(query: q, cancelToken: _inflightToken);
        }
      } else if (_activeCategory == 'cities') {
        final base = await _api.searchAggregated(q, cancelToken: _inflightToken);
        cities = (base['cities'] as List<CityDto>);
      } else if (_activeCategory == 'activities') {
        final base = await _api.searchAggregated(q, cancelToken: _inflightToken);
        activities = (base['activities'] as List<ActivityModel>);
      } else if (_activeCategory == 'events') {
        // For events, first find matching cities, then get events for that city
        final base = await _api.searchAggregated(q, cancelToken: _inflightToken);
        final matchingCities = (base['cities'] as List<CityDto>);
        if (matchingCities.isNotEmpty) {
          final cityId = matchingCities.first.id;
          events = await _api.getCityEvents(cityId, cancelToken: _inflightToken);
        }
      } else if (_activeCategory == 'services' || _activeCategory == 'accommodations') {
        // First try to find matching cities, then get accommodations for that city
        final base = await _api.searchAggregated(q, cancelToken: _inflightToken);
        final matchingCities = (base['cities'] as List<CityDto>);
        if (matchingCities.isNotEmpty) {
          final cityName = matchingCities.first.nom;
          products = await _api.getProductsByCity(cityName, cancelToken: _inflightToken);
        } else {
          // Fallback to name-based search
          products = await _api.getProducts(query: q, cancelToken: _inflightToken);
        }
      } else if (_activeCategory == 'monuments') {
        // First try to find matching cities, then get monuments for that city
        final base = await _api.searchAggregated(q, cancelToken: _inflightToken);
        final matchingCities = (base['cities'] as List<CityDto>);
        if (matchingCities.isNotEmpty) {
          final cityName = matchingCities.first.nom;
          monuments = await _api.getMonumentsByCity(cityName, cancelToken: _inflightToken);
        } else {
          // Fallback to name-based search
          monuments = await _api.searchMonuments(q, cancelToken: _inflightToken);
        }
      }

      setState(() {
        _cityResults = cities;
        _activityResults = activities;
        _eventResults = events;
        _serviceResults = products;
        _attractionResults = monuments;
        _accommodationResults = products;
        _isSearching = false;
      });
    } catch (e) {
      print('Search error: $e');
      setState(() {
        _error = null; // Don't show error to user, use fallback data
        _isSearching = false;
      });
      
      // Try to perform local search as fallback
      try {
        final localResults = _api.performLocalSearch(_searchQuery.trim());
        setState(() {
          _cityResults = localResults['cities'] as List<CityDto>;
          _activityResults = localResults['activities'] as List<ActivityModel>;
        });
      } catch (localError) {
        print('Local search also failed: $localError');
        setState(() {
          _cityResults = [];
          _activityResults = [];
        });
      }
    }
  }

  Future<void> _fetchBaselineForActiveCategory() async {
    try {
      _inflightToken?.cancel('baseline');
      _inflightToken = CancelToken();
      setState(() { _isSearching = true; _error = null; });
      if (_activeCategory == 'all' || _activeCategory == 'cities') {
        final cities = await _api.getAllCities(cancelToken: _inflightToken);
        setState(() { _cityResults = cities; });
      }
      if (_activeCategory == 'all' || _activeCategory == 'activities') {
        final acts = await _api.getAllActivities(cancelToken: _inflightToken);
        setState(() { _activityResults = acts; });
      }
      if (_activeCategory == 'all' || _activeCategory == 'monuments') {
        final mons = await _api.getAllMonuments(cancelToken: _inflightToken);
        setState(() { _attractionResults = mons; });
      }
      if (_activeCategory == 'all' || _activeCategory == 'services' || _activeCategory == 'accommodations') {
        final prods = await _api.getProducts(cancelToken: _inflightToken);
        setState(() { _serviceResults = prods; _accommodationResults = prods; });
      }
    } catch (e) {
      print('Baseline fetch error: $e');
      setState(() { _error = null; }); // Don't show error to user
    } finally {
      if (mounted) setState(() { _isSearching = false; });
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
          appBar: AppBar(
            backgroundColor: colorScheme.background,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: colorScheme.onBackground),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              localizationService.translate('search_morocco'),
              style: TextStyle(
                color: colorScheme.onBackground,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          body: Column(
            children: [
              _buildSearchBar(colorScheme),
              _buildTopFilters(colorScheme),
              Expanded(
                child: _buildSearchResults(colorScheme),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(ColorScheme colorScheme) {
    return Consumer<LocalizationService>(
      builder: (context, localizationService, child) {
        return Container(
          margin: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.onSurface.withOpacity(0.1)),
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: localizationService.translate('search_cities_activities_hint'),
              hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
              prefixIcon: Icon(Icons.search, color: colorScheme.onSurface.withOpacity(0.6)),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            style: TextStyle(
              fontSize: 16,
              color: colorScheme.onSurface,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchResults(ColorScheme colorScheme) {
    if (_error != null) {
      return Center(child: Text(_error!, style: TextStyle(color: colorScheme.error)));
    }

    if (_isSearching) {
      return Center(
        child: CircularProgressIndicator(
          color: colorScheme.primary,
        ),
      );
    }

    // Do not short-circuit on empty query; baseline results may be loaded

    final noResults = _cityResults.isEmpty && _activityResults.isEmpty && _eventResults.isEmpty && _serviceResults.isEmpty && _attractionResults.isEmpty && _accommodationResults.isEmpty;
    if (noResults) {
      return _buildNoResults(colorScheme);
    }

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 16),
      children: [
        if (_activeCategory == 'all' && _cityResults.isNotEmpty || _activeCategory == 'cities') ...[
          SizedBox(height: 8),
          _buildSectionHeader('Cities (${_cityResults.length})', colorScheme),
          SizedBox(height: 8),
          ..._cityResults.map((c) => _buildCityResultCard(c, colorScheme)).toList(),
          SizedBox(height: 16),
        ],
        if (_activeCategory == 'all' && _activityResults.isNotEmpty || _activeCategory == 'activities') ...[
          _buildSectionHeader('Activities (${_activityResults.length})', colorScheme),
          SizedBox(height: 8),
          ..._activityResults.map((a) => _buildActivityResultCard(a, colorScheme)).toList(),
          SizedBox(height: 16),
        ],
        if (_activeCategory == 'all' && _eventResults.isNotEmpty || _activeCategory == 'events') ...[
          _buildSectionHeader('Events (${_eventResults.length})', colorScheme),
          SizedBox(height: 8),
          ..._eventResults.map((e) => _buildGenericResultTile(e, colorScheme, Icons.event)).toList(),
          SizedBox(height: 16),
        ],
        if (_activeCategory == 'all' && _serviceResults.isNotEmpty || _activeCategory == 'services') ...[
          _buildSectionHeader('Services (${_serviceResults.length})', colorScheme),
          SizedBox(height: 8),
          ..._serviceResults.map((s) => _buildGenericResultTile(s, colorScheme, Icons.room_service)).toList(),
          SizedBox(height: 16),
        ],
        // Show monuments when selected or in All
        if (_activeCategory == 'all' && _attractionResults.isNotEmpty || _activeCategory == 'monuments') ...[
          _buildSectionHeader('Monuments (${_attractionResults.length})', colorScheme),
          SizedBox(height: 8),
          ..._attractionResults.map((a) => _buildMonumentCard(a, colorScheme)).toList(),
          SizedBox(height: 16),
        ],
        if (_activeCategory == 'all' && _accommodationResults.isNotEmpty || _activeCategory == 'accommodations') ...[
          _buildSectionHeader('Accommodations (${_accommodationResults.length})', colorScheme),
          SizedBox(height: 8),
          ..._accommodationResults.map((p) => _buildGenericResultTile(p, colorScheme, Icons.hotel)).toList(),
          SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildTopFilters(ColorScheme colorScheme) {
    final tabs = [
      {'id': 'all', 'label': 'All'},
      {'id': 'cities', 'label': 'Cities'},
      {'id': 'activities', 'label': 'Activities'},
      {'id': 'events', 'label': 'Events'},
      {'id': 'services', 'label': 'Services'},
      {'id': 'monuments', 'label': 'Monuments'},
      {'id': 'accommodations', 'label': 'Accommodations'},
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: tabs.map((tab) {
          final selected = _activeCategory == tab['id'];
          return Padding(
            padding: EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(tab['label'] as String),
              selected: selected,
              onSelected: (_) async {
                setState(() { _activeCategory = tab['id'] as String; });
                if (_searchQuery.trim().isEmpty) {
                  await _fetchBaselineForActiveCategory();
                } else {
                  await _performSearch();
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCityScopeBar(ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text('City:', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7))),
          SizedBox(width: 8),
          Expanded(
            child: IgnorePointer(
              ignoring: _isLoadingCities,
              child: DropdownButton<int?>(
                isExpanded: true,
                value: _selectedCityId,
                hint: Text(_isLoadingCities ? 'Loading cities...' : 'All cities'),
                items: [
                  DropdownMenuItem<int?>(value: null, child: Text('All cities')),
                  ..._allCities.map((c) => DropdownMenuItem<int?>(value: c.id, child: Text(c.nom))).toList(),
                ],
                onChanged: (val) {
                  setState(() { _selectedCityId = val; });
                  _performSearch();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, ColorScheme colorScheme) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
      ),
    );
  }

  Widget _buildCityResultCard(CityDto city, ColorScheme colorScheme) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 2)),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CityDetailsPage(city: city.toCityDetailsMap()),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildCityImage(city, colorScheme),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(city.nom, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
                    if (city.climatNom != null)
                      Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text(city.climatNom!, style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withOpacity(0.6))),
                      ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: colorScheme.onSurface.withOpacity(0.4), size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityResultCard(ActivityModel activity, ColorScheme colorScheme) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 2)),
        ],
      ),
      child: InkWell(
        onTap: () {
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
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildActivityImage(activity, colorScheme),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(activity.nom, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        if (activity.dureeMinimun != null)
                          Text('${activity.dureeMinimun}-${activity.dureeMaximun ?? ''} min', style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withOpacity(0.6))),
                        if (activity.categorie != null)
                          Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Text(activity.categorie!, style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withOpacity(0.6))),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: colorScheme.onSurface.withOpacity(0.4), size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenericResultTile(Map<String, dynamic> item, ColorScheme colorScheme, IconData icon) {
    final title = (item['title'] ?? item['name'] ?? item['nom'] ?? item['nomMonument'] ?? item['nomHebergement'] ?? '').toString();
    final subtitle = (item['description'] ?? item['categorie'] ?? item['adresseMonument'] ?? item['adresse'] ?? '').toString();
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 2))],
      ),
      child: ListTile(
        leading: Icon(icon, color: colorScheme.primary),
        title: Text(title, style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w600)),
        subtitle: subtitle.isNotEmpty ? Text(subtitle, style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6))) : null,
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: colorScheme.onSurface.withOpacity(0.4)),
        onTap: () {},
      ),
    );
  }

  Widget _buildMonumentCard(Map<String, dynamic> monument, ColorScheme colorScheme) {
    final title = (monument['nomMonument'] ?? monument['nom'] ?? '').toString();
    final address = (monument['adresseMonument'] ?? '').toString();
    final price = monument['prix'];
    final isFree = monument['gratuit'] == true;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 2)),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.museum, color: colorScheme.primary),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.isNotEmpty ? title : 'Monument',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    if (address.isNotEmpty)
                      Text(
                        address,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6), fontSize: 12),
                      ),
                    SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.star, size: 14, color: Colors.amber),
                        SizedBox(width: 4),
                        Text(
                          (monument['notesMoyennes']?.toString() ?? '4.5'),
                          style: TextStyle(color: colorScheme.onSurface.withOpacity(0.8), fontSize: 12),
                        ),
                        SizedBox(width: 12),
                        Icon(Icons.price_change, size: 14, color: colorScheme.onSurface.withOpacity(0.6)),
                        SizedBox(width: 4),
                        Text(
                          isFree ? 'Free' : (price != null ? price.toString() : 'N/A'),
                          style: TextStyle(color: colorScheme.onSurface.withOpacity(0.8), fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: colorScheme.onSurface.withOpacity(0.4), size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Consumer<LocalizationService>(
      builder: (context, localizationService, child) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search,
                size: 64,
                color: colorScheme.onSurface.withOpacity(0.4),
              ),
              SizedBox(height: 16),
              Text(
                localizationService.translate('search_for_cities_activities'),
                style: TextStyle(
                  fontSize: 18,
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNoResults(ColorScheme colorScheme) {
    return Consumer<LocalizationService>(
      builder: (context, localizationService, child) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 64,
                color: colorScheme.onSurface.withOpacity(0.4),
              ),
              SizedBox(height: 16),
              Text(
                '${localizationService.translate('no_results_found')} "$_searchQuery"',
                style: TextStyle(
                  fontSize: 18,
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                localizationService.translate('try_different_keywords'),
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurface.withOpacity(0.5),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCityImage(CityDto city, ColorScheme colorScheme) {
    final imageUrl = city.imageUrl ?? ImageService.getCityImage(city.nom);
    
    if (ImageService.isLocalAsset(imageUrl)) {
      final String assetPath = imageUrl.startsWith('images/') 
          ? 'assets/$imageUrl' 
          : imageUrl;
      
      return Image.asset(
        assetPath,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 60,
            height: 60,
            color: colorScheme.onSurface.withOpacity(0.1),
            child: Icon(Icons.location_city, color: colorScheme.onSurface.withOpacity(0.6)),
          );
        },
      );
    }

    return Image.network(
      imageUrl,
      width: 60,
      height: 60,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: 60,
          height: 60,
          color: colorScheme.onSurface.withOpacity(0.1),
          child: Icon(Icons.location_city, color: colorScheme.onSurface.withOpacity(0.6)),
        );
      },
    );
  }

  Widget _buildActivityImage(ActivityModel activity, ColorScheme colorScheme) {
    final imageUrl = activity.imageUrl ?? ImageService.getActivityImage(activity.categorie ?? '', activity.nom);
    
    if (ImageService.isLocalAsset(imageUrl)) {
      final String assetPath = imageUrl.startsWith('images/') 
          ? 'assets/$imageUrl' 
          : imageUrl;
      
      return Image.asset(
        assetPath,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 60,
            height: 60,
            color: colorScheme.onSurface.withOpacity(0.1),
            child: Icon(Icons.local_activity, color: colorScheme.onSurface.withOpacity(0.6)),
          );
        },
      );
    }

    return Image.network(
      imageUrl,
      width: 60,
      height: 60,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: 60,
          height: 60,
          color: colorScheme.onSurface.withOpacity(0.1),
          child: Icon(Icons.local_activity, color: colorScheme.onSurface.withOpacity(0.6)),
        );
      },
    );
  }
} 