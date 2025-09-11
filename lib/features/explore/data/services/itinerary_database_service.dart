import 'package:dio/dio.dart';
import '../../../saved/data/models/trip_model.dart';
import '../../../saved/data/models/planning_journalier_model.dart';
import '../../../saved/data/models/planning_activite_model.dart';

class ItineraryDatabaseService {
  final Dio _dio = Dio();
  final String baseUrl = 'http://localhost:8080/api';

  // Sauvegarder un séjour complet avec itinéraire
  Future<Map<String, dynamic>> saveCompleteItinerary({
    required TripModel trip,
    required List<List<Map<String, dynamic>>> dailyActivities,
    required double totalBudget,
    required double spentAmount,
  }) async {
    try {
      // Créer les plannings journaliers pour chaque jour
      final List<PlanningJournalierModel> dailyPlannings = [];
      final List<PlanningActiviteModel> allActivities = [];
      
      for (int dayIndex = 0; dayIndex < dailyActivities.length; dayIndex++) {
        final dayActivities = dailyActivities[dayIndex];
        final currentDate = trip.startDate.add(Duration(days: dayIndex));
        
        // Créer le planning journalier pour ce jour
        final dailyPlanning = PlanningJournalierModel(
          datePlanning: currentDate,
          description: 'Jour ${dayIndex + 1} - ${trip.destination}',
          duree: _calculateDayDuration(dayActivities),
          statut: 'planifie',
        );
        dailyPlannings.add(dailyPlanning);
        
        // Créer les activités pour ce jour
        for (final activity in dayActivities) {
          final planningActivite = PlanningActiviteModel(
            idPlanning: 0, // Sera mis à jour après sauvegarde
            idActivite: DateTime.now().millisecondsSinceEpoch + dayIndex,
            nomActivite: activity['name'],
            description: activity['description'],
            prix: activity['price']?.toDouble() ?? 0.0,
            dureeMinimun: activity['duration'] ?? 60,
            dureeMaximun: (activity['duration'] ?? 60) + 30,
            saison: 'Toute l\'année',
            niveauDificulta: 'Facile',
            categorie: activity['category'] ?? 'General',
            ville: activity['location'] ?? trip.destination,
            imageUrl: activity['image'] ?? '',
            dateActivite: currentDate,
            statut: 'planifie',
          );
          allActivities.add(planningActivite);
        }
      }

      // Sauvegarder le voyage
      final tripResponse = await _dio.post(
        '$baseUrl/trip',
        data: trip.toMap(),
      );

      if (tripResponse.statusCode != 200 && tripResponse.statusCode != 201) {
        throw Exception('Erreur lors de la sauvegarde du voyage');
      }

      final tripId = tripResponse.data['id'] ?? int.parse(trip.id);

      // Sauvegarder les plannings journaliers
      final List<int> planningIds = [];
      for (final planning in dailyPlannings) {
        final planningResponse = await _dio.post(
          '$baseUrl/planning-journalier',
          data: {
            ...planning.toMap(),
            'id_sejour': tripId,
          },
        );
        
        if (planningResponse.statusCode == 200 || planningResponse.statusCode == 201) {
          planningIds.add(planningResponse.data['id_planning'] ?? planningIds.length + 1);
        }
      }

      // Sauvegarder les activités avec les bons IDs de planning
      int activityIndex = 0;
      for (int dayIndex = 0; dayIndex < dailyActivities.length; dayIndex++) {
        final dayActivities = dailyActivities[dayIndex];
        final planningId = dayIndex < planningIds.length ? planningIds[dayIndex] : 0;
        
        for (final activity in dayActivities) {
          final activityResponse = await _dio.post(
            '$baseUrl/planning-activite',
            data: {
              ...allActivities[activityIndex].toMap(),
              'id_planning': planningId,
            },
          );
          activityIndex++;
        }
      }

      // Mettre à jour les statistiques du séjour
      await _updateSejourStats(
        tripId: tripId,
        totalBudget: totalBudget,
        spentAmount: spentAmount,
        totalDays: dailyActivities.length,
      );

      return {
        'success': true,
        'tripId': tripId,
        'planningIds': planningIds,
        'message': 'Itinéraire sauvegardé avec succès',
      };
    } catch (e) {
      throw Exception('Erreur lors de la sauvegarde de l\'itinéraire: $e');
    }
  }

  // Mettre à jour les statistiques du séjour
  Future<void> _updateSejourStats({
    required int tripId,
    required double totalBudget,
    required double spentAmount,
    required int totalDays,
  }) async {
    try {
      await _dio.put(
        '$baseUrl/sejour/$tripId/stats',
        data: {
          'budget_total': totalBudget,
          'montant_depense': spentAmount,
          'nombre_jours': totalDays,
          'statut': spentAmount >= totalBudget ? 'budget_depasse' : 'en_cours',
          'derniere_maj': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      print('Erreur lors de la mise à jour des statistiques: $e');
    }
  }

  // Charger un itinéraire existant
  Future<Map<String, dynamic>> loadItinerary(int tripId) async {
    try {
      // Charger les informations du voyage
      final tripResponse = await _dio.get('$baseUrl/trip/$tripId');
      if (tripResponse.statusCode != 200) {
        throw Exception('Voyage non trouvé');
      }

      // Charger les plannings journaliers
      final planningsResponse = await _dio.get('$baseUrl/planning-journalier/trip/$tripId');
      final plannings = planningsResponse.data as List<dynamic>;

      // Organiser les activités par jour
      final Map<int, List<Map<String, dynamic>>> dailyActivities = {};
      
      for (final planning in plannings) {
        final planningId = planning['id_planning'];
        final datePlanning = DateTime.parse(planning['date_planning']);
        final dayIndex = datePlanning.difference(DateTime.parse(tripResponse.data['start_date'])).inDays;
        
        // Charger les activités pour ce planning
        final activitiesResponse = await _dio.get('$baseUrl/planning-activite/planning/$planningId');
        final activities = activitiesResponse.data as List<dynamic>;
        
        dailyActivities[dayIndex] = activities.map((activity) => {
          'id': activity['id_activite'],
          'name': activity['nom_activite'],
          'description': activity['description'],
          'time': _formatTimeFromDateTime(DateTime.parse(activity['date_activite'])),
          'duration': activity['duree_minimun'],
          'price': activity['prix'],
          'category': activity['categorie'],
          'image': activity['image_url'],
          'location': activity['ville'],
        }).toList();
      }

      return {
        'trip': tripResponse.data,
        'dailyActivities': dailyActivities,
        'totalDays': dailyActivities.keys.length,
      };
    } catch (e) {
      throw Exception('Erreur lors du chargement de l\'itinéraire: $e');
    }
  }

  // Mettre à jour une activité spécifique
  Future<void> updateActivity({
    required int activityId,
    required Map<String, dynamic> activityData,
  }) async {
    try {
      await _dio.put(
        '$baseUrl/planning-activite/$activityId',
        data: activityData,
      );
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de l\'activité: $e');
    }
  }

  // Supprimer une activité
  Future<void> deleteActivity(int activityId) async {
    try {
      await _dio.delete('$baseUrl/planning-activite/$activityId');
    } catch (e) {
      throw Exception('Erreur lors de la suppression de l\'activité: $e');
    }
  }

  // Ajouter une nouvelle activité à un jour spécifique
  Future<void> addActivityToDay({
    required int tripId,
    required int dayIndex,
    required Map<String, dynamic> activityData,
  }) async {
    try {
      // Trouver le planning journalier pour ce jour
      final planningsResponse = await _dio.get('$baseUrl/planning-journalier/trip/$tripId');
      final plannings = planningsResponse.data as List<dynamic>;
      
      if (dayIndex >= plannings.length) {
        throw Exception('Jour invalide');
      }
      
      final planningId = plannings[dayIndex]['id_planning'];
      
      // Créer la nouvelle activité
      final planningActivite = PlanningActiviteModel(
        idPlanning: planningId,
        idActivite: DateTime.now().millisecondsSinceEpoch,
        nomActivite: activityData['name'],
        description: activityData['description'],
        prix: activityData['price']?.toDouble() ?? 0.0,
        dureeMinimun: activityData['duration'] ?? 60,
        dureeMaximun: (activityData['duration'] ?? 60) + 30,
        saison: 'Toute l\'année',
        niveauDificulta: 'Facile',
        categorie: activityData['category'] ?? 'General',
        ville: activityData['location'] ?? '',
        imageUrl: activityData['image'] ?? '',
        dateActivite: DateTime.now(),
        statut: 'planifie',
      );

      await _dio.post(
        '$baseUrl/planning-activite',
        data: planningActivite.toMap(),
      );
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout de l\'activité: $e');
    }
  }

  // Obtenir les suggestions intelligentes basées sur la destination et le budget
  Future<List<Map<String, dynamic>>> getSmartSuggestions({
    required String destination,
    required double remainingBudget,
    required List<String> selectedCategories,
  }) async {
    try {
      final response = await _dio.get(
        '$baseUrl/suggestions',
        queryParameters: {
          'destination': destination,
          'budget': remainingBudget,
          'categories': selectedCategories.join(','),
        },
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        // Retourner des suggestions par défaut si l'API n'est pas disponible
        return _getDefaultSuggestions(destination, remainingBudget);
      }
    } catch (e) {
      // Retourner des suggestions par défaut en cas d'erreur
      return _getDefaultSuggestions(destination, remainingBudget);
    }
  }

  List<Map<String, dynamic>> _getDefaultSuggestions(String destination, double remainingBudget) {
    return [
      {
        'id': 'suggestion_1',
        'name': 'Add Dinner at Local Restaurant',
        'category': 'Food & Drink',
        'icon': 'restaurant',
        'price': (remainingBudget * 0.1).clamp(20.0, 50.0),
        'duration': 120,
        'description': 'Experience authentic local cuisine',
      },
      {
        'id': 'suggestion_2',
        'name': 'Shopping at Local Market',
        'category': 'Shopping',
        'icon': 'shopping_bag',
        'price': (remainingBudget * 0.15).clamp(30.0, 80.0),
        'duration': 150,
        'description': 'Find unique souvenirs and crafts',
      },
      {
        'id': 'suggestion_3',
        'name': 'Cultural Evening Show',
        'category': 'Entertainment',
        'icon': 'theater_comedy',
        'price': (remainingBudget * 0.08).clamp(15.0, 40.0),
        'duration': 90,
        'description': 'Enjoy traditional performances',
      },
    ];
  }

  int _calculateDayDuration(List<Map<String, dynamic>> dayActivities) {
    return dayActivities.fold<int>(
      0,
      (sum, activity) => sum + (activity['duration'] as int? ?? 60),
    );
  }

  String _formatTimeFromDateTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    
    return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }
}
