import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class CacheService {
  static CacheService? _instance;
  static CacheService get instance => _instance ??= CacheService._();

  CacheService._();

  Future<void> initialize() async {
    try {
      debugPrint('[CACHE] Initializing cache service...');
      final cacheDir = await getTemporaryDirectory();
      debugPrint('[CACHE] Cache directory: ${cacheDir.path}');
      debugPrint('[CACHE] Cache service initialized successfully');
    } catch (e) {
      debugPrint('[CACHE] Failed to initialize cache service: $e');
    }
  }

  Future<void> clearAllCaches() async {
    try {
      debugPrint('[CACHE] Clearing all caches...');
      final cacheDir = await getTemporaryDirectory();

      if (await cacheDir.exists()) {
        await for (var entity in cacheDir.list(recursive: true)) {
          if (entity is File) {
            try {
              await entity.delete();
            } catch (e) {
              debugPrint('[CACHE] Failed to delete file: ${entity.path}');
            }
          }
        }
      }

      debugPrint('[CACHE] All caches cleared successfully');
    } catch (e) {
      debugPrint('[CACHE] Failed to clear caches: $e');
    }
  }

  Future<int> getCacheSize() async {
    try {
      final cacheDir = await getTemporaryDirectory();
      int totalSize = 0;

      if (await cacheDir.exists()) {
        await for (var entity in cacheDir.list(recursive: true)) {
          if (entity is File) {
            totalSize += await entity.length();
          }
        }
      }

      debugPrint(
        '[CACHE] Total cache size: ${(totalSize / 1024 / 1024).toStringAsFixed(2)} MB',
      );
      return totalSize;
    } catch (e) {
      debugPrint('[CACHE] Failed to get cache size: $e');
      return 0;
    }
  }
}
