import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/services/image_service.dart';
import '../../../../core/constants/constants.dart';

class MonumentDetailsPage extends StatelessWidget {
  final Map<String, dynamic> monument;

  const MonumentDetailsPage({super.key, required this.monument});

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
          _buildSliverAppBar(context, colorScheme, isTablet, isDesktop),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildMonumentOverview(colorScheme, isTablet, isDesktop),
                _buildMonumentDetails(colorScheme, isTablet, isDesktop),
                _buildMonumentCharacteristics(colorScheme),
                _buildMonumentActions(
                  context,
                  colorScheme,
                  isTablet,
                  isDesktop,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(
    BuildContext context,
    ColorScheme colorScheme,
    bool isTablet,
    bool isDesktop,
  ) {
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
            _buildMonumentInfo(isTablet, isDesktop),
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
            child: const Icon(Icons.share, color: Colors.white),
          ),
          onPressed: () => _shareMonument(context),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHeroImage() {
    final imageUrl = monument['imageUrl'] ?? monument['image'] ?? '';

    if (imageUrl.isEmpty) {
      return Container(
        color: Colors.grey[300],
        child: const Center(
          child: Icon(Icons.location_city, size: 80, color: Colors.grey),
        ),
      );
    }

    if (ImageService.isLocalAsset(imageUrl)) {
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[300],
          child: const Center(
            child: Icon(Icons.location_city, size: 80, color: Colors.grey),
          ),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: Colors.grey[300],
        child: const Center(child: CircularProgressIndicator()),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[300],
        child: const Center(
          child: Icon(Icons.location_city, size: 80, color: Colors.grey),
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
          colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
        ),
      ),
    );
  }

  Widget _buildMonumentInfo(bool isTablet, bool isDesktop) {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            monument['nomMonument'] ?? 'Unknown Monument',
            style: TextStyle(
              color: Colors.white,
              fontSize: isDesktop ? 36 : (isTablet ? 32 : 28),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            monument['adresseMonument'] ?? 'Unknown Location',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: isDesktop ? 20 : (isTablet ? 18 : 16),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (monument['notesMoyennes'] != null) ...[
                const Icon(Icons.star, color: Colors.amber, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${monument['notesMoyennes']}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 16),
              ],
              if (monument['typeMonument'] != null) ...[
                const Icon(Icons.category, color: Colors.white70, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    monument['typeMonument'],
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

  Widget _buildMonumentOverview(
    ColorScheme colorScheme,
    bool isTablet,
    bool isDesktop,
  ) {
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
                      monument['nomMonument'] ?? 'Unknown Monument',
                      style: TextStyle(
                        fontSize: isDesktop ? 28 : (isTablet ? 26 : 24),
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onBackground,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (monument['typeMonument'] != null)
                      Text(
                        monument['typeMonument'],
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
              if (monument['notesMoyennes'] != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
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
                      Icon(Icons.star, color: colorScheme.primary, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${monument['notesMoyennes']}',
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
          if (monument['description'] != null)
            Text(
              monument['description'],
              style: TextStyle(
                fontSize: isDesktop ? 16 : (isTablet ? 15 : 14),
                color: colorScheme.onBackground.withOpacity(0.8),
                height: 1.5,
              ),
            ),
          const SizedBox(height: 20),
          // Monument characteristics
          _buildMonumentCharacteristics(colorScheme),
          const SizedBox(height: 20),
          // Info cards
          _buildInfoCards(colorScheme),
        ],
      ),
    );
  }

  Widget _buildMonumentCharacteristics(ColorScheme colorScheme) {
    List<Map<String, dynamic>> characteristics = [];

    // Add characteristics based on monument data
    if (monument['hasHistorique'] == true)
      characteristics.add({
        'icon': Icons.history_edu,
        'label': 'Historical',
        'color': Colors.brown,
      });
    if (monument['hasCulturelle'] == true)
      characteristics.add({
        'icon': Icons.museum,
        'label': 'Cultural',
        'color': Colors.purple,
      });
    if (monument['gratuit'] == true)
      characteristics.add({
        'icon': Icons.money_off,
        'label': 'Free Entry',
        'color': Colors.green,
      });

    if (characteristics.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Monument Features',
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
                border: Border.all(
                  color: (char['color'] as Color).withOpacity(0.3),
                ),
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
          Icons.location_on,
          'Address',
          monument['adresseMonument'] ?? 'N/A',
          colorScheme,
        ),
        const SizedBox(width: 16),
        _buildInfoCard(
          Icons.access_time,
          'Hours',
          monument['horairesOuverture'] ?? 'N/A',
          colorScheme,
        ),
        const SizedBox(width: 16),
        _buildInfoCard(
          Icons.attach_money,
          'Price',
          monument['gratuit'] == true
              ? 'Free'
              : '${monument['prix'] ?? 'N/A'} MAD',
          colorScheme,
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    IconData icon,
    String title,
    String value,
    ColorScheme colorScheme,
  ) {
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

  Widget _buildMonumentDetails(
    ColorScheme colorScheme,
    bool isTablet,
    bool isDesktop,
  ) {
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
            'Monument Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            Icons.category,
            'Type',
            monument['typeMonument'] ?? 'N/A',
            colorScheme,
          ),
          _buildDetailRow(
            Icons.location_on,
            'Address',
            monument['adresseMonument'] ?? 'N/A',
            colorScheme,
          ),
          if (monument['horairesOuverture'] != null)
            _buildDetailRow(
              Icons.access_time,
              'Opening Hours',
              monument['horairesOuverture'],
              colorScheme,
            ),
          if (monument['prix'] != null && monument['gratuit'] != true)
            _buildDetailRow(
              Icons.attach_money,
              'Price',
              '${monument['prix']} MAD',
              colorScheme,
            ),
          if (monument['gratuit'] == true)
            _buildDetailRow(Icons.money_off, 'Entry', 'Free', colorScheme),
          if (monument['notesMoyennes'] != null)
            _buildDetailRow(
              Icons.star,
              'Rating',
              '${monument['notesMoyennes']}/5',
              colorScheme,
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value,
    ColorScheme colorScheme,
  ) {
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

  Widget _buildMonumentActions(
    BuildContext context,
    ColorScheme colorScheme,
    bool isTablet,
    bool isDesktop,
  ) {
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
            'Additional Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          if (monument['description'] != null)
            Text(
              monument['description'],
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
                  onPressed: () => _getDirections(context),
                  icon: const Icon(Icons.directions, size: 18),
                  label: const Text('Get Directions'),
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
                  onPressed: () => _shareMonument(context),
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

  void _getDirections(BuildContext context) {
    // TODO: Implement directions functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Directions functionality coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _shareMonument(BuildContext context) {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share functionality coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
