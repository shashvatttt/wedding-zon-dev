import 'package:flutter/material.dart';
import '../models/feed_user.dart';
import '../models/feed_response.dart';
import '../repositories/feed_repository.dart';
import '../../../core/models/api_response.dart';
import '../../../core/services/image_cache_service.dart';

class FeedProvider extends ChangeNotifier {
  final FeedRepository _feedRepository;

  FeedProvider(this._feedRepository);

  List<FeedUser> _users = [];
  String? _nextCursor;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  bool _hasMore = true;
  String? _currentViewAs;
  bool _isSearchMode = false;
  Map<String, dynamic>? _currentFilters;

  List<FeedUser> get users => _users;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  bool get hasMore => _hasMore;
  bool get isEmpty => _users.isEmpty && !_isLoading;
  String? get currentViewAs => _currentViewAs;

  bool get isSearchMode => _isSearchMode;
  Map<String, dynamic>? get currentFilters => _currentFilters;

  Future<void> loadFeed({
    bool refresh = false,
    String? viewAs,
    bool ignorePrefs = false,
  }) async {
    if (_isLoading) return;

    if (refresh) {
      _users.clear();
      _nextCursor = null;
      _hasMore = true;
      _error = null;
    }

    if (viewAs != _currentViewAs) {
      _users.clear();
      _nextCursor = null;
      _currentViewAs = viewAs;
      _hasMore = true;
      _error = null;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _feedRepository.getFeed(
        cursor: _nextCursor,
        viewAs: _currentViewAs,
        ignorePrefs: ignorePrefs,
      );

      _isLoading = false;

      if (response.success && response.data != null) {
        if (refresh || viewAs != null) {
          _users = response.data!.users;
        } else {
          _users.addAll(response.data!.users);
        }
        _nextCursor = response.data!.nextCursor;
        _hasMore = response.data!.hasMore;

        _preloadUserImages(_users);
      } else {
        _error = response.message;
      }
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
    }
    notifyListeners();
  }

  Future<void> searchUsers(Map<String, dynamic> filters) async {
    if (_isLoading) return;

    _isSearchMode = true;
    _currentFilters = filters;
    _users = [];
    _nextCursor = null;

    _isLoading = true;
    _error = null;
    notifyListeners();

    debugPrint('[FEED] Applying filters: $filters');

    final response = await _feedRepository.searchUsers(filters: filters);

    if (response.success && response.data != null) {
      _users = response.data!.users;
      _nextCursor = response.data!.nextCursor;
      _hasMore = response.data!.hasMore;
      debugPrint(
        '[FEED] Found ${_users.length} users, hasMore: $_hasMore, nextCursor: $_nextCursor',
      );

      _preloadUserImages(_users);
    } else {
      _error = response.message ?? 'Search failed';
      debugPrint('[FEED ERROR] $_error');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore || _nextCursor == null) return;

    _isLoadingMore = true;
    notifyListeners();

    debugPrint(
      '[FEED] Loading more... SearchMode: $_isSearchMode, cursor: $_nextCursor',
    );

    ApiResponse<FeedResponse> response;

    if (_isSearchMode && _currentFilters != null) {
      response = await _feedRepository.searchUsers(
        filters: {..._currentFilters!, 'cursor': _nextCursor},
      );
    } else {
      response = await _feedRepository.getFeed(
        cursor: _nextCursor,
        viewAs: _currentViewAs,
      );
    }

    if (response.success && response.data != null) {
      _users.addAll(response.data!.users);
      _nextCursor = response.data!.nextCursor;
      _hasMore = response.data!.hasMore;

      debugPrint(
        '[FEED] Loaded ${response.data!.users.length} more users, total: ${_users.length}',
      );

      _preloadUserImages(response.data!.users);
    } else {
      debugPrint('[FEED ERROR] Failed to load more: ${response.message}');
    }

    _isLoadingMore = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    debugPrint('[FEED] Refreshing feed... SearchMode: $_isSearchMode');
    _nextCursor = null;
    _hasMore = true;

    if (_isSearchMode && _currentFilters != null) {
      await searchUsers(_currentFilters!);
    } else {
      await loadFeed(viewAs: _currentViewAs);
    }
  }

  void reset() {
    _users = [];
    _nextCursor = null;
    _isLoading = false;
    _isLoadingMore = false;
    _error = null;
    _hasMore = true;
    _isSearchMode = false;
    _currentFilters = null;
    notifyListeners();
  }

  void _preloadUserImages(List<FeedUser> users) {
    try {
      final imageCache = ImageCacheService.instance;
      final imageUrls = <String>[];

      for (final user in users.take(10)) {
        if (user.profilePhoto != null) {
          imageUrls.add(user.profilePhoto!);
        }

        if (user.photos.isNotEmpty) {
          imageUrls.addAll(
            user.photos.take(2).map((photo) => photo.url).toList(),
          );
        }
      }

      if (imageUrls.isNotEmpty) {
        imageCache.preloadFeedImages(imageUrls);
        debugPrint(
          '[FEED_PROVIDER] 🖼️ Preloading ${imageUrls.length} images for ${users.length} users',
        );
      }
    } catch (e) {
      debugPrint('[FEED_PROVIDER] ⚠️ Failed to preload user images: $e');
    }
  }
}
