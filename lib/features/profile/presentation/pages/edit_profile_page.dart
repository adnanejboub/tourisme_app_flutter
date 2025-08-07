import 'package:flutter/material.dart';
import '../../../../core/constants/constants.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController(text: 'Adnane');
  final _lastNameController = TextEditingController();
  final _airportController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _address2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _regionController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedCountry = 'France';
  XFile? _pickedImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await showModalBottomSheet<XFile?>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () async {
                final img = await picker.pickImage(source: ImageSource.gallery);
                Navigator.pop(context, img);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a photo'),
              onTap: () async {
                final img = await picker.pickImage(source: ImageSource.camera);
                Navigator.pop(context, img);
              },
            ),
          ],
        ),
      ),
    );
    if (picked != null) {
      setState(() => _pickedImage = picked);
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _airportController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _address2Controller.dispose();
    _cityController.dispose();
    _regionController.dispose();
    _postalCodeController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text('Account Information', style: TextStyle(color: Colors.black87)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: _pickedImage != null ? FileImage(File(_pickedImage!.path)) : null,
                    child: _pickedImage == null
                        ? const Icon(Icons.person, size: 60, color: Colors.grey)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(6),
                        child: Icon(Icons.camera_alt, size: 20, color: Color(AppConstants.primaryColor)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildTextField(_firstNameController, 'First Name', hint: 'Enter your first name')),
                      const SizedBox(width: 12),
                      Expanded(child: _buildTextField(_lastNameController, 'Last Name', hint: 'Enter your last name')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(_airportController, 'Home Airport', hint: 'e.g. Casablanca, Morocco - All airports'),
                  const SizedBox(height: 16),
                  _buildTextField(_emailController, 'E-mail', hint: 'Enter your email', keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 16),
                  _buildTextField(_addressController, 'Full Address', hint: 'Enter your address'),
                  const SizedBox(height: 16),
                  _buildTextField(_address2Controller, 'Address (suite)', hint: 'Additional address info'),
                  const SizedBox(height: 16),
                  _buildTextField(_cityController, 'City', hint: 'Enter your city'),
                  const SizedBox(height: 16),
                  _buildTextField(_regionController, 'State/Region/Province', hint: 'Enter your region'),
                  const SizedBox(height: 16),
                  _buildTextField(_postalCodeController, 'Postal Code', hint: 'Enter your postal code'),
                  const SizedBox(height: 16),
                  // Country dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedCountry,
                    decoration: InputDecoration(
                      labelText: 'Country',
                      hintText: 'Select your country',
                      labelStyle: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
                      hintStyle: const TextStyle(color: Colors.grey),
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
                    items: const [
                      DropdownMenuItem(value: 'France', child: Text('France')),
                      DropdownMenuItem(value: 'Morocco', child: Text('Morocco')),
                      DropdownMenuItem(value: 'Spain', child: Text('Spain')),
                      DropdownMenuItem(value: 'USA', child: Text('USA')),
                    ],
                    onChanged: (val) => setState(() => _selectedCountry = val!),
                  ),
                  const SizedBox(height: 16),
                  // Phone
                  _buildTextField(_phoneController, 'Phone Number', hint: '+212...', keyboardType: TextInputType.phone),
                  const SizedBox(height: 16),
                  // Password
                  _buildTextField(_passwordController, 'Password', hint: '********', obscureText: true),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/reset-password'),
                      child: const Text('Renew your password', style: TextStyle(color: Colors.blue)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(AppConstants.primaryColor),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                      ),
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          // TODO: Save profile changes
                          Navigator.pop(context);
                        }
                      },
                      child: const Text(
                        'Save',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    String? hint,
    TextInputType? keyboardType,
    bool obscureText = false,
  }) {
    return Focus(
      child: Builder(
        builder: (context) {
          final isFocused = Focus.of(context).hasFocus;
          return TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500, fontSize: 16),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(
                color: isFocused ? Color(AppConstants.primaryColor) : Colors.grey,
                fontWeight: FontWeight.w500,
              ),
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.grey, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Color(AppConstants.primaryColor), width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              fillColor: Colors.white,
              filled: true,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'This field is required';
              }
              return null;
            },
          );
        },
      ),
    );
  }
}
