import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../core/constants/constants.dart';
import 'itinerary_result_page.dart';

class ItineraryPlanningPage extends StatefulWidget {
  final Map<String, dynamic>? destination;

  const ItineraryPlanningPage({
    super.key,
    this.destination,
  });

  @override
  State<ItineraryPlanningPage> createState() => _ItineraryPlanningPageState();
}

class _ItineraryPlanningPageState extends State<ItineraryPlanningPage> {
  int _selectedDays = 3;
  String _selectedBudget = 'mid_range';
  List<String> _selectedActivities = [];
  DateTime _startDate = DateTime.now().add(const Duration(days: 7));
  bool _isGenerating = false;

  final List<Map<String, dynamic>> _availableActivities = [
    {
      'id': 'sightseeing',
      'name': 'Sightseeing',
      'icon': Icons.visibility,
      'duration': '2-4 hours',
      'description': 'Visit famous landmarks and attractions',
    },
    {
      'id': 'food_tour',
      'name': 'Food Tour',
      'icon': Icons.restaurant,
      'duration': '3-4 hours',
      'description': 'Explore local cuisine and traditional dishes',
    },
    {
      'id': 'shopping',
      'name': 'Shopping',
      'icon': Icons.shopping_bag,
      'duration': '2-3 hours',
      'description': 'Visit markets, souks and shopping districts',
    },
    {
      'id': 'cultural_visit',
      'name': 'Cultural Visit',
      'icon': Icons.museum,
      'duration': '1-2 hours',
      'description': 'Explore museums, historical sites and cultural centers',
    },
    {
      'id': 'adventure',
      'name': 'Adventure',
      'icon': Icons.directions_bike,
      'duration': '4-6 hours',
      'description': 'Outdoor activities and adventure sports',
    },
    {
      'id': 'relaxation',
      'name': 'Relaxation',
      'icon': Icons.spa,
      'duration': '2-3 hours',
      'description': 'Wellness activities and relaxation spots',
    },
  ];

  final Map<String, Map<String, dynamic>> _budgetRanges = {
    'budget': {
      'name': 'Budget',
      'range': '300-800 MAD/day',
      'description': 'Affordable options, hostels, local restaurants',
      'icon': Icons.account_balance_wallet,
    },
    'mid_range': {
      'name': 'Mid-Range',
      'range': '800-1500 MAD/day',
      'description': 'Comfortable hotels, good restaurants, guided tours',
      'icon': Icons.star,
    },
    'luxury': {
      'name': 'Luxury',
      'range': '1500+ MAD/day',
      'description': 'Premium hotels, fine dining, private guides',
      'icon': Icons.diamond,
    },
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final localizationService = Provider.of<LocalizationService>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 900;

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
          'Plan Your Trip to ${widget.destination?['name'] ?? 'Morocco'}',
          style: TextStyle(
            color: colorScheme.onBackground,
            fontWeight: FontWeight.bold,
            fontSize: isDesktop ? 22 : (isTablet ? 20 : 18),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isDesktop ? 24 : (isTablet ? 20 : 16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDestinationInfo(colorScheme, localizationService, isTablet, isDesktop),
            SizedBox(height: isDesktop ? 40 : 32),
            _buildTripDurationSection(colorScheme, localizationService, isTablet, isDesktop),
            SizedBox(height: isDesktop ? 40 : 32),
            _buildBudgetSection(colorScheme, localizationService, isTablet, isDesktop),
            SizedBox(height: isDesktop ? 40 : 32),
            _buildStartDateSection(colorScheme, localizationService, isTablet, isDesktop),
            SizedBox(height: isDesktop ? 40 : 32),
            _buildActivitiesSection(colorScheme, localizationService, isTablet, isDesktop),
            SizedBox(height: isDesktop ? 40 : 32),
            _buildActionButton(colorScheme, localizationService, isTablet, isDesktop),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDestinationInfo(ColorScheme colorScheme, LocalizationService localizationService, bool isTablet, bool isDesktop) {
    final destination = widget.destination;
    if (destination == null) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : (isTablet ? 20 : 16)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withOpacity(0.1),
            colorScheme.primary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              destination['image'] as String? ?? 'https://images.unsplash.com/photo-1517685352821-92cf88aee5a5',
              width: isDesktop ? 80 : (isTablet ? 70 : 60),
              height: isDesktop ? 80 : (isTablet ? 70 : 60),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: isDesktop ? 80 : (isTablet ? 70 : 60),
                  height: isDesktop ? 80 : (isTablet ? 70 : 60),
                  color: colorScheme.surfaceVariant,
                  child: Icon(
                    Icons.image,
                    color: colorScheme.onSurfaceVariant,
                    size: isDesktop ? 32 : (isTablet ? 28 : 24),
                  ),
                );
              },
            ),
          ),
          SizedBox(width: isDesktop ? 24 : (isTablet ? 20 : 16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  destination['name'] as String? ?? 'Unknown Destination',
                  style: TextStyle(
                    fontSize: isDesktop ? 24 : (isTablet ? 22 : 18),
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  destination['description'] as String? ?? 'Discover the beauty and culture of this amazing destination',
                  style: TextStyle(
                    fontSize: isDesktop ? 16 : (isTablet ? 15 : 14),
                    color: colorScheme.onSurface.withOpacity(0.7),
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: isDesktop ? 20 : 18),
                    SizedBox(width: 8),
                    Text(
                      '${destination['rating'] ?? 4.5}/5',
                      style: TextStyle(
                        fontSize: isDesktop ? 16 : 14,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(width: 16),
                    Icon(Icons.location_on, color: colorScheme.primary, size: isDesktop ? 20 : 18),
                    SizedBox(width: 8),
                    Text(
                      destination['tags']?.join(', ') ?? 'Morocco',
                      style: TextStyle(
                        fontSize: isDesktop ? 16 : 14,
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripDurationSection(ColorScheme colorScheme, LocalizationService localizationService, bool isTablet, bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trip Duration',
          style: TextStyle(
            fontSize: isDesktop ? 22 : (isTablet ? 20 : 18),
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'How many days do you want to spend in ${widget.destination?['name'] ?? 'Morocco'}?',
          style: TextStyle(
            fontSize: isDesktop ? 16 : 14,
            color: colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        SizedBox(height: isDesktop ? 24 : 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: isDesktop ? 4 : (isTablet ? 4 : 2),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: isDesktop ? 1.5 : 1.2,
          children: [
            _buildDurationOption(1, '1 Day', 'Quick visit', colorScheme, isTablet, isDesktop),
            _buildDurationOption(2, '2 Days', 'Weekend trip', colorScheme, isTablet, isDesktop),
            _buildDurationOption(3, '3 Days', 'Short break', colorScheme, isTablet, isDesktop),
            _buildDurationOption(5, '5 Days', 'Extended stay', colorScheme, isTablet, isDesktop),
            _buildDurationOption(7, '1 Week', 'Full week', colorScheme, isTablet, isDesktop),
            _buildDurationOption(10, '10 Days', 'Long vacation', colorScheme, isTablet, isDesktop),
          ],
        ),
      ],
    );
  }

  Widget _buildDurationOption(int days, String label, String subtitle, ColorScheme colorScheme, bool isTablet, bool isDesktop) {
    final isSelected = _selectedDays == days;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedDays = days;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(isDesktop ? 16 : 12),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.outline.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected 
                ? colorScheme.primary.withOpacity(0.3)
                : colorScheme.shadow.withOpacity(0.1),
              blurRadius: isSelected ? 8 : 4,
              offset: Offset(0, isSelected ? 4 : 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: isDesktop ? 18 : (isTablet ? 16 : 14),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: isSelected ? colorScheme.onPrimary.withOpacity(0.8) : colorScheme.onSurface.withOpacity(0.6),
                fontSize: isDesktop ? 14 : 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetSection(ColorScheme colorScheme, LocalizationService localizationService, bool isTablet, bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Budget Range',
          style: TextStyle(
            fontSize: isDesktop ? 22 : (isTablet ? 20 : 18),
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Select your preferred budget range for this trip',
          style: TextStyle(
            fontSize: isDesktop ? 16 : 14,
            color: colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        SizedBox(height: isDesktop ? 24 : 16),
        Column(
          children: _budgetRanges.entries.map((entry) {
            final budget = entry.key;
            final budgetInfo = entry.value;
            final isSelected = _selectedBudget == budget;
            
            return Container(
              margin: EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedBudget = budget;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: EdgeInsets.all(isDesktop ? 20 : 16),
                  decoration: BoxDecoration(
                    color: isSelected ? colorScheme.primary : colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? colorScheme.primary : colorScheme.outline.withOpacity(0.3),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected 
                          ? colorScheme.primary.withOpacity(0.2)
                          : colorScheme.shadow.withOpacity(0.05),
                        blurRadius: isSelected ? 8 : 4,
                        offset: Offset(0, isSelected ? 4 : 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected 
                            ? colorScheme.onPrimary.withOpacity(0.2)
                            : colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          budgetInfo['icon'] as IconData,
                          color: isSelected ? colorScheme.onPrimary : colorScheme.primary,
                          size: isDesktop ? 28 : 24,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              budgetInfo['name'] as String,
                              style: TextStyle(
                                color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                                fontSize: isDesktop ? 18 : 16,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              budgetInfo['range'] as String,
                              style: TextStyle(
                                color: isSelected ? colorScheme.onPrimary.withOpacity(0.9) : colorScheme.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: isDesktop ? 16 : 14,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              budgetInfo['description'] as String,
                              style: TextStyle(
                                color: isSelected ? colorScheme.onPrimary.withOpacity(0.8) : colorScheme.onSurface.withOpacity(0.7),
                                fontSize: isDesktop ? 14 : 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle,
                          color: colorScheme.onPrimary,
                          size: isDesktop ? 28 : 24,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStartDateSection(ColorScheme colorScheme, LocalizationService localizationService, bool isTablet, bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Start Date',
          style: TextStyle(
            fontSize: isDesktop ? 22 : (isTablet ? 20 : 18),
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'When would you like to start your trip?',
          style: TextStyle(
            fontSize: isDesktop ? 16 : 14,
            color: colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        SizedBox(height: isDesktop ? 24 : 16),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _startDate,
              firstDate: DateTime.now().add(const Duration(days: 1)),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: colorScheme,
                    dialogBackgroundColor: colorScheme.surface,
                  ),
                  child: child!,
                );
              },
            );
            if (date != null) {
              setState(() {
                _startDate = date;
              });
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsets.all(isDesktop ? 24 : 20),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.primary.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.calendar_today,
                    color: colorScheme.primary,
                    size: isDesktop ? 28 : 24,
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected Date',
                        style: TextStyle(
                          fontSize: isDesktop ? 16 : 14,
                          color: colorScheme.onSurface.withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        DateFormat('EEEE, MMMM dd, yyyy').format(_startDate),
                        style: TextStyle(
                          fontSize: isDesktop ? 20 : 18,
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${_startDate.difference(DateTime.now()).inDays} days from now',
                        style: TextStyle(
                          fontSize: isDesktop ? 16 : 14,
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.edit_calendar,
                  color: colorScheme.primary,
                  size: isDesktop ? 28 : 24,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivitiesSection(ColorScheme colorScheme, LocalizationService localizationService, bool isTablet, bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Activities & Interests',
          style: TextStyle(
            fontSize: isDesktop ? 22 : (isTablet ? 20 : 18),
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Select the activities that interest you most (select at least 2)',
          style: TextStyle(
            fontSize: isDesktop ? 16 : 14,
            color: colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        SizedBox(height: isDesktop ? 24 : 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isDesktop ? 3 : (isTablet ? 2 : 2),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: isDesktop ? 1.1 : 1.0,
          ),
          itemCount: _availableActivities.length,
          itemBuilder: (context, index) {
            final activity = _availableActivities[index];
            final isSelected = _selectedActivities.contains(activity['id'] as String);

            return InkWell(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedActivities.remove(activity['id']);
                  } else {
                    _selectedActivities.add(activity['id'] as String);
                  }
                });
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? colorScheme.primary : colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? colorScheme.primary : colorScheme.outline.withOpacity(0.3),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected 
                        ? colorScheme.primary.withOpacity(0.2)
                        : colorScheme.shadow.withOpacity(0.1),
                      blurRadius: isSelected ? 8 : 4,
                      offset: Offset(0, isSelected ? 4 : 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected 
                          ? colorScheme.onPrimary.withOpacity(0.2)
                          : colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        activity['icon'] as IconData,
                        color: isSelected ? colorScheme.onPrimary : colorScheme.primary,
                        size: isDesktop ? 32 : 28,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      activity['name'] as String,
                      style: TextStyle(
                        color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: isDesktop ? 16 : 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 6),
                    Text(
                      activity['duration'] as String,
                      style: TextStyle(
                        color: isSelected ? colorScheme.onPrimary.withOpacity(0.8) : colorScheme.onSurface.withOpacity(0.7),
                        fontSize: isDesktop ? 14 : 12,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4),
                    Text(
                      activity['description'] as String,
                      style: TextStyle(
                        color: isSelected ? colorScheme.onPrimary.withOpacity(0.7) : colorScheme.onSurface.withOpacity(0.6),
                        fontSize: isDesktop ? 12 : 10,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButton(ColorScheme colorScheme, LocalizationService localizationService, bool isTablet, bool isDesktop) {
    final canGenerate = _selectedActivities.length >= 2 && !_isGenerating;
    
    return Container(
      width: double.infinity,
      height: isDesktop ? 64 : 56,
      child: ElevatedButton(
        onPressed: canGenerate ? _generateItinerary : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: canGenerate ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.3),
          foregroundColor: canGenerate ? colorScheme.onPrimary : colorScheme.onSurface.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: canGenerate ? 4 : 0,
        ),
        child: _isGenerating
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: isDesktop ? 24 : 20,
                    height: isDesktop ? 24 : 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onPrimary),
                    ),
                  ),
                  SizedBox(width: 16),
                  Text(
                    'Generating Itinerary...',
                    style: TextStyle(
                      fontSize: isDesktop ? 18 : 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: isDesktop ? 28 : 24,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Generate Smart Itinerary',
                    style: TextStyle(
                      fontSize: isDesktop ? 18 : 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _generateItinerary() async {
    if (_selectedActivities.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select at least 2 activities to generate an itinerary'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    // Simuler la génération d'itinéraire
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isGenerating = false;
    });

    // Naviguer vers la page de résultat
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItineraryResultPage(
          destination: widget.destination,
          tripData: {
            'days': _selectedDays,
            'budget': _selectedBudget,
            'activities': _selectedActivities,
            'startDate': _startDate,
            'budgetInfo': _budgetRanges[_selectedBudget],
          },
        ),
      ),
    );
  }
}