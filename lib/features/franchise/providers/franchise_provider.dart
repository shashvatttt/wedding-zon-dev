import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../../core/models/user_model.dart';
import '../repositories/franchise_repository.dart';

import 'package:image_picker/image_picker.dart';

class FranchiseProvider extends ChangeNotifier {
  final FranchiseRepository _franchiseRepository;

  FranchiseProvider(this._franchiseRepository);

  List<User> _profiles = [];
  bool _isLoading = false;
  String _error = '';

  List<User> get profiles => _profiles;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> loadProfiles() async {
    debugPrint(
      '[FRANCHISE_PROVIDER] 🔵 loadProfiles - Starting to load profiles',
    );

    _isLoading = true;
    _error = '';
    notifyListeners();

    final response = await _franchiseRepository.getProfiles();

    if (response.success && response.data != null) {
      _profiles = response.data!;
      debugPrint(
        '[FRANCHISE_PROVIDER] ✅ loadProfiles - Loaded ${_profiles.length} profiles',
      );
      debugPrint(
        '[FRANCHISE_PROVIDER] 📊 loadProfiles - Profile IDs: ${_profiles.map((p) => p.id).toList()}',
      );
    } else {
      _error = response.message ?? 'Failed to load profiles';
      debugPrint('[FRANCHISE_PROVIDER] ❌ loadProfiles - Failed: $_error');
    }

    _isLoading = false;
    notifyListeners();
    debugPrint('[FRANCHISE_PROVIDER] 🏁 loadProfiles - Completed');
  }

  Future<Map<String, dynamic>?> createMember(Map<String, dynamic> data) async {
    debugPrint(
      '[FRANCHISE_PROVIDER] 🔵 createMember - Starting member creation',
    );
    debugPrint(
      '[FRANCHISE_PROVIDER] 📤 createMember - Data keys: ${data.keys}',
    );

    _isLoading = true;
    _error = '';
    notifyListeners();

    final response = await _franchiseRepository.createProfile(data);
    _isLoading = false;

    if (response.success && response.data != null) {
      try {
        if (response.data!['profile'] != null) {
          final user = User.fromJson(response.data!['profile']);
          _profiles.insert(0, user);
          debugPrint(
            '[FRANCHISE_PROVIDER] ✅ createMember - Member created: ${user.id}',
          );
          debugPrint(
            '[FRANCHISE_PROVIDER] 🔐 createMember - Has credentials: ${response.data!['credentials'] != null}',
          );
        }
        notifyListeners();
        return response.data;
      } catch (e) {
        _error = 'Failed to parse response: $e';
        debugPrint('[FRANCHISE_PROVIDER] ❌ createMember - Parse error: $e');
        notifyListeners();
        return null;
      }
    } else {
      _error = response.message ?? 'Failed to create member';
      debugPrint('[FRANCHISE_PROVIDER] ❌ createMember - Failed: $_error');
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateMember(String userId, Map<String, dynamic> data) async {
    debugPrint('[FRANCHISE_PROVIDER] ========================================');
    debugPrint('[FRANCHISE_PROVIDER] 🔵 updateMember - Starting update');
    debugPrint('[FRANCHISE_PROVIDER] 👤 User ID: $userId');
    debugPrint('[FRANCHISE_PROVIDER] 📤 Update data keys: ${data.keys}');
    debugPrint('[FRANCHISE_PROVIDER] 📦 Full update data:');
    data.forEach((key, value) {
      debugPrint(
        '[FRANCHISE_PROVIDER]   - $key: $value (${value.runtimeType})',
      );
    });
    debugPrint('[FRANCHISE_PROVIDER] ========================================');

    _isLoading = true;
    notifyListeners();

    final response = await _franchiseRepository.updateProfile(userId, data);
    _isLoading = false;

    if (response.success && response.data != null) {
      debugPrint('[FRANCHISE_PROVIDER] ✅ updateMember - API call successful');
      debugPrint(
        '[FRANCHISE_PROVIDER] 📥 Response data: ${response.data!.toJson()}',
      );

      final index = _profiles.indexWhere((p) => p.id == userId);
      debugPrint(
        '[FRANCHISE_PROVIDER] 🔍 Finding profile in local list - Index: $index',
      );

      if (index != -1) {
        final oldProfile = _profiles[index];
        debugPrint('[FRANCHISE_PROVIDER] 📊 OLD profile data:');
        debugPrint('[FRANCHISE_PROVIDER]   - Name: ${oldProfile.fullName}');
        debugPrint('[FRANCHISE_PROVIDER]   - First: ${oldProfile.firstName}');
        debugPrint('[FRANCHISE_PROVIDER]   - Last: ${oldProfile.lastName}');

        _profiles[index] = response.data!;

        final newProfile = _profiles[index];
        debugPrint('[FRANCHISE_PROVIDER] 📊 NEW profile data:');
        debugPrint('[FRANCHISE_PROVIDER]   - Name: ${newProfile.fullName}');
        debugPrint('[FRANCHISE_PROVIDER]   - First: ${newProfile.firstName}');
        debugPrint('[FRANCHISE_PROVIDER]   - Last: ${newProfile.lastName}');

        debugPrint(
          '[FRANCHISE_PROVIDER] ✅ updateMember - Profile updated at index $index',
        );
        debugPrint(
          '[FRANCHISE_PROVIDER] 🔔 Calling notifyListeners to refresh UI',
        );
        notifyListeners();
        debugPrint(
          '[FRANCHISE_PROVIDER] ========================================',
        );
      } else {
        debugPrint(
          '[FRANCHISE_PROVIDER] ⚠️ updateMember - Profile not found in local list!',
        );
        debugPrint(
          '[FRANCHISE_PROVIDER] 📋 Current profile IDs: ${_profiles.map((p) => p.id).toList()}',
        );
        debugPrint(
          '[FRANCHISE_PROVIDER] ========================================',
        );
      }
      return true;
    } else {
      _error = response.message ?? 'Failed to update member';
      debugPrint('[FRANCHISE_PROVIDER] ❌ updateMember - Failed: $_error');
      debugPrint(
        '[FRANCHISE_PROVIDER] ========================================',
      );
      notifyListeners();
      return false;
    }
  }

  Future<Map<String, dynamic>?> getPreferences(String userId) async {
    debugPrint(
      '[FRANCHISE_PROVIDER] 🔵 getPreferences - Fetching preferences for: $userId',
    );

    _isLoading = true;
    notifyListeners();

    final response = await _franchiseRepository.getPreferences(userId);
    _isLoading = false;
    notifyListeners();

    if (response.success) {
      debugPrint(
        '[FRANCHISE_PROVIDER] ✅ getPreferences - Fetched: ${response.data}',
      );
      return response.data;
    } else {
      _error = response.message ?? 'Failed to get preferences';
      debugPrint('[FRANCHISE_PROVIDER] ❌ getPreferences - Failed: $_error');
      return null;
    }
  }

  Future<bool> updatePreferences(
    String userId,
    Map<String, dynamic> preferences,
  ) async {
    debugPrint(
      '[FRANCHISE_PROVIDER] 🔵 updatePreferences - Updating preferences for: $userId',
    );
    debugPrint(
      '[FRANCHISE_PROVIDER] 📤 updatePreferences - Preferences: $preferences',
    );

    _isLoading = true;
    notifyListeners();

    final response = await _franchiseRepository.updatePreferences(
      userId,
      preferences,
    );

    if (response.success) {
      debugPrint(
        '[FRANCHISE_PROVIDER] ✅ updatePreferences - Success, refreshing profile',
      );

      final profileResponse = await _franchiseRepository.getProfile(userId);
      if (profileResponse.success && profileResponse.data != null) {
        final index = _profiles.indexWhere((p) => p.id == userId);
        if (index != -1) {
          _profiles[index] = profileResponse.data!;
          debugPrint(
            '[FRANCHISE_PROVIDER] 🔄 updatePreferences - Profile refreshed at index $index',
          );
        }
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _error = response.message ?? 'Failed to update preferences';
      debugPrint('[FRANCHISE_PROVIDER] ❌ updatePreferences - Failed: $_error');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> uploadPhotos(String userId, List<dynamic> fileInputs) async {
    debugPrint(
      '[FRANCHISE_PROVIDER] 🔵 uploadPhotos - Starting photo upload for user: $userId',
    );

    _isLoading = true;
    notifyListeners();

    try {
      final List<String> paths = [];

      for (var input in fileInputs) {
        if (input is String) {
          paths.add(input);
        } else if (input is File) {
          paths.add(input.path);
        } else if (input is XFile) {
          paths.add(input.path);
        } else {
          try {
            paths.add((input as dynamic).path.toString());
          } catch (e) {
            debugPrint(
              '[FRANCHISE_PROVIDER] ⚠️ uploadPhotos - Invalid file input type: ${input.runtimeType}',
            );
          }
        }
      }

      debugPrint(
        '[FRANCHISE_PROVIDER] 📸 uploadPhotos - Uploading ${paths.length} photos',
      );

      if (paths.isEmpty) {
        _error = "No valid photos to upload";
        _isLoading = false;
        notifyListeners();
        debugPrint(
          '[FRANCHISE_PROVIDER] ❌ uploadPhotos - No valid photos to upload',
        );
        return false;
      }

      final response = await _franchiseRepository.uploadPhotos(userId, paths);

      if (response.success) {
        debugPrint(
          '[FRANCHISE_PROVIDER] ✅ uploadPhotos - Upload successful, refreshing profile',
        );

        final profileResponse = await _franchiseRepository.getProfile(userId);
        if (profileResponse.success && profileResponse.data != null) {
          final index = _profiles.indexWhere((p) => p.id == userId);
          if (index != -1) {
            _profiles[index] = profileResponse.data!;
            debugPrint(
              '[FRANCHISE_PROVIDER] 🔄 uploadPhotos - Profile updated at index $index',
            );
            debugPrint(
              '[FRANCHISE_PROVIDER] 📊 uploadPhotos - Updated profile photos: ${profileResponse.data!.photos.length}',
            );
            debugPrint(
              '[FRANCHISE_PROVIDER] 📊 uploadPhotos - Updated profile photo: ${profileResponse.data!.profilePhoto}',
            );
          } else {
            debugPrint(
              '[FRANCHISE_PROVIDER] ⚠️ uploadPhotos - Profile not found in local list',
            );
          }
        } else {
          debugPrint(
            '[FRANCHISE_PROVIDER] ⚠️ uploadPhotos - Failed to refresh profile: ${profileResponse.message}',
          );
        }

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.message ?? 'Failed to upload photos';
        _isLoading = false;
        notifyListeners();
        debugPrint(
          '[FRANCHISE_PROVIDER] ❌ uploadPhotos - Upload failed: $_error',
        );
        return false;
      }
    } catch (e) {
      debugPrint('[FRANCHISE_PROVIDER] ❌ uploadPhotos - Exception: $e');
      _error = 'Upload failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<String?> downloadMatchPdf(
    String userId, {
    required String language,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _franchiseRepository.getMatchPdf(userId, language);

      _isLoading = false;
      notifyListeners();

      if (response.success && response.data != null) {
        final dir = await getTemporaryDirectory();
        final fileName = 'match_${userId}_$language.pdf';
        final file = File('${dir.path}/$fileName');

        await file.writeAsBytes(response.data!);
        return file.path;
      } else {
        _error = response.message ?? 'Failed to download PDF';
        notifyListeners();
        return null;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'PDF download failed: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  Future<Map<String, dynamic>?> loadProfileDetails(String userId) async {
    final user = _profiles.firstWhere(
      (p) => p.id == userId,
      orElse: () => User(id: ''),
    );
    if (user.id.isNotEmpty) {
      return user.toJson();
    }
    return null;
  }

  Future<bool> deletePhoto(String userId, String photoId) async {
    debugPrint(
      '[FRANCHISE_PROVIDER] 🔵 deletePhoto - Deleting photo: $photoId for user: $userId',
    );

    _isLoading = true;
    notifyListeners();

    final response = await _franchiseRepository.deletePhoto(userId, photoId);
    _isLoading = false;

    if (response.success) {
      debugPrint(
        '[FRANCHISE_PROVIDER] ✅ deletePhoto - Success, refreshing profile',
      );

      final profileResponse = await _franchiseRepository.getProfile(userId);
      if (profileResponse.success && profileResponse.data != null) {
        final index = _profiles.indexWhere((p) => p.id == userId);
        if (index != -1) {
          _profiles[index] = profileResponse.data!;
          debugPrint(
            '[FRANCHISE_PROVIDER] 🔄 deletePhoto - Profile updated at index $index',
          );
        }
      }

      notifyListeners();
      return true;
    } else {
      _error = response.message ?? 'Failed to delete photo';
      debugPrint('[FRANCHISE_PROVIDER] ❌ deletePhoto - Failed: $_error');
      notifyListeners();
      return false;
    }
  }

  Future<User?> updateFranchiseOwnerProfile(Map<String, dynamic> data) async {
    debugPrint(
      '[FRANCHISE_PROVIDER] 🔵 updateFranchiseOwnerProfile - Updating owner profile',
    );

    _isLoading = true;
    _error = '';
    notifyListeners();

    final response = await _franchiseRepository.updateFranchiseOwnerProfile(
      data,
    );
    _isLoading = false;

    if (response.success && response.data != null) {
      debugPrint(
        '[FRANCHISE_PROVIDER] ✅ updateFranchiseOwnerProfile - Success',
      );
      debugPrint(
        '[FRANCHISE_PROVIDER] 📊 Updated user: ${response.data!.toJson()}',
      );
      notifyListeners();
      return response.data;
    } else {
      _error = response.message ?? 'Failed to update profile';
      debugPrint(
        '[FRANCHISE_PROVIDER] ❌ updateFranchiseOwnerProfile - Failed: $_error',
      );
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateFranchiseStatus(String status) async {
    debugPrint(
      '[FRANCHISE_PROVIDER] 🔵 updateFranchiseStatus - Updating status to: $status',
    );

    _isLoading = true;
    _error = '';
    notifyListeners();

    final response = await _franchiseRepository.updateFranchiseStatus(status);
    _isLoading = false;

    if (response.success) {
      debugPrint('[FRANCHISE_PROVIDER] ✅ updateFranchiseStatus - Success');
      notifyListeners();
      return true;
    } else {
      _error = response.message ?? 'Failed to update status';
      debugPrint(
        '[FRANCHISE_PROVIDER] ❌ updateFranchiseStatus - Failed: $_error',
      );
      notifyListeners();
      return false;
    }
  }

  Future<bool> submitPayment() async {
    debugPrint('[FRANCHISE_PROVIDER] 🔵 submitPayment - Submitting payment');

    _isLoading = true;
    _error = '';
    notifyListeners();

    final response = await _franchiseRepository.submitPayment();
    _isLoading = false;

    if (response.success) {
      debugPrint('[FRANCHISE_PROVIDER] ✅ submitPayment - Success');
      notifyListeners();
      return true;
    } else {
      _error = response.message ?? 'Failed to submit payment';
      debugPrint('[FRANCHISE_PROVIDER] ❌ submitPayment - Failed: $_error');
      notifyListeners();
      return false;
    }
  }

  Future<bool> setProfilePhoto(String userId, String photoId) async {
    debugPrint(
      '[FRANCHISE_PROVIDER] 🔵 setProfilePhoto - Setting profile photo: $photoId for user: $userId',
    );

    _isLoading = true;
    notifyListeners();

    final response = await _franchiseRepository.setProfilePhoto(
      userId,
      photoId,
    );
    _isLoading = false;

    if (response.success) {
      debugPrint(
        '[FRANCHISE_PROVIDER] ✅ setProfilePhoto - Success, refreshing profile',
      );

      final profileResponse = await _franchiseRepository.getProfile(userId);
      if (profileResponse.success && profileResponse.data != null) {
        final index = _profiles.indexWhere((p) => p.id == userId);
        if (index != -1) {
          _profiles[index] = profileResponse.data!;
          debugPrint(
            '[FRANCHISE_PROVIDER] 🔄 setProfilePhoto - Profile updated at index $index',
          );
        }
      }
      notifyListeners();
      return true;
    } else {
      _error = response.message ?? 'Failed to set profile photo';
      debugPrint('[FRANCHISE_PROVIDER] ❌ setProfilePhoto - Failed: $_error');
      notifyListeners();
      return false;
    }
  }
}
