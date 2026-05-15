import 'package:flutter/material.dart';

mixin FormValidationMixin<T extends StatefulWidget> on State<T> {
  bool _isFormValid = false;

  GlobalKey<FormState> get formKey;

  bool get isFormValid => _isFormValid;

  void validateForm() {
    final isValid = formKey.currentState?.validate() ?? false;
    if (isValid != _isFormValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  void setupValidationListeners(List<TextEditingController> controllers) {
    for (final controller in controllers) {
      controller.addListener(validateForm);
    }
  }

  void removeValidationListeners(List<TextEditingController> controllers) {
    for (final controller in controllers) {
      controller.removeListener(validateForm);
    }
  }

  bool checkFormValidity() {
    return formKey.currentState?.validate() ?? false;
  }
}
