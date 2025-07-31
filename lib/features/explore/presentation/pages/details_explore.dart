import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../core/constants/constants.dart';
import 'itinerary_planning_page.dart';

class DetailsExplorePage extends StatefulWidget {
  final Map<String, dynamic> destination;

  const DetailsExplorePage({
    Key? key,
    required this.destination,
  }) : super(key: key);

  @override
  State<DetailsExplorePage> createState() => _DetailsExplorePageState();
}

class _DetailsExplorePageState extends State<DetailsExplorePage> {
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalizationService>(
      builder: (context, localizationService, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: CustomScrollView(
            slivers: [
              _buildSliverAppBar(localizationService),
              SliverToBoxAdapter(
                child: _buildContent(localizationService),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSliverAppBar(LocalizationService localizationService) {
    return SliverAppBar(
      expandedHeight: 300,
      floating: false,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.black87),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        widget.destination['name'] ?? 'Destination',
        style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.red : Colors.black87,
          ),
          onPressed: () {
            setState(() {
              isFavorite = !isFavorite;
            });
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              widget.destination['imageUrl'] ?? 'https://images.unsplash.com/photo-1517685352821-92cf88aee5a5',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: Icon(Icons.image, size: 100, color: Colors.grey[600]),
                );
              },
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(LocalizationService localizationService) {
    return Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDestinationInfo(localizationService),
          SizedBox(height: 32),
          _buildKeyAttractions(localizationService),
          SizedBox(height: 32),
          _buildRecommendedActivities(localizationService),
          SizedBox(height: 32),
          _buildLocationMap(localizationService),
          SizedBox(height: 32),
          _buildActionButton(localizationService),
        ],
      ),
    );
  }

  Widget _buildDestinationInfo(LocalizationService localizationService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.destination['name'] ?? 'Destination',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        Text(
          widget.destination['arabicName'] ?? 'The Red City',
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 16),
        Text(
          widget.destination['description'] ?? 'A vibrant city in Morocco, known for its bustling souks, historic palaces, and beautiful gardens. It\'s a major economic center and tourist destination, offering a rich cultural experience with its ancient medina, lively squares, and stunning architecture.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildKeyAttractions(LocalizationService localizationService) {
    final attractions = widget.destination['attractions'] as List<String>? ?? [
      'Jemaa el-Fna Square',
      'Bahia Palace',
      'Jardin Majorelle',
      'Koutoubia Mosque',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Attractions',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 16),
        ...attractions.map((attraction) => Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Icon(
                Icons.location_on,
                color: Color(AppConstants.primaryColor),
                size: 20,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  attraction,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildRecommendedActivities(LocalizationService localizationService) {
    final activities = [
      {
        'title': 'Explore the Souks',
        'location': '${widget.destination['name']} Medina',
        'image': 'https://images.unsplash.com/photo-1517685352821-92cf88aee5a5',
      },
      {
        'title': 'Visit the Secret Garden',
        'location': widget.destination['name'],
        'image': 'https://images.unsplash.com/photo-1570191913384-b786dde7d9b4',
      },
      {
        'title': 'Enjoy a traditional Hammam',
        'location': 'Various locations',
        'image': 'https://images.unsplash.com/photo-1590736969955-71cc94901144',
      },
      {
        'title': 'Hot Air Balloon Ride',
        'location': 'Palmerale, ${widget.destination['name']}',
        'image': 'https://images.unsplash.com/photo-1591414646028-7b60c18c6f14',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recommended Activities',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 16),
        ...activities.map((activity) => _buildActivityCard(activity)).toList(),
      ],
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> activity) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
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
                    color: Colors.grey[300],
                    child: Icon(Icons.image, color: Colors.grey[600]),
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
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    activity['location']!,
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
      ),
    );
  }

  Widget _buildLocationMap(LocalizationService localizationService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location on Map',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 16),
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.map,
                  size: 48,
                  color: Colors.grey[600],
                ),
                SizedBox(height: 8),
                Text(
                  'Map View',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(LocalizationService localizationService) {
    return Container(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ItineraryPlanningPage(destination: widget.destination),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(AppConstants.primaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          'Plan Your Itinerary',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
} 