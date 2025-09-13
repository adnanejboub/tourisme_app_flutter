import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../core/services/image_service.dart';
import '../../data/models/trip_model.dart';
import '../../data/services/trip_service.dart';
import '../../data/services/wishlist_service.dart';
import '../../../../core/constants/constants.dart';

class TripFormPage extends StatefulWidget {
  final TripModel? trip;
  final List<Map<String, dynamic>>? cityActivities;

  const TripFormPage({super.key, this.trip, this.cityActivities});

  @override
  State<TripFormPage> createState() => _TripFormPageState();
}

class _TripFormPageState extends State<TripFormPage> {
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
      _nameController.text = widget.trip!.name;
      _notesController.text = widget.trip!.notes ?? '';
      _startDate = widget.trip!.startDate;
      _endDate = widget.trip!.endDate;
      _selectedDestination = widget.trip!.destination;
      _activities = List.from(widget.trip!.activities);
    } else {
      // Valeurs par défaut comme dans l'image
      _nameController.text = 'Marrakech Adventure';
      _selectedDestination = 'Marrakech';
      _startDate = DateTime(2025, 9, 19);
      _endDate = DateTime(2025, 9, 21);
      _notesController.text = 'Budget: Mid-Range (800-1500 MAD/day)';
      
      // Utiliser les vraies activités de la ville si disponibles
      if (widget.cityActivities != null && widget.cityActivities!.isNotEmpty) {
        _activities = widget.cityActivities!.take(3).map((activity) {
          return TripActivity(
            id: activity['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
            name: activity['nom'] ?? activity['nomActivite'] ?? activity['name'] ?? 'Activity',
            type: activity['categorie'] ?? activity['typeActivite'] ?? activity['type'] ?? 'General',
            duration: activity['dureeMinimun'] ?? 120,
            description: activity['description'] ?? 'Explore this activity',
          );
        }).toList();
      } else {
        _activities = [
          TripActivity(
            id: '1',
            name: 'Adventure',
            type: 'attraction',
            duration: 300,
          ),
          TripActivity(
            id: '2',
            name: 'Relaxation',
            type: 'custom',
            duration: 150,
          ),
        ];
      }
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
          'Edit Trip',
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
              onPressed: () => _deleteTrip(),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildTripDetailsSection(colorScheme),
            const SizedBox(height: 24),
            _buildActivitiesSection(colorScheme),
            const SizedBox(height: 24),
            _buildSaveButton(colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildTripDetailsSection(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trip Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colorScheme.onBackground,
          ),
        ),
        const SizedBox(height: 16),
        
        // Trip Name
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Trip Name',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: Icon(Icons.edit, color: colorScheme.primary),
          ),
        ),
        const SizedBox(height: 16),
        
        // Destination
        DropdownButtonFormField<String>(
          value: _selectedDestination.isNotEmpty ? _selectedDestination : null,
          decoration: InputDecoration(
            labelText: 'Destination',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: Icon(Icons.location_on, color: colorScheme.primary),
            suffixIcon: Icon(Icons.keyboard_arrow_down, color: colorScheme.primary),
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
        ),
        const SizedBox(height: 16),
        
        // Dates
        Row(
          children: [
            Expanded(
              child: _buildDateField(
                label: 'Start Date',
                date: _startDate,
                onDateSelected: (date) => setState(() => _startDate = date),
                colorScheme: colorScheme,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDateField(
                label: 'End Date',
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
            labelText: 'Notes',
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

  Widget _buildActivitiesSection(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Activities',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onBackground,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _showCityActivitiesDialog(colorScheme),
              icon: const Icon(Icons.add, size: 16),
              label: Text('+ Add Activity'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        if (_activities.isEmpty)
          _buildEmptyActivitiesState(colorScheme)
        else
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _activities.length,
            itemBuilder: (context, index) {
              final activity = _activities[index];
              return _buildActivityCard(activity, index, colorScheme);
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

  Widget _buildEmptyActivitiesState(ColorScheme colorScheme) {
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
            'No activities added yet',
            style: TextStyle(
              fontSize: 16,
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(TripActivity activity, int index, ColorScheme colorScheme) {
    return Container(
      key: ValueKey(activity.id),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: colorScheme.primary,
          child: const Icon(Icons.settings, color: Colors.white, size: 20),
        ),
        title: Text(
          activity.name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: activity.duration != null
            ? Text(
                '${activity.duration} min',
                style: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 14,
                ),
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: colorScheme.primary, size: 20),
              onPressed: () => _editActivity(index),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red, size: 20),
              onPressed: () => _removeActivity(index),
            ),
            IconButton(
              icon: Icon(Icons.reorder, color: colorScheme.onSurface.withOpacity(0.6), size: 20),
              onPressed: null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(ColorScheme colorScheme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : () => _saveTrip(),
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: _isLoading
            ? CircularProgressIndicator(color: colorScheme.onPrimary)
            : Text(
                'Save Changes',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  void _showCityActivitiesDialog(ColorScheme colorScheme) {
    if (widget.cityActivities == null || widget.cityActivities!.isEmpty) {
      // Fallback vers le dialog d'ajout d'activité manuel
      _showActivityDialog();
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    'Select Activity',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: colorScheme.onSurface),
                  ),
                ],
              ),
            ),
            // Activities list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: widget.cityActivities!.length,
                itemBuilder: (context, index) {
                  final activity = widget.cityActivities![index];
                  return _buildCityActivityCard(activity, colorScheme);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCityActivityCard(Map<String, dynamic> activity, ColorScheme colorScheme) {
    final imageUrl = activity['image'] ?? activity['imageUrl'] ?? '';
    final activityName = activity['nom'] ?? activity['nomActivite'] ?? activity['name'] ?? 'Activity';
    final duration = activity['dureeMinimun'] ?? 120;
    final description = activity['description'] ?? '';
    final category = activity['categorie'] ?? activity['typeActivite'] ?? activity['type'] ?? 'General';
    final price = activity['prix'];
    
    // Utiliser ImageService pour obtenir l'image appropriée
    final String finalImageUrl = imageUrl.isNotEmpty 
        ? imageUrl 
        : ImageService.getActivityImage(category, activityName);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _addCityActivity(activity),
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            // Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                color: colorScheme.surfaceVariant.withOpacity(0.3),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                child: _buildActivityImage(finalImageUrl, colorScheme),
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activityName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            category,
                            style: TextStyle(
                              fontSize: 10,
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${duration} min',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        if (price != null) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.attach_money,
                            size: 12,
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${price} MAD',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Add button
            Padding(
              padding: const EdgeInsets.all(12),
              child: Icon(
                Icons.add_circle_outline,
                color: colorScheme.primary,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addCityActivity(Map<String, dynamic> activity) {
    final tripActivity = TripActivity(
      id: activity['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: activity['nom'] ?? activity['nomActivite'] ?? activity['name'] ?? 'Activity',
      type: activity['categorie'] ?? activity['typeActivite'] ?? activity['type'] ?? 'General',
      duration: activity['dureeMinimun'] ?? 120,
      description: activity['description'] ?? '',
    );

    setState(() {
      _activities.add(tripActivity);
    });

    Navigator.pop(context); // Fermer le modal
  }

  Widget _buildActivityImage(String imageUrl, ColorScheme colorScheme) {
    if (imageUrl.isEmpty) {
      return Icon(
        Icons.local_activity,
        color: colorScheme.primary,
        size: 32,
      );
    }

    if (ImageService.isLocalAsset(imageUrl)) {
      // Convert relative path to full asset path
      final String assetPath = imageUrl.startsWith('images/')
          ? 'assets/$imageUrl'
          : imageUrl;
      
      return Image.asset(
        assetPath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Icon(
          Icons.local_activity,
          color: colorScheme.primary,
          size: 32,
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        child: Icon(
          Icons.local_activity,
          color: colorScheme.primary,
          size: 32,
        ),
      ),
      errorWidget: (context, url, error) => Icon(
        Icons.local_activity,
        color: colorScheme.primary,
        size: 32,
      ),
    );
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
                decoration: const InputDecoration(
                  labelText: 'Activity Name',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: durationController,
                decoration: const InputDecoration(
                  labelText: 'Duration (minutes)',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newActivity = TripActivity(
                id: activity?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                name: nameController.text.trim(),
                type: selectedType,
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
    setState(() => _isLoading = true);

    try {
      TripModel trip;
      if (widget.trip == null) {
        trip = await _tripService.createTrip(
          name: _nameController.text.trim(),
          destination: _selectedDestination,
          startDate: _startDate!,
          endDate: _endDate!,
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        );
      } else {
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

      for (final activity in _activities) {
        await _tripService.addActivityToTrip(trip.id, activity);
      }

      // Ajouter à la wishlist - Frontend et Backend
      try {
        await WishlistService.saveSnapshot(
          type: 'trip',
          itemId: int.tryParse(trip.id) ?? 0,
          data: {
            'id': trip.id,
            'name': trip.name,
            'destination': trip.destination,
            'startDate': trip.startDate.toIso8601String(),
            'endDate': trip.endDate.toIso8601String(),
            'activities': trip.activities.map((a) => a.toJson()).toList(),
            'notes': trip.notes,
            'createdAt': trip.createdAt.toIso8601String(),
            'updatedAt': trip.updatedAt.toIso8601String(),
          },
        );
        
        // Notifier les changements dans la wishlist
        WishlistService.changes.value = WishlistService.changes.value + 1;
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Trip saved to wishlist successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        print('Error saving trip to wishlist: $e');
      }

      if (mounted) {
        Navigator.pop(context, trip);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving trip: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteTrip() async {
    if (widget.trip == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Trip'),
        content: const Text('Are you sure you want to delete this trip? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
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
            SnackBar(content: Text('Error deleting trip: $e')),
          );
        }
      }
    }
  }
}
