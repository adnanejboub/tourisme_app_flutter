import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  // Modèle pour l'information de localisation
  LocationInfo? _currentLocation;
  LocationInfo? get currentLocation => _currentLocation;

  /// Détecter la localisation de l'utilisateur
  Future<LocationInfo> detectUserLocation() async {
    try {
      // Essayer d'abord la géolocalisation GPS
      final gpsLocation = await _tryGPSLocation();
      if (gpsLocation != null) {
        _currentLocation = gpsLocation;
        return gpsLocation;
      }

      // Fallback vers la géolocalisation IP
      final ipLocation = await _getLocationFromIP();
      _currentLocation = ipLocation;
      return ipLocation;
    } catch (e) {
      debugPrint('Error detecting location: $e');
      // Retourner une localisation par défaut (Casablanca, Maroc)
      _currentLocation = LocationInfo.defaultLocation();
      return _currentLocation!;
    }
  }

  /// Essayer d'obtenir la localisation via GPS
  Future<LocationInfo?> _tryGPSLocation() async {
    try {
      // Vérifier les permissions
      final permission = await Permission.location.status;
      if (!permission.isGranted) {
        final result = await Permission.location.request();
        if (!result.isGranted) {
          return null;
        }
      }

      // Vérifier si le service de localisation est activé
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      // Obtenir la position actuelle
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 30),
      );

      // Obtenir le nom de la ville via reverse geocoding (optionnel)
      final cityName = await _getCityFromCoordinates(position.latitude, position.longitude);

      return LocationInfo(
        city: cityName ?? 'Location détectée',
        country: 'Morocco',
        latitude: position.latitude,
        longitude: position.longitude,
        source: LocationSource.gps,
      );
    } catch (e) {
      debugPrint('GPS location failed: $e');
      return null;
    }
  }

  /// Obtenir la localisation via l'adresse IP
  Future<LocationInfo> _getLocationFromIP() async {
    try {
      // Utiliser un service de géolocalisation IP gratuit
      final response = await http.get(
        Uri.parse('http://ip-api.com/json?fields=status,country,city,lat,lon'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'success') {
          return LocationInfo(
            city: data['city'] ?? 'Ville inconnue',
            country: data['country'] ?? 'Pays inconnu',
            latitude: (data['lat'] as num?)?.toDouble(),
            longitude: (data['lon'] as num?)?.toDouble(),
            source: LocationSource.ip,
          );
        }
      }
    } catch (e) {
      debugPrint('IP location failed: $e');
    }

    // Fallback vers la localisation par défaut
    return LocationInfo.defaultLocation();
  }

  /// Obtenir le nom de la ville à partir des coordonnées (optionnel)
  Future<String?> _getCityFromCoordinates(double latitude, double longitude) async {
    try {
      // Ici vous pouvez utiliser un service de reverse geocoding
      // Comme Google Maps API, Nominatim, etc.
      // Pour cet exemple, nous retournons null pour utiliser une detection simple
      return null;
    } catch (e) {
      debugPrint('Reverse geocoding failed: $e');
      return null;
    }
  }

  /// Obtenir la ville la plus proche du Maroc basée sur les coordonnées
  String getNearestMoroccanCity(double? latitude, double? longitude) {
    if (latitude == null || longitude == null) {
      return 'Casablanca';
    }

    final cities = [
      {'name': 'Casablanca', 'lat': 33.5731, 'lon': -7.5898},
      {'name': 'Rabat', 'lat': 34.0209, 'lon': -6.8416},
      {'name': 'Marrakech', 'lat': 31.6295, 'lon': -7.9811},
      {'name': 'Fès', 'lat': 34.0331, 'lon': -5.0003},
      {'name': 'Tanger', 'lat': 35.7595, 'lon': -5.8340},
      {'name': 'Agadir', 'lat': 30.4278, 'lon': -9.5981},
      {'name': 'Meknès', 'lat': 33.8935, 'lon': -5.5473},
      {'name': 'Oujda', 'lat': 34.6814, 'lon': -1.9086},
      {'name': 'Kénitra', 'lat': 34.2610, 'lon': -6.5802},
      {'name': 'Tétouan', 'lat': 35.5889, 'lon': -5.3626},
    ];

    double minDistance = double.infinity;
    String nearestCity = 'Casablanca';

    for (final city in cities) {
      final distance = Geolocator.distanceBetween(
        latitude,
        longitude,
        city['lat'] as double,
        city['lon'] as double,
      );

      if (distance < minDistance) {
        minDistance = distance;
        nearestCity = city['name'] as String;
      }
    }

    return nearestCity;
  }
}

/// Modèle pour l'information de localisation
class LocationInfo {
  final String city;
  final String country;
  final double? latitude;
  final double? longitude;
  final LocationSource source;

  LocationInfo({
    required this.city,
    required this.country,
    this.latitude,
    this.longitude,
    required this.source,
  });

  factory LocationInfo.defaultLocation() {
    return LocationInfo(
      city: 'Casablanca',
      country: 'Morocco',
      latitude: 33.5731,
      longitude: -7.5898,
      source: LocationSource.default_,
    );
  }

  @override
  String toString() {
    return 'LocationInfo(city: $city, country: $country, source: $source)';
  }
}

enum LocationSource {
  gps,
  ip,
  default_,
}
