import 'package:flutter/material.dart';
import '../repositories/profile_repository.dart';
import '../../../core/models/user_model.dart';
import '../../../core/models/api_response.dart';

class OnboardingProvider extends ChangeNotifier {
  final ProfileRepository _profileRepository;

  OnboardingProvider(this._profileRepository);

  int _currentStep = 0;
  bool _isLoading = false;

  final Map<String, dynamic> _formData = {};

  int get currentStep => _currentStep;
  bool get isLoading => _isLoading;
  Map<String, dynamic> get formData => _formData;

  void updateField(String key, dynamic value) {
    debugPrint('[ONBOARDING_PROVIDER] 🔄 updateField called');
    if (key == 'land_unit') {
      debugPrint(
        '[ONBOARDING_PROVIDER] 🚨 🚨 🚨 land_unit update detected! 🚨 🚨 🚨',
      );
      debugPrint('[ONBOARDING_PROVIDER] Stack trace: ${StackTrace.current}');
    }
    debugPrint('[ONBOARDING_PROVIDER]   - Key: $key');
    debugPrint('[ONBOARDING_PROVIDER]   - Value: $value');

    _formData[key] = value;
    notifyListeners();
  }

  void nextStep() {
    if (_currentStep < 7) {
      _currentStep++;
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  void setStep(int step) {
    _currentStep = step;
    notifyListeners();
  }

  Future<ApiResponse<User>> submitProfile() async {
    _isLoading = true;
    notifyListeners();

    _formData['is_profile_complete'] = true;

    debugPrint('[ONBOARDING] Submitting form data: $_formData');
    debugPrint('[ONBOARDING] 📤 Role being sent: ${_formData['role']}');
    final response = await _profileRepository.registerDetails(_formData);

    if (response.success &&
        _formData['latitude'] != null &&
        _formData['longitude'] != null) {
      debugPrint('[ONBOARDING] Submitting location coordinates...');
      await updateUserLocation(_formData['latitude'], _formData['longitude']);
    }

    _isLoading = false;
    notifyListeners();

    return response;
  }

  Future<void> updateUserLocation(double lat, double lng) async {
    debugPrint('[ONBOARDING] Updating location: $lat, $lng');
    await _profileRepository.updateLocation(lat, lng);
  }

  void prepopulateFromUser(User user) {
    debugPrint(
      '[ONBOARDING_PROVIDER] ========================================',
    );
    debugPrint('[ONBOARDING_PROVIDER] 🔄 prepopulateFromUser - Starting');
    debugPrint('[ONBOARDING_PROVIDER] 📥 User data received:');
    debugPrint('[ONBOARDING_PROVIDER]   - height: ${user.height}');
    debugPrint(
      '[ONBOARDING_PROVIDER]   - maritalStatus: ${user.maritalStatus}',
    );
    debugPrint('[ONBOARDING_PROVIDER]   - motherTongue: ${user.motherTongue}');
    debugPrint('[ONBOARDING_PROVIDER]   - disability: ${user.disability}');
    debugPrint(
      '[ONBOARDING_PROVIDER]   - disabilityDescription: ${user.disabilityDescription}',
    );
    debugPrint('[ONBOARDING_PROVIDER]   - bloodGroup: ${user.bloodGroup}');

    void addIfNotEmpty(String key, String? value) {
      if (value != null && value.trim().isNotEmpty) {
        _formData[key] = value;
        debugPrint('[ONBOARDING_PROVIDER]   ✅ Set $key = $value');
      } else {
        debugPrint('[ONBOARDING_PROVIDER]   ⚠️ Skipped $key (empty or null)');
      }
    }

    addIfNotEmpty('created_for', user.createdFor);
    addIfNotEmpty('username', user.username);
    addIfNotEmpty('email', user.email);
    addIfNotEmpty('phone', user.phone);
    addIfNotEmpty('first_name', user.firstName);
    addIfNotEmpty('last_name', user.lastName);
    if (user.dob != null) {
      _formData['dob'] = user.dob!.toIso8601String();
    }
    addIfNotEmpty('gender', user.gender);
    if (user.height != null) {
      String h = user.height!;
      if (h.contains(' (')) {
        h = h.split(' (')[0];
      }
      addIfNotEmpty('height', h);
    }

    if (user.maritalStatus != null) {
      if (user.maritalStatus is List) {
        if ((user.maritalStatus as List).isNotEmpty) {
          addIfNotEmpty(
            'marital_status',
            (user.maritalStatus as List).first.toString(),
          );
        }
      } else if (user.maritalStatus is String) {
        addIfNotEmpty('marital_status', user.maritalStatus);
      }
    }

    addIfNotEmpty('mother_tongue', user.motherTongue);
    addIfNotEmpty('disability', user.disability);
    addIfNotEmpty('disability_description', user.disabilityDescription);
    addIfNotEmpty('aadhar_number', user.aadharNumber);
    addIfNotEmpty('blood_group', user.bloodGroup);
    addIfNotEmpty('about_me', user.aboutMe);

    addIfNotEmpty('phone', user.phone);
    addIfNotEmpty('email', user.email);

    addIfNotEmpty('city', user.city);
    addIfNotEmpty('state', user.state);
    addIfNotEmpty('country', user.country);

    if (user.latitude != null) _formData['latitude'] = user.latitude;
    if (user.longitude != null) _formData['longitude'] = user.longitude;

    addIfNotEmpty('father_name', user.fatherName);
    addIfNotEmpty('mother_name', user.motherName);
    addIfNotEmpty('father_status', user.fatherStatus);
    addIfNotEmpty('mother_status', user.motherStatus);
    addIfNotEmpty('father_occupation', user.fatherOccupation);
    addIfNotEmpty('mother_occupation', user.motherOccupation);
    if (user.brothers != null) _formData['brothers'] = user.brothers.toString();
    if (user.sisters != null) _formData['sisters'] = user.sisters.toString();
    addIfNotEmpty('family_status', user.familyStatus);
    addIfNotEmpty('family_type', user.familyType);
    addIfNotEmpty('family_values', user.familyValues);
    addIfNotEmpty('live_with_family', user.liveWithFamily);
    addIfNotEmpty('annual_income', user.annualIncome);
    addIfNotEmpty('family_location', user.familyLocation);

    addIfNotEmpty('highest_education', user.highestEducation);
    addIfNotEmpty('college_name', user.collegeName);
    addIfNotEmpty('educational_details', user.educationalDetails);
    addIfNotEmpty('occupation', user.occupation);
    addIfNotEmpty('employed_in', user.employedIn);
    addIfNotEmpty('personal_income', user.personalIncome);
    addIfNotEmpty('working_sector', user.workingSector);
    addIfNotEmpty('working_location', user.workingLocation);

    addIfNotEmpty('religion', user.religion);
    addIfNotEmpty('community', user.community);
    addIfNotEmpty('sub_community', user.subCommunity);

    addIfNotEmpty('appearance', user.appearance);
    addIfNotEmpty('living_status', user.livingStatus);
    addIfNotEmpty('physical_status', user.physicalStatus);
    addIfNotEmpty('eating_habits', user.eatingHabits);
    addIfNotEmpty('smoking_habits', user.smokingHabits);
    addIfNotEmpty('drinking_habits', user.drinkingHabits);
    if (user.hobbies.isNotEmpty) {
      _formData['hobbies'] = user.hobbies;
    }

    if (user.landArea != null) {
      _formData['land_area'] = user.landArea;
    }
    addIfNotEmpty('property_type', user.propertyType);
    if (user.propertyTypes != null && user.propertyTypes!.isNotEmpty) {
      _formData['property_types'] = user.propertyTypes;
    }
    if (user.landTypes != null && user.landTypes!.isNotEmpty) {
      _formData['land_types'] = user.landTypes;
    }
    if (user.houseTypes != null && user.houseTypes!.isNotEmpty) {
      _formData['house_types'] = user.houseTypes;
    }
    if (user.businessTypes != null && user.businessTypes!.isNotEmpty) {
      _formData['business_types'] = user.businessTypes;
    }
    addIfNotEmpty('property_possession_type', user.propertyPossessionType);

    addIfNotEmpty('alternate_mobile', user.alternateMobile);
    addIfNotEmpty('suitable_time_to_call', user.suitableTimeToCall);

    debugPrint('[ONBOARDING_PROVIDER] ✅ prepopulateFromUser - Complete');

    notifyListeners();
  }

  void reset() {
    _currentStep = 0;
    _formData.clear();
    notifyListeners();
  }
}
