class Validators {
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your full name';
    }

    return null;
  }

  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a username';
    }

    final usernameRegex = RegExp(r'^[a-z0-9_-]{3,20}$');

    if (!usernameRegex.hasMatch(value)) {
      return 'Username can only contain 3 to 20 characters, including lowercase letters, numbers, "-" and "_"';
    }

    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }

    if (value.length < 6) {
      return 'Your password must be at least 6 characters long';
    }

    return null;
  }

  static String? validateConfirmPassword(String? value, String? password) {
    if (validatePassword(value) != null) {
      return validatePassword(value);
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }
}
