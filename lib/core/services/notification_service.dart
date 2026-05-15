import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

import '../routes/app_routes.dart';
import 'navigation_service.dart';
import 'notification_storage_service.dart';
import '../../features/notifications/models/notification_model.dart';
import '../../features/notifications/providers/notifications_provider.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  debugPrint('[NOTIFICATION] Background message: ${message.messageId}');
  debugPrint('[NOTIFICATION] Background data: ${message.data}');

  final type = message.data['type'];
  final senderName =
      message.data['senderName'] ?? message.data['sender_name'] ?? 'Someone';

  String title = message.notification?.title ?? 'WeddingZon';
  String body = message.notification?.body ?? '';

  if (type == 'photo_access_request') {
    title = 'Photo Access Request';
    body = '$senderName requested access to your photos';
  } else if (type == 'details_access_request') {
    title = 'Details Access Request';
    body = '$senderName requested access to your details';
  } else if (type == 'photo_access_granted') {
    title = 'Photo Access Granted';
    body = '$senderName granted you photo access';
  } else if (type == 'details_access_granted') {
    title = 'Details Access Granted';
    body = '$senderName granted you details access';
  } else if (type == 'connection_request') {
    title = 'Connection Request';
    body = '$senderName sent you a connection request';
  } else if (type == 'request_accepted' || type == 'connection_accepted') {
    title = 'Connection Accepted';
    body = '$senderName accepted your connection request';
  }

  debugPrint('[NOTIFICATION] Background processed: $title - $body');
}

class NotificationService {
  late final FirebaseMessaging _firebaseMessaging;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final NavigationService _navigationService;
  final NotificationStorageService _storageService;
  static const MethodChannel _channel = MethodChannel(
    'com.example.weddingzon/notification',
  );

  Map<String, dynamic>? _pendingNotificationData;

  NotificationService(this._navigationService, this._storageService) {
    _firebaseMessaging = FirebaseMessaging.instance;
  }

  Future<void> initialize() async {
    debugPrint('[NOTIFICATION] ========================================');
    debugPrint('[NOTIFICATION] Initializing NotificationService...');
    debugPrint('[NOTIFICATION] ========================================');

    await _requestPermission();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        if (response.payload != null) {
          try {
            final data = jsonDecode(response.payload!);
            debugPrint(
              '[NOTIFICATION] Local notification tapped with payload: $data',
            );
            _handleNavigation(data);
          } catch (e) {
            debugPrint('[NOTIFICATION] Payload decode error: $e');
          }
        }
      },
    );

    final platform = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await platform?.createNotificationChannel(
      const AndroidNotificationChannel(
        'weddingzon_channel',
        'WeddingZon Notifications',
        description: 'Notifications for WeddingZon updates',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      ),
    );

    final token = await getToken();
    debugPrint('[NOTIFICATION] FCM Token available: ${token != null}');

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint(
        '[NOTIFICATION] Foreground message: ${message.notification?.title}',
      );
      _showRemoteNotification(message);
      _saveNotification(message);
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    debugPrint('[NOTIFICATION] Checking for initial Firebase message...');
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint(
        '[NOTIFICATION] App opened from terminated state: ${initialMessage.data}',
      );
      debugPrint(
        '[NOTIFICATION] Initial message notification: ${initialMessage.notification}',
      );
      debugPrint(
        '[NOTIFICATION] Initial message messageId: ${initialMessage.messageId}',
      );
      debugPrint(
        '[NOTIFICATION] Initial message sentTime: ${initialMessage.sentTime}',
      );
      _saveNotification(initialMessage);

      _pendingNotificationData = initialMessage.data;
      debugPrint(
        '[NOTIFICATION] Stored pending notification data for cold start',
      );
    } else {
      debugPrint('[NOTIFICATION] No initial Firebase message found');
    }

    await _checkNativeNotificationData();

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('[NOTIFICATION] App opened from background: ${message.data}');
      debugPrint(
        '[NOTIFICATION] Background message notification: ${message.notification}',
      );
      _saveNotification(message);
      _handleNavigation(message.data);
    });

    debugPrint('[NOTIFICATION] ========================================');
    debugPrint('[NOTIFICATION] NotificationService initialization complete');
    debugPrint('[NOTIFICATION] ========================================');
  }

  Future<void> _checkNativeNotificationData() async {
    try {
      debugPrint('[NOTIFICATION] Checking native notification data...');
      final notificationData = await _channel.invokeMethod(
        'getNotificationData',
      );
      debugPrint(
        '[NOTIFICATION] Native response type: ${notificationData.runtimeType}',
      );
      debugPrint('[NOTIFICATION] Native response: $notificationData');

      if (notificationData != null) {
        if (notificationData is Map && notificationData.isNotEmpty) {
          debugPrint(
            '[NOTIFICATION] Got notification data from native: $notificationData',
          );
          _pendingNotificationData = Map<String, dynamic>.from(
            notificationData,
          );
          debugPrint(
            '[NOTIFICATION] Stored pending notification data from native',
          );
        } else {
          debugPrint('[NOTIFICATION] Native data is empty or not a map');
        }
      } else {
        debugPrint(
          '[NOTIFICATION] No notification data from native (null response)',
        );
      }
    } catch (e, stackTrace) {
      debugPrint(
        '[NOTIFICATION] Error getting notification data from native: $e',
      );
      debugPrint('[NOTIFICATION] Stack trace: $stackTrace');
    }
  }

  Future<void> _requestPermission() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint(
      '[NOTIFICATION] Permission status: ${settings.authorizationStatus}',
    );
  }

  Future<String?> getToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      debugPrint('[NOTIFICATION] FCM Token: $token');
      return token;
    } catch (e) {
      debugPrint('[NOTIFICATION] Failed to get token: $e');
      return null;
    }
  }

  Future<void> deleteToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      debugPrint('[NOTIFICATION] Token deleted');
    } catch (e) {
      debugPrint('[NOTIFICATION] Delete token error: $e');
    }
  }

  void _showLocalNotification({
    required String title,
    required String body,
    String? payload,
    int? id,
  }) {
    _localNotifications.show(
      id ?? DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'weddingzon_channel',
          'WeddingZon Notifications',
          channelDescription: 'Notifications for WeddingZon updates',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: payload,
    );
  }

  void _showRemoteNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification != null) {
      _showLocalNotification(
        title: notification.title ?? 'New Notification',
        body: notification.body ?? '',
        payload: jsonEncode(message.data),
        id: notification.hashCode,
      );
    }
  }

  Future<void> handleSocketNotification(Map<String, dynamic> data) async {
    debugPrint('[NOTIFICATION] Handling socket notification: $data');

    final type = data['type'] ?? 'general';
    String title = data['title'] ?? 'New Notification';
    String body = data['body'] ?? '';

    if (type == 'photo_access_request') {
      final senderName =
          data['senderName'] ?? data['sender']?['name'] ?? 'Someone';
      title = 'Photo Access Request';
      body = '$senderName requested access to your photos';
    } else if (type == 'details_access_request') {
      final senderName =
          data['senderName'] ?? data['sender']?['name'] ?? 'Someone';
      title = 'Details Access Request';
      body = '$senderName requested access to your details';
    } else if (type == 'photo_access_granted') {
      final senderName =
          data['senderName'] ?? data['sender']?['name'] ?? 'Someone';
      title = 'Photo Access Granted';
      body = '$senderName granted you photo access';
    } else if (type == 'details_access_granted') {
      final senderName =
          data['senderName'] ?? data['sender']?['name'] ?? 'Someone';
      title = 'Details Access Granted';
      body = '$senderName granted you details access';
    } else if (type == 'connection_request') {
      final senderName =
          data['senderName'] ?? data['sender']?['name'] ?? 'Someone';
      title = 'Connection Request';
      body = '$senderName sent you a connection request';
    } else if (type == 'request_accepted' || type == 'connection_accepted') {
      final senderName =
          data['senderName'] ?? data['sender']?['name'] ?? 'Someone';
      title = 'Connection Accepted';
      body = '$senderName accepted your connection request';
    }

    _showLocalNotification(title: title, body: body, payload: jsonEncode(data));

    final model = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      type: type,
      data: data,
      timestamp: DateTime.now(),
    );

    await _storageService.saveNotification(model);
  }

  Future<void> _saveNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final model = NotificationModel(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: notification.title ?? 'New Notification',
      body: notification.body ?? '',
      type: message.data['type'] ?? 'general',
      data: message.data,
      timestamp: message.sentTime ?? DateTime.now(),
    );

    await _storageService.saveNotification(model);
  }

  void _handleNavigation(Map<String, dynamic> data) {
    debugPrint('[NOTIFICATION] ========================================');
    debugPrint('[NOTIFICATION] Handling navigation for payload: $data');
    debugPrint('[NOTIFICATION] ========================================');

    final type = data['type'];

    if (type == 'chat_message' || type == 'message' || type == 'new_message') {
      debugPrint('[NOTIFICATION] 💬 Chat message notification detected');
      debugPrint('[NOTIFICATION] → Navigating to Chat Tab');
      _navigationService.navigateFromNotification(AppRoutes.chatTab);
      return;
    }

    if (type == 'profile_view' || type == 'profile_viewed') {
      debugPrint('[NOTIFICATION] 👁️ Profile view notification detected');
      debugPrint('[NOTIFICATION] → Navigating to Profile Viewers Screen');
      _navigationService.navigateFromNotification(AppRoutes.profileViewers);
      return;
    }

    if (type == 'request_accepted' ||
        type == 'connection_accepted' ||
        type == 'connection') {
      debugPrint('[NOTIFICATION] ✅ Connection accepted notification detected');
      debugPrint('[NOTIFICATION] → Navigating to Chat Tab');
      _navigationService.navigateFromNotification(AppRoutes.chatTab);
      return;
    }

    if (type == 'photo_access_granted' || type == 'photo_granted') {
      debugPrint(
        '[NOTIFICATION] 📸 Photo access granted notification detected',
      );
      debugPrint('[NOTIFICATION] → Navigating to Chat Tab');
      _navigationService.navigateFromNotification(AppRoutes.chatTab);
      return;
    }

    if (type == 'details_access_granted' || type == 'details_granted') {
      debugPrint(
        '[NOTIFICATION] 📋 Details access granted notification detected',
      );
      debugPrint('[NOTIFICATION] → Navigating to Chat Tab');
      _navigationService.navigateFromNotification(AppRoutes.chatTab);
      return;
    }

    if (type == 'connection_request') {
      debugPrint('[NOTIFICATION] 🔔 Connection request notification detected');
      debugPrint('[NOTIFICATION] → Navigating to Chat Tab - Requests Tab');
      _navigationService.navigateFromNotification(
        AppRoutes.chatTab,
        arguments: {'chatTabIndex': 3},
      );
      return;
    }

    if (type == 'photo_access_request' || type == 'photo_request') {
      debugPrint(
        '[NOTIFICATION] 📷 Photo access request notification detected',
      );
      debugPrint('[NOTIFICATION] → Navigating to Chat Tab - Requests Tab');
      _navigationService.navigateFromNotification(
        AppRoutes.chatTab,
        arguments: {'chatTabIndex': 3},
      );
      return;
    }

    if (type == 'details_access_request' || type == 'details_request') {
      debugPrint(
        '[NOTIFICATION] 📝 Details access request notification detected',
      );
      debugPrint('[NOTIFICATION] → Navigating to Chat Tab - Requests Tab');
      _navigationService.navigateFromNotification(
        AppRoutes.chatTab,
        arguments: {'chatTabIndex': 3},
      );
      return;
    }

    debugPrint('[NOTIFICATION] ⚠️ Unknown notification type: $type');
    debugPrint('[NOTIFICATION] → Navigating to Feed (default)');
    _navigationService.navigateFromNotification(AppRoutes.feed);
  }

  void handlePendingNotification() {
    debugPrint('[NOTIFICATION] ========================================');
    debugPrint('[NOTIFICATION] handlePendingNotification() called');
    debugPrint(
      '[NOTIFICATION] Current pending data: $_pendingNotificationData',
    );
    debugPrint('[NOTIFICATION] ========================================');

    if (_pendingNotificationData != null) {
      debugPrint('[NOTIFICATION] ========================================');
      debugPrint('[NOTIFICATION] HANDLING PENDING COLD START NOTIFICATION');
      debugPrint('[NOTIFICATION] Data: $_pendingNotificationData');
      debugPrint('[NOTIFICATION] ========================================');

      final data = _pendingNotificationData!;
      _pendingNotificationData = null;

      Future.delayed(const Duration(milliseconds: 500), () {
        debugPrint(
          '[NOTIFICATION] Executing navigation for cold start notification',
        );
        _handleNavigation(data);
      });
    } else {
      debugPrint('[NOTIFICATION] No pending notification to handle');

      debugPrint('[NOTIFICATION] Trying native check as fallback...');
      _checkNativeNotificationData().then((_) {
        if (_pendingNotificationData != null) {
          debugPrint('[NOTIFICATION] Found notification data on retry!');
          final data = _pendingNotificationData!;
          _pendingNotificationData = null;

          Future.delayed(const Duration(milliseconds: 500), () {
            debugPrint(
              '[NOTIFICATION] Executing navigation for retry notification',
            );
            _handleNavigation(data);
          });
        } else {
          debugPrint('[NOTIFICATION] Still no notification data found');

          _checkRecentServerNotifications();
        }
      });
    }
  }

  void _checkRecentServerNotifications() {
    debugPrint(
      '[NOTIFICATION] Checking recent server notifications for cold start...',
    );

    Future.delayed(const Duration(seconds: 3), () {
      try {
        final navigator = _navigationService.navigatorKey.currentState;
        if (navigator?.context != null && navigator!.mounted) {
          _checkForRecentNotificationNavigation(navigator.context);
        }
      } catch (e) {
        debugPrint(
          '[NOTIFICATION] Error checking recent server notifications: $e',
        );
      }
    });
  }

  void _checkForRecentNotificationNavigation(BuildContext context) {
    try {
      final notificationsProvider = Provider.of<NotificationsProvider>(
        context,
        listen: false,
      );
      final notifications = notificationsProvider.notifications;

      if (notifications.isEmpty) {
        debugPrint(
          '[NOTIFICATION] No server notifications available for cold start check',
        );
        return;
      }

      final fiveMinutesAgo = DateTime.now().subtract(
        const Duration(minutes: 5),
      );
      final recentNotifications = notifications
          .where((n) => n.timestamp.isAfter(fiveMinutesAgo) && !n.isRead)
          .toList();

      if (recentNotifications.isEmpty) {
        debugPrint(
          '[NOTIFICATION] No recent unread notifications for cold start',
        );
        return;
      }

      final mostRecent = recentNotifications.first;
      debugPrint(
        '[NOTIFICATION] Found recent notification for cold start: ${mostRecent.type} - ${mostRecent.body}',
      );

      final navigationData = {
        'type': mostRecent.type,
        'senderName':
            mostRecent.data['name'] ?? mostRecent.data['username'] ?? 'Someone',
        'username': mostRecent.data['username'],
        'userId': mostRecent.data['userId'] ?? mostRecent.data['user_id'],
        'coldStart': 'true',
      };

      debugPrint(
        '[NOTIFICATION] Triggering cold start navigation with data: $navigationData',
      );

      notificationsProvider.markAsRead(mostRecent.id);

      Future.delayed(const Duration(milliseconds: 500), () {
        _handleNavigation(navigationData);
      });
    } catch (e) {
      debugPrint(
        '[NOTIFICATION] Error in _checkForRecentNotificationNavigation: $e',
      );
    }
  }

  void debugTestNotification(String type) {
    debugPrint('[NOTIFICATION] DEBUG: Testing notification type: $type');
    final testData = {'type': type, 'senderName': 'Test User', 'debug': 'true'};
    _handleNavigation(testData);
  }

  Future<void> checkForPendingNotifications() async {
    debugPrint('[NOTIFICATION] Manual check for pending notifications...');
    await _checkNativeNotificationData();
    handlePendingNotification();
  }

  Future<void> simulateNotification(
    String type, {
    String senderName = 'Test User',
  }) async {
    try {
      debugPrint(
        '[NOTIFICATION] Simulating notification: type=$type, sender=$senderName',
      );

      await _channel.invokeMethod('simulateNotification', {
        'type': type,
        'senderName': senderName,
      });

      await _checkNativeNotificationData();

      handlePendingNotification();
    } catch (e) {
      debugPrint('[NOTIFICATION] Error simulating notification: $e');
    }
  }

  Future<void> simulateColdStartNotification(
    String type, {
    String senderName = 'Test User',
  }) async {
    try {
      debugPrint('[NOTIFICATION] ========================================');
      debugPrint('[NOTIFICATION] SIMULATING COLD START NOTIFICATION');
      debugPrint('[NOTIFICATION] Type: $type, Sender: $senderName');
      debugPrint('[NOTIFICATION] ========================================');

      await _channel.invokeMethod('simulateNotification', {
        'type': type,
        'senderName': senderName,
        'coldStart': 'true',
      });

      _pendingNotificationData = null;

      await _checkNativeNotificationData();

      debugPrint('[NOTIFICATION] Captured data: $_pendingNotificationData');

      Future.delayed(const Duration(milliseconds: 1000), () {
        debugPrint('[NOTIFICATION] Simulating app initialization complete...');
        handlePendingNotification();
      });
    } catch (e) {
      debugPrint('[NOTIFICATION] Error simulating cold start notification: $e');
    }
  }

  void forceCheckRecentNotifications() {
    debugPrint('[NOTIFICATION] Force checking recent server notifications...');
    _checkRecentServerNotifications();
  }

  Future<void> handleRealNotificationFromKilledState() async {
    debugPrint('[NOTIFICATION] ========================================');
    debugPrint('[NOTIFICATION] Handling real notification from killed state');
    debugPrint('[NOTIFICATION] ========================================');

    try {
      final initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null && initialMessage.data.isNotEmpty) {
        debugPrint(
          '[NOTIFICATION] Method 1 SUCCESS: Firebase getInitialMessage',
        );
        debugPrint('[NOTIFICATION] Data: ${initialMessage.data}');
        _pendingNotificationData = initialMessage.data;
        handlePendingNotification();
        return;
      }
    } catch (e) {
      debugPrint('[NOTIFICATION] Method 1 FAILED: $e');
    }

    try {
      await _checkNativeNotificationData();
      if (_pendingNotificationData != null &&
          _pendingNotificationData!.isNotEmpty) {
        debugPrint('[NOTIFICATION] Method 2 SUCCESS: Native Android intent');
        debugPrint('[NOTIFICATION] Data: $_pendingNotificationData');
        handlePendingNotification();
        return;
      }
    } catch (e) {
      debugPrint('[NOTIFICATION] Method 2 FAILED: $e');
    }

    debugPrint(
      '[NOTIFICATION] Method 3: Checking recent server notifications...',
    );
    Future.delayed(const Duration(seconds: 2), () {
      _checkRecentServerNotifications();
    });
  }
}
