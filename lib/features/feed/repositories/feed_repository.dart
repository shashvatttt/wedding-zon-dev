import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/api_response.dart';
import '../../../core/services/api_service.dart';
import '../models/feed_response.dart';

class FeedRepository {
  final ApiService _apiService;

  FeedRepository(this._apiService);

  Future<ApiResponse<FeedResponse>> getFeed({
    String? cursor,
    String? viewAs,
    bool ignorePrefs = false,
  }) async {
    try {
      final queryParams = <String, dynamic>{'full': true};
      if (cursor != null) queryParams['cursor'] = cursor;
      if (viewAs != null) queryParams['viewAs'] = viewAs;
      if (ignorePrefs) queryParams['ignore_prefs'] = true;

      final response = await _apiService.dio.get(
        AppConstants.usersFeed,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        return ApiResponse(
          success: true,
          data: FeedResponse.fromJson(response.data),
        );
      }

      String errorMessage = 'Failed to load feed';
      if (response.data is Map<String, dynamic>) {
        errorMessage = response.data['message'] ?? errorMessage;
      }

      return ApiResponse(success: false, message: errorMessage);
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message: e.response?.data['message'] ?? e.message ?? 'Network error',
      );
    }
  }

  Future<ApiResponse<FeedResponse>> searchUsers({
    Map<String, dynamic>? filters,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'full': true,
        if (filters != null) ...filters,
      };

      debugPrint('[FEED_REPO] 🔍 Searching with filters: $queryParams');

      final response = await _apiService.dio.get(
        AppConstants.usersFeed,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        debugPrint('[FEED_REPO] ✅ Search response received');

        return ApiResponse(
          success: true,
          data: FeedResponse.fromJson(response.data),
        );
      }

      String errorMessage = 'Failed to search users';
      if (response.data is Map<String, dynamic>) {
        errorMessage = response.data['message'] ?? errorMessage;
      }

      return ApiResponse(success: false, message: errorMessage);
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message: e.response?.data['message'] ?? e.message ?? 'Network error',
      );
    }
  }
}
