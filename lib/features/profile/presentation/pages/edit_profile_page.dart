import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/localization_service.dart';
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

  Future<void> _pickImage(LocalizationService localizationService) async {
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
              title: Text(localizationService.translate('choose_from_gallery')),
              onTap: () async {
                final img = await picker.pickImage(source: ImageSource.gallery);
                Navigator.pop(context, img);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(localizationService.translate('take_photo')),
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
    final colorScheme = theme.colorScheme;

    return Consumer<LocalizationService>(
      builder: (context, localizationService, child) {
        return Scaffold(
          backgroundColor: colorScheme.background,
          appBar: AppBar(
            backgroundColor: colorScheme.background,
            elevation: 0,
            iconTheme: IconThemeData(color: colorScheme.onBackground),
            title: Text(
              localizationService.translate('account_information'),
              style: TextStyle(color: colorScheme.onBackground),
            ),
            centerTitle: true,
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                Center(
                  child: GestureDetector(
                    onTap: () => _pickImage(localizationService),
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundColor: colorScheme.surfaceVariant,
                          backgroundImage: _pickedImage != null ? FileImage(File(_pickedImage!.path)) : null,
                          child: _pickedImage == null
                              ? Icon(Icons.person, size: 60, color: colorScheme.onSurfaceVariant)
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.camera_alt, color: colorScheme.onPrimary, size: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              _firstNameController,
                              localizationService.translate('first_name'),
                              colorScheme,
                              localizationService,
                              hint: localizationService.translate('enter_first_name'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              _lastNameController,
                              localizationService.translate('last_name'),
                              colorScheme,
                              localizationService,
                              hint: localizationService.translate('enter_last_name'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        _airportController,
                        localizationService.translate('home_airport'),
                        colorScheme,
                        localizationService,
                        hint: localizationService.translate('airport_hint'),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        _emailController,
                        localizationService.translate('email_label'),
                        colorScheme,
                        localizationService,
                        hint: localizationService.translate('enter_email'),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        _addressController,
                        localizationService.translate('full_address'),
                        colorScheme,
                        localizationService,
                        hint: localizationService.translate('enter_address'),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        _address2Controller,
                        localizationService.translate('address_suite'),
                        colorScheme,
                        localizationService,
                        hint: localizationService.translate('additional_address_info'),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        _cityController,
                        localizationService.translate('city'),
                        colorScheme,
                        localizationService,
                        hint: localizationService.translate('enter_city'),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        _regionController,
                        localizationService.translate('state_region_province'),
                        colorScheme,
                        localizationService,
                        hint: localizationService.translate('enter_region'),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        _postalCodeController,
                        localizationService.translate('postal_code'),
                        colorScheme,
                        localizationService,
                        hint: localizationService.translate('enter_postal_code'),
                      ),
                      const SizedBox(height: 16),
                      // Country dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedCountry,
                        decoration: InputDecoration(
                          labelText: localizationService.translate('country'),
                          hintText: localizationService.translate('select_country'),
                          labelStyle: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
                          hintStyle: TextStyle(color: colorScheme.onSurface),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.grey, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'France',
                            child: Text(localizationService.translate('france')),
                          ),
                          DropdownMenuItem(
                            value: 'Morocco',
                            child: Text(localizationService.translate('morocco')),
                          ),
                          DropdownMenuItem(
                            value: 'Spain',
                            child: Text(localizationService.translate('spain')),
                          ),
                          DropdownMenuItem(
                            value: 'USA',
                            child: Text(localizationService.translate('usa')),
                          ),
                        ],
                        onChanged: (val) => setState(() => _selectedCountry = val!),
                      ),
                      const SizedBox(height: 16),
                      // Phone
                      _buildTextField(
                        _phoneController,
                        localizationService.translate('phone_number'),
                        colorScheme,
                        localizationService,
                        hint: '+212...',
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      // Password
                      _buildTextField(
                        _passwordController,
                        localizationService.translate('password_label'),
                        colorScheme,
                        localizationService,
                        hint: '********',
                        obscureText: true,
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () => Navigator.pushNamed(context, '/reset-password'),
                          child: Text(
                            localizationService.translate('renew_password'),
                            style: TextStyle(color: colorScheme.primary),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                          ),
                          onPressed: () {
                            if (_formKey.currentState?.validate() ?? false) {
                              // TODO: Save profile changes
                              _showSuccessMessage(context, localizationService);
                            }
                          },
                          child: Text(
                            localizationService.translate('save'),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
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
          ),
        );
      },
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label,
      ColorScheme colorScheme,
      LocalizationService localizationService, {
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
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(
                color: isFocused ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
              hintText: hint,
              hintStyle: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.normal,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.outline, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              fillColor: colorScheme.surface,
              filled: true,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return localizationService.translate('field_required');
              }
              return null;
            },
          );
        },
      ),
    );
  }

  void _showSuccessMessage(BuildContext context, LocalizationService localizationService) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(localizationService.translate('profile_updated_success')),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    Navigator.pop(context);
  }
}