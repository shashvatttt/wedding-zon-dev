import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/feed_provider.dart';
import '../models/feed_user.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../shared/widgets/wz_loading.dart';
import '../../../core/theme/wz_colors.dart';
import '../../../shared/widgets/wz_toast.dart';

class ViewAsFeedScreen extends StatefulWidget {
  final String viewAsUserId;
  final String? viewAsUserName;

  const ViewAsFeedScreen({
    super.key,
    required this.viewAsUserId,
    this.viewAsUserName,
  });

  @override
  State<ViewAsFeedScreen> createState() => _ViewAsFeedScreenState();
}

class _ViewAsFeedScreenState extends State<ViewAsFeedScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FeedProvider>().loadFeed(viewAs: widget.viewAsUserId);
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<FeedProvider>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
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
            Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  color: Colors.orange.shade100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.visibility,
                              color: Colors.deepOrange,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Viewing as: ${widget.viewAsUserName ?? "Member"} (Read-Only)',
                                style: const TextStyle(
                                  color: Colors.deepOrange,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.deepOrange),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(left: 24, top: 16, right: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          'Weddingzon',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: WzColors.primary,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          _FilterChip(
                            label: AppLocalizations.of(
                              context,
                            )!.translate('verified'),
                            isSelected: false,
                            onTap: () {
                              WzToast.show(
                                context,
                                message: 'Filters are disabled in view-as mode',
                                type: WzToastType.normal,
                              );
                            },
                          ),
                          const SizedBox(width: 14),
                          _FilterChip(
                            label: AppLocalizations.of(
                              context,
                            )!.translate('nearby'),
                            isSelected: false,
                            onTap: () {
                              WzToast.show(
                                context,
                                message: 'Filters are disabled in view-as mode',
                                type: WzToastType.normal,
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
                            onTap: () {
                              WzToast.show(
                                context,
                                message: 'Filters are disabled in view-as mode',
                                type: WzToastType.normal,
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Expanded(
                  child: Consumer<FeedProvider>(
                    builder: (context, provider, _) {
                      if (provider.isLoading && provider.users.isEmpty) {
                        return const Center(child: WzLoading());
                      }

                      if (provider.error != null && provider.users.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                provider.error!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        );
                      }

                      if (provider.users.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No profiles to show',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.separated(
                        controller: _scrollController,
                        padding: const EdgeInsets.only(
                          left: 32,
                          right: 32,
                          bottom: 32,
                        ),
                        itemCount:
                            provider.users.length +
                            (provider.isLoadingMore ? 1 : 0),
                        separatorBuilder: (_, __) => const SizedBox(height: 24),
                        itemBuilder: (context, index) {
                          if (index == provider.users.length) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: WzLoading(),
                              ),
                            );
                          }

                          final user = provider.users[index];
                          return _buildProfileCard(user, index);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(FeedUser user, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.userProfileView,
          arguments: user.username,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: AspectRatio(
                aspectRatio: 0.75,
                child: user.profilePhoto != null
                    ? Image.network(
                        user.profilePhoto!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.person,
                            size: 64,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : Container(
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.person,
                          size: 64,
                          color: Colors.grey,
                        ),
                      ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.fullName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (user.age != null ||
                      user.height != null ||
                      user.city != null)
                    Text(
                      [
                        if (user.age != null) '${user.age} yrs',
                        if (user.height != null) user.height,
                        if (user.city != null) user.city,
                      ].join(' • '),
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  if (user.occupation != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      user.occupation!,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ],
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEF2F55) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFEF2F55)
                : const Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : const Color(0xFF6B7280),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF111827),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
