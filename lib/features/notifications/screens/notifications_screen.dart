import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notifications_provider.dart';
import '../../../shared/widgets/scaffold_with_background.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/routes/app_routes.dart';
import '../models/notification_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationsProvider>().loadNotifications(
        forceRefresh: true,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWithBackground(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    AppLocalizations.of(
                      context,
                    )!.translate('notifications_title'),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Consumer<NotificationsProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading && provider.notifications.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final visibleNotifications = provider.notifications
                      .where(
                        (n) =>
                            n.type == 'request_accepted' ||
                            n.type == 'photo_access_granted' ||
                            n.type == 'details_access_granted' ||
                            n.type == 'connection',
                      )
                      .toList();

                  if (visibleNotifications.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_none,
                            size: 60,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            AppLocalizations.of(
                              context,
                            )!.translate('no_notifications'),
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: visibleNotifications.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final notification = visibleNotifications[index];
                      return _buildNotificationItem(notification);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(NotificationModel notification) {
    final data = notification.data;
    final username = data['username']?.toString() ?? '';
    final firstName = data['firstName']?.toString() ?? '';
    final lastName = data['lastName']?.toString() ?? '';
    final profilePhoto = data['profilePhoto']?.toString();

    final displayName = firstName.isNotEmpty
        ? '$firstName ${lastName.isNotEmpty ? lastName : ""}'.trim()
        : (username.isNotEmpty ? username : 'User');

    String getMessage() {
      switch (notification.type) {
        case 'request_accepted':
        case 'connection':
        case 'connection_accepted':
          return ' accepted your connection request';
        case 'photo_access_granted':
        case 'photo_granted':
          return ' granted you photo access';
        case 'details_access_granted':
        case 'details_granted':
          return ' granted you details access';
        default:
          return ' sent you a notification';
      }
    }

    return GestureDetector(
      onTap: () {
        if (!notification.isRead) {
          context.read<NotificationsProvider>().markAsRead(notification.id);
        }

        if (username.isNotEmpty) {
          debugPrint(
            '[NOTIFICATIONS] 👆 Tapped notification: ${notification.type}',
          );
          debugPrint('[NOTIFICATIONS] → Navigating to profile: $username');

          Navigator.pushNamed(
            context,
            AppRoutes.userProfileView,
            arguments: username,
          );
        }
      },
      child: Card(
        color: notification.isRead ? Colors.white : Colors.blue.shade50,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: profilePhoto != null && profilePhoto.isNotEmpty
                    ? Image.network(
                        profilePhoto,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 50,
                          height: 50,
                          color: Colors.grey[300],
                          child: const Icon(Icons.person, size: 25),
                        ),
                      )
                    : Container(
                        width: 50,
                        height: 50,
                        color: Colors.grey[300],
                        child: const Icon(Icons.person, size: 25),
                      ),
              ),
              const SizedBox(width: 16),

              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF111827),
                    ),
                    children: [
                      TextSpan(
                        text: displayName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      TextSpan(text: getMessage()),
                    ],
                  ),
                ),
              ),

              const Icon(Icons.chevron_right, color: Color(0xFF111827)),
            ],
          ),
        ),
      ),
    );
  }
}
