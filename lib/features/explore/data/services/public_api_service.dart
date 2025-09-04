import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/city_dto.dart';
import '../models/activity.dart';

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
    final response = await _dio.get('/public/activities', cancelToken: cancelToken);
    if (response.statusCode == 200 && response.data is List) {
      final data = response.data as List;
      return data.map((e) => ActivityModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to load activities');
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
    final response = await _dio.get('/public/cities/$cityId/activities', cancelToken: cancelToken);
    if (response.statusCode == 200 && response.data is List) {
      final data = response.data as List;
      return data.map((e) => ActivityModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    // For non-list or error payloads, normalize to empty list rather than throwing in UI-driven filters
    return [];
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

  // Get monument details
  Future<Map<String, dynamic>> getMonumentDetails(int monumentId, {CancelToken? cancelToken}) async {
    final response = await _dio.get(
      '/public/monuments/$monumentId',
      cancelToken: cancelToken,
    );
    if (response.statusCode == 200 && response.data is Map) {
      return Map<String, dynamic>.from(response.data as Map);
    }
    throw Exception('Failed to load monument details');
  }

  // Get activity details
  Future<Map<String, dynamic>> getActivityDetails(int activityId, {CancelToken? cancelToken}) async {
    final response = await _dio.get(
      '/public/activities/$activityId/details',
      cancelToken: cancelToken,
    );
    if (response.statusCode == 200 && response.data is Map) {
      return Map<String, dynamic>.from(response.data as Map);
    }
    throw Exception('Failed to load activity details');
  }

  // Get accommodation details
  Future<Map<String, dynamic>> getAccommodationDetails(int hebergementId, {CancelToken? cancelToken}) async {
    final response = await _dio.get(
      '/public/hebergements/$hebergementId',
      cancelToken: cancelToken,
    );
    if (response.statusCode == 200 && response.data is Map) {
      return Map<String, dynamic>.from(response.data as Map);
    }
    throw Exception('Failed to load accommodation details');
  }

  // Get service details (parent + subtype info)
  Future<Map<String, dynamic>> getServiceDetails(int serviceId, {CancelToken? cancelToken}) async {
    final response = await _dio.get(
      '/public/services/$serviceId',
      cancelToken: cancelToken,
    );
    if (response.statusCode == 200 && response.data is Map) {
      return Map<String, dynamic>.from(response.data as Map);
    }
    throw Exception('Failed to load service details');
  }

  // List all services (lightweight)
  Future<List<Map<String, dynamic>>> getAllServices({CancelToken? cancelToken}) async {
    final response = await _dio.get('/public/services', cancelToken: cancelToken);
    if (response.statusCode == 200 && response.data is List) {
      return List<Map<String, dynamic>>.from(response.data as List);
    }
    return [];
  }

}


