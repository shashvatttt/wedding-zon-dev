import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../ui_clone/screens/feed_screen_ui.dart';
import '../../../shared/screens/coming_soon_screen.dart';
import '../../../ui_clone/screens/vendor_browse_screen_ui.dart';
import '../../../ui_clone/screens/chat_list_screen_ui.dart';

import '../../profile/screens/full_profile_screen.dart';
import '../../../ui_clone/widgets/wz_bottom_nav_bar.dart';
import '../../auth/providers/auth_provider.dart';
import '../../chat/provider/chat_provider.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../shared/widgets/wz_toast.dart';

import '../../../core/constants/app_constants.dart';
import '../../connections/providers/connections_provider.dart';
import '../../notifications/providers/notifications_provider.dart';

import '../../../core/localization/app_localizations.dart';

class MainShellScreen extends StatefulWidget {
  final int initialIndex;
  final int? chatTabIndex;
  final Map<String, dynamic>? initialFilters;

  static const int defaultIndex = 2;

  const MainShellScreen({
    super.key,
    this.initialIndex = defaultIndex,
    this.chatTabIndex,
    this.initialFilters,
  });

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen>
    with AutomaticKeepAliveClientMixin {
  late int _currentIndex;
  late PageController _pageController;
  DateTime? _lastBackPressTime;

  List<Widget> get _screens => [
    const VendorBrowseScreenUI(showNavBar: false),
    ChatListScreenUI(showNavBar: false, initialTab: widget.chatTabIndex),
    FeedScreenUI(showNavBar: false, initialFilters: widget.initialFilters),
    const ComingSoonScreen(),
    const FullProfileScreen(showNavBar: false),
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeChat();
      _initializeBadges();
      _handlePendingNotifications();
    });
  }

  void _initializeBadges() {
    if (!mounted) return;
    context.read<ConnectionsProvider>().loadIncomingRequests();

    context.read<NotificationsProvider>().loadNotifications();
  }

  Future<void> _initializeChat() async {
    final authProvider = context.read<AuthProvider>();
    final chatProvider = context.read<ChatProvider>();
    final apiService = context.read<ApiService>();

    final currentUser = authProvider.currentUser;
    if (currentUser != null) {
      debugPrint('[SHELL] Initializing chat for user: ${currentUser.id}');
      chatProvider.setCurrentUserId(currentUser.id);

      final accessToken = await apiService.getAccessTokenFromCookies();

      if (accessToken != null && accessToken.isNotEmpty) {
        debugPrint('[SHELL] Using real JWT token for socket authentication');
        debugPrint('[SHELL] Token preview: ${accessToken.substring(0, 20)}...');

        chatProvider.connectSocket(accessToken);
      } else {
        debugPrint(
          '[SHELL] WARNING: Could not extract access_token from cookies',
        );
        debugPrint('[SHELL] Attempting fallback with cookie string...');

        final cookieString = await apiService.getCookieString(
          AppConstants.socketUrl,
        );

        if (cookieString.isEmpty) {
          debugPrint(
            '[SHELL] CRITICAL: No auth credentials available for socket',
          );
        }

        chatProvider.connectSocket('cookie-auth', cookieString: cookieString);
      }
    }
  }

  void _handlePendingNotifications() {
    debugPrint('[SHELL] _handlePendingNotifications() called');

    final notificationService = context.read<NotificationService>();
    notificationService.handleRealNotificationFromKilledState();

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        debugPrint(
          '[SHELL] Final delayed notification check after server load...',
        );
        notificationService.handlePendingNotification();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    debugPrint('[SHELL] Tab switched to index: $index');
    if (index == _currentIndex) return;

    setState(() {
      _currentIndex = index;
    });

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    if (index == 1) {
      context.read<ChatProvider>().loadConversations();
    }
  }

  Future<bool> _onWillPop() async {
    final now = DateTime.now();
    if (_lastBackPressTime == null ||
        now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
      _lastBackPressTime = now;
      WzToast.show(
        context,
        message: AppLocalizations.of(context)!.translate('press_back_exit'),
        duration: const Duration(seconds: 2),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Stack(
        children: [
          Scaffold(
            body: PageView(
              physics: const BouncingScrollPhysics(),
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });

                if (index == 1 && mounted) {
                  context.read<ChatProvider>().loadConversations();
                }
              },
              children: _screens,
            ),
            bottomNavigationBar: WzBottomNavBar(
              currentIndex: _currentIndex,
              onTap: _onItemTapped,
            ),

            floatingActionButton: _buildDebugFAB(),
          ),

          const WzToastDebugButton(),
        ],
      ),
    );
  }

  Widget? _buildDebugFAB() {
    bool isDebugMode = false;
    assert(() {
      isDebugMode = true;
      return true;
    }());

    if (!isDebugMode) return null;

    return FloatingActionButton(
      heroTag: 'shell_debug_fab',
      mini: true,
      onPressed: () async {
        final notificationService = context.read<NotificationService>();

        final action = await showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Test Notifications'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Simulate Notification:'),
                ListTile(
                  title: const Text('Connection Request'),
                  onTap: () => Navigator.pop(context, 'connection_request'),
                ),
                ListTile(
                  title: const Text('Photo Access Request'),
                  onTap: () => Navigator.pop(context, 'photo_access_request'),
                ),
                ListTile(
                  title: const Text('Details Access Request'),
                  onTap: () => Navigator.pop(context, 'details_access_request'),
                ),
                ListTile(
                  title: const Text('Photo Access Granted'),
                  onTap: () => Navigator.pop(context, 'photo_access_granted'),
                ),
                ListTile(
                  title: const Text('Chat Message'),
                  onTap: () => Navigator.pop(context, 'chat_message'),
                ),
                ListTile(
                  title: const Text('Profile View'),
                  onTap: () => Navigator.pop(context, 'profile_view'),
                ),
                const Divider(),
                const Text('Debug Real Notifications:'),
                ListTile(
                  title: const Text('Check Firebase getInitialMessage'),
                  onTap: () => Navigator.pop(context, 'check_firebase_initial'),
                ),
                ListTile(
                  title: const Text('Force Handle Real Notification'),
                  onTap: () => Navigator.pop(context, 'force_handle_real'),
                ),
                const Text('Test Cold Start:'),
                ListTile(
                  title: const Text('Cold Start - Connection Request'),
                  onTap: () =>
                      Navigator.pop(context, 'cold_start_connection_request'),
                ),
                ListTile(
                  title: const Text('Cold Start - Photo Request'),
                  onTap: () =>
                      Navigator.pop(context, 'cold_start_photo_access_request'),
                ),
                ListTile(
                  title: const Text('Cold Start - Details Request'),
                  onTap: () => Navigator.pop(
                    context,
                    'cold_start_details_access_request',
                  ),
                ),
                ListTile(
                  title: const Text('Check Recent Server Notifications'),
                  onTap: () => Navigator.pop(context, 'check_recent'),
                ),
              ],
            ),
          ),
        );

        if (action != null) {
          if (action == 'check_recent') {
            notificationService.forceCheckRecentNotifications();
          } else if (action == 'check_firebase_initial') {
            notificationService.handleRealNotificationFromKilledState();
          } else if (action == 'force_handle_real') {
            notificationService.handleRealNotificationFromKilledState();
          } else if (action.startsWith('cold_start_')) {
            final type = action.replaceFirst('cold_start_', '');
            await notificationService.simulateColdStartNotification(type);
          } else {
            await notificationService.simulateNotification(action);
          }
        }
      },
      tooltip: 'Test Notifications',
      child: const Icon(Icons.notifications_active),
    );
  }
}
