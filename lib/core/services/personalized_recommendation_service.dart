import 'dart:math';
import '../../../features/explore/data/services/public_api_service.dart';
import '../../../features/explore/data/models/city_dto.dart';
import '../../../features/explore/data/models/activity.dart';
import 'new_user_service.dart';
import 'city_recommendation_service.dart';

class PersonalizedRecommendationService {
  final PublicApiService _publicApi = PublicApiService();
  final CityRecommendationService _cityRecommendationService = CityRecommendationService();
  final Random _random = Random();

  // Mapping des préférences vers des caractéristiques de villes
  final Map<String, List<String>> _preferenceToCityCharacteristics = {
    'culture': ['isHistorique', 'isCulturelle'],
    'history': ['isHistorique', 'isCulturelle'],
    'nature': ['isMontagne', 'isPlage'],
    'beach': ['isPlage', 'isRiviera'],
    'mountain': ['isMontagne'],
    'desert': ['isDesert'],
    'modern': ['isModerne'],
    'relaxation': ['isPlage', 'isRiviera'],
    'adventure': ['isMontagne', 'isDesert'],
    'shopping': ['isModerne'],
    'nightlife': ['isModerne'],
    'food': ['isCulturelle'],
  };

  // Mapping des préférences vers des catégories d'activités
  final Map<String, List<String>> _preferenceToActivityCategories = {
    'culture': ['MONUMENT', 'EVENEMENTS', 'TOURS'],
    'history': ['MONUMENT', 'TOURS'],
    'nature': ['TOURS', 'EVENEMENTS'],
    'beach': ['EVENEMENTS', 'TOURS'],
    'mountain': ['TOURS', 'EVENEMENTS'],
    'desert': ['TOURS', 'EVENEMENTS'],
    'modern': ['EVENEMENTS', 'TOURS'],
    'relaxation': ['EVENEMENTS'],
    'adventure': ['TOURS', 'EVENEMENTS'],
    'shopping': ['EVENEMENTS'],
    'nightlife': ['EVENEMENTS'],
    'food': ['EVENEMENTS'],
  };

  // Villes recommandées par défaut avec leurs caractéristiques
  final List<Map<String, dynamic>> _recommendedCities = [
    {
      'name': 'Marrakech',
      'description': 'La ville rouge et ses souks animés',
      'image': 'assets/images/cities/marrakech.jpg',
      'characteristics': ['isHistorique', 'isCulturelle', 'isDesert'],
      'activities': ['culture', 'history', 'shopping', 'food'],
      'monuments': ['Mosquée Koutoubia', 'Palais Bahia', 'Jardin Majorelle'],
    },
    {
      'name': 'Casablanca',
      'description': 'Métropole moderne du Maroc',
      'image': 'assets/images/cities/casablanca.jpg',
      'characteristics': ['isModerne', 'isCulturelle', 'isPlage'],
      'activities': ['modern', 'shopping', 'nightlife', 'business'],
      'monuments': ['Mosquée Hassan II', 'Quartier des Habous'],
    },
    {
      'name': 'Fès',
      'description': 'Capitale spirituelle et médina historique',
      'image': 'assets/images/cities/fes.jpg',
      'characteristics': ['isHistorique', 'isCulturelle'],
      'activities': ['culture', 'history', 'food'],
      'monuments': ['Médina de Fès', 'Université Al Quaraouiyine', 'Tanneries'],
    },
    {
      'name': 'Agadir',
      'description': 'Station balnéaire du sud du Maroc',
      'image': 'assets/images/cities/agadir.jpg',
      'characteristics': ['isPlage', 'isModerne', 'isRiviera'],
      'activities': ['beach', 'relaxation', 'modern'],
      'monuments': ['Kasbah d\'Agadir', 'Souk El Had'],
    },
    {
      'name': 'Chefchaouen',
      'description': 'La ville bleue des montagnes',
      'image': 'assets/images/cities/chefchaouen.jpg',
      'characteristics': ['isMontagne', 'isCulturelle'],
      'activities': ['nature', 'culture', 'relaxation'],
      'monuments': ['Médina bleue', 'Place Outa el Hammam'],
    },
    {
      'name': 'Merzouga',
      'description': 'Porte du désert du Sahara',
      'image': 'assets/images/cities/merzouga.jpg',
      'characteristics': ['isDesert'],
      'activities': ['adventure', 'desert', 'nature'],
      'monuments': ['Dunes de Merzouga', 'Erg Chebbi'],
    },
  ];

  /// Obtient une ville recommandée basée sur les préférences de l'utilisateur
  Future<Map<String, dynamic>?> getRecommendedCity() async {
    try {
      // Utiliser le nouveau service de recommandation de ville
      final recommendedCity = await _cityRecommendationService.getRecommendedCity();
      
      if (recommendedCity != null) {
        print('Ville recommandée par le nouveau service: ${recommendedCity['name']}');
        return recommendedCity;
      }
      
      // Fallback vers les villes par défaut
      print('Utilisation du fallback vers les villes par défaut');
      return _recommendedCities[_random.nextInt(_recommendedCities.length)];
    } catch (e) {
      print('Erreur lors de la récupération de la ville recommandée: $e');
      return _recommendedCities[_random.nextInt(_recommendedCities.length)];
    }
  }

  /// Obtient les activités recommandées pour une ville donnée
  Future<List<ActivityModel>> getRecommendedActivities(String cityName) async {
    try {
      // Utiliser le nouveau service de recommandation de ville
      final activities = await _cityRecommendationService.getRecommendedActivities(cityName);
      
      if (activities.isNotEmpty) {
        return activities;
      }
      
      // Fallback vers l'ancienne méthode
      final preferences = await NewUserService.getUserPreferences();
      final interests = _extractInterests(preferences);
      return _createDefaultActivitiesForCity(cityName, interests);
    } catch (e) {
      print('Erreur lors de la récupération des activités: $e');
      return _createDefaultActivitiesForCity(cityName, []);
    }
  }

  /// Obtient les monuments recommandés pour une ville donnée
  Future<List<ActivityModel>> getRecommendedMonuments(String cityName) async {
    try {
      // Utiliser le nouveau service de recommandation de ville
      final monuments = await _cityRecommendationService.getRecommendedMonuments(cityName);
      
      if (monuments.isNotEmpty) {
        return monuments;
      }
      
      // Fallback vers l'ancienne méthode
      return _createDefaultMonumentsForCity(cityName);
    } catch (e) {
      print('Erreur lors de la récupération des monuments: $e');
      return _createDefaultMonumentsForCity(cityName);
    }
  }

  /// Extrait les intérêts des préférences utilisateur
  List<String> _extractInterests(Map<String, dynamic> preferences) {
    final List<String> interests = [];
    final dynamic interestsPref = preferences['interests'];
    
    if (interestsPref is List) {
      interests.addAll(interestsPref.map((e) => e.toString().toLowerCase()));
    } else if (interestsPref is String && interestsPref.isNotEmpty) {
      interests.add(interestsPref.toLowerCase());
    }
    
    return interests;
  }

  /// Vérifie si une activité est un monument
  bool _isMonumentActivity(ActivityModel activity) {
    final category = (activity.categorie ?? '').toLowerCase();
    final name = activity.nom.toLowerCase();
    return category.contains('monument') ||
        category.contains('historique') ||
        category.contains('patrimoine') ||
        name.contains('mosquée') ||
        name.contains('palais') ||
        name.contains('médina') ||
        name.contains('kasbah') ||
        name.contains('jardin');
  }

  /// Crée des activités par défaut pour une ville
  List<ActivityModel> _createDefaultActivitiesForCity(String cityName, List<String> interests) {
    final activities = <ActivityModel>[];
    
    // Activités basées sur les intérêts
    if (interests.contains('culture') || interests.contains('history')) {
      activities.add(ActivityModel(
        id: 1000 + _random.nextInt(1000),
        nom: 'Visite culturelle de $cityName',
        description: 'Découvrez le patrimoine culturel et historique de $cityName',
        dureeMinimun: 120,
        dureeMaximun: 240,
        saison: 'Toute l\'année',
        niveauDificulta: 'Facile',
        categorie: 'TOURS',
        ville: cityName,
        prix: 50,
        imageUrl: 'assets/images/activities/cultural_heritage.jpg',
      ));
    }
    
    if (interests.contains('food')) {
      activities.add(ActivityModel(
        id: 2000 + _random.nextInt(1000),
        nom: 'Dégustation gastronomique',
        description: 'Savourez les spécialités culinaires de $cityName',
        dureeMinimun: 90,
        dureeMaximun: 180,
        saison: 'Toute l\'année',
        niveauDificulta: 'Facile',
        categorie: 'EVENEMENTS',
        ville: cityName,
        prix: 30,
        imageUrl: 'assets/images/activities/medina_tour.jpg',
      ));
    }
    
    if (interests.contains('nature') || interests.contains('beach')) {
      activities.add(ActivityModel(
        id: 3000 + _random.nextInt(1000),
        nom: 'Exploration naturelle',
        description: 'Découvrez les paysages naturels autour de $cityName',
        dureeMinimun: 180,
        dureeMaximun: 360,
        saison: 'Toute l\'année',
        niveauDificulta: 'Moyen',
        categorie: 'TOURS',
        ville: cityName,
        prix: 40,
        imageUrl: 'assets/images/activities/atlas_hiking.jpg',
      ));
    }
    
    // Activité par défaut si aucune préférence
    if (activities.isEmpty) {
      activities.add(ActivityModel(
        id: 4000 + _random.nextInt(1000),
        nom: 'Découverte de $cityName',
        description: 'Explorez les principales attractions de $cityName',
        dureeMinimun: 120,
        dureeMaximun: 240,
        saison: 'Toute l\'année',
        niveauDificulta: 'Facile',
        categorie: 'TOURS',
        ville: cityName,
        prix: 35,
        imageUrl: 'assets/images/activities/medina_tour.jpg',
      ));
    }
    
    return activities;
  }

  /// Crée des monuments par défaut pour une ville
  List<ActivityModel> _createDefaultMonumentsForCity(String cityName) {
    return [
      ActivityModel(
        id: 5000 + _random.nextInt(1000),
        nom: 'Monument historique de $cityName',
        description: 'Découvrez ce monument emblématique de $cityName',
        dureeMinimun: 60,
        dureeMaximun: 120,
        saison: 'Toute l\'année',
        niveauDificulta: 'Facile',
        categorie: 'MONUMENT',
        ville: cityName,
        prix: 20,
        imageUrl: 'assets/images/activities/cultural_heritage.jpg',
      ),
      ActivityModel(
        id: 6000 + _random.nextInt(1000),
        nom: 'Site culturel de $cityName',
        description: 'Explorez ce site culturel important de $cityName',
        dureeMinimun: 90,
        dureeMaximun: 150,
        saison: 'Toute l\'année',
        niveauDificulta: 'Facile',
        categorie: 'MONUMENT',
        ville: cityName,
        prix: 15,
        imageUrl: 'assets/images/activities/medina_tour.jpg',
      ),
    ];
  }
}
