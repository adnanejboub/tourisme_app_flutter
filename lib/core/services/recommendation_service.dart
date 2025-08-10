import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

// Models pour une meilleure structure de données
class Destination {
  final String id;
  final String name;
  final String arabicName;
  final String description;
  final String image;
  final double rating;
  final List<String> tags;
  final String bestTime;
  final String avgTemperature;
  final List<String> popularActivities;
  final BudgetRange budgetRange;
  final List<String> highlights;

  const Destination({
    required this.id,
    required this.name,
    required this.arabicName,
    required this.description,
    required this.image,
    required this.rating,
    required this.tags,
    required this.bestTime,
    required this.avgTemperature,
    required this.popularActivities,
    required this.budgetRange,
    required this.highlights,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'arabicName': arabicName,
      'description': description,
      'image': image,
      'rating': rating,
      'tags': tags,
      'bestTime': bestTime,
      'avgTemperature': avgTemperature,
      'popularActivities': popularActivities,
      'budgetRange': budgetRange.name,
      'highlights': highlights,
    };
  }

  factory Destination.fromMap(Map<String, dynamic> map) {
    return Destination(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      arabicName: map['arabicName'] ?? '',
      description: map['description'] ?? '',
      image: map['image'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      tags: List<String>.from(map['tags'] ?? []),
      bestTime: map['bestTime'] ?? '',
      avgTemperature: map['avgTemperature'] ?? '',
      popularActivities: List<String>.from(map['popularActivities'] ?? []),
      budgetRange: BudgetRange.fromString(map['budgetRange'] ?? 'mid_range'),
      highlights: List<String>.from(map['highlights'] ?? []),
    );
  }
}

class Activity {
  final String id;
  final String name;
  final String arabicName;
  final String description;
  final IconData icon;
  final String duration;
  final String bestTime;
  final BudgetLevel budget;
  final int popularity;
  final List<String> tags;

  const Activity({
    required this.id,
    required this.name,
    required this.arabicName,
    required this.description,
    required this.icon,
    required this.duration,
    required this.bestTime,
    required this.budget,
    required this.popularity,
    required this.tags,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'arabicName': arabicName,
      'description': description,
      'icon': icon,
      'duration': duration,
      'bestTime': bestTime,
      'budget': budget.name,
      'popularity': popularity,
      'tags': tags,
    };
  }
}

class ItineraryDay {
  final int day;
  final String title;
  final List<ActivitySlot> activities;
  final double estimatedCost;
  final List<String> tips;

  const ItineraryDay({
    required this.day,
    required this.title,
    required this.activities,
    required this.estimatedCost,
    required this.tips,
  });
}

class ActivitySlot {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final String startTime;
  final String endTime;
  final String duration;
  final String location;
  final double estimatedCost;
  final List<String> tips;

  const ActivitySlot({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.location,
    required this.estimatedCost,
    required this.tips,
  });
}

class RecommendationFilter {
  final List<String>? preferredActivities;
  final BudgetRange? budgetRange;
  final int? tripDuration;
  final ClimatePreference? preferredClimate;
  final List<String>? interests;
  final Season? season;
  final String? experienceType;

  const RecommendationFilter({
    this.preferredActivities,
    this.budgetRange,
    this.tripDuration,
    this.preferredClimate,
    this.interests,
    this.season,
    this.experienceType,
  });
}

// Enums pour une meilleure sécurité de type
enum BudgetRange {
  budget,
  midRange,
  luxury;

  static BudgetRange fromString(String value) {
    switch (value.toLowerCase()) {
      case 'budget':
        return BudgetRange.budget;
      case 'mid_range':
        return BudgetRange.midRange;
      case 'luxury':
        return BudgetRange.luxury;
      default:
        return BudgetRange.midRange;
    }
  }

  String get displayName {
    switch (this) {
      case BudgetRange.budget:
        return 'Budget';
      case BudgetRange.midRange:
        return 'Mid Range';
      case BudgetRange.luxury:
        return 'Luxury';
    }
  }
}

enum BudgetLevel {
  low,
  medium,
  high;

  static BudgetLevel fromString(String value) {
    switch (value.toLowerCase()) {
      case 'low':
        return BudgetLevel.low;
      case 'medium':
        return BudgetLevel.medium;
      case 'high':
        return BudgetLevel.high;
      default:
        return BudgetLevel.medium;
    }
  }
}

enum ClimatePreference {
  cool,
  moderate,
  warm;

  static ClimatePreference fromString(String value) {
    switch (value.toLowerCase()) {
      case 'cool':
        return ClimatePreference.cool;
      case 'moderate':
        return ClimatePreference.moderate;
      case 'warm':
        return ClimatePreference.warm;
      default:
        return ClimatePreference.moderate;
    }
  }
}

enum Season {
  spring,
  summer,
  autumn,
  winter;

  static Season fromString(String value) {
    switch (value.toLowerCase()) {
      case 'spring':
        return Season.spring;
      case 'summer':
        return Season.summer;
      case 'autumn':
        return Season.autumn;
      case 'winter':
        return Season.winter;
      default:
        return Season.spring;
    }
  }
}

// Exceptions personnalisées
class RecommendationException implements Exception {
  final String message;
  final String? code;

  const RecommendationException(this.message, [this.code]);

  @override
  String toString() => 'RecommendationException: $message';
}

class RecommendationService {
  static final RecommendationService _instance = RecommendationService._internal();
  factory RecommendationService() => _instance;
  RecommendationService._internal();

  // Cache pour améliorer les performances
  final Map<String, List<Destination>> _destinationCache = {};
  final Map<String, List<Activity>> _activityCache = {};

  // Configuration des coûts (peut être externalisée)
  static const Map<String, double> _activityBaseCosts = {
    'sightseeing': 50.0,
    'food_tour': 150.0,
    'shopping': 100.0,
    'cultural_visit': 30.0,
    'adventure': 200.0,
    'relaxation': 120.0,
  };

  static const Map<BudgetRange, double> _dailyBaseCosts = {
    BudgetRange.budget: 400.0,
    BudgetRange.midRange: 800.0,
    BudgetRange.luxury: 1500.0,
  };

  // Données des destinations (en production, cela viendrait d'une API)
  static const List<Map<String, dynamic>> _destinationData = [
    {
      'id': 'marrakech',
      'name': 'Marrakech',
      'arabicName': 'مراكش',
      'description': 'La ville rouge, célèbre pour ses souks, palais et jardins',
      'image': 'https://images.unsplash.com/photo-1517685352821-92cf88aee5a5?w=800&q=80',
      'rating': 4.8,
      'tags': ['Culture', 'Histoire', 'Souks', 'Palais'],
      'bestTime': 'Mars-Mai, Septembre-Novembre',
      'avgTemperature': '25°C',
      'popularActivities': ['sightseeing', 'food_tour', 'shopping', 'cultural_visit'],
      'budgetRange': 'mid_range',
      'highlights': [
        'Médina historique',
        'Jardin Majorelle',
        'Place Jemaa el-Fna',
        'Palais Bahia',
        'Souks traditionnels'
      ],
    },
    {
      'id': 'fes',
      'name': 'Fès',
      'arabicName': 'فاس',
      'description': 'La plus ancienne ville impériale, capitale culturelle et spirituelle',
      'image': 'https://images.unsplash.com/photo-1551632811-561732d1e306?w=800&q=80',
      'rating': 4.7,
      'tags': ['Histoire', 'Culture', 'Médina', 'Université'],
      'bestTime': 'Avril-Juin, Septembre-Octobre',
      'avgTemperature': '22°C',
      'popularActivities': ['cultural_visit', 'sightseeing', 'food_tour', 'shopping'],
      'budgetRange': 'budget',
      'highlights': [
        'Médina de Fès el-Bali',
        'Université Al Quaraouiyine',
        'Tanneries traditionnelles',
        'Palais Royal',
        'Musée Nejjarine'
      ],
    },
    {
      'id': 'casablanca',
      'name': 'Casablanca',
      'arabicName': 'الدار البيضاء',
      'description': 'La plus grande ville du Maroc, centre économique et portuaire',
      'image': 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=800&q=80',
      'rating': 4.5,
      'tags': ['Moderne', 'Business', 'Côte', 'Architecture'],
      'bestTime': 'Mai-Octobre',
      'avgTemperature': '23°C',
      'popularActivities': ['sightseeing', 'food_tour', 'shopping', 'relaxation'],
      'budgetRange': 'mid_range',
      'highlights': [
        'Mosquée Hassan II',
        'Corniche d\'Ain Diab',
        'Place Mohammed V',
        'Centre-ville moderne',
        'Plages de la côte'
      ],
    },
    {
      'id': 'chefchaouen',
      'name': 'Chefchaouen',
      'arabicName': 'شفشاون',
      'description': 'La perle bleue du Rif, ville pittoresque aux maisons bleues',
      'image': 'https://images.unsplash.com/photo-1569624438842-821a47b32f3b?w=800&q=80',
      'rating': 4.9,
      'tags': ['Nature', 'Photographie', 'Montagne', 'Tranquillité'],
      'bestTime': 'Avril-Juin, Septembre-Octobre',
      'avgTemperature': '20°C',
      'popularActivities': ['sightseeing', 'adventure', 'relaxation', 'cultural_visit'],
      'budgetRange': 'budget',
      'highlights': [
        'Médina bleue',
        'Place Outa el-Hammam',
        'Kasbah historique',
        'Ras el-Maa',
        'Randonnées dans le Rif'
      ],
    },
    {
      'id': 'essaouira',
      'name': 'Essaouira',
      'arabicName': 'الصويرة',
      'description': 'Port de pêche charmant, célèbre pour ses plages et son artisanat',
      'image': 'https://images.unsplash.com/photo-1570481662006-a3a1374699e8?w=800&q=80',
      'rating': 4.6,
      'tags': ['Plage', 'Artisanat', 'Musique', 'Vent'],
      'bestTime': 'Mai-Octobre',
      'avgTemperature': '24°C',
      'popularActivities': ['relaxation', 'shopping', 'food_tour', 'adventure'],
      'budgetRange': 'budget',
      'highlights': [
        'Médina fortifiée',
        'Port de pêche',
        'Plages de sable',
        'Souk des artisans',
        'Festival Gnaoua'
      ],
    },
    {
      'id': 'agadir',
      'name': 'Agadir',
      'arabicName': 'أكادير',
      'description': 'Station balnéaire moderne avec de longues plages de sable fin',
      'image': 'https://images.unsplash.com/photo-1590736969955-71cc94901144?w=800&q=80',
      'rating': 4.4,
      'tags': ['Plage', 'Resort', 'Golf', 'Plaisirs'],
      'bestTime': 'Mai-Octobre',
      'avgTemperature': '26°C',
      'popularActivities': ['relaxation', 'adventure', 'food_tour', 'shopping'],
      'budgetRange': 'mid_range',
      'highlights': [
        'Plage d\'Agadir',
        'Kasbah d\'Agadir',
        'Marina d\'Agadir',
        'Golf de l\'Océan',
        'Souk El Had'
      ],
    },
    {
      'id': 'tangier',
      'name': 'Tanger',
      'arabicName': 'طنجة',
      'description': 'Port stratégique, carrefour entre l\'Europe et l\'Afrique',
      'image': 'https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?w=800&q=80',
      'rating': 4.3,
      'tags': ['Histoire', 'Port', 'Culture', 'Vue mer'],
      'bestTime': 'Avril-Juin, Septembre-Octobre',
      'avgTemperature': '21°C',
      'popularActivities': ['sightseeing', 'cultural_visit', 'food_tour', 'shopping'],
      'budgetRange': 'budget',
      'highlights': [
        'Kasbah de Tanger',
        'Place du Grand Socco',
        'Cap Spartel',
        'Grotte d\'Hercule',
        'Médina historique'
      ],
    },
    {
      'id': 'rabat',
      'name': 'Rabat',
      'arabicName': 'الرباط',
      'description': 'Capitale administrative du Maroc, ville moderne et historique',
      'image': 'https://images.unsplash.com/photo-1590736969955-71cc94901144?w=800&q=80',
      'rating': 4.4,
      'tags': ['Capitale', 'Histoire', 'Moderne', 'Culture'],
      'bestTime': 'Avril-Juin, Septembre-Octobre',
      'avgTemperature': '22°C',
      'popularActivities': ['cultural_visit', 'sightseeing', 'food_tour', 'shopping'],
      'budgetRange': 'mid_range',
      'highlights': [
        'Kasbah des Oudayas',
        'Tour Hassan',
        'Mausolée Mohammed V',
        'Chellah',
        'Médina de Rabat'
      ],
    },
  ];

  // Données des activités
  static const List<Map<String, dynamic>> _activityData = [
    {
      'id': 'sightseeing',
      'name': 'Sightseeing',
      'arabicName': 'مشاهدة المعالم',
      'description': 'Découvrez les sites emblématiques et les monuments historiques',
      'icon': Icons.visibility,
      'duration': '2-4 hours',
      'bestTime': 'Morning or Late Afternoon',
      'budget': 'low',
      'popularity': 95,
      'tags': ['Culture', 'Histoire', 'Photographie'],
    },
    {
      'id': 'food_tour',
      'name': 'Food Tour',
      'arabicName': 'جولة الطعام',
      'description': 'Goûtez aux délices de la cuisine marocaine traditionnelle',
      'icon': Icons.restaurant,
      'duration': '3-4 hours',
      'bestTime': 'Lunch or Dinner',
      'budget': 'medium',
      'popularity': 88,
      'tags': ['Cuisine', 'Culture', 'Tradition'],
    },
    {
      'id': 'shopping',
      'name': 'Shopping',
      'arabicName': 'التسوق',
      'description': 'Explorez les souks et marchés pour des souvenirs uniques',
      'icon': Icons.shopping_bag,
      'duration': '2-3 hours',
      'bestTime': 'Morning or Evening',
      'budget': 'medium',
      'popularity': 82,
      'tags': ['Artisanat', 'Souvenirs', 'Marchés'],
    },
    {
      'id': 'cultural_visit',
      'name': 'Cultural Visit',
      'arabicName': 'زيارة ثقافية',
      'description': 'Plongez dans l\'histoire et la culture marocaine',
      'icon': Icons.museum,
      'duration': '1-2 hours',
      'bestTime': 'Any time',
      'budget': 'low',
      'popularity': 78,
      'tags': ['Histoire', 'Art', 'Éducation'],
    },
    {
      'id': 'adventure',
      'name': 'Adventure',
      'arabicName': 'مغامرة',
      'description': 'Partez à l\'aventure dans les montagnes et déserts',
      'icon': Icons.directions_bike,
      'duration': '4-6 hours',
      'bestTime': 'Morning',
      'budget': 'high',
      'popularity': 75,
      'tags': ['Nature', 'Sport', 'Défi'],
    },
    {
      'id': 'relaxation',
      'name': 'Relaxation',
      'arabicName': 'استرخاء',
      'description': 'Détendez-vous dans les hammams et spas traditionnels',
      'icon': Icons.spa,
      'duration': '2-3 hours',
      'bestTime': 'Afternoon or Evening',
      'budget': 'medium',
      'popularity': 70,
      'tags': ['Bien-être', 'Détente', 'Traditions'],
    },
  ];

  // Getters pour les destinations et activités
  List<Destination> get _destinations {
    const cacheKey = 'all_destinations';
    if (_destinationCache.containsKey(cacheKey)) {
      return _destinationCache[cacheKey]!;
    }

    final destinations = _destinationData
        .map((data) => Destination.fromMap(data))
        .toList();

    _destinationCache[cacheKey] = destinations;
    return destinations;
  }

  List<Activity> get _activities {
    const cacheKey = 'all_activities';
    if (_activityCache.containsKey(cacheKey)) {
      return _activityCache[cacheKey] as List<Activity>;
    }

    final activities = _activityData
        .map((data) => Activity(
      id: data['id'],
      name: data['name'],
      arabicName: data['arabicName'],
      description: data['description'],
      icon: data['icon'],
      duration: data['duration'],
      bestTime: data['bestTime'],
      budget: BudgetLevel.fromString(data['budget']),
      popularity: data['popularity'],
      tags: List<String>.from(data['tags']),
    ))
        .toList();

    _activityCache[cacheKey] = activities;
    return activities;
  }

  /// Obtenir toutes les destinations
  Future<List<Destination>> getAllDestinations() async {
    try {
      return _destinations;
    } catch (e) {
      throw RecommendationException(
          'Failed to get destinations: ${e.toString()}',
          'GET_DESTINATIONS_ERROR'
      );
    }
  }

  /// Obtenir une destination par ID
  Future<Destination?> getDestinationById(String id) async {
    if (id.isEmpty) {
      throw RecommendationException(
          'Destination ID cannot be empty',
          'INVALID_ID'
      );
    }

    try {
      return _destinations.firstWhere(
            (dest) => dest.id == id,
        orElse: () => throw RecommendationException(
            'Destination with ID "$id" not found',
            'DESTINATION_NOT_FOUND'
        ),
      );
    } catch (e) {
      if (e is RecommendationException) rethrow;
      return null;
    }
  }

  /// Obtenir toutes les activités
  Future<List<Activity>> getAllActivities() async {
    try {
      return _activities;
    } catch (e) {
      throw RecommendationException(
          'Failed to get activities: ${e.toString()}',
          'GET_ACTIVITIES_ERROR'
      );
    }
  }

  /// Obtenir une activité par ID
  Future<Activity?> getActivityById(String id) async {
    if (id.isEmpty) {
      throw RecommendationException(
          'Activity ID cannot be empty',
          'INVALID_ID'
      );
    }

    try {
      return _activities.firstWhere(
            (activity) => activity.id == id,
        orElse: () => throw RecommendationException(
            'Activity with ID "$id" not found',
            'ACTIVITY_NOT_FOUND'
        ),
      );
    } catch (e) {
      if (e is RecommendationException) rethrow;
      return null;
    }
  }

  /// Obtenir des recommandations de destinations basées sur les préférences
  Future<List<Destination>> getRecommendedDestinations({
    RecommendationFilter? filter,
    int limit = 6,
  }) async {
    try {
      var recommendations = List<Destination>.from(_destinations);

      if (filter != null) {
        recommendations = _applyDestinationFilters(recommendations, filter);
      }

      // Trier par rating si aucun critère spécifique
      if (filter?.preferredActivities == null && filter?.interests == null) {
        recommendations.sort((a, b) => b.rating.compareTo(a.rating));
      }

      return recommendations.take(limit).toList();
    } catch (e) {
      throw RecommendationException(
          'Failed to get recommended destinations: ${e.toString()}',
          'GET_RECOMMENDATIONS_ERROR'
      );
    }
  }

  /// Appliquer les filtres aux destinations
  List<Destination> _applyDestinationFilters(
      List<Destination> destinations,
      RecommendationFilter filter,
      ) {
    var filtered = List<Destination>.from(destinations);

    // Filtrer par budget
    if (filter.budgetRange != null) {
      filtered = filtered
          .where((dest) => dest.budgetRange == filter.budgetRange)
          .toList();
    }

    // Filtrer par durée de voyage
    if (filter.tripDuration != null) {
      filtered = _filterByTripDuration(filtered, filter.tripDuration!);
    }

    // Filtrer par climat
    if (filter.preferredClimate != null) {
      filtered = _filterByClimate(filtered, filter.preferredClimate!);
    }

    // Trier par activités préférées
    if (filter.preferredActivities != null &&
        filter.preferredActivities!.isNotEmpty) {
      filtered = _sortByActivityMatch(filtered, filter.preferredActivities!);
    }

    // Trier par intérêts
    if (filter.interests != null && filter.interests!.isNotEmpty) {
      filtered = _sortByInterestMatch(filtered, filter.interests!);
    }

    // Filtrer par saison
    if (filter.season != null) {
      filtered = _filterBySeason(filtered, filter.season!);
    }

    return filtered;
  }

  /// Filtrer les destinations par durée de voyage
  List<Destination> _filterByTripDuration(
      List<Destination> destinations,
      int tripDuration,
      ) {
    return destinations.where((dest) {
      if (tripDuration <= 3) {
        // Voyages courts : privilégier les villes avec beaucoup d'activités
        return dest.popularActivities.length >= 3;
      } else if (tripDuration <= 7) {
        // Voyages moyens : toutes les destinations conviennent
        return true;
      } else {
        // Voyages longs : privilégier les destinations avec variété
        return dest.popularActivities.length >= 4;
      }
    }).toList();
  }

  /// Filtrer les destinations par climat
  List<Destination> _filterByClimate(
      List<Destination> destinations,
      ClimatePreference climate,
      ) {
    return destinations.where((dest) {
      final temp = dest.avgTemperature;
      switch (climate) {
        case ClimatePreference.cool:
          return temp.contains('20') || temp.contains('21');
        case ClimatePreference.moderate:
          return temp.contains('22') || temp.contains('23');
        case ClimatePreference.warm:
          return temp.contains('25') || temp.contains('26');
      }
    }).toList();
  }

  /// Filtrer les destinations par saison
  List<Destination> _filterBySeason(
      List<Destination> destinations,
      Season season,
      ) {
    const seasonMap = {
      Season.spring: ['marrakech', 'fes', 'chefchaouen', 'essaouira'],
      Season.summer: ['agadir', 'essaouira', 'tangier'],
      Season.autumn: ['marrakech', 'fes', 'chefchaouen', 'rabat'],
      Season.winter: ['agadir', 'marrakech', 'casablanca'],
    };

    final seasonDestinations = seasonMap[season] ?? [];
    return destinations
        .where((dest) => seasonDestinations.contains(dest.id))
        .toList();
  }

  /// Trier les destinations par correspondance d'activités
  List<Destination> _sortByActivityMatch(
      List<Destination> destinations,
      List<String> preferredActivities,
      ) {
    destinations.sort((a, b) {
      final aScore = _calculateActivityMatch(a, preferredActivities);
      final bScore = _calculateActivityMatch(b, preferredActivities);
      return bScore.compareTo(aScore);
    });
    return destinations;
  }

  /// Trier les destinations par correspondance d'intérêts
  List<Destination> _sortByInterestMatch(
      List<Destination> destinations,
      List<String> interests,
      ) {
    destinations.sort((a, b) {
      final aScore = _calculateInterestMatch(a, interests);
      final bScore = _calculateInterestMatch(b, interests);
      return bScore.compareTo(aScore);
    });
    return destinations;
  }

  /// Calculer la correspondance des activités
  int _calculateActivityMatch(
      Destination destination,
      List<String> preferredActivities,
      ) {
    return preferredActivities
        .where((activity) => destination.popularActivities.contains(activity))
        .length;
  }

  /// Calculer la correspondance des intérêts
  int _calculateInterestMatch(
      Destination destination,
      List<String> interests,
      ) {
    return interests
        .where((interest) => destination.tags
        .any((tag) => tag.toLowerCase().contains(interest.toLowerCase())))
        .length;
  }

  /// Obtenir des recommandations d'activités pour une destination
  Future<List<Activity>> getRecommendedActivities({
    required String destinationId,
    List<String>? userPreferences,
    BudgetRange? budgetRange,
    int? tripDuration,
    int limit = 4,
  }) async {
    if (destinationId.isEmpty) {
      throw RecommendationException(
          'Destination ID cannot be empty',
          'INVALID_DESTINATION_ID'
      );
    }

    try {
      final destination = await getDestinationById(destinationId);
      if (destination == null) {
        throw RecommendationException(
            'Destination not found',
            'DESTINATION_NOT_FOUND'
        );
      }

      var recommendations = List<Activity>.from(_activities);

      // Prioriser les activités populaires de la destination
      recommendations = _sortByDestinationPopularity(
        recommendations,
        destination.popularActivities,
      );

      // Filtrer par préférences utilisateur
      if (userPreferences != null && userPreferences.isNotEmpty) {
        recommendations = _sortByUserPreferences(
          recommendations,
          userPreferences,
        );
      }

      // Filtrer par budget
      if (budgetRange != null) {
        recommendations = _filterActivitiesByBudget(
          recommendations,
          budgetRange,
        );
      }

      // Adapter à la durée du voyage
      if (tripDuration != null && tripDuration <= 2) {
        recommendations = _filterActivitiesByDuration(recommendations);
      }

      return recommendations.take(limit).toList();
    } catch (e) {
      if (e is RecommendationException) rethrow;
      throw RecommendationException(
          'Failed to get recommended activities: ${e.toString()}',
          'GET_ACTIVITY_RECOMMENDATIONS_ERROR'
      );
    }
  }

  /// Trier les activités par popularité dans la destination
  List<Activity> _sortByDestinationPopularity(
      List<Activity> activities,
      List<String> destinationActivities,
      ) {
    activities.sort((a, b) {
      final aIsPopular = destinationActivities.contains(a.id);
      final bIsPopular = destinationActivities.contains(b.id);

      if (aIsPopular && !bIsPopular) return -1;
      if (!aIsPopular && bIsPopular) return 1;
      return b.popularity.compareTo(a.popularity);
    });
    return activities;
  }

  /// Trier les activités par préférences utilisateur
  List<Activity> _sortByUserPreferences(
      List<Activity> activities,
      List<String> userPreferences,
      ) {
    activities.sort((a, b) {
      final aScore = userPreferences.contains(a.id) ? 1 : 0;
      final bScore = userPreferences.contains(b.id) ? 1 : 0;
      return bScore.compareTo(aScore);
    });
    return activities;
  }

  /// Filtrer les activités par budget
  List<Activity> _filterActivitiesByBudget(
      List<Activity> activities,
      BudgetRange budgetRange,
      ) {
    return activities.where((activity) {
      switch (budgetRange) {
        case BudgetRange.budget:
          return activity.budget == BudgetLevel.low;
        case BudgetRange.midRange:
          return activity.budget == BudgetLevel.low ||
              activity.budget == BudgetLevel.medium;
        case BudgetRange.luxury:
          return true; // Luxury accepte toutes les activités
      }
    }).toList();
  }

  /// Filtrer les activités par durée pour les voyages courts
  List<Activity> _filterActivitiesByDuration(List<Activity> activities) {
    return activities.where((activity) {
      final duration = activity.duration;
      return duration.contains('1-2') || duration.contains('2-3');
    }).toList();
  }

  /// Générer un itinéraire personnalisé
  Future<Map<String, dynamic>> generatePersonalizedItinerary({
    required String destinationId,
    required int tripDuration,
    required List<String> preferredActivities,
    required BudgetRange budgetRange,
    required DateTime startDate,
  }) async {
    // Validation des paramètres
    _validateItineraryParams(
      destinationId,
      tripDuration,
      preferredActivities,
      startDate,
    );

    try {
      final destination = await getDestinationById(destinationId);
      if (destination == null) {
        throw RecommendationException(
            'Destination not found',
            'DESTINATION_NOT_FOUND'
        );
      }

      final dailyItineraries = <ItineraryDay>[];
      double totalCost = 0.0;

      // Générer l'itinéraire quotidien
      for (int day = 1; day <= tripDuration; day++) {
        final dailyItinerary = await _generateDailyItinerary(
          day: day,
          destination: destination,
          preferredActivities: preferredActivities,
          budgetRange: budgetRange,
          isFirstDay: day == 1,
          isLastDay: day == tripDuration,
        );

        dailyItineraries.add(dailyItinerary);
        totalCost += dailyItinerary.estimatedCost;
      }

      // Calculer le coût total
      final estimatedCost = _calculateEstimatedCost(
        tripDuration: tripDuration,
        budgetRange: budgetRange,
        activities: preferredActivities,
      );

      // Générer les recommandations
      final recommendations = _generateItineraryRecommendations(
        destination: destination,
        tripDuration: tripDuration,
        preferredActivities: preferredActivities,
      );

      return {
        'destination': destination.toMap(),
        'tripDuration': tripDuration,
        'startDate': startDate.toIso8601String(),
        'budgetRange': budgetRange.name,
        'dailyItineraries': dailyItineraries
            .map((day) => _itineraryDayToMap(day))
            .toList(),
        'totalEstimatedCost': estimatedCost,
        'recommendations': recommendations,
        'generatedAt': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      if (e is RecommendationException) rethrow;
      throw RecommendationException(
          'Failed to generate itinerary: ${e.toString()}',
          'GENERATE_ITINERARY_ERROR'
      );
    }
  }

  /// Valider les paramètres de l'itinéraire
  void _validateItineraryParams(
      String destinationId,
      int tripDuration,
      List<String> preferredActivities,
      DateTime startDate,
      ) {
    if (destinationId.isEmpty) {
      throw RecommendationException(
          'Destination ID cannot be empty',
          'INVALID_DESTINATION_ID'
      );
    }

    if (tripDuration <= 0 || tripDuration > 30) {
      throw RecommendationException(
          'Trip duration must be between 1 and 30 days',
          'INVALID_TRIP_DURATION'
      );
    }

    if (preferredActivities.isEmpty) {
      throw RecommendationException(
          'At least one preferred activity must be specified',
          'NO_PREFERRED_ACTIVITIES'
      );
    }

    if (startDate.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      throw RecommendationException(
          'Start date cannot be in the past',
          'INVALID_START_DATE'
      );
    }
  }

  /// Générer un itinéraire quotidien
  Future<ItineraryDay> _generateDailyItinerary({
    required int day,
    required Destination destination,
    required List<String> preferredActivities,
    required BudgetRange budgetRange,
    required bool isFirstDay,
    required bool isLastDay,
  }) async {
    final activities = destination.popularActivities
        .where((id) => preferredActivities.contains(id))
        .toList();

    // Si pas assez d'activités préférées, ajouter des activités populaires
    if (activities.length < 2) {
      final additionalActivities = destination.popularActivities
          .where((id) => !activities.contains(id))
          .take(2 - activities.length);
      activities.addAll(additionalActivities);
    }

    final activitySlots = <ActivitySlot>[];
    double dailyCost = 0.0;

    // Générer les activités de la journée
    int currentHour = isFirstDay ? 10 : 9; // Commencer plus tard le premier jour

    for (int i = 0; i < activities.length && i < 3; i++) {
      final activityId = activities[i];
      final activity = await getActivityById(activityId);

      if (activity != null) {
        final activitySlot = _createActivitySlot(
          activity: activity,
          startHour: currentHour,
          destination: destination,
          budgetRange: budgetRange,
        );

        activitySlots.add(activitySlot);
        dailyCost += activitySlot.estimatedCost;
        currentHour += _parseDuration(activity.duration);

        // Pause entre les activités
        if (i < activities.length - 1) {
          currentHour += 1;
        }
      }
    }

    // Générer des conseils pour la journée
    final tips = _generateDailyTips(
      day: day,
      destination: destination,
      activities: activitySlots,
      isFirstDay: isFirstDay,
      isLastDay: isLastDay,
    );

    return ItineraryDay(
      day: day,
      title: _getDayTitle(day, destination.name),
      activities: activitySlots,
      estimatedCost: dailyCost,
      tips: tips,
    );
  }

  /// Créer un créneau d'activité
  ActivitySlot _createActivitySlot({
    required Activity activity,
    required int startHour,
    required Destination destination,
    required BudgetRange budgetRange,
  }) {
    final duration = _parseDuration(activity.duration);
    final endHour = startHour + duration;

    return ActivitySlot(
      id: activity.id,
      name: activity.name,
      description: activity.description,
      icon: activity.icon,
      startTime: '${startHour.toString().padLeft(2, '0')}:00',
      endTime: '${endHour.toString().padLeft(2, '0')}:00',
      duration: '${duration}h',
      location: _getActivityLocation(activity.id, destination),
      estimatedCost: _estimateActivityCost(activity, budgetRange),
      tips: _getActivityTips(activity.id, destination),
    );
  }

  /// Obtenir le titre de la journée
  String _getDayTitle(int day, String destinationName) {
    const titles = {
      1: 'Arrivée à',
      2: 'Découverte de',
      3: 'Immersion culturelle',
      4: 'Exploration approfondie',
      5: 'Aventures locales',
      6: 'Dernières découvertes',
      7: 'Journée finale',
    };

    final title = titles[day];
    if (title != null && day <= 2) {
      return '$title $destinationName';
    } else if (title != null) {
      return title;
    }
    return 'Jour $day à $destinationName';
  }

  /// Obtenir l'emplacement de l'activité
  String _getActivityLocation(String activityId, Destination destination) {
    const locationMap = {
      'sightseeing': 'Centre-ville et monuments',
      'food_tour': 'Restaurants locaux et souks',
      'shopping': 'Souks et marchés traditionnels',
      'cultural_visit': 'Musées et sites historiques',
      'adventure': 'Montagnes et nature environnante',
      'relaxation': 'Hammams et spas traditionnels',
    };

    return locationMap[activityId] ?? 'Divers endroits';
  }

  /// Estimer le coût d'une activité
  double _estimateActivityCost(Activity activity, BudgetRange budgetRange) {
    final baseCost = _activityBaseCosts[activity.id] ?? 100.0;

    final multiplier = switch (budgetRange) {
      BudgetRange.budget => 0.7,
      BudgetRange.midRange => 1.0,
      BudgetRange.luxury => 1.5,
    };

    return baseCost * multiplier;
  }

  /// Obtenir des conseils pour une activité
  List<String> _getActivityTips(String activityId, Destination destination) {
    const tipsMap = {
      'sightseeing': [
        'Visitez tôt le matin pour éviter la foule',
        'Portez des chaussures confortables',
        'N\'oubliez pas votre appareil photo',
        'Respectez les codes vestimentaires locaux',
      ],
      'food_tour': [
        'Goûtez aux spécialités locales',
        'Demandez des recommandations aux habitants',
        'Essayez les restaurants populaires',
        'N\'ayez pas peur de nouvelles saveurs',
      ],
      'shopping': [
        'Négociez poliment dans les souks',
        'Comparez les prix entre les étals',
        'Achetez des produits artisanaux locaux',
        'Gardez de l\'argent liquide',
      ],
      'cultural_visit': [
        'Apprenez l\'histoire avant la visite',
        'Respectez les règles des sites religieux',
        'Prenez le temps de lire les explications',
        'Évitez les heures de pointe',
      ],
      'adventure': [
        'Vérifiez la météo avant de partir',
        'Portez des vêtements appropriés',
        'Partez avec un guide local',
        'Emportez suffisamment d\'eau',
      ],
      'relaxation': [
        'Réservez à l\'avance',
        'Arrivez 15 minutes en avance',
        'Détendez-vous complètement',
        'Hydratez-vous après la séance',
      ],
    };

    return List<String>.from(
      tipsMap[activityId] ?? ['Profitez de votre expérience !'],
    );
  }

  /// Générer des conseils quotidiens
  List<String> _generateDailyTips({
    required int day,
    required Destination destination,
    required List<ActivitySlot> activities,
    required bool isFirstDay,
    required bool isLastDay,
  }) {
    final tips = <String>[];

    if (isFirstDay) {
      tips.addAll([
        'Reposez-vous après votre voyage',
        'Faites connaissance avec votre hébergement',
        'Explorez les environs immédiats',
        'Préparez-vous pour les jours suivants',
      ]);
    } else if (isLastDay) {
      tips.addAll([
        'Profitez de vos derniers moments',
        'Achetez vos derniers souvenirs',
        'Préparez votre départ',
        'Notez vos impressions pour y revenir',
      ]);
    } else {
      tips.addAll([
        'Variez vos activités pour ne pas vous fatiguer',
        'Prenez le temps de vous reposer',
        'Interagissez avec les habitants',
        'Documentez votre voyage',
      ]);
    }

    // Conseils spécifiques à la destination
    final tags = destination.tags;
    if (tags.any((tag) => tag.toLowerCase().contains('montagne'))) {
      tips.add('Vérifiez la météo avant vos sorties');
    }
    if (tags.any((tag) => tag.toLowerCase().contains('plage'))) {
      tips.add('Protégez-vous du soleil');
    }
    if (tags.any((tag) => tag.toLowerCase().contains('souks'))) {
      tips.add('Préparez-vous à négocier');
    }

    return tips.take(4).toList(); // Limiter à 4 conseils par jour
  }

  /// Calculer le coût estimé total
  double _calculateEstimatedCost({
    required int tripDuration,
    required BudgetRange budgetRange,
    required List<String> activities,
  }) {
    double dailyCost = _dailyBaseCosts[budgetRange] ?? 800.0;

    // Ajouter le coût des activités
    for (final activityId in activities) {
      final baseCost = _activityBaseCosts[activityId] ?? 100.0;
      final multiplier = switch (budgetRange) {
        BudgetRange.budget => 0.7,
        BudgetRange.midRange => 1.0,
        BudgetRange.luxury => 1.5,
      };
      dailyCost += baseCost * multiplier;
    }

    return dailyCost * tripDuration;
  }

  /// Générer des recommandations personnalisées
  List<String> _generateItineraryRecommendations({
    required Destination destination,
    required int tripDuration,
    required List<String> preferredActivities,
  }) {
    final recommendations = <String>[];

    if (tripDuration >= 5) {
      recommendations.add(
        'Considérez une excursion d\'une journée dans les environs',
      );
    }

    if (preferredActivities.contains('food_tour')) {
      recommendations.add('Essayez un cours de cuisine marocaine');
    }

    final tags = destination.tags;
    if (tags.any((tag) => tag.toLowerCase().contains('montagne'))) {
      recommendations.add('Prévoyez des vêtements chauds pour les soirées');
    }

    if (tags.any((tag) => tag.toLowerCase().contains('plage'))) {
      recommendations.add('Apportez votre équipement de plage');
    }

    recommendations.addAll([
      'Apprenez quelques mots d\'arabe pour une meilleure expérience',
      'Respectez les coutumes et traditions locales',
    ]);

    return recommendations;
  }

  /// Parser la durée d'une activité
  int _parseDuration(String duration) {
    final regex = RegExp(r'(\d+)-(\d+)');
    final match = regex.firstMatch(duration);

    if (match != null) {
      final min = int.parse(match.group(1)!);
      final max = int.parse(match.group(2)!);
      return ((min + max) / 2).round();
    }

    return 2; // Durée par défaut
  }

  /// Convertir ItineraryDay en Map
  Map<String, dynamic> _itineraryDayToMap(ItineraryDay day) {
    return {
      'day': day.day,
      'title': day.title,
      'activities': day.activities
          .map((activity) => _activitySlotToMap(activity))
          .toList(),
      'estimatedCost': day.estimatedCost,
      'tips': day.tips,
    };
  }

  /// Convertir ActivitySlot en Map
  Map<String, dynamic> _activitySlotToMap(ActivitySlot slot) {
    return {
      'id': slot.id,
      'name': slot.name,
      'description': slot.description,
      'startTime': slot.startTime,
      'endTime': slot.endTime,
      'duration': slot.duration,
      'location': slot.location,
      'estimatedCost': slot.estimatedCost,
      'tips': slot.tips,
    };
  }

  /// Obtenir des destinations similaires
  Future<List<Destination>> getSimilarDestinations(
      String destinationId, {
        int limit = 4,
      }) async {
    if (destinationId.isEmpty) {
      throw RecommendationException(
          'Destination ID cannot be empty',
          'INVALID_DESTINATION_ID'
      );
    }

    try {
      final destination = await getDestinationById(destinationId);
      if (destination == null) {
        throw RecommendationException(
            'Destination not found',
            'DESTINATION_NOT_FOUND'
        );
      }

      final similarities = _destinations
          .where((dest) => dest.id != destinationId)
          .map((dest) {
        final score = _calculateSimilarity(destination, dest);
        return MapEntry(dest, score);
      })
          .toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return similarities
          .take(limit)
          .map((entry) => entry.key)
          .toList();
    } catch (e) {
      if (e is RecommendationException) rethrow;
      throw RecommendationException(
          'Failed to get similar destinations: ${e.toString()}',
          'GET_SIMILAR_DESTINATIONS_ERROR'
      );
    }
  }

  /// Calculer la similarité entre deux destinations
  double _calculateSimilarity(Destination dest1, Destination dest2) {
    double score = 0.0;

    // Similarité des tags (40%)
    final commonTags = dest1.tags
        .where((tag) => dest2.tags.contains(tag))
        .length;
    score += (commonTags / dest1.tags.length) * 0.4;

    // Similarité du budget (30%)
    if (dest1.budgetRange == dest2.budgetRange) {
      score += 0.3;
    } else {
      // Budget adjacents obtiennent des points partiels
      final budgetDistance = (dest1.budgetRange.index - dest2.budgetRange.index).abs();
      if (budgetDistance == 1) {
        score += 0.15;
      }
    }

    // Similarité de la température (20%)
    if (dest1.avgTemperature == dest2.avgTemperature) {
      score += 0.2;
    } else {
      // Températures proches obtiennent des points partiels
      final temp1 = int.tryParse(dest1.avgTemperature.replaceAll(RegExp(r'[^\d]'), '')) ?? 0;
      final temp2 = int.tryParse(dest2.avgTemperature.replaceAll(RegExp(r'[^\d]'), '')) ?? 0;
      final tempDiff = (temp1 - temp2).abs();
      if (tempDiff <= 2) {
        score += 0.1;
      }
    }

    // Similarité des activités (10%)
    final commonActivities = dest1.popularActivities
        .where((activity) => dest2.popularActivities.contains(activity))
        .length;
    score += (commonActivities / dest1.popularActivities.length) * 0.1;

    return score.clamp(0.0, 1.0);
  }

  /// Obtenir des destinations par saison
  Future<List<Destination>> getDestinationsBySeason(Season season) async {
    try {
      return _filterBySeason(_destinations, season);
    } catch (e) {
      throw RecommendationException(
          'Failed to get destinations by season: ${e.toString()}',
          'GET_DESTINATIONS_BY_SEASON_ERROR'
      );
    }
  }

  /// Obtenir des destinations par budget
  Future<List<Destination>> getDestinationsByBudget(BudgetRange budgetRange) async {
    try {
      return _destinations
          .where((dest) => dest.budgetRange == budgetRange)
          .toList();
    } catch (e) {
      throw RecommendationException(
          'Failed to get destinations by budget: ${e.toString()}',
          'GET_DESTINATIONS_BY_BUDGET_ERROR'
      );
    }
  }

  /// Obtenir des destinations par type d'expérience
  Future<List<Destination>> getDestinationsByExperienceType(
      String experienceType,
      ) async {
    if (experienceType.isEmpty) {
      throw RecommendationException(
          'Experience type cannot be empty',
          'INVALID_EXPERIENCE_TYPE'
      );
    }

    try {
      const experienceMap = {
        'culture': ['marrakech', 'fes', 'rabat'],
        'nature': ['chefchaouen', 'essaouira'],
        'beach': ['agadir', 'essaouira', 'tangier'],
        'city': ['casablanca', 'rabat', 'tangier'],
        'adventure': ['chefchaouen', 'essaouira'],
        'relaxation': ['agadir', 'essaouira'],
      };

      final experienceDestinations = experienceMap[experienceType.toLowerCase()] ?? [];
      return _destinations
          .where((dest) => experienceDestinations.contains(dest.id))
          .toList();
    } catch (e) {
      throw RecommendationException(
          'Failed to get destinations by experience type: ${e.toString()}',
          'GET_DESTINATIONS_BY_EXPERIENCE_ERROR'
      );
    }
  }

  /// Nettoyer le cache
  void clearCache() {
    _destinationCache.clear();
    _activityCache.clear();
  }

  /// Obtenir les statistiques du service
  Map<String, dynamic> getServiceStats() {
    return {
      'destinationsCount': _destinations.length,
      'activitiesCount': _activities.length,
      'cacheSize': _destinationCache.length + _activityCache.length,
      'averageDestinationRating': _destinations.isEmpty
          ? 0.0
          : _destinations.map((d) => d.rating).reduce((a, b) => a + b) / _destinations.length,
    };
  }
}
