import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/wz_colors.dart';
import '../../core/theme/wz_text_styles.dart';
import '../../core/theme/wz_spacing.dart';

class WzAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const WzAppBar({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.centerTitle = false,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title != null
          ? Text(
              title!,
              style: WzTextStyles.heading3.copyWith(
                color: foregroundColor ?? WzColors.text,
              ),
            )
          : null,
      leading: leading,
      actions: actions,
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? WzColors.white,
      foregroundColor: foregroundColor ?? WzColors.text,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}

class WzStatusBar extends StatelessWidget {
  final String time;

  const WzStatusBar({super.key, this.time = '9:41'});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: WzSpacing.space16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            time,
            style: WzTextStyles.body1.copyWith(fontWeight: FontWeight.w600),
          ),

          Row(
            children: [
              Icon(Icons.signal_cellular_4_bar, size: 16, color: WzColors.text),
              const SizedBox(width: WzSpacing.space8),
              Icon(Icons.wifi, size: 16, color: WzColors.text),
              const SizedBox(width: WzSpacing.space8),
              Icon(Icons.battery_full, size: 20, color: WzColors.text),
            ],
          ),
        ],
      ),
    );
  }
}

class WzBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<WzBottomNavItem> items;

  const WzBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: WzColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = currentIndex == index;
              return Expanded(
                child: InkWell(
                  onTap: () => onTap(index),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildIcon(item, isSelected),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: WzTextStyles.small.copyWith(
                          color: isSelected ? WzColors.primary : WzColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(WzBottomNavItem item, bool isSelected) {
    if (isSelected && item.activeIcon != null) {
      return item.activeIcon!;
    }

    if (item.customIcon != null) {
      return item.customIcon!;
    }

    return Icon(
      item.icon,
      size: 24,
      color: isSelected ? WzColors.primary : WzColors.muted,
    );
  }
}

class WzBottomNavItem {
  final IconData? icon;
  final Widget? customIcon;
  final Widget? activeIcon;
  final String label;

  const WzBottomNavItem({
    this.icon,
    this.customIcon,
    this.activeIcon,
    required this.label,
  }) : assert(icon != null || customIcon != null);
}

class WzTabBar extends StatelessWidget {
  final List<String> tabs;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool isScrollable;

  const WzTabBar({
    super.key,
    required this.tabs,
    required this.currentIndex,
    required this.onTap,
    this.isScrollable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: const BoxDecoration(
        color: WzColors.white,
        border: Border(bottom: BorderSide(color: WzColors.border, width: 1)),
      ),
      child: isScrollable
          ? SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: _buildTabs()),
            )
          : Row(children: _buildTabs()),
    );
  }

  List<Widget> _buildTabs() {
    return List.generate(tabs.length, (index) {
      final isSelected = currentIndex == index;
      return Expanded(
        flex: isScrollable ? 0 : 1,
        child: InkWell(
          onTap: () => onTap(index),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isScrollable ? WzSpacing.space16 : WzSpacing.space8,
            ),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isSelected ? WzColors.primary : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
            child: Center(
              child: Text(
                tabs[index],
                style: WzTextStyles.body1.copyWith(
                  color: isSelected ? WzColors.primary : WzColors.muted,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

class WzDrawer extends StatelessWidget {
  final Widget? header;
  final List<WzDrawerItem> items;
  final ValueChanged<int>? onItemTap;

  const WzDrawer({super.key, this.header, required this.items, this.onItemTap});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: WzColors.white,
      child: SafeArea(
        child: Column(
          children: [
            if (header != null) header!,
            if (header != null) const Divider(),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  if (item.isDivider) {
                    return const Divider();
                  }
                  return ListTile(
                    leading: item.icon != null
                        ? Icon(item.icon, color: WzColors.text)
                        : null,
                    title: Text(item.title, style: WzTextStyles.body1),
                    trailing: item.trailing,
                    onTap: () {
                      if (onItemTap != null) {
                        onItemTap!(index);
                      }
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
}

class WzDrawerItem {
  final String title;
  final IconData? icon;
  final Widget? trailing;
  final bool isDivider;

  const WzDrawerItem({
    required this.title,
    this.icon,
    this.trailing,
    this.isDivider = false,
  });

  const WzDrawerItem.divider()
    : title = '',
      icon = null,
      trailing = null,
      isDivider = true;
}
