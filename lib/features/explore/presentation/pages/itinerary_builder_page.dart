import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/constants.dart';
import '../../../saved/data/models/trip_model.dart';
import '../../../saved/data/services/trip_service.dart';
import '../../../saved/data/services/planning_database_service.dart';
import '../../../saved/data/models/planning_journalier_model.dart';
import '../../../saved/data/models/planning_activite_model.dart';
import '../../data/services/itinerary_database_service.dart';
import 'day_plan_detail_page.dart';

class ItineraryBuilderPage extends StatefulWidget {
  final Map<String, dynamic>? destination;
  final TripModel? existingTrip;

  const ItineraryBuilderPage({
    super.key, 
    this.destination,
    this.existingTrip,
  });

  @override
  State<ItineraryBuilderPage> createState() => _ItineraryBuilderPageState();
}

class _ItineraryBuilderPageState extends State<ItineraryBuilderPage> {
  int _selectedDay = 1;
  int _totalDays = 5;
  double _totalBudget = 750.0;
  double _spentAmount = 0.0;
  List<List<Map<String, dynamic>>> _dailyActivities = [];
  List<Map<String, dynamic>> _smartSuggestions = [];
  bool _isLoading = true;

  final PlanningDatabaseService _planningDbService = PlanningDatabaseService();
  final TripService _tripService = TripService();
  final ItineraryDatabaseService _itineraryDbService = ItineraryDatabaseService();

  @override
  void initState() {
    super.initState();
    // Initialiser _dailyActivities avec des listes vides
    _dailyActivities = List.generate(_totalDays, (index) => <Map<String, dynamic>>[]);
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() => _isLoading = true);
    
    // Charger les données existantes ou créer de nouvelles
    if (widget.existingTrip != null) {
      await _loadExistingTrip();
    } else {
      await _createNewItinerary();
    }
    
    _generateSmartSuggestions();
    setState(() => _isLoading = false);
  }

  Future<void> _loadExistingTrip() async {
    // Charger les activités existantes depuis la base de données
    try {
      final plannings = await _planningDbService.getPlanningJournalierByTrip(
        int.parse(widget.existingTrip!.id)
      );
      
      _dailyActivities = List.generate(_totalDays, (index) => <Map<String, dynamic>>[]);
      
      for (final planning in plannings) {
        final dayIndex = planning.datePlanning.difference(widget.existingTrip!.startDate).inDays;
        if (dayIndex >= 0 && dayIndex < _totalDays) {
          final activities = await _planningDbService.getPlanningActivitesByPlanning(
            planning.idPlanning ?? 0
          );
          
          _dailyActivities[dayIndex] = activities.map((activity) => {
            'id': activity.idActivite,
            'name': activity.nomActivite,
            'description': activity.description,
            'time': '09:00 AM', // À calculer selon l'heure prévue
            'duration': activity.dureeMinimun,
            'price': activity.prix,
            'category': activity.categorie,
            'image': activity.imageUrl,
            'location': activity.ville,
          }).toList();
        }
      }
      
      _calculateSpentAmount();
    } catch (e) {
      print('Erreur lors du chargement du voyage: $e');
    }
  }

  Future<void> _createNewItinerary() async {
    // Créer un nouvel itinéraire basé sur la destination
    _dailyActivities = List.generate(_totalDays, (index) => <Map<String, dynamic>>[]);
    
    // Ajouter quelques activités par défaut
    _addDefaultActivities();
    _calculateSpentAmount();
  }

  void _addDefaultActivities() {
    final destinationName = widget.destination?['name'] ?? 'Morocco';
    
    // Jour 1 - Activités par défaut
    _dailyActivities[0] = [
      {
        'id': '1',
        'name': '${destinationName} City Tour',
        'description': 'Explore the main attractions',
        'time': '09:00 AM',
        'duration': 180,
        'price': 50.0,
        'category': 'Sightseeing',
        'image': widget.destination?['image'] ?? '',
        'location': destinationName,
      },
      {
        'id': '2',
        'name': 'Local Restaurant',
        'description': 'Taste authentic local cuisine',
        'time': '12:30 PM',
        'duration': 90,
        'price': 25.0,
        'category': 'Food',
        'image': '',
        'location': destinationName,
      },
    ];
  }

  Future<void> _generateSmartSuggestions() async {
    try {
      final remainingBudget = _totalBudget - _spentAmount;
      final selectedCategories = _dailyActivities
          .expand((day) => day)
          .map((activity) => activity['category'] as String)
          .toSet()
          .toList();

      _smartSuggestions = await _itineraryDbService.getSmartSuggestions(
        destination: widget.destination?['name'] ?? 'Morocco',
        remainingBudget: remainingBudget,
        selectedCategories: selectedCategories,
      );
    } catch (e) {
      print('Erreur lors du chargement des suggestions: $e');
      // Utiliser des suggestions par défaut en cas d'erreur
      _smartSuggestions = [
        {
          'id': 'suggestion_1',
          'name': 'Add Dinner at Local Bistro',
      'category': 'Food & Drink',
      'icon': Icons.restaurant,
          'price': 35.0,
          'duration': 120,
          'description': 'Experience local dining culture',
    },
    {
          'id': 'suggestion_2',
          'name': 'Shopping at Local Market',
      'category': 'Shopping',
      'icon': Icons.shopping_bag,
          'price': 40.0,
          'duration': 150,
          'description': 'Find unique souvenirs and crafts',
    },
    {
          'id': 'suggestion_3',
          'name': 'Evening Cultural Show',
      'category': 'Entertainment',
          'icon': Icons.theater_comedy,
          'price': 30.0,
          'duration': 90,
          'description': 'Enjoy traditional performances',
        },
      ];
    }
  }

  void _calculateSpentAmount() {
    _spentAmount = 0.0;
    for (final dayActivities in _dailyActivities) {
      for (final activity in dayActivities) {
        _spentAmount += (activity['price'] as num).toDouble();
      }
    }
  }

  void _addActivityToDay(int dayIndex, Map<String, dynamic> activity) {
    setState(() {
      // Vérifier que l'index est valide
      if (dayIndex >= 0 && dayIndex < _dailyActivities.length) {
        _dailyActivities[dayIndex].add(activity);
        _calculateSpentAmount();
      }
    });
    _saveToDatabase();
  }

  void _removeActivityFromDay(int dayIndex, String activityId) {
    setState(() {
      // Vérifier que l'index est valide
      if (dayIndex >= 0 && dayIndex < _dailyActivities.length) {
        _dailyActivities[dayIndex].removeWhere((activity) => activity['id'] == activityId);
        _calculateSpentAmount();
      }
    });
    _saveToDatabase();
  }

  Future<void> _saveToDatabase() async {
    // Sauvegarder les modifications dans la base de données
    try {
      if (widget.existingTrip != null) {
        // Mettre à jour le voyage existant
        await _updateExistingTrip();
      } else {
        // Créer un nouveau voyage
        await _createNewTrip();
      }
      
      // Sauvegarder l'itinéraire complet
      await _itineraryDbService.saveCompleteItinerary(
        trip: widget.existingTrip ?? _createTripModel(),
        dailyActivities: _dailyActivities,
        totalBudget: _totalBudget,
        spentAmount: _spentAmount,
      );
    } catch (e) {
      print('Erreur lors de la sauvegarde: $e');
    }
  }

  Future<void> _createNewTrip() async {
    final trip = _createTripModel();
    await _tripService.saveTrip(trip);
  }

  TripModel _createTripModel() {
    return TripModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: '${widget.destination?['name'] ?? 'Morocco'} Adventure',
      destination: widget.destination?['name'] ?? 'Morocco',
      startDate: DateTime.now().add(const Duration(days: 7)),
      endDate: DateTime.now().add(Duration(days: 7 + _totalDays - 1)),
      activities: [],
      notes: 'Budget: \$${_totalBudget.toStringAsFixed(0)} | Spent: \$${_spentAmount.toStringAsFixed(0)}',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Future<void> _updateExistingTrip() async {
    // Mettre à jour le voyage existant
    if (widget.existingTrip != null) {
      final updatedTrip = widget.existingTrip!.copyWith(
        notes: 'Budget: \$${_totalBudget.toStringAsFixed(0)} | Spent: \$${_spentAmount.toStringAsFixed(0)}',
        updatedAt: DateTime.now(),
      );
      await _tripService.saveTrip(updatedTrip);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
        title: const Text(
          'Itinerary Builder',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildDaySelector(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  _buildBudgetTracker(),
                  const SizedBox(height: 24),
                  _buildDayItinerary(),
                  const SizedBox(height: 24),
                  _buildSmartSuggestions(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySelector() {
    return Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: _selectedDay > 1 ? () => setState(() => _selectedDay--) : null,
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                    children: List.generate(_totalDays, (index) {
                    final dayNumber = index + 1;
                    final isSelected = dayNumber == _selectedDay;
                      
                    return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: GestureDetector(
                          onTap: () => setState(() => _selectedDay = dayNumber),
                        child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                              color: isSelected ? Colors.blue : Colors.grey[200],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Day $dayNumber',
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.grey[600],
                                fontWeight: FontWeight.w600,
                              ),
                          ),
                        ),
                      ),
                    );
                  }),
                  ),
                ),
              ),
              IconButton(
                onPressed: _selectedDay < _totalDays ? () => setState(() => _selectedDay++) : null,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            height: 2,
            child: LinearProgressIndicator(
              value: _selectedDay / _totalDays,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetTracker() {
    final remaining = _totalBudget - _spentAmount;
    final progress = _spentAmount / _totalBudget;
    
    return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Budget Tracker',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
              color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
                  backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              progress > 0.8 ? Colors.red : Colors.green,
            ),
                  minHeight: 8,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                '\$${_spentAmount.toStringAsFixed(0)} / \$${_totalBudget.toStringAsFixed(0)} spent',
                      style: const TextStyle(
                        fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                      ),
                    ),
                    Text(
                'Remaining: \$${remaining.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: remaining < 0 ? Colors.red : Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildDayItinerary() {
    // Vérifier que la liste n'est pas vide et que l'index est valide
    if (_dailyActivities.isEmpty || _selectedDay - 1 >= _dailyActivities.length) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          children: [
            Icon(
              Icons.add_circle_outline,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Chargement des activités...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }
    
    final dayActivities = _dailyActivities[_selectedDay - 1];
    final totalDuration = dayActivities.fold<int>(
      0, 
      (sum, activity) => sum + (activity['duration'] as int),
    );
    final hours = totalDuration ~/ 60;
    final minutes = totalDuration % 60;

    return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Day $_selectedDay',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                color: Colors.black87,
                        ),
                      ),
                      Text(
              '${hours}h ${minutes}m',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
        if (dayActivities.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.add_circle_outline,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No activities planned for Day $_selectedDay',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add activities from suggestions below',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          )
        else
          ...dayActivities.map((activity) => _buildActivityCard(activity)),
      ],
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                activity['time'],
                      style: const TextStyle(
                  fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        activity['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _editActivity(activity);
                  } else if (value == 'delete') {
                          _removeActivityFromDay(_selectedDay - 1, activity['id']);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 20),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 20, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete', style: TextStyle(color: Colors.red)),
                            ],
                ),
              ),
            ],
                      child: const Icon(Icons.more_vert, color: Colors.grey),
                    ),
                  ],
          ),
          const SizedBox(height: 4),
          Text(
            activity['description'],
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${activity['duration']} min',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.attach_money,
                  size: 16,
                  color: Colors.grey[500],
                ),
                const SizedBox(width: 4),
                Text(
                      '\$${activity['price'].toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
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

  Widget _buildSmartSuggestions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Smart Suggestions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        ..._smartSuggestions.map((suggestion) => _buildSuggestionCard(suggestion)),
      ],
    );
  }

  Widget _buildSuggestionCard(Map<String, dynamic> suggestion) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => _addSuggestionToCurrentDay(suggestion),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
            children: [
              Container(
                  width: 48,
                  height: 48,
                decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  suggestion['icon'],
                    color: Colors.blue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
          Text(
            suggestion['name'],
            style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            suggestion['category'],
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        suggestion['description'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${suggestion['price'].toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    Text(
                      '${suggestion['duration']} min',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _addSuggestionToCurrentDay(Map<String, dynamic> suggestion) {
    final activity = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': suggestion['name'],
      'description': suggestion['description'],
      'time': _getNextAvailableTime(),
      'duration': suggestion['duration'],
      'price': suggestion['price'],
      'category': suggestion['category'],
      'image': '',
      'location': widget.destination?['name'] ?? 'Morocco',
    };

    _addActivityToDay(_selectedDay - 1, activity);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${suggestion['name']} added to Day $_selectedDay'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _getNextAvailableTime() {
    // Vérifier que la liste n'est pas vide et que l'index est valide
    if (_dailyActivities.isEmpty || _selectedDay - 1 >= _dailyActivities.length) {
      return '09:00 AM';
    }
    
    final dayActivities = _dailyActivities[_selectedDay - 1];
    if (dayActivities.isEmpty) return '09:00 AM';
    
    // Calculer la prochaine heure disponible
    final lastActivity = dayActivities.last;
    final lastTime = lastActivity['time'];
    final lastDuration = lastActivity['duration'] as int;
    
    // Convertir en minutes depuis minuit
    final timeParts = lastTime.split(' ');
    final time = timeParts[0];
    final period = timeParts[1];
    final hourMinute = time.split(':');
    var hour = int.parse(hourMinute[0]);
    final minute = int.parse(hourMinute[1]);
    
    if (period == 'PM' && hour != 12) hour += 12;
    if (period == 'AM' && hour == 12) hour = 0;
    
    var totalMinutes = hour * 60 + minute + lastDuration + 30; // 30 min de pause
    
    var newHour = (totalMinutes ~/ 60) % 24;
    final newMinute = totalMinutes % 60;
    
    final periodStr = newHour >= 12 ? 'PM' : 'AM';
    if (newHour > 12) newHour -= 12;
    if (newHour == 0) newHour = 12;
    
    return '${newHour.toString().padLeft(2, '0')}:${newMinute.toString().padLeft(2, '0')} $periodStr';
  }

  void _editActivity(Map<String, dynamic> activity) {
    // Naviguer vers la page de modification d'activité
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DayPlanDetailPage(
          activity: activity,
          onSave: (updatedActivity) {
            setState(() {
              final dayIndex = _selectedDay - 1;
              // Vérifier que l'index est valide
              if (dayIndex >= 0 && dayIndex < _dailyActivities.length) {
                final activityIndex = _dailyActivities[dayIndex].indexWhere(
                  (a) => a['id'] == activity['id']
                );
                if (activityIndex != -1) {
                  _dailyActivities[dayIndex][activityIndex] = updatedActivity;
                  _calculateSpentAmount();
                }
              }
            });
            _saveToDatabase();
          },
        ),
      ),
    );
  }
}