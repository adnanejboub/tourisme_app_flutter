import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import '../../../../core/services/profile_image_service.dart';

class ProfileAvatar extends StatefulWidget {
  final String? imageUrl;
  final Function(File?)? onImageSelected;
  final bool isGuest; // Nouveau paramètre pour identifier les utilisateurs Guest
  const ProfileAvatar({
    Key? key, 
    this.imageUrl, 
    this.onImageSelected,
    this.isGuest = false,
  }) : super(key: key);

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  File? _selectedImage;
  Uint8List? _webImageBytes; // Pour stocker les bytes sur le web
  final ImagePicker _picker = ImagePicker();
  final ProfileImageService _profileImageService = ProfileImageService();

  @override
  void initState() {
    super.initState();
    // Charger l'image de profil existante
    _profileImageService.loadProfileImage();
    // Écouter les changements
    _profileImageService.addListener(_onProfileImageChanged);
  }

  @override
  void dispose() {
    _profileImageService.removeListener(_onProfileImageChanged);
    super.dispose();
  }

  void _onProfileImageChanged() {
    if (mounted) {
      setState(() {
        _selectedImage = _profileImageService.currentProfileImage;
        _webImageBytes = _profileImageService.currentProfileImageBytes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        GestureDetector(
          onTap: _showImagePickerOptions,
          child: CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey[200],
            backgroundImage: _getImageProvider(),
            child: _getImageProvider() == null
                ? Icon(Icons.person, size: 60, color: Colors.grey[400])
                : null,
          ),
        ),
        Positioned(
          bottom: 4,
          right: 4,
          child: GestureDetector(
            onTap: _showImagePickerOptions,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(Icons.camera_alt, size: 20, color: Colors.white),
                onPressed: _showImagePickerOptions,
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  ImageProvider? _getImageProvider() {
    // Pour les utilisateurs Guest, ne pas afficher d'image personnalisée
    if (widget.isGuest) {
      return null;
    }
    
    if (kIsWeb && _webImageBytes != null) {
      return MemoryImage(_webImageBytes!);
    } else if (_selectedImage != null) {
      return FileImage(_selectedImage!);
    } else if (widget.imageUrl != null) {
      return NetworkImage(widget.imageUrl!);
    }
    return null;
  }

  void _showImagePickerOptions() {
    // Pour les utilisateurs Guest, ne pas permettre de changer l'image
    if (widget.isGuest) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please log in to change your profile picture'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Take Photo'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Choose from Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      // Demander les permissions AVANT de prendre la photo
      if (!kIsWeb) {
        if (source == ImageSource.camera) {
          final cameraStatus = await Permission.camera.request();
          if (cameraStatus != PermissionStatus.granted) {
            _showPermissionDeniedDialog('Camera permission is required to take photos.');
            return;
          }
        } else {
          // Sur Android, utiliser storage au lieu de photos
          Permission permission = Platform.isAndroid 
              ? Permission.storage 
              : Permission.photos;
          final photosStatus = await permission.request();
          if (photosStatus != PermissionStatus.granted) {
            _showPermissionDeniedDialog('Storage permission is required to select images.');
            return;
          }
        }
      }

      // Maintenant prendre la photo ou sélectionner l'image
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (image != null) {
        if (kIsWeb) {
          // Sur le web, stocker les bytes
          final bytes = await image.readAsBytes();
          await _profileImageService.saveProfileImageBytes(bytes);
        } else {
          // Sur mobile, créer le fichier et sauvegarder
          final file = File(image.path);
          await _profileImageService.saveProfileImage(file);
        }
        
        // Notifier le parent widget
        if (widget.onImageSelected != null) {
          final tempFile = File(image.path);
          widget.onImageSelected!(tempFile);
        }
        
        // Afficher un message de confirmation
        _showSuccessMessage(source == ImageSource.camera ? 'Photo taken and saved successfully!' : 'Image selected and saved successfully!');
      }
    } catch (e) {
      _showErrorDialog('Error selecting image: $e');
    }
  }

  void _showPermissionDeniedDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Permission Required'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: Text('Settings'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }
}
