import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../core/constants/constants.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../auth/domain/entities/auth_entities.dart';
import '../bloc/profile_bloc.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _nationalityController = TextEditingController();
  final _passportController = TextEditingController();
  final _preferencesController = TextEditingController();
  final _languageLevelController = TextEditingController();
  final _budgetController = TextEditingController();
  
  String _selectedCountry = 'France';
  XFile? _pickedImage;
  UserProfileEntity? _currentProfile;

  @override
  void initState() {
    super.initState();
    // Load current profile data only if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileBloc = context.read<ProfileBloc>();
      if (profileBloc.state is! ProfileLoaded) {
        profileBloc.add(LoadCompleteProfile());
      }
    });
  }

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
    _phoneController.dispose();
    _addressController.dispose();
    _nationalityController.dispose();
    _passportController.dispose();
    _preferencesController.dispose();
    _languageLevelController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileUpdated) {
          // Show success dialog
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 28),
                    SizedBox(width: 12),
                    Text(
                      'Succès',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                content: Text(
                  'Votre profil a été mis à jour avec succès !',
                  style: TextStyle(fontSize: 16),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                      Navigator.of(context).pop(); // Go back to previous page
                    },
                    child: Text(
                      'OK',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        } else if (state is ProfileError) {
          // Show error dialog
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red, size: 28),
                    SizedBox(width: 12),
                    Text(
                      'Erreur',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                content: Text(
                  state.message,
                  style: TextStyle(fontSize: 16),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                    },
                    child: Text(
                      'Réessayer',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        }
      },
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, profileState) {
          // Populate controllers when profile is loaded
          if (profileState is ProfileLoaded && _currentProfile != profileState.profile) {
            _currentProfile = profileState.profile;
            _populateControllers(profileState.profile);
          }

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
                              _phoneController,
                              localizationService.translate('phone_number'),
                              colorScheme,
                              localizationService,
                              hint: '+212...',
                              keyboardType: TextInputType.phone,
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
                              _nationalityController,
                              localizationService.translate('nationality'),
                              colorScheme,
                              localizationService,
                              hint: localizationService.translate('enter_nationality'),
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              _passportController,
                              localizationService.translate('passport_number'),
                              colorScheme,
                              localizationService,
                              hint: localizationService.translate('enter_passport_number'),
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              _preferencesController,
                              localizationService.translate('preferences'),
                              colorScheme,
                              localizationService,
                              hint: localizationService.translate('enter_preferences'),
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              _languageLevelController,
                              localizationService.translate('language_level'),
                              colorScheme,
                              localizationService,
                              hint: localizationService.translate('enter_language_level'),
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              _budgetController,
                              localizationService.translate('budget'),
                              colorScheme,
                              localizationService,
                              hint: localizationService.translate('enter_budget'),
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
                                onPressed: profileState is ProfileUpdating ? null : () {
                                  if (_formKey.currentState?.validate() ?? false) {
                                    _saveProfile();
                                  }
                                },
                                child: profileState is ProfileUpdating
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
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
        },
      ),
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

  void _populateControllers(UserProfileEntity profile) {
    _firstNameController.text = profile.firstName;
    _lastNameController.text = profile.lastName;
    _phoneController.text = profile.telephone ?? '';
    _addressController.text = profile.adresse ?? '';
    _nationalityController.text = profile.nationalite ?? '';
    _passportController.text = profile.passeport ?? '';
    _preferencesController.text = profile.preferences ?? '';
    _languageLevelController.text = profile.niveauLangue ?? '';
    _budgetController.text = profile.budgetMax?.toString() ?? '';
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      // Validate required fields
      final firstName = _firstNameController.text.trim();
      final lastName = _lastNameController.text.trim();
      
      if (firstName.isEmpty || lastName.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Le prénom et le nom sont obligatoires'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
        return;
      }
      
      final params = ProfileUpdateParams(
        firstName: firstName.isEmpty ? null : firstName,
        lastName: lastName.isEmpty ? null : lastName,
        telephone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        adresse: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        nationalite: _nationalityController.text.trim().isEmpty ? null : _nationalityController.text.trim(),
        passeport: _passportController.text.trim().isEmpty ? null : _passportController.text.trim(),
        preferences: _preferencesController.text.trim().isEmpty ? null : _preferencesController.text.trim(),
        niveauLangue: _languageLevelController.text.trim().isEmpty ? null : _languageLevelController.text.trim(),
        budgetMax: _budgetController.text.trim().isEmpty ? null : double.tryParse(_budgetController.text.trim()),
      );

      print('Saving profile with params: ${params.toJson()}');
      context.read<ProfileBloc>().add(UpdateProfile(params));
    }
  }
}