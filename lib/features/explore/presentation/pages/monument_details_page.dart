import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../core/constants/constants.dart';
import '../../data/services/public_api_service.dart';
import '../../data/models/city_dto.dart';
import 'city_details_page.dart';

class MonumentDetailsPage extends StatefulWidget {
  final int monumentId;

  const MonumentDetailsPage({
    super.key,
    required this.monumentId,
  });

  @override
  State<MonumentDetailsPage> createState() => _MonumentDetailsPageState();
}

class _MonumentDetailsPageState extends State<MonumentDetailsPage>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late TabController _tabController;
  bool _isLoading = false;
  bool _isFavorite = false;
  
  // API service
  late PublicApiService _apiService;
  
  // Dynamic data
  Map<String, dynamic>? _monumentDetails;
  Map<String, dynamic>? _cityInfo;
  List<Map<String, dynamic>> _relatedMonuments = [];
  
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
    _loadMonumentDetails();
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

  Future<void> _loadMonumentDetails() async {
    try {
      setState(() {
        _isLoadingDetails = true;
        _errorMessage = null;
      });

      final details = await _apiService.getMonumentDetails(widget.monumentId);
      
      setState(() {
        _monumentDetails = details;
        _cityInfo = details['city'] as Map<String, dynamic>?;
        _relatedMonuments = List<Map<String, dynamic>>.from(details['relatedMonuments'] ?? []);
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

  Future<void> _shareMonument() async {
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

  void _navigateToRelatedMonument(int monumentId) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MonumentDetailsPage(monumentId: monumentId),
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
                'Error loading monument details',
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
                onPressed: _loadMonumentDetails,
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
                _buildMonumentOverview(colorScheme, isTablet, isDesktop),
                _buildMonumentInfo(colorScheme, isTablet, isDesktop),
                _buildRelatedMonuments(colorScheme, isTablet, isDesktop),
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
            _buildMonumentInfoOverlay(isTablet, isDesktop),
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
          onPressed: _shareMonument,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHeroImage() {
    return CachedNetworkImage(
      imageUrl: _monumentDetails?['imageUrl'] ?? '',
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
          child: Icon(Icons.location_city, size: 50, color: Colors.grey),
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

  Widget _buildMonumentInfoOverlay(bool isTablet, bool isDesktop) {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _monumentDetails?['nomMonument'] ?? 'Unknown Monument',
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
                '${_monumentDetails?['notesMoyennes'] ?? 0.0}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 16),
              if (_monumentDetails?['typeMonument'] != null) ...[
                const Icon(Icons.category, color: Colors.white70, size: 20),
                const SizedBox(width: 8),
                Text(
                  _monumentDetails!['typeMonument'],
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

  Widget _buildMonumentOverview(ColorScheme colorScheme, bool isTablet, bool isDesktop) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Monument name and type
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _monumentDetails?['nomMonument'] ?? 'Unknown Monument',
                      style: TextStyle(
                        fontSize: isDesktop ? 28 : (isTablet ? 26 : 24),
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onBackground,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (_monumentDetails?['typeMonument'] != null)
                      Text(
                        _monumentDetails!['typeMonument'],
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
                      '${_monumentDetails?['notesMoyennes'] ?? 0.0}',
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
          if (_monumentDetails?['description'] != null)
            Text(
              _monumentDetails!['description'],
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
          Icons.location_on,
          'Address',
          _monumentDetails?['adresseMonument'] ?? 'N/A',
          colorScheme,
        ),
        const SizedBox(width: 16),
        _buildInfoCard(
          Icons.access_time,
          'Hours',
          _monumentDetails?['horairesOuverture'] ?? 'N/A',
          colorScheme,
        ),
        const SizedBox(width: 16),
        _buildInfoCard(
          Icons.attach_money,
          'Price',
          _monumentDetails?['gratuit'] == true 
              ? 'Free' 
              : (_monumentDetails?['prix'] != null 
                  ? '${_monumentDetails!['prix']} MAD' 
                  : 'N/A'),
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
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonumentInfo(ColorScheme colorScheme, bool isTablet, bool isDesktop) {
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
            'Monument Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          // Historical and cultural significance
          if (_monumentDetails?['hasHistorique'] != null || _monumentDetails?['hasCulturelle'] != null)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (_monumentDetails?['hasHistorique'] != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.history_edu, color: Colors.orange, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Historical: ${_monumentDetails!['hasHistorique']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_monumentDetails?['hasCulturelle'] != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.purple.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.museum, color: Colors.purple, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Cultural: ${_monumentDetails!['hasCulturelle']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.purple,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
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

  Widget _buildRelatedMonuments(ColorScheme colorScheme, bool isTablet, bool isDesktop) {
    if (_relatedMonuments.isEmpty) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Related Monuments',
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
              itemCount: _relatedMonuments.length,
              itemBuilder: (context, index) {
                final monument = _relatedMonuments[index];
                return _buildRelatedMonumentCard(monument, colorScheme);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedMonumentCard(Map<String, dynamic> monument, ColorScheme colorScheme) {
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
        onTap: () => _navigateToRelatedMonument(monument['idMonument']),
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
                    imageUrl: monument['imageUrl'] ?? '',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.location_city, color: Colors.grey),
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
                    monument['nomMonument'] ?? 'Unknown',
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
                        '${monument['notesMoyennes'] ?? 0.0}',
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
