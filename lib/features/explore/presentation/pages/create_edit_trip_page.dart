import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../core/constants/constants.dart';
import '../../../saved/data/models/trip_model.dart';
import '../../../saved/data/services/trip_service.dart';
import '../../../saved/presentation/pages/add_existing_activities_page.dart';

class CreateEditTripPage extends StatefulWidget {
  final TripModel? trip; // null pour créer, non-null pour éditer

  const CreateEditTripPage({Key? key, this.trip}) : super(key: key);

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
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: _deleteTrip,
                ),
            ],
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.all(16),
              children: [
                _buildBasicInfoSection(colorScheme, localizationService),
                SizedBox(height: 24),
                _buildActivitiesSection(colorScheme, localizationService),
                SizedBox(height: 24),
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
        SizedBox(height: 16),
        
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
        SizedBox(height: 16),
        
        // Destination
        DropdownButtonFormField<String>(
          value: _selectedDestination.isNotEmpty ? _selectedDestination : null,
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
        SizedBox(height: 16),
        
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
            SizedBox(width: 16),
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
        SizedBox(height: 16),
        
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
          lastDate: DateTime.now().add(Duration(days: 365)),
        );
        if (selectedDate != null) {
          onDateSelected(selectedDate);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outline),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: colorScheme.primary),
            SizedBox(width: 12),
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
            Row(
              children: [
                if (_selectedDestination.isNotEmpty)
                  ElevatedButton.icon(
                    onPressed: _addExistingActivities,
                    icon: Icon(Icons.list, size: 16),
                    label: Text('Existing'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.secondary,
                      foregroundColor: colorScheme.onSecondary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _addActivity,
                  icon: Icon(Icons.add),
                  label: Text(localizationService.translate('add_activity') ?? 'Add'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 16),
        
        if (_activities.isEmpty)
          _buildEmptyActivitiesState(colorScheme, localizationService)
        else
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
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
      padding: EdgeInsets.all(32),
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
          SizedBox(height: 16),
          Text(
            localizationService.translate('no_activities_added') ?? 'No activities added yet',
            style: TextStyle(
              fontSize: 16,
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            localizationService.translate('add_activities_description') ?? 'Tap the buttons above to add activities to your trip',
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
      margin: EdgeInsets.only(bottom: 12),
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
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (activity.description != null)
              Text(activity.description!),
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
              onPressed: () => _editActivity(index),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
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
        onPressed: _isLoading ? null : _saveTrip,
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: EdgeInsets.symmetric(vertical: 16),
        ),
        child: _isLoading
            ? CircularProgressIndicator(color: colorScheme.onPrimary)
            : Text(
                widget.trip == null 
                    ? localizationService.translate('create_trip') ?? 'Create Trip'
                    : localizationService.translate('save_changes') ?? 'Save Changes',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  void _addActivity() {
    _showActivityDialog();
  }

  void _addExistingActivities() async {
    if (_selectedDestination.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a destination first')),
      );
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddExistingActivitiesPage(
          destination: _selectedDestination,
          existingActivities: _activities,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _activities = result as List<TripActivity>;
      });
    }
  }

  void _editActivity(int index) {
    _showActivityDialog(activity: _activities[index], index: index);
  }

  void _removeActivity(int index) {
    setState(() {
      _activities.removeAt(index);
    });
  }

  void _showActivityDialog({TripActivity? activity, int? index}) {
    final nameController = TextEditingController(text: activity?.name ?? '');
    final descriptionController = TextEditingController(text: activity?.description ?? '');
    final locationController = TextEditingController(text: activity?.location ?? '');
    final durationController = TextEditingController(text: activity?.duration?.toString() ?? '');
    String selectedType = activity?.type ?? 'custom';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(activity == null ? 'Add Activity' : 'Edit Activity'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Activity Name'),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description (Optional)'),
                maxLines: 2,
              ),
              TextField(
                controller: locationController,
                decoration: InputDecoration(labelText: 'Location (Optional)'),
              ),
              TextField(
                controller: durationController,
                decoration: InputDecoration(labelText: 'Duration in minutes (Optional)'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: InputDecoration(labelText: 'Type'),
                items: [
                  DropdownMenuItem(value: 'custom', child: Text('Custom')),
                  DropdownMenuItem(value: 'attraction', child: Text('Attraction')),
                  DropdownMenuItem(value: 'restaurant', child: Text('Restaurant')),
                  DropdownMenuItem(value: 'hotel', child: Text('Hotel')),
                  DropdownMenuItem(value: 'transport', child: Text('Transport')),
                ],
                onChanged: (value) => selectedType = value ?? 'custom',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
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
            child: Text(activity == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveTrip() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select start and end dates')),
      );
      return;
    }
    if (_startDate!.isAfter(_endDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Start date must be before end date')),
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

      Navigator.pop(context, trip);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving trip: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteTrip() async {
    if (widget.trip == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Trip'),
        content: Text('Are you sure you want to delete this trip? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _tripService.deleteTrip(widget.trip!.id);
      Navigator.pop(context);
    }
  }
}
