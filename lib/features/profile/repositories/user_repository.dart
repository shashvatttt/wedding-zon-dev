import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:flutter/material.dart';
import '../../../core/models/api_response.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/photo_model.dart';
import '../../../core/models/user_model.dart';
import '../../profile/models/profile_viewer_model.dart';
import '../../../core/constants/app_constants.dart';

class UserRepository {
  final ApiService _apiService;

  UserRepository(this._apiService);

  Future<ApiResponse<void>> blockUser(String userId) async {
    try {
      final response = await _apiService.dio.post(
        AppConstants.usersBlock,
        data: {'targetUserId': userId},
        options: Options(extra: {'withCredentials': true}),
      );

      return response.statusCode == 200
          ? ApiResponse(success: true)
          : ApiResponse(
              success: false,
              message: response.data['message'] ?? 'Failed to block user',
            );
    } catch (e) {
      debugPrint('[USER_REPO] Block user error: $e');
      return ApiResponse(success: false, message: 'Network error');
    }
  }

  Future<ApiResponse<void>> unblockUser(String userId) async {
    try {
      final response = await _apiService.dio.post(
        AppConstants.usersUnblock,
        data: {'targetUserId': userId},
        options: Options(extra: {'withCredentials': true}),
      );

      return response.statusCode == 200
          ? ApiResponse(success: true)
          : ApiResponse(
              success: false,
              message: response.data['message'] ?? 'Failed to unblock user',
            );
    } catch (e) {
      debugPrint('[USER_REPO] Unblock user error: $e');
      return ApiResponse(success: false, message: 'Network error');
    }
  }

  Future<ApiResponse<void>> reportUser(
    String userId,
    String reason,
    String description,
  ) async {
    try {
      final response = await _apiService.dio.post(
        AppConstants.usersReport,
        data: {
          'targetUserId': userId,
          'reason': reason,
          'description': description,
        },
        options: Options(extra: {'withCredentials': true}),
      );

      return response.statusCode == 200
          ? ApiResponse(success: true)
          : ApiResponse(
              success: false,
              message: response.data['message'] ?? 'Failed to report user',
            );
    } catch (e) {
      debugPrint('[USER_REPO] Report user error: $e');
      return ApiResponse(success: false, message: 'Network error');
    }
  }

  Future<ApiResponse<void>> recordProfileView(String userId) async {
    try {
      final response = await _apiService.dio.post(
        '${AppConstants.users}/view/$userId',
        options: Options(extra: {'withCredentials': true}),
      );

      return response.statusCode == 200
          ? ApiResponse(success: true)
          : ApiResponse(
              success: false,
              message: response.data['message'] ?? 'Failed to record view',
            );
    } catch (e) {
      debugPrint('[USER_REPO] Record view error: $e');
      return ApiResponse(success: false, message: 'Network error');
    }
  }

  Future<ApiResponse<List<ProfileViewer>>> getProfileViewers() async {
    try {
      final response = await _apiService.dio.get(
        '${AppConstants.users}/viewers',
        options: Options(extra: {'withCredentials': true}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        final viewers = data
            .map((json) => ProfileViewer.fromJson(json as Map<String, dynamic>))
            .toList();
        return ApiResponse(success: true, data: viewers);
      }

      return ApiResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to fetch viewers',
      );
    } catch (e) {
      debugPrint('[USER_REPO] Get viewers error: $e');
      return ApiResponse(success: false, message: 'Network error');
    }
  }

  Future<ApiResponse<List<Photo>>> uploadPhotos(
    List<File> photos, {
    void Function(int sent, int total)? onProgress,
  }) async {
    try {
      final formData = FormData();

      for (var file in photos) {
        final fileName = file.path.split(Platform.pathSeparator).last;

        final mimeType = lookupMimeType(file.path) ?? 'image/jpeg';
        final mimeTypeParts = mimeType.split('/');

        debugPrint('[UPLOAD] Adding file: $fileName, MIME: $mimeType');

        formData.files.add(
          MapEntry(
            'photos',
            await MultipartFile.fromFile(
              file.path,
              filename: fileName,
              contentType: MediaType(mimeTypeParts[0], mimeTypeParts[1]),
            ),
          ),
        );
      }

      final response = await _apiService.dio.post(
        AppConstants.usersUploadPhotos,
        data: formData,
        onSendProgress: onProgress,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'] as List<dynamic>?;
        final uploadedPhotos =
            data
                ?.map((p) => Photo.fromJson(p as Map<String, dynamic>))
                .toList() ??
            [];

        return ApiResponse(
          success: true,
          data: uploadedPhotos,
          message: response.data['message'],
          errors: response.data['errors'] as List<dynamic>?,
        );
      }

      return ApiResponse(
        success: false,
        message: response.data['message'] ?? 'Upload failed',
      );
    } on DioException catch (e) {
      debugPrint('[UPLOAD ERROR] ${e.message}');
      return ApiResponse(
        success: false,
        message: e.response?.data['message'] ?? e.message ?? 'Network error',
      );
    }
  }

  Future<ApiResponse<List<Photo>>> deletePhoto(String photoId) async {
    try {
      debugPrint('[USER_REPO] Deleting photo: $photoId');
      final response = await _apiService.dio.delete(
        '${AppConstants.usersPhotos}/$photoId',
        options: Options(extra: {'withCredentials': true}),
      );

      debugPrint('[USER_REPO] Delete response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data['data'] as List<dynamic>?;
        final photos =
            data
                ?.map((p) => Photo.fromJson(p as Map<String, dynamic>))
                .toList() ??
            [];

        return ApiResponse(
          success: true,
          data: photos,
          message: response.data['message'],
        );
      }

      debugPrint('[USER_REPO] Delete failed: ${response.data}');
      return ApiResponse(
        success: false,
        message: response.data['message'] ?? 'Delete failed',
      );
    } on DioException catch (e) {
      debugPrint('[USER_REPO] Delete error: ${e.message}');
      return ApiResponse(
        success: false,
        message: e.response?.data['message'] ?? e.message ?? 'Network error',
      );
    }
  }

  Future<ApiResponse<List<Photo>>> setAsProfilePhoto(String photoId) async {
    try {
      debugPrint('[USER_REPO] Setting profile photo: $photoId');
      final response = await _apiService.dio.patch(
        '${AppConstants.usersPhotos}/$photoId/set-profile',
        options: Options(extra: {'withCredentials': true}),
      );

      debugPrint('[USER_REPO] Set profile response: ${response.statusCode}');

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'] as List<dynamic>?;
        final photos =
            data
                ?.map((p) => Photo.fromJson(p as Map<String, dynamic>))
                .toList() ??
            [];

        return ApiResponse(
          success: true,
          data: photos,
          message: response.data['message'],
        );
      }

      debugPrint('[USER_REPO] Set profile failed: ${response.data}');
      return ApiResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to set profile photo',
      );
    } on DioException catch (e) {
      debugPrint('[USER_REPO] Set profile error: ${e.message}');
      return ApiResponse(
        success: false,
        message: e.response?.data['message'] ?? e.message ?? 'Network error',
      );
    }
  }

  Future<ApiResponse<void>> updateUserLocation(double lat, double lng) async {
    try {
      debugPrint('[USER_REPO] Updating location: $lat, $lng');
      final response = await _apiService.dio.patch(
        AppConstants.usersLocation,
        data: {'latitude': lat, 'longitude': lng},
        options: Options(extra: {'withCredentials': true}),
      );

      return response.statusCode == 200
          ? ApiResponse(success: true, message: 'Location updated successfully')
          : ApiResponse(
              success: false,
              message: response.data['message'] ?? 'Failed to update location',
            );
    } catch (e) {
      debugPrint('[USER_REPO] Update location error: $e');
      return ApiResponse(success: false, message: 'Network error');
    }
  }

  Future<ApiResponse<User>> getCurrentUser() async {
    try {
      debugPrint('[USER_REPO] ========== GET CURRENT USER ==========');

      final response = await _apiService.dio.get(
        AppConstants.authMe,
        queryParameters: {'full': true},
        options: Options(extra: {'withCredentials': true}),
      );

      debugPrint('[USER_REPO] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        debugPrint('[USER_REPO] User data received');
        return ApiResponse(success: true, data: User.fromJson(response.data));
      }

      return ApiResponse(
        success: false,
        message: response.statusMessage ?? 'Failed to get user',
      );
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message: e.response?.data['message'] ?? e.message ?? 'Network error',
      );
    }
  }

  Future<ApiResponse<User>> updateProfile(Map<String, dynamic> data) async {
    try {
      debugPrint('[USER_REPO] ========== UPDATE PROFILE ==========');

      final response = await _apiService.dio.post(
        AppConstants.authRegisterDetails,
        data: data,
        options: Options(extra: {'withCredentials': true}),
      );

      if (response.statusCode == 200) {
        return ApiResponse(
          success: true,
          data: User.fromJson(response.data['user']),
        );
      }

      return ApiResponse(
        success: false,
        message: response.statusMessage ?? 'Failed to update profile',
      );
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message: e.response?.data['message'] ?? e.message ?? 'Network error',
      );
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getUserByUsername(
    String username,
  ) async {
    try {
      debugPrint('[USER_REPO] ========== GET USER BY USERNAME ==========');
      debugPrint('[USER_REPO] Username: $username');

      final response = await _apiService.dio.get(
        '${AppConstants.usersProfile}/$username',
        options: Options(extra: {'withCredentials': true}),
      );

      debugPrint('[USER_REPO] Status: ${response.statusCode}');

      if (response.statusCode == 200 && response.data != null) {
        debugPrint('[USER_REPO] User profile data received');

        final responseData = response.data;
        final userData =
            (responseData is Map<String, dynamic> &&
                responseData.containsKey('data') &&
                responseData['data'] is Map<String, dynamic>)
            ? responseData['data']
            : responseData;

        return ApiResponse(
          success: true,
          data: userData as Map<String, dynamic>,
        );
      }

      return ApiResponse(
        success: false,
        message: response.statusMessage ?? 'Failed to get user profile',
      );
    } on DioException catch (e) {
      debugPrint('[USER_REPO] Error: ${e.message}');
      return ApiResponse(
        success: false,
        message: e.response?.data['message'] ?? e.message ?? 'Network error',
      );
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getMyPreferences() async {
    try {
      debugPrint('[USER_REPO] 🔵 getMyPreferences - Fetching user data first');

      final userResponse = await getCurrentUser();

      if (userResponse.success && userResponse.data != null) {
        final user = userResponse.data!;

        if (user.partnerPreferences != null) {
          debugPrint('[USER_REPO] ✅ Found preferences in user object');
          return ApiResponse(
            success: true,
            data: user.partnerPreferences!.toJson(),
          );
        }
      }

      final endpoint = '${AppConstants.users}/preferences';
      debugPrint(
        '[USER_REPO] 🔵 getMyPreferences - Trying endpoint: $endpoint',
      );

      final response = await _apiService.dio.get(
        endpoint,
        options: Options(extra: {'withCredentials': true}),
      );

      debugPrint(
        '[USER_REPO] 🟢 getMyPreferences - Status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        if (response.data is Map) {
          final data =
              response.data['data'] ??
              response.data['preferences'] ??
              response.data;
          return ApiResponse(
            success: true,
            data: Map<String, dynamic>.from(data),
          );
        }
      }

      return ApiResponse(success: false, message: 'Failed to load preferences');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        debugPrint(
          '[USER_REPO] ℹ️ No preferences found (404) - returning empty',
        );
        return ApiResponse(success: true, data: {});
      }
      debugPrint('[USER_REPO] ❌ getMyPreferences - DioError: $e');
      return ApiResponse(success: false, message: e.message ?? 'Network error');
    } catch (e) {
      debugPrint('[USER_REPO] ❌ getMyPreferences - Error: $e');
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse<bool>> updateMyPreferences(
    Map<String, dynamic> preferences,
  ) async {
    try {
      final endpoint = '${AppConstants.users}/preferences';
      debugPrint('[USER_REPO] 🔵 updateMyPreferences - Updating: $endpoint');
      debugPrint('[USER_REPO] 📤 Preferences data: $preferences');

      final response = await _apiService.dio.put(
        endpoint,
        data: {'preferences': preferences},
        options: Options(extra: {'withCredentials': true}),
      );

      debugPrint(
        '[USER_REPO] 🟢 updateMyPreferences - Status: ${response.statusCode}',
      );
      debugPrint('[USER_REPO] 📥 Response: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse(success: true, data: true);
      }

      return ApiResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to update',
      );
    } on DioException catch (e) {
      debugPrint('[USER_REPO] ❌ updateMyPreferences - DioError: ${e.message}');
      debugPrint('[USER_REPO] ❌ Status: ${e.response?.statusCode}');
      debugPrint('[USER_REPO] ❌ Response: ${e.response?.data}');
      return ApiResponse(
        success: false,
        message: e.response?.data['message'] ?? e.message ?? 'Network error',
      );
    } catch (e) {
      debugPrint('[USER_REPO] ❌ updateMyPreferences - Error: $e');
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse<bool>> clearMyPreferences() async {
    try {
      final endpoint = '${AppConstants.users}/preferences';
      debugPrint('[USER_REPO] 🔵 clearMyPreferences - Clearing: $endpoint');

      final clearedPreferences = {
        'minAge': null,
        'maxAge': null,
        'age_min': null,
        'age_max': null,
        'heightMin': null,
        'heightMax': null,
        'height_min': null,
        'height_max': null,
        'religion': null,
        'community': null,
        'location': null,
        'marital_status': null,
        'maritalStatus': null,
        'eating_habits': null,
        'smoking_habits': null,
        'drinking_habits': null,
        'highest_education': null,
        'occupation': null,
        'annual_income': null,
        'country': null,
        'state': null,
        'city': null,
        'mother_tongue': null,
        'profile_managed_by': null,
        'profileManagedBy': null,
        'family_status': null,
        'manglik_status': null,
      };

      debugPrint('[USER_REPO] 📤 Clearing with: $clearedPreferences');

      final response = await _apiService.dio.put(
        endpoint,
        data: {'preferences': clearedPreferences},
        options: Options(extra: {'withCredentials': true}),
      );

      debugPrint(
        '[USER_REPO] 🟢 clearMyPreferences - Status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        return ApiResponse(success: true, data: true);
      }

      return ApiResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to clear preferences',
      );
    } catch (e) {
      debugPrint('[USER_REPO] ❌ clearMyPreferences - Error: $e');
      return ApiResponse(success: false, message: e.toString());
    }
  }
}
