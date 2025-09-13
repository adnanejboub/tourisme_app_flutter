import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/localization_service.dart';
import '../../data/models/trip_model.dart';
import '../../data/services/trip_service.dart';
import 'trip_form_page.dart';

class TripDetailsPage extends StatefulWidget {
  final TripModel trip;

  const TripDetailsPage({super.key, required this.trip});

  @override
  State<TripDetailsPage> createState() => _TripDetailsPageState();
}

class _TripDetailsPageState extends State<TripDetailsPage> {
  final TripService _tripService = TripService();
  late TripModel _trip;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _trip = widget.trip;
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
              _trip.name,
              style: TextStyle(
                color: colorScheme.onBackground,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.edit, color: colorScheme.primary),
                onPressed: _editTrip,
              ),
              IconButton(
                icon: Icon(Icons.share, color: colorScheme.primary),
                onPressed: () => _shareTrip(localizationService),
              ),
            ],
          ),
          body: _isLoading
              ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
              : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTripHeader(colorScheme, localizationService),
                const SizedBox(height: 24),
                _buildTripInfo(colorScheme, localizationService),
                const SizedBox(height: 24),
                _buildActivitiesSection(colorScheme, localizationService),
                if (_trip.notes != null && _trip.notes!.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _buildNotesSection(colorScheme, localizationService),
                ],
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _addActivity(localizationService),
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            icon: const Icon(Icons.add),
            label: Text(localizationService.translate('add_activity') ?? 'Add Activity'),
          ),
        );
      },
    );
  }

  Widget _buildTripHeader(ColorScheme colorScheme, LocalizationService localizationService) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.flight_takeoff,
                size: 32,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _trip.name,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onBackground,
                      ),
                    ),
                    Text(
                      _trip.destination,
                      style: TextStyle(
                        fontSize: 16,
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoChip(
                  icon: Icons.calendar_today,
                  label: '${_trip.duration} ${localizationService.translate('days') ?? 'days'}',
                  colorScheme: colorScheme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoChip(
                  icon: Icons.local_activity,
                  label: '${_trip.activities.length} ${localizationService.translate('activities') ?? 'activities'}',
                  colorScheme: colorScheme,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required ColorScheme colorScheme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripInfo(ColorScheme colorScheme, LocalizationService localizationService) {
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
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              _buildInfoRow(
                icon: Icons.calendar_today,
                label: localizationService.translate('start_date') ?? 'Start Date',
                value: _formatDate(_trip.startDate),
                colorScheme: colorScheme,
              ),
              const Divider(height: 24),
              _buildInfoRow(
                icon: Icons.calendar_today,
                label: localizationService.translate('end_date') ?? 'End Date',
                value: _formatDate(_trip.endDate),
                colorScheme: colorScheme,
              ),
              const Divider(height: 24),
              _buildInfoRow(
                icon: Icons.location_on,
                label: localizationService.translate('destination') ?? 'Destination',
                value: _trip.destination,
                colorScheme: colorScheme,
              ),
              const Divider(height: 24),
              _buildInfoRow(
                icon: Icons.access_time,
                label: localizationService.translate('created') ?? 'Created',
                value: _formatDate(_trip.createdAt),
                colorScheme: colorScheme,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required ColorScheme colorScheme,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: colorScheme.primary),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
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
            Text(
              '${_trip.activities.length}',
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (_trip.activities.isEmpty)
          _buildEmptyActivitiesState(colorScheme, localizationService)
        else
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _trip.activities.length,
            itemBuilder: (context, index) {
              final activity = _trip.activities[index];
              return _buildActivityCard(activity, index, colorScheme, localizationService);
            },
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) {
                  newIndex -= 1;
                }
                final item = _trip.activities.removeAt(oldIndex);
                _trip.activities.insert(newIndex, item);
              });
              _saveTripOrder();
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
            localizationService.translate('add_activities_description') ?? 'Tap the button below to add activities to your trip',
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
            if (activity.description != null)
              Text(activity.description!),
            if (activity.location != null)
              Text(activity.location!),
            if (activity.duration != null)
              Text('${activity.duration} ${localizationService.translate('minutes') ?? 'min'}'),
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

  Widget _buildNotesSection(ColorScheme colorScheme, LocalizationService localizationService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizationService.translate('notes') ?? 'Notes',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colorScheme.onBackground,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
          ),
          child: Text(
            _trip.notes!,
            style: TextStyle(
              fontSize: 16,
              color: colorScheme.onSurface,
              height: 1.5,
            ),
          ),
        ),
      ],
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _editTrip() async {
    // Force update to TripEditorPage
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TripFormPage(trip: _trip),
      ),
    );

    if (result != null) {
      setState(() {
        _trip = result as TripModel;
      });
    }
  }

  void _shareTrip(LocalizationService localizationService) {
    // TODO: Implémenter le partage de trip
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(localizationService.translate('sharing_feature_coming_soon') ?? 'Sharing feature coming soon!'),
      ),
    );
  }

  void _addActivity(LocalizationService localizationService) {
    _showActivityDialog(localizationService);
  }

  void _editActivity(int index, LocalizationService localizationService) {
    _showActivityDialog(localizationService, activity: _trip.activities[index], index: index);
  }

  void _removeActivity(int index) {
    setState(() {
      _trip.activities.removeAt(index);
    });
    _saveTripOrder();
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
                  _trip.activities[index] = newActivity;
                } else {
                  _trip.activities.add(newActivity);
                }
              });

              _saveTripOrder();
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

  Future<void> _saveTripOrder() async {
    if (!mounted) return;

    setState(() => _isLoading = true);
    try {
      await _tripService.reorderActivities(_trip.id, _trip.activities);
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde de l\'ordre: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving changes: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}