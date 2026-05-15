import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/api_response.dart';
import '../models/availability_entry.dart';

class AvailabilityRepository {
  final ApiService _apiService;

  AvailabilityRepository(this._apiService);

  Future<ApiResponse<List<AvailabilityEntry>>> updateAvailability({
    required DateTime date,
    required String status,
    required String action,
    String? note,
  }) async {
    try {
      debugPrint('[AVAILABILITY_REPO] Updating availability');
      debugPrint('[AVAILABILITY_REPO] Date: ${date.toIso8601String()}');
      debugPrint('[AVAILABILITY_REPO] Status: $status');
      debugPrint('[AVAILABILITY_REPO] Action: $action');

      final response = await _apiService.dio.patch(
        '/vendor-features/availability',
        data: {
          'date': date.toIso8601String().split('T')[0],
          'status': status,
          'action': action,
          if (note != null && note.isNotEmpty) 'note': note,
        },
      );

      debugPrint('[AVAILABILITY_REPO] Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          final availabilityList = (data['data'] as List)
              .map((e) => AvailabilityEntry.fromJson(e as Map<String, dynamic>))
              .toList();

          return ApiResponse(
            success: true,
            data: availabilityList,
            message: 'Availability updated successfully',
          );
        }
      }

      String errorMessage = 'Failed to update availability';
      if (response.data is Map<String, dynamic>) {
        errorMessage = response.data['message'] ?? errorMessage;
      } else if (response.data is String) {
        errorMessage = response.data;
      }

      return ApiResponse(success: false, message: errorMessage);
    } catch (e) {
      debugPrint('[AVAILABILITY_REPO] Error: $e');
      return ApiResponse(success: false, message: 'An error occurred: $e');
    }
  }
}
