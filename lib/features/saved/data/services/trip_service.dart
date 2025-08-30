import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/trip_model.dart';

class TripService {
  static const String _tripsKey = 'user_trips';
  
  // Récupérer tous les trips
  Future<List<TripModel>> getAllTrips() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tripsJson = prefs.getStringList(_tripsKey) ?? [];
      
      return tripsJson
          .map((tripJson) => TripModel.fromJson(jsonDecode(tripJson)))
          .toList();
    } catch (e) {
      print('Erreur lors de la récupération des trips: $e');
      return [];
    }
  }
  
  // Sauvegarder un trip
  Future<bool> saveTrip(TripModel trip) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final trips = await getAllTrips();
      
      // Mettre à jour si l'ID existe déjà, sinon ajouter
      final existingIndex = trips.indexWhere((t) => t.id == trip.id);
      if (existingIndex >= 0) {
        trips[existingIndex] = trip.copyWith(updatedAt: DateTime.now());
      } else {
        trips.add(trip);
      }
      
      // Sauvegarder en JSON
      final tripsJson = trips
          .map((trip) => jsonEncode(trip.toJson()))
          .toList();
      
      return await prefs.setStringList(_tripsKey, tripsJson);
    } catch (e) {
      print('Erreur lors de la sauvegarde du trip: $e');
      return false;
    }
  }
  
  // Supprimer un trip
  Future<bool> deleteTrip(String tripId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final trips = await getAllTrips();
      
      trips.removeWhere((trip) => trip.id == tripId);
      
      final tripsJson = trips
          .map((trip) => jsonEncode(trip.toJson()))
          .toList();
      
      return await prefs.setStringList(_tripsKey, tripsJson);
    } catch (e) {
      print('Erreur lors de la suppression du trip: $e');
      return false;
    }
  }
  
  // Créer un nouveau trip
  Future<TripModel> createTrip({
    required String name,
    required String destination,
    required DateTime startDate,
    required DateTime endDate,
    String? notes,
  }) async {
    final trip = TripModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      destination: destination,
      startDate: startDate,
      endDate: endDate,
      activities: [],
      notes: notes,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    await saveTrip(trip);
    return trip;
  }
  
  // Ajouter une activité à un trip
  Future<bool> addActivityToTrip(String tripId, TripActivity activity) async {
    try {
      final trips = await getAllTrips();
      final tripIndex = trips.indexWhere((t) => t.id == tripId);
      
      if (tripIndex >= 0) {
        final updatedTrip = trips[tripIndex].copyWith(
          activities: [...trips[tripIndex].activities, activity],
          updatedAt: DateTime.now(),
        );
        
        trips[tripIndex] = updatedTrip;
        return await _saveAllTrips(trips);
      }
      
      return false;
    } catch (e) {
      print('Erreur lors de l\'ajout d\'activité: $e');
      return false;
    }
  }
  
  // Mettre à jour l'ordre des activités
  Future<bool> reorderActivities(String tripId, List<TripActivity> reorderedActivities) async {
    try {
      final trips = await getAllTrips();
      final tripIndex = trips.indexWhere((t) => t.id == tripId);
      
      if (tripIndex >= 0) {
        final updatedTrip = trips[tripIndex].copyWith(
          activities: reorderedActivities,
          updatedAt: DateTime.now(),
        );
        
        trips[tripIndex] = updatedTrip;
        return await _saveAllTrips(trips);
      }
      
      return false;
    } catch (e) {
      print('Erreur lors de la réorganisation des activités: $e');
      return false;
    }
  }
  
  // Supprimer une activité d'un trip
  Future<bool> removeActivityFromTrip(String tripId, String activityId) async {
    try {
      final trips = await getAllTrips();
      final tripIndex = trips.indexWhere((t) => t.id == tripId);
      
      if (tripIndex >= 0) {
        final updatedActivities = trips[tripIndex].activities
            .where((activity) => activity.id != activityId)
            .toList();
        
        final updatedTrip = trips[tripIndex].copyWith(
          activities: updatedActivities,
          updatedAt: DateTime.now(),
        );
        
        trips[tripIndex] = updatedTrip;
        return await _saveAllTrips(trips);
      }
      
      return false;
    } catch (e) {
      print('Erreur lors de la suppression d\'activité: $e');
      return false;
    }
  }
  
  // Sauvegarder tous les trips
  Future<bool> _saveAllTrips(List<TripModel> trips) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tripsJson = trips
          .map((trip) => jsonEncode(trip.toJson()))
          .toList();
      
      return await prefs.setStringList(_tripsKey, tripsJson);
    } catch (e) {
      print('Erreur lors de la sauvegarde de tous les trips: $e');
      return false;
    }
  }
}

