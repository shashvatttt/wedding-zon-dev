import 'package:flutter/foundation.dart';
import '../../../core/services/socket_service.dart';
import '../../../core/services/notification_service.dart';
import '../../chat/provider/chat_provider.dart';
import '../../connections/providers/connections_provider.dart';
import '../../notifications/models/notification_model.dart';
import '../../notifications/providers/notifications_provider.dart';

class BadgeProvider extends ChangeNotifier {
  final ChatProvider _chatProvider;
  final ConnectionsProvider _connectionsProvider;
  final NotificationsProvider _notificationsProvider;
  final SocketService _socketService;
  final NotificationService _notificationService;

  int _chatBadgeCount = 0;
  int _connectionBadgeCount = 0;

  BadgeProvider(
    this._chatProvider,
    this._connectionsProvider,
    this._notificationsProvider,
    this._socketService,
    this._notificationService,
  ) {
    _initListeners();
  }

  int get chatBadgeCount => _chatBadgeCount;
  int get connectionBadgeCount => _connectionBadgeCount;

  void _initListeners() {
    _chatProvider.addListener(_updateChatCount);
    _connectionsProvider.addListener(_updateConnectionCount);
    _notificationsProvider.addListener(_updateConnectionCount);

    _socketService.onNotificationReceived = _handleSocketNotification;

    _updateChatCount();
    _updateConnectionCount();
  }

  void _updateChatCount() {
    final chatUnreadCount = _chatProvider.totalUnreadCount;
    final incomingRequestsCount = _connectionsProvider.incomingRequests.length;

    final totalChatBadgeCount = chatUnreadCount + incomingRequestsCount;

    if (totalChatBadgeCount != _chatBadgeCount) {
      _chatBadgeCount = totalChatBadgeCount;
      debugPrint(
        '[BadgeProvider] Chat count updated: $_chatBadgeCount (messages: $chatUnreadCount, requests: $incomingRequestsCount)',
      );
      notifyListeners();
    }
  }

  void _updateConnectionCount() {
    final unreadAcceptedNotifications = _notificationsProvider.notifications
        .where(
          (n) =>
              !n.isRead &&
              (n.type == 'request_accepted' ||
                  n.type == 'connection_accepted' ||
                  n.type == 'photo_access_granted' ||
                  n.type == 'details_access_granted'),
        )
        .length;

    if (unreadAcceptedNotifications != _connectionBadgeCount) {
      _connectionBadgeCount = unreadAcceptedNotifications;
      debugPrint(
        '[BadgeProvider] Connection count updated: $_connectionBadgeCount (only unread accepted notifications)',
      );
      notifyListeners();
    }
  }

  void _handleSocketNotification(Map<String, dynamic> data) {
    debugPrint('[BadgeProvider] Received socket notification: $data');
    final type = data['type'];

    if (type == 'connection_request' ||
        type == 'photo_access_request' ||
        type == 'details_access_request') {
      debugPrint('[BadgeProvider] Routing $type to ConnectionsProvider');
      _connectionsProvider.handleRealTimeRequest(data);

      debugPrint(
        '[BadgeProvider] Also triggering notification display for $type',
      );
      _notificationService.handleSocketNotification(data);
    } else if (type == 'request_accepted' ||
        type == 'connection_accepted' ||
        type == 'photo_access_granted' ||
        type == 'details_access_granted') {
      debugPrint('[BadgeProvider] Routing $type to NotificationsProvider');
      final model = NotificationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: data['title'] ?? 'Request Accepted',
        body: data['body'] ?? '',
        type: type ?? 'general',
        data: data,
        timestamp: DateTime.now(),
        isRead: false,
      );
      _notificationsProvider.handleRealTimeNotification(model);
    } else {
      debugPrint('[BadgeProvider] Routing $type to NotificationsProvider');
      final model = NotificationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: data['title'] ?? 'New Notification',
        body: data['body'] ?? '',
        type: type ?? 'general',
        data: data,
        timestamp: DateTime.now(),
        isRead: false,
      );
      _notificationsProvider.handleRealTimeNotification(model);
    }
  }

  @override
  void dispose() {
    _chatProvider.removeListener(_updateChatCount);
    _connectionsProvider.removeListener(_updateConnectionCount);
    _notificationsProvider.removeListener(_updateConnectionCount);
    super.dispose();
  }
}
