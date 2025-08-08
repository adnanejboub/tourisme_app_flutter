import 'package:flutter/material.dart';
import '../../../../core/constants/constants.dart';

class SavedPage extends StatefulWidget {
  const SavedPage({Key? key}) : super(key: key);

  @override
  State<SavedPage> createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(colorScheme),
            _buildTabBar(colorScheme),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildActivitiesTab(colorScheme),
                  _buildCitiesTab(colorScheme),
                  _buildProductsTab(colorScheme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Wishlist',
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

  Widget _buildTabBar(ColorScheme colorScheme) {
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
        tabs: const [
          Tab(text: 'Activities'),
          Tab(text: 'Cities'),
          Tab(text: 'Products'),
        ],
      ),
    );
  }

  Widget _buildActivitiesTab(ColorScheme colorScheme) {
    // TODO: Replace with real activities data
    final activities = <Map<String, dynamic>>[]; // Empty for now

    if (activities.isEmpty) {
      return _buildEmptyState(
        icon: Icons.local_activity,
        title: 'No activities saved yet',
        subtitle: 'Start exploring and save your favorite activities',
        actionText: 'Explore Activities',
        onAction: () {},
        colorScheme: colorScheme,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        return _buildActivityCard(activity, colorScheme);
      },
    );
  }

  Widget _buildCitiesTab(ColorScheme colorScheme) {
    // TODO: Replace with real cities data
    final cities = <Map<String, dynamic>>[]; // Empty for now

    if (cities.isEmpty) {
      return _buildEmptyState(
        icon: Icons.location_city,
        title: 'No cities saved yet',
        subtitle: 'Save cities you want to visit',
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
        return _buildCityCard(city, colorScheme);
      },
    );
  }

  Widget _buildProductsTab(ColorScheme colorScheme) {
    // TODO: Replace with real products data
    final products = <Map<String, dynamic>>[]; // Empty for now

    if (products.isEmpty) {
      return _buildEmptyState(
        icon: Icons.shopping_bag,
        title: 'No products saved yet',
        subtitle: 'Save products you want to buy',
        actionText: 'Explore Products',
        onAction: () {},
        colorScheme: colorScheme,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return _buildProductCard(product, colorScheme);
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

  Widget _buildActivityCard(Map<String, dynamic> activity, ColorScheme colorScheme) {
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
          activity['title'] ?? 'Activity',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          activity['location'] ?? 'Location',
          style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
        ),
        trailing: IconButton(
          icon: Icon(Icons.favorite, color: colorScheme.primary),
          onPressed: () {},
        ),
      ),
    );
  }

  Widget _buildCityCard(Map<String, dynamic> city, ColorScheme colorScheme) {
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
          child: Icon(Icons.location_city, color: colorScheme.onPrimary),
        ),
        title: Text(
          city['name'] ?? 'City',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          city['country'] ?? 'Country',
          style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
        ),
        trailing: IconButton(
          icon: Icon(Icons.favorite, color: colorScheme.primary),
          onPressed: () {},
        ),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, ColorScheme colorScheme) {
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
          product['name'] ?? 'Product',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          product['price'] ?? 'Price',
          style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
        ),
        trailing: IconButton(
          icon: Icon(Icons.favorite, color: colorScheme.primary),
          onPressed: () {},
        ),
      ),
    );
  }
}