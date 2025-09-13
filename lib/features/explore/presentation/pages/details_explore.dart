import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../core/constants/constants.dart';
// import 'itinerary_planning_page.dart'; // Page supprimée
import '../../../saved/data/services/wishlist_service.dart';
import '../../../saved/presentation/pages/saved_page.dart';
import '../../../saved/data/services/trip_service.dart';
import '../../../saved/data/models/trip_model.dart';

class DetailsExplorePage extends StatefulWidget {
  final Map<String, dynamic> destination;

  const DetailsExplorePage({Key? key, required this.destination})
    : super(key: key);

  @override
  State<DetailsExplorePage> createState() => _DetailsExplorePageState();
}

class _DetailsExplorePageState extends State<DetailsExplorePage> {
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer<LocalizationService>(
      builder: (context, localizationService, child) {
        return Scaffold(
          backgroundColor: colorScheme.background,
          body: CustomScrollView(
            slivers: [
              _buildSliverAppBar(localizationService, colorScheme),
              SliverToBoxAdapter(
                child: _buildContent(localizationService, colorScheme),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSliverAppBar(
    LocalizationService localizationService,
    ColorScheme colorScheme,
  ) {
    return SliverAppBar(
      expandedHeight: 300,
      floating: false,
      pinned: true,
      backgroundColor: colorScheme.background,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: colorScheme.onBackground),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        widget.destination['name'] ?? 'Destination',
        style: TextStyle(
          color: colorScheme.onBackground,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.red : colorScheme.onBackground,
          ),
          onPressed: () async {
            final id = widget.destination['id'] as int?;
            final type = (widget.destination['type'] as String?) ?? 'city';
            if (id == null) return;
            final prev = isFavorite;
            setState(() {
              isFavorite = !prev;
            });
            try {
              await WishlistService.saveSnapshot(
                type: type,
                itemId: id,
                data: {
                  'id': id,
                  'name': widget.destination['name'] ?? '',
                  'image':
                      widget.destination['image'] ??
                      widget.destination['imageUrl'] ??
                      '',
                },
              );
              final res = await WishlistService().toggleFavorite(
                type: type,
                itemId: id,
              );
              final action = res['action'] as String?;
              final added = action == 'added';
              if (mounted) {
                setState(() {
                  isFavorite = added;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      added ? 'Added to favorites' : 'Removed from favorites',
                    ),
                  ),
                );
              }
            } catch (e) {
              if (mounted)
                setState(() {
                  isFavorite = prev;
                });
              if (e is UnauthorizedException && mounted) {
                Navigator.pushNamed(context, '/login');
              }
            }
          },
        ),
        IconButton(
          icon: Icon(Icons.share, color: colorScheme.onBackground),
          onPressed: () => _showShareOptions(),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            _buildSmartImage(
              imageUrl:
                  widget.destination['image'] ??
                  widget.destination['imageUrl'] ??
                  '',
              colorScheme: colorScheme,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    LocalizationService localizationService,
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDestinationInfo(localizationService, colorScheme),
          SizedBox(height: 32),
          // Afficher les sections seulement pour les villes, pas pour les activités
          if (widget.destination['categorie'] == null) ...[
            _buildKeyAttractions(localizationService, colorScheme),
            SizedBox(height: 32),
            _buildRecommendedActivities(localizationService, colorScheme),
            SizedBox(height: 32),
            _buildLocationMap(localizationService, colorScheme),
            SizedBox(height: 32),
          ],
          _buildActionButton(localizationService, colorScheme),
        ],
      ),
    );
  }

  Widget _buildDestinationInfo(
    LocalizationService localizationService,
    ColorScheme colorScheme,
  ) {
    // Vérifier si c'est une activité ou une ville
    final isActivity = widget.destination['categorie'] != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.destination['title'] ??
              widget.destination['name'] ??
              'Destination',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: colorScheme.onBackground,
          ),
        ),
        SizedBox(height: 8),
        if (isActivity) ...[
          // Affichage spécifique pour les activités
          if (widget.destination['categorie'] != null)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                widget.destination['categorie'],
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          SizedBox(height: 16),
          // Informations détaillées de l'activité
          _buildActivityDetails(colorScheme),
        ] else ...[
          // Affichage pour les villes
          Text(
            widget.destination['arabicName'] ?? 'The Red City',
            style: TextStyle(
              fontSize: 18,
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
        SizedBox(height: 16),
        Text(
          widget.destination['description'] ??
              'A vibrant city in Morocco, known for its bustling souks, historic palaces, and beautiful gardens. It\'s a major economic center and tourist destination, offering a rich cultural experience with its ancient medina, lively squares, and stunning architecture.',
          style: TextStyle(
            fontSize: 16,
            color: colorScheme.onSurface.withOpacity(0.7),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildActivityDetails(ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.onSurface.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          // Prix
          if (widget.destination['prix'] != null &&
              widget.destination['prix'] > 0)
            _buildDetailRow(
              icon: Icons.attach_money,
              label: 'Prix',
              value: '${widget.destination['prix'].toStringAsFixed(0)} MAD',
              colorScheme: colorScheme,
            ),
          // Durée
          if (widget.destination['dureeMinimun'] != null)
            _buildDetailRow(
              icon: Icons.access_time,
              label: 'Durée',
              value: widget.destination['dureeMaximun'] != null
                  ? '${widget.destination['dureeMinimun']}-${widget.destination['dureeMaximun']} minutes'
                  : '${widget.destination['dureeMinimun']} minutes',
              colorScheme: colorScheme,
            ),
          // Saison
          if (widget.destination['saison'] != null)
            _buildDetailRow(
              icon: Icons.calendar_today,
              label: 'Saison',
              value: widget.destination['saison'],
              colorScheme: colorScheme,
            ),
          // Niveau de difficulté
          if (widget.destination['niveauDificulta'] != null)
            _buildDetailRow(
              icon: Icons.trending_up,
              label: 'Difficulté',
              value: widget.destination['niveauDificulta'],
              colorScheme: colorScheme,
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required ColorScheme colorScheme,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colorScheme.primary),
          SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyAttractions(
    LocalizationService localizationService,
    ColorScheme colorScheme,
  ) {
    final attractions =
        widget.destination['attractions'] as List<String>? ??
        [
          'Jemaa el-Fna Square',
          'Bahia Palace',
          'Jardin Majorelle',
          'Koutoubia Mosque',
        ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizationService.translate('key_attractions'),
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: colorScheme.onBackground,
          ),
        ),
        SizedBox(height: 16),
        ...attractions
            .map(
              (attraction) => Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        attraction,
                        style: TextStyle(
                          fontSize: 16,
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ],
    );
  }

  Widget _buildRecommendedActivities(
    LocalizationService localizationService,
    ColorScheme colorScheme,
  ) {
    final activities = [
      {
        'title': localizationService.translate('explore_the_souks'),
        'location':
            '${widget.destination['name']} ${localizationService.translate('medina')}',
        'image': 'https://images.unsplash.com/photo-1517685352821-92cf88aee5a5',
      },
      {
        'title': localizationService.translate('visit_secret_garden'),
        'location': widget.destination['name'],
        'image': 'https://images.unsplash.com/photo-1570191913384-b786dde7d9b4',
      },
      {
        'title': localizationService.translate('enjoy_traditional_hammam'),
        'location': localizationService.translate('various_locations'),
        'image': 'https://images.unsplash.com/photo-1590736969955-71cc94901144',
      },
      {
        'title': localizationService.translate('hot_air_balloon_ride'),
        'location':
            '${localizationService.translate('palmerale')}, ${widget.destination['name']}',
        'image': 'https://images.unsplash.com/photo-1591414646028-7b60c18c6f14',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizationService.translate('recommended_activities'),
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: colorScheme.onBackground,
          ),
        ),
        SizedBox(height: 16),
        ...activities
            .map((activity) => _buildActivityCard(activity, colorScheme))
            .toList(),
      ],
    );
  }

  Widget _buildActivityCard(
    Map<String, dynamic> activity,
    ColorScheme colorScheme,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                activity['image']!,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 60,
                    height: 60,
                    color: colorScheme.onSurface.withOpacity(0.1),
                    child: Icon(
                      Icons.image,
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  );
                },
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity['title']!,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    activity['location']!,
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationMap(
    LocalizationService localizationService,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizationService.translate('location_on_map'),
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: colorScheme.onBackground,
          ),
        ),
        SizedBox(height: 16),
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.onSurface.withOpacity(0.1)),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.map,
                  size: 48,
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
                SizedBox(height: 8),
                Text(
                  localizationService.translate('map_view'),
                  style: TextStyle(
                    fontSize: 16,
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    LocalizationService localizationService,
    ColorScheme colorScheme,
  ) {
    final isActivity = widget.destination['categorie'] != null;

    return Container(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () async {
          if (isActivity) {
            // Pour les activités, afficher une confirmation de réservation
            _showBookingConfirmation(localizationService, colorScheme);
          } else {
            // Pour les villes, créer automatiquement un trip
            await _createTripFromDestination(localizationService, colorScheme);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          isActivity
              ? 'Réserver cette activité'
              : localizationService.translate('plan_your_itinerary'),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }

  void _showBookingConfirmation(
    LocalizationService localizationService,
    ColorScheme colorScheme,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Confirmation de réservation',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Voulez-vous réserver cette activité ?',
                style: TextStyle(color: colorScheme.onSurface),
              ),
              SizedBox(height: 16),
              Text(
                widget.destination['title'] ?? 'Activité',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              if (widget.destination['prix'] != null &&
                  widget.destination['prix'] > 0) ...[
                SizedBox(height: 8),
                Text(
                  'Prix: ${widget.destination['prix'].toStringAsFixed(0)} MAD',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Annuler',
                style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Activité réservée avec succès !'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: Text('Confirmer'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSmartImage({
    required String imageUrl,
    required ColorScheme colorScheme,
  }) {
    if (imageUrl.isEmpty) {
      return Container(
        color: colorScheme.onSurface.withOpacity(0.1),
        child: Icon(
          Icons.image,
          size: 100,
          color: colorScheme.onSurface.withOpacity(0.6),
        ),
      );
    }

    // Vérifier si c'est une image locale (assets)
    if (imageUrl.startsWith('assets/') || imageUrl.startsWith('images/')) {
      final assetPath = imageUrl.startsWith('images/')
          ? 'assets/$imageUrl'
          : imageUrl;
      return Image.asset(
        assetPath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: colorScheme.onSurface.withOpacity(0.1),
            child: Icon(
              Icons.image,
              size: 100,
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          );
        },
      );
    } else {
      // Image réseau
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: colorScheme.onSurface.withOpacity(0.1),
            child: Icon(
              Icons.image,
              size: 100,
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          );
        },
      );
    }
  }

  void _showShareOptions() {
    final destination = widget.destination;
    final name = destination['name'] ?? destination['title'] ?? 'Destination';
    final description =
        destination['description'] ?? 'Découvrez cette magnifique destination';
    final type = destination['categorie'] != null ? 'activité' : 'ville';

    final shareText =
        '''
🌟 Découvrez cette magnifique $type : $name

$description

Téléchargez l'application de tourisme pour découvrir plus de destinations incroyables ! 🚀

#Tourisme #Maroc #$name
''';

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Partager $name',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildShareOption(
                  icon: Icons.share,
                  label: 'Partager',
                  onTap: () {
                    Navigator.pop(context);
                    Share.share(shareText);
                  },
                ),
                _buildShareOption(
                  icon: Icons.message,
                  label: 'WhatsApp',
                  onTap: () {
                    Navigator.pop(context);
                    Share.share(shareText, subject: 'Découvrez $name');
                  },
                ),
                _buildShareOption(
                  icon: Icons.facebook,
                  label: 'Facebook',
                  onTap: () {
                    Navigator.pop(context);
                    Share.share(shareText, subject: 'Découvrez $name');
                  },
                ),
                _buildShareOption(
                  icon: Icons.email,
                  label: 'Email',
                  onTap: () {
                    Navigator.pop(context);
                    Share.share(shareText, subject: 'Découvrez $name');
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 32,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Future<void> _createTripFromDestination(
    LocalizationService localizationService,
    ColorScheme colorScheme,
  ) async {
    try {
      final destinationName =
          widget.destination['name'] ?? 'Unknown Destination';

      // Créer automatiquement un trip avec les données de la destination
      final tripService = TripService();
      final now = DateTime.now();
      final trip = TripModel(
        id: now.millisecondsSinceEpoch.toString(), // ID temporaire
        name: 'Trip to $destinationName',
        destination: destinationName,
        startDate: now.add(const Duration(days: 7)),
        endDate: now.add(const Duration(days: 10)),
        notes: 'Budget: Mid-Range (800-1500 MAD/day)',
        activities: [
          TripActivity(
            id: '1',
            name: 'Adventure',
            type: 'adventure',
            duration: 300,
            description: 'Explore the destination and its attractions',
          ),
          TripActivity(
            id: '2',
            name: 'Relaxation',
            type: 'relaxation',
            duration: 150,
            description: 'Enjoy local culture and cuisine',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      );

      // Enregistrer le trip dans la wishlist
      final createdTrip = await tripService.createTrip(
        name: trip.name,
        destination: trip.destination,
        startDate: trip.startDate,
        endDate: trip.endDate,
        notes: trip.notes,
      );

      // Ajouter les activités au trip créé
      for (final activity in trip.activities) {
        await tripService.addActivityToTrip(createdTrip.id, activity);
      }

      // Stocker les activités recommandées dans le trip pour l'édition
      final recommendedActivities = [
        {
          'id': '1',
          'nom': 'Explore the Souks',
          'nomActivite': 'Explore the Souks',
          'name': 'Explore the Souks',
          'categorie': 'Shopping',
          'typeActivite': 'Shopping',
          'type': 'Shopping',
          'description': 'Discover local crafts and traditional goods',
          'dureeMinimun': 120,
        },
        {
          'id': '2',
          'nom': 'Visit Historical Sites',
          'nomActivite': 'Visit Historical Sites',
          'name': 'Visit Historical Sites',
          'categorie': 'Cultural',
          'typeActivite': 'Cultural',
          'type': 'Cultural',
          'description': 'Explore historical monuments and landmarks',
          'dureeMinimun': 180,
        },
        {
          'id': '3',
          'nom': 'Hot Air Balloon Ride',
          'nomActivite': 'Hot Air Balloon Ride',
          'name': 'Hot Air Balloon Ride',
          'categorie': 'Adventure',
          'typeActivite': 'Adventure',
          'type': 'Adventure',
          'description': 'Enjoy a scenic balloon ride',
          'dureeMinimun': 240,
        },
      ];
      await tripService.updateTripActivities(
        createdTrip.id,
        recommendedActivities,
      );

      // Ajouter le trip à la wishlist
      if (createdTrip != null) {
        await WishlistService.saveSnapshot(
          type: 'trip',
          itemId: int.parse(createdTrip.id),
          data: {
            'id': createdTrip.id,
            'name': createdTrip.name,
            'destination': createdTrip.destination,
            'startDate': createdTrip.startDate.toIso8601String(),
            'endDate': createdTrip.endDate.toIso8601String(),
            'notes': createdTrip.notes,
            'activities': createdTrip.activities
                .map(
                  (activity) => {
                    'id': activity.id,
                    'name': activity.name,
                    'type': activity.type,
                    'duration': activity.duration,
                    'description': activity.description,
                  },
                )
                .toList(),
          },
        );
        await WishlistService().toggleFavorite(
          type: 'trip',
          itemId: int.parse(createdTrip.id),
        );
      }

      // Afficher un message de succès
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Trip to $destinationName saved to wishlist successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating trip: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
