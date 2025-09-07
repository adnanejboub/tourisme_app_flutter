import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../shared/widgets/guest_mode_mixin.dart';
import '../../../../config/routes/app_routes.dart';
import '../../data/models/trip_model.dart';
import '../../data/services/trip_service.dart';
import '../../data/services/wishlist_service.dart';
import '../../../explore/data/services/public_api_service.dart';
import 'package:tourisme_app_flutter/domain/product/entities/product.dart';
import 'package:tourisme_app_flutter/features/marketplace/product_detail/pages/product_detail.dart';
import 'create_edit_trip_page.dart';
import 'trip_details_page.dart';

class SavedPage extends StatefulWidget {
  const SavedPage({Key? key}) : super(key: key);

  @override
  State<SavedPage> createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage>
    with SingleTickerProviderStateMixin, GuestModeMixin {
  late TabController _tabController;
  int _currentIndex = 0;
  final TripService _tripService = TripService();
  final WishlistService _wishlistService = WishlistService();
  final PublicApiService _publicApi = PublicApiService();
  List<TripModel> _trips = [];
  List<Map<String, dynamic>> _favorites = [];
  List<Map<String, dynamic>> _favActivities = [];
  List<Map<String, dynamic>> _cityCards = [];
  List<Map<String, dynamic>> _favProducts = [];
  bool _isLoadingTrips = false;
  bool _isLoadingFavorites = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadTrips();
    _loadFavorites();
    WishlistService.changes.addListener(_onFavoritesChanged);
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoadingFavorites = true);
    try {
      final favs = await _wishlistService.fetchFavorites();
      _favorites = favs;
      await _hydrateFavorites();
      if (mounted) setState(() {});
    } catch (e) {
      print('Erreur lors du chargement des favoris: $e');
    } finally {
      setState(() => _isLoadingFavorites = false);
    }
  }

  Widget _buildCitiesTab(ColorScheme colorScheme) {
    final cities = _cityCards;
    if (_isLoadingFavorites) {
      return Center(
        child: CircularProgressIndicator(color: colorScheme.primary),
      );
    }
    if (cities.isEmpty) {
      return _buildEmptyState(
        icon: Icons.location_city,
        title: 'No Cities Saved',
        subtitle: 'Save cities you love from Explore',
        actionText: 'Explore Cities',
        onAction: () {},
        colorScheme: colorScheme,
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: cities.length,
      itemBuilder: (context, index) {
        final city = cities[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: SizedBox(
              width: 48,
              height: 48,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child:
                    (city['image'] as String?) != null &&
                        (city['image'] as String).isNotEmpty
                    ? Image.network(city['image'] as String, fit: BoxFit.cover)
                    : Icon(
                        Icons.location_city,
                        color: colorScheme.primary,
                        size: 32,
                      ),
              ),
            ),
            title: Text(
              (city['name'] ?? 'City').toString(),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              (city['country'] ?? '').toString(),
              style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.info_outline, color: colorScheme.primary),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.cityDetails,
                      arguments: {
                        'city': {
                          'id': (city['id'] as num?)?.toInt() ?? 0,
                          'nomVille': (city['name'] ?? '').toString(),
                          'name': (city['name'] ?? '').toString(),
                          'paysNom': (city['country'] ?? '').toString(),
                          'image': (city['image'] ?? city['imageUrl'] ?? '')
                              .toString(),
                          'imageUrl': (city['image'] ?? city['imageUrl'] ?? '')
                              .toString(),
                          'description': (city['description'] ?? '').toString(),
                        },
                      },
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: colorScheme.error),
                  onPressed: () async {
                    final id = (city['id'] as num?)?.toInt();
                    if (id == null) return;
                    await _wishlistService.toggleFavorite(
                      type: 'city',
                      itemId: id,
                    );
                    await _loadFavorites();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _hydrateFavorites() async {
    final activities = _favorites
        .where((f) => f['type'] == 'activity')
        .toList();
    final products = _favorites.where((f) => f['type'] == 'product').toList();

    final activityCalls = activities.map((a) async {
      final id = (a['itemId'] as num).toInt();
      final snap = await WishlistService.loadSnapshot(
        type: 'activity',
        itemId: id,
      );
      final data = snap ?? await _publicApi.getActivityById(id);
      if (data != null) return data;
      return <String, dynamic>{
        'id': id,
        'nom': 'Activity',
        'image': '',
        'location': '',
      };
    }).toList();

    final productCalls = products.map((p) async {
      final id = (p['itemId'] as num).toInt();
      final snap = await WishlistService.loadSnapshot(
        type: 'product',
        itemId: id,
      );
      final data = snap ?? await _publicApi.getProductById(id);
      if (data != null) return data;
      return <String, dynamic>{
        'idProduit': id,
        'nom': 'Product',
        'prix': '',
        'image': '',
      };
    }).toList();

    _favActivities = await Future.wait(activityCalls);
    _favProducts = await Future.wait(productCalls);

    // hydrate city favorites (type 'city')
    final cities = _favorites.where((f) => f['type'] == 'city').toList();
    final cityCalls = cities.map((c) async {
      final id = (c['itemId'] as num).toInt();
      final snap = await WishlistService.loadSnapshot(type: 'city', itemId: id);
      if (snap != null) return snap;
      // fallback to minimal card using city details endpoint header only
      try {
        final details = await _publicApi.getCityDetails(id);
        final city = details['city'] as Map<String, dynamic>;
        return {
          'id': id,
          'name': city['nomVille'] ?? '',
          'country': city['paysNom'] ?? '',
          'image': city['image'] ?? city['imageUrl'] ?? '',
        };
      } catch (_) {
        return {'id': id, 'name': 'City', 'image': ''};
      }
    }).toList();
    _cityCards = await Future.wait(cityCalls);
  }

  @override
  void dispose() {
    WishlistService.changes.removeListener(_onFavoritesChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onFavoritesChanged() {
    if (mounted && !_isLoadingFavorites) {
      _loadFavorites();
    }
  }

  Future<void> _loadTrips() async {
    setState(() => _isLoadingTrips = true);
    try {
      final trips = await _tripService.getAllTrips();
      setState(() => _trips = trips);
    } catch (e) {
      print('Erreur lors du chargement des trips: $e');
    } finally {
      setState(() => _isLoadingTrips = false);
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
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(colorScheme, localizationService),
                _buildTabBar(colorScheme, localizationService),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildCitiesTab(colorScheme),
                      _buildActivitiesTab(colorScheme, localizationService),
                      _buildTripsTab(colorScheme, localizationService),
                      _buildProductsTab(colorScheme, localizationService),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(
    ColorScheme colorScheme,
    LocalizationService localizationService,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              localizationService.translate('wishlist') ?? 'Wishlist',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: colorScheme.onBackground,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.sort, color: colorScheme.primary, size: 24),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(
    ColorScheme colorScheme,
    LocalizationService localizationService,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: TabBar(
        controller: _tabController,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(width: 6, color: colorScheme.primary),
          insets: EdgeInsets.zero,
        ),
        labelColor: colorScheme.primary,
        unselectedLabelColor: colorScheme.onSurface.withOpacity(0.6),
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 14,
        ),
        tabs: [
          const Tab(text: 'Cities'),
          Tab(
            text: localizationService.translate('activities') ?? 'Activities',
          ),
          Tab(text: localizationService.translate('Trips') ?? 'Trips'),
          Tab(text: localizationService.translate('products') ?? 'Products'),
        ],
      ),
    );
  }

  Widget _buildActivitiesTab(
    ColorScheme colorScheme,
    LocalizationService localizationService,
  ) {
    final activities = _favActivities.isNotEmpty ? _favActivities : _cityCards;

    if (_isLoadingFavorites) {
      return Center(
        child: CircularProgressIndicator(color: colorScheme.primary),
      );
    }

    if (activities.isEmpty) {
      return _buildEmptyState(
        icon: Icons.local_activity,
        title:
            localizationService.translate('no_activities_saved') ??
            'No Activities Saved',
        subtitle:
            localizationService.translate('start_exploring_activities') ??
            'Start exploring and save your favorite activities',
        actionText:
            localizationService.translate('explore_activities') ??
            'Explore Activities',
        onAction: () {},
        colorScheme: colorScheme,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        return _buildActivityCard(activity, colorScheme, localizationService);
      },
    );
  }

  Widget _buildTripsTab(
    ColorScheme colorScheme,
    LocalizationService localizationService,
  ) {
    if (_isLoadingTrips) {
      return Center(
        child: CircularProgressIndicator(color: colorScheme.primary),
      );
    }

    if (_trips.isEmpty) {
      return _buildEmptyTripsState(colorScheme, localizationService);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _trips.length,
      itemBuilder: (context, index) {
        final trip = _trips[index];
        return _buildTripCard(trip, colorScheme, localizationService);
      },
    );
  }

  Widget _buildEmptyTripsState(
    ColorScheme colorScheme,
    LocalizationService localizationService,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.flight_takeoff,
              size: 80,
              color: colorScheme.onSurface.withOpacity(0.4),
            ),
            const SizedBox(height: 24),
            Text(
              localizationService.translate('no_trips_saved') ??
                  'No Trips Saved',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onBackground,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              localizationService.translate('create_your_first_trip') ??
                  'Create your first trip and start planning your adventure',
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () => _createNewTrip(),
                icon: Icon(Icons.add),
                label: Text(
                  localizationService.translate('create_trip') ?? 'Create Trip',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripCard(
    TripModel trip,
    ColorScheme colorScheme,
    LocalizationService localizationService,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: InkWell(
        onTap: () => _editTrip(trip),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _editTrip(trip),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trip.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            trip.destination,
                            style: TextStyle(
                              fontSize: 14,
                              color: colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => _editTrip(trip),
                        icon: Icon(
                          Icons.edit,
                          color: colorScheme.primary,
                          size: 20,
                        ),
                        tooltip:
                            localizationService.translate('edit_trip') ??
                            'Edit Trip',
                      ),
                      IconButton(
                        onPressed: () => _deleteTrip(trip, localizationService),
                        icon: Icon(Icons.delete, color: Colors.red, size: 20),
                        tooltip:
                            localizationService.translate('delete_trip') ??
                            'Delete Trip',
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                  SizedBox(width: 8),
                  Text(
                    '${_formatDate(trip.startDate)} - ${_formatDate(trip.endDate)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  Spacer(),
                  Text(
                    '${trip.duration} days',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.local_activity,
                    size: 16,
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                  SizedBox(width: 8),
                  Text(
                    '${trip.activities.length} activities',
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              if (trip.notes != null && trip.notes!.isNotEmpty) ...[
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    trip.notes!,
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.primary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductsTab(
    ColorScheme colorScheme,
    LocalizationService localizationService,
  ) {
    final products = _favProducts;

    if (_isLoadingFavorites) {
      return Center(
        child: CircularProgressIndicator(color: colorScheme.primary),
      );
    }

    if (products.isEmpty) {
      return _buildEmptyState(
        icon: Icons.shopping_bag,
        title:
            localizationService.translate('no_products_saved') ??
            'No Products Saved',
        subtitle:
            localizationService.translate('save_products_buy') ??
            'Save products you want to buy later',
        actionText:
            localizationService.translate('explore_products') ??
            'Explore Products',
        onAction: () {},
        colorScheme: colorScheme,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return _buildProductCard(product, colorScheme, localizationService);
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required String actionText,
    required VoidCallback onAction,
    required ColorScheme colorScheme,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: colorScheme.onSurface.withOpacity(0.4)),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onBackground,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: onAction,
                child: Text(
                  actionText,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(
    Map<String, dynamic> activity,
    ColorScheme colorScheme,
    LocalizationService localizationService,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: SizedBox(
          width: 48,
          height: 48,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: (() {
              final img =
                  (activity['image'] ?? activity['imageUrl']) as String?;
              if (img != null && img.isNotEmpty) {
                return Image.network(img, fit: BoxFit.cover);
              }
              return Icon(
                Icons.local_activity,
                color: colorScheme.primary,
                size: 32,
              );
            })(),
          ),
        ),
        title: Text(
          activity['nom'] ??
              activity['title'] ??
              activity['name'] ??
              localizationService.translate('activity') ??
              'Activity',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Location
            if (activity['ville']?['nomVille'] != null ||
                activity['city'] != null ||
                activity['lieu'] != null ||
                activity['location'] != null)
              Text(
                activity['ville']?['nomVille'] ??
                    activity['city'] ??
                    activity['lieu'] ??
                    activity['location'] ??
                    '',
                style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            // Price
            if (activity['prix'] != null)
              Text(
                '${activity['prix'].toString()} MAD',
                style: TextStyle(
                  color: Colors.amber[800],
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.info_outline, color: colorScheme.primary),
              onPressed: () {
                // Navigate to activity details if available
                // For now, we can show a simple dialog or navigate to explore page
              },
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: colorScheme.error),
              onPressed: () async {
                final dynamic rawId =
                    activity['id'] ??
                    activity['idActivite'] ??
                    activity['id_activity'] ??
                    activity['idAct'];
                final int? id = rawId is int
                    ? rawId
                    : (rawId is num ? rawId.toInt() : null);
                if (id == null || id == 0) return;
                try {
                  await _wishlistService.toggleFavorite(
                    type: 'activity',
                    itemId: id,
                  );
                  await _loadFavorites();
                } catch (_) {}
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(
    Map<String, dynamic> product,
    ColorScheme colorScheme,
    LocalizationService localizationService,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: SizedBox(
          width: 48,
          height: 48,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child:
                (product['image'] ?? product['imageUrl']) != null &&
                    ((product['image'] ?? product['imageUrl']) as String)
                        .isNotEmpty
                ? Image.network(
                    (product['image'] ?? product['imageUrl']) as String,
                    fit: BoxFit.cover,
                  )
                : Icon(
                    Icons.shopping_bag,
                    color: colorScheme.primary,
                    size: 32,
                  ),
          ),
        ),
        title: Text(
          product['nom'] ??
              product['title'] ??
              localizationService.translate('products') ??
              'Product',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          product['prix'] != null
              ? '${product['prix']} MAD'
              : (product['price']?.toString() ?? ''),
          style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.info_outline, color: colorScheme.primary),
              onPressed: () {
                // Navigate to product detail page (construct minimal entity)
                final dynamic rawId = product['id'] ?? product['idProduit'];
                final int id = rawId is int
                    ? rawId
                    : (rawId is num ? rawId.toInt() : 0);
                final entity = ProductEntity(
                  id: id.toString(),
                  title: (product['nom'] ?? product['title'] ?? 'Product')
                      .toString(),
                  description: (product['description'] ?? '').toString(),
                  price: (product['prix'] ?? product['price'] ?? 0).toDouble(),
                  image: (product['image'] ?? product['imageUrl'] ?? '')
                      .toString(),
                  categoryId: '',
                  colors: const [],
                  sizes: const [],
                  isFavorite: true,
                  discountedPrice: 0,
                  createdDate: DateTime.now(),
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetailPage(product: entity),
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: colorScheme.error),
              onPressed: () async {
                final dynamic rawId = product['id'] ?? product['idProduit'];
                final int? id = rawId is int
                    ? rawId
                    : (rawId is num ? rawId.toInt() : null);
                if (id == null || id == 0) return;
                try {
                  await _wishlistService.toggleFavorite(
                    type: 'product',
                    itemId: id,
                  );
                  await _loadFavorites();
                } catch (_) {}
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _createNewTrip() async {
    executeWithGuestCheck('save_items', () async {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CreateEditTripPage()),
      );

      if (result != null) {
        await _loadTrips(); // Recharger la liste des trips
      }
    });
  }

  Future<void> _editTrip(TripModel trip) async {
    executeWithGuestCheck('save_items', () async {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TripDetailsPage(trip: trip)),
      );

      if (result != null) {
        await _loadTrips(); // Recharger la liste des trips
      }
    });
  }

  Future<void> _deleteTrip(
    TripModel trip,
    LocalizationService localizationService,
  ) async {
    executeWithGuestCheck('save_items', () async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            localizationService.translate('delete_trip') ?? 'Delete Trip',
          ),
          content: Text(
            localizationService.translate('delete_trip_confirmation') ??
                'Are you sure you want to delete this trip? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(localizationService.translate('cancel') ?? 'Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text(localizationService.translate('delete') ?? 'Delete'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        try {
          final tripService = TripService();
          await tripService.deleteTrip(trip.id);

          // Recharger la liste des trips
          await _loadTrips();

          // Afficher un message de succès
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  localizationService.translate('trip_deleted_successfully') ??
                      'Trip deleted successfully',
                ),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${localizationService.translate('error_deleting_trip') ?? 'Error deleting trip'}: $e',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    });
  }
}
