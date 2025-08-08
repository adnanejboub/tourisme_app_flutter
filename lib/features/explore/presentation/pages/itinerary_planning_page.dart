import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../core/constants/constants.dart';

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

  final List<Map<String, dynamic>> _availableActivities = [
    {
      'id': 'sightseeing',
      'name': 'activity_sightseeing',
      'icon': Icons.visibility,
      'duration': '2_4_hours',
    },
    {
      'id': 'food_tour',
      'name': 'activity_food_tour',
      'icon': Icons.restaurant,
      'duration': '3_4_hours',
    },
    {
      'id': 'shopping',
      'name': 'activity_shopping',
      'icon': Icons.shopping_bag,
      'duration': '2_3_hours',
    },
    {
      'id': 'cultural_visit',
      'name': 'activity_cultural_visit',
      'icon': Icons.museum,
      'duration': '1_2_hours',
    },
    {
      'id': 'adventure',
      'name': 'activity_adventure',
      'icon': Icons.directions_bike,
      'duration': '4_6_hours',
    },
    {
      'id': 'relaxation',
      'name': 'activity_relaxation',
      'icon': Icons.spa,
      'duration': '2_3_hours',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final localizationService = Provider.of<LocalizationService>(context);

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
          localizationService.translate('plan_your_itinerary'),
          style: TextStyle(
            color: colorScheme.onBackground,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDestinationInfo(colorScheme, localizationService),
            const SizedBox(height: 32),
            _buildTripDurationSection(colorScheme, localizationService),
            const SizedBox(height: 32),
            _buildBudgetSection(colorScheme, localizationService),
            const SizedBox(height: 32),
            _buildStartDateSection(colorScheme, localizationService),
            const SizedBox(height: 32),
            _buildActivitiesSection(colorScheme, localizationService),
            const SizedBox(height: 32),
            _buildActionButton(colorScheme, localizationService),
          ],
        ),
      ),
    );
  }

  Widget _buildDestinationInfo(ColorScheme colorScheme, LocalizationService localizationService) {
    final destination = widget.destination;
    if (destination == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              destination['image'] as String? ?? 'https://images.unsplash.com/photo-1517685352821-92cf88aee5a5',
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 60,
                  height: 60,
                  color: colorScheme.surfaceVariant,
                  child: Icon(
                    Icons.image,
                    color: colorScheme.onSurfaceVariant,
                  ),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: 60,
                  height: 60,
                  color: colorScheme.surfaceVariant,
                  child: const Center(child: CircularProgressIndicator()),
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  destination['name'] as String? ?? localizationService.translate('unknown_destination'),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  destination['arabicName'] as String? ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripDurationSection(ColorScheme colorScheme, LocalizationService localizationService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizationService.translate('trip_duration'),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildDurationOption(1, localizationService.translate('one_day'), colorScheme),
            _buildDurationOption(2, localizationService.translate('two_days'), colorScheme),
            _buildDurationOption(3, localizationService.translate('three_days'), colorScheme),
            _buildDurationOption(5, localizationService.translate('five_days'), colorScheme),
          ],
        ),
      ],
    );
  }

  Widget _buildDurationOption(int days, String label, ColorScheme colorScheme) {
    final isSelected = _selectedDays == days;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedDays = days;
            });
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? colorScheme.primary : colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? colorScheme.primary : colorScheme.outline,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetSection(ColorScheme colorScheme, LocalizationService localizationService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizationService.translate('budget_range'),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildBudgetOption('budget', localizationService.translate('budget'), colorScheme),
            _buildBudgetOption('mid_range', localizationService.translate('mid_range'), colorScheme),
            _buildBudgetOption('luxury', localizationService.translate('luxury'), colorScheme),
          ],
        ),
      ],
    );
  }

  Widget _buildBudgetOption(String budget, String label, ColorScheme colorScheme) {
    final isSelected = _selectedBudget == budget;
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedBudget = budget;
        });
      },
      backgroundColor: colorScheme.surface,
      selectedColor: colorScheme.primary,
      checkmarkColor: colorScheme.onPrimary,
      side: BorderSide(
        color: isSelected ? colorScheme.primary : colorScheme.outline,
        width: 1,
      ),
      elevation: isSelected ? 2 : 0,
      pressElevation: 4,
    );
  }

  Widget _buildStartDateSection(ColorScheme colorScheme, LocalizationService localizationService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizationService.translate('start_date'),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _startDate,
              firstDate: DateTime.now(),
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
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.outline),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: colorScheme.onSurface.withOpacity(0.7),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  DateFormat('dd/MM/yyyy').format(_startDate),
                  style: TextStyle(
                    fontSize: 16,
                    color: colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_drop_down,
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivitiesSection(ColorScheme colorScheme, LocalizationService localizationService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizationService.translate('activities_interests'),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          localizationService.translate('select_activities'),
          style: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
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
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? colorScheme.primary : colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? colorScheme.primary : colorScheme.outline,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withOpacity(0.1),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      activity['icon'] as IconData,
                      color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface.withOpacity(0.7),
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      localizationService.translate(activity['name'] as String),
                      style: TextStyle(
                        color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      localizationService.translate(activity['duration'] as String),
                      style: TextStyle(
                        color: isSelected ? colorScheme.onPrimary.withOpacity(0.8) : colorScheme.onSurface.withOpacity(0.7),
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

  Widget _buildActionButton(ColorScheme colorScheme, LocalizationService localizationService) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _selectedActivities.isEmpty ? null : () => _generateItinerary(localizationService),
        style: ElevatedButton.styleFrom(
          backgroundColor: _selectedActivities.isEmpty ? colorScheme.onSurface.withOpacity(0.4) : colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: _selectedActivities.isEmpty ? 0 : 2,
        ),
        child: Text(
          localizationService.translate('generate_itinerary'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _generateItinerary(LocalizationService localizationService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          localizationService.translate('itinerary_generated'),
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        content: Text(
          localizationService.translate('itinerary_success'),
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              localizationService.translate('ok'),
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}