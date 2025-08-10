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

  // Liste des villes avec leurs informations
  final List<Map<String, dynamic>> _allCities = [
    {
      'id': 'casablanca',
      'name': 'Casablanca',
      'country': 'Morocco',
      'image': 'https://images.unsplash.com/photo-1553603228-0f7051e6ad75?w=400',
      'rating': 4.5,
      'reviews': '15K',
      'tags': ['Business', 'Beach', 'Modern'],
      'latitude': 33.5731,
      'longitude': -7.5898,
      'description': 'Economic capital with modern architecture and Hassan II Mosque',
      'popularActivities': ['Visit Hassan II Mosque', 'Explore Medina', 'Beach activities'],
      'bestTime': 'March to November',
      'averageCost': 'Medium',
    },
    {
      'id': 'marrakech',
      'name': 'Marrakech',
      'country': 'Morocco',
      'image': 'https://images.unsplash.com/photo-1518548419970-58e3b4079ab2?w=400',
      'rating': 4.7,
      'reviews': '22K',
      'tags': ['Cultural', 'Historic', 'Souks'],
      'latitude': 31.6295,
      'longitude': -7.9811,
      'description': 'Red city with vibrant souks and historic medina',
      'popularActivities': ['Explore Jemaa el-Fnaa', 'Visit Majorelle Garden', 'Shop in souks'],
      'bestTime': 'March to May, September to November',
      'averageCost': 'Low to Medium',
    },
    {
      'id': 'fes',
      'name': 'Fes',
      'country': 'Morocco',
      'image': 'https://images.unsplash.com/photo-1553603228-0f7051e6ad75?w=400',
      'rating': 4.6,
      'reviews': '18K',
      'tags': ['Cultural', 'Historic', 'Medina'],
      'latitude': 34.0181,
      'longitude': -5.0078,
      'description': 'Spiritual and cultural heart of Morocco',
      'popularActivities': ['Visit Al-Qarawiyyin', 'Explore Fes el-Bali', 'Tanneries'],
      'bestTime': 'March to May, September to November',
      'averageCost': 'Low to Medium',
    },
    {
      'id': 'agadir',
      'name': 'Agadir',
      'country': 'Morocco',
      'image': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400',
      'rating': 4.4,
      'reviews': '12K',
      'tags': ['Beach', 'Relaxation', 'Modern'],
      'latitude': 30.4278,
      'longitude': -9.5981,
      'description': 'Coastal city with beautiful beaches and modern amenities',
      'popularActivities': ['Beach activities', 'Water sports', 'Relaxation'],
      'bestTime': 'March to November',
      'averageCost': 'Medium',
    },
    {
      'id': 'tangier',
      'name': 'Tangier',
      'country': 'Morocco',
      'image': 'https://images.unsplash.com/photo-1553603228-0f7051e6ad75?w=400',
      'rating': 4.3,
      'reviews': '10K',
      'tags': ['Coastal', 'Historic', 'Mediterranean'],
      'latitude': 35.7595,
      'longitude': -5.8340,
      'description': 'Gateway between Europe and Africa with rich history',
      'popularActivities': ['Visit Kasbah', 'Explore Medina', 'Beach activities'],
      'bestTime': 'March to November',
      'averageCost': 'Low to Medium',
    },
    {
      'id': 'essaouira',
      'name': 'Essaouira',
      'country': 'Morocco',
      'image': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400',
      'rating': 4.5,
      'reviews': '8K',
      'tags': ['Beach', 'Artistic', 'Relaxed'],
      'latitude': 31.5085,
      'longitude': -9.7595,
      'description': 'Coastal gem with artistic atmosphere and strong winds',
      'popularActivities': ['Wind surfing', 'Art galleries', 'Beach relaxation'],
      'bestTime': 'March to November',
      'averageCost': 'Low to Medium',
    },
    {
      'id': 'chefchaouen',
      'name': 'Chefchaouen',
      'country': 'Morocco',
      'image': 'https://images.unsplash.com/photo-1553603228-0f7051e6ad75?w=400',
      'rating': 4.8,
      'reviews': '14K',
      'tags': ['Blue City', 'Mountains', 'Photography'],
      'latitude': 35.1714,
      'longitude': -5.2697,
      'description': 'Famous blue-painted city in the Rif Mountains',
      'popularActivities': ['Photography', 'Hiking', 'Explore blue streets'],
      'bestTime': 'March to November',
      'averageCost': 'Low to Medium',
    },
    {
      'id': 'rabat',
      'name': 'Rabat',
      'country': 'Morocco',
      'image': 'https://images.unsplash.com/photo-1553603228-0f7051e6ad75?w=400',
      'rating': 4.4,
      'reviews': '11K',
      'tags': ['Capital', 'Historic', 'Modern'],
      'latitude': 34.0209,
      'longitude': -6.8416,
      'description': 'Capital city with rich history and modern development',
      'popularActivities': ['Visit Hassan Tower', 'Explore Kasbah', 'Modern city tour'],
      'bestTime': 'March to November',
      'averageCost': 'Medium',
    },
  ];

  List<Map<String, dynamic>> get _filteredCities {
    List<Map<String, dynamic>> cities = _allCities;

    // Filtrage par recherche
    if (_searchQuery.isNotEmpty) {
      cities = cities.where((city) {
        return city['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
               city['country'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
               city['tags'].any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()));
      }).toList();
    }

    // Filtrage par catégorie
    if (_selectedFilter != 'all') {
      switch (_selectedFilter) {
        case 'beach':
          cities = cities.where((city) => 
            city['tags'].any((tag) => tag.toLowerCase().contains('beach'))).toList();
          break;
        case 'cultural':
          cities = cities.where((city) => 
            city['tags'].any((tag) => tag.toLowerCase().contains('cultural') || 
                                   tag.toLowerCase().contains('historic'))).toList();
          break;
        case 'modern':
          cities = cities.where((city) => 
            city['tags'].any((tag) => tag.toLowerCase().contains('modern'))).toList();
          break;
        case 'mountains':
          cities = cities.where((city) => 
            city['tags'].any((tag) => tag.toLowerCase().contains('mountains'))).toList();
          break;
      }
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
      double distance = Geolocator.distanceBetween(
        latitude,
        longitude,
        city['latitude'],
        city['longitude'],
      );

      if (distance < minDistance) {
        minDistance = distance;
        nearestCity = city['name'];
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
            'name': city['name'],
            'type': 'city',
            'isUserLocation': city['name'] == _detectedCity,
            'location': {
              'latitude': city['latitude'],
              'longitude': city['longitude'],
            },
            'description': city['description'],
            'popularActivities': city['popularActivities'],
            'bestTime': city['bestTime'],
            'averageCost': city['averageCost'],
            'image': city['image'],
            'rating': city['rating'],
            'tags': city['tags'],
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
                    hintText: 'Search cities, countries, or activities...',
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
                      image: NetworkImage(city['image']),
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
                          city['rating'].toString(),
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
                      city['name'],
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
                      city['country'],
                      style: TextStyle(
                        fontSize: subtitleSize,
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: (city['tags'] as List<String>).take(2).map((tag) {
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
                            tag,
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
