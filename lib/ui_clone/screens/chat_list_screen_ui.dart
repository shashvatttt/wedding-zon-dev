import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../features/chat/provider/chat_provider.dart';
import '../../features/connections/providers/connections_provider.dart';
import '../../features/connections/widgets/request_card.dart';
import '../../core/routes/app_routes.dart';
import '../../shared/widgets/scaffold_with_background.dart';
import '../../features/notifications/screens/notifications_screen.dart';
import '../../../shared/widgets/notification_badge.dart';
import '../../features/shell/providers/badge_provider.dart';
import './settings_screen_ui.dart';
import '../widgets/wz_bottom_nav_bar.dart';
import '../../core/localization/app_localizations.dart';
import '../../shared/widgets/skeleton_widgets.dart';
import '../../core/theme/wz_colors.dart';
import '../../core/responsive/responsive.dart';
import '../../core/services/image_cache_service.dart';

class ChatListScreenUI extends StatefulWidget {
  final bool showNavBar;
  final int? initialTab;

  const ChatListScreenUI({super.key, this.showNavBar = true, this.initialTab});

  @override
  State<ChatListScreenUI> createState() => _ChatListScreenUIState();
}

class _ChatListScreenUIState extends State<ChatListScreenUI>
    with TickerProviderStateMixin {
  int _selectedTabIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late PageController _tabPageController;
  late AnimationController _underlineAnimationController;
  late Animation<double> _underlineAnimation;
  final List<GlobalKey> _tabKeys = List.generate(4, (index) => GlobalKey());
  int _fromTabIndex = 0;
  int _toTabIndex = 0;

  @override
  void initState() {
    super.initState();

    if (widget.initialTab != null) {
      _selectedTabIndex = widget.initialTab!;
      _fromTabIndex = widget.initialTab!;
      _toTabIndex = widget.initialTab!;
    }
    _tabPageController = PageController(initialPage: _selectedTabIndex);

    _underlineAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _underlineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _underlineAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().loadConversations();
      context.read<ChatProvider>().loadVendorConversations();
      context.read<ConnectionsProvider>().loadIncomingRequests();
      context.read<ConnectionsProvider>().loadSentRequests();
      context.read<ConnectionsProvider>().loadMyConnections();

      _initializeChatImageCache();
    });
  }

  Future<void> _initializeChatImageCache() async {
    final imageCache = ImageCacheService.instance;

    await imageCache.cleanupExpiredImageCache();

    debugPrint('[CHAT_UI] 🖼️ Chat image cache initialized');
  }

  void _animateToTab(int index) {
    if (index == _selectedTabIndex) return;

    _fromTabIndex = _selectedTabIndex;
    _toTabIndex = index;

    setState(() => _selectedTabIndex = index);

    _underlineAnimationController.reset();
    _underlineAnimationController.forward();

    _tabPageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _tabPageController.dispose();
    _underlineAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWithBackground(
      scaffoldKey: _scaffoldKey,
      endDrawer: const Drawer(
        elevation: 16,
        width: 300,
        child: SettingsScreenUI(),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.translate('chats'),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          AppLocalizations.of(
                            context,
                          )!.translate('start_connecting_text'),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111827),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        Consumer<BadgeProvider>(
                          builder: (context, badgeProvider, _) {
                            return NotificationBadge(
                              count: badgeProvider.connectionBadgeCount,
                              showDotOnly: true,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.notifications,
                                  size: 24,
                                  color: Color(0xFF111827),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const NotificationsScreen(),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: SvgPicture.asset(
                            'assets/icons/settings.svg',
                            width: 24,
                            height: 24,
                          ),
                          onPressed: () {
                            _scaffoldKey.currentState?.openEndDrawer();
                          },
                        ),
                        const SizedBox(width: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Consumer2<ChatProvider, ConnectionsProvider>(
                builder: (context, chatProvider, connectionsProvider, _) {
                  final acceptedUnread = chatProvider.conversations
                      .where((c) => c.role != 'vendor')
                      .fold(0, (sum, c) => sum + c.unreadCount);
                  final vendorUnread = chatProvider.vendorConversations.fold(
                    0,
                    (sum, c) => sum + c.unreadCount,
                  );
                  final requestsCount =
                      connectionsProvider.incomingRequests.length;

                  return Column(
                    children: [
                      Stack(
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _ConversationTab(
                                  key: _tabKeys[0],
                                  label: AppLocalizations.of(
                                    context,
                                  )!.translate('accepted'),
                                  isSelected: _selectedTabIndex == 0,
                                  onTap: () => _animateToTab(0),
                                  showBadge: acceptedUnread > 0,
                                ),
                                const SizedBox(width: 24),
                                _ConversationTab(
                                  key: _tabKeys[1],
                                  label: AppLocalizations.of(
                                    context,
                                  )!.translate('vendors'),
                                  isSelected: _selectedTabIndex == 1,
                                  onTap: () => _animateToTab(1),
                                  showBadge: vendorUnread > 0,
                                ),
                                const SizedBox(width: 24),
                                _ConversationTab(
                                  key: _tabKeys[2],
                                  label: AppLocalizations.of(
                                    context,
                                  )!.translate('interests'),
                                  isSelected: _selectedTabIndex == 2,
                                  onTap: () => _animateToTab(2),
                                ),
                                const SizedBox(width: 24),
                                _ConversationTab(
                                  key: _tabKeys[3],
                                  label: AppLocalizations.of(
                                    context,
                                  )!.translate('requests'),
                                  isSelected: _selectedTabIndex == 3,
                                  onTap: () => _animateToTab(3),
                                  showBadge: requestsCount > 0,
                                  badgeCount: requestsCount,
                                ),
                              ],
                            ),
                          ),

                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 2,
                              child: AnimatedBuilder(
                                animation: _underlineAnimationController,
                                builder: (context, child) {
                                  return CustomPaint(
                                    size: const Size(double.infinity, 2),
                                    painter: _SlidingUnderlinePainter(
                                      animationProgress:
                                          _underlineAnimationController
                                              .isAnimating
                                          ? _underlineAnimation.value
                                          : 1.0,
                                      fromTabIndex: _fromTabIndex,
                                      toTabIndex: _toTabIndex,
                                      tabKeys: _tabKeys,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 36),

            Expanded(
              child: ResponsiveContainer(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: PageView(
                    controller: _tabPageController,
                    physics: const BouncingScrollPhysics(),
                    onPageChanged: (index) {
                      setState(() {
                        _selectedTabIndex = index;
                      });
                    },
                    children: [
                      _buildAcceptedTab(),
                      _buildVendorsTab(),
                      _buildInterestsTab(),
                      _buildRequestsTab(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: widget.showNavBar
          ? const WzBottomNavBar(currentIndex: 1)
          : null,
    );
  }

  Widget _buildAcceptedTab() {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, _) {
        final conversations = chatProvider.conversations
            .where((conv) => conv.role != 'vendor')
            .toList();

        if (chatProvider.isLoading && conversations.isEmpty) {
          return const SkeletonList(
            skeletonItem: ChatItemSkeleton(),
            itemCount: 5,
          );
        }

        if (conversations.isEmpty) {
          return RefreshIndicator(
            onRefresh: () async {
              await chatProvider.loadConversations();
            },
            color: WzColors.primary,
            child: ListView(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: Center(
                    child: Text(
                      AppLocalizations.of(
                        context,
                      )!.translate('no_conversations'),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await chatProvider.loadConversations();
          },
          color: WzColors.primary,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: conversations.length,
            separatorBuilder: (_, __) => const SizedBox(height: 20),
            itemBuilder: (context, index) {
              final conversation = conversations[index];
              return GestureDetector(
                key: ValueKey('chat_${conversation.userId}'),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.uiChatConversation,
                    arguments: {
                      'userId': conversation.userId,
                      'username': conversation.username,
                      'firstName': conversation.firstName,
                      'lastName': conversation.lastName,
                      'profilePhoto': conversation.profilePhoto,
                    },
                  );
                },
                child: _ConversationItem(conversation: conversation),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildVendorsTab() {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, _) {
        final vendorConversations = chatProvider.vendorConversations;

        if (chatProvider.isLoadingVendors && vendorConversations.isEmpty) {
          return const SkeletonList(
            skeletonItem: ChatItemSkeleton(),
            itemCount: 5,
          );
        }

        if (vendorConversations.isEmpty) {
          return RefreshIndicator(
            onRefresh: () async {
              await chatProvider.loadVendorConversations();
            },
            color: WzColors.primary,
            child: ListView(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.store, size: 60, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No vendor conversations yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppLocalizations.of(context)!.startChattingVendors,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, AppRoutes.shop),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEF2F55),
                            foregroundColor: Colors.white,
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.browseVendors,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await chatProvider.loadVendorConversations();
          },
          color: WzColors.primary,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: vendorConversations.length,
            separatorBuilder: (_, __) => const SizedBox(height: 20),
            itemBuilder: (context, index) {
              final conversation = vendorConversations[index];
              return GestureDetector(
                key: ValueKey('vendor_chat_${conversation.userId}'),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.uiChatConversation,
                    arguments: {
                      'userId': conversation.userId,
                      'username': conversation.username,
                      'firstName': conversation.firstName,
                      'lastName': conversation.lastName,
                      'profilePhoto': conversation.profilePhoto,
                      'isVendor': true,
                    },
                  );
                },
                child: _VendorConversationItem(conversation: conversation),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildVendorConversationItem(conversation) {
    final vendorDetails = conversation.vendorDetails;
    final businessName =
        vendorDetails?['business_name'] ?? vendorDetails?['businessName'];
    final serviceType =
        vendorDetails?['service_type'] ?? vendorDetails?['serviceType'];

    return Row(
      children: [
        Stack(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[300],
                border: Border.all(color: const Color(0xFFEF2F55), width: 2),
              ),
              child: ClipOval(
                child: RepaintBoundary(
                  child:
                      (conversation.profilePhoto != null &&
                          conversation.profilePhoto!.isNotEmpty)
                      ? ImageCacheService.instance.buildProfileImage(
                          key: ValueKey(
                            'vendor_${conversation.userId}_${conversation.profilePhoto}',
                          ),
                          imageUrl: conversation.profilePhoto!,
                          size: 50,
                        )
                      : Container(
                          width: 50,
                          height: 50,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey,
                          ),
                          child: const Icon(Icons.store, color: Colors.white),
                        ),
                ),
              ),
            ),
            if (conversation.unreadCount > 0)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          businessName ??
                                  '${conversation.firstName} ${conversation.lastName}'
                                      .trim()
                                      .isEmpty
                              ? conversation.username
                              : '${conversation.firstName} ${conversation.lastName}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111827),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (serviceType != null)
                          Text(
                            serviceType,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      conversation.lastMessage ??
                          AppLocalizations.of(
                            context,
                          )!.translate('no_messages'),
                      style: TextStyle(
                        fontSize: 13,
                        color: conversation.unreadCount > 0
                            ? Colors.black87
                            : Colors.grey[600],
                        fontWeight: conversation.unreadCount > 0
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (conversation.unreadCount > 0)
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF2F55),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${conversation.unreadCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConversationItem(conversation) {
    return Row(
      children: [
        Stack(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey,
              ),
              child: ClipOval(
                child: RepaintBoundary(
                  child:
                      (conversation.profilePhoto != null &&
                          conversation.profilePhoto!.isNotEmpty)
                      ? ImageCacheService.instance.buildProfileImage(
                          key: ValueKey(
                            'chat_${conversation.userId}_${conversation.profilePhoto}',
                          ),
                          imageUrl: conversation.profilePhoto!,
                          size: 50,
                        )
                      : Container(
                          width: 50,
                          height: 50,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey,
                          ),
                          child: const Icon(Icons.person, color: Colors.white),
                        ),
                ),
              ),
            ),
            if (conversation.unreadCount > 0)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${conversation.firstName} ${conversation.lastName}'
                            .trim()
                            .isEmpty
                        ? conversation.username
                        : '${conversation.firstName} ${conversation.lastName}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      conversation.lastMessage ??
                          AppLocalizations.of(
                            context,
                          )!.translate('no_messages'),
                      style: TextStyle(
                        fontSize: 13,
                        color: conversation.unreadCount > 0
                            ? Colors.black87
                            : Colors.grey[600],
                        fontWeight: conversation.unreadCount > 0
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (conversation.unreadCount > 0)
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF2F55),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${conversation.unreadCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInterestsTab() {
    return Consumer<ConnectionsProvider>(
      builder: (context, provider, _) {
        if (provider.isLoadingSent && provider.sentRequests.isEmpty) {
          return const SkeletonList(
            skeletonItem: ChatItemSkeleton(),
            itemCount: 3,
          );
        }

        debugPrint(
          '🔍 [CHAT_INTERESTS] Total sent requests: ${provider.sentRequests.length}',
        );
        for (var i = 0; i < provider.sentRequests.length; i++) {
          final req = provider.sentRequests[i];
          debugPrint('🔍 [CHAT_INTERESTS] Request $i: ${req.toString()}');
          debugPrint('🔍 [CHAT_INTERESTS] Request $i status: ${req['status']}');
          debugPrint('🔍 [CHAT_INTERESTS] Request $i type: ${req['type']}');
        }

        final pendingInterests = provider.sentRequests.where((request) {
          final status = request['status'] as String?;
          debugPrint(
            '🔍 [CHAT_INTERESTS] Checking status: $status == pending? ${status == 'pending'}',
          );
          return status == 'pending';
        }).toList();

        debugPrint(
          '🔍 [CHAT_INTERESTS] Filtered pending requests: ${pendingInterests.length}',
        );

        if (pendingInterests.isEmpty) {
          return RefreshIndicator(
            onRefresh: () async {
              await provider.loadSentRequests();
            },
            color: WzColors.primary,
            child: ListView(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.favorite_border,
                          size: 60,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppLocalizations.of(
                            context,
                          )!.translate('not_interested_text'),
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => Navigator.pushNamedAndRemoveUntil(
                            context,
                            AppRoutes.feed,
                            (route) => false,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEF2F55),
                            foregroundColor: Colors.white,
                          ),
                          child: Text(
                            AppLocalizations.of(
                              context,
                            )!.translate('find_match'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await provider.loadSentRequests();
          },
          color: WzColors.primary,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: pendingInterests.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final interest = pendingInterests[index];
              final toUser =
                  interest['toUser'] as Map<String, dynamic>? ??
                  interest['to'] as Map<String, dynamic>? ??
                  interest['receiver'] as Map<String, dynamic>? ??
                  {};
              final username = toUser['username'] as String? ?? '';
              return Container(
                key: ValueKey('interest_$username'),
                child: _buildInterestCard(interest, provider),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildInterestCard(
    Map<String, dynamic> request,
    ConnectionsProvider provider,
  ) {
    final toUser =
        request['toUser'] as Map<String, dynamic>? ??
        request['to'] as Map<String, dynamic>? ??
        request['receiver'] as Map<String, dynamic>? ??
        {};

    final username = toUser['username'] as String? ?? '';
    final firstName = toUser['first_name'] ?? toUser['firstName'] ?? '';
    final lastName = toUser['last_name'] ?? toUser['lastName'] ?? '';
    final profilePhoto =
        toUser['profilePhoto'] ?? toUser['profile_photo'] as String?;
    final age = toUser['age'] as int?;
    final height = toUser['height'] as String?;
    final city = toUser['city'] as String?;

    final displayName = firstName.toString().isNotEmpty
        ? '$firstName ${lastName.toString().isNotEmpty ? lastName : ""}'.trim()
        : username;

    final details = [
      if (age != null) '${age}yrs',
      if (height != null) height,
      if (city != null) city,
    ].join(' • ');

    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pushNamed(
            context,
            AppRoutes.userProfileView,
            arguments: username,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: RepaintBoundary(
              child: profilePhoto != null && profilePhoto.isNotEmpty
                  ? ImageCacheService.instance.buildProfileImage(
                      key: ValueKey('interest_${username}_$profilePhoto'),
                      imageUrl: profilePhoto,
                      size: 60,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[300],
                      child: const Icon(Icons.person, size: 30),
                    ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (details.isNotEmpty)
                Text(
                  details,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  AppLocalizations.of(context)!.translate('pending'),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () async {
            final type = request['type'] as String? ?? 'connection';
            if (type == 'connection') {
              await provider.cancelConnectionRequest(username);
            } else if (type == 'photo') {
              await provider.cancelPhotoAccessRequest(username);
            } else if (type == 'details') {
              await provider.cancelDetailsAccessRequest(username);
            }
          },
          icon: const Icon(Icons.close, color: Colors.red),
          tooltip: AppLocalizations.of(context)!.cancelRequest,
        ),
      ],
    );
  }

  Widget _buildRequestsTab() {
    return Consumer<ConnectionsProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.incomingRequests.isEmpty) {
          return const SkeletonList(
            skeletonItem: ChatItemSkeleton(),
            itemCount: 3,
          );
        }

        if (provider.incomingRequests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.mail_outline, size: 60, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.translate('no_requests'),
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadIncomingRequests(),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: provider.incomingRequests.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final request = provider.incomingRequests[index];
              final requestId = request['_id'] as String;
              final requestType = request['type'] as String? ?? 'connection';

              return RequestCard(
                key: ValueKey('request_$requestId'),
                request: request,
                isLoading: provider.isLoading,
                onAccept: () {
                  if (requestType == 'connection') {
                    provider.accept(requestId);
                  } else if (requestType == 'photo') {
                    provider.respondPhotoRequest(requestId, 'grant');
                  } else if (requestType == 'details') {
                    provider.respondDetailsRequest(requestId, 'grant');
                  }
                },
                onReject: () {
                  if (requestType == 'connection') {
                    provider.reject(requestId);
                  } else if (requestType == 'photo') {
                    provider.respondPhotoRequest(requestId, 'reject');
                  } else if (requestType == 'details') {
                    provider.respondDetailsRequest(requestId, 'reject');
                  }
                },
              );
            },
          ),
        );
      },
    );
  }
}

class _ConversationTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool showBadge;
  final int? badgeCount;

  const _ConversationTab({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.showBadge = false,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? const Color(0xFFEF2F55)
                      : const Color(0xFF111827),
                ),
              ),
              if (showBadge) ...[
                const SizedBox(width: 4),
                if (badgeCount != null && badgeCount! > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF2F55),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      badgeCount! > 99 ? '99+' : badgeCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEF2F55),
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _SlidingUnderlinePainter extends CustomPainter {
  final double animationProgress;
  final int fromTabIndex;
  final int toTabIndex;
  final List<GlobalKey> tabKeys;

  _SlidingUnderlinePainter({
    required this.animationProgress,
    required this.fromTabIndex,
    required this.toTabIndex,
    required this.tabKeys,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFEF2F55)
      ..style = PaintingStyle.fill;

    final tabPositions = <double>[];
    final tabWidths = <double>[];

    double currentX = 0;
    for (int i = 0; i < tabKeys.length; i++) {
      final key = tabKeys[i];
      final context = key.currentContext;

      double tabWidth = 80;

      if (context != null) {
        final renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          tabWidth = renderBox.size.width;
        }
      }

      tabPositions.add(currentX);
      tabWidths.add(tabWidth);
      currentX += tabWidth + 24;
    }

    if (tabPositions.isEmpty ||
        fromTabIndex >= tabPositions.length ||
        toTabIndex >= tabPositions.length) {
      return;
    }

    final fromPosition = tabPositions[fromTabIndex];
    final toPosition = tabPositions[toTabIndex];
    final fromWidth = tabWidths[fromTabIndex];
    final toWidth = tabWidths[toTabIndex];

    final currentPosition =
        fromPosition + (toPosition - fromPosition) * animationProgress;
    final currentWidth = fromWidth + (toWidth - fromWidth) * animationProgress;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(currentPosition, 0, currentWidth, 2),
        const Radius.circular(1),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is _SlidingUnderlinePainter &&
        (oldDelegate.animationProgress != animationProgress ||
            oldDelegate.fromTabIndex != fromTabIndex ||
            oldDelegate.toTabIndex != toTabIndex);
  }
}

class _ConversationItem extends StatelessWidget {
  final dynamic conversation;

  const _ConversationItem({required this.conversation});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Stack(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey,
              ),
              child: ClipOval(
                child: RepaintBoundary(
                  child:
                      (conversation.profilePhoto != null &&
                          conversation.profilePhoto!.isNotEmpty)
                      ? ImageCacheService.instance.buildProfileImage(
                          key: ValueKey(
                            'chat_${conversation.userId}_${conversation.profilePhoto}',
                          ),
                          imageUrl: conversation.profilePhoto!,
                          size: 50,
                        )
                      : Container(
                          width: 50,
                          height: 50,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey,
                          ),
                          child: const Icon(Icons.person, color: Colors.white),
                        ),
                ),
              ),
            ),
            if (conversation.unreadCount > 0)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${conversation.firstName} ${conversation.lastName}'
                            .trim()
                            .isEmpty
                        ? conversation.username
                        : '${conversation.firstName} ${conversation.lastName}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      conversation.lastMessage ??
                          AppLocalizations.of(
                            context,
                          )!.translate('no_messages'),
                      style: TextStyle(
                        fontSize: 13,
                        color: conversation.unreadCount > 0
                            ? Colors.black87
                            : Colors.grey[600],
                        fontWeight: conversation.unreadCount > 0
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (conversation.unreadCount > 0)
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF2F55),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${conversation.unreadCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _VendorConversationItem extends StatelessWidget {
  final dynamic conversation;

  const _VendorConversationItem({required this.conversation});

  @override
  Widget build(BuildContext context) {
    final vendorDetails = conversation.vendorDetails;
    final businessName =
        vendorDetails?['business_name'] ?? vendorDetails?['businessName'];
    final serviceType =
        vendorDetails?['service_type'] ?? vendorDetails?['serviceType'];

    return Row(
      children: [
        Stack(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey,
              ),
              child: ClipOval(
                child: RepaintBoundary(
                  child:
                      (conversation.profilePhoto != null &&
                          conversation.profilePhoto!.isNotEmpty)
                      ? ImageCacheService.instance.buildProfileImage(
                          key: ValueKey(
                            'vendor_${conversation.userId}_${conversation.profilePhoto}',
                          ),
                          imageUrl: conversation.profilePhoto!,
                          size: 50,
                        )
                      : Container(
                          width: 50,
                          height: 50,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey,
                          ),
                          child: const Icon(Icons.store, color: Colors.white),
                        ),
                ),
              ),
            ),
            if (conversation.unreadCount > 0)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      businessName ??
                          ('${conversation.firstName} ${conversation.lastName}'
                                  .trim()
                                  .isEmpty
                              ? conversation.username
                              : '${conversation.firstName} ${conversation.lastName}'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (serviceType != null) ...[
                const SizedBox(height: 2),
                Text(
                  serviceType,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      conversation.lastMessage ??
                          AppLocalizations.of(
                            context,
                          )!.translate('no_messages'),
                      style: TextStyle(
                        fontSize: 13,
                        color: conversation.unreadCount > 0
                            ? Colors.black87
                            : Colors.grey[600],
                        fontWeight: conversation.unreadCount > 0
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (conversation.unreadCount > 0)
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF2F55),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${conversation.unreadCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
