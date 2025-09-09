import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../core/constants/constants.dart';
import 'city_details_page.dart';

class CitySelectionPage extends StatefulWidget {
  const CitySelectionPage({super.key});

  @override
  State<CitySelectionPage> createState() => _CitySelectionPageState();
}

class _CitySelectionPageState extends State<CitySelectionPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'all';
  Position? _userLocation;
  String? _detectedCity;
  bool _isLoadingLocation = false;
  bool _isSearching = false;

  // Utiliser la même structure de données que search_explore_page
  List<Map<String, dynamic>> get _allCities => AppConstants.moroccoCities;

  List<Map<String, dynamic>> get _filteredCities {
    List<Map<String, dynamic>> cities = _allCities;

    // Filtrage par recherche
    if (_searchQuery.isNotEmpty) {
      cities = cities.where((city) {
        // Vérifier que les clés existent avant d'y accéder
        final name = city['name']?.toString().toLowerCase() ?? '';
        final description = city['description']?.toString().toLowerCase() ?? '';
        
        // Vérifier si la ville a un type et les filtrer
        final types = city['type'] as List<dynamic>?;
        final hasMatchingType = types?.any((type) => 
          type.toString().toLowerCase().contains(_searchQuery.toLowerCase())) ?? false;
        
        return name.contains(_searchQuery.toLowerCase()) ||
               description.contains(_searchQuery.toLowerCase()) ||
               hasMatchingType;
      }).toList();
    }

    // Filtrage par catégorie
    if (_selectedFilter != 'all') {
      cities = cities.where((city) {
        final types = city['type'] as List<dynamic>?;
        if (types == null) return false;
        
        switch (_selectedFilter) {
          case 'beach':
            return types.any((type) => type.toString().toLowerCase().contains('beach') || 
                                       type.toString().toLowerCase().contains('coastal'));
          case 'cultural':
            return types.any((type) => type.toString().toLowerCase().contains('cultural') || 
                                       type.toString().toLowerCase().contains('historical'));
          case 'modern':
            return types.any((type) => type.toString().toLowerCase().contains('modern'));
          case 'mountains':
            return types.any((type) => type.toString().toLowerCase().contains('mountains'));
          default:
            return false;
        }
      }).toList();
    }

    return cities;
  }

  @override
  void initState() {
    super.initState();
    _detectUserLocation();
  }

  Future<void> _detectUserLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      // Demander les permissions de localisation
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoadingLocation = false;
        });
        return;
      }

      // Obtenir la position actuelle
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _userLocation = position;
        _detectedCity = _findNearestCity(position.latitude, position.longitude);
        _isLoadingLocation = false;
      });

    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
      });
      print('Erreur de géolocalisation: $e');
    }
  }

  String? _findNearestCity(double latitude, double longitude) {
    double minDistance = double.infinity;
    String? nearestCity;

    for (var city in _allCities) {
      // Vérifier que les clés existent avant d'y accéder
      final cityLat = city['latitude'];
      final cityLng = city['longitude'];
      final cityName = city['name'];
      
      if (cityLat == null || cityLng == null || cityName == null) continue;
      
      double distance = Geolocator.distanceBetween(
        latitude,
        longitude,
        cityLat.toDouble(),
        cityLng.toDouble(),
      );

      if (distance < minDistance) {
        minDistance = distance;
        nearestCity = cityName.toString();
      }
    }

    return nearestCity;
  }

  void _onCitySelected(Map<String, dynamic> city) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CityDetailsPage(
          city: {
            'name': city['name'] ?? '',
            'type': 'city',
            'isUserLocation': city['name'] == _detectedCity,
            'location': {
              'latitude': city['latitude'] ?? 0.0,
              'longitude': city['longitude'] ?? 0.0,
            },
            'description': city['description'] ?? '',
            'popularActivities': city['attractions'] ?? [],
            'bestTime': 'March to November', // Valeur par défaut
            'averageCost': 'Medium', // Valeur par défaut
            'image': city['imageUrl'] ?? '',
            'rating': 4.5, // Valeur par défaut
            'tags': city['type'] ?? [],
          },
        ),
      ),
    );
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
          'Select Your Destination',
          style: TextStyle(
            color: colorScheme.onBackground,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          if (_detectedCity != null)
            Container(
              margin: EdgeInsets.only(right: 16),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: colorScheme.primary.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on,
                    color: colorScheme.primary,
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Near: $_detectedCity',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche et filtres
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Barre de recherche
                TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: LocalizationService().translate('search_cities_countries_activities_hint'),
                    prefixIcon: Icon(Icons.search, color: colorScheme.onSurface.withOpacity(0.6)),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: colorScheme.onSurface.withOpacity(0.6)),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                SizedBox(height: 16),
                // Filtres
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('all', 'All Cities', colorScheme),
                      _buildFilterChip('beach', 'Beach Cities', colorScheme),
                      _buildFilterChip('cultural', 'Cultural Cities', colorScheme),
                      _buildFilterChip('modern', 'Modern Cities', colorScheme),
                      _buildFilterChip('mountains', 'Mountain Cities', colorScheme),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Liste des villes
          Expanded(
            child: _isLoadingLocation
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: colorScheme.primary),
                        SizedBox(height: 16),
                        Text(
                          'Detecting your location...',
                          style: TextStyle(
                            color: colorScheme.onSurface.withOpacity(0.6),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : _filteredCities.isEmpty
                    ? Center(
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
                              'No cities found',
                              style: TextStyle(
                                color: colorScheme.onSurface.withOpacity(0.6),
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Try adjusting your search or filters',
                              style: TextStyle(
                                color: colorScheme.onSurface.withOpacity(0.4),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: EdgeInsets.all(16),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isDesktop ? 3 : (isTablet ? 2 : 2),
                          childAspectRatio: isDesktop ? 0.8 : (isTablet ? 0.75 : 0.7),
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: _filteredCities.length,
                        itemBuilder: (context, index) {
                          final city = _filteredCities[index];
                          final isUserLocation = city['name'] == _detectedCity;
                          
                          return _buildCityCard(city, isUserLocation, colorScheme, isTablet, isDesktop);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, ColorScheme colorScheme) {
    final isSelected = _selectedFilter == value;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
      },
      child: Container(
        margin: EdgeInsets.only(right: 12),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.outline.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : colorScheme.onSurface,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildCityCard(Map<String, dynamic> city, bool isUserLocation, ColorScheme colorScheme, bool isTablet, bool isDesktop) {
    final cardHeight = isDesktop ? 280.0 : (isTablet ? 260.0 : 240.0);
    final imageHeight = isDesktop ? 160.0 : (isTablet ? 140.0 : 120.0);
    final titleSize = isDesktop ? 18.0 : (isTablet ? 16.0 : 14.0);
    final subtitleSize = isDesktop ? 14.0 : (isTablet ? 13.0 : 12.0);

    return GestureDetector(
      onTap: () => _onCitySelected(city),
      child: Container(
        height: cardHeight,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image avec badge de localisation
            Stack(
              children: [
                Container(
                  height: imageHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    image: DecorationImage(
                      image: NetworkImage(city['imageUrl'] ?? 'https://images.unsplash.com/photo-1517685352821-92cf88aee5a5'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                if (isUserLocation)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Colors.white,
                            size: 12,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Near You',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Note
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 12),
                        SizedBox(width: 4),
                        Text(
                          '4.5', // Valeur par défaut
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Informations de la ville
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(isDesktop ? 16 : 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      city['name'] ?? '',
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
                      'Morocco', // Valeur par défaut
                      style: TextStyle(
                        fontSize: subtitleSize,
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: (city['type'] as List<dynamic>? ?? []).take(2).map((type) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            type.toString(),
                            style: TextStyle(
                              fontSize: 10,
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    Spacer(),
                    // Bouton de sélection
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Select City',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: subtitleSize,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
