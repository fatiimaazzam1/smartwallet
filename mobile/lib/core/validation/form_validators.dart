abstract final class FormValidators {
  FormValidators._();

  static String? requiredField(
    String? value, {
    String fieldName = 'This field',
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    return null;
  }

  static String? name(String? value, {required String fieldName}) {
    final requiredError = requiredField(value, fieldName: fieldName);

    if (requiredError != null) {
      return requiredError;
    }

    if (value!.trim().length < 2) {
      return '$fieldName must contain at least 2 characters';
    }

    return null;
  }

  static String? email(String? value) {
    final requiredError = requiredField(value, fieldName: 'Email');

    if (requiredError != null) {
      return requiredError;
    }

    final email = value!.trim();

    if (email.length > 150) {
      return 'Email must not exceed 150 characters';
    }

    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (!emailPattern.hasMatch(email)) {
      return 'Enter a valid email address';
    }

    return null;
  }

  static String? password(String? value) {
    final requiredError = requiredField(value, fieldName: 'Password');

    if (requiredError != null) {
      return requiredError;
    }

    final password = value!;

    if (password.length < 8 || password.length > 72) {
      return 'Password must be between 8 and 72 characters';
    }

    if (password.contains(RegExp(r'\s'))) {
      return 'Password must not contain spaces';
    }

    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain a lowercase letter';
    }

    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain an uppercase letter';
    }

    if (!password.contains(RegExp(r'\d'))) {
      return 'Password must contain a number';
    }

    if (!password.contains(RegExp(r'[^A-Za-z0-9]'))) {
      return 'Password must contain a special character';
    }

    return null;
  }

  static String? confirmPassword(String? value, String password) {
    final requiredError = requiredField(
      value,
      fieldName: 'Password confirmation',
    );

    if (requiredError != null) {
      return requiredError;
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }
}
