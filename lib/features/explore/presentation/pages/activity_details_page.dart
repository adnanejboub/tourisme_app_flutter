import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../core/constants/constants.dart';
import '../../data/services/public_api_service.dart';
import '../../data/models/city_dto.dart';
import 'city_details_page.dart';

class ActivityDetailsPage extends StatefulWidget {
  final int activityId;

  const ActivityDetailsPage({
    super.key,
    required this.activityId,
  });

  @override
  State<ActivityDetailsPage> createState() => _ActivityDetailsPageState();
}

class _ActivityDetailsPageState extends State<ActivityDetailsPage>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late TabController _tabController;
  bool _isLoading = false;
  bool _isFavorite = false;
  
  // API service
  late PublicApiService _apiService;
  
  // Dynamic data
  Map<String, dynamic>? _activityDetails;
  Map<String, dynamic>? _cityInfo;
  List<Map<String, dynamic>> _relatedActivities = [];
  List<Map<String, dynamic>> _medias = [];
  Map<String, dynamic>? _statistics;
  
  // Loading states
  bool _isLoadingDetails = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _tabController = TabController(length: 3, vsync: this);
    _apiService = PublicApiService();
    _loadFavoriteStatus();
    _loadActivityDetails();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _loadFavoriteStatus() {
    // TODO: Load favorite status from SharedPreferences or API
    setState(() {
      _isFavorite = false;
    });
  }

  Future<void> _loadActivityDetails() async {
    try {
      setState(() {
        _isLoadingDetails = true;
        _errorMessage = null;
      });

      final details = await _apiService.getActivityDetails(widget.activityId);
      
      setState(() {
        _activityDetails = details;
        _cityInfo = details['city'] as Map<String, dynamic>?;
        _relatedActivities = List<Map<String, dynamic>>.from(details['relatedActivities'] ?? []);
        _medias = List<Map<String, dynamic>>.from(details['medias'] ?? []);
        _statistics = details['statistics'] as Map<String, dynamic>?;
        _isLoadingDetails = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoadingDetails = false;
      });
    }
  }

  void _onTabChanged(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    _tabController.animateTo(index);
  }

  Future<void> _toggleFavorite() async {
    setState(() {
      _isFavorite = !_isFavorite;
    });

    // TODO: Save to SharedPreferences or send to API
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

  Future<void> _shareActivity() async {
    // TODO: Implement sharing with share_plus package
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share functionality coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _navigateToCity() {
    if (_cityInfo != null) {
      // Convert the city info to the format expected by CityDetailsPage
      final cityMap = {
        'id': _cityInfo!['idVille'],
        'nomVille': _cityInfo!['nomVille'],
        'name': _cityInfo!['nomVille'],
        'description': _cityInfo!['description'] ?? '',
        'imageUrl': _cityInfo!['imageUrl'] ?? '',
        'image': _cityInfo!['imageUrl'] ?? '',
        'latitude': _cityInfo!['latitude'],
        'longitude': _cityInfo!['longitude'],
        'paysNom': _cityInfo!['paysNom'],
        'climatNom': _cityInfo!['climatNom'],
        'isPlage': _cityInfo!['isPlage'],
        'isMontagne': _cityInfo!['isMontagne'],
        'isDesert': _cityInfo!['isDesert'],
        'isRiviera': _cityInfo!['isRiviera'],
        'isHistorique': _cityInfo!['isHistorique'],
        'isCulturelle': _cityInfo!['isCulturelle'],
        'isModerne': _cityInfo!['isModerne'],
        'noteMoyenne': _cityInfo!['noteMoyenne'],
        'rating': _cityInfo!['noteMoyenne'],
      };

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CityDetailsPage(city: cityMap),
        ),
      );
    }
  }

  void _navigateToRelatedActivity(int activityId) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ActivityDetailsPage(activityId: activityId),
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

    if (_isLoadingDetails) {
      return Scaffold(
        backgroundColor: colorScheme.background,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: colorScheme.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading activity details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onBackground,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onBackground.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadActivityDetails,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(colorScheme, isTablet, isDesktop),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildActivityOverview(colorScheme, isTablet, isDesktop),
                _buildActivityInfo(colorScheme, isTablet, isDesktop),
                _buildRelatedActivities(colorScheme, isTablet, isDesktop),
                const SizedBox(height: 20),
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
            _buildActivityInfoOverlay(isTablet, isDesktop),
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
          onPressed: _shareActivity,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHeroImage() {
    return CachedNetworkImage(
      imageUrl: _activityDetails?['imageUrl'] ?? '',
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
          child: Icon(Icons.local_activity, size: 50, color: Colors.grey),
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

  Widget _buildActivityInfoOverlay(bool isTablet, bool isDesktop) {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _activityDetails?['nom'] ?? 'Unknown Activity',
            style: TextStyle(
              color: Colors.white,
              fontSize: isDesktop ? 36 : (isTablet ? 32 : 28),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _cityInfo?['nomVille'] ?? 'Unknown City',
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
                '${_activityDetails?['noteMoyenne'] ?? 0.0}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 16),
              if (_activityDetails?['categorie'] != null) ...[
                const Icon(Icons.category, color: Colors.white70, size: 20),
                const SizedBox(width: 8),
                Text(
                  _activityDetails!['categorie'].toString().replaceAll('_', ' '),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityOverview(ColorScheme colorScheme, bool isTablet, bool isDesktop) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Activity name and category
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _activityDetails?['nom'] ?? 'Unknown Activity',
                      style: TextStyle(
                        fontSize: isDesktop ? 28 : (isTablet ? 26 : 24),
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onBackground,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (_activityDetails?['categorie'] != null)
                      Text(
                        _activityDetails!['categorie'].toString().replaceAll('_', ' '),
                        style: TextStyle(
                          fontSize: isDesktop ? 18 : (isTablet ? 16 : 14),
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
              // Rating badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, color: colorScheme.primary, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${_activityDetails?['noteMoyenne'] ?? 0.0}',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Description
          if (_activityDetails?['description'] != null)
            Text(
              _activityDetails!['description'],
              style: TextStyle(
                fontSize: isDesktop ? 16 : (isTablet ? 15 : 14),
                color: colorScheme.onBackground.withOpacity(0.8),
                height: 1.5,
              ),
            ),
          const SizedBox(height: 20),
          // Info cards
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
          'Duration',
          _buildDurationText(),
          colorScheme,
        ),
        const SizedBox(width: 16),
        _buildInfoCard(
          Icons.attach_money,
          'Price',
          _buildPriceText(),
          colorScheme,
        ),
        const SizedBox(width: 16),
        _buildInfoCard(
          Icons.trending_up,
          'Difficulty',
          _activityDetails?['niveauDificulta'] ?? 'N/A',
          colorScheme,
        ),
      ],
    );
  }

  String _buildDurationText() {
    final min = _activityDetails?['dureeMinimun'];
    final max = _activityDetails?['dureeMaximun'];
    if (min != null && max != null) {
      return '$min-$max min';
    } else if (min != null) {
      return '$min+ min';
    } else if (max != null) {
      return 'Up to $max min';
    }
    return 'N/A';
  }

  String _buildPriceText() {
    final price = _activityDetails?['prix'];
    if (price != null) {
      return '${price.toStringAsFixed(0)} MAD';
    }
    return 'Contact for price';
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
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityInfo(ColorScheme colorScheme, bool isTablet, bool isDesktop) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activity Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          // Activity details
          _buildActivityDetailRow('Season', _activityDetails?['saison'] ?? 'N/A', Icons.calendar_today, colorScheme),
          _buildActivityDetailRow('Difficulty', _activityDetails?['niveauDificulta'] ?? 'N/A', Icons.trending_up, colorScheme),
          if (_activityDetails?['conditionsSpeciales'] != null)
            _buildActivityDetailRow('Special Conditions', _activityDetails!['conditionsSpeciales'], Icons.info_outline, colorScheme),
          _buildActivityDetailRow('Availability', _activityDetails?['isDisponible'] == true ? 'Available' : 'Not Available', Icons.check_circle, colorScheme),
          const SizedBox(height: 16),
          // City information
          if (_cityInfo != null)
            InkWell(
              onTap: _navigateToCity,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_city, color: colorScheme.primary, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Located in ${_cityInfo!['nomVille']}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap to explore the city',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.primary.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, color: colorScheme.primary, size: 16),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActivityDetailRow(String label, String value, IconData icon, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: colorScheme.primary, size: 20),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedActivities(ColorScheme colorScheme, bool isTablet, bool isDesktop) {
    if (_relatedActivities.isEmpty) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Related Activities',
            style: TextStyle(
              fontSize: isDesktop ? 20 : (isTablet ? 18 : 16),
              fontWeight: FontWeight.bold,
              color: colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _relatedActivities.length,
              itemBuilder: (context, index) {
                final activity = _relatedActivities[index];
                return _buildRelatedActivityCard(activity, colorScheme);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedActivityCard(Map<String, dynamic> activity, ColorScheme colorScheme) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _navigateToRelatedActivity(activity['idActivite']),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  color: Colors.grey[200],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: CachedNetworkImage(
                    imageUrl: activity['imageUrl'] ?? '',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.local_activity, color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity['nom'] ?? 'Unknown',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        '${activity['noteMoyenne'] ?? 0.0}',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurface.withOpacity(0.7),
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
}
