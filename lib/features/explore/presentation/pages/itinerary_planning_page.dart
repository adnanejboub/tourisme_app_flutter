import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../core/constants/constants.dart';

class ItineraryPlanningPage extends StatefulWidget {
  final Map<String, dynamic>? destination;

  const ItineraryPlanningPage({
    Key? key,
    this.destination,
  }) : super(key: key);

  @override
  State<ItineraryPlanningPage> createState() => _ItineraryPlanningPageState();
}

class _ItineraryPlanningPageState extends State<ItineraryPlanningPage> {
  int _selectedDays = 3;
  String _selectedBudget = 'mid_range';
  List<String> _selectedActivities = [];
  DateTime _startDate = DateTime.now().add(Duration(days: 7));

  final List<Map<String, dynamic>> _availableActivities = [
    {
      'id': 'sightseeing',
      'name': 'Sightseeing',
      'icon': Icons.visibility,
      'duration': '2-4 hours',
    },
    {
      'id': 'food_tour',
      'name': 'Food Tour',
      'icon': Icons.restaurant,
      'duration': '3-4 hours',
    },
    {
      'id': 'shopping',
      'name': 'Shopping',
      'icon': Icons.shopping_bag,
      'duration': '2-3 hours',
    },
    {
      'id': 'cultural_visit',
      'name': 'Cultural Visit',
      'icon': Icons.museum,
      'duration': '1-2 hours',
    },
    {
      'id': 'adventure',
      'name': 'Adventure',
      'icon': Icons.directions_bike,
      'duration': '4-6 hours',
    },
    {
      'id': 'relaxation',
      'name': 'Relaxation',
      'icon': Icons.spa,
      'duration': '2-3 hours',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalizationService>(
      builder: (context, localizationService, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Plan Your Itinerary',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDestinationInfo(),
                SizedBox(height: 32),
                _buildTripDurationSection(),
                SizedBox(height: 32),
                _buildBudgetSection(),
                SizedBox(height: 32),
                _buildStartDateSection(),
                SizedBox(height: 32),
                _buildActivitiesSection(),
                SizedBox(height: 32),
                _buildActionButton(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDestinationInfo() {
    final destination = widget.destination;
    if (destination == null) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              destination['image'] ?? 'https://images.unsplash.com/photo-1517685352821-92cf88aee5a5',
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
                  destination['name'] ?? 'Destination',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  destination['arabicName'] ?? '',
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

  Widget _buildTripDurationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trip Duration',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildDurationOption(1, '1 Day'),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildDurationOption(2, '2 Days'),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildDurationOption(3, '3 Days'),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildDurationOption(5, '5 Days'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDurationOption(int days, String label) {
    final isSelected = _selectedDays == days;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedDays = days;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Color(AppConstants.primaryColor) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Color(AppConstants.primaryColor) : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildBudgetSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Budget Range',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildBudgetOption('budget', 'Budget'),
            _buildBudgetOption('mid_range', 'Mid-range'),
            _buildBudgetOption('luxury', 'Luxury'),
          ],
        ),
      ],
    );
  }

  Widget _buildBudgetOption(String budget, String label) {
    final isSelected = _selectedBudget == budget;
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedBudget = selected ? budget : _selectedBudget;
        });
      },
      backgroundColor: Colors.grey[100],
      selectedColor: Color(AppConstants.primaryColor),
      checkmarkColor: Colors.white,
      side: BorderSide(
        color: isSelected ? Color(AppConstants.primaryColor) : Colors.grey[300]!,
        width: 1,
      ),
    );
  }

  Widget _buildStartDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Start Date',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 16),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _startDate,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(Duration(days: 365)),
            );
            if (date != null) {
              setState(() {
                _startDate = date;
              });
            }
          },
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.grey[600]),
                SizedBox(width: 12),
                Text(
                  '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                Spacer(),
                Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Activities',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Select activities you\'d like to include',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: _availableActivities.length,
          itemBuilder: (context, index) {
            final activity = _availableActivities[index];
            final isSelected = _selectedActivities.contains(activity['id']);
            
            return InkWell(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedActivities.remove(activity['id']);
                  } else {
                    _selectedActivities.add(activity['id']);
                  }
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? Color(AppConstants.primaryColor) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? Color(AppConstants.primaryColor) : Colors.grey[300]!,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      activity['icon'] as IconData,
                      color: isSelected ? Colors.white : Colors.grey[600],
                      size: 32,
                    ),
                    SizedBox(height: 8),
                    Text(
                      activity['name']!,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4),
                    Text(
                      activity['duration']!,
                      style: TextStyle(
                        color: isSelected ? Colors.white70 : Colors.grey[600],
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
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

  Widget _buildActionButton() {
    return Container(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _selectedActivities.isEmpty ? null : _generateItinerary,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(AppConstants.primaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          'Generate Itinerary',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _generateItinerary() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Itinerary Generated!'),
        content: Text('Your personalized itinerary has been created successfully.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
} 