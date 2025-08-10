import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../core/constants/constants.dart';
import 'itinerary_planning_page.dart';

class CityDetailsPage extends StatefulWidget {
  final Map<String, dynamic> city;

  const CityDetailsPage({
    super.key,
    required this.city,
  });

  @override
  State<CityDetailsPage> createState() => _CityDetailsPageState();
}

class _CityDetailsPageState extends State<CityDetailsPage>
    with TickerProviderStateMixin {
  int _selectedTabIndex = 0;
  late PageController _pageController;
  late TabController _tabController;
  bool _isLoading = false;
  bool _isFavorite = false;

  // Données des activités pour chaque ville (à remplacer par un service API)
  static const Map<String, List<Map<String, dynamic>>> _cityActivitiesData = {
    'Casablanca': [
      {
        'id': 'hassan_mosque',
        'name': 'Hassan II Mosque',
        'type': 'Cultural',
        'image': 'https://images.unsplash.com/photo-1553603228-0f7051e6ad75?w=400',
        'rating': 4.8,
        'duration': '2-3 hours',
        'price': 'Free',
        'description': 'Largest mosque in Morocco with stunning ocean views',
        'location': 'Boulevard de la Corniche',
        'bestTime': 'Morning or sunset',
      },
      {
        'id': 'medina',
        'name': 'Old Medina',
        'type': 'Historic',
        'image': 'https://images.unsplash.com/photo-1553603228-0f7051e6ad75?w=400',
        'rating': 4.5,
        'duration': '3-4 hours',
        'price': 'Free',
        'description': 'Historic quarter with traditional markets and architecture',
        'location': 'Old City Center',
        'bestTime': 'Morning or late afternoon',
      },
      {
        'id': 'corniche',
        'name': 'Corniche Beach',
        'type': 'Beach',
        'image': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400',
        'rating': 4.3,
        'duration': '2-6 hours',
        'price': 'Free',
        'description': 'Popular beach area with restaurants and activities',
        'location': 'Coastal area',
        'bestTime': 'Afternoon to sunset',
      },
    ],
    'Marrakech': [
      {
        'id': 'jemaa_elfnaa',
        'name': 'Jemaa el-Fnaa',
        'type': 'Cultural',
        'image': 'https://images.unsplash.com/photo-1518548419970-58e3b4079ab2?w=400',
        'rating': 4.7,
        'duration': '2-4 hours',
        'price': 'Free',
        'description': 'Famous square with street performers and food stalls',
        'location': 'Medina center',
        'bestTime': 'Evening',
      },
      {
        'id': 'majorelle',
        'name': 'Majorelle Garden',
        'type': 'Nature',
        'image': 'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?w=400',
        'rating': 4.6,
        'duration': '1-2 hours',
        'price': '70 MAD',
        'description': 'Beautiful botanical garden with blue architecture',
        'location': 'Gueliz district',
        'bestTime': 'Morning',
      },
      {
        'id': 'bahia_palace',
        'name': 'Bahia Palace',
        'type': 'Historic',
        'image': 'https://images.unsplash.com/photo-1553603228-0f7051e6ad75?w=400',
        'rating': 4.4,
        'duration': '1-2 hours',
        'price': '70 MAD',
        'description': '19th-century palace with beautiful gardens',
        'location': 'Medina',
        'bestTime': 'Morning or afternoon',
      },
    ],
    'Fes': [
      {
        'id': 'al_qarawiyyin',
        'name': 'Al-Qarawiyyin University',
        'type': 'Historic',
        'image': 'https://images.unsplash.com/photo-1553603228-0f7051e6ad75?w=400',
        'rating': 4.7,
        'duration': '1-2 hours',
        'price': 'Free',
        'description': 'Oldest university in the world',
        'location': 'Fes el-Bali',
        'bestTime': 'Morning',
      },
      {
        'id': 'tanneries',
        'name': 'Chouara Tanneries',
        'type': 'Cultural',
        'image': 'https://images.unsplash.com/photo-1553603228-0f7051e6ad75?w=400',
        'rating': 4.5,
        'duration': '1 hour',
        'price': 'Free',
        'description': 'Traditional leather tanning workshops',
        'location': 'Fes el-Bali',
        'bestTime': 'Morning',
      },
    ],
  };

  // Données des hébergements pour chaque ville (à remplacer par un service API)
  static const Map<String, List<Map<String, dynamic>>> _cityHotelsData = {
    'Casablanca': [
      {
        'id': 'hilton_casablanca',
        'name': 'Hilton Casablanca',
        'type': 'Luxury',
        'image': 'https://images.unsplash.com/photo-1553603228-0f7051e6ad75?w=400',
        'rating': 4.6,
        'price': 'From 1200 MAD',
        'location': 'City Center',
        'amenities': ['WiFi', 'Pool', 'Spa', 'Restaurant'],
        'description': 'Modern luxury hotel in the heart of Casablanca',
      },
      {
        'id': 'ibis_casablanca',
        'name': 'Ibis Casablanca City Center',
        'type': 'Mid-range',
        'image': 'https://images.unsplash.com/photo-1553603228-0f7051e6ad75?w=400',
        'rating': 4.2,
        'price': 'From 600 MAD',
        'location': 'City Center',
        'amenities': ['WiFi', 'Restaurant', 'Bar'],
        'description': 'Comfortable hotel with great location',
      },
    ],
    'Marrakech': [
      {
        'id': 'riad_marrakech',
        'name': 'Riad Marrakech',
        'type': 'Traditional',
        'image': 'https://images.unsplash.com/photo-1518548419970-58e3b4079ab2?w=400',
        'rating': 4.8,
        'price': 'From 800 MAD',
        'location': 'Medina',
        'amenities': ['WiFi', 'Terrace', 'Traditional decor'],
        'description': 'Authentic Moroccan riad experience',
      },
      {
        'id': 'palmeraie_resort',
        'name': 'Palmeraie Resort',
        'type': 'Luxury',
        'image': 'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?w=400',
        'rating': 4.7,
        'price': 'From 2000 MAD',
        'location': 'Palmeraie',
        'amenities': ['WiFi', 'Pool', 'Spa', 'Golf', 'Restaurant'],
        'description': 'Luxury resort in the palm grove',
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _tabController = TabController(length: 3, vsync: this);
    _loadFavoriteStatus();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _loadFavoriteStatus() {
    // TODO: Charger le statut favori depuis SharedPreferences ou API
    setState(() {
      _isFavorite = false;
    });
  }

  List<Map<String, dynamic>> get _currentActivities {
    return _cityActivitiesData[widget.city['name']] ?? [];
  }

  List<Map<String, dynamic>> get _currentHotels {
    return _cityHotelsData[widget.city['name']] ?? [];
  }

  void _onTabChanged(int index) {
    if (_selectedTabIndex != index) {
      setState(() {
        _selectedTabIndex = index;
      });
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _tabController.animateTo(index);
    }
  }

  Future<void> _toggleFavorite() async {
    setState(() {
      _isFavorite = !_isFavorite;
    });

    // TODO: Sauvegarder dans SharedPreferences ou envoyer à l'API
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            _isFavorite
                ? 'Added to favorites'
                : 'Removed from favorites'
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _shareCity() async {
    // TODO: Implémenter le partage avec share_plus package
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share functionality coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _planItinerary() {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItineraryPlanningPage(
          destination: {
            'name': widget.city['name'],
            'type': 'city',
            'isUserLocation': widget.city['isUserLocation'] ?? false,
            'location': widget.city['location'],
            'description': widget.city['description'],
            'popularActivities': widget.city['popularActivities'],
            'bestTime': widget.city['bestTime'],
            'averageCost': widget.city['averageCost'],
            'image': widget.city['image'],
            'rating': widget.city['rating'],
            'tags': widget.city['tags'],
            'activities': _currentActivities,
            'hotels': _currentHotels,
          },
        ),
      ),
    ).whenComplete(() {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(colorScheme, isTablet, isDesktop),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildCityDescription(colorScheme, isTablet, isDesktop),
                _buildTabBar(colorScheme),
                const SizedBox(height: 20),
                _buildTabContent(colorScheme, isTablet, isDesktop),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(ColorScheme colorScheme, bool isTablet, bool isDesktop) {
    return SliverAppBar(
      expandedHeight: isDesktop ? 400 : (isTablet ? 350 : 300),
      floating: false,
      pinned: true,
      backgroundColor: colorScheme.background,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            _buildHeroImage(),
            _buildGradientOverlay(),
            _buildCityInfo(isTablet, isDesktop),
          ],
        ),
      ),
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : Colors.white,
            ),
          ),
          onPressed: _toggleFavorite,
        ),
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.share, color: Colors.white),
          ),
          onPressed: _shareCity,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHeroImage() {
    return CachedNetworkImage(
      imageUrl: widget.city['image'] ?? '',
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: Colors.grey[300],
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[300],
        child: const Center(
          child: Icon(Icons.error, size: 50, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
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
    );
  }

  Widget _buildCityInfo(bool isTablet, bool isDesktop) {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.city['name'] ?? 'Unknown City',
            style: TextStyle(
              color: Colors.white,
              fontSize: isDesktop ? 36 : (isTablet ? 32 : 28),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.city['country'] ?? 'Unknown Country',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: isDesktop ? 20 : (isTablet ? 18 : 16),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 20),
              const SizedBox(width: 8),
              Text(
                '${widget.city['rating'] ?? 0.0}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.location_on, color: Colors.white70, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.city['tags'] != null
                      ? (widget.city['tags'] as List).join(', ')
                      : '',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCityDescription(ColorScheme colorScheme, bool isTablet, bool isDesktop) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About ${widget.city['name'] ?? 'this city'}',
            style: TextStyle(
              fontSize: isDesktop ? 24 : (isTablet ? 22 : 20),
              fontWeight: FontWeight.bold,
              color: colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.city['description'] ?? 'No description available.',
            style: TextStyle(
              fontSize: isDesktop ? 16 : (isTablet ? 15 : 14),
              color: colorScheme.onBackground.withOpacity(0.8),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          _buildInfoCards(colorScheme),
        ],
      ),
    );
  }

  Widget _buildInfoCards(ColorScheme colorScheme) {
    return Row(
      children: [
        _buildInfoCard(
          Icons.access_time,
          'Best Time',
          widget.city['bestTime'] ?? 'N/A',
          colorScheme,
        ),
        const SizedBox(width: 16),
        _buildInfoCard(
          Icons.attach_money,
          'Average Cost',
          widget.city['averageCost'] ?? 'N/A',
          colorScheme,
        ),
        const SizedBox(width: 16),
        _buildInfoCard(
          Icons.star,
          'Rating',
          '${widget.city['rating'] ?? 0.0}/5',
          colorScheme,
        ),
      ],
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String value, ColorScheme colorScheme) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: colorScheme.primary, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar(ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton('Activities', 0, Icons.explore, colorScheme),
          ),
          Expanded(
            child: _buildTabButton('Hotels', 1, Icons.hotel, colorScheme),
          ),
          Expanded(
            child: _buildTabButton('Plan Trip', 2, Icons.map, colorScheme),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, int index, IconData icon, ColorScheme colorScheme) {
    final isSelected = _selectedTabIndex == index;

    return GestureDetector(
      onTap: () => _onTabChanged(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : colorScheme.onSurface.withOpacity(0.6),
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : colorScheme.onSurface.withOpacity(0.6),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(ColorScheme colorScheme, bool isTablet, bool isDesktop) {
    return SizedBox(
      height: isDesktop ? 600 : (isTablet ? 550 : 500),
      child: PageView(
        controller: _pageController,
        onPageChanged: _onTabChanged,
        children: [
          _buildActivitiesTab(colorScheme, isTablet, isDesktop),
          _buildHotelsTab(colorScheme, isTablet, isDesktop),
          _buildPlanTripTab(colorScheme, isTablet, isDesktop),
        ],
      ),
    );
  }

  Widget _buildActivitiesTab(ColorScheme colorScheme, bool isTablet, bool isDesktop) {
    if (_currentActivities.isEmpty) {
      return _buildEmptyState(
        'No activities available',
        'Activities will be added soon for this destination.',
        Icons.explore_off,
        colorScheme,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _currentActivities.length,
      itemBuilder: (context, index) {
        final activity = _currentActivities[index];
        return _buildActivityCard(activity, colorScheme, isTablet, isDesktop);
      },
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> activity, ColorScheme colorScheme, bool isTablet, bool isDesktop) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to activity details
        },
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            _buildActivityImage(activity, isTablet, isDesktop),
            Expanded(
              child: _buildActivityInfo(activity, colorScheme, isTablet, isDesktop),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityImage(Map<String, dynamic> activity, bool isTablet, bool isDesktop) {
    final size = isDesktop ? 120.0 : (isTablet ? 100.0 : 80.0);

    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          bottomLeft: Radius.circular(16),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          bottomLeft: Radius.circular(16),
        ),
        child: CachedNetworkImage(
          imageUrl: activity['image'] ?? '',
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey[300],
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[300],
            child: const Center(
              child: Icon(Icons.image_not_supported, color: Colors.grey),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityInfo(Map<String, dynamic> activity, ColorScheme colorScheme, bool isTablet, bool isDesktop) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            activity['name'] ?? 'Unknown Activity',
            style: TextStyle(
              fontSize: isDesktop ? 18 : (isTablet ? 16 : 14),
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              activity['type'] ?? 'Activity',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            activity['description'] ?? 'No description available.',
            style: TextStyle(
              fontSize: isDesktop ? 14 : (isTablet ? 13 : 12),
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.access_time, size: 14, color: colorScheme.onSurface.withOpacity(0.6)),
              const SizedBox(width: 4),
              Text(
                activity['duration'] ?? 'N/A',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.attach_money, size: 14, color: colorScheme.onSurface.withOpacity(0.6)),
              const SizedBox(width: 4),
              Text(
                activity['price'] ?? 'N/A',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(Icons.star, size: 14, color: Colors.amber),
                  const SizedBox(width: 2),
                  Text(
                    '${activity['rating'] ?? 0.0}',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurface.withOpacity(0.8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHotelsTab(ColorScheme colorScheme, bool isTablet, bool isDesktop) {
    if (_currentHotels.isEmpty) {
      return _buildEmptyState(
        'No hotels available',
        'Hotel recommendations will be added soon for this destination.',
        Icons.hotel_outlined,
        colorScheme,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _currentHotels.length,
      itemBuilder: (context, index) {
        final hotel = _currentHotels[index];
        return _buildHotelCard(hotel, colorScheme, isTablet, isDesktop);
      },
    );
  }

  Widget _buildHotelCard(Map<String, dynamic> hotel, ColorScheme colorScheme, bool isTablet, bool isDesktop) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to hotel details
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            _buildHotelImage(hotel, isTablet, isDesktop),
            _buildHotelInfo(hotel, colorScheme, isTablet, isDesktop),
          ],
        ),
      ),
    );
  }

  Widget _buildHotelImage(Map<String, dynamic> hotel, bool isTablet, bool isDesktop) {
    return Container(
      height: isDesktop ? 200 : (isTablet ? 180 : 160),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: CachedNetworkImage(
          imageUrl: hotel['image'] ?? '',
          width: double.infinity,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey[300],
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[300],
            child: const Center(
              child: Icon(Icons.hotel_outlined, size: 50, color: Colors.grey),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHotelInfo(Map<String, dynamic> hotel, ColorScheme colorScheme, bool isTablet, bool isDesktop) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  hotel['name'] ?? 'Unknown Hotel',
                  style: TextStyle(
                    fontSize: isDesktop ? 18 : (isTablet ? 16 : 14),
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  hotel['type'] ?? 'Hotel',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            hotel['description'] ?? 'No description available.',
            style: TextStyle(
              fontSize: isDesktop ? 14 : (isTablet ? 13 : 12),
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.location_on, size: 14, color: colorScheme.onSurface.withOpacity(0.6)),
              const SizedBox(width: 4),
              Text(
                hotel['location'] ?? 'Unknown Location',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(Icons.star, size: 14, color: Colors.amber),
                  const SizedBox(width: 2),
                  Text(
                    '${hotel['rating'] ?? 0.0}',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurface.withOpacity(0.8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                hotel['price'] ?? 'Price not available',
                style: TextStyle(
                  fontSize: 16,
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (hotel['amenities'] != null)
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: (hotel['amenities'] as List<dynamic>).map((amenity) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    amenity.toString(),
                    style: TextStyle(
                      fontSize: 10,
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildPlanTripTab(ColorScheme colorScheme, bool isTablet, bool isDesktop) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(
            Icons.map,
            size: isDesktop ? 80 : (isTablet ? 70 : 60),
            color: colorScheme.primary.withOpacity(0.6),
          ),
          const SizedBox(height: 24),
          Text(
            'Plan Your Perfect Trip to ${widget.city['name'] ?? 'this destination'}',
                          style: TextStyle(
                fontSize: isDesktop ? 24 : (isTablet ? 22 : 20),
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Create a personalized itinerary with activities, hotels, and travel tips based on your preferences.',
            style: TextStyle(
              fontSize: isDesktop ? 16 : (isTablet ? 15 : 14),
              color: colorScheme.onSurface.withOpacity(0.7),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.primary.withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                Text(
                  'What you\'ll get:',
                  style: TextStyle(
                    fontSize: isDesktop ? 18 : (isTablet ? 16 : 14),
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                _buildFeatureItem(Icons.check_circle, 'Customized daily itinerary', colorScheme),
                _buildFeatureItem(Icons.check_circle, 'Activity recommendations', colorScheme),
                _buildFeatureItem(Icons.check_circle, 'Hotel suggestions', colorScheme),
                _buildFeatureItem(Icons.check_circle, 'Travel tips and timing', colorScheme),
              ],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _isLoading ? null : _planItinerary,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 48 : (isTablet ? 40 : 32),
                vertical: isDesktop ? 20 : (isTablet ? 18 : 16),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: _isLoading
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
                : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.map, size: 20),
                const SizedBox(width: 12),
                Text(
                  'Start Planning',
                  style: TextStyle(
                    fontSize: isDesktop ? 18 : (isTablet ? 16 : 14),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            color: colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String message, IconData icon, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurface.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}