import '../constants/constants.dart';
class Validators {

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(AppConstants.emailPattern);
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }


  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < AppConstants.minPasswordLength) {
      return 'Password must be at least ${AppConstants.minPasswordLength} characters';
    }


    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }


    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }


    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    return null;
  }


  static String? validateConfirmPassword(String? value, String? originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != originalPassword) {
      return 'Passwords do not match';
    }

    return null;
  }


  static String? validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Full name is required';
    }

    if (value.trim().length < 2) {
      return 'Full name must be at least 2 characters';
    }


    if (!value.trim().contains(' ')) {
      return 'Please enter your full name (first and last name)';
    }


    final nameRegex = RegExp(r"^[a-zA-ZÀ-ÿ\s\-']+$");
    if (!nameRegex.hasMatch(value)) {
      return 'Full name can only contain letters, spaces, hyphens, and apostrophes';
    }

    return null;
  }


  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    final phoneRegex = RegExp(AppConstants.phonePattern);
    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid Moroccan phone number';
    }

    return null;
  }


  static String? validateOTP(String? value) {
    if (value == null || value.isEmpty) {
      return 'OTP is required';
    }

    if (value.length != AppConstants.otpLength) {
      return 'OTP must be ${AppConstants.otpLength} digits';
    }

    if (!RegExp(r'''^[0-9]+
    ''').hasMatch(value)) {
      return 'OTP can only contain numbers';
    }

    return null;
  }


  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return 'Age is required';
    }

    final age = int.tryParse(value);
    if (age == null) {
      return 'Please enter a valid age';
    }

    if (age < 16) {
      return 'You must be at least 16 years old';
    }

    if (age > 120) {
      return 'Please enter a valid age';
    }

    return null;
  }


  static String? validateBudget(String? value) {
    if (value == null || value.isEmpty) {
      return 'Budget is required';
    }

    final budget = double.tryParse(value);
    if (budget == null) {
      return 'Please enter a valid budget amount';
    }

    if (budget <= 0) {
      return 'Budget must be greater than 0';
    }

    return null;
  }

  static String? validateURL(String? value) {
    if (value == null || value.isEmpty) {
      return null; // URL is optional in most cases
    }

    final urlRegex = RegExp(
        r'''^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)'''

    );

    if (!urlRegex.hasMatch(value)) {
      return 'Please enter a valid URL';
    }

    return null;
  }


  static String? validateDate(DateTime? value) {
    if (value == null) {
      return 'Date is required';
    }

    final now = DateTime.now();
    if (value.isBefore(now)) {
      return 'Date cannot be in the past';
    }

    return null;
  }


  static String? validateTripDuration(int? days) {
    if (days == null || days <= 0) {
      return 'Please select a valid trip duration';
    }

    if (days > 365) {
      return 'Trip duration cannot exceed 365 days';
    }

    return null;
  }

  static String? validateFileSize(int? sizeInBytes) {
    if (sizeInBytes == null) {
      return 'Invalid file';
    }

    if (sizeInBytes > AppConstants.maxFileUploadSize) {
      final maxSizeMB = AppConstants.maxFileUploadSize / (1024 * 1024);
      return 'File size cannot exceed ${maxSizeMB.toStringAsFixed(0)}MB';
    }

    return null;
  }


  static String? validateMultipleSelection(List<dynamic>? values, String fieldName, {int minSelection = 1}) {
    if (values == null || values.isEmpty) {
      return 'Please select at least one $fieldName';
    }

    if (values.length < minSelection) {
      return 'Please select at least $minSelection $fieldName${minSelection > 1 ? 's' : ''}';
    }

    return null;
  }

  static String cleanInput(String input) {
    return input.trim().replaceAll(RegExp(r'\s+'), ' ');
  }


  static String formatPhoneNumber(String phone) {

    String cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');


    if (cleaned.length == 9) {
      cleaned = '212$cleaned';
    } else if (cleaned.startsWith('0')) {
      cleaned = '212${cleaned.substring(1)}';
    }


    if (cleaned.length == 12 && cleaned.startsWith('212')) {
      return '+${cleaned.substring(0, 3)} ${cleaned.substring(3, 4)}${cleaned.substring(4, 6)} ${cleaned.substring(6, 8)} ${cleaned.substring(8, 10)} ${cleaned.substring(10, 12)}';
    }

    return phone;
  }


  static bool isValidEmail(String email) {
    return RegExp(AppConstants.emailPattern).hasMatch(email);
  }


  static bool isStrongPassword(String password) {
    return RegExp(AppConstants.passwordPattern).hasMatch(password);
  }


  static PasswordStrength getPasswordStrength(String password) {
    if (password.isEmpty) return PasswordStrength.empty;
    if (password.length < 6) return PasswordStrength.weak;

    int score = 0;


    if (password.length >= 8) score++;
    if (password.length >= 12) score++;


    if (password.contains(RegExp(r'[a-z]'))) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;

    if (score <= 2) return PasswordStrength.weak;
    if (score <= 4) return PasswordStrength.medium;
    return PasswordStrength.strong;
  }
}

enum PasswordStrength {
  empty,
  weak,
  medium,
  strong,
}