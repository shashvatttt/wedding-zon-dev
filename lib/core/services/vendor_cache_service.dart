import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/feed/models/feed_user.dart';

class VendorCacheService {
  static const String _vendorListKey = 'cached_vendor_list';
  static const String _vendorDetailsPrefix = 'cached_vendor_details_';
  static const String _lastUpdateKey = 'vendor_cache_last_update';
  static const String _searchCachePrefix = 'vendor_search_';

  static const Duration _listCacheDuration = Duration(minutes: 30);
  static const Duration _detailsCacheDuration = Duration(hours: 1);
  static const Duration _searchCacheDuration = Duration(minutes: 15);

  static VendorCacheService? _instance;
  static VendorCacheService get instance =>
      _instance ??= VendorCacheService._();

  VendorCacheService._();

  Future<void> cacheVendorList(
    List<FeedUser> vendors, {
    String? category,
    String? searchQuery,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final cacheData = {
        'vendors': vendors.map((v) => v.toJson()).toList(),
        'timestamp': timestamp,
        'category': category,
        'searchQuery': searchQuery,
        'count': vendors.length,
      };

      if (category == null && searchQuery == null) {
        await prefs.setString(_vendorListKey, jsonEncode(cacheData));
        await prefs.setInt(_lastUpdateKey, timestamp);
      }

      if (searchQuery != null || category != null) {
        final searchKey = _getSearchCacheKey(category, searchQuery);
        await prefs.setString(searchKey, jsonEncode(cacheData));
      }

      debugPrint('[VendorCache] ✅ Cached ${vendors.length} vendors');
    } catch (e) {
      debugPrint('[VendorCache] ❌ Failed to cache vendor list: $e');
    }
  }

  Future<List<FeedUser>?> getCachedVendorList({
    String? category,
    String? searchQuery,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? cacheKey;

      if (searchQuery != null || category != null) {
        cacheKey = _getSearchCacheKey(category, searchQuery);
      } else {
        cacheKey = _vendorListKey;
      }

      final cachedData = prefs.getString(cacheKey);
      if (cachedData == null) return null;

      final data = jsonDecode(cachedData) as Map<String, dynamic>;
      final timestamp = data['timestamp'] as int;
      final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;

      Duration cacheDuration = _listCacheDuration;
      if (searchQuery != null || category != null) {
        cacheDuration = _searchCacheDuration;
      }

      if (cacheAge > cacheDuration.inMilliseconds) {
        debugPrint(
          '[VendorCache] ⏰ Cache expired, age: ${Duration(milliseconds: cacheAge).inMinutes}min',
        );
        return null;
      }

      final vendorList = (data['vendors'] as List)
          .map((json) => FeedUser.fromJson(json))
          .toList();

      debugPrint(
        '[VendorCache] 📱 Loaded ${vendorList.length} vendors from cache',
      );
      return vendorList;
    } catch (e) {
      debugPrint('[VendorCache] ❌ Failed to load cached vendor list: $e');
      return null;
    }
  }

  Future<void> cacheVendorDetails(FeedUser vendor) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final cacheData = {'vendor': vendor.toJson(), 'timestamp': timestamp};

      await prefs.setString(
        '$_vendorDetailsPrefix${vendor.id}',
        jsonEncode(cacheData),
      );

      debugPrint(
        '[VendorCache] ✅ Cached details for vendor: ${vendor.businessName}',
      );
    } catch (e) {
      debugPrint('[VendorCache] ❌ Failed to cache vendor details: $e');
    }
  }

  Future<FeedUser?> getCachedVendorDetails(String vendorId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('$_vendorDetailsPrefix$vendorId');
      if (cachedData == null) return null;

      final data = jsonDecode(cachedData) as Map<String, dynamic>;
      final timestamp = data['timestamp'] as int;
      final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;

      if (cacheAge > _detailsCacheDuration.inMilliseconds) {
        debugPrint(
          '[VendorCache] ⏰ Details cache expired for vendor: $vendorId',
        );
        return null;
      }

      final vendor = FeedUser.fromJson(data['vendor']);
      debugPrint(
        '[VendorCache] 📱 Loaded vendor details from cache: ${vendor.businessName}',
      );
      return vendor;
    } catch (e) {
      debugPrint('[VendorCache] ❌ Failed to load cached vendor details: $e');
      return null;
    }
  }

  Future<bool> shouldRefreshCache({
    String? category,
    String? searchQuery,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? cacheKey;

      if (searchQuery != null || category != null) {
        cacheKey = _getSearchCacheKey(category, searchQuery);
      } else {
        cacheKey = _vendorListKey;
      }

      final cachedData = prefs.getString(cacheKey);
      if (cachedData == null) return true;

      final data = jsonDecode(cachedData) as Map<String, dynamic>;
      final timestamp = data['timestamp'] as int;
      final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;

      Duration cacheDuration = _listCacheDuration;
      if (searchQuery != null || category != null) {
        cacheDuration = _searchCacheDuration;
      }

      return cacheAge > cacheDuration.inMilliseconds;
    } catch (e) {
      return true;
    }
  }

  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();

      for (final key in keys) {
        if (key.startsWith(_vendorDetailsPrefix) ||
            key.startsWith(_searchCachePrefix) ||
            key == _vendorListKey ||
            key == _lastUpdateKey) {
          await prefs.remove(key);
        }
      }

      debugPrint('[VendorCache] 🗑️ Cleared all vendor cache');
    } catch (e) {
      debugPrint('[VendorCache] ❌ Failed to clear cache: $e');
    }
  }

  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();

      int vendorListCount = 0;
      int vendorDetailsCount = 0;
      int searchCacheCount = 0;
      int totalSize = 0;
      DateTime? oldestEntry;
      DateTime? newestEntry;

      for (final key in keys) {
        if (key == _vendorListKey) {
          vendorListCount++;
          final data = prefs.getString(key);
          if (data != null) {
            totalSize += data.length;
            try {
              final json = jsonDecode(data) as Map<String, dynamic>;
              final timestamp = DateTime.fromMillisecondsSinceEpoch(
                json['timestamp'],
              );
              if (oldestEntry == null || timestamp.isBefore(oldestEntry)) {
                oldestEntry = timestamp;
              }
              if (newestEntry == null || timestamp.isAfter(newestEntry)) {
                newestEntry = timestamp;
              }
            } catch (e) {}
          }
        } else if (key.startsWith(_vendorDetailsPrefix)) {
          vendorDetailsCount++;
          final data = prefs.getString(key);
          if (data != null) {
            totalSize += data.length;
            try {
              final json = jsonDecode(data) as Map<String, dynamic>;
              final timestamp = DateTime.fromMillisecondsSinceEpoch(
                json['timestamp'],
              );
              if (oldestEntry == null || timestamp.isBefore(oldestEntry)) {
                oldestEntry = timestamp;
              }
              if (newestEntry == null || timestamp.isAfter(newestEntry)) {
                newestEntry = timestamp;
              }
            } catch (e) {}
          }
        } else if (key.startsWith(_searchCachePrefix)) {
          searchCacheCount++;
          final data = prefs.getString(key);
          if (data != null) {
            totalSize += data.length;
            try {
              final json = jsonDecode(data) as Map<String, dynamic>;
              final timestamp = DateTime.fromMillisecondsSinceEpoch(
                json['timestamp'],
              );
              if (oldestEntry == null || timestamp.isBefore(oldestEntry)) {
                oldestEntry = timestamp;
              }
              if (newestEntry == null || timestamp.isAfter(newestEntry)) {
                newestEntry = timestamp;
              }
            } catch (e) {}
          }
        }
      }

      return {
        'vendorListCount': vendorListCount,
        'vendorDetailsCount': vendorDetailsCount,
        'searchCacheCount': searchCacheCount,
        'totalSizeBytes': totalSize,
        'totalSizeKB': (totalSize / 1024).round(),
        'totalSizeMB': (totalSize / (1024 * 1024)).toStringAsFixed(2),
        'oldestEntry': oldestEntry?.toIso8601String(),
        'newestEntry': newestEntry?.toIso8601String(),
        'cacheAge': oldestEntry != null
            ? DateTime.now().difference(oldestEntry).inMinutes
            : 0,
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  String _getSearchCacheKey(String? category, String? searchQuery) {
    final parts = <String>[];
    if (category != null) parts.add('cat_$category');
    if (searchQuery != null) parts.add('q_$searchQuery');
    return '$_searchCachePrefix${parts.join('_')}';
  }

  Future<void> preloadVendorDetails(List<FeedUser> vendors) async {
    final vendorsToPreload = vendors.take(10);

    for (final vendor in vendorsToPreload) {
      final cached = await getCachedVendorDetails(vendor.id);
      if (cached == null) {
        await cacheVendorDetails(vendor);
      }
    }
  }

  Future<void> warmUpCache() async {
    try {
      debugPrint('[VendorCache] 🔥 Warming up cache...');

      final cachedVendors = await getCachedVendorList();
      if (cachedVendors != null && cachedVendors.isNotEmpty) {
        await preloadVendorDetails(cachedVendors);
        debugPrint(
          '[VendorCache] ✅ Cache warmed with ${cachedVendors.length} vendors',
        );
      } else {
        debugPrint('[VendorCache] ℹ️ No cached vendors found for warming');
      }
    } catch (e) {
      debugPrint('[VendorCache] ❌ Failed to warm cache: $e');
    }
  }

  Future<void> cleanupExpiredCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      final now = DateTime.now().millisecondsSinceEpoch;
      int cleanedCount = 0;

      for (final key in keys) {
        if (key.startsWith(_vendorDetailsPrefix) ||
            key.startsWith(_searchCachePrefix) ||
            key == _vendorListKey) {
          final cachedData = prefs.getString(key);
          if (cachedData != null) {
            try {
              final data = jsonDecode(cachedData) as Map<String, dynamic>;
              final timestamp = data['timestamp'] as int;
              final cacheAge = now - timestamp;

              Duration expiration = _listCacheDuration;
              if (key.startsWith(_vendorDetailsPrefix)) {
                expiration = _detailsCacheDuration;
              } else if (key.startsWith(_searchCachePrefix)) {
                expiration = _searchCacheDuration;
              }

              if (cacheAge > expiration.inMilliseconds) {
                await prefs.remove(key);
                cleanedCount++;
              }
            } catch (e) {
              await prefs.remove(key);
              cleanedCount++;
            }
          }
        }
      }

      if (cleanedCount > 0) {
        debugPrint(
          '[VendorCache] 🧹 Cleaned $cleanedCount expired cache entries',
        );
      }
    } catch (e) {
      debugPrint('[VendorCache] ❌ Failed to cleanup cache: $e');
    }
  }
}
