import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/api_response.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/navigation_service.dart';
import '../../../core/services/user_storage_service.dart';
import '../../../core/routes/app_routes.dart';
import '../repositories/auth_repository.dart';
import '../../../core/services/notification_service.dart';
import '../../notifications/repositories/notification_repository.dart';
import '../../chat/provider/chat_provider.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/toast_service.dart';

import '../../../core/services/socket_service.dart';
import '../../../core/services/deep_link_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepository _authRepository;
  final NavigationService _navService;
  final SocketService _socketService;
  final NotificationService _notificationService;
  final NotificationRepository _notificationRepository;
  final DeepLinkService? _deepLinkService;
  final ApiService _apiService;

  User? _currentUser;
  bool _isLoading = false;
  bool _isCheckingAuth = false;
  bool isSignupFlow = false;

  AuthProvider(
    this._authRepository,
    this._navService,
    this._socketService,
    this._notificationService,
    this._notificationRepository,
    this._apiService, {
    DeepLinkService? deepLinkService,
  }) : _deepLinkService = deepLinkService;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isCheckingAuth => _isCheckingAuth;
  bool get isAuthenticated => _currentUser != null;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setCheckingAuth(bool value) {
    _isCheckingAuth = value;
    notifyListeners();
  }

  Future<void> checkAuthStatus({bool autoRoute = true}) async {
    _setCheckingAuth(true);
    debugPrint('[AUTH] ========== CHECKING AUTH STATUS ==========');

    try {
      final cachedUser = await UserStorageService.loadUser();
      if (cachedUser != null) {
        _currentUser = cachedUser;
        debugPrint('[AUTH] Loaded cached user: ${cachedUser.email}');
      }

      final response = await _authRepository.getCurrentUser();

      if (response.success && response.data != null) {
        _currentUser = response.data;
        await _saveUserLocally(_currentUser!);
        debugPrint('[AUTH] User verified by server');

        await _registerNotificationToken();
        await _initializeSocketConnection();

        debugPrint('[AUTH] User: ${_currentUser?.email}');
        debugPrint(
          '[AUTH] PROFILE COMPLETE: ${_currentUser?.isProfileComplete}',
        );
        if (autoRoute) {
          routeUser(_currentUser!);
        }
      } else {
        debugPrint('[AUTH] Server says no active session: ${response.message}');

        if (cachedUser != null && cachedUser.isProfileComplete) {
          debugPrint(
            '[AUTH] Using cached user (session expired but user has completed profile)',
          );
          if (autoRoute) {
            routeUser(cachedUser);
          }
        } else if (cachedUser != null) {
          debugPrint(
            '[AUTH] Cached user has incomplete profile - need to re-auth',
          );
          await UserStorageService.clearUser();
          _currentUser = null;
        } else {
          _currentUser = null;
        }
      }
    } catch (e) {
      debugPrint('[AUTH] Auth check error (likely network): $e');
      if (_currentUser != null) {
        debugPrint('[AUTH] Using cached user due to network error');
        if (autoRoute) {
          routeUser(_currentUser!);
        }
        _setCheckingAuth(false);
        return;
      }
    }

    _setCheckingAuth(false);
  }

  Future<void> signInWithGoogle({
    required bool isSignup,
    int retryCount = 0,
  }) async {
    _setLoading(true);
    isSignupFlow = isSignup;

    debugPrint(
      '[AUTH] ========== GOOGLE ${isSignup ? 'SIGNUP' : 'LOGIN'} (Attempt ${retryCount + 1}) ==========',
    );

    try {
      final response = await _authRepository.googleLogin();

      debugPrint('[AUTH] AuthRepository response received');
      debugPrint('[AUTH] Success: ${response.success}');
      debugPrint('[AUTH] Message: ${response.message}');
      debugPrint('[AUTH] Data: ${response.data}');

      if (response.success && response.data != null) {
        _currentUser = response.data;
        await _saveUserLocally(_currentUser!);

        await _registerNotificationToken();
        await _initializeSocketConnection();

        debugPrint('[AUTH] Google auth successful');
        debugPrint('[AUTH] User: ${_currentUser?.email}');
        debugPrint('[AUTH] Phone Verified: ${_currentUser?.isPhoneVerified}');
        debugPrint(
          '[AUTH] Profile Complete: ${_currentUser?.isProfileComplete}',
        );

        if (isSignup) {
          if (_currentUser!.isProfileComplete) {
            debugPrint('[AUTH] Profile already complete, routing to SHELL');
            _navService.pushNamedAndRemoveUntil(AppRoutes.home);

            if (_deepLinkService?.pendingUsername != null) {
              debugPrint(
                '[AUTH] Found pending deep link: ${_deepLinkService!.pendingUsername}',
              );
              Future.delayed(const Duration(milliseconds: 500), () {
                _deepLinkService.navigateToPendingProfile();
              });
            }
          } else if (_currentUser!.phoneNumber != null &&
              _currentUser!.phoneNumber!.isNotEmpty) {
            debugPrint(
              '[AUTH] Mobile number exists, treating as login (skipping mobile setup)',
            );
            _navService.pushNamedAndRemoveUntil(AppRoutes.roleSelection);
          } else {
            toast.success("Step 1 complete! Now verify your phone number");
            _navService.pushNamedAndRemoveUntil(AppRoutes.mobileSignup);
          }
        } else {
          routeUser(_currentUser!);
        }
      } else {
        debugPrint('[AUTH] Google auth failed: ${response.message}');

        if (response.message!.contains('Exception') ||
            response.message!.contains('Error')) {
          debugPrint('[AUTH] CRITICAL FAILURE: ${response.message}');
        }
        _handleGoogleSignInError(response.message, isSignup, retryCount);
      }
    } catch (e) {
      debugPrint('[AUTH] Exception: $e');
      final errorString = e.toString().toLowerCase();

      if (errorString.contains('network_error') ||
          errorString.contains('apiexception: 7') ||
          errorString.contains('network') ||
          errorString.contains('connection')) {
        debugPrint('[AUTH] Network error detected - will retry');
        _handleNetworkError(isSignup, retryCount);
      } else {
        toast.error(
          'An error occurred during Google sign-in. Please try again.',
        );
      }
    }

    _setLoading(false);
  }

  void _handleGoogleSignInError(
    String? message,
    bool isSignup,
    int retryCount,
  ) {
    if (message != null &&
        (message.contains('network') || message.contains('connection'))) {
      _handleNetworkError(isSignup, retryCount);
    } else {
      toast.error(message ?? 'Google sign-in failed');
    }
  }

  void _handleNetworkError(bool isSignup, int retryCount) {
    if (retryCount < 2) {
      toast.show('Network error. Retrying... (${retryCount + 1}/3)');

      Future.delayed(const Duration(seconds: 2), () {
        signInWithGoogle(isSignup: isSignup, retryCount: retryCount + 1);
      });
    } else {
      toast.error(
        'Network error. Please check your internet connection and try again.',
      );
    }
  }

  String? _error;

  String? get error => _error;
  User? get user => _currentUser;

  Future<bool> loginWithPassword(String username, String password) async {
    _setLoading(true);
    _error = null;
    debugPrint('[AUTH] ========== PASSWORD LOGIN ==========');
    debugPrint('[AUTH] 🔵 Attempting login for username: $username');

    try {
      final response = await _authRepository.loginWithPassword(
        username,
        password,
      );

      if (response.success && response.data != null) {
        _currentUser = response.data;
        await _saveUserLocally(_currentUser!);

        await _registerNotificationToken();
        await _initializeSocketConnection();

        debugPrint('[AUTH] ✅ Login successful');
        debugPrint('[AUTH] 👤 User: ${_currentUser?.email}');
        debugPrint('[AUTH] 🎭 Role: ${_currentUser?.role}');

        toast.success("Login successful");

        routeUser(_currentUser!);
        _setLoading(false);
        return true;
      } else {
        _error = response.message ?? "Login failed";
        debugPrint('[AUTH] ❌ Login failed: $_error');
        toast.error(_error!);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = "An error occurred during login";
      debugPrint('[AUTH] ❌ Login Exception: $e');
      toast.error(_error!);
      _setLoading(false);
      return false;
    }
  }

  Future<bool> sendOtp(String phoneNumber) async {
    _setLoading(true);
    debugPrint('[AUTH] ========== SEND OTP ==========');
    debugPrint('[AUTH] Phone: $phoneNumber');

    try {
      final response = await _authRepository.sendOtp(phoneNumber);

      if (response.success) {
        debugPrint('[AUTH] OTP sent');
        toast.success(response.message ?? 'OTP sent successfully');
        _setLoading(false);
        return true;
      } else {
        debugPrint('[AUTH] Send OTP failed: ${response.message}');
        toast.error(response.message ?? 'Failed to send OTP');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      debugPrint('[AUTH] Exception: $e');
      toast.error('An error occurred');
      _setLoading(false);
      return false;
    }
  }

  Future<void> verifyOtp(
    String phoneNumber,
    String otp, {
    required bool isSignup,
    bool autoRoute = true,
  }) async {
    _setLoading(true);
    isSignupFlow = isSignup;

    debugPrint('[AUTH] ========== VERIFY OTP ==========');
    debugPrint('[AUTH] Phone: $phoneNumber');
    debugPrint('[AUTH] Is Signup: $isSignup');

    try {
      final response = await _authRepository.verifyOtp(phoneNumber, otp);

      if (response.success && response.data != null) {
        _currentUser = response.data;
        await _saveUserLocally(_currentUser!);

        await _registerNotificationToken();

        debugPrint('[AUTH] OTP verified');
        debugPrint(
          '[AUTH] User: ${_currentUser?.email ?? _currentUser?.phoneNumber}',
        );
        debugPrint(
          '[AUTH] Profile Complete: ${_currentUser?.isProfileComplete}',
        );

        toast.success('Phone verified successfully!');

        if (autoRoute) {
          if (isSignup) {
            if (_currentUser!.isProfileComplete) {
              debugPrint('[AUTH] Profile already complete, routing to FEED');
              _navService.pushNamedAndRemoveUntil('/ui-clone/feed');

              if (_deepLinkService?.pendingUsername != null) {
                debugPrint(
                  '[AUTH] Found pending deep link: ${_deepLinkService!.pendingUsername}',
                );
                Future.delayed(const Duration(milliseconds: 500), () {
                  _deepLinkService.navigateToPendingProfile();
                });
              }
            } else {
              debugPrint('[AUTH] Profile incomplete, routing to onboarding');
              _navService.pushNamedAndRemoveUntil(AppRoutes.roleSelection);
            }
          } else {
            routeUser(_currentUser!);
          }
        }
      } else {
        debugPrint('[AUTH] OTP verification failed: ${response.message}');
        toast.error(response.message ?? 'Invalid OTP');
      }
    } catch (e) {
      debugPrint('[AUTH] Exception: $e');
      toast.error('An error occurred');
    }

    _setLoading(false);
  }

  void routeCurrentUser() {
    if (_currentUser != null) {
      routeUser(_currentUser!);
    } else {
      _navService.pushNamedAndRemoveUntil(AppRoutes.landing);
    }
  }

  void routeUser(User user) {
    debugPrint('[AUTH] ========== ROUTING USER (LOGIN) ==========');
    debugPrint('[AUTH] User ID: ${user.id}');
    debugPrint('[AUTH] Email: ${user.email}');
    debugPrint('[AUTH] Phone: ${user.phoneNumber}');
    debugPrint('[AUTH] Role: ${user.role}');
    debugPrint('[AUTH] isPhoneVerified: ${user.isPhoneVerified}');
    debugPrint('[AUTH] isProfileComplete: ${user.isProfileComplete}');
    debugPrint('[AUTH] Franchise Status: ${user.franchiseStatus}');
    debugPrint('[AUTH] Franchise Details: ${user.franchiseDetails}');
    debugPrint('[AUTH] Vendor Status: ${user.vendorStatus}');
    debugPrint('[AUTH] Vendor Details: ${user.vendorDetails}');
    debugPrint('[AUTH] =====================================');

    if (user.role == 'franchise') {
      debugPrint('[AUTH] User is Franchise Owner, checking status...');

      if (user.franchiseDetails == null ||
          user.franchiseDetails!.businessName == null) {
        debugPrint('[AUTH] Franchise details not filled → Profile Form Screen');
        toast.show('Please complete your franchise profile');
        _navService.pushNamedAndRemoveUntil(AppRoutes.franchiseProfileForm);
        return;
      }

      switch (user.franchiseStatus) {
        case 'pending_payment':
          debugPrint('[AUTH] Status: pending_payment → Payment Screen');
          toast.show('Please complete the activation payment');
          _navService.pushNamedAndRemoveUntil(AppRoutes.franchisePayment);
          return;

        case 'pending_approval':
          debugPrint('[AUTH] Status: pending_approval → Approval Screen');
          toast.show('Your franchise application is under review');
          _navService.pushNamedAndRemoveUntil(AppRoutes.franchiseApproval);
          return;

        case 'rejected':
          debugPrint('[AUTH] Status: rejected → Show error');
          toast.error(
            'Your franchise application was rejected. Please contact support.',
          );
          _navService.pushNamedAndRemoveUntil(AppRoutes.landing);
          return;

        case 'active':
          debugPrint('[AUTH] Status: active → Dashboard');

          final hasPendingDeepLink = _deepLinkService?.pendingUsername != null;
          final pendingUsername = _deepLinkService?.pendingUsername;

          if (hasPendingDeepLink) {
            debugPrint('[AUTH] ========================================');
            debugPrint(
              '[AUTH] ✅ PENDING DEEP LINK for franchise: $pendingUsername',
            );
            debugPrint('[AUTH] ========================================');
          }

          _navService.pushNamedAndRemoveUntil(AppRoutes.franchiseDashboard);

          if (hasPendingDeepLink) {
            Future.delayed(const Duration(milliseconds: 1000), () {
              debugPrint(
                '[AUTH] 🚀 Navigating to pending profile: $pendingUsername',
              );
              _deepLinkService!.navigateToPendingProfile();
            });
          }
          return;

        default:
          debugPrint(
            '[AUTH] Status: ${user.franchiseStatus ?? "null"} → Profile Form (no status set)',
          );
          toast.show('Please complete your franchise registration');
          _navService.pushNamedAndRemoveUntil(AppRoutes.franchiseProfileForm);
          return;
      }
    }

    if (user.role == 'vendor') {
      debugPrint('[AUTH] User is Vendor, checking status...');

      if (user.vendorDetails == null ||
          user.vendorDetails!.businessName == null) {
        debugPrint(
          '[AUTH] Vendor details not filled → Vendor Registration Screen',
        );
        toast.show('Please complete your vendor registration');
        _navService.pushNamedAndRemoveUntil(AppRoutes.vendorRegistration);
        return;
      }

      switch (user.vendorStatus) {
        case 'pending_payment':
          debugPrint(
            '[AUTH] Status: pending_payment → Franchise Payment Screen',
          );
          toast.show('Please complete the activation payment');
          _navService.pushNamedAndRemoveUntil(AppRoutes.franchisePayment);
          return;

        case 'pending_approval':
          debugPrint(
            '[AUTH] Status: pending_approval → Franchise Approval Screen',
          );
          toast.show('Your vendor application is under review');
          _navService.pushNamedAndRemoveUntil(AppRoutes.franchiseApproval);
          return;

        case 'rejected':
          debugPrint('[AUTH] Status: rejected → Show error');
          toast.error(
            'Your vendor application was rejected. Please contact support.',
          );
          _navService.pushNamedAndRemoveUntil(AppRoutes.landing);
          return;

        case 'active':
          debugPrint('[AUTH] Status: active → Vendor Dashboard');

          final hasPendingDeepLink = _deepLinkService?.pendingUsername != null;
          final pendingUsername = _deepLinkService?.pendingUsername;

          if (hasPendingDeepLink) {
            debugPrint('[AUTH] ========================================');
            debugPrint(
              '[AUTH] ✅ PENDING DEEP LINK for vendor: $pendingUsername',
            );
            debugPrint('[AUTH] ========================================');
          }

          _navService.pushNamedAndRemoveUntil(AppRoutes.vendorDashboard);

          if (hasPendingDeepLink) {
            Future.delayed(const Duration(milliseconds: 1000), () {
              debugPrint(
                '[AUTH] 🚀 Navigating to pending profile: $pendingUsername',
              );
              _deepLinkService!.navigateToPendingProfile();
            });
          }
          return;

        default:
          debugPrint(
            '[AUTH] Status: ${user.vendorStatus ?? "null"} → Profile Activation (no status set)',
          );

          toast.show('Please complete the activation payment');
          _navService.pushNamedAndRemoveUntil(AppRoutes.franchisePayment);
          return;
      }
    }

    if (user.role == 'member') {
      debugPrint('[AUTH] User is Franchise Member, routing directly to Feed');

      final hasPendingDeepLink = _deepLinkService?.pendingUsername != null;
      final pendingUsername = _deepLinkService?.pendingUsername;

      if (hasPendingDeepLink) {
        debugPrint('[AUTH] ========================================');
        debugPrint('[AUTH] ✅✅✅ PENDING DEEP LINK DETECTED!');
        debugPrint('[AUTH] Username: $pendingUsername');
        debugPrint('[AUTH] Will navigate to home first, then to profile');
        debugPrint('[AUTH] ========================================');
      }

      _navService.pushNamedAndRemoveUntil(AppRoutes.home);

      if (hasPendingDeepLink) {
        debugPrint('[AUTH] Scheduling deep link navigation in 1000ms...');
        Future.delayed(const Duration(milliseconds: 1000), () {
          debugPrint('[AUTH] ========================================');
          debugPrint('[AUTH] 🚀 EXECUTING DEEP LINK NAVIGATION');
          debugPrint('[AUTH] Target username: $pendingUsername');
          debugPrint('[AUTH] ========================================');
          _deepLinkService!.navigateToPendingProfile();
        });
      }
      return;
    }

    if (!user.isPhoneVerified) {
      debugPrint('[AUTH] Phone not verified, routing to phone auth');
      toast.show('Please verify your phone number');
      _navService.pushNamedAndRemoveUntil(AppRoutes.mobileLogin);
      return;
    }

    if (!user.isProfileComplete) {
      debugPrint('[AUTH] Profile incomplete, routing to role selection');
      toast.show('Please complete your profile');
      _navService.pushNamedAndRemoveUntil(AppRoutes.roleSelection);
      _logMissingFields(user);
    } else {
      debugPrint('[AUTH] Profile complete, checking for pending deep link...');

      final hasPendingDeepLink = _deepLinkService?.pendingUsername != null;
      final pendingUsername = _deepLinkService?.pendingUsername;

      if (hasPendingDeepLink) {
        debugPrint('[AUTH] ========================================');
        debugPrint('[AUTH] ✅✅✅ PENDING DEEP LINK DETECTED!');
        debugPrint('[AUTH] Username: $pendingUsername');
        debugPrint('[AUTH] Will navigate to home first, then to profile');
        debugPrint('[AUTH] ========================================');
      }

      _navService.pushNamedAndRemoveUntil(AppRoutes.home);

      if (hasPendingDeepLink) {
        debugPrint('[AUTH] Scheduling deep link navigation in 1000ms...');
        Future.delayed(const Duration(milliseconds: 1000), () {
          debugPrint('[AUTH] ========================================');
          debugPrint('[AUTH] 🚀 EXECUTING DEEP LINK NAVIGATION');
          debugPrint('[AUTH] Target username: $pendingUsername');
          debugPrint('[AUTH] ========================================');
          _deepLinkService!.navigateToPendingProfile();
        });
      } else {
        debugPrint('[AUTH] No pending deep link, staying on feed');
      }
    }
  }

  Future<void> _saveUserLocally(User user) async {
    await UserStorageService.saveUser(user);
  }

  void updateUser(User user) {
    debugPrint('[AUTH] ========== UPDATING USER DATA ==========');
    _currentUser = user;
    _saveUserLocally(user);
    debugPrint('[AUTH] Profile Complete: ${user.isProfileComplete}');

    if (_deepLinkService != null) {
      _deepLinkService.updateAuthStatus(true);
      debugPrint('[AUTH] Updated deep link service: user is authenticated');
    }

    notifyListeners();
  }

  Future<void> logout() async {
    debugPrint('[AUTH] ========== LOGOUT ==========');

    try {
      _socketService.disconnect();
      debugPrint('[AUTH] Socket disconnected');

      await _unregisterNotificationToken();

      if (_deepLinkService != null) {
        _deepLinkService.updateAuthStatus(false);
        _deepLinkService.clearPendingUsername();
        debugPrint('[AUTH] Updated deep link service: user is logged out');
      }

      await _authRepository.logout();
      await UserStorageService.clearUser();
      _currentUser = null;
      isSignupFlow = false;

      toast.success('Logout successful');

      _navService.pushNamedAndRemoveUntil(AppRoutes.landing);
      notifyListeners();

      debugPrint('[AUTH] Logout complete');
    } catch (e) {
      debugPrint('[AUTH] Logout error: $e');
      toast.error('Logout failed');
    }
  }

  Future<void> refreshUser() async {
    debugPrint('[AUTH] ========== REFRESH USER (NO NAV) ==========');
    try {
      final response = await _authRepository.getCurrentUser();

      if (response.success && response.data != null) {
        _currentUser = response.data;
        await _saveUserLocally(_currentUser!);
        notifyListeners();
        debugPrint('[AUTH] User refreshed successfully');
      } else {
        debugPrint('[AUTH] Refresh failed: ${response.message}');
      }
    } catch (e) {
      debugPrint('[AUTH] Refresh error: $e');
    }
  }

  Future<ApiResponse<User>> getCurrentUser() async {
    return await _authRepository.getCurrentUser();
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      final response = await _authRepository.updateProfile(data);
      if (response.success && response.data != null) {
        updateUser(response.data!);
        _setLoading(false);
        return true;
      } else {
        toast.error(response.message ?? 'Update failed');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      debugPrint('[AUTH] Update profile error: $e');
      _setLoading(false);
      return false;
    }
  }

  void _logMissingFields(User user) {
    debugPrint('[AUTH] ========== PROFILE FIELD STATUS ==========');

    void check(String label, dynamic value, {required bool isRequired}) {
      final isEmpty = value == null || (value is String && value.isEmpty);
      if (isEmpty) {
        final status = isRequired ? '(REQUIRED)' : '(Optional)';
        debugPrint('[AUTH] [MISSING] $label $status');
      }
    }

    check('Date of Birth', user.dob, isRequired: true);
    check('Gender', user.gender, isRequired: true);
    check('Profile Created For', user.createdFor, isRequired: true);
    check('Height', user.height, isRequired: true);
    check('Marital Status', user.maritalStatus, isRequired: true);
    check('Mother Tongue', user.motherTongue, isRequired: true);
    check('Country', user.country, isRequired: true);
    check('State', user.state, isRequired: true);
    check('City', user.city, isRequired: true);

    check('Father Status', user.fatherStatus, isRequired: true);
    check('Mother Status', user.motherStatus, isRequired: true);
    check('Family Status', user.familyStatus, isRequired: true);
    check('Family Type', user.familyType, isRequired: true);
    check('Family Values', user.familyValues, isRequired: true);

    check('Highest Education', user.highestEducation, isRequired: true);
    check('Occupation', user.occupation, isRequired: true);
    check('Employed In', user.employedIn, isRequired: true);
    check('Annual Income', user.personalIncome, isRequired: true);

    check('Religion', user.religion, isRequired: true);
    check('Community', user.community, isRequired: true);
    check('Sub-Community', user.subCommunity, isRequired: false);

    check('Appearance', user.appearance, isRequired: true);
    check('Living Status', user.livingStatus, isRequired: true);
    check('Eating Habits', user.eatingHabits, isRequired: true);
    check('Smoking', user.smokingHabits, isRequired: false);
    check('Drinking', user.drinkingHabits, isRequired: false);

    debugPrint('[AUTH] ==========================================');
  }

  Future<void> _registerNotificationToken() async {
    try {
      final token = await _notificationService.getToken();
      if (token != null) {
        await _notificationRepository.registerToken(token);
        debugPrint('[AUTH] Notification token registered');
      }
    } catch (e) {
      debugPrint('[AUTH] Failed to register notification token: $e');
    }
  }

  Future<void> _unregisterNotificationToken() async {
    try {
      final token = await _notificationService.getToken();
      if (token != null) {
        await _notificationRepository.unregisterToken(token);
        await _notificationService.deleteToken();
        debugPrint('[AUTH] Notification token unregistered');
      }
    } catch (e) {
      debugPrint('[AUTH] Failed to unregister notification token: $e');
    }
  }

  Future<void> _initializeSocketConnection() async {
    if (_currentUser == null) return;

    try {
      debugPrint(
        '[AUTH] Initializing socket connection for user: ${_currentUser!.id}',
      );

      final chatProvider = _navService.navigatorKey.currentContext != null
          ? Provider.of<ChatProvider>(
              _navService.navigatorKey.currentContext!,
              listen: false,
            )
          : null;

      if (chatProvider != null) {
        chatProvider.setCurrentUserId(_currentUser!.id);
      }

      final accessToken = await _apiService.getAccessTokenFromCookies();

      if (accessToken != null && accessToken.isNotEmpty) {
        debugPrint('[AUTH] Using JWT token for socket authentication');
        _socketService.connect(accessToken);
      } else {
        debugPrint('[AUTH] Using cookie-based authentication for socket');
        final cookieString = await _apiService.getCookieString();
        _socketService.connect('cookie-auth', cookieString: cookieString);
      }
    } catch (e) {
      debugPrint('[AUTH] Failed to initialize socket connection: $e');
    }
  }
}
