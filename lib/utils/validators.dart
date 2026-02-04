class Validators {
  static String? validateNotEmpty(String? value) {
    // Check if value is empty
    if (value == null || value.isEmpty) {
      return 'Please enter something valid';
    }

    // No issues found
    return null;
  }

  static String? validateName(String? value) {
    // Check if name is empty
    if (value == null || value.isEmpty) {
      return 'Please enter your full name';
    }

    // Remove trailing spaces
    value = value.trim();

    // Check if name is in correct format
    final nameRegex = RegExp(r'^(?=.{3,25}$)[A-Za-z]+(?: [A-Za-z]+)*$');
    if (!nameRegex.hasMatch(value)) {
      return 'Name can only contain 3 to 25 characters, including letters and spaces';
    }

    // No issues found
    return null;
  }

  static String? validateUsername(String? value) {
    // Check if username is empty
    if (value == null || value.isEmpty) {
      return 'Please enter a username';
    }

    // Remove trailing spaces
    value = value.trim();

    // Check if username is in correct format
    final usernameRegex = RegExp(r'^[a-z0-9_-]{3,20}$');
    if (!usernameRegex.hasMatch(value)) {
      return 'Username can only contain 3 to 20 characters, including lowercase letters, numbers, "-" and "_"';
    }

    // No issues found
    return null;
  }

  static String? validateEmail(String? value) {
    // Check if email is empty
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }

    // Remove trailing spaces
    value = value.trim();

    // Check if email is in correct format
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }

    // No issues found
    return null;
  }

  static String? validatePassword(String? value) {
    // Check if password is empty
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }

    // Check if password is in correct format
    if (value.length < 6) {
      return 'Your password must be at least 6 characters long';
    }

    // No issues found
    return null;
  }

  static String? validateConfirmPassword(String? value, String? password) {
    // Check if confirm password is empty
    if (validatePassword(value) != null) {
      return validatePassword(value);
    }

    // Check if confirm password is the same as password
    if (value != password) {
      return 'Passwords do not match';
    }

    // No issues found
    return null;
  }
}
