import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../navigation/ui_clone_routes.dart';
import '../../core/routes/app_routes.dart';
import '../../core/localization/app_localizations.dart';
import '../../features/shell/providers/badge_provider.dart';
import '../../features/auth/providers/auth_provider.dart';

class WzBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;

  const WzBottomNavBar({super.key, required this.currentIndex, this.onTap});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<BadgeProvider>(
        builder: (context, badgeProvider, _) {
          return Container(
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFEF2F55),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 4),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _BottomNavItem(
                  iconPath: 'assets/icons/vendor.svg',
                  label: AppLocalizations.of(context)!.translate('nav_vendors'),
                  isSelected: currentIndex == 0,
                  onTap: () => _handleTap(context, 0),
                ),
                _BottomNavItem(
                  iconPath: 'assets/icons/chat.svg',
                  label: AppLocalizations.of(context)!.translate('nav_chats'),
                  isSelected: currentIndex == 1,
                  onTap: () => _handleTap(context, 1),
                  showBadge: badgeProvider.chatBadgeCount > 0,
                ),
                _BottomNavItem(
                  iconPath: 'assets/icons/home.svg',
                  label: AppLocalizations.of(context)!.translate('nav_home'),
                  isSelected: currentIndex == 2,
                  onTap: () => _handleTap(context, 2),
                ),
                _BottomNavItem(
                  iconPath: 'assets/icons/shopping.svg',
                  label: AppLocalizations.of(
                    context,
                  )!.translate('nav_shopping'),
                  isSelected: currentIndex == 3,
                  onTap: () => _handleTap(context, 3),
                ),
                _BottomNavItem(
                  iconPath: 'assets/icons/profile.svg',
                  label: AppLocalizations.of(context)!.translate('nav_profile'),
                  isSelected: currentIndex == 4,
                  onTap: () => _handleTap(context, 4),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _handleTap(BuildContext context, int index) {
    if (onTap != null) {
      onTap!(index);
    } else {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isAuthenticated = authProvider.isAuthenticated;

      // Restricted tabs for guests (index 1: Chat, index 4: Profile)
      if (!isAuthenticated && (index == 1 || index == 4)) {
        Navigator.pushNamed(context, AppRoutes.loginChoice);
        return;
      }

      _defaultNavigateToTab(context, index);
    }
  }

  void _defaultNavigateToTab(BuildContext context, int index) {
    if (index == currentIndex) return;

    String? route;

    switch (index) {
      case 0:
        route = UiCloneRoutes.vendorBrowse;
        break;
      case 1:
        route = UiCloneRoutes.chatList;
        break;
      case 2:
        route = AppRoutes.home; // Allow guests to see the feed shell
        break;
      case 3:
        route = UiCloneRoutes.comingSoonShopping;
        break;
      case 4:
        route = AppRoutes.fullProfile;
        break;
    }

    if (route != null) {
      if (index == 2) {
        // Special handling for home to avoid stack buildup
        Navigator.pushNamedAndRemoveUntil(context, route, (route) => false);
      } else {
        Navigator.pushNamed(context, route);
      }
    }
  }
}

class _BottomNavItem extends StatelessWidget {
  final String iconPath;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool showBadge;

  const _BottomNavItem({
    required this.iconPath,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.showBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                SvgPicture.asset(
                  iconPath,
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    isSelected
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.7),
                    BlendMode.srcIn,
                  ),
                ),
                if (showBadge)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.7),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
