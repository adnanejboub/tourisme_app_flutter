// lib/features/presentation/widgets/language_selector_widget.dart
import 'package:flutter/material.dart';
import '../../../../../config/theme/app_theme.dart';
import '../../../../../core/constants/constants.dart';

class LanguageSelectorWidget extends StatelessWidget {
  final String selectedLanguage;
  final Function(String) onLanguageChanged;

  const LanguageSelectorWidget({
    Key? key,
    required this.selectedLanguage,
    required this.onLanguageChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: 56,
        maxHeight: 80, // Limite la hauteur maximale
      ),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.borderColor),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: selectedLanguage,
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: AppTheme.textSecondaryColor,
          ),
          style: TextStyle(
            fontSize: 16,
            color: AppTheme.textPrimaryColor,
            decoration: TextDecoration.none, // Remove any inherited decoration
          ),
          menuMaxHeight: 280, // Menu scrollable
          dropdownColor: Colors.white,
          underline: Container(), // Ensure no underline
          items: AppConstants.supportedLanguages.map((Map<String, String> language) {
            return DropdownMenuItem<String>(
              value: language['name'],
              child: _buildLanguageItem(language),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              onLanguageChanged(newValue);
            }
          },
        ),
      ),
    );
  }

  Widget _buildLanguageItem(Map<String, String> language) {
    return Container(
      constraints: BoxConstraints(
        minHeight: 48,
        maxHeight: 64,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Flag
          Container(
            width: 32,
            child: Text(
              language['flag']!,
              style: TextStyle(
                fontSize: 20,
                decoration: TextDecoration.none, // Remove any text decoration
              ),
              textAlign: TextAlign.center,
            ),
          ),

          SizedBox(width: 12),

          // Language info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  language['name']!,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.textPrimaryColor,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.none, // Remove any text decoration
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                if (language['code'] != 'en') ...[
                  SizedBox(height: 1),
                  Text(
                    _getNativeName(language['code']!),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondaryColor,
                      decoration: TextDecoration.none, // Remove any text decoration
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ],
            ),
          ),

          // Check icon
          if (selectedLanguage == language['name'])
            Container(
              width: 24,
              child: Icon(
                Icons.check_circle,
                color: AppTheme.primaryColor,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }

  String _getNativeName(String code) {
    switch (code) {
      case 'fr':
        return 'Français';
      case 'ar':
        return 'العربية';
      case 'es':
        return 'Español';
      default:
        return '';
    }
  }
}