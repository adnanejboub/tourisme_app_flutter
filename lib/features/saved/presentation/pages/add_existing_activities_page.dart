import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../core/constants/constants.dart';
import '../../data/models/trip_model.dart';

class AddExistingActivitiesPage extends StatefulWidget {
  final String destination;
  final List<TripActivity> existingActivities;

  const AddExistingActivitiesPage({
    Key? key,
    required this.destination,
    required this.existingActivities,
  }) : super(key: key);

  @override
  State<AddExistingActivitiesPage> createState() => _AddExistingActivitiesPageState();
}

class _AddExistingActivitiesPageState extends State<AddExistingActivitiesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Map<String, dynamic>> _availableAttractions = [];
  List<TripActivity> _selectedActivities = [];

  @override
  void initState() {
    super.initState();
    _loadAvailableAttractions();
    _selectedActivities = List.from(widget.existingActivities);
  }

  void _loadAvailableAttractions() {
    // Charger les attractions disponibles pour la destination
    final city = AppConstants.moroccoCities.firstWhere(
      (city) => city['name'] == widget.destination,
      orElse: () => <String, dynamic>{},
    );

    if (city.isNotEmpty && city['attractions'] != null) {
      _availableAttractions = (city['attractions'] as List<dynamic>).map((attraction) {
        return {
          'name': attraction,
          'type': 'attraction',
          'location': widget.destination,
          'description': 'Popular attraction in ${widget.destination}',
        };
      }).toList();
    }
  }

  List<Map<String, dynamic>> get _filteredAttractions {
    if (_searchQuery.isEmpty) return _availableAttractions;
    
    return _availableAttractions.where((attraction) {
      return attraction['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

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
              '${localizationService.translate('add_activities_from') ?? 'Add Activities from'} ${widget.destination}',
              style: TextStyle(
                color: colorScheme.onBackground,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            actions: [
              TextButton(
                onPressed: _saveSelectedActivities,
                child: Text(
                  '${localizationService.translate('save_selected') ?? 'Save'} (${_selectedActivities.length})',
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              _buildSearchBar(colorScheme, localizationService),
              Expanded(
                child: _filteredAttractions.isEmpty
                    ? _buildEmptyState(colorScheme, localizationService)
                    : ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: _filteredAttractions.length,
                        itemBuilder: (context, index) {
                          final attraction = _filteredAttractions[index];
                          final isSelected = _selectedActivities.any(
                            (activity) => activity.name == attraction['name'],
                          );
                          return _buildAttractionCard(
                            attraction,
                            isSelected,
                            colorScheme,
                            localizationService,
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(ColorScheme colorScheme, LocalizationService localizationService) {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.onSurface.withOpacity(0.1)),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: localizationService.translate('search_activities') ?? 'Search activities...',
          hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
          prefixIcon: Icon(Icons.search, color: colorScheme.onSurface.withOpacity(0.6)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        style: TextStyle(
          fontSize: 16,
          color: colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme, LocalizationService localizationService) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: colorScheme.onSurface.withOpacity(0.4),
            ),
            SizedBox(height: 24),
            Text(
              localizationService.translate('no_attractions_found') ?? 'No attractions found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onBackground,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Text(
              'Try adjusting your search or check if the destination has available attractions',
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttractionCard(
    Map<String, dynamic> attraction,
    bool isSelected,
    ColorScheme colorScheme,
    LocalizationService localizationService,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? colorScheme.primary : colorScheme.outline.withOpacity(0.3),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isSelected ? colorScheme.primary : colorScheme.primary.withOpacity(0.1),
          child: Icon(
            Icons.attractions,
            color: isSelected ? colorScheme.onPrimary : colorScheme.primary,
          ),
        ),
        title: Text(
          attraction['name'],
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (attraction['description'] != null)
              Text(
                attraction['description'],
                style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
              ),
            Text(
              attraction['location'],
              style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
            ),
          ],
        ),
        trailing: Checkbox(
          value: isSelected,
          onChanged: (value) {
            setState(() {
              if (value == true) {
                _addActivity(attraction);
              } else {
                _removeActivity(attraction['name']);
              }
            });
          },
          activeColor: colorScheme.primary,
        ),
        onTap: () {
          setState(() {
            if (isSelected) {
              _removeActivity(attraction['name']);
            } else {
              _addActivity(attraction);
            }
          });
        },
      ),
    );
  }

  void _addActivity(Map<String, dynamic> attraction) {
    final activity = TripActivity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: attraction['name'],
      type: attraction['type'] ?? 'attraction',
      description: attraction['description'],
      location: attraction['location'],
    );

    if (!_selectedActivities.any((activity) => activity.name == attraction['name'])) {
      setState(() {
        _selectedActivities.add(activity);
      });
    }
  }

  void _removeActivity(String attractionName) {
    setState(() {
      _selectedActivities.removeWhere((activity) => activity.name == attractionName);
    });
  }

  void _saveSelectedActivities() {
    Navigator.pop(context, _selectedActivities);
  }
}
