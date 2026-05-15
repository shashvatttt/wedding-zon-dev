import 'package:flutter/foundation.dart';
import '../../feed/models/feed_user.dart';
import '../../../core/services/api_service.dart';

class MatchRepository {
  final ApiService _apiService;

  MatchRepository(this._apiService);

  Future<List<FeedUser>> getRecommendedMatches({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiService.dio.get(
        '/api/matches/recommendations',
        queryParameters: {'page': page, 'limit': limit},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => FeedUser.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching recommended matches: $e');
      return [];
    }
  }

  Future<List<FeedUser>> searchMatches(Map<String, dynamic> filters) async {
    try {
      final cleanedFilters = Map<String, dynamic>.from(filters)
        ..removeWhere((key, value) => value == null || value == '');

      final endpoint = cleanedFilters.containsKey('vendor_status')
          ? '/users/search'
          : '/matches/search';

      debugPrint('[MATCH_REPO] 🔍 Searching with endpoint: $endpoint');
      debugPrint('[MATCH_REPO] 📋 Filters: $cleanedFilters');

      final response = await _apiService.dio.get(
        endpoint,
        queryParameters: cleanedFilters,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        debugPrint('[MATCH_REPO] ✅ Found ${data.length} results');

        if (data.isNotEmpty) {
          debugPrint('[MATCH_REPO] 📦 First result sample:');
          debugPrint('[MATCH_REPO]   - role: ${data[0]['role']}');
          debugPrint(
            '[MATCH_REPO]   - vendor_status: ${data[0]['vendor_status']}',
          );
          debugPrint(
            '[MATCH_REPO]   - vendor_details: ${data[0]['vendor_details']}',
          );
        }

        return data.map((json) => FeedUser.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('[MATCH_REPO] ❌ Error searching: $e');
      return [];
    }
  }

  Future<FeedUser?> getMatchDetails(String userId) async {
    try {
      final response = await _apiService.dio.get('/users/$userId');

      if (response.statusCode == 200) {
        return FeedUser.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching match details: $e');
      return null;
    }
  }

  Future<FeedUser?> getVendorDetails(String vendorId) async {
    try {
      debugPrint('[MATCH_REPO] 🏪 Fetching vendor details: $vendorId');
      final response = await _apiService.dio.get('/users/$vendorId');

      if (response.statusCode == 200) {
        final vendor = FeedUser.fromJson(response.data['data']);
        debugPrint(
          '[MATCH_REPO] ✅ Vendor details loaded: ${vendor.businessName}',
        );
        return vendor;
      }
      return null;
    } catch (e) {
      debugPrint('[MATCH_REPO] ❌ Error fetching vendor details: $e');
      return null;
    }
  }
}
