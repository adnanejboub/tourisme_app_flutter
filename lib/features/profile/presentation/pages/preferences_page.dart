import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../core/constants/constants.dart';
import '../../../auth/presentation/widgets/language_selector_widget.dart';

class PreferencesPage extends StatefulWidget {
  const PreferencesPage({Key? key}) : super(key: key);

  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  String _selectedLanguage = AppConstants.supportedLanguages.first['name']!;
  String _selectedCurrency = 'Euro';
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvcController = TextEditingController();
  final _cardNameController = TextEditingController();

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvcController.dispose();
    _cardNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer<LocalizationService>(
      builder: (context, localizationService, child) {
        return Scaffold(
          backgroundColor: colorScheme.background,
          appBar: AppBar(
            title: Text(
              localizationService.translate('preferences'),
              style: TextStyle(color: colorScheme.onBackground),
            ),
            backgroundColor: colorScheme.background,
            iconTheme: IconThemeData(color: colorScheme.onBackground),
            elevation: 0.5,
            centerTitle: true,
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              // Account Information
              _PrefTile(
                title: localizationService.translate('account_information'),
                icon: Icons.person,
                onTap: () => Navigator.pushNamed(context, '/edit_profile'),
                colorScheme: colorScheme,
              ),
              const SizedBox(height: 16),
              // Language
              Text(
                localizationService.translate('language'),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: colorScheme.onBackground,
                ),
              ),
              const SizedBox(height: 8),
              LanguageSelectorWidget(
                selectedLanguage: _selectedLanguage,
                onLanguageChanged: (lang) => setState(() => _selectedLanguage = lang),
              ),
              const SizedBox(height: 24),
              // Currency
              Text(
                localizationService.translate('currency'),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: colorScheme.onBackground,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.outline),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCurrency,
                    isExpanded: true,
                    icon: Icon(Icons.keyboard_arrow_down, color: colorScheme.onSurface),
                    dropdownColor: colorScheme.surface,
                    style: TextStyle(color: colorScheme.onSurface),
                    items: [
                      DropdownMenuItem(
                        value: 'Euro',
                        child: Text(localizationService.translate('euro')),
                      ),
                      DropdownMenuItem(
                        value: 'MAD',
                        child: Text(localizationService.translate('mad')),
                      ),
                      DropdownMenuItem(
                        value: 'Dollar',
                        child: Text(localizationService.translate('dollar')),
                      ),
                    ],
                    onChanged: (val) => setState(() => _selectedCurrency = val!),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Payment Method
              Text(
                localizationService.translate('payment_method'),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: colorScheme.onBackground,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.outline),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildTextField(
                      _cardNumberController,
                      localizationService.translate('card_number'),
                      colorScheme,
                      hint: '1234 5678 9012 3456',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            _expiryController,
                            localizationService.translate('expiry'),
                            colorScheme,
                            hint: 'MM/YY',
                            keyboardType: TextInputType.datetime,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            _cvcController,
                            localizationService.translate('cvc'),
                            colorScheme,
                            hint: '123',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      _cardNameController,
                      localizationService.translate('cardholder_name'),
                      colorScheme,
                      hint: localizationService.translate('name_on_card'),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () {
                          // TODO: Save payment info
                          _showSuccessMessage(context, localizationService, colorScheme);
                        },
                        child: Text(
                          localizationService.translate('save'),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label,
      ColorScheme colorScheme, {
        String? hint,
        TextInputType? keyboardType,
      }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
        hintText: hint,
        hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.5)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        fillColor: colorScheme.surface,
        filled: true,
      ),
    );
  }

  void _showSuccessMessage(BuildContext context, LocalizationService localizationService, ColorScheme colorScheme) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(localizationService.translate('payment_info_saved')),
        backgroundColor: colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _PrefTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  const _PrefTile({
    Key? key,
    required this.title,
    required this.icon,
    required this.onTap,
    required this.colorScheme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(14),
      elevation: 2,
      shadowColor: colorScheme.shadow.withOpacity(0.1),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Row(
            children: [
              Icon(icon, color: colorScheme.primary, size: 24),
              const SizedBox(width: 18),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: colorScheme.onSurface.withOpacity(0.6),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}