import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/api_response.dart';
import '../models/vendor_review.dart';
import '../models/vendor_availability.dart';

class VendorFeaturesRepository {
  final ApiService _apiService;

  VendorFeaturesRepository(this._apiService);

  Future<ApiResponse<List<VendorReview>>> getVendorReviews(
    String vendorId, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiService.dio.get(
        '/vendor-features/reviews/$vendorId',
        queryParameters: {'page': page, 'limit': limit},
        options: Options(extra: {'withCredentials': true}),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> reviewsData = response.data['data'] ?? [];
        final reviews = reviewsData
            .map((json) => VendorReview.fromJson(json))
            .toList();
        return ApiResponse(
          success: true,
          data: reviews,
          message: 'Reviews fetched successfully',
        );
      }

      return ApiResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to fetch reviews',
      );
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message: e.response?.data['message'] ?? 'Network error',
      );
    } catch (e) {
      return ApiResponse(success: false, message: 'An error occurred: $e');
    }
  }

  Future<ApiResponse<VendorReview>> submitReview({
    required String vendorId,
    required String userId,
    required int rating,
    required String comment,
  }) async {
    try {
      final payload = {
        'vendorId': vendorId,
        'userId': userId,
        'rating': rating,
        'comment': comment,
      };

      debugPrint('[VENDOR_FEATURES_REPO] 📤 Submitting review...');
      debugPrint('[VENDOR_FEATURES_REPO] 📦 Payload: $payload');

      final response = await _apiService.dio.post(
        '/vendor-features/reviews',
        data: payload,
        options: Options(extra: {'withCredentials': true}),
      );

      debugPrint(
        '[VENDOR_FEATURES_REPO] 📥 Response status: ${response.statusCode}',
      );
      debugPrint('[VENDOR_FEATURES_REPO] 📥 Response data: ${response.data}');

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data['success'] == true) {
        final review = VendorReview.fromJson(response.data['data']);
        return ApiResponse(
          success: true,
          data: review,
          message: 'Review submitted successfully',
        );
      }

      return ApiResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to submit review',
      );
    } on DioException catch (e) {
      debugPrint(
        '[VENDOR_FEATURES_REPO] ❌ DioException: ${e.response?.statusCode}',
      );
      debugPrint('[VENDOR_FEATURES_REPO] ❌ Error data: ${e.response?.data}');
      return ApiResponse(
        success: false,
        message: e.response?.data['message'] ?? 'Network error',
      );
    } catch (e) {
      debugPrint('[VENDOR_FEATURES_REPO] ❌ General error: $e');
      return ApiResponse(success: false, message: 'An error occurred: $e');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> submitRequest({
    required String vendorId,
    required String type,
    required String eventDate,
    String? details,
  }) async {
    try {
      final payload = {
        'vendorId': vendorId,
        'type': type,
        'eventDate': eventDate,
        'details': details ?? '',
      };

      debugPrint('[VENDOR_FEATURES_REPO] 📤 Submitting request...');
      debugPrint('[VENDOR_FEATURES_REPO] 📦 Payload: $payload');

      final response = await _apiService.dio.post(
        '/vendor-features/requests',
        data: payload,
        options: Options(extra: {'withCredentials': true}),
      );

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data['success'] == true) {
        return ApiResponse(
          success: true,
          data: response.data['data'],
          message: 'Request submitted successfully',
        );
      }

      return ApiResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to submit request',
      );
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message: e.response?.data['message'] ?? 'Network error',
      );
    } catch (e) {
      return ApiResponse(success: false, message: 'An error occurred: $e');
    }
  }

  Future<ApiResponse<List<VendorAvailability>>> manageAvailability({
    required String date,
    required String status,
    required String action,
    String? note,
  }) async {
    try {
      final response = await _apiService.dio.patch(
        '/vendor-features/availability',
        data: {
          'date': date,
          'status': status,
          'action': action,
          if (note != null) 'note': note,
        },
        options: Options(extra: {'withCredentials': true}),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> availabilityData = response.data['data'] ?? [];
        final availability = availabilityData
            .map((json) => VendorAvailability.fromJson(json))
            .toList();
        return ApiResponse(
          success: true,
          data: availability,
          message: 'Availability updated successfully',
        );
      }

      return ApiResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to update availability',
      );
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message: e.response?.data['message'] ?? 'Network error',
      );
    } catch (e) {
      return ApiResponse(success: false, message: 'An error occurred: $e');
    }
  }
}
