import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../core/constants/constants.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer<LocalizationService>(
      builder: (context, localizationService, child) {
        final List<Map<String, dynamic>> recommendationsNearYou = [
          {
            'title': localizationService.translate('rec_park_title'),
            'subtitle': localizationService.translate('rec_park_subtitle'),
            'image': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400',
            'type': 'park',
            'rating': 4.8,
            'distance': '5 miles',
          },
          {
            'title': localizationService.translate('rec_museum_title'),
            'subtitle': localizationService.translate('rec_museum_subtitle'),
            'image': 'https://images.unsplash.com/photo-1544026488-31c3f2a5df1f?w=400',
            'type': 'museum',
            'rating': 4.6,
            'distance': 'Downtown',
          },
        ];

        final List<Map<String, dynamic>> trendingDestinations = [
          {
            'name': localizationService.translate('trending_paris_name'),
            'subtitle': localizationService.translate('trending_paris_subtitle'),
            'image': 'https://images.unsplash.com/photo-1502602898536-47ad22581b52?w=400',
            'rating': 4.8,
            'reviews': '2.1K',
          },
          {
            'name': localizationService.translate('trending_kyoto_name'),
            'subtitle': localizationService.translate('trending_kyoto_subtitle'),
            'image': 'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?w=400',
            'rating': 4.9,
            'reviews': '1.8K',
          },
        ];

        final List<Map<String, dynamic>> seasonalHighlights = [
          {
            'title': localizationService.translate('seasonal_summer_title'),
            'subtitle': localizationService.translate('seasonal_summer_subtitle'),
            'image': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=400',
            'destinations': ['Agadir', 'Essaouira', 'Tangier'],
          },
          {
            'title': localizationService.translate('seasonal_autumn_title'),
            'subtitle': localizationService.translate('seasonal_autumn_subtitle'),
            'image': 'https://images.unsplash.com/photo-1507041957456-9c397ce39c97?w=400',
            'destinations': ['Atlas Mountains', 'Ifrane', 'Azrou'],
          },
        ];

        final List<Map<String, dynamic>> featuredCities = [
          {
            'name': localizationService.translate('city_nyc_name'),
            'country': 'USA',
            'image': 'https://images.unsplash.com/photo-1496442226666-8d4d0e62e6e9?w=400',
            'rating': 4.4,
            'reviews': '7K',
            'tags': [
              localizationService.translate('tag_business'),
              localizationService.translate('tag_art_culture')
            ],
            'isFavorite': false,
          },
          {
            'name': localizationService.translate('city_paris_name'),
            'country': 'France',
            'image': 'https://images.unsplash.com/photo-1502602898536-47ad22581b52?w=400',
            'rating': 4.6,
            'reviews': '12K',
            'tags': [
              localizationService.translate('tag_museums'),
              localizationService.translate('tag_cultural_attractions')
            ],
            'isFavorite': true,
          },
          {
            'name': localizationService.translate('city_tokyo_name'),
            'country': 'Japan',
            'image': 'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?w=400',
            'rating': 4.7,
            'reviews': '8.5K',
            'tags': [
              localizationService.translate('tag_technology'),
              localizationService.translate('tag_traditional_culture')
            ],
            'isFavorite': false,
          },
        ];

        return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: colorScheme.background,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = constraints.maxWidth;
                final screenHeight = constraints.maxHeight;
                final isTablet = screenWidth > 600;
                final isDesktop = screenWidth > 900;
                final isLandscape = screenWidth > screenHeight;

                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 24 : (isTablet ? 20 : 16),
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(localizationService, screenWidth, isTablet, isDesktop, colorScheme),
                      SizedBox(height: isDesktop ? 24 : 16),
                      _buildSearchBar(localizationService, screenWidth, isTablet, isDesktop, colorScheme),
                      SizedBox(height: isDesktop ? 24 : 16),
                      _buildSection(
                        localizationService.translate('home_recommendations_title'),
                        recommendationsNearYou,
                            (item) => _buildRecommendationCard(item, screenWidth, isTablet, isDesktop, colorScheme),
                        screenWidth,
                        isTablet,
                        isDesktop,
                        colorScheme,
                      ),
                      _buildSection(
                        localizationService.translate('home_trending_title'),
                        trendingDestinations,
                            (item) => _buildTrendingDestinationCard(item, localizationService, screenWidth, isTablet, isDesktop, colorScheme),
                        screenWidth,
                        isTablet,
                        isDesktop,
                        colorScheme,
                      ),
                      _buildSection(
                        localizationService.translate('home_seasonal_title'),
                        seasonalHighlights,
                            (item) => _buildSeasonalHighlightCard(item, screenWidth, isTablet, isDesktop, colorScheme),
                        screenWidth,
                        isTablet,
                        isDesktop,
                        colorScheme,
                      ),
                      _buildFeaturedCities(localizationService, featuredCities, screenWidth, isTablet, isDesktop, colorScheme),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(LocalizationService localizationService, double screenWidth, bool isTablet, bool isDesktop, ColorScheme colorScheme) {
    final titleSize = isDesktop ? 28.0 : (isTablet ? 26.0 : 24.0);
    final subtitleSize = isDesktop ? 22.0 : (isTablet ? 21.0 : 20.0);
    final iconSize = isDesktop ? 32.0 : (isTablet ? 30.0 : 28.0);

    return Container(
      padding: EdgeInsets.all(isDesktop ? 20 : 16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  localizationService.translate('home_title'),
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              Icon(
                Icons.notifications_outlined,
                color: colorScheme.onSurface.withOpacity(0.6),
                size: iconSize,
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            '${localizationService.translate('home_welcome')}, Adnane Jboub',
            style: TextStyle(
              fontSize: subtitleSize,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(LocalizationService localizationService, double screenWidth, bool isTablet, bool isDesktop, ColorScheme colorScheme) {
    final fontSize = isDesktop ? 16.0 : (isTablet ? 15.0 : 14.0);
    final iconSize = isDesktop ? 24.0 : (isTablet ? 22.0 : 20.0);

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: localizationService.translate('home_search_hint'),
          hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.6), fontSize: fontSize),
          prefixIcon: Icon(Icons.search, color: colorScheme.onSurface.withOpacity(0.6), size: iconSize),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 20 : 16,
            vertical: isDesktop ? 16 : 12,
          ),
        ),
        onTap: () {
          Navigator.pushNamed(context, '/search');
        },
      ),
    );
  }

  Widget _buildSection(
      String title,
      List<Map<String, dynamic>> items,
      Widget Function(Map<String, dynamic>) cardBuilder,
      double screenWidth,
      bool isTablet,
      bool isDesktop,
      ColorScheme colorScheme,
      ) {
    final titleSize = isDesktop ? 22.0 : (isTablet ? 21.0 : 20.0);
    final cardHeight = isDesktop ? 280.0 : (isTablet ? 260.0 : 250.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(0, isDesktop ? 20 : 16, 0, isDesktop ? 12 : 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        SizedBox(
          height: cardHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(left: isDesktop ? 4 : 0),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(right: isDesktop ? 20 : 16),
                child: cardBuilder(items[index]),
              );
            },
          ),
        ),
        SizedBox(height: isDesktop ? 20 : 16),
      ],
    );
  }

  Widget _buildFeaturedCities(
      LocalizationService localizationService,
      List<Map<String, dynamic>> cities,
      double screenWidth,
      bool isTablet,
      bool isDesktop,
      ColorScheme colorScheme,
      ) {
    final titleSize = isDesktop ? 22.0 : (isTablet ? 21.0 : 20.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(0, isDesktop ? 20 : 16, 0, isDesktop ? 12 : 8),
          child: Text(
            localizationService.translate('home_featured_cities_title'),
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        isDesktop && screenWidth > 1200
            ? GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemCount: cities.length,
          itemBuilder: (context, index) {
            return _buildFeaturedCityCard(cities[index], localizationService, screenWidth, isTablet, isDesktop, colorScheme);
          },
        )
            : ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: cities.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.only(bottom: isDesktop ? 16 : 12),
              child: _buildFeaturedCityCard(cities[index], localizationService, screenWidth, isTablet, isDesktop, colorScheme),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecommendationCard(Map<String, dynamic> recommendation, double screenWidth, bool isTablet, bool isDesktop, ColorScheme colorScheme) {
    final cardWidth = isDesktop ? 320.0 : (isTablet ? 300.0 : 280.0);
    final imageHeight = isDesktop ? 120.0 : (isTablet ? 100.0 : 80.0);
    final titleSize = isDesktop ? 18.0 : (isTablet ? 17.0 : 16.0);
    final subtitleSize = isDesktop ? 15.0 : (isTablet ? 14.5 : 14.0);

    return Container(
      width: cardWidth,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: imageHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              image: DecorationImage(
                image: NetworkImage(recommendation['image']),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(isDesktop ? 16 : 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recommendation['title'],
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    recommendation['subtitle'],
                    style: TextStyle(
                      fontSize: subtitleSize,
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingDestinationCard(
      Map<String, dynamic> destination,
      LocalizationService localizationService,
      double screenWidth,
      bool isTablet,
      bool isDesktop,
      ColorScheme colorScheme,
      ) {
    final cardWidth = isDesktop ? 180.0 : (isTablet ? 170.0 : 160.0);
    final imageHeight = isDesktop ? 140.0 : (isTablet ? 130.0 : 120.0);
    final titleSize = isDesktop ? 16.0 : (isTablet ? 15.0 : 14.0);
    final subtitleSize = isDesktop ? 13.0 : (isTablet ? 12.5 : 12.0);

    return Container(
      width: cardWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: imageHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: NetworkImage(destination['image']),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: subtitleSize),
                        SizedBox(width: 4),
                        Text(
                          destination['rating'].toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: subtitleSize,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    destination['name'],
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    destination['subtitle'],
                    style: TextStyle(
                      fontSize: subtitleSize,
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeasonalHighlightCard(Map<String, dynamic> highlight, double screenWidth, bool isTablet, bool isDesktop, ColorScheme colorScheme) {
    final cardWidth = isDesktop ? 240.0 : (isTablet ? 220.0 : 200.0);
    final titleSize = isDesktop ? 18.0 : (isTablet ? 17.0 : 16.0);
    final subtitleSize = isDesktop ? 13.0 : (isTablet ? 12.5 : 12.0);

    return Container(
      width: cardWidth,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: NetworkImage(highlight['image']),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(isDesktop ? 16 : 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                highlight['title'],
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4),
              Text(
                highlight['subtitle'],
                style: TextStyle(
                  fontSize: subtitleSize,
                  color: Colors.white.withOpacity(0.9),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedCityCard(
      Map<String, dynamic> city,
      LocalizationService localizationService,
      double screenWidth,
      bool isTablet,
      bool isDesktop,
      ColorScheme colorScheme,
      ) {
    final imageHeight = isDesktop ? 200.0 : (isTablet ? 190.0 : 180.0);
    final titleSize = isDesktop ? 20.0 : (isTablet ? 19.0 : 18.0);
    final ratingSize = isDesktop ? 15.0 : (isTablet ? 14.5 : 14.0);
    final reviewSize = isDesktop ? 13.0 : (isTablet ? 12.5 : 12.0);
    final tagSize = isDesktop ? 13.0 : (isTablet ? 12.5 : 12.0);
    final iconSize = isDesktop ? 22.0 : (isTablet ? 21.0 : 20.0);

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: imageHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              image: DecorationImage(
                image: NetworkImage(city['image']),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    width: isDesktop ? 40 : 36,
                    height: isDesktop ? 40 : 36,
                    decoration: BoxDecoration(
                      color: colorScheme.surface.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      city['isFavorite'] ? Icons.favorite : Icons.favorite_border,
                      color: city['isFavorite'] ? Colors.red : colorScheme.onSurface.withOpacity(0.6),
                      size: iconSize,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(isDesktop ? 16 : 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        city['name'],
                        style: TextStyle(
                          fontSize: titleSize,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: ratingSize + 1),
                        SizedBox(width: 4),
                        Text(
                          city['rating'].toString(),
                          style: TextStyle(
                            fontSize: ratingSize,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(width: 4),
                        Text(
                          '(${city['reviews']} ${localizationService.translate('reviews_label')})',
                          style: TextStyle(
                            fontSize: reviewSize,
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: (city['tags'] as List<String>).map((tag) {
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 14 : 12,
                        vertical: isDesktop ? 8 : 6,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          fontSize: tagSize,
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}