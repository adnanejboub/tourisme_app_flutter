import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/city_dto.dart';
import '../models/activity.dart';
import 'activity_data_service.dart';
import '../../../../core/services/moroccan_cities_service.dart';

class PublicApiService {
  final Dio _dio;

  PublicApiService({Dio? dio}) : _dio = dio ?? DioClient.instance;

  Future<List<CityDto>> getAllCities({CancelToken? cancelToken}) async {
    try {
      final response = await _dio.get(
        '/public/cities',
        cancelToken: cancelToken,
      );
      if (response.statusCode == 200 && response.data is List) {
        final data = response.data as List;
        return data
            .map((e) => CityDto.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      print('Server cities failed, using local data: $e');
    }

    // Fallback to local Moroccan cities
    final moroccanCitiesService = MoroccanCitiesService();
    final localCities = moroccanCitiesService.getAllCities();
    return localCities
        .map(
          (city) => CityDto(
            id: localCities.indexOf(city) + 1,
            nom: city.name,
            description: city.description,
            imageUrl: city.images.isNotEmpty ? city.images.first : null,
            latitude: city.latitude,
            longitude: city.longitude,
          ),
        )
        .toList();
  }

  Future<List<ActivityModel>> getAllActivities({
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get(
        '/public/activities',
        cancelToken: cancelToken,
      );
      if (response.statusCode == 200 && response.data is List) {
        final data = response.data as List;
        final serverActivities = data
            .map((e) => ActivityModel.fromJson(e as Map<String, dynamic>))
            .toList();

        // Combine server activities with sample activities
        final sampleActivities = ActivityDataService.getSampleActivities();
        final combinedActivities = <ActivityModel>[];

        // Add server activities first
        combinedActivities.addAll(serverActivities);

        // Add sample activities that don't already exist (by ID)
        final existingIds = serverActivities.map((a) => a.id).toSet();
        for (final sampleActivity in sampleActivities) {
          if (!existingIds.contains(sampleActivity.id)) {
            combinedActivities.add(sampleActivity);
          }
        }

        return combinedActivities;
      }
    } catch (e) {
      // If server fails, return sample activities
      print('Server activities failed, using sample data: $e');
    }

    // Fallback to sample activities
    return ActivityDataService.getSampleActivities();
  }

  Future<Map<String, dynamic>?> getActivityById(
    int id, {
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.get(
      '/public/activities/$id',
      cancelToken: cancelToken,
    );
    if (response.statusCode == 200 && response.data is Map) {
      return Map<String, dynamic>.from(response.data as Map);
    }
    return null;
  }

  Future<Map<String, dynamic>> searchAggregated(
    String query, {
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get(
        '/public/search',
        queryParameters: {'q': query},
        cancelToken: cancelToken,
      );
      if (response.statusCode == 200 && response.data is Map) {
        final map = response.data as Map<String, dynamic>;
        final citiesRaw = map['cities'] as List? ?? [];
        final activitiesRaw = map['activities'] as List? ?? [];
        final cities = citiesRaw
            .map((e) => CityDto.fromJson(e as Map<String, dynamic>))
            .toList();
        final activities = activitiesRaw
            .map((e) => ActivityModel.fromJson(e as Map<String, dynamic>))
            .toList();
        return {'cities': cities, 'activities': activities};
      }
    } catch (e) {
      print('Server search failed, using local search: $e');
    }

    // Fallback to local search
    return performLocalSearch(query);
  }

  Map<String, dynamic> performLocalSearch(String query) {
    final queryLower = query.toLowerCase();
    
    // Search in local cities
    final moroccanCitiesService = MoroccanCitiesService();
    final allCities = moroccanCitiesService.getAllCities();
    final matchingCities = allCities
        .where((city) => 
            city.name.toLowerCase().contains(queryLower) ||
            city.description.toLowerCase().contains(queryLower))
        .map((city) => CityDto(
          id: allCities.indexOf(city) + 1,
          nom: city.name,
          description: city.description,
          imageUrl: city.images.isNotEmpty ? city.images.first : null,
          latitude: city.latitude,
          longitude: city.longitude,
          climatNom: _getClimateByRegion(city.region),
        ))
        .toList();

    // Search in local activities
    final allActivities = ActivityDataService.getSampleActivities();
    final matchingActivities = allActivities
        .where((activity) => 
            activity.nom.toLowerCase().contains(queryLower) ||
            (activity.description?.toLowerCase().contains(queryLower) ?? false) ||
            (activity.categorie?.toLowerCase().contains(queryLower) ?? false) ||
            (activity.ville?.toLowerCase().contains(queryLower) ?? false))
        .toList();

    return {
      'cities': matchingCities,
      'activities': matchingActivities,
    };
  }

  Future<List<ActivityModel>> getActivitiesByCity(
    int cityId, {
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get(
        '/public/cities/$cityId/activities',
        cancelToken: cancelToken,
      );
      if (response.statusCode == 200 && response.data is List) {
        final data = response.data as List;
        final serverActivities = data
            .map((e) => ActivityModel.fromJson(e as Map<String, dynamic>))
            .toList();

        // Combine with sample activities for better content
        final sampleActivities = ActivityDataService.getSampleActivities();
        final combinedActivities = <ActivityModel>[];

        // Add server activities first
        combinedActivities.addAll(serverActivities);

        // Add city-specific activities to enrich the content
        final existingIds = serverActivities.map((a) => a.id).toSet();
        final cityName = _getCityNameById(cityId);
        final citySpecificActivities = ActivityDataService.getActivitiesForCity(cityName);
        for (final sampleActivity in citySpecificActivities) {
          if (!existingIds.contains(sampleActivity.id)) {
            combinedActivities.add(sampleActivity);
          }
        }

        return combinedActivities;
      }
    } catch (e) {
      print('Server city activities failed, using sample data: $e');
    }

    // Fallback to city-specific activities
    final cityName = _getCityNameById(cityId);
    return ActivityDataService.getActivitiesForCity(cityName);
  }

  // Helper method to get climate by region
  String _getClimateByRegion(String region) {
    switch (region.toLowerCase()) {
      case 'casablanca-settat':
      case 'rabat-salé-kénitra':
      case 'tanger-tétouan-al hoceïma':
        return 'Méditerranéen';
      case 'marrakech-safi':
      case 'drâa-tafilalet':
      case 'oriental':
        return 'Désertique';
      case 'souss-massa':
      case 'laâyoune-sakia el hamra':
      case 'dakhla-oued ed-dahab':
        return 'Océanique';
      case 'fès-meknès':
      case 'beni mellal-khénifra':
        return 'Continental';
      default:
        return 'Méditerranéen';
    }
  }

  // Helper method to get city name by ID
  String _getCityNameById(int cityId) {
    final moroccanCitiesService = MoroccanCitiesService();
    final allCities = moroccanCitiesService.getAllCities();
    
    // Map common city IDs to names
    if (cityId >= 1 && cityId <= allCities.length) {
      return allCities[cityId - 1].name;
    }
    
    // Fallback mapping for specific cities
    switch (cityId) {
      case 1: return 'Casablanca';
      case 2: return 'Marrakech';
      case 3: return 'Fès';
      case 4: return 'Rabat';
      case 5: return 'Chefchaouen';
      case 6: return 'Agadir';
      case 7: return 'Tanger';
      case 8: return 'Essaouira';
      case 9: return 'Meknès';
      case 10: return 'Ouarzazate';
      case 11: return 'Tétouan';
      case 12: return 'Oujda';
      case 13: return 'Safi';
      default: return 'Casablanca'; // Default fallback
    }
  }

  Future<List<Map<String, dynamic>>> getCityEvents(
    int cityId, {
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.get(
      '/public/cities/$cityId/events',
      cancelToken: cancelToken,
    );
    if (response.statusCode == 200) {
      final data = response.data;
      if (data is Map && data['events'] is List) {
        return List<Map<String, dynamic>>.from(data['events'] as List);
      }
      if (data is List) {
        return List<Map<String, dynamic>>.from(data);
      }
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> getCityAttractions(
    int cityId, {
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.get(
      '/public/cities/$cityId/monuments',
      cancelToken: cancelToken,
    );
    if (response.statusCode == 200) {
      final data = response.data;
      if (data is List) {
        return List<Map<String, dynamic>>.from(data);
      }
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> searchMonuments(
    String query, {
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.get(
      '/public/monuments/search',
      queryParameters: {'q': query},
      cancelToken: cancelToken,
    );
    if (response.statusCode == 200 && response.data is List) {
      return List<Map<String, dynamic>>.from(response.data as List);
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> getAllMonuments({
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.get(
      '/public/monuments',
      cancelToken: cancelToken,
    );
    if (response.statusCode == 200 && response.data is List) {
      return List<Map<String, dynamic>>.from(response.data as List);
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> getProducts({
    String? query,
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.get(
      '/public/hebergements',
      queryParameters: query != null && query.isNotEmpty ? {'q': query} : null,
      cancelToken: cancelToken,
    );
    if (response.statusCode == 200 && response.data is List) {
      return List<Map<String, dynamic>>.from(response.data as List);
    }
    return [];
  }

  Future<Map<String, dynamic>?> getProductById(
    int id, {
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.get(
      '/public/products/$id',
      cancelToken: cancelToken,
    );
    if (response.statusCode == 200 && response.data is Map) {
      return Map<String, dynamic>.from(response.data as Map);
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getProductsByCity(
    String cityName, {
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.get(
      '/public/hebergements/by-city',
      queryParameters: {'city': cityName},
      cancelToken: cancelToken,
    );
    if (response.statusCode == 200 && response.data is List) {
      return List<Map<String, dynamic>>.from(response.data as List);
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> getMonumentsByCity(
    String cityName, {
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.get(
      '/public/monuments/by-city',
      queryParameters: {'city': cityName},
      cancelToken: cancelToken,
    );
    if (response.statusCode == 200 && response.data is List) {
      return List<Map<String, dynamic>>.from(response.data as List);
    }
    return [];
  }

  // Get comprehensive city details with all related data
  Future<Map<String, dynamic>> getCityDetails(
    int cityId, {
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get(
        '/public/cities/$cityId/details',
        cancelToken: cancelToken,
      );
      if (response.statusCode == 200 && response.data is Map) {
        return Map<String, dynamic>.from(response.data as Map);
      }
    } catch (e) {
      print('Error loading city details for city $cityId: $e');
    }

    // Fallback: try to get basic city info
    try {
      final response = await _dio.get(
        '/public/cities/$cityId',
        cancelToken: cancelToken,
      );
      if (response.statusCode == 200 && response.data is Map) {
        final cityData = Map<String, dynamic>.from(response.data as Map);
        return {
          'city': cityData,
          'activities': await getCityActivities(
            cityId,
            cancelToken: cancelToken,
          ),
          'monuments': await getCityMonuments(cityId, cancelToken: cancelToken),
          'accommodations': await getCityAccommodations(
            cityId,
            cancelToken: cancelToken,
          ),
        };
      }
    } catch (e) {
      print('Error loading basic city info for city $cityId: $e');
    }

    // Final fallback: try to get city info from local data
    final moroccanCitiesService = MoroccanCitiesService();

    // Try to get all cities and find a suitable fallback
    final allCities = moroccanCitiesService.getAllCities();
    MoroccanCity? fallbackCity;

    // Try to find a city that might match the ID or use a default
    if (cityId >= 1 && cityId <= allCities.length) {
      fallbackCity = allCities[cityId - 1]; // Use ID as index
    } else {
      // Use common Moroccan cities as fallback
      fallbackCity =
          moroccanCitiesService.getCityByName('Casablanca') ??
          moroccanCitiesService.getCityByName('Marrakech') ??
          moroccanCitiesService.getCityByName('Rabat');
    }

    if (fallbackCity != null) {
      // Get city-specific activities for the fallback city
      final citySpecificActivities = ActivityDataService.getActivitiesForCity(fallbackCity.name);
      final cityActivities = citySpecificActivities
          .map(
            (activity) => {
              'id': activity.id,
              'nom': activity.nom,
              'nomActivite': activity.nom,
              'description': activity.description,
              'prix': activity.prix,
              'dureeMinimun': activity.dureeMinimun,
              'dureeMaximun': activity.dureeMaximun,
              'saison': activity.saison,
              'niveauDificulta': activity.niveauDificulta,
              'categorie': activity.categorie,
              'typeActivite': activity.categorie,
              'imageUrl': activity.imageUrl,
              'ville': activity.ville,
            },
          )
          .toList();

      return {
        'city': {
          'id': cityId,
          'nomVille': fallbackCity.name,
          'nom': fallbackCity.name,
          'name': fallbackCity.name,
          'description': fallbackCity.description,
          'region': fallbackCity.region,
          'imageUrl': fallbackCity.images.isNotEmpty
              ? fallbackCity.images.first
              : null,
          'latitude': fallbackCity.latitude,
          'longitude': fallbackCity.longitude,
        },
        'activities': cityActivities,
         'monuments': fallbackCity.landmarks
             .asMap()
             .entries
             .map(
               (entry) => {
                 'id': entry.key + 1,
                 'nom': entry.value,
                 'description': 'Monument historique de ${fallbackCity!.name}',
                 'ville': fallbackCity!.name,
               },
             )
             .toList(),
        'accommodations': [],
      };
    }

    // Ultimate fallback: return empty structure
    return {
      'city': {
        'id': cityId,
        'nomVille': 'Ville inconnue',
        'description': 'Informations non disponibles',
      },
      'activities': [],
      'monuments': [],
      'accommodations': [],
    };
  }

  // Get city activities
  Future<List<Map<String, dynamic>>> getCityActivities(
    int cityId, {
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.get(
      '/public/cities/$cityId/activities',
      cancelToken: cancelToken,
    );
    if (response.statusCode == 200 && response.data is List) {
      return List<Map<String, dynamic>>.from(response.data as List);
    }
    return [];
  }

  // Get city monuments
  Future<List<Map<String, dynamic>>> getCityMonuments(
    int cityId, {
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.get(
      '/public/cities/$cityId/monuments',
      cancelToken: cancelToken,
    );
    if (response.statusCode == 200 && response.data is List) {
      return List<Map<String, dynamic>>.from(response.data as List);
    }
    return [];
  }

  // Get city accommodations
  Future<List<Map<String, dynamic>>> getCityAccommodations(
    int cityId, {
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.get(
      '/public/cities/$cityId/hebergements',
      cancelToken: cancelToken,
    );
    if (response.statusCode == 200 && response.data is List) {
      return List<Map<String, dynamic>>.from(response.data as List);
    }
    return [];
  }
}
