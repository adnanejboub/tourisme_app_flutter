import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/dio_client.dart';

class WishlistService {
  final Dio _dio = DioClient.instance;
  static final ValueNotifier<int> changes = ValueNotifier<int>(0);

  Future<List<Map<String, dynamic>>> fetchFavorites() async {
    final res = await _dio.get('/api/user/favorites');
    if (res.statusCode == 200) {
      final data = res.data as Map<String, dynamic>;
      final items = (data['favorites'] as List?) ?? [];
      return items.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    if (res.statusCode == 401) throw UnauthorizedException();
    throw Exception('Failed to load favorites');
  }

  Future<Map<String, dynamic>> toggleFavorite({required String type, required int itemId}) async {
    final res = await _dio.post('/api/user/favorites', data: {
      'type': type,
      'itemId': itemId,
    });
    if (res.statusCode == 200) {
      final data = Map<String, dynamic>.from(res.data as Map);
      // Notify listeners that favorites changed
      try { changes.value = changes.value + 1; } catch (_) {}
      return data;
    }
    if (res.statusCode == 401) throw UnauthorizedException();
    throw Exception('Failed to toggle favorite');
  }

  // Local snapshot cache for rendering identical UI in wishlist
  static String _key(String type, int itemId) => 'fav_snapshot_${type}_$itemId';
  static String _idsKey(String type) => 'fav_ids_${type}';

  static Future<void> saveSnapshot({required String type, required int itemId, required Map<String, dynamic> data}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key(type, itemId), _encode(data));
    } catch (_) {}
  }

  static Future<void> removeSnapshot({required String type, required int itemId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key(type, itemId));
    } catch (_) {}
  }

  static Future<Map<String, dynamic>?> loadSnapshot({required String type, required int itemId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final s = prefs.getString(_key(type, itemId));
      if (s == null) return null;
      return _decode(s);
    } catch (_) {
      return null;
    }
  }

  // Local IDs list fallback (for guest mode or offline)
  static Future<Set<int>> loadLocalIds(String type) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final s = prefs.getString(_idsKey(type));
      if (s == null || s.isEmpty) return <int>{};
      final list = List<int>.from((const JsonDecoder().convert(s) as List).map((e) => (e as num).toInt()));
      return Set<int>.from(list);
    } catch (_) {
      return <int>{};
    }
  }

  static Future<void> saveLocalIds(String type, Set<int> ids) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_idsKey(type), const JsonEncoder().convert(ids.toList()));
    } catch (_) {}
  }

  static Future<void> addLocalId(String type, int itemId) async {
    final ids = await loadLocalIds(type);
    ids.add(itemId);
    await saveLocalIds(type, ids);
    try { changes.value = changes.value + 1; } catch (_) {}
  }

  static Future<void> removeLocalId(String type, int itemId) async {
    final ids = await loadLocalIds(type);
    ids.remove(itemId);
    await saveLocalIds(type, ids);
    try { changes.value = changes.value + 1; } catch (_) {}
  }

  static String _encode(Map<String, dynamic> map) => const JsonEncoder().convert(map);
  static Map<String, dynamic> _decode(String s) => Map<String, dynamic>.from(const JsonDecoder().convert(s) as Map);
}

class UnauthorizedException implements Exception {}



