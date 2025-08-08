import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tourisme_app_flutter/features/marketplace/home/pages/home.dart';
import 'home_page.dart';
import '../../../explore/presentation/pages/explore_page.dart';
import '../../../products/presentation/pages/products_page.dart';
import '../../../saved/presentation/pages/saved_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../core/constants/constants.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({Key? key}) : super(key: key);

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int selectedBottomIndex = 0;

  final List<Widget> pages = [
    HomePage(),
    ExplorePage(),
    MarketplacePage(),
    SavedPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Consumer<LocalizationService>(
      builder: (context, localizationService, child) {
        return Scaffold(
          body: IndexedStack(
            index: selectedBottomIndex,
            children: pages,
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: Offset(0, -5),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: selectedBottomIndex,
              onTap: (index) => setState(() => selectedBottomIndex = index),
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: colorScheme.primary,
              unselectedItemColor: colorScheme.onSurface.withOpacity(0.6),
              selectedLabelStyle: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: 12,
              ),
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined, size: 24),
                  activeIcon: Icon(Icons.home, size: 24),
                  label: localizationService.translate('nav_home'),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.explore_outlined, size: 24),
                  activeIcon: Icon(Icons.explore, size: 24),
                  label: localizationService.translate('nav_explore'),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_bag_outlined, size: 24),
                  activeIcon: Icon(Icons.shopping_bag, size: 24),
                  label: localizationService.translate('nav_products'),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.favorite_border, size: 24),
                  activeIcon: Icon(Icons.favorite, size: 24),
                  label: localizationService.translate('wishlist'),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline, size: 24),
                  activeIcon: Icon(Icons.person, size: 24),
                  label: localizationService.translate('nav_profile'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}