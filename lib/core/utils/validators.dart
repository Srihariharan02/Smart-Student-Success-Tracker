class Validators {
  Validators._();

  static String? requiredField(String? value, {String message = 'This field is required'}) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? marks(String? value, {num max = 100}) {
    if (value == null || value.trim().isEmpty) {
      return 'Marks required';
    }
    final numVal = num.tryParse(value);
    if (numVal == null) return 'Must be a number';
    if (numVal < 0 || numVal > max) return 'Must be 0 - $max';
    return null;
  }
}
