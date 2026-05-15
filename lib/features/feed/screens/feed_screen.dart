import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../matches/providers/match_provider.dart';
import '../providers/connection_provider.dart';
import '../widgets/shimmer_card.dart';
import '../widgets/empty_feed_state.dart';
import '../../shell/providers/badge_provider.dart';
import '../../../shared/widgets/notification_badge.dart';
import '../screens/dynamic_feed_filters_modal.dart';
import '../../../ui_clone/screens/settings_screen_ui.dart';
import '../../../shared/widgets/scaffold_with_background.dart';
import '../../notifications/screens/notifications_screen.dart';
import '../../../core/localization/app_localizations.dart';

class FeedScreen extends StatefulWidget {
  final String? viewAsUserId;
  final String? viewAsUserName;

  const FeedScreen({super.key, this.viewAsUserId, this.viewAsUserName});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _activeFilter = 'New';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadMatches();
    });

    _scrollController.addListener(_onScroll);
  }

  Future<void> _loadMatches() async {
    _applyQuickFilter('New');
  }

  void _applyQuickFilter(String filter) {
    setState(() {
      _activeFilter = filter;
    });

    final matchProvider = context.read<MatchProvider>();
    final Map<String, dynamic> filters = {};

    if (filter == 'New') {
      filters['sortBy'] = 'created_at';
    } else if (filter == 'Nearby') {
      final currentUser = context.read<AuthProvider>().currentUser;
      if (currentUser?.city != null) {
        filters['city'] = currentUser!.city;
      }
    }

    matchProvider.search(filters);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() async {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      await context.read<MatchProvider>().loadMatches();
      if (mounted) {
        _updateConnectionStatuses();
      }
    }
  }

  void _updateConnectionStatuses() {
    final users = context.read<MatchProvider>().searchResults.isNotEmpty
        ? context.read<MatchProvider>().searchResults
        : context.read<MatchProvider>().matches;

    context.read<ConnectionProvider>().updateStatusesFromFeed(users);
  }

  Future<void> _onRefresh() async {
    _applyQuickFilter(_activeFilter);
  }

  void _openFilters() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const DynamicFeedFiltersModal(),
    );

    if (result != null) {
      setState(() {
        _activeFilter = result.isEmpty ? 'New' : 'Filters';
      });

      final filters = result.isEmpty ? {'sortBy': 'created_at'} : result;

      context.read<MatchProvider>().search(filters);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

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
            _buildHeader(),
            const SizedBox(height: 16),
            _buildFilterChips(),
            const SizedBox(height: 16),
            if (widget.viewAsUserId != null)
              Container(
                width: double.infinity,
                color: Colors.blue.shade100,
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                child: Center(
                  child: Text(
                    '${AppLocalizations.of(context)!.translate('viewing_as')} ${widget.viewAsUserName ?? AppLocalizations.of(context)!.translate('member')}',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            Expanded(
              child: Consumer<MatchProvider>(
                builder: (context, matchProvider, _) {
                  return _buildFeedContent(matchProvider);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.translate('my_matches'),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
              Text(
                AppLocalizations.of(context)!.translate('as_per_preferences'),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
            ],
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
                              builder: (context) => const NotificationsScreen(),
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
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        children: [
          _FilterChip(
            label: AppLocalizations.of(context)!.translate('filter_new'),
            isSelected: _activeFilter == 'New',
            onTap: () => _applyQuickFilter('New'),
          ),
          const SizedBox(width: 14),
          _FilterChip(
            label: AppLocalizations.of(context)!.translate('filter_nearby'),
            isSelected: _activeFilter == 'Nearby',
            onTap: () => _applyQuickFilter('Nearby'),
          ),
          const SizedBox(width: 14),
          _FilterChip(
            label: AppLocalizations.of(context)!.translate('filter_filters'),
            icon: Icons.filter_list,
            isSelected: _activeFilter == 'Filters',
            onTap: _openFilters,
          ),
        ],
      ),
    );
  }

  Widget _buildFeedContent(MatchProvider matchProvider) {
    final users =
        matchProvider.searchResults.isNotEmpty || _activeFilter != 'Default'
        ? matchProvider.searchResults
        : matchProvider.matches;

    if (matchProvider.isLoading && users.isEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 3,
        itemBuilder: (context, index) => const ShimmerCard(),
      );
    }

    if (matchProvider.error != null && users.isEmpty) {
      return Center(child: Text(matchProvider.error!));
    }

    if (users.isEmpty && !matchProvider.isLoading) {
      return const EmptyFeedState();
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(32, 16, 32, 100),
        itemCount: users.length + (matchProvider.isLoading ? 1 : 0),
        separatorBuilder: (ctx, i) => const SizedBox(height: 70),
        itemBuilder: (context, index) {
          if (index == users.length) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = users[index];

          return Card(
            child: ListTile(
              title: Text(user.fullName),
              subtitle: Text(user.username),
              onTap: () {},
            ),
          );
        },
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
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEF2F55) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 4,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : const Color(0xFF111827),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF111827),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
