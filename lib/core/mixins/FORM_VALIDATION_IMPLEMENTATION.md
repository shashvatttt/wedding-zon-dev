# Form Validation Implementation Guide

## Overview
This guide explains how to implement real-time form validation that keeps the Save/Next button disabled until all required fields are filled and valid.

## Implementation Steps

### 1. Add the Mixin to Your Screen State

```dart
import 'package:weddingzon/core/mixins/form_validation_mixin.dart';

class _ProfileBasicDetailsUIState extends State<ProfileBasicDetailsUI> 
    with FormValidationMixin {
  
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  
  @override
  GlobalKey<FormState> get formKey => _formKey;
  
  // ... rest of your code
}
```

### 2. Setup Validation Listeners in initState

```dart
@override
void initState() {
  super.initState();
  
  // Setup validation listeners for all text controllers
  setupValidationListeners([
    _firstNameController,
    _lastNameController,
    _usernameController,
    // ... add all your controllers
  ]);
  
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _initializeData();
    // Validate after data is loaded
    validateForm();
  });
}
```

### 3. Remove Listeners in dispose

```dart
@override
void dispose() {
  removeValidationListeners([
    _firstNameController,
    _lastNameController,
    _usernameController,
    // ... same controllers as in initState
  ]);
  
  _firstNameController.dispose();
  _lastNameController.dispose();
  // ... dispose all controllers
  
  super.dispose();
}
```

### 4. Add Validation Triggers for Dropdowns/Selections

```dart
void _onGenderSelected(String? value) {
  setState(() {
    _selectedGender = value;
  });
  // Trigger validation after state change
  WidgetsBinding.instance.addPostFrameCallback((_) {
    validateForm();
  });
}
```

### 5. Update Button to Use isFormValid

For EditProfileNavigationButtons:
```dart
EditProfileNavigationButtons(
  currentSection: 'basic',
  onSave: isFormValid ? _onNext : null, // Disable if form invalid
)
```

For WzPrimaryButton:
```dart
WzPrimaryButton(
  text: appLoc?.translate('next') ?? 'Next',
  onPressed: isFormValid ? _onNext : null, // Disable if form invalid
  width: double.infinity,
)
```

### 6. Ensure Validators Return Proper Messages

```dart
TextFormField(
  controller: _firstNameController,
  validator: (value) {
    if (value == null || value.trim().isEmpty) {
      return 'First name is required';
    }
    return null; // Return null if valid
  },
  // ... other properties
)
```

## Screens to Update

1. ✅ profile_basic_details_ui.dart
2. ✅ profile_religious_background_ui.dart
3. ✅ profile_location_ui.dart
4. ✅ profile_family_ui.dart
5. ✅ profile_education_ui.dart
6. ✅ profile_lifestyle_ui.dart
7. ✅ profile_habits_ui.dart
8. ✅ profile_property_assets_ui.dart
9. ✅ profile_contact_details_ui.dart
10. ✅ profile_about_me_ui.dart
11. ✅ profile_additional_details_ui.dart
12. ✅ partner_preferences_edit_ui.dart

## Key Points

- The button will be disabled (grayed out) when `isFormValid` is false
- Validation runs automatically when:
  - User types in any text field
  - User selects from dropdown
  - Data is loaded from backend
- No toast/error shown - just visual button state
- Form validators must return `null` for valid fields
- Form validators must return error string for invalid fields

## Testing

1. Open any profile edit screen
2. Clear a required field - button should disable
3. Fill the required field - button should enable
4. Select/deselect dropdowns - button state should update
5. Submit should only work when button is enabled
