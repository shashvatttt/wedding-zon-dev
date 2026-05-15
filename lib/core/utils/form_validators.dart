import 'package:flutter/services.dart';

class FormValidators {
  static String? validateName(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Name'} is required';
    }
    if (value.trim().length < 2) {
      return '${fieldName ?? 'Name'} must be at least 2 characters';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return '${fieldName ?? 'Name'} can only contain letters';
    }
    return null;
  }

  static String? validateEmail(String? value, {bool required = true}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'Email is required' : null;
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? validatePhone(String? value, {bool required = true}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'Phone number is required' : null;
    }
    final cleaned = value.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.length != 10) {
      return 'Phone number must be 10 digits';
    }
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(cleaned)) {
      return 'Enter a valid Indian phone number';
    }
    return null;
  }

  static String? validateAadhaar(String? value, {bool required = false}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'Aadhaar number is required' : null;
    }
    final cleaned = value.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.length != 12) {
      return 'Aadhaar must be 12 digits';
    }
    return null;
  }

  static String? validateGST(String? value, {bool required = false}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'GST number is required' : null;
    }

    if (!RegExp(
      r'^\d{2}[A-Z]{5}\d{4}[A-Z]{1}[A-Z\d]{1}[Z]{1}[A-Z\d]{1}$',
    ).hasMatch(value.toUpperCase())) {
      return 'Enter a valid GST number';
    }
    return null;
  }

  static String? validatePincode(String? value, {bool required = false}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'Pincode is required' : null;
    }
    if (!RegExp(r'^\d{6}$').hasMatch(value)) {
      return 'Pincode must be 6 digits';
    }
    return null;
  }

  static String? validateNumber(
    String? value, {
    bool required = false,
    int? min,
    int? max,
    String? fieldName,
  }) {
    if (value == null || value.trim().isEmpty) {
      return required ? '${fieldName ?? 'This field'} is required' : null;
    }
    final number = int.tryParse(value);
    if (number == null) {
      return 'Enter a valid number';
    }
    if (min != null && number < min) {
      return '${fieldName ?? 'Value'} must be at least $min';
    }
    if (max != null && number > max) {
      return '${fieldName ?? 'Value'} must be at most $max';
    }
    return null;
  }

  static String? validatePrice(String? value, {bool required = false}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'Price is required' : null;
    }
    final price = double.tryParse(value);
    if (price == null) {
      return 'Enter a valid price';
    }
    if (price < 0) {
      return 'Price cannot be negative';
    }
    return null;
  }

  static String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }

  static String? validateMinLength(
    String? value,
    int minLength, {
    String? fieldName,
  }) {
    if (value == null || value.isEmpty) {
      return null;
    }
    if (value.length < minLength) {
      return '${fieldName ?? 'This field'} must be at least $minLength characters';
    }
    return null;
  }

  static String? validateMaxLength(
    String? value,
    int maxLength, {
    String? fieldName,
  }) {
    if (value == null || value.isEmpty) {
      return null;
    }
    if (value.length > maxLength) {
      return '${fieldName ?? 'This field'} must be at most $maxLength characters';
    }
    return null;
  }

  static String? validateUrl(String? value, {bool required = false}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'URL is required' : null;
    }
    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );
    if (!urlRegex.hasMatch(value)) {
      return 'Enter a valid URL';
    }
    return null;
  }

  static String? validateAge(DateTime? dob, {int? minAge, int? maxAge}) {
    if (dob == null) {
      return 'Date of birth is required';
    }
    final age = DateTime.now().difference(dob).inDays ~/ 365;
    if (minAge != null && age < minAge) {
      return 'Must be at least $minAge years old';
    }
    if (maxAge != null && age > maxAge) {
      return 'Must be at most $maxAge years old';
    }
    return null;
  }
}

class FormFormatters {
  static List<TextInputFormatter> phone() => [
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(10),
  ];

  static List<TextInputFormatter> aadhaar() => [
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(12),
  ];

  static List<TextInputFormatter> pincode() => [
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(6),
  ];

  static List<TextInputFormatter> name() => [
    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
  ];

  static List<TextInputFormatter> numbersOnly() => [
    FilteringTextInputFormatter.digitsOnly,
  ];

  static List<TextInputFormatter> decimal({int? decimalPlaces}) => [
    FilteringTextInputFormatter.allow(
      RegExp(r'^\d*\.?\d{0,' + (decimalPlaces?.toString() ?? '2') + r'}'),
    ),
  ];

  static List<TextInputFormatter> gst() => [
    LengthLimitingTextInputFormatter(15),
    TextInputFormatter.withFunction((oldValue, newValue) {
      return newValue.copyWith(text: newValue.text.toUpperCase());
    }),
    FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
  ];

  static List<TextInputFormatter> username() => [
    FilteringTextInputFormatter.allow(RegExp(r'[a-z0-9_]')),
    TextInputFormatter.withFunction((oldValue, newValue) {
      return newValue.copyWith(text: newValue.text.toLowerCase());
    }),
  ];
}
