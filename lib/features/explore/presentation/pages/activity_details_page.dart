import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import '../../../../core/services/image_service.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/services/error_handler_service.dart';
import '../../../saved/data/services/wishlist_service.dart';

class ActivityDetailsPage extends StatefulWidget {
  final Map<String, dynamic> activity;

  const ActivityDetailsPage({
    super.key,
    required this.activity,
  });

  @override
  State<ActivityDetailsPage> createState() => _ActivityDetailsPageState();
}

class _ActivityDetailsPageState extends State<ActivityDetailsPage> {
  bool _isFavorite = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();
  }

  Future<void> _loadFavoriteStatus() async {
    try {
      final favs = await WishlistService().fetchFavorites();
      final activityId = _extractActivityId(widget.activity);
      setState(() {
        _isFavorite = favs.any((f) => f['type'] == 'activity' && f['itemId'] == activityId);
      });
    } catch (_) {}
  }

  int _extractActivityId(Map<String, dynamic> activity) {
    final dynamic rawId = activity['id'] ?? activity['idActivite'] ?? activity['id_activity'] ?? activity['idAct'];
    if (rawId is int) return rawId;
    if (rawId is num) return rawId.toInt();
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
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
                _buildActivityOverview(colorScheme, isTablet, isDesktop),
                _buildActivityDetails(colorScheme, isTablet, isDesktop),
                _buildActivityCharacteristics(colorScheme),
                _buildActivityActions(context, colorScheme, isTablet, isDesktop),
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
            _buildActivityInfo(isTablet, isDesktop),
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
          onPressed: () => _shareActivity(context),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHeroImage() {
    final String? providedImageUrl = widget.activity['imageUrl'] ?? widget.activity['image'];
    final String? category = widget.activity['categorie'] ?? widget.activity['typeActivite'] ?? widget.activity['type'] ?? 'Activité';
    final String? activityName = widget.activity['nom'] ?? widget.activity['nomActivite'] ?? widget.activity['name'] ?? 'Activité touristique';
    
    // Utiliser ImageService pour obtenir l'image appropriée
    final String imageUrl = (providedImageUrl?.isNotEmpty == true) 
        ? providedImageUrl! 
        : ImageService.getActivityImage(category, activityName);
    
    if (imageUrl.isEmpty) {
      return Container(
        color: Colors.grey[300],
        child: const Center(
          child: Icon(Icons.local_activity, size: 80, color: Colors.grey),
        ),
      );
    }

    if (ImageService.isLocalAsset(imageUrl)) {
      // Convert relative path to full asset path
      final String assetPath = imageUrl.startsWith('images/') 
          ? 'assets/$imageUrl' 
          : imageUrl;
      
      return Image.asset(
        assetPath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('Error loading image: $assetPath - $error');
          return Container(
            color: Colors.grey[300],
            child: const Center(
              child: Icon(Icons.local_activity, size: 80, color: Colors.grey),
            ),
          );
        },
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: Colors.grey[300],
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      errorWidget: (context, url, error) {
        print('Error loading network image: $url - $error');
        return Container(
          color: Colors.grey[300],
          child: const Center(
            child: Icon(Icons.local_activity, size: 80, color: Colors.grey),
          ),
        );
      },
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

  Widget _buildActivityInfo(bool isTablet, bool isDesktop) {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.activity['nom']?.toString() ?? widget.activity['nomActivite']?.toString() ?? widget.activity['name']?.toString() ?? 'Activité touristique',
            style: TextStyle(
              color: Colors.white,
              fontSize: isDesktop ? 36 : (isTablet ? 32 : 28),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.activity['categorie']?.toString() ?? widget.activity['typeActivite']?.toString() ?? widget.activity['type']?.toString() ?? 'Activité',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: isDesktop ? 20 : (isTablet ? 18 : 16),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (widget.activity['saison'] != null && widget.activity['saison'].toString().isNotEmpty) ...[
                const Icon(Icons.calendar_today, color: Colors.white70, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.activity['saison']?.toString() ?? 'Toute l\'année',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              if (widget.activity['ville'] != null && widget.activity['ville'].toString().isNotEmpty) ...[
                const SizedBox(width: 16),
                const Icon(Icons.location_on, color: Colors.white70, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.activity['ville']?.toString() ?? '',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
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
                      widget.activity['nom']?.toString() ?? widget.activity['nomActivite']?.toString() ?? widget.activity['name']?.toString() ?? 'Activité touristique',
                      style: TextStyle(
                        fontSize: isDesktop ? 28 : (isTablet ? 26 : 24),
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onBackground,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.activity['categorie']?.toString() ?? widget.activity['typeActivite']?.toString() ?? widget.activity['type']?.toString() ?? 'Activité',
                      style: TextStyle(
                        fontSize: isDesktop ? 18 : (isTablet ? 16 : 14),
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              // Price badge
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
                    Icon(Icons.attach_money, color: colorScheme.primary, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      _getPriceText(),
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
          Text(
            (widget.activity['description']?.toString() ?? '').isNotEmpty 
                ? widget.activity['description']!.toString()
                : 'Découvrez cette activité unique au Maroc avec nos guides experts. Une expérience inoubliable vous attend dans cette destination exceptionnelle.',
            style: TextStyle(
              fontSize: isDesktop ? 16 : (isTablet ? 15 : 14),
              color: colorScheme.onBackground.withOpacity(0.8),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          // Activity characteristics
          _buildActivityCharacteristics(colorScheme),
          const SizedBox(height: 20),
          // Detailed activity information
          _buildDetailedActivityInfo(colorScheme, isTablet, isDesktop),
          const SizedBox(height: 20),
          // Info cards
          _buildInfoCards(colorScheme),
        ],
      ),
    );
  }

  Widget _buildDetailedActivityInfo(ColorScheme colorScheme, bool isTablet, bool isDesktop) {
    final String activityName = widget.activity['nom'] ?? widget.activity['nomActivite'] ?? widget.activity['name'] ?? '';
    final String category = widget.activity['categorie'] ?? widget.activity['typeActivite'] ?? widget.activity['type'] ?? '';
    
    return Container(
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
            'Informations Détaillées',
            style: TextStyle(
              fontSize: isDesktop ? 20 : (isTablet ? 18 : 16),
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          
          // Prix et informations financières
          _buildPricingInfo(colorScheme, activityName, category),
          const SizedBox(height: 16),
          
          // Durée et horaires
          _buildDurationInfo(colorScheme),
          const SizedBox(height: 16),
          
          // Informations pratiques
          _buildPracticalInfo(colorScheme, activityName, category),
          const SizedBox(height: 16),
          
          // Recommandations locales
          _buildLocalRecommendations(colorScheme, activityName, category),
        ],
      ),
    );
  }

  Widget _buildPricingInfo(ColorScheme colorScheme, String activityName, String category) {
    final double? prix = widget.activity['prix'] != null ? 
        (widget.activity['prix'] is num ? (widget.activity['prix'] as num).toDouble() : 
         double.tryParse(widget.activity['prix'].toString())) : null;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.attach_money, color: colorScheme.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              'Tarifs',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (prix != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Text(
                  'Prix de base: ',
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
                Text(
                  '${prix.toStringAsFixed(0)} MAD',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _getPriceRange(prix),
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurface.withOpacity(0.6),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getPricingDetails(activityName, category, prix),
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurface.withOpacity(0.7),
              height: 1.4,
            ),
          ),
        ] else ...[
          Text(
            'Prix sur demande - Contactez-nous pour plus d\'informations',
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurface.withOpacity(0.7),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDurationInfo(ColorScheme colorScheme) {
    final int? dureeMin = widget.activity['dureeMinimun'] != null ? 
        (widget.activity['dureeMinimun'] is num ? (widget.activity['dureeMinimun'] as num).toInt() : 
         int.tryParse(widget.activity['dureeMinimun'].toString())) : null;
    final int? dureeMax = widget.activity['dureeMaximun'] != null ? 
        (widget.activity['dureeMaximun'] is num ? (widget.activity['dureeMaximun'] as num).toInt() : 
         int.tryParse(widget.activity['dureeMaximun'].toString())) : null;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.access_time, color: colorScheme.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              'Durée',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (dureeMin != null || dureeMax != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colorScheme.secondary.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (dureeMin != null && dureeMax != null) ...[
                  Text(
                    '${_formatDuration(dureeMin)} - ${_formatDuration(dureeMax)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.secondary,
                    ),
                  ),
                ] else if (dureeMin != null) ...[
                  Text(
                    'Minimum: ${_formatDuration(dureeMin)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.secondary,
                    ),
                  ),
                ] else if (dureeMax != null) ...[
                  Text(
                    'Maximum: ${_formatDuration(dureeMax)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.secondary,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  _getDurationDetails(dureeMin, dureeMax),
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          Text(
            'Durée flexible selon vos préférences',
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurface.withOpacity(0.7),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPracticalInfo(ColorScheme colorScheme, String activityName, String category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.info_outline, color: colorScheme.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              'Informations Pratiques',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPracticalItem('Saison recommandée', _getSeasonInfo(), colorScheme),
              _buildPracticalItem('Niveau de difficulté', _getDifficultyInfo(), colorScheme),
              _buildPracticalItem('Équipement nécessaire', _getEquipmentInfo(activityName, category), colorScheme),
              _buildPracticalItem('Langues parlées', 'Arabe, Français, Anglais', colorScheme),
              _buildPracticalItem('Transport', _getTransportInfo(activityName, category), colorScheme),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocalRecommendations(ColorScheme colorScheme, String activityName, String category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.star, color: Colors.amber, size: 20),
            const SizedBox(width: 8),
            Text(
              'Conseils Locaux',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.amber.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _getLocalRecommendations(activityName, category).map((recommendation) => 
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lightbulb_outline, color: Colors.amber, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        recommendation,
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurface.withOpacity(0.8),
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityCharacteristics(ColorScheme colorScheme) {
    List<Map<String, dynamic>> characteristics = [];
    
    // Add characteristics based on activity data
    final String difficulty = (widget.activity['niveauDificulta']?.toString() ?? '').isNotEmpty 
        ? widget.activity['niveauDificulta']!.toString() 
        : 'Facile';
    Color difficultyColor = Colors.green;
    if (difficulty.toLowerCase().contains('moyen')) {
      difficultyColor = Colors.orange;
    } else if (difficulty.toLowerCase().contains('difficile')) {
      difficultyColor = Colors.red;
    }
    characteristics.add({'icon': Icons.trending_up, 'label': 'Difficulté: $difficulty', 'color': difficultyColor});
    
    final String season = (widget.activity['saison']?.toString() ?? '').isNotEmpty 
        ? widget.activity['saison']!.toString() 
        : 'Toute l\'année';
    characteristics.add({'icon': Icons.calendar_today, 'label': 'Saison: $season', 'color': Colors.blue});

    if (characteristics.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Caractéristiques de l\'activité',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: colorScheme.onBackground,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: characteristics.map((char) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: (char['color'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: (char['color'] as Color).withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    char['icon'] as IconData,
                    size: 16,
                    color: char['color'] as Color,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    char['label'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      color: char['color'] as Color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildInfoCards(ColorScheme colorScheme) {
    return Row(
      children: [
        _buildInfoCard(
          Icons.access_time,
          'Duration',
          _getDurationText(),
          colorScheme,
        ),
        const SizedBox(width: 16),
        _buildInfoCard(
          Icons.calendar_today,
          'Season',
          (widget.activity['saison']?.toString() ?? '').isNotEmpty 
              ? widget.activity['saison']!.toString() 
              : 'Toute l\'année',
          colorScheme,
        ),
        const SizedBox(width: 16),
        _buildInfoCard(
          Icons.attach_money,
          'Price',
          _getPriceText(),
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

  Widget _buildActivityDetails(ColorScheme colorScheme, bool isTablet, bool isDesktop) {
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
            'Activity Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(Icons.category, 'Category', widget.activity['categorie']?.toString() ?? widget.activity['typeActivite']?.toString() ?? widget.activity['type']?.toString() ?? 'Activité touristique', colorScheme),
          _buildDetailRow(Icons.access_time, 'Duration', _getDurationText(), colorScheme),
          _buildDetailRow(Icons.calendar_today, 'Best Season', (widget.activity['saison']?.toString() ?? '').isNotEmpty ? widget.activity['saison']!.toString() : 'Toute l\'année', colorScheme),
          _buildDetailRow(Icons.trending_up, 'Difficulty Level', (widget.activity['niveauDificulta']?.toString() ?? '').isNotEmpty ? widget.activity['niveauDificulta']!.toString() : 'Facile', colorScheme),
          _buildDetailRow(Icons.attach_money, 'Price', _getPriceText(), colorScheme),
          if (widget.activity['ville'] != null && widget.activity['ville'].toString().isNotEmpty)
            _buildDetailRow(Icons.location_city, 'City', widget.activity['ville'].toString(), colorScheme),
          if (widget.activity['conditionsSpeciales'] != null && widget.activity['conditionsSpeciales'].toString().isNotEmpty)
            _buildDetailRow(Icons.info, 'Special Conditions', widget.activity['conditionsSpeciales'].toString(), colorScheme),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: colorScheme.primary, size: 20),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 8),
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

  Widget _buildActivityActions(BuildContext context, ColorScheme colorScheme, bool isTablet, bool isDesktop) {
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
            'Book This Activity',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            (widget.activity['description']?.toString() ?? '').isNotEmpty 
                ? widget.activity['description']!.toString()
                : 'Découvrez cette activité unique au Maroc avec nos guides experts. Une expérience inoubliable vous attend dans cette destination exceptionnelle.',
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurface.withOpacity(0.8),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _bookActivity,
                  icon: _isLoading 
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.book_online, size: 18),
                  label: Text(_isLoading ? 'Booking...' : 'Book Now'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _shareActivity(context),
                  icon: const Icon(Icons.share, size: 18),
                  label: const Text('Share'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _toggleFavorite() async {
    final activityId = _extractActivityId(widget.activity);
    if (activityId == 0) return;
    
    final prev = _isFavorite;
    setState(() { _isFavorite = !prev; });
    
    try {
      await WishlistService.saveSnapshot(
        type: 'activity',
        itemId: activityId,
        data: {
          'id': activityId,
          'nom': widget.activity['nom']?.toString() ?? widget.activity['nomActivite']?.toString() ?? widget.activity['name']?.toString() ?? '',
          'title': widget.activity['nom']?.toString() ?? widget.activity['nomActivite']?.toString() ?? widget.activity['name']?.toString() ?? '',
          'image': widget.activity['image']?.toString() ?? widget.activity['imageUrl']?.toString() ?? '',
          'imageUrl': widget.activity['image']?.toString() ?? widget.activity['imageUrl']?.toString() ?? '',
          'prix': widget.activity['prix'],
          'dureeMinimun': widget.activity['dureeMinimun'],
          'dureeMaximun': widget.activity['dureeMaximun'],
          'saison': widget.activity['saison']?.toString(),
          'niveauDificulta': widget.activity['niveauDificulta']?.toString(),
          'categorie': widget.activity['categorie']?.toString() ?? widget.activity['typeActivite']?.toString() ?? widget.activity['type']?.toString(),
        },
      );
      final res = await WishlistService().toggleFavorite(type: 'activity', itemId: activityId);
      final action = res['action'] as String?;
      final added = action == 'added';
      if (mounted) {
        setState(() { _isFavorite = added; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(added ? 'Added to wishlist' : 'Removed from wishlist')),
        );
      }
    } catch (e) {
      if (mounted) setState(() { _isFavorite = prev; });
      if (mounted) {
        if (e is UnauthorizedException) {
          Navigator.pushNamed(context, '/login');
        } else {
          ErrorHandlerService.showErrorSnackBar(
            context, 
            e, 
            customMessage: 'Erreur lors de la mise à jour de la liste de souhaits'
          );
        }
      }
    }
  }

  Future<void> _bookActivity() async {
    setState(() { _isLoading = true; });
    
    try {
      // Add to wishlist first
      await _toggleFavorite();
      
      // Show booking confirmation
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Activity Booked!'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('You have successfully booked:'),
                  const SizedBox(height: 8),
                  Text(
                    widget.activity['nom']?.toString() ?? widget.activity['nomActivite']?.toString() ?? widget.activity['name']?.toString() ?? 'Activité',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text('Prix: ${_getPriceText()}'),
                  const SizedBox(height: 4),
                  Text('Durée: ${_getDurationText()}'),
                  const SizedBox(height: 4),
                  Text('Saison: ${(widget.activity['saison']?.toString() ?? '').isNotEmpty ? widget.activity['saison']!.toString() : 'Toute l\'année'}'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ErrorHandlerService.showErrorSnackBar(
          context, 
          e, 
          customMessage: 'Erreur lors de la réservation de l\'activité'
        );
      }
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  void _shareActivity(BuildContext context) {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share functionality coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Méthodes pour générer des informations réalistes du Maroc
  String _getPriceRange(double prix) {
    if (prix <= 50) return '(Prix économique)';
    if (prix <= 150) return '(Prix moyen)';
    if (prix <= 300) return '(Prix élevé)';
    return '(Prix premium)';
  }

  String _getPricingDetails(String activityName, String category, double? prix) {
    if (prix == null) return 'Contactez-nous pour obtenir un devis personnalisé.';
    
    final String baseInfo = 'Prix indicatif par personne. ';
    
    switch (category.toLowerCase()) {
      case 'randonnée':
        return baseInfo + 'Inclut guide local, équipement de sécurité et transport. Supplément possible pour repas berbère traditionnel (+50 MAD).';
      case 'safari':
        return baseInfo + 'Inclut hébergement en campement, repas, transport 4x4 et guide. Supplément pour nuit supplémentaire (+200 MAD).';
      case 'visite culturelle':
        return baseInfo + 'Inclut guide francophone et entrées aux monuments. Supplément pour guide privé (+100 MAD).';
      case 'plage':
        return baseInfo + 'Inclut équipement nautique et parasol. Supplément pour cours de surf (+80 MAD).';
      case 'artisanat':
        return baseInfo + 'Inclut matériel et démonstration. Possibilité d\'acheter les créations sur place.';
      case 'sports nautiques':
        return baseInfo + 'Inclut équipement complet et moniteur qualifié. Assurance incluse.';
      case 'aventure':
        return baseInfo + 'Inclut équipement de sécurité, guide et transport. Repas traditionnel inclus.';
      default:
        return baseInfo + 'Prix inclut les services de base. Suppléments possibles selon options choisies.';
    }
  }

  String _getDurationDetails(int? dureeMin, int? dureeMax) {
    if (dureeMin == null && dureeMax == null) {
      return 'Durée flexible selon vos préférences.';
    }
    
    if (dureeMin != null && dureeMax != null) {
      final String minStr = _formatDuration(dureeMin);
      final String maxStr = _formatDuration(dureeMax);
      return 'Durée recommandée entre $minStr et $maxStr. Possibilité d\'adapter selon votre emploi du temps.';
    }
    
    if (dureeMin != null) {
      return 'Durée minimum recommandée: ${_formatDuration(dureeMin)}.';
    }
    
    return 'Durée maximum: ${_formatDuration(dureeMax!)}.';
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) {
      return '${minutes}min';
    } else if (minutes < 1440) {
      final int hours = minutes ~/ 60;
      final int remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '${hours}h';
      } else {
        return '${hours}h${remainingMinutes}min';
      }
    } else {
      final int days = minutes ~/ 1440;
      final int remainingHours = (minutes % 1440) ~/ 60;
      if (remainingHours == 0) {
        return '${days} jour${days > 1 ? 's' : ''}';
      } else {
        return '${days} jour${days > 1 ? 's' : ''} et ${remainingHours}h';
      }
    }
  }

  List<String> _getLocalRecommendations(String activityName, String category) {
    final List<String> recommendations = [];
    
    // Recommandations générales
    recommendations.add('💡 Réservez à l\'avance, surtout en haute saison (avril-octobre)');
    recommendations.add('🌡️ Vérifiez la météo avant votre activité');
    recommendations.add('👕 Portez des vêtements confortables et adaptés au climat');
    
    // Recommandations spécifiques par catégorie
    switch (category.toLowerCase()) {
      case 'randonnée':
        recommendations.add('🥾 Chaussures de randonnée obligatoires');
        recommendations.add('💧 Apportez au moins 2L d\'eau par personne');
        recommendations.add('🧴 Crème solaire indispensable (indice 50+)');
        break;
      case 'safari':
        recommendations.add('🌙 Vêtements chauds pour les nuits dans le désert');
        recommendations.add('📷 Appareil photo avec batteries de rechange');
        recommendations.add('🎒 Sac de couchage recommandé');
        break;
      case 'visite culturelle':
        recommendations.add('👟 Chaussures confortables pour la marche');
        recommendations.add('📱 Guide audio disponible en français');
        recommendations.add('🎫 Entrées incluses dans le prix');
        break;
      case 'plage':
        recommendations.add('🏖️ Serviette et maillot de bain');
        recommendations.add('☀️ Protection solaire obligatoire');
        recommendations.add('🏄 Équipement nautique fourni');
        break;
      case 'artisanat':
        recommendations.add('🎨 Matériel fourni, aucune expérience requise');
        recommendations.add('🛍️ Possibilité d\'acheter vos créations');
        recommendations.add('📸 Photos autorisées dans l\'atelier');
        break;
      case 'sports nautiques':
        recommendations.add('🏄 Maillot de bain et serviette');
        recommendations.add('🏊 Savoir nager recommandé');
        recommendations.add('📋 Assurance incluse dans le prix');
        break;
    }
    
    // Recommandations spécifiques par activité
    if (activityName.toLowerCase().contains('fès')) {
      recommendations.add('🏛️ Visite des tanneries incluse');
      recommendations.add('🛍️ Souks traditionnels à proximité');
    }
    
    if (activityName.toLowerCase().contains('atlas')) {
      recommendations.add('⛰️ Altitude jusqu\'à 4000m possible');
      recommendations.add('🌡️ Température peut descendre à 0°C');
    }
    
    if (activityName.toLowerCase().contains('désert')) {
      recommendations.add('🐪 Balade à dos de dromadaire incluse');
      recommendations.add('⭐ Observation des étoiles la nuit');
    }
    
    return recommendations;
  }

  // Méthodes pour les informations pratiques
  String _getSeasonInfo() {
    final String? saison = widget.activity['saison'];
    if (saison != null && saison.isNotEmpty) {
      return saison;
    }
    return 'Toute l\'année';
  }

  String _getDifficultyInfo() {
    final String? difficulte = widget.activity['niveauDificulta'];
    if (difficulte != null && difficulte.isNotEmpty) {
      return difficulte;
    }
    return 'Facile';
  }

  String _getEquipmentInfo(String activityName, String category) {
    switch (category.toLowerCase()) {
      case 'randonnée':
        return 'Chaussures de randonnée, vêtements chauds, sac à dos, eau';
      case 'safari':
        return 'Vêtements chauds, appareil photo, sac de couchage';
      case 'visite culturelle':
        return 'Chaussures confortables, guide audio (optionnel)';
      case 'plage':
        return 'Maillot de bain, serviette, crème solaire';
      case 'artisanat':
        return 'Matériel fourni, tablier (optionnel)';
      case 'sports nautiques':
        return 'Maillot de bain, serviette, équipement fourni';
      case 'aventure':
        return 'Vêtements adaptés, chaussures fermées, eau';
      default:
        return 'Vêtements confortables selon l\'activité';
    }
  }

  String _getTransportInfo(String activityName, String category) {
    switch (category.toLowerCase()) {
      case 'randonnée':
        return 'Transport en minibus inclus depuis le point de départ';
      case 'safari':
        return 'Transport 4x4 inclus, transfert depuis l\'hôtel';
      case 'visite culturelle':
        return 'Transport en minibus ou à pied selon la distance';
      case 'plage':
        return 'Transport en bus ou taxi, parking disponible';
      case 'artisanat':
        return 'Transport en minibus vers l\'atelier';
      case 'sports nautiques':
        return 'Transport vers le spot, équipement sur place';
      case 'aventure':
        return 'Transport spécialisé inclus selon l\'activité';
      default:
        return 'Transport organisé selon l\'activité';
    }
  }

  Widget _buildPracticalItem(String title, String value, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods to handle null values
  String _getDurationText() {
    final dureeMin = widget.activity['dureeMinimun'];
    final dureeMax = widget.activity['dureeMaximun'];
    
    if (dureeMin != null && dureeMax != null) {
      return '${dureeMin.toString()}-${dureeMax.toString()} minutes';
    } else if (dureeMin != null) {
      return '${dureeMin.toString()} minutes minimum';
    } else if (dureeMax != null) {
      return '${dureeMax.toString()} minutes maximum';
    } else {
      return 'Durée flexible';
    }
  }

  String _getPriceText() {
    final prix = widget.activity['prix'];
    if (prix != null) {
      return '${prix.toString()} MAD';
    } else {
      return 'Prix sur demande';
    }
  }
}
