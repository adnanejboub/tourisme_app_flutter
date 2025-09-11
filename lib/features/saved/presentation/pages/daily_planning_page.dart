import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/services/localization_service.dart';
import '../../data/models/planning_journalier_model.dart';
import '../../data/models/planning_activite_model.dart';
import '../../data/services/planning_database_service.dart';

class DailyPlanningPage extends StatefulWidget {
  final int tripId;
  final String tripName;
  final DateTime startDate;
  final DateTime endDate;

  const DailyPlanningPage({
    Key? key,
    required this.tripId,
    required this.tripName,
    required this.startDate,
    required this.endDate,
  }) : super(key: key);

  @override
  State<DailyPlanningPage> createState() => _DailyPlanningPageState();
}

class _DailyPlanningPageState extends State<DailyPlanningPage> {
  final PlanningDatabaseService _planningService = PlanningDatabaseService();
  List<PlanningJournalierModel> _dailyPlannings = [];
  Map<int, List<PlanningActiviteModel>> _activitiesByDay = {};
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.startDate;
    _loadDailyPlannings();
  }

  Future<void> _loadDailyPlannings() async {
    setState(() => _isLoading = true);
    try {
      final plannings = await _planningService.getPlanningJournalierByTrip(widget.tripId);
      setState(() {
        _dailyPlannings = plannings;
        _isLoading = false;
      });
      
      // Charger les activités pour chaque jour
      for (final planning in plannings) {
        if (planning.idPlanning != null) {
          final activities = await _planningService.getPlanningActivitesByPlanning(planning.idPlanning!);
          setState(() {
            _activitiesByDay[planning.idPlanning!] = activities;
          });
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du chargement: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
            title: Text(
              'Planning Journalier - ${widget.tripName}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colorScheme.onBackground,
              ),
            ),
            backgroundColor: colorScheme.background,
            elevation: 0,
            actions: [
              IconButton(
                icon: Icon(Icons.add, color: colorScheme.primary),
                onPressed: () => _showAddPlanningDialog(),
              ),
            ],
          ),
          body: _isLoading
              ? Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    _buildDateSelector(colorScheme),
                    Expanded(
                      child: _buildDailyPlanningList(colorScheme),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildDateSelector(ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: _selectedDate.isAfter(widget.startDate) ? _previousDay : null,
            icon: Icon(Icons.chevron_left),
          ),
          Expanded(
            child: Text(
              DateFormat('EEEE, dd MMMM yyyy', 'fr').format(_selectedDate),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onBackground,
              ),
            ),
          ),
          IconButton(
            onPressed: _selectedDate.isBefore(widget.endDate) ? _nextDay : null,
            icon: Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyPlanningList(ColorScheme colorScheme) {
    final dayPlanning = _dailyPlannings.firstWhere(
      (p) => _isSameDay(p.datePlanning, _selectedDate),
      orElse: () => PlanningJournalierModel(
        datePlanning: _selectedDate,
        description: '',
        duree: 0,
        statut: 'planifie',
      ),
    );

    final dayActivities = _activitiesByDay[dayPlanning.idPlanning] ?? [];

    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildPlanningCard(dayPlanning, colorScheme),
        SizedBox(height: 16),
        Text(
          'Activités du jour',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colorScheme.onBackground,
          ),
        ),
        SizedBox(height: 8),
        if (dayActivities.isEmpty)
          _buildEmptyActivitiesCard(colorScheme)
        else
          ...dayActivities.map((activity) => _buildActivityCard(activity, colorScheme)),
      ],
    );
  }

  Widget _buildPlanningCard(PlanningJournalierModel planning, ColorScheme colorScheme) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Planning du jour',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onBackground,
                  ),
                ),
                _buildStatusChip(planning.statut, colorScheme),
              ],
            ),
            SizedBox(height: 8),
            if (planning.description.isNotEmpty) ...[
              Text(
                planning.description,
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onBackground.withOpacity(0.7),
                ),
              ),
              SizedBox(height: 8),
            ],
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: colorScheme.primary),
                SizedBox(width: 4),
                Text(
                  '${planning.duree} minutes',
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onBackground.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(PlanningActiviteModel activity, ColorScheme colorScheme) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colorScheme.primary.withOpacity(0.1),
          child: Icon(
            _getActivityIcon(activity.categorie),
            color: colorScheme.primary,
          ),
        ),
        title: Text(
          activity.nomActivite,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(activity.description),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: colorScheme.primary),
                SizedBox(width: 4),
                Text('${activity.dureeMinimun}-${activity.dureeMaximun} min'),
                SizedBox(width: 16),
                Icon(Icons.attach_money, size: 14, color: colorScheme.primary),
                SizedBox(width: 4),
                Text('${activity.prix.toStringAsFixed(0)} MAD'),
              ],
            ),
          ],
        ),
        trailing: _buildStatusChip(activity.statut, colorScheme),
        onTap: () => _showActivityDetails(activity),
      ),
    );
  }

  Widget _buildEmptyActivitiesCard(ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.event_available,
              size: 64,
              color: colorScheme.onBackground.withOpacity(0.3),
            ),
            SizedBox(height: 16),
            Text(
              'Aucune activité planifiée',
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onBackground.withOpacity(0.6),
              ),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _showAddActivityDialog(),
              child: Text('Ajouter une activité'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status, ColorScheme colorScheme) {
    Color statusColor;
    switch (status) {
      case 'planifie':
        statusColor = Colors.blue;
        break;
      case 'en_cours':
        statusColor = Colors.orange;
        break;
      case 'termine':
        statusColor = Colors.green;
        break;
      case 'annule':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Chip(
      label: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: statusColor,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  IconData _getActivityIcon(String category) {
    switch (category.toLowerCase()) {
      case 'tours':
        return Icons.tour;
      case 'monument':
        return Icons.account_balance;
      case 'evenements':
        return Icons.event;
      case 'restaurant':
        return Icons.restaurant;
      default:
        return Icons.local_activity;
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  void _previousDay() {
    setState(() {
      _selectedDate = _selectedDate.subtract(Duration(days: 1));
    });
  }

  void _nextDay() {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: 1));
    });
  }

  void _showAddPlanningDialog() {
    // TODO: Implémenter le dialogue d'ajout de planning
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Fonctionnalité d\'ajout de planning à venir')),
    );
  }

  void _showAddActivityDialog() {
    // TODO: Implémenter le dialogue d'ajout d'activité
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Fonctionnalité d\'ajout d\'activité à venir')),
    );
  }

  void _showActivityDetails(PlanningActiviteModel activity) {
    // TODO: Implémenter l'affichage des détails de l'activité
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Détails de l\'activité: ${activity.nomActivite}')),
    );
  }
}
