import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../core/constants/constants.dart';
import 'details_explore.dart';
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
  List<CityDto> _cityResults = [];
  List<ActivityModel> _activityResults = [];
  bool _isSearching = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
    _performSearch();
  }

  Future<void> _performSearch() async {
    if (_searchQuery.isEmpty) {
      setState(() {
        _cityResults = [];
        _activityResults = [];
        _isSearching = false;
        _error = null;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _error = null;
    });

    try {
      final result = await _api.searchAggregated(_searchQuery.trim());
      setState(() {
        _cityResults = (result['cities'] as List<CityDto>);
        _activityResults = (result['activities'] as List<ActivityModel>);
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isSearching = false;
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

    if (_searchQuery.isEmpty) {
      return _buildEmptyState(colorScheme);
    }

    if (_cityResults.isEmpty && _activityResults.isEmpty) {
      return _buildNoResults(colorScheme);
    }

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 16),
      children: [
        if (_cityResults.isNotEmpty) ...[
          SizedBox(height: 8),
          _buildSectionHeader('Cities (${_cityResults.length})', colorScheme),
          SizedBox(height: 8),
          ..._cityResults.map((c) => _buildCityResultCard(c, colorScheme)).toList(),
          SizedBox(height: 16),
        ],
        if (_activityResults.isNotEmpty) ...[
          _buildSectionHeader('Activities (${_activityResults.length})', colorScheme),
          SizedBox(height: 8),
          ..._activityResults.map((a) => _buildActivityResultCard(a, colorScheme)).toList(),
          SizedBox(height: 16),
        ],
      ],
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
              builder: (context) => DetailsExplorePage(destination: {
                'id': city.id,
                'name': city.nom,
                'description': city.description ?? '',
                'image': city.imageUrl ?? '',
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
                child: Image.network(
                  city.imageUrl ?? '',
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
} 