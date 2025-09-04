import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../core/constants/constants.dart';
import '../../data/services/public_api_service.dart';

class ServiceDetailsPage extends StatefulWidget {
  final int serviceId;

  const ServiceDetailsPage({super.key, required this.serviceId});

  @override
  State<ServiceDetailsPage> createState() => _ServiceDetailsPageState();
}

class _ServiceDetailsPageState extends State<ServiceDetailsPage> with TickerProviderStateMixin {
  late PageController _pageController;
  late TabController _tabController;
  late PublicApiService _apiService;

  bool _isFavorite = false;
  bool _isLoadingDetails = true;
  String? _errorMessage;

  Map<String, dynamic>? _serviceDetails;
  Map<String, dynamic>? _cityInfo;
  List<Map<String, dynamic>> _relatedServices = [];
  List<Map<String, dynamic>> _medias = [];
  Map<String, dynamic>? _statistics;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _tabController = TabController(length: 3, vsync: this);
    _apiService = PublicApiService();
    _loadServiceDetails();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadServiceDetails() async {
    try {
      setState(() {
        _isLoadingDetails = true;
        _errorMessage = null;
      });
      final details = await _apiService.getServiceDetails(widget.serviceId);
      setState(() {
        _serviceDetails = details;
        _cityInfo = details['city'] as Map<String, dynamic>?;
        _relatedServices = List<Map<String, dynamic>>.from(details['relatedServices'] ?? []);
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 900;

    if (_isLoadingDetails) {
      return Scaffold(
        backgroundColor: colorScheme.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: colorScheme.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: colorScheme.error),
              const SizedBox(height: 16),
              Text('Error loading service details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: colorScheme.onBackground)),
              const SizedBox(height: 8),
              Text(_errorMessage!, style: TextStyle(fontSize: 14, color: colorScheme.onBackground.withOpacity(0.7)), textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _loadServiceDetails, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    final String typeService = (_serviceDetails?['typeService'] ?? '').toString();
    final String displayName = typeService.isNotEmpty ? typeService : 'Service';

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(displayName, colorScheme, isTablet, isDesktop),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildOverview(colorScheme, isTablet, isDesktop, displayName),
                _buildDetailsCard(colorScheme),
                _buildRelatedServices(colorScheme, isTablet, isDesktop),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(String title, ColorScheme colorScheme, bool isTablet, bool isDesktop) {
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
            _buildTitleOverlay(title, isTablet, isDesktop),
          ],
        ),
      ),
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), shape: BoxShape.circle),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), shape: BoxShape.circle),
            child: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border, color: _isFavorite ? Colors.red : Colors.white),
          ),
          onPressed: () => setState(() => _isFavorite = !_isFavorite),
        ),
      ],
    );
  }

  Widget _buildHeroImage() {
    final imageUrl = _medias.isNotEmpty ? (_medias.first['nomMedia'] ?? '') : '';
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(color: Colors.grey[300], child: const Center(child: CircularProgressIndicator())),
      errorWidget: (context, url, error) => Container(color: Colors.grey[300], child: const Center(child: Icon(Icons.store, size: 50, color: Colors.grey))),
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
        ),
      ),
    );
  }

  Widget _buildTitleOverlay(String title, bool isTablet, bool isDesktop) {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: Colors.white, fontSize: isDesktop ? 36 : (isTablet ? 32 : 28), fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (_cityInfo != null)
            Text(
              _cityInfo!['nomVille'] ?? 'Unknown City',
              style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: isDesktop ? 20 : (isTablet ? 18 : 16)),
            ),
        ],
      ),
    );
  }

  Widget _buildOverview(ColorScheme colorScheme, bool isTablet, bool isDesktop, String title) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontSize: isDesktop ? 28 : (isTablet ? 26 : 24), fontWeight: FontWeight.bold, color: colorScheme.onBackground)),
                    const SizedBox(height: 4),
                    if (_serviceDetails?['typeService'] != null)
                      Text(
                        _serviceDetails!['typeService'].toString(),
                        style: TextStyle(fontSize: isDesktop ? 18 : (isTablet ? 16 : 14), color: colorScheme.primary, fontWeight: FontWeight.w600),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_serviceDetails?['description'] != null)
            Text(
              _serviceDetails!['description'],
              style: TextStyle(fontSize: isDesktop ? 16 : (isTablet ? 15 : 14), color: colorScheme.onBackground.withOpacity(0.8), height: 1.5),
            ),
          const SizedBox(height: 20),
          _buildInfoCards(colorScheme),
        ],
      ),
    );
  }

  Widget _buildInfoCards(ColorScheme colorScheme) {
    final bool hasMedias = _statistics?['hasMedias'] == true;
    final bool cityPresent = _statistics?['cityPresent'] == true;
    return Row(
      children: [
        _buildInfoCard(Icons.photo_library, 'Gallery', hasMedias ? 'Available' : 'N/A', colorScheme),
        const SizedBox(width: 16),
        _buildInfoCard(Icons.location_city, 'City', cityPresent ? (_cityInfo?['nomVille'] ?? 'Yes') : 'N/A', colorScheme),
        const SizedBox(width: 16),
        _buildInfoCard(Icons.category, 'Type', _serviceDetails?['typeService']?.toString() ?? 'N/A', colorScheme),
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
          border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: colorScheme.primary, size: 24),
            const SizedBox(height: 8),
            Text(title, style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withOpacity(0.6), fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 14, color: colorScheme.onSurface, fontWeight: FontWeight.w600), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard(ColorScheme colorScheme) {
    final fournisseur = _serviceDetails?['fournisseur'] as Map<String, dynamic>?;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Service Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
          const SizedBox(height: 16),
          if (fournisseur != null) ...[
            _buildDetailRow('Provider', fournisseur['nom'] ?? 'N/A', Icons.store, colorScheme),
            if (fournisseur['email'] != null) _buildDetailRow('Email', fournisseur['email'], Icons.email, colorScheme),
            if (fournisseur['telephone'] != null) _buildDetailRow('Phone', fournisseur['telephone'], Icons.phone, colorScheme),
            const SizedBox(height: 8),
          ],
          if (_cityInfo != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: colorScheme.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: colorScheme.primary.withOpacity(0.3))),
              child: Row(
                children: [
                  Icon(Icons.location_city, color: colorScheme.primary, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Located in ${_cityInfo!['nomVille']}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colorScheme.primary)),
                      const SizedBox(height: 4),
                      Text('Tap back to explore the city', style: TextStyle(fontSize: 12, color: colorScheme.primary.withOpacity(0.7))),
                    ]),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: colorScheme.primary, size: 20),
          const SizedBox(width: 12),
          Text('$label: ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
          Expanded(child: Text(value, style: TextStyle(fontSize: 14, color: colorScheme.onSurface.withOpacity(0.8)))),
        ],
      ),
    );
  }

  Widget _buildRelatedServices(ColorScheme colorScheme, bool isTablet, bool isDesktop) {
    if (_relatedServices.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Related Services', style: TextStyle(fontSize: isDesktop ? 20 : (isTablet ? 18 : 16), fontWeight: FontWeight.bold, color: colorScheme.onBackground)),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _relatedServices.length,
              itemBuilder: (context, index) {
                final service = _relatedServices[index];
                return _buildRelatedServiceCard(service, colorScheme);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedServiceCard(Map<String, dynamic> service, ColorScheme colorScheme) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ServiceDetailsPage(serviceId: service['idService'])),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(borderRadius: const BorderRadius.vertical(top: Radius.circular(12)), color: Colors.grey[200]),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: CachedNetworkImage(
                    imageUrl: service['imageUrl'] ?? '',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    placeholder: (context, url) => Container(color: Colors.grey[300], child: const Center(child: CircularProgressIndicator())),
                    errorWidget: (context, url, error) => Container(color: Colors.grey[300], child: const Icon(Icons.store, color: Colors.grey)),
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
                    (service['typeService'] ?? '').toString(),
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colorScheme.onSurface),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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


