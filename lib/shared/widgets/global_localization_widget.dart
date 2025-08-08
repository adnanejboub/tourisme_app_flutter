import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/core/services/localization_service.dart';

class LocalizedText extends StatelessWidget {
  final String textKey;
  final TextStyle? style;
  final TextAlign? textAlign;

  const LocalizedText(
      this.textKey, {
        Key? key,
        this.style,
        this.textAlign,
      }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalizationService>(
      builder: (context, localizationService, child) {
        return Text(
          localizationService.translate(textKey),
          style: style,
          textAlign: textAlign,
        );
      },
    );
  }
}

// Widget pour afficher le nom de la langue actuelle
class CurrentLanguageDisplay extends StatelessWidget {
  const CurrentLanguageDisplay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalizationService>(
      builder: (context, localizationService, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _getLanguageFlag(localizationService.currentLanguage),
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 8),
              Text(
                localizationService.nativeLanguageName,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getLanguageFlag(String language) {
    switch (language) {
      case 'English':
        return '🇺🇸';
      case 'Français':
        return '🇫🇷';
      case 'العربية':
        return '🇲🇦';
      case 'Español':
        return '🇪🇸';
      default:
        return '🇺🇸';
    }
  }
}