import 'package:flutter/material.dart';
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Preferences', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black87),
        elevation: 0.5,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Account Information
          _PrefTile(
            title: 'Account Information',
            icon: Icons.person,
            onTap: () => Navigator.pushNamed(context, '/edit_profile'),
          ),
          const SizedBox(height: 16),
          // Language
          const Text('Language', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
          const SizedBox(height: 8),
          LanguageSelectorWidget(
            selectedLanguage: _selectedLanguage,
            onLanguageChanged: (lang) => setState(() => _selectedLanguage = lang),
          ),
          const SizedBox(height: 24),
          // Currency
          const Text('Currency', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCurrency,
                isExpanded: true,
                icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[700]),
                items: const [
                  DropdownMenuItem(value: 'Euro', child: Text('Euro (€)')),
                  DropdownMenuItem(value: 'MAD', child: Text('MAD (د.م)')),
                  DropdownMenuItem(value: 'Dollar', child: Text("Dollar (\$)")),
                ],
                onChanged: (val) => setState(() => _selectedCurrency = val!),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Payment Method
          const Text('Payment Method', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildTextField(_cardNumberController, 'Card Number', hint: '1234 5678 9012 3456', keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(_expiryController, 'Expiry', hint: 'MM/YY', keyboardType: TextInputType.datetime),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(_cvcController, 'CVC', hint: '123', keyboardType: TextInputType.number),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildTextField(_cardNameController, 'Cardholder Name', hint: 'Name on card'),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(AppConstants.primaryColor),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {
                      // TODO: Save payment info
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Payment info saved!')),
                      );
                    },
                    child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {String? hint, TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(AppConstants.primaryColor), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

class _PrefTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  const _PrefTile({Key? key, required this.title, required this.icon, required this.onTap}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Row(
            children: [
              Icon(icon, color: Color(AppConstants.primaryColor), size: 24),
              const SizedBox(width: 18),
              Expanded(
                child: Text(title, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500, fontSize: 16)),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
