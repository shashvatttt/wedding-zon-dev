import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
import 'navigation_service.dart';
import 'api_service.dart';
import 'toast_service.dart';
import '../../features/matches/repositories/match_repository.dart';

class DeepLinkService {
  final NavigationService _navigationService;
  final ApiService _apiService;
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;
  bool _isAuthenticated = false;
  final _toast = ToastService();

  String? _pendingUsername;
  String? _pendingProfileType;

  DateTime? _lastNavigationTime;
  static const _debounceMilliseconds = 500;

  static const _allowedHosts = [
    'dev.d34g4kpybwb3xb.amplifyapp.com',
    'd34g4kpybwb3xb.amplifyapp.com',
  ];

  DeepLinkService(this._navigationService, this._apiService);

  String? get pendingUsername => _pendingUsername;
  String? get pendingProfileType => _pendingProfileType;

  void clearPendingUsername() {
    debugPrint('[DeepLink] Clearing pending username: $_pendingUsername');
    _pendingUsername = null;
    _pendingProfileType = null;
  }

  void updateAuthStatus(bool isAuthenticated) {
    debugPrint('[DeepLink] ========================================');
    debugPrint('[DeepLink] AUTH STATUS UPDATE');
    debugPrint('[DeepLink] Previous: $_isAuthenticated');
    debugPrint('[DeepLink] New: $isAuthenticated');
    debugPrint('[DeepLink] Pending username: $_pendingUsername');
    debugPrint('[DeepLink] ========================================');

    _isAuthenticated = isAuthenticated;

    if (isAuthenticated && _pendingUsername != null) {
      debugPrint('[DeepLink] ✅ User authenticated with pending deep link!');
      debugPrint('[DeepLink] Will navigate to profile: $_pendingUsername');

      Future.delayed(const Duration(milliseconds: 300), () {
        if (_pendingUsername != null) {
          navigateToPendingProfile();
        }
      });
    }
  }

  Future<void> initialize({required bool isAuthenticated}) async {
    debugPrint('[DeepLink] ========================================');
    debugPrint('[DeepLink] INITIALIZING DEEP LINK SERVICE');
    debugPrint('[DeepLink] isAuthenticated: $isAuthenticated');
    debugPrint('[DeepLink] Timestamp: ${DateTime.now()}');
    debugPrint('[DeepLink] ========================================');

    _isAuthenticated = isAuthenticated;

    try {
      debugPrint('[DeepLink] 🥶 Checking for COLD START link...');
      debugPrint('[DeepLink] Calling _appLinks.getInitialLink()...');

      final initialUri = await _appLinks.getInitialLink();

      debugPrint(
        '[DeepLink] getInitialLink() returned: ${initialUri?.toString() ?? "null"}',
      );

      if (initialUri != null) {
        debugPrint('[DeepLink] ========================================');
        debugPrint('[DeepLink] ✅✅✅ COLD START LINK DETECTED! ✅✅✅');
        debugPrint('[DeepLink] Full URL: $initialUri');
        debugPrint('[DeepLink] Scheme: ${initialUri.scheme}');
        debugPrint('[DeepLink] Host: ${initialUri.host}');
        debugPrint('[DeepLink] Path: ${initialUri.path}');
        debugPrint('[DeepLink] Path Segments: ${initialUri.pathSegments}');
        debugPrint(
          '[DeepLink] Query Parameters: ${initialUri.queryParameters}',
        );
        debugPrint('[DeepLink] Fragment: ${initialUri.fragment}');
        debugPrint(
          '[DeepLink] isAuthenticated at this moment: $_isAuthenticated',
        );
        debugPrint('[DeepLink] ========================================');
        await _handleDeepLink(initialUri, isColdStart: true);
      } else {
        debugPrint(
          '[DeepLink] ℹ️ No cold start link detected (normal app launch)',
        );
        debugPrint(
          '[DeepLink] This is expected if user opened app from launcher',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('[DeepLink] ❌❌❌ ERROR getting initial link: $e');
      debugPrint('[DeepLink] Error type: ${e.runtimeType}');
      debugPrint('[DeepLink] Stack trace: $stackTrace');
      debugPrint('[DeepLink] This may indicate a platform configuration issue');
    }

    debugPrint('[DeepLink] 🔥 Setting up WARM START listener...');
    debugPrint('[DeepLink] Cancelling any existing subscription...');
    _linkSubscription?.cancel();

    debugPrint('[DeepLink] Creating new uriLinkStream subscription...');
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) {
        debugPrint('[DeepLink] ========================================');
        debugPrint('[DeepLink] ✅✅✅ WARM START LINK RECEIVED! ✅✅✅');
        debugPrint('[DeepLink] Full URL: $uri');
        debugPrint('[DeepLink] Scheme: ${uri.scheme}');
        debugPrint('[DeepLink] Host: ${uri.host}');
        debugPrint('[DeepLink] Path: ${uri.path}');
        debugPrint('[DeepLink] Path Segments: ${uri.pathSegments}');
        debugPrint('[DeepLink] Timestamp: ${DateTime.now()}');
        debugPrint('[DeepLink] ========================================');
        _handleDeepLink(uri, isColdStart: false);
      },
      onError: (err) {
        debugPrint('[DeepLink] ❌ Error in link stream: $err');
        debugPrint('[DeepLink] Error type: ${err.runtimeType}');
      },
    );

    debugPrint('[DeepLink] ========================================');
    debugPrint('[DeepLink] ✅ DEEP LINK SERVICE INITIALIZED SUCCESSFULLY');
    debugPrint('[DeepLink] Cold start check: COMPLETE');
    debugPrint('[DeepLink] Warm start listener: ACTIVE');
    debugPrint('[DeepLink] Auth status: $_isAuthenticated');
    debugPrint('[DeepLink] Pending username: $_pendingUsername');
    debugPrint('[DeepLink] ========================================');
  }

  Future<void> _handleDeepLink(Uri uri, {required bool isColdStart}) async {
    debugPrint('[DeepLink] ----------------------------------------');
    debugPrint('[DeepLink] PROCESSING DEEP LINK');
    debugPrint('[DeepLink] Type: ${isColdStart ? "COLD START" : "WARM START"}');
    debugPrint('[DeepLink] URL: $uri');
    debugPrint('[DeepLink] isAuthenticated: $_isAuthenticated');
    debugPrint('[DeepLink] ----------------------------------------');

    debugPrint('[DeepLink] Step 1: Validating domain...');
    if (!_isValidHost(uri.host)) {
      debugPrint('[DeepLink] ❌ INVALID HOST: ${uri.host}');
      debugPrint('[DeepLink] Allowed hosts: $_allowedHosts');
      debugPrint('[DeepLink] Link REJECTED for security');
      _handleInvalidLink('Invalid link domain');
      return;
    }
    debugPrint('[DeepLink] ✅ Domain validated: ${uri.host}');

    debugPrint('[DeepLink] Step 2: Checking debounce...');
    if (_shouldDebounce()) {
      final timeSinceLastNav = DateTime.now()
          .difference(_lastNavigationTime!)
          .inMilliseconds;
      debugPrint(
        '[DeepLink] ⏸️ DEBOUNCED! Last navigation was ${timeSinceLastNav}ms ago',
      );
      debugPrint('[DeepLink] Ignoring duplicate navigation');
      return;
    }
    debugPrint('[DeepLink] ✅ Debounce check passed');

    debugPrint('[DeepLink] Step 3: Extracting username...');
    debugPrint('[DeepLink] Path segments: ${uri.pathSegments}');
    final username = _extractUsername(uri);
    if (username == null) {
      debugPrint('[DeepLink] ❌ NO USERNAME found in URL');
      debugPrint('[DeepLink] Path: ${uri.path}');
      debugPrint('[DeepLink] Link REJECTED');
      _handleInvalidLink('Invalid profile link');
      return;
    }
    debugPrint('[DeepLink] ✅ Username extracted: "$username"');

    debugPrint('[DeepLink] Step 4: Sanitizing username...');
    final sanitizedUsername = _sanitizeUsername(username);
    debugPrint('[DeepLink] Original: "$username"');
    debugPrint('[DeepLink] Sanitized: "$sanitizedUsername"');

    if (sanitizedUsername.isEmpty) {
      debugPrint('[DeepLink] ❌ USERNAME EMPTY after sanitization');
      debugPrint('[DeepLink] Link REJECTED for security');
      _handleInvalidLink('Invalid username format');
      return;
    }
    debugPrint('[DeepLink] ✅ Username sanitized and valid');

    debugPrint('[DeepLink] Step 5: Handling navigation...');

    if (isColdStart) {
      debugPrint('[DeepLink] ========================================');
      debugPrint('[DeepLink] 🥶 COLD START - Fetching user data');
      debugPrint('[DeepLink] Username: $sanitizedUsername');
      debugPrint('[DeepLink] Auth status: $_isAuthenticated');

      try {
        final repository = MatchRepository(_apiService);
        final user = await repository.getMatchDetails(sanitizedUsername);

        if (user != null) {
          _pendingUsername = sanitizedUsername;
          _pendingProfileType = user.role == 'vendor' ? 'vendor' : 'user';

          debugPrint('[DeepLink] ✅ User data fetched successfully');
          debugPrint('[DeepLink] Profile type: $_pendingProfileType');
          debugPrint('[DeepLink] Stored as pending for later navigation');
        } else {
          debugPrint('[DeepLink] ⚠️ User not found, storing username only');
          _pendingUsername = sanitizedUsername;
          _pendingProfileType = null;
        }
      } catch (e) {
        debugPrint('[DeepLink] ⚠️ Failed to fetch user data: $e');
        debugPrint(
          '[DeepLink] Storing username only, will determine type later',
        );
        _pendingUsername = sanitizedUsername;
        _pendingProfileType = null;
      }

      if (_isAuthenticated) {
        debugPrint('[DeepLink] ✅ User authenticated');
        debugPrint(
          '[DeepLink] Splash screen will route to home, then to profile',
        );
      } else {
        debugPrint('[DeepLink] ⚠️ User not authenticated');
        debugPrint(
          '[DeepLink] Splash screen will route to auth, then to profile after login',
        );
      }
      debugPrint('[DeepLink] ========================================');
      return;
    }

    if (!_isAuthenticated) {
      debugPrint('[DeepLink] ========================================');
      debugPrint('[DeepLink] ⚠️ USER NOT AUTHENTICATED (Warm Start)');
      debugPrint('[DeepLink] Storing pending username: $sanitizedUsername');
      _pendingUsername = sanitizedUsername;

      debugPrint('[DeepLink] 🔐 Navigating to AUTH CHOICE SCREEN');
      debugPrint(
        '[DeepLink] After login, will navigate to: $sanitizedUsername',
      );
      debugPrint('[DeepLink] ========================================');

      try {
        _navigationService.navigateAndClearStack(AppRoutes.landing);
        debugPrint(
          '[DeepLink] ✅ Navigated to auth choice screen with proper stack',
        );
      } catch (e) {
        debugPrint('[DeepLink] ❌ Failed to navigate to auth: $e');
      }

      return;
    }

    debugPrint('[DeepLink] ✅ User is authenticated (Warm Start)');

    debugPrint('[DeepLink] Step 6: Navigating to profile...');
    await _navigateToProfile(sanitizedUsername);
    debugPrint('[DeepLink] ----------------------------------------');
  }

  Future<void> _navigateToProfile(String username) async {
    debugPrint('[DeepLink] ========================================');
    debugPrint('[DeepLink] 🚀 NAVIGATING TO PROFILE');
    debugPrint('[DeepLink] Username: $username');
    debugPrint('[DeepLink] Fetching user data to determine profile type...');
    debugPrint('[DeepLink] ========================================');

    _lastNavigationTime = DateTime.now();

    try {
      final repository = MatchRepository(_apiService);
      final user = await repository.getMatchDetails(username);

      if (user == null) {
        debugPrint('[DeepLink] ❌ User not found: $username');
        throw Exception('User not found');
      }

      String targetRoute;
      if (user.role == 'vendor') {
        targetRoute = AppRoutes.vendorProfile;
        debugPrint('[DeepLink] ✅ User is a VENDOR');
        debugPrint('[DeepLink] Route: $targetRoute');
        debugPrint('[DeepLink] Target: VendorProfileScreen($username)');
      } else {
        targetRoute = AppRoutes.userProfileView;
        debugPrint('[DeepLink] ✅ User is a REGULAR USER');
        debugPrint('[DeepLink] Route: $targetRoute');
        debugPrint('[DeepLink] Target: UserProfileViewUI($username)');
      }

      _navigationService.navigateFromNotification(
        targetRoute,
        arguments: username,
      );
      debugPrint(
        '[DeepLink] ✅ Navigation initiated successfully with proper stack',
      );
    } catch (e, stackTrace) {
      debugPrint('[DeepLink] ❌ NAVIGATION FAILED: $e');
      debugPrint('[DeepLink] Stack trace: $stackTrace');

      _toast.error('Profile not found');

      try {
        _navigationService.navigateFromNotification(AppRoutes.home);
        debugPrint(
          '[DeepLink] ✅ Navigated to home as fallback with proper stack',
        );
      } catch (fallbackError) {
        debugPrint(
          '[DeepLink] ❌ FALLBACK NAVIGATION ALSO FAILED: $fallbackError',
        );
      }
    }
    debugPrint('[DeepLink] ========================================');
  }

  void _handleInvalidLink(String reason) {
    debugPrint('[DeepLink] ========================================');
    debugPrint('[DeepLink] ❌ INVALID LINK DETECTED');
    debugPrint('[DeepLink] Reason: $reason');
    debugPrint('[DeepLink] Auth status: $_isAuthenticated');
    debugPrint('[DeepLink] ========================================');

    _toast.show('Invalid link');

    try {
      if (_isAuthenticated) {
        debugPrint('[DeepLink] Navigating to home (user logged in)');
        _navigationService.navigateFromNotification(AppRoutes.home);
      } else {
        debugPrint('[DeepLink] Navigating to auth choice (user logged out)');
        _navigationService.navigateFromNotification(AppRoutes.landing);
      }
      debugPrint(
        '[DeepLink] ✅ Fallback navigation successful with proper stack',
      );
    } catch (e) {
      debugPrint('[DeepLink] ❌ Fallback navigation failed: $e');
    }
  }

  Future<void> navigateToPendingProfile() async {
    debugPrint('[DeepLink] ========================================');
    debugPrint('[DeepLink] CHECKING PENDING PROFILE');
    debugPrint('[DeepLink] Pending username: $_pendingUsername');
    debugPrint('[DeepLink] Pending profile type: $_pendingProfileType');
    debugPrint('[DeepLink] Is authenticated: $_isAuthenticated');

    if (_pendingUsername != null) {
      if (!_isAuthenticated) {
        debugPrint('[DeepLink] ⚠️ Cannot navigate: User not authenticated');
        debugPrint('[DeepLink] Pending username will be retained');
        return;
      }

      debugPrint(
        '[DeepLink] ✅ Navigating to pending profile: $_pendingUsername',
      );
      final username = _pendingUsername!;
      final profileType = _pendingProfileType;

      try {
        if (profileType != null) {
          debugPrint('[DeepLink] ✅ Using cached profile type: $profileType');
          _lastNavigationTime = DateTime.now();

          final targetRoute = profileType == 'vendor'
              ? AppRoutes.vendorProfile
              : AppRoutes.userProfileView;

          debugPrint('[DeepLink] Route: $targetRoute');
          _navigationService.navigateFromNotification(
            targetRoute,
            arguments: username,
          );
          debugPrint(
            '[DeepLink] ✅ Navigation initiated successfully with proper stack',
          );
        } else {
          debugPrint('[DeepLink] ⚠️ Profile type not cached, fetching now...');
          await _navigateToProfile(username);
        }

        _pendingUsername = null;
        _pendingProfileType = null;
        debugPrint('[DeepLink] ✅ Pending profile navigation complete');
        debugPrint('[DeepLink] Cleared pending username and profile type');
      } catch (e) {
        debugPrint('[DeepLink] ❌ Navigation failed, keeping pending data: $e');
      }
    } else {
      debugPrint('[DeepLink] ℹ️ No pending profile to navigate to');
    }
    debugPrint('[DeepLink] ========================================');
  }

  String? _extractUsername(Uri uri) {
    debugPrint('[DeepLink] Extracting username from path: ${uri.path}');
    debugPrint('[DeepLink] Path segments count: ${uri.pathSegments.length}');

    if (uri.pathSegments.isEmpty) {
      debugPrint('[DeepLink] No path segments found');
      return null;
    }

    final username = uri.pathSegments.first;
    debugPrint('[DeepLink] Extracted: "$username"');
    return username;
  }

  String _sanitizeUsername(String username) {
    debugPrint('[DeepLink] Sanitizing username: "$username"');

    final sanitized = username.replaceAll(RegExp(r'[^a-zA-Z0-9_\-.]'), '');
    final trimmed = sanitized.trim();
    debugPrint('[DeepLink] After sanitization: "$trimmed"');
    if (username != trimmed) {
      debugPrint('[DeepLink] ⚠️ Username was modified during sanitization');
    }
    return trimmed;
  }

  bool _isValidHost(String host) {
    final lowercaseHost = host.toLowerCase();
    final isValid = _allowedHosts.contains(lowercaseHost);
    debugPrint(
      '[DeepLink] Host validation: "$host" -> ${isValid ? "VALID" : "INVALID"}',
    );
    return isValid;
  }

  bool _shouldDebounce() {
    if (_lastNavigationTime == null) {
      debugPrint('[DeepLink] No previous navigation, debounce: false');
      return false;
    }
    final elapsed = DateTime.now().difference(_lastNavigationTime!);
    final shouldDebounce = elapsed.inMilliseconds < _debounceMilliseconds;
    debugPrint(
      '[DeepLink] Time since last nav: ${elapsed.inMilliseconds}ms, debounce: $shouldDebounce',
    );
    return shouldDebounce;
  }

  void dispose() {
    _linkSubscription?.cancel();
    _linkSubscription = null;
    debugPrint('[DeepLink] Deep link service disposed');
  }
}
