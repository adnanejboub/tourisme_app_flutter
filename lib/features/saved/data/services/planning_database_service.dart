import 'package:dio/dio.dart';
import '../models/planning_journalier_model.dart';
import '../models/planning_activite_model.dart';
import '../models/trip_model.dart';

class PlanningDatabaseService {
  final Dio _dio = Dio();
  final String baseUrl = 'http://localhost:8080/api'; // Ajustez selon votre backend

  // Sauvegarder un planning journalier
  Future<PlanningJournalierModel> savePlanningJournalier(PlanningJournalierModel planning) async {
    try {
      final response = await _dio.post(
        '$baseUrl/planning-journalier',
        data: planning.toMap(),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return PlanningJournalierModel.fromMap(response.data);
      } else {
        throw Exception('Erreur lors de la sauvegarde du planning journalier');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Sauvegarder une activité de planning
  Future<PlanningActiviteModel> savePlanningActivite(PlanningActiviteModel activite) async {
    try {
      final response = await _dio.post(
        '$baseUrl/planning-activite',
        data: activite.toMap(),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return PlanningActiviteModel.fromMap(response.data);
      } else {
        throw Exception('Erreur lors de la sauvegarde de l\'activité');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Sauvegarder un voyage complet avec planning journalier et activités
  Future<Map<String, dynamic>> saveCompleteTrip({
    required TripModel trip,
    required List<PlanningJournalierModel> planningJournalier,
    required List<PlanningActiviteModel> planningActivites,
  }) async {
    try {
      final response = await _dio.post(
        '$baseUrl/trip/complete',
        data: {
          'trip': trip.toMap(),
          'planning_journalier': planningJournalier.map((p) => p.toMap()).toList(),
          'planning_activites': planningActivites.map((a) => a.toMap()).toList(),
        },
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception('Erreur lors de la sauvegarde du voyage complet');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Récupérer les plannings journaliers d'un voyage
  Future<List<PlanningJournalierModel>> getPlanningJournalierByTrip(int tripId) async {
    try {
      final response = await _dio.get('$baseUrl/planning-journalier/trip/$tripId');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((item) => PlanningJournalierModel.fromMap(item)).toList();
      } else {
        throw Exception('Erreur lors de la récupération du planning journalier');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Récupérer les activités d'un planning
  Future<List<PlanningActiviteModel>> getPlanningActivitesByPlanning(int planningId) async {
    try {
      final response = await _dio.get('$baseUrl/planning-activite/planning/$planningId');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((item) => PlanningActiviteModel.fromMap(item)).toList();
      } else {
        throw Exception('Erreur lors de la récupération des activités');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Mettre à jour le statut d'un planning journalier
  Future<PlanningJournalierModel> updatePlanningJournalierStatus(int id, String newStatus) async {
    try {
      final response = await _dio.put(
        '$baseUrl/planning-journalier/$id/status',
        data: {'statut': newStatus},
      );
      
      if (response.statusCode == 200) {
        return PlanningJournalierModel.fromMap(response.data);
      } else {
        throw Exception('Erreur lors de la mise à jour du statut');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Mettre à jour le statut d'une activité
  Future<PlanningActiviteModel> updatePlanningActiviteStatus(int id, String newStatus) async {
    try {
      final response = await _dio.put(
        '$baseUrl/planning-activite/$id/status',
        data: {'statut': newStatus},
      );
      
      if (response.statusCode == 200) {
        return PlanningActiviteModel.fromMap(response.data);
      } else {
        throw Exception('Erreur lors de la mise à jour du statut de l\'activité');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }
}
