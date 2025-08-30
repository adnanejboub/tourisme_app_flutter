import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/theme/app_theme.dart';
import '../../core/services/guest_mode_service.dart';
import '../../core/services/localization_service.dart';

class PlanTripButton extends StatelessWidget {
  final VoidCallback? onTripPlanned;
  final String destination;

  const PlanTripButton({
    Key? key,
    this.onTripPlanned,
    required this.destination,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: GuestModeService(),
      builder: (context, child) {
        final guestModeService = GuestModeService();
        final isGuestMode = guestModeService.isGuestMode;

        return Consumer<LocalizationService>(
          builder: (context, localizationService, child) {
            return Container(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _handlePlanTrip(context, guestModeService),
                icon: Icon(
                  isGuestMode ? Icons.lock : Icons.calendar_today,
                  size: 20,
                ),
                label: Text(
                  isGuestMode 
                      ? localizationService.translate('login_required_message')
                      : localizationService.translate('plan_your_itinerary'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isGuestMode 
                      ? Colors.grey[300] 
                      : AppTheme.primaryColor,
                  foregroundColor: isGuestMode 
                      ? Colors.grey[600] 
                      : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _handlePlanTrip(BuildContext context, GuestModeService guestModeService) {
    if (guestModeService.isGuestMode) {
      // En mode invité, afficher le dialogue de connexion
      guestModeService.showLoginRequiredDialog(context, 'plan_trip');
    } else {
      // Utilisateur connecté, procéder à la planification
      _performTripPlanning(context);
    }
  }

  void _performTripPlanning(BuildContext context) {
    // Simuler la planification de voyage
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Planification de voyage vers $destination en cours...'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );

    // Appeler le callback
    onTripPlanned?.call();
  }
}
