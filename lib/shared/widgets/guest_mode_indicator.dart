import 'package:flutter/material.dart';
import '../../core/services/guest_mode_service.dart';
import '../../core/services/localization_service.dart';
import '../../config/theme/app_theme.dart';
import '../../config/routes/app_routes.dart';

class GuestModeIndicator extends StatelessWidget {
  const GuestModeIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: GuestModeService(),
      builder: (context, child) {
        final guestModeService = GuestModeService();
        
        if (!guestModeService.isGuestMode) {
          return const SizedBox.shrink();
        }

        final localizationService = LocalizationService();
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            border: Border(
              bottom: BorderSide(
                color: AppTheme.primaryColor.withOpacity(0.3),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: AppTheme.primaryColor,
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                child: Text(
                  localizationService.translate('login'),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () {
                  _handleSkip(context, guestModeService);
                },
                child: Text(
                  localizationService.translate('skip'),
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleSkip(BuildContext context, GuestModeService guestModeService) async {
    // Activer le mode invité
    guestModeService.enableGuestMode();
    
    // Afficher un message informatif
    if (!context.mounted) return;
    
    guestModeService.showGuestModeInfo(context);

    // Naviguer vers la page principale en mode invité
    if (!context.mounted) return;
    AppRoutes.navigateToHome(context);
  }
}
