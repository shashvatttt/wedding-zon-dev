import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CustomImageCacheManager extends CacheManager with ImageCacheManager {
  static const key = 'customImageCache';
  static CustomImageCacheManager? _instance;

  factory CustomImageCacheManager() {
    _instance ??= CustomImageCacheManager._();
    return _instance!;
  }

  CustomImageCacheManager._()
    : super(
        Config(
          key,
          stalePeriod: const Duration(days: 30),
          maxNrOfCacheObjects: 1000,
          repo: JsonCacheInfoRepository(databaseName: key),
          fileService: HttpFileService(),
        ),
      );
}

class ImageCacheService {
  static const String _imageMetadataPrefix = 'image_meta_';
  static const String _preloadQueueKey = 'image_preload_queue';

  static const Duration _imageCacheDuration = Duration(hours: 24);
  static const Duration _metadataCacheDuration = Duration(hours: 1);

  static const int _maxPreloadQueue = 50;
  static const int _preloadBatchSize = 10;

  static ImageCacheService? _instance;
  static ImageCacheService get instance => _instance ??= ImageCacheService._();

  ImageCacheService._();

  String _getCacheKey(String imageUrl) {
    final bytes = utf8.encode(imageUrl);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> preloadFeedImages(List<String> imageUrls) async {
    try {
      debugPrint('[ImageCache] 🔄 Preloading ${imageUrls.length} feed images');

      await _addToPreloadQueue(imageUrls);

      _processPreloadQueue();
    } catch (e) {
      debugPrint('[ImageCache] ❌ Failed to preload feed images: $e');
    }
  }

  Future<void> _addToPreloadQueue(List<String> imageUrls) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingQueue = prefs.getStringList(_preloadQueueKey) ?? [];

      final newUrls = imageUrls
          .where((url) => !existingQueue.contains(url))
          .toList();
      existingQueue.addAll(newUrls);

      if (existingQueue.length > _maxPreloadQueue) {
        existingQueue.removeRange(0, existingQueue.length - _maxPreloadQueue);
      }

      await prefs.setStringList(_preloadQueueKey, existingQueue);
      debugPrint(
        '[ImageCache] 📝 Added ${newUrls.length} images to preload queue (total: ${existingQueue.length})',
      );
    } catch (e) {
      debugPrint('[ImageCache] ❌ Failed to add to preload queue: $e');
    }
  }

  void _processPreloadQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queue = prefs.getStringList(_preloadQueueKey) ?? [];

      if (queue.isEmpty) return;

      final batch = queue.take(_preloadBatchSize).toList();
      debugPrint(
        '[ImageCache] 🔄 Processing preload batch: ${batch.length} images',
      );

      for (final imageUrl in batch) {
        try {
          final isCached = await _isImageCached(imageUrl);
          if (!isCached) {
            CachedNetworkImageProvider(imageUrl);

            debugPrint(
              '[ImageCache] ✅ Queued for preload: ${imageUrl.substring(0, 50)}...',
            );
          }
        } catch (e) {
          debugPrint('[ImageCache] ⚠️ Failed to preload image: $e');
        }
      }

      queue.removeRange(0, batch.length);
      await prefs.setStringList(_preloadQueueKey, queue);

      if (queue.isNotEmpty) {
        Future.delayed(const Duration(milliseconds: 500), _processPreloadQueue);
      }
    } catch (e) {
      debugPrint('[ImageCache] ❌ Failed to process preload queue: $e');
    }
  }

  Future<bool> _isImageCached(String imageUrl) async {
    try {
      final cacheKey = _getCacheKey(imageUrl);
      final prefs = await SharedPreferences.getInstance();
      final metadata = prefs.getString('$_imageMetadataPrefix$cacheKey');

      if (metadata == null) return false;

      final data = jsonDecode(metadata) as Map<String, dynamic>;
      final timestamp = data['timestamp'] as int;
      final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;

      return cacheAge < _imageCacheDuration.inMilliseconds;
    } catch (e) {
      return false;
    }
  }

  Widget buildFeedImage({
    required String imageUrl,
    required BoxFit fit,
    double? width,
    double? height,
    Widget? placeholder,
    Widget? errorWidget,
    Key? key,
  }) {
    final baseUrl = imageUrl.split('?').first;

    return CachedNetworkImage(
      key: key ?? ValueKey(baseUrl),
      imageUrl: imageUrl,
      fit: fit,
      width: width,
      height: height,
      memCacheWidth: width != null && width.isFinite ? width.toInt() : null,
      memCacheHeight: height != null && height.isFinite ? height.toInt() : null,
      placeholder: (context, url) => placeholder ?? _buildDefaultPlaceholder(),
      errorWidget: (context, url, error) =>
          errorWidget ?? _buildDefaultErrorWidget(),

      fadeInDuration: const Duration(milliseconds: 0),
      fadeOutDuration: const Duration(milliseconds: 0),
      useOldImageOnUrlChange: true,
      maxWidthDiskCache: width != null && width.isFinite
          ? (width * 2).toInt()
          : null,
      maxHeightDiskCache: height != null && height.isFinite
          ? (height * 2).toInt()
          : null,

      cacheManager: CustomImageCacheManager(),
      cacheKey: baseUrl,
    );
  }

  Widget buildProfileImage({
    required String imageUrl,
    required double size,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
    Key? key,
  }) {
    final baseUrl = imageUrl.split('?').first;

    return CachedNetworkImage(
      key: key ?? ValueKey(baseUrl),
      imageUrl: imageUrl,
      fit: fit,
      width: size,
      height: size,
      memCacheWidth: size.isFinite ? size.toInt() : null,
      memCacheHeight: size.isFinite ? size.toInt() : null,
      placeholder: (context, url) =>
          placeholder ?? _buildProfilePlaceholder(size),
      errorWidget: (context, url, error) =>
          errorWidget ?? _buildProfileErrorWidget(size),

      fadeInDuration: const Duration(milliseconds: 0),
      fadeOutDuration: const Duration(milliseconds: 0),
      maxWidthDiskCache: size.isFinite ? (size * 2).toInt() : null,
      maxHeightDiskCache: size.isFinite ? (size * 2).toInt() : null,

      cacheManager: CustomImageCacheManager(),
      cacheKey: baseUrl,
    );
  }

  Widget _buildDefaultPlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
        ),
      ),
    );
  }

  Widget _buildDefaultErrorWidget() {
    return Container(
      color: Colors.grey[800],
      child: const Icon(Icons.person, size: 120, color: Colors.white54),
    );
  }

  Widget _buildProfilePlaceholder(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        shape: BoxShape.circle,
      ),
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[600]!),
        ),
      ),
    );
  }

  Widget _buildProfileErrorWidget(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey[400],
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.person, size: size * 0.6, color: Colors.white),
    );
  }

  Future<void> warmUpImageCache(List<String> popularImageUrls) async {
    try {
      debugPrint(
        '[ImageCache] 🔥 Warming up image cache with ${popularImageUrls.length} images',
      );

      await preloadFeedImages(popularImageUrls);

      debugPrint('[ImageCache] ✅ Image cache warm-up initiated');
    } catch (e) {
      debugPrint('[ImageCache] ❌ Failed to warm up image cache: $e');
    }
  }

  Future<void> cleanupExpiredImageCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      final now = DateTime.now().millisecondsSinceEpoch;
      int cleanedCount = 0;

      for (final key in keys) {
        if (key.startsWith(_imageMetadataPrefix)) {
          final cachedData = prefs.getString(key);
          if (cachedData != null) {
            try {
              final data = jsonDecode(cachedData) as Map<String, dynamic>;
              final timestamp = data['timestamp'] as int;
              final cacheAge = now - timestamp;

              if (cacheAge > _metadataCacheDuration.inMilliseconds) {
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

      await CachedNetworkImage.evictFromCache('');

      if (cleanedCount > 0) {
        debugPrint(
          '[ImageCache] 🧹 Cleaned $cleanedCount expired image cache entries',
        );
      }
    } catch (e) {
      debugPrint('[ImageCache] ❌ Failed to cleanup image cache: $e');
    }
  }

  Future<Map<String, dynamic>> getImageCacheStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();

      int metadataCount = 0;
      int totalMetadataSize = 0;
      int preloadQueueSize = 0;
      DateTime? oldestEntry;
      DateTime? newestEntry;

      for (final key in keys) {
        if (key.startsWith(_imageMetadataPrefix)) {
          metadataCount++;
          final data = prefs.getString(key);
          if (data != null) {
            totalMetadataSize += data.length;
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
        } else if (key == _preloadQueueKey) {
          final queue = prefs.getStringList(key) ?? [];
          preloadQueueSize = queue.length;
        }
      }

      return {
        'metadataCount': metadataCount,
        'totalMetadataSizeBytes': totalMetadataSize,
        'totalMetadataSizeKB': (totalMetadataSize / 1024).round(),
        'preloadQueueSize': preloadQueueSize,
        'oldestEntry': oldestEntry?.toIso8601String(),
        'newestEntry': newestEntry?.toIso8601String(),
        'cacheAge': oldestEntry != null
            ? DateTime.now().difference(oldestEntry).inHours
            : 0,
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  Future<void> clearAllImageCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();

      for (final key in keys) {
        if (key.startsWith(_imageMetadataPrefix) || key == _preloadQueueKey) {
          await prefs.remove(key);
        }
      }

      await CachedNetworkImage.evictFromCache('');

      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();

      debugPrint('[ImageCache] 🗑️ Cleared all image cache');
    } catch (e) {
      debugPrint('[ImageCache] ❌ Failed to clear image cache: $e');
    }
  }

  Future<void> preloadUserImages(List<String> imageUrls) async {
    try {
      debugPrint(
        '[ImageCache] 👤 Preloading ${imageUrls.length} user profile images',
      );

      for (final imageUrl in imageUrls.take(5)) {
        try {
          final isCached = await _isImageCached(imageUrl);
          if (!isCached) {
            CachedNetworkImageProvider(imageUrl);
          }
        } catch (e) {
          debugPrint('[ImageCache] ⚠️ Failed to preload user image: $e');
        }
      }

      debugPrint('[ImageCache] ✅ User images queued for preloading');
    } catch (e) {
      debugPrint('[ImageCache] ❌ Failed to preload user images: $e');
    }
  }
}
