import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class ProfileImageService {
  static final ProfileImageService _instance = ProfileImageService._internal();
  factory ProfileImageService() => _instance;
  ProfileImageService._internal();

  static const String _profileImageKey = 'profile_image_path';
  static const String _profileImageBytesKey = 'profile_image_bytes';

  // Variables pour stocker l'image actuelle
  File? _currentProfileImage;
  Uint8List? _currentProfileImageBytes;

  // Getters
  File? get currentProfileImage => _currentProfileImage;
  Uint8List? get currentProfileImageBytes => _currentProfileImageBytes;

  // Sauvegarder l'image de profil
  Future<void> saveProfileImage(File? image) async {
    if (image == null) return;

    try {
      _currentProfileImage = image;
      
      if (kIsWeb) {
        // Sur le web, sauvegarder les bytes
        final bytes = await image.readAsBytes();
        _currentProfileImageBytes = bytes;
        await _saveImageBytes(bytes);
      } else {
        // Sur mobile, sauvegarder le chemin
        await _saveImagePath(image.path);
      }
      
      // Notifier les listeners
      _notifyListeners();
    } catch (e) {
      print('Error saving profile image: $e');
    }
  }

  // Sauvegarder les bytes d'image (pour le web)
  Future<void> saveProfileImageBytes(Uint8List? bytes) async {
    if (bytes == null) return;

    try {
      _currentProfileImageBytes = bytes;
      await _saveImageBytes(bytes);
      
      // Notifier les listeners
      _notifyListeners();
    } catch (e) {
      print('Error saving profile image bytes: $e');
    }
  }

  // Charger l'image de profil au démarrage
  Future<void> loadProfileImage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (kIsWeb) {
        // Sur le web, charger les bytes
        final bytesString = prefs.getString(_profileImageBytesKey);
        if (bytesString != null) {
          final bytes = Uint8List.fromList(bytesString.codeUnits);
          _currentProfileImageBytes = bytes;
        }
      } else {
        // Sur mobile, charger le chemin
        final imagePath = prefs.getString(_profileImageKey);
        if (imagePath != null && File(imagePath).existsSync()) {
          _currentProfileImage = File(imagePath);
        }
      }
      
      // Notifier les listeners
      _notifyListeners();
    } catch (e) {
      print('Error loading profile image: $e');
    }
  }

  // Sauvegarder le chemin de l'image (mobile)
  Future<void> _saveImagePath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileImageKey, path);
  }

  // Sauvegarder les bytes de l'image (web)
  Future<void> _saveImageBytes(Uint8List bytes) async {
    final prefs = await SharedPreferences.getInstance();
    final bytesString = String.fromCharCodes(bytes);
    await prefs.setString(_profileImageBytesKey, bytesString);
  }

  // Supprimer l'image de profil
  Future<void> clearProfileImage() async {
    try {
      _currentProfileImage = null;
      _currentProfileImageBytes = null;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_profileImageKey);
      await prefs.remove(_profileImageBytesKey);
      
      // Notifier les listeners
      _notifyListeners();
    } catch (e) {
      print('Error clearing profile image: $e');
    }
  }

  // Listeners pour notifier les changements
  final List<VoidCallback> _listeners = [];

  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  // Vérifier si une image existe
  bool get hasProfileImage {
    if (kIsWeb) {
      return _currentProfileImageBytes != null;
    } else {
      return _currentProfileImage != null && _currentProfileImage!.existsSync();
    }
  }
}
