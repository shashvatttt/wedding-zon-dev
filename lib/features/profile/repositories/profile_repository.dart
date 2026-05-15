import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/api_response.dart';
import '../../../core/services/api_service.dart';

class ProfileRepository {
  final ApiService _apiService;

  ProfileRepository(this._apiService);

  Future<ApiResponse<Map<String, dynamic>>> getMyPreferences() async {
    try {
      final endpoint = '${AppConstants.users}/preferences';
      debugPrint(
        '[PROFILE_REPO] 🔵 getMyPreferences - Fetching from: $endpoint',
      );

      final response = await _apiService.dio.get(
        endpoint,
        options: Options(extra: {'withCredentials': true}),
      );

      debugPrint(
        '[PROFILE_REPO] 🟢 getMyPreferences - Status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        if (response.data is Map && response.data['success'] == true) {
          final data = response.data['data'] ?? response.data['preferences'];
          if (data is Map) {
            return ApiResponse(
              success: true,
              data: Map<String, dynamic>.from(data),
            );
          }
        }

        if (response.data is Map) {
          return ApiResponse(
            success: true,
            data: Map<String, dynamic>.from(response.data),
          );
        }
      }

      return ApiResponse(success: false, message: 'Failed to load preferences');
    } catch (e) {
      debugPrint('[PROFILE_REPO] ❌ getMyPreferences - Error: $e');
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse<bool>> updateMyPreferences(
    Map<String, dynamic> preferences,
  ) async {
    try {
      final endpoint = '${AppConstants.users}/preferences';
      debugPrint('[PROFILE_REPO] 🔵 updateMyPreferences - Updating: $endpoint');
      debugPrint('[PROFILE_REPO] 📦 Preferences count: ${preferences.length}');
      debugPrint('[PROFILE_REPO] 🔑 Keys: ${preferences.keys.toList()}');

      final response = await _apiService.dio.put(
        endpoint,
        data: preferences,
        options: Options(extra: {'withCredentials': true}),
      );

      debugPrint(
        '[PROFILE_REPO] 🟢 updateMyPreferences - Status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        return ApiResponse(success: true, data: true);
      }

      return ApiResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to update',
      );
    } catch (e) {
      debugPrint('[PROFILE_REPO] ❌ updateMyPreferences - Error: $e');
      return ApiResponse(success: false, message: e.toString());
    }
  }
}
