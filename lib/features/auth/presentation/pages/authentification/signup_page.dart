import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tourisme_app_flutter/config/routes/app_routes.dart';
import 'package:tourisme_app_flutter/features/auth/presentation/pages/verification/otp_verification_page.dart';
import 'package:tourisme_app_flutter/core/services/localization_service.dart';
import 'package:tourisme_app_flutter/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:tourisme_app_flutter/features/auth/domain/entities/auth_entities.dart';
import 'package:tourisme_app_flutter/features/auth/domain/usecases/auth_usecases.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  // Validation des champs
  final _formKey = GlobalKey<FormState>();
  String? _usernameError;
  String? _emailError;
  String? _firstNameError;
  String? _lastNameError;
  String? _passwordError;
  String? _confirmPasswordError;

  _DeviceInfo _getDeviceInfo(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double screenWidth = mediaQuery.size.width;
    final double screenHeight = mediaQuery.size.height;
    final double shortSide = mediaQuery.size.shortestSide;
    final double longestSide = mediaQuery.size.longestSide;
    final double aspectRatio = longestSide / shortSide;
    final bool isLandscape = screenWidth > screenHeight;
    final double devicePixelRatio = mediaQuery.devicePixelRatio;
    final double textScaleFactor = mediaQuery.textScaleFactor.clamp(0.8, 1.3);

    if (aspectRatio > 2.8) {
      return _DeviceInfo(
        type: _DeviceType.ultraWide,
        scaleFactor: (shortSide / 400).clamp(0.7, 1.5),
        textScaleFactor: textScaleFactor,
        isHighDensity: devicePixelRatio > 2.5,
        isLandscape: isLandscape,
      );
    } else if (shortSide >= 768) {
      return _DeviceInfo(
        type: _DeviceType.largeTablet,
        scaleFactor: (shortSide / 768).clamp(0.9, 1.4),
        textScaleFactor: textScaleFactor,
        isHighDensity: devicePixelRatio > 2.0,
        isLandscape: isLandscape,
      );
    } else if (shortSide >= 600) {
      return _DeviceInfo(
        type: _DeviceType.tablet,
        scaleFactor: (shortSide / 600).clamp(0.8, 1.3),
        textScaleFactor: textScaleFactor,
        isHighDensity: devicePixelRatio > 2.0,
        isLandscape: isLandscape,
      );
    } else if (shortSide >= 414) {
      return _DeviceInfo(
        type: _DeviceType.largePhone,
        scaleFactor: (shortSide / 414).clamp(0.9, 1.2),
        textScaleFactor: textScaleFactor,
        isHighDensity: devicePixelRatio > 2.5,
        isLandscape: isLandscape,
      );
    } else if (shortSide >= 375) {
      return _DeviceInfo(
        type: _DeviceType.phone,
        scaleFactor: (shortSide / 375).clamp(0.8, 1.1),
        textScaleFactor: textScaleFactor,
        isHighDensity: devicePixelRatio > 2.0,
        isLandscape: isLandscape,
      );
    } else {
      return _DeviceInfo(
        type: _DeviceType.smallPhone,
        scaleFactor: (shortSide / 320).clamp(0.7, 1.0),
        textScaleFactor: textScaleFactor,
        isHighDensity: devicePixelRatio > 1.5,
        isLandscape: isLandscape,
      );
    }
  }

  _ResponsiveDimensions _getDimensions(BuildContext context) {
    final deviceInfo = _getDeviceInfo(context);
    final double scale = deviceInfo.scaleFactor;
    final double textScale = deviceInfo.textScaleFactor;
    final bool isHighDensity = deviceInfo.isHighDensity;
    final bool isLandscape = deviceInfo.isLandscape;
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    final double densityAdjustment = isHighDensity ? 1.1 : 1.0;
    final double landscapeAdjustment = isLandscape ? 0.8 : 1.0;

    switch (deviceInfo.type) {
      case _DeviceType.smallPhone:
        return _ResponsiveDimensions(
          horizontalPadding: 20 * scale * densityAdjustment * landscapeAdjustment,
          verticalPadding: 16 * scale * densityAdjustment * landscapeAdjustment,
          spacing: 16 * scale * densityAdjustment * landscapeAdjustment,
          maxWidth: mediaQuery.size.width * 0.95,
          titleFontSize: 24 * scale * textScale * densityAdjustment,
          subtitleFontSize: 16 * scale * textScale * densityAdjustment,
          inputFontSize: 16 * scale * textScale * densityAdjustment,
          labelFontSize: 14 * scale * textScale * densityAdjustment,
          buttonFontSize: 16 * scale * textScale * densityAdjustment,
          inputHeight: 56 * scale * densityAdjustment,
          buttonHeight: 48 * scale * densityAdjustment,
          borderRadius: 12 * scale * densityAdjustment,
          elevation: 4 * scale * densityAdjustment,
          iconSize: 32 * scale * densityAdjustment,
        );
      case _DeviceType.phone:
        return _ResponsiveDimensions(
          horizontalPadding: 24 * scale * densityAdjustment * landscapeAdjustment,
          verticalPadding: 20 * scale * densityAdjustment * landscapeAdjustment,
          spacing: 20 * scale * densityAdjustment * landscapeAdjustment,
          maxWidth: mediaQuery.size.width * 0.9,
          titleFontSize: 28 * scale * textScale * densityAdjustment,
          subtitleFontSize: 18 * scale * textScale * densityAdjustment,
          inputFontSize: 16 * scale * textScale * densityAdjustment,
          labelFontSize: 14 * scale * textScale * densityAdjustment,
          buttonFontSize: 18 * scale * textScale * densityAdjustment,
          inputHeight: 56 * scale * densityAdjustment,
          buttonHeight: 52 * scale * densityAdjustment,
          borderRadius: 12 * scale * densityAdjustment,
          elevation: 6 * scale * densityAdjustment,
          iconSize: 36 * scale * densityAdjustment,
        );
      case _DeviceType.largePhone:
        return _ResponsiveDimensions(
          horizontalPadding: 28 * scale * densityAdjustment * landscapeAdjustment,
          verticalPadding: 24 * scale * densityAdjustment * landscapeAdjustment,
          spacing: 24 * scale * densityAdjustment * landscapeAdjustment,
          maxWidth: mediaQuery.size.width * 0.85,
          titleFontSize: 32 * scale * textScale * densityAdjustment,
          subtitleFontSize: 20 * scale * textScale * densityAdjustment,
          inputFontSize: 18 * scale * textScale * densityAdjustment,
          labelFontSize: 16 * scale * textScale * densityAdjustment,
          buttonFontSize: 20 * scale * textScale * densityAdjustment,
          inputHeight: 60 * scale * densityAdjustment,
          buttonHeight: 56 * scale * densityAdjustment,
          borderRadius: 16 * scale * densityAdjustment,
          elevation: 8 * scale * densityAdjustment,
          iconSize: 40 * scale * densityAdjustment,
        );
      case _DeviceType.tablet:
        return _ResponsiveDimensions(
          horizontalPadding: 32 * scale * densityAdjustment * landscapeAdjustment,
          verticalPadding: 28 * scale * densityAdjustment * landscapeAdjustment,
          spacing: 28 * scale * densityAdjustment * landscapeAdjustment,
          maxWidth: 600 * scale * densityAdjustment,
          titleFontSize: 36 * scale * textScale * densityAdjustment,
          subtitleFontSize: 22 * scale * textScale * densityAdjustment,
          inputFontSize: 20 * scale * textScale * densityAdjustment,
          labelFontSize: 18 * scale * textScale * densityAdjustment,
          buttonFontSize: 22 * scale * textScale * densityAdjustment,
          inputHeight: 64 * scale * densityAdjustment,
          buttonHeight: 60 * scale * densityAdjustment,
          borderRadius: 20 * scale * densityAdjustment,
          elevation: 10 * scale * densityAdjustment,
          iconSize: 44 * scale * densityAdjustment,
        );
      case _DeviceType.largeTablet:
        return _ResponsiveDimensions(
          horizontalPadding: 40 * scale * densityAdjustment * landscapeAdjustment,
          verticalPadding: 32 * scale * densityAdjustment * landscapeAdjustment,
          spacing: 32 * scale * densityAdjustment * landscapeAdjustment,
          maxWidth: 700 * scale * densityAdjustment,
          titleFontSize: 40 * scale * textScale * densityAdjustment,
          subtitleFontSize: 24 * scale * textScale * densityAdjustment,
          inputFontSize: 22 * scale * textScale * densityAdjustment,
          labelFontSize: 20 * scale * textScale * densityAdjustment,
          buttonFontSize: 24 * scale * textScale * densityAdjustment,
          inputHeight: 68 * scale * densityAdjustment,
          buttonHeight: 64 * scale * densityAdjustment,
          borderRadius: 24 * scale * densityAdjustment,
          elevation: 12 * scale * densityAdjustment,
          iconSize: 48 * scale * densityAdjustment,
        );
      case _DeviceType.ultraWide:
        return _ResponsiveDimensions(
          horizontalPadding: 48 * scale * densityAdjustment * landscapeAdjustment,
          verticalPadding: 40 * scale * densityAdjustment * landscapeAdjustment,
          spacing: 40 * scale * densityAdjustment * landscapeAdjustment,
          maxWidth: 800 * scale * densityAdjustment,
          titleFontSize: 44 * scale * textScale * densityAdjustment,
          subtitleFontSize: 26 * scale * textScale * densityAdjustment,
          inputFontSize: 24 * scale * textScale * densityAdjustment,
          labelFontSize: 22 * scale * textScale * densityAdjustment,
          buttonFontSize: 26 * scale * textScale * densityAdjustment,
          inputHeight: 72 * scale * densityAdjustment,
          buttonHeight: 68 * scale * densityAdjustment,
          borderRadius: 28 * scale * densityAdjustment,
          elevation: 14 * scale * densityAdjustment,
          iconSize: 52 * scale * densityAdjustment,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dimensions = _getDimensions(context);
    final deviceInfo = _getDeviceInfo(context);
    final bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          setState(() => _isLoading = false);
          // Inscription réussie, naviguer vers la page principale
          Navigator.of(context).pushReplacementNamed(AppRoutes.home);
        } else if (state is AuthNewUserNeedsPreferences) {
          setState(() => _isLoading = false);
          // Nouvel utilisateur: rediriger vers le questionnaire de préférences
          Navigator.of(context).pushReplacementNamed(AppRoutes.newUserPreferences);
        } else if (state is AuthFailure) {
          setState(() => _isLoading = false);
          // Afficher l'erreur avec un style amélioré
          _showErrorDialog(state.message);
        } else if (state is AuthLoading) {
          setState(() => _isLoading = true);
        }
      },
      child: Scaffold(
        backgroundColor: isDarkMode ? Theme.of(context).scaffoldBackgroundColor : Colors.white,
        appBar: AppBar(
          backgroundColor: isDarkMode ? Theme.of(context).scaffoldBackgroundColor : Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              isIOS ? Icons.arrow_back_ios_rounded : Icons.arrow_back,
              color: isDarkMode ? Colors.white : Colors.black,
              size: dimensions.labelFontSize * 1.5,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: dimensions.maxWidth,
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: dimensions.horizontalPadding,
                  vertical: dimensions.verticalPadding,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      // Icône principale
                      Container(
                        padding: EdgeInsets.all(dimensions.spacing),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.1),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blueAccent.withOpacity(0.2),
                              blurRadius: dimensions.elevation,
                              offset: Offset(0, dimensions.elevation / 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.person_add_alt_1_rounded,
                          size: dimensions.iconSize,
                          color: Colors.blueAccent,
                        ),
                      ),
                      SizedBox(height: dimensions.spacing),

                      // Titre
                      Text(
                        LocalizationService().translate('create_account'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: dimensions.titleFontSize,
                          fontWeight: isIOS ? FontWeight.w600 : FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.blueGrey[800],
                          letterSpacing: isIOS ? -0.5 : 0,
                        ),
                      ),
                      SizedBox(height: dimensions.spacing * 1.5),

                      // Champ nom d'utilisateur
                      _buildTextField(
                        controller: _usernameController,
                        labelText: LocalizationService().translate('username_label'),
                        hintText: LocalizationService().translate('enter_username'),
                        prefixIcon: Icons.person,
                        dimensions: dimensions,
                        isDarkMode: isDarkMode,
                        isIOS: isIOS,
                        errorText: _usernameError,
                        validator: _validateUsername,
                      ),
                      SizedBox(height: dimensions.spacing),

                      // Champ prénom
                      _buildTextField(
                        controller: _firstNameController,
                        labelText: LocalizationService().translate('first_name'),
                        hintText: LocalizationService().translate('enter_first_name'),
                        prefixIcon: Icons.person_outline,
                        dimensions: dimensions,
                        isDarkMode: isDarkMode,
                        isIOS: isIOS,
                        errorText: _firstNameError,
                        validator: _validateFirstName,
                      ),
                      SizedBox(height: dimensions.spacing),

                      // Champ nom
                      _buildTextField(
                        controller: _lastNameController,
                        labelText: LocalizationService().translate('last_name'),
                        hintText: LocalizationService().translate('enter_last_name'),
                        prefixIcon: Icons.person_outline,
                        dimensions: dimensions,
                        isDarkMode: isDarkMode,
                        isIOS: isIOS,
                        errorText: _lastNameError,
                        validator: _validateLastName,
                      ),
                      SizedBox(height: dimensions.spacing),

                      // Champ email
                      _buildTextField(
                        controller: _emailController,
                        labelText: LocalizationService().translate('email_label'),
                        hintText: LocalizationService().translate('forgot_password_email_hint'),
                        prefixIcon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        dimensions: dimensions,
                        isDarkMode: isDarkMode,
                        isIOS: isIOS,
                        errorText: _emailError,
                        validator: _validateEmail,
                      ),
                      SizedBox(height: dimensions.spacing),

                      // Champ mot de passe
                      _buildTextField(
                        controller: _passwordController,
                        labelText: LocalizationService().translate('password_label'),
                        hintText: LocalizationService().translate('password_hint'),
                        prefixIcon: Icons.lock,
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? (isIOS ? Icons.visibility_off_rounded : Icons.visibility_off)
                                : (isIOS ? Icons.visibility_rounded : Icons.visibility),
                            size: dimensions.labelFontSize * 1.3,
                            color: isDarkMode ? Colors.white54 : Colors.grey[600],
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        dimensions: dimensions,
                        isDarkMode: isDarkMode,
                        isIOS: isIOS,
                        errorText: _passwordError,
                        validator: _validatePassword,
                      ),
                      SizedBox(height: dimensions.spacing),

                      // Champ confirmation mot de passe
                      _buildTextField(
                        controller: _confirmPasswordController,
                        labelText: LocalizationService().translate('confirm_password_label'),
                        hintText: LocalizationService().translate('confirm_password_hint'),
                        prefixIcon: Icons.lock_reset,
                        obscureText: _obscureConfirmPassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? (isIOS ? Icons.visibility_off_rounded : Icons.visibility_off)
                                : (isIOS ? Icons.visibility_rounded : Icons.visibility),
                            size: dimensions.labelFontSize * 1.3,
                            color: isDarkMode ? Colors.white54 : Colors.grey[600],
                          ),
                          onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                        ),
                        dimensions: dimensions,
                        isDarkMode: isDarkMode,
                        isIOS: isIOS,
                        errorText: _confirmPasswordError,
                        validator: _validateConfirmPassword,
                      ),
                      SizedBox(height: dimensions.spacing * 1.5),

                      // Bouton d'inscription
                      Container(
                        height: dimensions.buttonHeight,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(dimensions.borderRadius),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blueAccent.withOpacity(0.3),
                              blurRadius: dimensions.elevation,
                              offset: Offset(0, dimensions.elevation / 2),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleSignUp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(dimensions.borderRadius),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? SizedBox(
                            height: dimensions.buttonFontSize,
                            width: dimensions.buttonFontSize,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                              : Text(
                            LocalizationService().translate('sign_up'),
                            style: TextStyle(
                              fontSize: dimensions.buttonFontSize,
                              fontWeight: isIOS ? FontWeight.w600 : FontWeight.bold,
                              letterSpacing: isIOS ? 0.5 : 0,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: dimensions.spacing),

                      // Lien de connexion
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: <Widget>[
                          Text(
                            LocalizationService().translate('already_account'),
                            style: TextStyle(
                              fontSize: dimensions.labelFontSize,
                              color: isDarkMode ? Colors.white70 : Colors.grey[700],
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Text(
                              LocalizationService().translate('log_in'),
                              style: TextStyle(
                                fontSize: dimensions.labelFontSize,
                                color: Colors.blueAccent,
                                fontWeight: isIOS ? FontWeight.w600 : FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData prefixIcon,
    required _ResponsiveDimensions dimensions,
    required bool isDarkMode,
    required bool isIOS,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? errorText,
    String? Function(String?)? validator,
  }) {
    return Container(
      height: dimensions.inputHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(dimensions.borderRadius),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: dimensions.elevation / 2,
            offset: Offset(0, dimensions.elevation / 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        style: TextStyle(
          fontSize: dimensions.inputFontSize,
          color: isDarkMode ? Colors.white : Colors.black87,
        ),
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          errorText: errorText,
          labelStyle: TextStyle(
            fontSize: dimensions.labelFontSize,
            color: isDarkMode ? Colors.white70 : Colors.grey[600],
            fontWeight: isIOS ? FontWeight.w400 : FontWeight.w500,
          ),
          hintStyle: TextStyle(
            fontSize: dimensions.inputFontSize * 0.9,
            color: isDarkMode ? Colors.white38 : Colors.grey[400],
          ),
          errorStyle: TextStyle(
            fontSize: dimensions.labelFontSize * 0.9,
            color: Colors.red,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(dimensions.borderRadius),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: isDarkMode
              ? Colors.grey[800]?.withOpacity(0.5)
              : Colors.grey[100],
          prefixIcon: Icon(
            prefixIcon,
            color: isDarkMode ? Colors.white54 : Colors.grey[600],
            size: dimensions.labelFontSize * 1.5,
          ),
          suffixIcon: suffixIcon,
        ),
        onChanged: (value) {
          // Effacer l'erreur quand l'utilisateur commence à taper
          setState(() {
            if (controller == _usernameController) _usernameError = null;
            if (controller == _emailController) _emailError = null;
            if (controller == _firstNameController) _firstNameError = null;
            if (controller == _lastNameController) _lastNameError = null;
            if (controller == _passwordController) _passwordError = null;
            if (controller == _confirmPasswordController) _confirmPasswordError = null;
          });
        },
      ),
    );
  }

  // Validateurs
  String? _validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Veuillez saisir un nom d\'utilisateur';
    }
    if (value.trim().length < 3) {
      return 'Le nom d\'utilisateur doit contenir au moins 3 caractères';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Veuillez saisir votre adresse email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
      return 'Veuillez saisir une adresse email valide';
    }
    return null;
  }

  String? _validateFirstName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Veuillez saisir votre prénom';
    }
    if (value.trim().length < 2) {
      return 'Le prénom doit contenir au moins 2 caractères';
    }
    return null;
  }

  String? _validateLastName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Veuillez saisir votre nom';
    }
    if (value.trim().length < 2) {
      return 'Le nom doit contenir au moins 2 caractères';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez saisir un mot de passe';
    }
    if (value.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez confirmer votre mot de passe';
    }
    if (value != _passwordController.text) {
      return 'Les mots de passe ne correspondent pas';
    }
    return null;
  }

  void _handleSignUp() {
    // Réinitialiser les erreurs
    setState(() {
      _usernameError = null;
      _emailError = null;
      _firstNameError = null;
      _lastNameError = null;
      _passwordError = null;
      _confirmPasswordError = null;
    });

    // Validation du formulaire
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Créer les paramètres d'inscription selon le backend
    final registerParams = RegisterParams(
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
    );

    // Déclencher l'événement d'inscription via le BLoC
    context.read<AuthBloc>().add(
      RegisterRequested(registerParams),
    );
  }

  /// Affiche une boîte de dialogue d'erreur améliorée
  void _showErrorDialog(String errorMessage) {
    final dimensions = _getDimensions(context);
    final deviceInfo = _getDeviceInfo(context);
    final bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(dimensions.borderRadius),
          ),
          backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
          title: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red,
                size: dimensions.iconSize * 0.8,
              ),
              SizedBox(width: dimensions.spacing * 0.5),
              Text(
                'Erreur d\'inscription',
                style: TextStyle(
                  fontSize: dimensions.titleFontSize * 0.8,
                  fontWeight: isIOS ? FontWeight.w600 : FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          content: Text(
            errorMessage,
            style: TextStyle(
              fontSize: dimensions.inputFontSize * 0.9,
              color: isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'OK',
                style: TextStyle(
                  fontSize: dimensions.buttonFontSize * 0.9,
                  color: Colors.blueAccent,
                  fontWeight: isIOS ? FontWeight.w600 : FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}

enum _DeviceType {
  smallPhone,
  phone,
  largePhone,
  tablet,
  largeTablet,
  ultraWide
}

class _DeviceInfo {
  final _DeviceType type;
  final double scaleFactor;
  final double textScaleFactor;
  final bool isHighDensity;
  final bool isLandscape;

  _DeviceInfo({
    required this.type,
    required this.scaleFactor,
    required this.textScaleFactor,
    required this.isHighDensity,
    required this.isLandscape,
  });
}

class _ResponsiveDimensions {
  final double horizontalPadding;
  final double verticalPadding;
  final double iconSize;
  final double titleFontSize;
  final double subtitleFontSize;
  final double inputHeight;
  final double inputFontSize;
  final double buttonHeight;
  final double buttonFontSize;
  final double labelFontSize;
  final double borderRadius;
  final double spacing;
  final double maxWidth;
  final double elevation;

  _ResponsiveDimensions({
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.iconSize,
    required this.titleFontSize,
    required this.subtitleFontSize,
    required this.inputHeight,
    required this.inputFontSize,
    required this.buttonHeight,
    required this.buttonFontSize,
    required this.labelFontSize,
    required this.borderRadius,
    required this.spacing,
    required this.maxWidth,
    required this.elevation,
  });
}