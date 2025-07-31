import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/localization_service.dart'; // Assurez-vous que le chemin est correct
import '../../../../core/constants/constants.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
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
          backgroundColor: Colors.grey[50],
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(localizationService),
                  _buildSearchBar(localizationService),
                  _buildSection(
                      localizationService.translate('home_recommendations_title'),
                      recommendationsNearYou,
                      _buildRecommendationCard),
                  _buildSection(
                      localizationService.translate('home_trending_title'),
                      trendingDestinations,
                          (item) => _buildTrendingDestinationCard(item, localizationService)),
                  _buildSection(
                      localizationService.translate('home_seasonal_title'),
                      seasonalHighlights,
                      _buildSeasonalHighlightCard),
                  _buildFeaturedCities(localizationService, featuredCities),

                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(LocalizationService localizationService) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
              Text(
                localizationService.translate('home_title'),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Icon(
                Icons.notifications_outlined,
                color: Colors.grey[600],
                size: 28,
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            '${localizationService.translate('home_welcome')}, Nasreddine Bikikre',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(LocalizationService localizationService) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
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
            hintStyle: TextStyle(color: Colors.grey[500]),
            prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onTap: () {
            Navigator.pushNamed(context, '/search');
          },
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Map<String, dynamic>> items,
      Widget Function(Map<String, dynamic>) cardBuilder) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(0, 16, 0, 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        SizedBox(
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return cardBuilder(items[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedCities(LocalizationService localizationService,
      List<Map<String, dynamic>> cities) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(0, 16, 0, 8),
          child: Text(
            localizationService.translate('home_featured_cities_title'),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: cities.length,
          itemBuilder: (context, index) {
            return _buildFeaturedCityCard(cities[index], localizationService);
          },
        ),
      ],
    );
  }

  Widget _buildRecommendationCard(Map<String, dynamic> recommendation) {
    return Container(
      width: 280,
      margin: EdgeInsets.only(right: 16 , bottom: 16 ),
      decoration: BoxDecoration(
        color: Colors.white,
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
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              image: DecorationImage(
                image: NetworkImage(recommendation['image']),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recommendation['title'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  recommendation['subtitle'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingDestinationCard(
      Map<String, dynamic> destination, LocalizationService localizationService) {
    return Container(
      width: 160,
      margin: EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
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
                        Icon(Icons.star, color: Colors.amber, size: 12),
                        SizedBox(width: 4),
                        Text(
                          destination['rating'].toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
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
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  destination['name'],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  destination['subtitle'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeasonalHighlightCard(Map<String, dynamic> highlight) {
    return Container(
      width: 200,
      margin: EdgeInsets.only(right: 16),
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
          padding: EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                highlight['title'],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 4),
              Text(
                highlight['subtitle'],
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedCityCard(
      Map<String, dynamic> city, LocalizationService localizationService) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
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
            height: 180,
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
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      city['isFavorite']
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color:
                      city['isFavorite'] ? Colors.red : Colors.grey[600],
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12),
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
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        SizedBox(width: 4),
                        Text(
                          city['rating'].toString(),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(width: 4),
                        Text(
                          '(${city['reviews']} ${localizationService.translate('reviews_label')})',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
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
                      padding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Color(AppConstants.primaryColor).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(AppConstants.primaryColor),
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