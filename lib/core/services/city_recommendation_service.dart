import 'package:tourisme_app_flutter/features/explore/data/models/city_dto.dart';
import 'package:tourisme_app_flutter/features/explore/data/models/activity.dart';
import 'package:tourisme_app_flutter/features/explore/data/services/public_api_service.dart';
import 'package:tourisme_app_flutter/core/services/new_user_service.dart';

class CityRecommendationService {
  final PublicApiService _publicApi = PublicApiService();

  /// Recommande une ville basée sur les préférences de l'utilisateur
  Future<Map<String, dynamic>?> getRecommendedCity() async {
    try {
      final preferences = await NewUserService.getUserPreferences();
      final cities = await _publicApi.getAllCities();
      
      print('Préférences utilisateur: $preferences');
      
      if (cities.isEmpty) return null;

      // Règles déterministes basées sur les 3 premières questions
      final preferredType = preferences['preferred_city_type'] as String?; // coastal/mountain/desert/historical/modern/cultural
      final climatePref = preferences['climate_preference'] as String?; // hot_dry/hot_humid/mild/cool/variable
      final sizePref = preferences['city_size'] as String?; // small/medium/large/mega

      // Exemple demandé: climat désertique et sec + ville moyenne -> Marrakech
      if (preferredType == 'desert' && climatePref == 'hot_dry' && sizePref == 'medium') {
        final match = cities.firstWhere(
          (c) => c.nom.toLowerCase() == 'marrakech',
          orElse: () => cities.first,
        );
        return _formatCityRecommendation(match);
      }

      // Calculer le score pour chaque ville
      final cityScores = <CityDto, double>{};
      
      for (final city in cities) {
        double score = 0.0;
        
        // Score basé sur le type de ville préféré
        final preferredCityType = preferences['preferred_city_type'] as String?;
        if (preferredCityType != null) {
          final typeScore = _getCityTypeScore(city, preferredCityType);
          score += typeScore;
          print('${city.nom} - Type score ($preferredCityType): $typeScore');
        }
        
        // Score basé sur le climat préféré
        final climatePreference = preferences['climate_preference'] as String?;
        if (climatePreference != null) {
          final climateScore = _getClimateScore(city, climatePreference);
          score += climateScore;
          print('${city.nom} - Climate score ($climatePreference): $climateScore');
        }
        
        // Score basé sur la taille de ville préférée
        final citySize = preferences['city_size'] as String?;
        if (citySize != null) {
          final sizeScore = _getCitySizeScore(city, citySize);
          score += sizeScore;
          print('${city.nom} - Size score ($citySize): $sizeScore');
        }
        
        // Score basé sur les intérêts
        final interests = preferences['interests'] as List<dynamic>?;
        if (interests != null) {
          final interestsScore = _getInterestsScore(city, interests.cast<String>());
          score += interestsScore;
          print('${city.nom} - Interests score: $interestsScore');
        }
        
        // Score basé sur le budget
        final budget = preferences['budget'] as String?;
        if (budget != null) {
          final budgetScore = _getBudgetScore(city, budget);
          score += budgetScore;
          print('${city.nom} - Budget score ($budget): $budgetScore');
        }
        
        cityScores[city] = score;
        print('${city.nom} - Score total: $score');
      }
      
      // Trier par score et retourner la meilleure ville
      final sortedCities = cityScores.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      
      if (sortedCities.isEmpty) return null;
      
      final bestCity = sortedCities.first.key;
      print('Ville recommandée: ${bestCity.nom} avec un score de ${sortedCities.first.value}');
      
      return _formatCityRecommendation(bestCity);
      
    } catch (e) {
      print('Erreur lors de la recommandation de ville: $e');
      return null;
    }
  }

  /// Récupère les activités recommandées pour une ville
  Future<List<ActivityModel>> getRecommendedActivities(String cityName) async {
    try {
      final activities = await _publicApi.getAllActivities();
      final preferences = await NewUserService.getUserPreferences();
      
      // Filtrer les activités de la ville
      final cityActivities = activities
          .where((activity) => 
              (activity.ville ?? '').toLowerCase() == cityName.toLowerCase())
          .toList();
      
      // Trier par pertinence basée sur les préférences
      final interests = preferences['interests'] as List<dynamic>? ?? [];
      final budget = preferences['budget'] as String?;
      
      cityActivities.sort((a, b) {
        double scoreA = _getActivityRelevanceScore(a, interests.cast<String>(), budget);
        double scoreB = _getActivityRelevanceScore(b, interests.cast<String>(), budget);
        return scoreB.compareTo(scoreA);
      });
      
      return cityActivities.take(6).toList();
    } catch (e) {
      print('Erreur lors de la récupération des activités: $e');
      return [];
    }
  }

  /// Récupère les monuments recommandés pour une ville
  Future<List<ActivityModel>> getRecommendedMonuments(String cityName) async {
    try {
      final activities = await _publicApi.getAllActivities();
      
      // Filtrer les monuments de la ville
      final monuments = activities
          .where((activity) => 
              (activity.ville ?? '').toLowerCase() == cityName.toLowerCase() &&
              _isMonumentActivity(activity))
          .toList();
      
      return monuments.take(4).toList();
    } catch (e) {
      print('Erreur lors de la récupération des monuments: $e');
      return [];
    }
  }

  double _getCityTypeScore(CityDto city, String preferredType) {
    switch (preferredType) {
      case 'coastal':
        return (city.isPlage ?? false) ? 10.0 : 0.0;
      case 'mountain':
        return (city.isMontagne ?? false) ? 10.0 : 0.0;
      case 'desert':
        return (city.isDesert ?? false) ? 10.0 : 0.0;
      case 'historical':
        return (city.isHistorique ?? false) ? 10.0 : 0.0;
      case 'modern':
        return (city.isModerne ?? false) ? 10.0 : 0.0;
      case 'cultural':
        return (city.isCulturelle ?? false) ? 10.0 : 0.0;
      default:
        return 0.0;
    }
  }

  double _getClimateScore(CityDto city, String climatePreference) {
    final climate = city.climatNom?.toLowerCase() ?? '';
    
    switch (climatePreference) {
      case 'hot_dry':
        return climate.contains('désert') || climate.contains('aride') ? 8.0 : 0.0;
      case 'hot_humid':
        return climate.contains('méditerranéen') || climate.contains('tropical') ? 8.0 : 0.0;
      case 'mild':
        return climate.contains('tempéré') || climate.contains('méditerranéen') ? 8.0 : 0.0;
      case 'cool':
        return climate.contains('montagne') || climate.contains('frais') ? 8.0 : 0.0;
      case 'variable':
        return 5.0; // Score neutre pour variable
      default:
        return 0.0;
    }
  }

  double _getCitySizeScore(CityDto city, String citySize) {
    // Estimation de la taille basée sur les caractéristiques
    bool isLarge = (city.isModerne ?? false) && (city.isPlage ?? false);
    bool isMedium = (city.isCulturelle ?? false) || (city.isHistorique ?? false);
    bool isSmall = !isLarge && !isMedium;
    
    switch (citySize) {
      case 'small':
        return isSmall ? 10.0 : (isMedium ? 5.0 : 0.0);
      case 'medium':
        return isMedium ? 10.0 : (isSmall || isLarge ? 5.0 : 0.0);
      case 'large':
        return isLarge ? 10.0 : (isMedium ? 5.0 : 0.0);
      case 'mega':
        return isLarge ? 10.0 : 0.0;
      default:
        return 0.0;
    }
  }

  double _getInterestsScore(CityDto city, List<String> interests) {
    double score = 0.0;
    
    for (final interest in interests) {
      switch (interest) {
        case 'culture':
          if (city.isCulturelle ?? false) score += 3.0;
          break;
        case 'history':
          if (city.isHistorique ?? false) score += 3.0;
          break;
        case 'nature':
          if ((city.isMontagne ?? false) || (city.isPlage ?? false)) score += 3.0;
          break;
        case 'adventure':
          if ((city.isMontagne ?? false) || (city.isDesert ?? false)) score += 3.0;
          break;
        case 'relaxation':
          if ((city.isPlage ?? false) || (city.isRiviera ?? false)) score += 3.0;
          break;
        case 'shopping':
          if (city.isModerne ?? false) score += 3.0;
          break;
        case 'nightlife':
          if (city.isModerne ?? false) score += 3.0;
          break;
        case 'food':
          score += 2.0; // Toutes les villes marocaines ont une bonne cuisine
          break;
      }
    }
    
    return score;
  }

  double _getBudgetScore(CityDto city, String budget) {
    // Les villes modernes sont généralement plus chères
    switch (budget) {
      case 'budget':
        return (city.isModerne ?? false) ? 0.0 : 5.0;
      case 'moderate':
        return 5.0; // Score neutre
      case 'luxury':
        return (city.isModerne ?? false) ? 8.0 : 3.0;
      default:
        return 0.0;
    }
  }

  double _getActivityRelevanceScore(ActivityModel activity, List<String> interests, String? budget) {
    double score = 0.0;
    final category = activity.categorie?.toLowerCase() ?? '';
    
    for (final interest in interests) {
      switch (interest) {
        case 'culture':
          if (category.contains('culture') || category.contains('monument')) score += 3.0;
          break;
        case 'history':
          if (category.contains('monument') || category.contains('historique')) score += 3.0;
          break;
        case 'nature':
          if (category.contains('nature') || category.contains('randonnée')) score += 3.0;
          break;
        case 'adventure':
          if (category.contains('aventure') || category.contains('sport')) score += 3.0;
          break;
        case 'relaxation':
          if (category.contains('spa') || category.contains('plage')) score += 3.0;
          break;
        case 'shopping':
          if (category.contains('shopping') || category.contains('souk')) score += 3.0;
          break;
        case 'nightlife':
          if (category.contains('bar') || category.contains('club')) score += 3.0;
          break;
        case 'food':
          if (category.contains('restaurant') || category.contains('gastronomie')) score += 3.0;
          break;
      }
    }
    
    // Ajuster selon le budget
    if (budget == 'budget' && (activity.prix ?? 0) > 100) {
      score -= 2.0;
    } else if (budget == 'luxury' && (activity.prix ?? 0) < 50) {
      score -= 1.0;
    }
    
    return score;
  }

  bool _isMonumentActivity(ActivityModel activity) {
    final category = (activity.categorie ?? '').toLowerCase();
    final name = activity.nom.toLowerCase();
    return category.contains('monument') ||
        category.contains('historique') ||
        category.contains('patrimoine') ||
        name.contains('mosquée') ||
        name.contains('quartier des habous') ||
        name.contains('médina') ||
        name.contains('kasbah') ||
        name.contains('palais') ||
        name.contains('fort') ||
        name.contains('citadelle');
  }

  Map<String, dynamic> _formatCityRecommendation(CityDto city) {
    return {
      'id': city.id,
      'name': city.nom,
      'description': city.description ?? 'Découvrez cette magnifique ville du Maroc',
      'image': city.imageUrl ?? 'assets/images/cities/${city.nom.toLowerCase()}.jpg',
      'characteristics': _getCityCharacteristics(city),
      'climate': city.climatNom ?? 'Méditerranéen',
      'isPlage': city.isPlage,
      'isMontagne': city.isMontagne,
      'isDesert': city.isDesert,
      'isRiviera': city.isRiviera,
      'isHistorique': city.isHistorique,
      'isCulturelle': city.isCulturelle,
      'isModerne': city.isModerne,
    };
  }

  List<String> _getCityCharacteristics(CityDto city) {
    final characteristics = <String>[];
    
    if (city.isPlage ?? false) characteristics.add('isPlage');
    if (city.isMontagne ?? false) characteristics.add('isMontagne');
    if (city.isDesert ?? false) characteristics.add('isDesert');
    if (city.isRiviera ?? false) characteristics.add('isRiviera');
    if (city.isHistorique ?? false) characteristics.add('isHistorique');
    if (city.isCulturelle ?? false) characteristics.add('isCulturelle');
    if (city.isModerne ?? false) characteristics.add('isModerne');
    
    return characteristics;
  }
}
