import 'package:flutter/material.dart';
import '../../feed/models/feed_user.dart';
import '../repositories/match_repository.dart';
import '../../../core/services/vendor_cache_service.dart';

class MatchProvider extends ChangeNotifier {
  final MatchRepository _repository;

  bool _isLoading = false;
  List<FeedUser> _matches = [];
  List<FeedUser> _searchResults = [];
  String? _error;

  int _currentPage = 1;
  bool _hasMore = true;
  static const int _limit = 10;

  Map<String, dynamic> _activeFilters = {};

  MatchProvider(this._repository) {
    _initializeCache();
  }

  Future<void> _initializeCache() async {
    final cache = VendorCacheService.instance;

    await cache.cleanupExpiredCache();

    await cache.warmUpCache();
  }

  bool get isLoading => _isLoading;
  List<FeedUser> get matches => _matches;
  List<FeedUser> get searchResults => _searchResults;
  String? get error => _error;
  bool get hasMore => _hasMore;
  Map<String, dynamic> get activeFilters => _activeFilters;

  Future<void> loadMatches({bool refresh = false}) async {
    if (_isLoading) return;
    if (refresh) {
      _currentPage = 1;
      _matches = [];
      _hasMore = true;
    }

    if (!_hasMore) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newMatches = await _repository.getRecommendedMatches(
        page: _currentPage,
        limit: _limit,
      );

      if (newMatches.length < _limit) {
        _hasMore = false;
      }

      if (refresh) {
        _matches = newMatches;
      } else {
        _matches.addAll(newMatches);
      }

      _currentPage++;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> search(Map<String, dynamic> filters) async {
    debugPrint('[MATCH_PROVIDER] ========================================');
    debugPrint('[MATCH_PROVIDER] 🔍 Starting search with caching');
    debugPrint('[MATCH_PROVIDER] 📋 Filters: $filters');

    final cache = VendorCacheService.instance;
    final category = filters['service_type'] as String?;
    final searchQuery = filters['search'] as String?;

    final cacheHealth = await getCacheHealth();
    debugPrint(
      '[MATCH_PROVIDER] 📊 Cache Health: ${cacheHealth['totalSizeKB']}KB, ${cacheHealth['vendorDetailsCount']} details cached',
    );

    final cachedResults = await cache.getCachedVendorList(
      category: category,
      searchQuery: searchQuery,
    );

    if (cachedResults != null) {
      debugPrint(
        '[MATCH_PROVIDER] 📱 Loaded ${cachedResults.length} vendors from cache',
      );
      _searchResults = cachedResults;
      _activeFilters = filters;
      _error = null;
      notifyListeners();

      cache.preloadVendorDetails(cachedResults);
    }

    final shouldRefresh = await cache.shouldRefreshCache(
      category: category,
      searchQuery: searchQuery,
    );

    if (shouldRefresh || cachedResults == null) {
      debugPrint('[MATCH_PROVIDER] 🌐 Fetching fresh data from backend');
      _isLoading = true;
      _error = null;
      _activeFilters = filters;

      if (cachedResults == null) {
        _searchResults = [];
      }
      notifyListeners();

      try {
        final freshResults = await _repository.searchMatches(filters);

        debugPrint('[MATCH_PROVIDER] ========================================');
        debugPrint('[MATCH_PROVIDER] ✅ Fresh search completed');
        debugPrint('[MATCH_PROVIDER] 📊 Results count: ${freshResults.length}');

        await cache.cacheVendorList(
          freshResults,
          category: category,
          searchQuery: searchQuery,
        );

        _searchResults = freshResults;

        if (freshResults.isNotEmpty) {
          debugPrint('[MATCH_PROVIDER] 📦 First result:');
          final first = freshResults.first;
          debugPrint('[MATCH_PROVIDER]   - Username: ${first.username}');
          debugPrint('[MATCH_PROVIDER]   - Role: ${first.role}');
          debugPrint(
            '[MATCH_PROVIDER]   - Vendor Status: ${first.vendorStatus}',
          );
          debugPrint(
            '[MATCH_PROVIDER]   - Business Name: ${first.businessName}',
          );
          debugPrint('[MATCH_PROVIDER]   - Service Type: ${first.serviceType}');
          debugPrint('[MATCH_PROVIDER]   - Photos: ${first.photos.length}');

          cache.preloadVendorDetails(freshResults);
        } else {
          debugPrint('[MATCH_PROVIDER] ⚠️ No results found');
          debugPrint('[MATCH_PROVIDER] 💡 Possible reasons:');
          debugPrint(
            '[MATCH_PROVIDER]   1. No vendors with vendor_status=active in database',
          );
          debugPrint(
            '[MATCH_PROVIDER]   2. Backend not returning vendor users',
          );
          debugPrint('[MATCH_PROVIDER]   3. Filters too restrictive');
        }
        debugPrint('[MATCH_PROVIDER] ========================================');
      } catch (e) {
        debugPrint('[MATCH_PROVIDER] ❌ Error: $e');
        _error = e.toString();

        if (cachedResults != null) {
          debugPrint('[MATCH_PROVIDER] 📱 Network failed, keeping cached data');
          _error = null;
        }
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    } else {
      debugPrint('[MATCH_PROVIDER] ✅ Cache is fresh, no backend call needed');
    }
  }

  void removeFilter(String key) {
    if (_activeFilters.containsKey(key)) {
      final newFilters = Map<String, dynamic>.from(_activeFilters);
      newFilters.remove(key);
      search(newFilters);
    }
  }

  void clearSearch() {
    _activeFilters = {};
    _searchResults = [];
    notifyListeners();
  }

  Future<FeedUser?> getVendorDetails(String vendorId) async {
    final cache = VendorCacheService.instance;

    final cachedVendor = await cache.getCachedVendorDetails(vendorId);
    if (cachedVendor != null) {
      debugPrint(
        '[MATCH_PROVIDER] 📱 Loaded vendor details from cache: ${cachedVendor.businessName}',
      );
      return cachedVendor;
    }

    try {
      debugPrint(
        '[MATCH_PROVIDER] 🌐 Fetching vendor details from backend: $vendorId',
      );
      final vendor = await _repository.getVendorDetails(vendorId);

      if (vendor != null) {
        await cache.cacheVendorDetails(vendor);
        debugPrint(
          '[MATCH_PROVIDER] ✅ Cached vendor details: ${vendor.businessName}',
        );
      }

      return vendor;
    } catch (e) {
      debugPrint('[MATCH_PROVIDER] ❌ Failed to fetch vendor details: $e');
      return null;
    }
  }

  Future<void> clearVendorCache() async {
    await VendorCacheService.instance.clearCache();
    debugPrint('[MATCH_PROVIDER] 🗑️ Cleared all vendor cache');
  }

  Future<void> refreshVendorCache({
    String? category,
    String? searchQuery,
  }) async {
    final cache = VendorCacheService.instance;

    if (category != null || searchQuery != null) {
      await cache.clearCache();
    } else {
      await cache.clearCache();
    }

    if (category != null || searchQuery != null) {
      final filters = <String, dynamic>{};
      if (category != null) filters['service_type'] = category;
      if (searchQuery != null) filters['search'] = searchQuery;
      await search(filters);
    }

    debugPrint('[MATCH_PROVIDER] 🔄 Refreshed vendor cache');
  }

  Future<Map<String, dynamic>> getCacheStats() async {
    return await VendorCacheService.instance.getCacheStats();
  }

  Future<Map<String, dynamic>> getCacheHealth() async {
    final cache = VendorCacheService.instance;
    final stats = await cache.getCacheStats();

    final shouldRefreshMain = await cache.shouldRefreshCache();

    return {
      ...stats,
      'mainCacheNeedsRefresh': shouldRefreshMain,
      'cacheServiceInitialized': true,
      'lastHealthCheck': DateTime.now().toIso8601String(),
    };
  }
}
