import 'package:flutter/material.dart';

class PreferencesPage extends StatefulWidget {
  const PreferencesPage({Key? key}) : super(key: key);

  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  String _selectedLanguage = 'English';
  bool _isDarkMode = false;
  Map<String, bool> _paymentOptions = {
    'Credit Card': false,
    'PayPal': false,
    'Cash': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Preferences'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: ListView(
          children: [
            const Text(
              'Preferred Language',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedLanguage,
              items: const [
                DropdownMenuItem(value: 'Arabic', child: Text('Arabic')),
                DropdownMenuItem(value: 'French', child: Text('French')),
                DropdownMenuItem(value: 'English', child: Text('English')),
                DropdownMenuItem(value: 'Spanish', child: Text('Spanish')),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _selectedLanguage = value);
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Display Mode', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Switch(
                  value: _isDarkMode,
                  onChanged: (val) => setState(() => _isDarkMode = val),
                  activeColor: Colors.blueAccent,
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Payment Options', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            ..._paymentOptions.keys.map((option) => CheckboxListTile(
                  value: _paymentOptions[option],
                  onChanged: (val) => setState(() => _paymentOptions[option] = val ?? false),
                  title: Text(option),
                  activeColor: Colors.blueAccent,
                  controlAffinity: ListTileControlAffinity.leading,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: EdgeInsets.zero,
                )),
          ],
        ),
      ),
    );
  }
}
