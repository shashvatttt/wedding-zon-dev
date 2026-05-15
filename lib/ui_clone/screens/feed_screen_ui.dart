import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../features/feed/providers/feed_provider.dart';
import '../../features/feed/models/feed_user.dart';
import '../../features/connections/providers/connections_provider.dart';
import '../../features/profile/providers/profile_provider.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/wz_colors.dart';
import '../../core/theme/wz_button_styles.dart';
import '../../core/utils/profile_helpers.dart';
import '../../shared/widgets/wz_toast.dart';
import '../widgets/wz_bottom_nav_bar.dart';
import './settings_screen_ui.dart';
import '../../features/feed/screens/dynamic_feed_filters_modal.dart';
import '../../features/shell/providers/badge_provider.dart';
import '../../../shared/widgets/notification_badge.dart';
import '../../features/notifications/screens/notifications_screen.dart';
import '../../shared/widgets/image_viewer.dart';
import '../../core/localization/app_localizations.dart';
import '../../shared/widgets/wz_loading.dart';
import '../../shared/widgets/skeleton_widgets.dart';
import '../../core/responsive/responsive.dart';
import '../../core/services/image_cache_service.dart';
import '../../features/auth/providers/auth_provider.dart';

class FeedScreenUI extends StatefulWidget {
  final bool showNavBar;
  final String? viewAsUserId;
  final String? viewAsUserName;
  final Map<String, dynamic>? initialFilters;

  const FeedScreenUI({
    super.key,
    this.showNavBar = true,
    this.viewAsUserId,
    this.viewAsUserName,
    this.initialFilters,
  });

  @override
  State<FeedScreenUI> createState() => _FeedScreenUIState();
}

class _FeedScreenUIState extends State<FeedScreenUI> with RouteAware {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  String? _lastViewedUsername;
  RouteObserver? _routeObserver;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    debugPrint(
      '📍 [SCREEN] ========== FEED SCREEN ========== [ROUTE: ${AppRoutes.feed}]',
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<FeedProvider>();
      
      if (widget.initialFilters != null) {
        provider.searchUsers(widget.initialFilters!);
      } else {
        provider.loadFeed(viewAs: widget.viewAsUserId);
      }

      _initializeImageCache();
    });
  }

  Future<void> _initializeImageCache() async {
    final imageCache = ImageCacheService.instance;

    await imageCache.cleanupExpiredImageCache();

    debugPrint('[FEED_UI] 🖼️ Image cache initialized');
  }

  void _preloadUpcomingImages(List<FeedUser> users, int currentIndex) {
    try {
      final imageCache = ImageCacheService.instance;

      final upcomingImages = <String>[];
      for (
        int i = currentIndex + 1;
        i < users.length && i <= currentIndex + 5;
        i++
      ) {
        final user = users[i];
        if (user.profilePhoto != null) {
          upcomingImages.add(user.profilePhoto!);
        }

        if (user.photos.isNotEmpty) {
          upcomingImages.addAll(
            user.photos.take(3).map((photo) => photo.url).toList(),
          );
        }
      }

      if (upcomingImages.isNotEmpty) {
        imageCache.preloadFeedImages(upcomingImages);
      }
    } catch (e) {
      debugPrint('[FEED_UI] ⚠️ Failed to preload upcoming images: $e');
    }
  }

  void _preloadInitialFeedImages(List<dynamic> users) {
    try {
      final imageCache = ImageCacheService.instance;

      final initialImages = <String>[];
      for (int i = 0; i < users.length && i < 10; i++) {
        final user = users[i];
        if (user.profilePhoto != null) {
          initialImages.add(user.profilePhoto!);
        }

        if (user.photos != null && user.photos.isNotEmpty) {
          initialImages.addAll(
            user.photos.take(2).map<String>((photo) => photo.url).toList(),
          );
        }
      }

      if (initialImages.isNotEmpty) {
        imageCache.preloadFeedImages(initialImages);
        debugPrint(
          '[FEED_UI] 🖼️ Preloading ${initialImages.length} initial feed images',
        );
      }
    } catch (e) {
      debugPrint('[FEED_UI] ⚠️ Failed to preload initial feed images: $e');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final modalRoute = ModalRoute.of(context);
    if (modalRoute is PageRoute) {
      final navigatorObservers = Navigator.of(context).widget.observers;
      for (var observer in navigatorObservers) {
        if (observer is RouteObserver<PageRoute>) {
          _routeObserver = observer;
          _routeObserver!.subscribe(this, modalRoute);
          break;
        }
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _routeObserver?.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    if (_lastViewedUsername != null) {
      final connectionsProvider = context.read<ConnectionsProvider>();
      connectionsProvider.fetchStatus(_lastViewedUsername!).then((_) {
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  void _setLastViewedUsername(String username) {
    _lastViewedUsername = username;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      endDrawer: const Drawer(
        elevation: 16,
        width: 300,
        child: SettingsScreenUI(),
      ),
      body: Stack(
        children: [
          Positioned(
            left: -75,
            top: -3,
            child: Opacity(
              opacity: 0.1,
              child: Image.asset(
                'assets/ui_clone/images/backgrounds/background_pattern_1.jpg',
                width: 512,
                height: 958,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox(),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                if (widget.viewAsUserId == null)
                  Padding(
                    padding: const EdgeInsets.only(left: 16, top: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.translate('my_matches'),
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF111827),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        AppRoutes.userPartnerPreferences,
                                      );
                                    },
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '${AppLocalizations.of(context)!.translate('as_per')} ',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF111827),
                                          ),
                                          maxLines: 1,
                                          softWrap: false,
                                        ),
                                        Text(
                                          AppLocalizations.of(
                                            context,
                                          )!.translate('partner_preferences'),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFFEF2F55),
                                          ),
                                          maxLines: 1,
                                          softWrap: false,
                                        ),
                                        const SizedBox(width: 4),
                                        SvgPicture.asset(
                                          'assets/ui_clone/icons/ic_edit.svg',
                                          width: 12,
                                          height: 12,
                                          colorFilter: const ColorFilter.mode(
                                            Color(0xFF111827),
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                      ],
                                    ),
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
                                        count:
                                            badgeProvider.connectionBadgeCount,
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
                                                builder: (_) =>
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
                                      _scaffoldKey.currentState
                                          ?.openEndDrawer();
                                    },
                                  ),
                                  const SizedBox(width: 16),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _FilterChip(
                                label: AppLocalizations.of(
                                  context,
                                )!.translate('verified'),
                                isSelected: false,
                                onTap: () {},
                              ),
                              const SizedBox(width: 14),
                              _FilterChip(
                                label: AppLocalizations.of(
                                  context,
                                )!.translate('nearby'),
                                isSelected: false,
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.nearby,
                                  );
                                },
                              ),
                              const SizedBox(width: 14),
                              _FilterChip(
                                label: AppLocalizations.of(
                                  context,
                                )!.translate('filters'),
                                icon: Icons.filter_list,
                                                               isSelected: false,
                                 onTap: () async {
                                  final authProvider = context.read<AuthProvider>();
                                  if (!authProvider.isAuthenticated) {
                                    Navigator.pushNamed(context, AppRoutes.loginChoice);
                                    return;
                                  }
                                  final result =
                                      await showModalBottomSheet<
                                        Map<String, dynamic>
                                      >(
                                        context: context,
                                        isScrollControlled: true,
                                        useSafeArea: true,
                                        backgroundColor: Colors.transparent,
                                        builder: (context) =>
                                            const DynamicFeedFiltersModal(),
                                      );
                                  if (result != null && context.mounted) {
                                    context.read<FeedProvider>().searchUsers(
                                      result,
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                if (widget.viewAsUserId != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 16, top: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.translate('my_matches'),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${AppLocalizations.of(context)!.translate('as_per')} ',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF111827),
                              ),
                              maxLines: 1,
                              softWrap: false,
                            ),
                            Text(
                              AppLocalizations.of(
                                context,
                              )!.translate('partner_preferences'),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFEF2F55),
                              ),
                              maxLines: 1,
                              softWrap: false,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: Stack(
                    children: [
                      Consumer<FeedProvider>(
                        builder: (context, provider, _) {
                          if (provider.isLoading && provider.users.isEmpty) {
                            return const SkeletonList(
                              skeletonItem: FeedProfileSkeleton(),
                              itemCount: 3,
                            );
                          }
                          if (provider.error != null) {
                            return Center(child: Text(provider.error!));
                          }
                          if (provider.users.isEmpty && !provider.isLoading) {
                            return _EmptyFeedState(
                              isSearchMode: provider.isSearchMode,
                              onShowAllProfiles: () async {
                                await _clearAllFiltersAndPreferences(context);
                              },
                            );
                          }
                          return RefreshIndicator(
                            onRefresh: () async {
                              debugPrint('[FEED_UI] Pull to refresh triggered');

                              await provider.refresh();
                              debugPrint(
                                '[FEED_UI] Refresh completed, users count: ${provider.users.length}',
                              );

                              _preloadInitialFeedImages(provider.users);

                              if (_pageController.hasClients) {
                                await Future.delayed(
                                  const Duration(milliseconds: 100),
                                );
                                _pageController.jumpToPage(0);
                              }
                            },
                            color: WzColors.primary,
                            child: PageView.builder(
                              controller: _pageController,
                              scrollDirection: Axis.vertical,
                              physics: const BouncingScrollPhysics(),
                              itemCount:
                                  provider.users.length +
                                  (provider.hasMore ? 1 : 0),
                              onPageChanged: (index) {
                                if (index >= provider.users.length - 2 &&
                                    provider.hasMore) {
                                  provider.loadMore();
                                }

                                _preloadUpcomingImages(provider.users, index);
                              },
                              itemBuilder: (context, index) {
                                if (index == provider.users.length) {
                                  provider.loadMore();
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 20),
                                    child: FeedProfileSkeleton(),
                                  );
                                }
                                final user = provider.users[index];
                                debugPrint(
                                  '🎓 [FEED_CARD] ========================================',
                                );
                                debugPrint(
                                  '🎓 [FEED_CARD] User: ${user.username}',
                                );
                                debugPrint(
                                  '🎓 [FEED_CARD]   Education: "${user.highestEducation}"',
                                );
                                debugPrint(
                                  '🎓 [FEED_CARD]   Income: "${user.annualIncome}"',
                                );
                                debugPrint(
                                  '🎓 [FEED_CARD]   Occupation: "${user.occupation}"',
                                );
                                debugPrint(
                                  '🎓 [FEED_CARD]   Height: "${user.height}"',
                                );
                                debugPrint(
                                  '🎓 [FEED_CARD]   Location: "${user.location}"',
                                );
                                debugPrint(
                                  '🎓 [FEED_CARD]   Religion: "${user.religion}"',
                                );
                                debugPrint(
                                  '🎓 [FEED_CARD]   Community: "${user.community}"',
                                );
                                debugPrint(
                                  '🎓 [FEED_CARD]   Marital Status: "${user.maritalStatus}"',
                                );
                                debugPrint(
                                  '🎓 [FEED_CARD] ========================================',
                                );
                                return RepaintBoundary(
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      child: _MatchCard(
                                        user: user,
                                        username: user.username,
                                        name: user.fullName,
                                        age: user.age ?? 0,
                                        height: user.height ?? '-',
                                        location: user.location ?? '-',
                                        religion: user.religion ?? '-',
                                        community: user.community ?? '-',
                                        occupation: user.occupation ?? '-',
                                        income: user.annualIncome ?? '-',
                                        education: user.highestEducation ?? '-',
                                        maritalStatus:
                                            user.maritalStatus ?? '-',
                                        activityStatus: user
                                            .getActivityStatus(),
                                        profileManagedBy:
                                            user.profileManagedBy ?? 'Self',
                                        photoCount: user.photos.length,
                                        profilePhoto: user.profilePhoto,
                                        pageController: _pageController,
                                        currentIndex: index,
                                        onProfileView: (username) {
                                          _setLastViewedUsername(username);
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (widget.showNavBar && widget.viewAsUserId == null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: WzBottomNavBar(currentIndex: 2),
            ),
        ],
      ),
    );
  }

  Future<void> _clearAllFiltersAndPreferences(BuildContext context) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) =>
            const WzLoadingOverlay(message: 'Clearing preferences...'),
      );
      debugPrint('[FEED] Starting clear all filters and preferences...');
      final profileProvider = context.read<ProfileProvider>();
      await profileProvider.clearPreferences();
      debugPrint('[FEED] Preferences cleared from backend');
      final feedProvider = context.read<FeedProvider>();
      debugPrint('[FEED] Resetting feed provider...');
      feedProvider.reset();
      debugPrint(
        '[FEED] Loading feed with refresh=true and ignorePrefs=true...',
      );
      await feedProvider.loadFeed(refresh: true, ignorePrefs: true);
      debugPrint(
        '[FEED] Feed loaded, users count: ${feedProvider.users.length}',
      );
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      WzToast.show(
        context,
        message: AppLocalizations.of(context)!.showingAllProfiles,
        type: WzToastType.success,
      );
      debugPrint(
        '[FEED] ✅ Cleared all filters and preferences, showing ${feedProvider.users.length} profiles',
      );
    } catch (e) {
      debugPrint('[FEED ERROR] ❌ Failed to clear filters: $e');
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      WzToast.show(
        context,
        message:
            '${AppLocalizations.of(context)!.translate('failed_clear_filters')}: $e',
        type: WzToastType.error,
      );
    }
  }
}

class _EmptyFeedState extends StatelessWidget {
  final bool isSearchMode;
  final VoidCallback onShowAllProfiles;

  const _EmptyFeedState({
    required this.isSearchMode,
    required this.onShowAllProfiles,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 60,
                color: Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isSearchMode
                  ? 'No Profiles Found'
                  : 'No Profiles Match Your Preferences',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              isSearchMode
                  ? 'No profiles match your current search filters.\nTry adjusting your filters or view all profiles.'
                  : 'No profiles match your partner preferences.\nTry clearing your preferences to see all available profiles.',
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF6B7280),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: onShowAllProfiles,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.refresh_rounded, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context)!.showAllProfiles,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (!isSearchMode)
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/profile/preferences');
                },
                child: Text(
                  AppLocalizations.of(context)!.editPartnerPreferences,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFDC2626),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        decoration: isSelected
            ? WzButtonStyles.chipSelected()
            : WzButtonStyles.chipUnselected(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? const Color(0xFFFFFFFF)
                    : const Color(0xFF000000),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: isSelected
                  ? WzButtonStyles.chipTextSelected()
                  : WzButtonStyles.chipTextUnselected(),
            ),
          ],
        ),
      ),
    );
  }
}

class _MatchCard extends StatefulWidget {
  final FeedUser user;
  final String username;
  final String name;
  final int age;
  final String height;
  final String location;
  final String community;
  final String religion;
  final String occupation;
  final String income;
  final String education;
  final String maritalStatus;
  final String activityStatus;
  final String profileManagedBy;
  final int photoCount;
  final String? profilePhoto;
  final PageController pageController;
  final int currentIndex;
  final void Function(String username)? onProfileView;

  const _MatchCard({
    required this.user,
    required this.username,
    required this.name,
    required this.age,
    required this.height,
    required this.location,
    required this.community,
    required this.religion,
    required this.occupation,
    required this.income,
    required this.education,
    required this.maritalStatus,
    required this.activityStatus,
    required this.profileManagedBy,
    required this.photoCount,
    this.profilePhoto,
    required this.pageController,
    required this.currentIndex,
    this.onProfileView,
  });

  @override
  State<_MatchCard> createState() => _MatchCardState();
}

class _MatchCardState extends State<_MatchCard> {
  String _connectionStatus = 'none';
  bool _isHeartLoading = false;
  bool _isCrossLoading = false;
  bool _isMessageLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchConnectionStatus();
    });
  }

  Future<void> _fetchConnectionStatus() async {
    final connectionsProvider = context.read<ConnectionsProvider>();
    await connectionsProvider.fetchStatus(widget.username);
    if (mounted) {
      setState(() {
        _connectionStatus = connectionsProvider.getConnectionStatus(
          widget.username,
        );
      });
    }
  }

  Future<void> _handleMessageButton(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isAuthenticated) {
      Navigator.pushNamed(context, AppRoutes.loginChoice);
      return;
    }
    if (_isMessageLoading) return;
    final connectionsProvider = context.read<ConnectionsProvider>();
    final connectionStatus = connectionsProvider.getConnectionStatus(
      widget.username,
    );

    if (connectionStatus == 'accepted') {
      Navigator.pushNamed(
        context,
        AppRoutes.uiChatConversation,
        arguments: {
          'userId': widget.user.id,
          'username': widget.user.username,
          'firstName': widget.user.firstName,
          'lastName': widget.user.lastName,
          'profilePhoto': widget.user.profilePhoto,
        },
      );
    } else if (connectionStatus == 'pending') {
      WzToast.show(
        context,
        message: AppLocalizations.of(
          context,
        )!.translate('connection_pending_chat'),
        type: WzToastType.normal,
      );
    } else {
      WzToast.show(
        context,
        message: AppLocalizations.of(
          context,
        )!.translate('send_connection_to_chat'),
        type: WzToastType.normal,
      );
    }
  }

  Future<void> _handleHeartButton(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isAuthenticated) {
      Navigator.pushNamed(context, AppRoutes.loginChoice);
      return;
    }
    if (_isHeartLoading) return;

    final connectionsProvider = context.read<ConnectionsProvider>();

    if (_connectionStatus == 'pending' || _connectionStatus == 'accepted') {
      setState(() {
        _connectionStatus = 'none';
        _isHeartLoading = true;
      });

      try {
        await connectionsProvider.cancelConnectionRequest(widget.username);
        await connectionsProvider.cancelDetailsAccessRequest(widget.username);
        await connectionsProvider.cancelPhotoAccessRequest(widget.username);
      } catch (e) {
      } finally {
        if (mounted) {
          setState(() {
            _isHeartLoading = false;
          });
        }
      }
    } else {
      setState(() {
        _connectionStatus = 'pending';
        _isHeartLoading = true;
      });

      try {
        final success = await connectionsProvider.sendInterest(widget.username);
        if (mounted && success) {
          WzToast.show(
            context,
            message: 'Request sent',
            type: WzToastType.success,
          );
        }
        await connectionsProvider.requestDetailsAccess(widget.username);
        await connectionsProvider.requestAccess(widget.username);
      } catch (e) {
      } finally {
        if (mounted) {
          setState(() {
            _isHeartLoading = false;
          });
        }
      }
    }
  }

  Future<void> _handleCrossButton(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isAuthenticated) {
      Navigator.pushNamed(context, AppRoutes.loginChoice);
      return;
    }
    if (_isCrossLoading) return;

    widget.pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _handlePhotoCountTap(BuildContext context) {
    final connectionsProvider = context.read<ConnectionsProvider>();
    final photoStatus = connectionsProvider.getStatus(widget.username);
    if (photoStatus == 'accepted') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageViewer(
            photos: widget.user.photos,
            initialIndex: 0,
            hasAccess: true,
            canSetProfile: false,
            canDelete: false,
          ),
        ),
      );
    } else {
      Navigator.pushNamed(context, '/ui-clone/membership-plans');
    }
  }

  void _handleCardTap(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isAuthenticated) {
      Navigator.pushNamed(context, AppRoutes.loginChoice);
      return;
    }
    widget.onProfileView?.call(widget.username);
    debugPrint('🔵 [_MatchCard] Navigating to: ${AppRoutes.userProfileView}');
    debugPrint('🔵 [_MatchCard] Arguments: ${widget.username}');
    Navigator.pushNamed(
      context,
      AppRoutes.userProfileView,
      arguments: widget.username,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = LayoutHelpers.screenWidth(context);
    final cardWidth = Breakpoints.isVerySmall(context)
        ? screenWidth - 32
        : Breakpoints.isMobile(context)
        ? (screenWidth * 0.9).clamp(300.0, 400.0)
        : 400.0;

    final cardHeight = cardWidth * 1.67;

    return Consumer<ConnectionsProvider>(
      builder: (context, connectionsProvider, child) {
        _connectionStatus = connectionsProvider.getConnectionStatus(
          widget.username,
        );
        return GestureDetector(
          onTap: () => _handleCardTap(context),
          child: Center(
            child: Container(
              width: cardWidth,
              height: cardHeight,
              constraints: BoxConstraints(maxWidth: 400, minWidth: 300),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 4,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: RepaintBoundary(
                        child: widget.profilePhoto != null
                            ? ImageCacheService.instance.buildFeedImage(
                                key: ValueKey(
                                  'feed_${widget.username}_${widget.profilePhoto}',
                                ),
                                imageUrl: widget.profilePhoto!,
                                fit: BoxFit.cover,
                                width: cardWidth,
                                height: cardHeight,
                              )
                            : Container(
                                color: Colors.grey[800],
                                child: const Icon(
                                  Icons.person,
                                  size: 120,
                                  color: Colors.white54,
                                ),
                              ),
                      ),
                    ),

                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      top: cardHeight * 0.3,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.5),
                              Colors.black.withValues(alpha: 0.75),
                              Colors.black.withValues(alpha: 0.95),
                            ],
                            stops: const [0.0, 0.3, 0.6, 1.0],
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      top: 16,
                      right: 16,
                      child: GestureDetector(
                        onTap: () => _handlePhotoCountTap(context),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(38),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(38),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.photo_library_outlined,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    widget.photoCount.toString(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      height: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 78,
                            child: Container(
                              height: 24,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Colors.white.withValues(alpha: 0.25),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),

                          Positioned(
                            left: 20,
                            right: 20,
                            bottom: 78,
                            child: Container(
                              height: 24,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                ProfileHelpers.getProfileManagedByText(
                                  widget.profileManagedBy,
                                ),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.activityStatus,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                    color: Color(0xFFEF2F55),
                                  ),
                                ),
                                const SizedBox(height: 4),

                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        widget.name,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      ', ${widget.age}',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),

                                Text(
                                  '${widget.height} • ${widget.location} • ${widget.religion}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),

                                Row(
                                  children: [
                                    const Icon(
                                      Icons.work_outline,
                                      size: 15,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        '${widget.occupation} • ${widget.income}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),

                                Row(
                                  children: [
                                    const Icon(
                                      Icons.school_outlined,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        widget.education,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.favorite_border,
                                      size: 12,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      widget.maritalStatus,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 32),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _ActionButton(
                                      icon: Icons.close,
                                      isLoading: _isCrossLoading,
                                      onTap: () => _handleCrossButton(context),
                                    ),
                                    const SizedBox(width: 32),
                                    _ActionButton(
                                      icon: _connectionStatus == 'accepted'
                                          ? Icons.favorite_rounded
                                          : (_connectionStatus == 'pending'
                                                ? Icons.favorite
                                                : Icons.favorite_border),
                                      iconColor:
                                          _connectionStatus == 'pending' ||
                                              _connectionStatus == 'accepted'
                                          ? const Color(0xFFEF2F55)
                                          : Colors.white,
                                      isLoading: false,
                                      onTap: () => _handleHeartButton(context),
                                    ),
                                    const SizedBox(width: 32),
                                    _ActionButton(
                                      iconPath: 'assets/icons/chat.svg',
                                      isLoading: _isMessageLoading,
                                      onTap: () =>
                                          _handleMessageButton(context),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData? icon;
  final String? iconPath;
  final bool isLoading;
  final VoidCallback onTap;
  final Color? iconColor;

  const _ActionButton({
    this.icon,
    this.iconPath,
    this.isLoading = false,
    required this.onTap,
    this.iconColor,
  }) : assert(
         icon != null || iconPath != null,
         'Either icon or iconPath must be provided',
       );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.28),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFFBC3CF), width: 1),
        ),
        child: isLoading
            ? const WzLoadingSmall()
            : iconPath != null
            ? Padding(
                padding: const EdgeInsets.all(16),
                child: SvgPicture.asset(
                  iconPath!,
                  colorFilter: ColorFilter.mode(
                    iconColor ?? Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              )
            : Icon(icon!, size: 32, color: iconColor ?? Colors.white),
      ),
    );
  }
}
