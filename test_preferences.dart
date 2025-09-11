import 'package:flutter/material.dart';
import 'lib/core/services/new_user_service.dart';
import 'lib/core/services/city_recommendation_service.dart';

void main() async {
  // Test des préférences utilisateur
  print('=== Test des préférences utilisateur ===');
  
  // Simuler des préférences utilisateur
  final testPreferences = {
    'preferred_city_type': 'coastal',
    'climate_preference': 'hot_humid',
    'city_size': 'large',
    'duration': 7.0,
    'budget': 'moderate',
    'transportation': ['plane', 'car'],
    'accommodation': 'hotel',
    'interests': ['culture', 'food', 'relaxation'],
    'group_size': 'couple',
    'special_requirements': ['wifi', 'parking']
  };
  
  // Sauvegarder les préférences
  await NewUserService.saveUserPreferences(testPreferences);
  await NewUserService.markPreferencesCompleted();
  
  print('Préférences sauvegardées: $testPreferences');
  
  // Récupérer les préférences
  final retrievedPreferences = await NewUserService.getUserPreferences();
  print('Préférences récupérées: $retrievedPreferences');
  
  // Tester le service de recommandation
  final cityRecommendationService = CityRecommendationService();
  final recommendedCity = await cityRecommendationService.getRecommendedCity();
  
  if (recommendedCity != null) {
    print('Ville recommandée: ${recommendedCity['name']}');
    print('Description: ${recommendedCity['description']}');
    print('Caractéristiques: ${recommendedCity['characteristics']}');
  } else {
    print('Aucune ville recommandée');
  }
  
  // Tester les activités recommandées
  if (recommendedCity != null) {
    final activities = await cityRecommendationService.getRecommendedActivities(recommendedCity['name']);
    print('Activités recommandées (${activities.length}):');
    for (final activity in activities) {
      print('- ${activity.nom} (${activity.categorie})');
    }
    
    // Tester les monuments recommandés
    final monuments = await cityRecommendationService.getRecommendedMonuments(recommendedCity['name']);
    print('Monuments recommandés (${monuments.length}):');
    for (final monument in monuments) {
      print('- ${monument.nom} (${monument.categorie})');
    }
  }
  
  print('=== Fin du test ===');
}
