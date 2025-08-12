import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/localization_service.dart';
import '../../data/models/trip_model.dart';
import '../../data/services/trip_service.dart';
import '../../../../core/constants/constants.dart';

class CreateEditTripPage extends StatefulWidget {
  final TripModel? trip; // null pour créer, non-null pour éditer

  const CreateEditTripPage({super.key, this.trip});

  @override
  State<CreateEditTripPage> createState() => _CreateEditTripPageState();
}

class _CreateEditTripPageState extends State<CreateEditTripPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  final _tripService = TripService();

  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedDestination = '';
  List<TripActivity> _activities = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.trip != null) {
      // Mode édition
      _nameController.text = widget.trip!.name;
      _notesController.text = widget.trip!.notes ?? '';
      _startDate = widget.trip!.startDate;
      _endDate = widget.trip!.endDate;
      _selectedDestination = widget.trip!.destination;
      _activities = List.from(widget.trip!.activities);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
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
              widget.trip == null
                  ? localizationService.translate('create_trip') ?? 'Create Trip'
                  : localizationService.translate('edit_trip') ?? 'Edit Trip',
              style: TextStyle(
                color: colorScheme.onBackground,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            actions: [
              if (widget.trip != null)
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteTrip(localizationService),
                ),
            ],
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildBasicInfoSection(colorScheme, localizationService),
                const SizedBox(height: 24),
                _buildActivitiesSection(colorScheme, localizationService),
                const SizedBox(height: 24),
                _buildSaveButton(colorScheme, localizationService),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBasicInfoSection(ColorScheme colorScheme, LocalizationService localizationService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizationService.translate('trip_details') ?? 'Trip Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colorScheme.onBackground,
          ),
        ),
        const SizedBox(height: 16),

        // Nom du trip
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: localizationService.translate('trip_name') ?? 'Trip Name',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: Icon(Icons.edit, color: colorScheme.primary),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return localizationService.translate('trip_name_required') ?? 'Trip name is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Destination
        DropdownButtonFormField<String>(
          value: _getValidDropdownValue(_selectedDestination),
          decoration: InputDecoration(
            labelText: localizationService.translate('destination') ?? 'Destination',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: Icon(Icons.location_on, color: colorScheme.primary),
          ),
          items: AppConstants.moroccoCities.map<DropdownMenuItem<String>>((city) {
            return DropdownMenuItem<String>(
              value: city['name'],
              child: Text(city['name']),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedDestination = value ?? '';
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return localizationService.translate('destination_required') ?? 'Destination is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Dates
        Row(
          children: [
            Expanded(
              child: _buildDateField(
                label: localizationService.translate('start_date') ?? 'Start Date',
                date: _startDate,
                onDateSelected: (date) => setState(() => _startDate = date),
                colorScheme: colorScheme,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDateField(
                label: localizationService.translate('end_date') ?? 'End Date',
                date: _endDate,
                onDateSelected: (date) => setState(() => _endDate = date),
                colorScheme: colorScheme,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Notes
        TextFormField(
          controller: _notesController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: localizationService.translate('notes') ?? 'Notes (Optional)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: Icon(Icons.note, color: colorScheme.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required Function(DateTime) onDateSelected,
    required ColorScheme colorScheme,
  }) {
    return InkWell(
      onTap: () async {
        final selectedDate = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (selectedDate != null) {
          onDateSelected(selectedDate);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outline),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                date != null
                    ? '${date.day}/${date.month}/${date.year}'
                    : label,
                style: TextStyle(
                  color: date != null ? colorScheme.onSurface : colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitiesSection(ColorScheme colorScheme, LocalizationService localizationService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              localizationService.translate('activities') ?? 'Activities',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onBackground,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _addActivity(localizationService),
              icon: const Icon(Icons.add),
              label: Text(localizationService.translate('add_activity') ?? 'Add'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (_activities.isEmpty)
          _buildEmptyActivitiesState(colorScheme, localizationService)
        else
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _activities.length,
            itemBuilder: (context, index) {
              final activity = _activities[index];
              return _buildActivityCard(activity, index, colorScheme, localizationService);
            },
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) {
                  newIndex -= 1;
                }
                final item = _activities.removeAt(oldIndex);
                _activities.insert(newIndex, item);
              });
            },
          ),
      ],
    );
  }

  Widget _buildEmptyActivitiesState(ColorScheme colorScheme, LocalizationService localizationService) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.add_location_alt,
            size: 48,
            color: colorScheme.onSurface.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            localizationService.translate('no_activities_added') ?? 'No activities added yet',
            style: TextStyle(
              fontSize: 16,
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            localizationService.translate('add_activities_description') ?? 'Tap the button above to add activities to your trip',
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(TripActivity activity, int index, ColorScheme colorScheme, LocalizationService localizationService) {
    return Container(
      key: ValueKey(activity.id),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getActivityColor(activity.type),
          child: Icon(_getActivityIcon(activity.type), color: Colors.white),
        ),
        title: Text(
          activity.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (activity.location != null)
              Text(activity.location!),
            if (activity.duration != null)
              Text('${activity.duration} min'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: colorScheme.primary),
              onPressed: () => _editActivity(index, localizationService),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _removeActivity(index),
            ),
          ],
        ),
      ),
    );
  }

  Color _getActivityColor(String type) {
    switch (type) {
      case 'attraction':
        return Colors.blue;
      case 'restaurant':
        return Colors.orange;
      case 'hotel':
        return Colors.green;
      case 'transport':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'attraction':
        return Icons.attractions;
      case 'restaurant':
        return Icons.restaurant;
      case 'hotel':
        return Icons.hotel;
      case 'transport':
        return Icons.directions_car;
      default:
        return Icons.star;
    }
  }

  Widget _buildSaveButton(ColorScheme colorScheme, LocalizationService localizationService) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : () => _saveTrip(localizationService),
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: _isLoading
            ? CircularProgressIndicator(color: colorScheme.onPrimary)
            : Text(
          widget.trip == null
              ? localizationService.translate('create_trip') ?? 'Create Trip'
              : localizationService.translate('save_changes') ?? 'Save Changes',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _addActivity(LocalizationService localizationService) {
    _showActivityDialog(localizationService);
  }

  void _editActivity(int index, LocalizationService localizationService) {
    _showActivityDialog(localizationService, activity: _activities[index], index: index);
  }

  void _removeActivity(int index) {
    setState(() {
      _activities.removeAt(index);
    });
  }

  void _showActivityDialog(LocalizationService localizationService, {TripActivity? activity, int? index}) {
    final nameController = TextEditingController(text: activity?.name ?? '');
    final descriptionController = TextEditingController(text: activity?.description ?? '');
    final locationController = TextEditingController(text: activity?.location ?? '');
    final durationController = TextEditingController(text: activity?.duration?.toString() ?? '');
    String selectedType = activity?.type ?? 'custom';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(activity == null ?
        localizationService.translate('add_activity') ?? 'Add Activity' :
        localizationService.translate('edit_activity') ?? 'Edit Activity'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: localizationService.translate('activity_name') ?? 'Activity Name',
                ),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: localizationService.translate('description_optional') ?? 'Description (Optional)',
                ),
                maxLines: 2,
              ),
              TextField(
                controller: locationController,
                decoration: InputDecoration(
                  labelText: localizationService.translate('location_optional') ?? 'Location (Optional)',
                ),
              ),
              TextField(
                controller: durationController,
                decoration: InputDecoration(
                  labelText: localizationService.translate('duration_minutes') ?? 'Duration in minutes (Optional)',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: InputDecoration(
                  labelText: localizationService.translate('type') ?? 'Type',
                ),
                items: [
                  DropdownMenuItem<String>(
                    value: 'custom',
                    child: Text(localizationService.translate('custom') ?? 'Custom'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'attraction',
                    child: Text(localizationService.translate('attraction') ?? 'Attraction'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'restaurant',
                    child: Text(localizationService.translate('restaurant') ?? 'Restaurant'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'hotel',
                    child: Text(localizationService.translate('hotel') ?? 'Hotel'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'transport',
                    child: Text(localizationService.translate('transport') ?? 'Transport'),
                  ),
                ],
                onChanged: (value) => selectedType = value ?? 'custom',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizationService.translate('cancel') ?? 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newActivity = TripActivity(
                id: activity?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                name: nameController.text.trim(),
                type: selectedType,
                description: descriptionController.text.trim().isEmpty ? null : descriptionController.text.trim(),
                location: locationController.text.trim().isEmpty ? null : locationController.text.trim(),
                duration: int.tryParse(durationController.text),
              );

              setState(() {
                if (index != null) {
                  _activities[index] = newActivity;
                } else {
                  _activities.add(newActivity);
                }
              });

              Navigator.pop(context);
            },
            child: Text(activity == null ?
            localizationService.translate('add') ?? 'Add' :
            localizationService.translate('save') ?? 'Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveTrip(LocalizationService localizationService) async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizationService.translate('select_dates_error') ?? 'Please select start and end dates'),
        ),
      );
      return;
    }
    if (_startDate!.isAfter(_endDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizationService.translate('date_order_error') ?? 'Start date must be before end date'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      TripModel trip;
      if (widget.trip == null) {
        // Créer un nouveau trip
        trip = await _tripService.createTrip(
          name: _nameController.text.trim(),
          destination: _selectedDestination,
          startDate: _startDate!,
          endDate: _endDate!,
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        );
      } else {
        // Mettre à jour le trip existant
        trip = widget.trip!.copyWith(
          name: _nameController.text.trim(),
          destination: _selectedDestination,
          startDate: _startDate!,
          endDate: _endDate!,
          activities: _activities,
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
          updatedAt: DateTime.now(),
        );
        await _tripService.saveTrip(trip);
      }

      // Ajouter les activités
      for (final activity in _activities) {
        await _tripService.addActivityToTrip(trip.id, activity);
      }

      if (mounted) {
        Navigator.pop(context, trip);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${localizationService.translate('save_error') ?? 'Error saving trip'}: $e'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteTrip(LocalizationService localizationService) async {
    if (widget.trip == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizationService.translate('delete_trip') ?? 'Delete Trip'),
        content: Text(localizationService.translate('delete_trip_confirmation') ??
            'Are you sure you want to delete this trip? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(localizationService.translate('cancel') ?? 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(localizationService.translate('delete') ?? 'Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _tripService.deleteTrip(widget.trip!.id);
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${localizationService.translate('delete_error') ?? 'Error deleting trip'}: $e'),
            ),
          );
        }
      }
    }
  }

  /// Retourne une valeur valide pour le dropdown ou null si la valeur actuelle n'est pas valide
  String? _getValidDropdownValue(String currentValue) {
    if (currentValue.isEmpty) return null;
    
    // Vérifier si la valeur actuelle existe dans la liste des villes
    final validCities = AppConstants.moroccoCities.map((city) => city['name'] as String).toList();
    
    // Essayer de trouver une correspondance exacte
    if (validCities.contains(currentValue)) {
      return currentValue;
    }
    
    // Essayer de trouver une correspondance partielle (pour gérer les accents, etc.)
    for (final cityName in validCities) {
      if (cityName.toLowerCase() == currentValue.toLowerCase() ||
          _normalizeString(cityName) == _normalizeString(currentValue)) {
        return cityName; // Retourner la valeur normalisée du dropdown
      }
    }
    
    // Si aucune correspondance n'est trouvée, retourner null
    return null;
  }

  /// Normalise une chaîne pour la comparaison (supprime les accents, met en minuscules)
  String _normalizeString(String input) {
    return input
        .toLowerCase()
        .replaceAll('é', 'e')
        .replaceAll('è', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('ë', 'e')
        .replaceAll('à', 'a')
        .replaceAll('â', 'a')
        .replaceAll('ä', 'a')
        .replaceAll('î', 'i')
        .replaceAll('ï', 'i')
        .replaceAll('ô', 'o')
        .replaceAll('ö', 'o')
        .replaceAll('ù', 'u')
        .replaceAll('û', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ç', 'c');
  }
}