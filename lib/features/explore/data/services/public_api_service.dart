import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/city_dto.dart';
import '../models/activity.dart';
import 'activity_data_service.dart';

class PublicApiService {
  final Dio _dio;

  PublicApiService({Dio? dio}) : _dio = dio ?? DioClient.instance;

  Future<List<CityDto>> getAllCities({CancelToken? cancelToken}) async {
    final response = await _dio.get('/public/cities', cancelToken: cancelToken);
    if (response.statusCode == 200 && response.data is List) {
      final data = response.data as List;
      return data.map((e) => CityDto.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to load cities');
  }

  Future<List<ActivityModel>> getAllActivities({CancelToken? cancelToken}) async {
    try {
      final response = await _dio.get('/public/activities', cancelToken: cancelToken);
      if (response.statusCode == 200 && response.data is List) {
        final data = response.data as List;
        final serverActivities = data.map((e) => ActivityModel.fromJson(e as Map<String, dynamic>)).toList();
        
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

  Future<Map<String, dynamic>?> getActivityById(int id, {CancelToken? cancelToken}) async {
    final response = await _dio.get('/public/activities/$id', cancelToken: cancelToken);
    if (response.statusCode == 200 && response.data is Map) {
      return Map<String, dynamic>.from(response.data as Map);
    }
    return null;
  }

  Future<Map<String, dynamic>> searchAggregated(String query, {CancelToken? cancelToken}) async {
    final response = await _dio.get(
      '/public/search',
      queryParameters: {'q': query},
      cancelToken: cancelToken,
    );
    if (response.statusCode == 200 && response.data is Map) {
      final map = response.data as Map<String, dynamic>;
      final citiesRaw = map['cities'] as List? ?? [];
      final activitiesRaw = map['activities'] as List? ?? [];
      final cities = citiesRaw.map((e) => CityDto.fromJson(e as Map<String, dynamic>)).toList();
      final activities = activitiesRaw.map((e) => ActivityModel.fromJson(e as Map<String, dynamic>)).toList();
      return {
        'cities': cities,
        'activities': activities,
      };
    }
    throw Exception('Failed to search');
  }

  Future<List<ActivityModel>> getActivitiesByCity(int cityId, {CancelToken? cancelToken}) async {
    try {
      final response = await _dio.get('/public/cities/$cityId/activities', cancelToken: cancelToken);
      if (response.statusCode == 200 && response.data is List) {
        final data = response.data as List;
        final serverActivities = data.map((e) => ActivityModel.fromJson(e as Map<String, dynamic>)).toList();
        
        // Combine with sample activities for better content
        final sampleActivities = ActivityDataService.getSampleActivities();
        final combinedActivities = <ActivityModel>[];
        
        // Add server activities first
        combinedActivities.addAll(serverActivities);
        
        // Add some sample activities to enrich the content
        final existingIds = serverActivities.map((a) => a.id).toSet();
        for (final sampleActivity in sampleActivities.take(5)) { // Add up to 5 sample activities
          if (!existingIds.contains(sampleActivity.id)) {
            combinedActivities.add(sampleActivity);
          }
        }
        
        return combinedActivities;
      }
    } catch (e) {
      print('Server city activities failed, using sample data: $e');
    }
    
    // Fallback to sample activities
    return ActivityDataService.getSampleActivities().take(8).toList();
  }

  Future<List<Map<String, dynamic>>> getCityEvents(int cityId, {CancelToken? cancelToken}) async {
    final response = await _dio.get('/public/cities/$cityId/events', cancelToken: cancelToken);
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

  Future<List<Map<String, dynamic>>> getCityAttractions(int cityId, {CancelToken? cancelToken}) async {
    final response = await _dio.get('/public/cities/$cityId/monuments', cancelToken: cancelToken);
    if (response.statusCode == 200) {
      final data = response.data;
      if (data is List) {
        return List<Map<String, dynamic>>.from(data);
      }
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> searchMonuments(String query, {CancelToken? cancelToken}) async {
    final response = await _dio.get('/public/monuments/search', queryParameters: {'q': query}, cancelToken: cancelToken);
    if (response.statusCode == 200 && response.data is List) {
      return List<Map<String, dynamic>>.from(response.data as List);
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> getAllMonuments({CancelToken? cancelToken}) async {
    final response = await _dio.get('/public/monuments', cancelToken: cancelToken);
    if (response.statusCode == 200 && response.data is List) {
      return List<Map<String, dynamic>>.from(response.data as List);
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> getProducts({String? query, CancelToken? cancelToken}) async {
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

  Future<Map<String, dynamic>?> getProductById(int id, {CancelToken? cancelToken}) async {
    final response = await _dio.get('/public/products/$id', cancelToken: cancelToken);
    if (response.statusCode == 200 && response.data is Map) {
      return Map<String, dynamic>.from(response.data as Map);
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getProductsByCity(String cityName, {CancelToken? cancelToken}) async {
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

  Future<List<Map<String, dynamic>>> getMonumentsByCity(String cityName, {CancelToken? cancelToken}) async {
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
  Future<Map<String, dynamic>> getCityDetails(int cityId, {CancelToken? cancelToken}) async {
    final response = await _dio.get(
      '/public/cities/$cityId/details',
      cancelToken: cancelToken,
    );
    if (response.statusCode == 200 && response.data is Map) {
      return Map<String, dynamic>.from(response.data as Map);
    }
    throw Exception('Failed to load city details');
  }

  // Get city activities
  Future<List<Map<String, dynamic>>> getCityActivities(int cityId, {CancelToken? cancelToken}) async {
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
  Future<List<Map<String, dynamic>>> getCityMonuments(int cityId, {CancelToken? cancelToken}) async {
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
  Future<List<Map<String, dynamic>>> getCityAccommodations(int cityId, {CancelToken? cancelToken}) async {
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


