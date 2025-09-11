import 'package:flutter/material.dart';
import 'lib/core/services/personalized_recommendation_service.dart';
import 'lib/core/services/new_user_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Test du service de recommandations personnalisées
  final service = PersonalizedRecommendationService();
  
  print('=== Test du système de recommandations personnalisées ===\n');
  
  // Simuler des préférences utilisateur
  await NewUserService.saveUserPreferences({
    'interests': ['culture', 'history', 'food'],
    'budget': 'mid_range',
    'duration': 5,
  });
  
  print('1. Préférences utilisateur simulées:');
  final prefs = await NewUserService.getUserPreferences();
  print('   - Intérêts: ${prefs['interests']}');
  print('   - Budget: ${prefs['budget']}');
  print('   - Durée: ${prefs['duration']} jours\n');
  
  // Test de recommandation de ville
  print('2. Ville recommandée:');
  final recommendedCity = await service.getRecommendedCity();
  if (recommendedCity != null) {
    print('   - Nom: ${recommendedCity['name']}');
    print('   - Description: ${recommendedCity['description']}');
    print('   - Image: ${recommendedCity['image']}');
    print('   - Caractéristiques: ${recommendedCity['characteristics']}');
    print('   - Activités: ${recommendedCity['activities']}\n');
    
    // Test des activités recommandées
    print('3. Activités recommandées pour ${recommendedCity['name']}:');
    final activities = await service.getRecommendedActivities(recommendedCity['name'] as String);
    for (int i = 0; i < activities.length; i++) {
      final activity = activities[i];
      print('   ${i + 1}. ${activity.nom}');
      print('      - Catégorie: ${activity.categorie}');
      print('      - Prix: ${activity.prix} MAD');
      print('      - Durée: ${activity.dureeMinimun}-${activity.dureeMaximun} min');
    }
    print('');
    
    // Test des monuments recommandés
    print('4. Monuments recommandés pour ${recommendedCity['name']}:');
    final monuments = await service.getRecommendedMonuments(recommendedCity['name'] as String);
    for (int i = 0; i < monuments.length; i++) {
      final monument = monuments[i];
      print('   ${i + 1}. ${monument.nom}');
      print('      - Catégorie: ${monument.categorie}');
      print('      - Prix: ${monument.prix} MAD');
    }
  }
  
  print('\n=== Test terminé ===');
}
