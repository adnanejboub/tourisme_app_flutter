import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/services/localization_service.dart';
import '../../data/models/trip_model.dart';
import '../../data/services/trip_service.dart';
import 'create_edit_trip_page.dart';
import 'trip_details_page.dart';

class SavedPage extends StatefulWidget {
  const SavedPage({Key? key}) : super(key: key);

  @override
  State<SavedPage> createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;
  final TripService _tripService = TripService();
  List<TripModel> _trips = [];
  bool _isLoadingTrips = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTrips();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

  Widget _buildHeader(ColorScheme colorScheme, LocalizationService localizationService) {
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

  Widget _buildTabBar(ColorScheme colorScheme, LocalizationService localizationService) {
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
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
        tabs: [
          Tab(text: localizationService.translate('activities') ?? 'Activities'),
          Tab(text: localizationService.translate('Trips') ?? 'Trips'),
          Tab(text: localizationService.translate('products') ?? 'Products'),
        ],
      ),
    );
  }

  Widget _buildActivitiesTab(ColorScheme colorScheme, LocalizationService localizationService) {
    // TODO: Replace with real activities data
    final activities = <Map<String, dynamic>>[]; // Empty for now

    if (activities.isEmpty) {
      return _buildEmptyState(
        icon: Icons.local_activity,
        title: localizationService.translate('no_activities_saved') ?? 'No Activities Saved',
        subtitle: localizationService.translate('start_exploring_activities') ?? 'Start exploring and save your favorite activities',
        actionText: localizationService.translate('explore_activities') ?? 'Explore Activities',
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

  Widget _buildTripsTab(ColorScheme colorScheme, LocalizationService localizationService) {
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

  Widget _buildEmptyTripsState(ColorScheme colorScheme, LocalizationService localizationService) {
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
              localizationService.translate('no_trips_saved') ?? 'No Trips Saved',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onBackground,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              localizationService.translate('create_your_first_trip') ?? 'Create your first trip and start planning your adventure',
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
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripCard(TripModel trip, ColorScheme colorScheme, LocalizationService localizationService) {
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
                        tooltip: localizationService.translate('edit_trip') ?? 'Edit Trip',
                      ),
                      IconButton(
                        onPressed: () => _deleteTrip(trip, localizationService),
                        icon: Icon(
                          Icons.delete,
                          color: Colors.red,
                          size: 20,
                        ),
                        tooltip: localizationService.translate('delete_trip') ?? 'Delete Trip',
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

  Widget _buildProductsTab(ColorScheme colorScheme, LocalizationService localizationService) {
    // TODO: Replace with real products data
    final products = <Map<String, dynamic>>[]; // Empty for now

    if (products.isEmpty) {
      return _buildEmptyState(
        icon: Icons.shopping_bag,
        title: localizationService.translate('no_products_saved') ?? 'No Products Saved',
        subtitle: localizationService.translate('save_products_buy') ?? 'Save products you want to buy later',
        actionText: localizationService.translate('explore_products') ?? 'Explore Products',
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
            Icon(
              icon,
              size: 80,
              color: colorScheme.onSurface.withOpacity(0.4),
            ),
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
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> activity, ColorScheme colorScheme, LocalizationService localizationService) {
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
        leading: CircleAvatar(
          backgroundColor: colorScheme.primary,
          child: Icon(Icons.local_activity, color: colorScheme.onPrimary),
        ),
        title: Text(
          activity['title'] ?? localizationService.translate('activity') ?? 'Activity',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          activity['location'] ?? localizationService.translate('location') ?? 'Location',
          style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
        ),
        trailing: IconButton(
          icon: Icon(Icons.favorite, color: colorScheme.primary),
          onPressed: () {},
        ),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, ColorScheme colorScheme, LocalizationService localizationService) {
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
        leading: CircleAvatar(
          backgroundColor: colorScheme.primary,
          child: Icon(Icons.shopping_bag, color: colorScheme.onPrimary),
        ),
        title: Text(
          product['name'] ?? localizationService.translate('products') ?? 'Product',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          product['price'] ?? localizationService.translate('price') ?? 'Price',
          style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
        ),
        trailing: IconButton(
          icon: Icon(Icons.favorite, color: colorScheme.primary),
          onPressed: () {},
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _createNewTrip() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateEditTripPage(),
      ),
    );
    
    if (result != null) {
      await _loadTrips(); // Recharger la liste des trips
    }
  }

  Future<void> _editTrip(TripModel trip) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TripDetailsPage(trip: trip),
      ),
    );
    
    if (result != null) {
      await _loadTrips(); // Recharger la liste des trips
    }
  }

  Future<void> _deleteTrip(TripModel trip, LocalizationService localizationService) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizationService.translate('delete_trip') ?? 'Delete Trip'),
        content: Text(localizationService.translate('delete_trip_confirmation') ?? 
            'Are you sure you want to delete this trip? This action cannot be undone.'),
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
              content: Text(localizationService.translate('trip_deleted_successfully') ?? 'Trip deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${localizationService.translate('error_deleting_trip') ?? 'Error deleting trip'}: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}