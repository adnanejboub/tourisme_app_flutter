import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../core/constants/constants.dart';

class EventsExplorePage extends StatefulWidget {
  const EventsExplorePage({Key? key}) : super(key: key);

  @override
  State<EventsExplorePage> createState() => _EventsExplorePageState();
}

class _EventsExplorePageState extends State<EventsExplorePage> {
  final List<Map<String, dynamic>> _events = [
    {
      'id': 1,
      'title': 'Cinema World Music Festival',
      'date': 'June 10-15',
      'location': 'Essaouira',
      'image': 'https://images.unsplash.com/photo-1591414646028-7b60c18c6f14',
      'description': 'International music festival featuring world-renowned artists and traditional Moroccan music.',
      'category': 'music',
    },
    {
      'id': 2,
      'title': 'Rose Festival',
      'date': 'May 10-12',
      'location': 'Kelaat M\'Gouna',
      'image': 'https://images.unsplash.com/photo-1517685352821-92cf88aee5a5',
      'description': 'Annual celebration of the rose harvest with traditional ceremonies and cultural performances.',
      'category': 'culture',
    },
    {
      'id': 3,
      'title': 'Fes Festival of World Sacred Music',
      'date': 'June 14-22',
      'location': 'Fes',
      'image': 'https://images.unsplash.com/photo-1570191913384-b786dde7d9b4',
      'description': 'Spiritual music festival bringing together artists from different religious traditions.',
      'category': 'music',
    },
    {
      'id': 4,
      'title': 'Marrakech International Film Festival',
      'date': 'November 29 - December 7',
      'location': 'Marrakech',
      'image': 'https://images.unsplash.com/photo-1590736969955-71cc94901144',
      'description': 'International film festival showcasing the best of world cinema.',
      'category': 'film',
    },
    {
      'id': 5,
      'title': 'Tan-Tan Moussem',
      'date': 'July 15-20',
      'location': 'Tan-Tan',
      'image': 'https://images.unsplash.com/photo-1591414646028-7b60c18c6f14',
      'description': 'Traditional nomadic festival celebrating Saharan culture and heritage.',
      'category': 'culture',
    },
  ];

  String _selectedCategory = 'all';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer<LocalizationService>(
      builder: (context, localizationService, child) {
        return Scaffold(
          backgroundColor: colorScheme.background,
          appBar: AppBar(
            backgroundColor: colorScheme.background,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: colorScheme.onBackground),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Upcoming Events',
              style: TextStyle(
                color: colorScheme.onBackground,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          body: Column(
            children: [
              _buildCategoryFilter(colorScheme),
              Expanded(
                child: _buildEventsList(colorScheme),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryFilter(ColorScheme colorScheme) {
    final categories = [
      {'id': 'all', 'name': 'All Events'},
      {'id': 'music', 'name': 'Music'},
      {'id': 'culture', 'name': 'Culture'},
      {'id': 'film', 'name': 'Film'},
      {'id': 'food', 'name': 'Food & Wine'},
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: categories.map((category) {
            final isSelected = _selectedCategory == category['id'];
            return Container(
              margin: EdgeInsets.only(right: 12),
              child: FilterChip(
                avatar: isSelected ? Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                ) : null,
                label: Text(
                  category['name'] as String,
                  style: TextStyle(
                    color: isSelected ? Colors.white : colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedCategory = selected ? category['id'] as String : 'all';
                  });
                },
                backgroundColor: colorScheme.surface,
                selectedColor: colorScheme.primary,
                checkmarkColor: Colors.white,
                side: BorderSide(
                  color: isSelected ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.2),
                  width: 1,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEventsList(ColorScheme colorScheme) {
    final filteredEvents = _selectedCategory == 'all'
        ? _events
        : _events.where((event) => event['category'] == _selectedCategory).toList();

    if (filteredEvents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: colorScheme.onSurface.withOpacity(0.4),
            ),
            SizedBox(height: 16),
            Text(
              'No events found for this category',
              style: TextStyle(
                fontSize: 18,
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredEvents.length,
      itemBuilder: (context, index) {
        final event = filteredEvents[index];
        return _buildEventCard(event, colorScheme);
      },
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event, ColorScheme colorScheme) {
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
      child: InkWell(
        onTap: () {
          // Navigate to event details
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                event['image']!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: 200,
                    color: colorScheme.onSurface.withOpacity(0.1),
                    child: Icon(Icons.image, size: 64, color: colorScheme.onSurface.withOpacity(0.6)),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          event['category']!.toString().toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                      Spacer(),
                      Icon(
                        Icons.favorite_border,
                        color: colorScheme.onSurface.withOpacity(0.6),
                        size: 20,
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    event['title']!,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    event['description']!,
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurface.withOpacity(0.7),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                      SizedBox(width: 8),
                      Text(
                        event['date']!,
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      SizedBox(width: 24),
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                      SizedBox(width: 8),
                      Text(
                        event['location']!,
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EventDetailsPage extends StatelessWidget {
  final Map<String, dynamic> event;

  const EventDetailsPage({
    Key? key,
    required this.event,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            floating: false,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    event['image']!,
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
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event['title']!,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.grey[600]),
                      SizedBox(width: 8),
                      Text(
                        event['date']!,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.grey[600]),
                      SizedBox(width: 8),
                      Text(
                        event['location']!,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  Text(
                    event['description']!,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 32),
                  Container(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Navigate to booking
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(AppConstants.primaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Get Tickets',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

