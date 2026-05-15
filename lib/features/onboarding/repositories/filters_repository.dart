import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/api_response.dart';
import '../models/filter_model.dart';
import '../../feed/utils/filter_debug_helper.dart';

class FiltersRepository {
  final ApiService _apiService;

  FiltersRepository(this._apiService);

  Future<ApiResponse<List<FilterModel>>> getFilters() async {
    try {
      debugPrint('[FiltersRepo] 🌐 Fetching filters from /filters');
      debugPrint(
        '[FiltersRepo] 🔑 API Base URL: ${_apiService.dio.options.baseUrl}',
      );

      debugPrint(
        FilterDebugHelper.generateCurlCommand(
          baseUrl: _apiService.dio.options.baseUrl,
          authToken: _apiService.dio.options.headers['Authorization']
              ?.toString()
              .replaceFirst('Bearer ', ''),
        ),
      );

      final response = await _apiService.dio.get('/filters');

      debugPrint('[FiltersRepo] 📥 Response status: ${response.statusCode}');
      debugPrint('[FiltersRepo] 📥 Response headers: ${response.headers}');

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;

        FilterDebugHelper.debugApiResponse(data);

        List<dynamic> filtersJson;
        if (data is List) {
          filtersJson = data;
          debugPrint(
            '[FiltersRepo] 📋 Direct array response with ${filtersJson.length} items',
          );
        } else if (data is Map && data['data'] != null) {
          filtersJson = data['data'] as List;
          debugPrint(
            '[FiltersRepo] 📋 Wrapped response with ${filtersJson.length} items',
          );
        } else if (data is Map && data['success'] != null) {
          debugPrint('[FiltersRepo] ⚠️ Response has success but no data field');
          debugPrint('[FiltersRepo] ⚠️ Full response: $data');
          return ApiResponse(
            success: false,
            message: 'No filters data in response',
          );
        } else {
          debugPrint('[FiltersRepo] ❌ Invalid response format: $data');
          return ApiResponse(
            success: false,
            message: 'Invalid response format',
          );
        }

        final allFilters = <FilterModel>[];
        for (var i = 0; i < filtersJson.length; i++) {
          try {
            final json = filtersJson[i] as Map<String, dynamic>;
            debugPrint(
              '[FiltersRepo] 🔍 Parsing filter $i: ${json['key']} (isVisible: ${json['isVisible']})',
            );

            if (json['isVisible'] != null) {
              FilterDebugHelper.testVisibilityParsing(json['isVisible']);
            }

            final filter = FilterModel.fromJson(json);
            allFilters.add(filter);

            debugPrint(
              '[FiltersRepo]   ✅ Parsed: ${filter.label} [${filter.section}] visible=${filter.isVisible}',
            );
          } catch (e, stackTrace) {
            debugPrint('[FiltersRepo]   ❌ Failed to parse filter $i: $e');
            FilterDebugHelper.debugFilterParsing(
              filtersJson[i] as Map<String, dynamic>,
              error: e.toString(),
            );
            debugPrint('[FiltersRepo]   Stack trace: $stackTrace');
          }
        }

        debugPrint(
          '[FiltersRepo] 📊 Total parsed: ${allFilters.length} filters',
        );

        final visibleFilters = allFilters
            .where((filter) => filter.isVisible)
            .toList();

        debugPrint(
          '[FiltersRepo] 👁️ Visible filters: ${visibleFilters.length}',
        );

        final filters = visibleFilters.isNotEmpty ? visibleFilters : allFilters;

        filters.sort((a, b) => a.order.compareTo(b.order));

        debugPrint('[FiltersRepo] ✅ Returning ${filters.length} filters');
        for (final filter in filters) {
          debugPrint(
            '[FiltersRepo]   - ${filter.label} (${filter.key}) [${filter.section}]',
          );
        }

        final sections = filters.map((f) => f.section).toSet().toList();
        final filtersBySection = <String, int>{};
        for (final section in sections) {
          filtersBySection[section] = filters
              .where((f) => f.section == section)
              .length;
        }

        FilterDebugHelper.printDiagnosticReport(
          baseUrl: _apiService.dio.options.baseUrl,
          filterCount: allFilters.length,
          visibleFilterCount: filters.length,
          sections: sections,
          filtersBySection: filtersBySection,
        );

        return ApiResponse(success: true, data: filters);
      }

      debugPrint('[FiltersRepo] ❌ Bad status code: ${response.statusCode}');

      String errorMessage = 'Failed to fetch filters';
      if (response.data is Map) {
        errorMessage = response.data?['message'] ?? errorMessage;
      } else if (response.data is String) {
        errorMessage =
            'API endpoint not found (404). Please check if /filters exists on the backend.';
      }

      return ApiResponse(success: false, message: errorMessage);
    } on DioException catch (e) {
      debugPrint('[FiltersRepo] ❌ DioException: ${e.message}');
      debugPrint('[FiltersRepo] Response: ${e.response?.data}');

      String errorMessage = 'Network error';
      if (e.response?.data is Map) {
        errorMessage =
            e.response?.data?['message'] ?? e.message ?? errorMessage;
      } else if (e.response?.statusCode == 404) {
        errorMessage =
            'API endpoint /filters not found. Please ensure the endpoint exists on the backend.';
      } else if (e.message != null) {
        errorMessage = e.message!;
      }

      return ApiResponse(success: false, message: errorMessage);
    } catch (e, stackTrace) {
      debugPrint('[FiltersRepo] ❌ Unexpected error: $e');
      debugPrint('[FiltersRepo] Stack trace: $stackTrace');
      return ApiResponse(success: false, message: 'Unexpected error: $e');
    }
  }
}
