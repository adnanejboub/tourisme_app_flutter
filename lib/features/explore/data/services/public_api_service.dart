import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/city_dto.dart';
import '../models/activity.dart';

class PublicApiService {
  final Dio _dio;

  PublicApiService({Dio? dio}) : _dio = dio ?? DioClient.instance;

  Future<List<CityDto>> getAllCities() async {
    final response = await _dio.get('/public/cities');
    if (response.statusCode == 200 && response.data is List) {
      final data = response.data as List;
      return data.map((e) => CityDto.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to load cities');
  }

  Future<List<ActivityModel>> getAllActivities() async {
    final response = await _dio.get('/public/activities');
    if (response.statusCode == 200 && response.data is List) {
      final data = response.data as List;
      return data.map((e) => ActivityModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to load activities');
  }
}


