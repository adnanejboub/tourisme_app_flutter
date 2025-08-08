import 'package:flutter/material.dart';
import '../../core/services/guest_mode_service.dart';

mixin GuestModeMixin<T extends StatefulWidget> on State<T> {
  final GuestModeService _guestModeService = GuestModeService();

  /// Vérifie si une fonctionnalité est autorisée en mode invité
  bool isFeatureAllowed(String feature) {
    return _guestModeService.isFeatureAllowed(feature);
  }

  /// Vérifie si une fonctionnalité est restreinte en mode invité
  bool isFeatureRestricted(String feature) {
    return _guestModeService.isFeatureRestricted(feature);
  }

  /// Affiche un dialogue de connexion requise
  void showLoginRequiredDialog(String feature) {
    _guestModeService.showLoginRequiredDialog(context, feature);
  }

  /// Exécute une action avec vérification du mode invité
  void executeWithGuestCheck(String feature, VoidCallback action) {
    if (isFeatureAllowed(feature)) {
      action();
    } else {
      showLoginRequiredDialog(feature);
    }
  }

  /// Affiche un message informatif sur le mode invité
  void showGuestModeInfo() {
    _guestModeService.showGuestModeInfo(context);
  }

  /// Vérifie si l'application est en mode invité
  bool get isGuestMode => _guestModeService.isGuestMode;
}
