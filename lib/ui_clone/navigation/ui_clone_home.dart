import 'package:flutter/material.dart';
import 'package:weddingzon/core/theme/wz_colors.dart';
import 'package:weddingzon/core/theme/wz_text_styles.dart';
import 'package:weddingzon/core/theme/wz_spacing.dart';
import 'ui_clone_routes.dart';

class UiCloneHomeScreen extends StatefulWidget {
  const UiCloneHomeScreen({super.key});

  @override
  State<UiCloneHomeScreen> createState() => _UiCloneHomeScreenState();
}

class _UiCloneHomeScreenState extends State<UiCloneHomeScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Authentication',
    'Profile Creation',
    'Main Features',
    'Vendor/Franchise',
    'Components',
  ];

  List<ScreenInfo> get _filteredScreens {
    var screens = UiCloneRoutes.allScreens;

    if (_selectedCategory != 'All') {
      screens = screens
          .where((screen) => screen.category == _selectedCategory)
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      screens = screens
          .where(
            (screen) =>
                screen.title.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                screen.description.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
          )
          .toList();
    }

    return screens;
  }

  int _getCategoryCount(String category) {
    if (category == 'All') {
      return UiCloneRoutes.allScreens.length;
    }
    return UiCloneRoutes.allScreens
        .where((screen) => screen.category == category)
        .length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WzColors.backgroundBg,
      appBar: AppBar(
        backgroundColor: WzColors.brandDefault,
        elevation: 0,
        title: const Text(
          'UI Clone Gallery',
          style: TextStyle(
            color: WzColors.brandOnBrand,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: WzColors.brandOnBrand),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: WzColors.primary.withOpacity(0.1),
            padding: const EdgeInsets.all(WzSpacing.space12),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: WzColors.primary,
                  size: 20,
                ),
                const SizedBox(width: WzSpacing.space8),
                Expanded(
                  child: Text(
                    '${UiCloneRoutes.allScreens.length} screens extracted from Figma',
                    style: WzTextStyles.body2.copyWith(
                      color: WzColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Container(
            color: WzColors.white,
            padding: const EdgeInsets.all(WzSpacing.space16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushNamed(UiCloneRoutes.splash);
                },
                icon: const Icon(Icons.play_arrow, size: 24),
                label: const Text(
                  'Start Demo Flow (Splash → Auth → Feed)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF2F55),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ),

          Container(
            color: WzColors.white,
            padding: const EdgeInsets.all(WzSpacing.space16),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search screens...',
                hintStyle: WzTextStyles.body2.copyWith(
                  color: WzColors.textSecondary,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: WzColors.textSecondary,
                ),
                filled: true,
                fillColor: WzColors.backgroundSecondary,
                border: OutlineInputBorder(
                  borderRadius: WzBorderRadius.medium,
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: WzSpacing.space16,
                  vertical: WzSpacing.space12,
                ),
              ),
            ),
          ),

          Container(
            color: WzColors.white,
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: WzSpacing.space16,
              ),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;
                final count = _getCategoryCount(category);

                return Padding(
                  padding: const EdgeInsets.only(right: WzSpacing.space8),
                  child: ChoiceChip(
                    label: Text('$category ($count)'),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    backgroundColor: WzColors.backgroundSecondary,
                    selectedColor: WzColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? WzColors.white : WzColors.textDefault,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                );
              },
            ),
          ),

          const Divider(height: 1),

          Expanded(
            child: _filteredScreens.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: WzColors.textSecondary.withOpacity(0.5),
                        ),
                        const SizedBox(height: WzSpacing.space16),
                        Text(
                          'No screens found',
                          style: WzTextStyles.heading4.copyWith(
                            color: WzColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: WzSpacing.space8),
                        Text(
                          'Try adjusting your search or filter',
                          style: WzTextStyles.body2.copyWith(
                            color: WzColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(WzSpacing.space16),
                    itemCount: _filteredScreens.length,
                    itemBuilder: (context, index) {
                      final screen = _filteredScreens[index];
                      return _ScreenCard(
                        screen: screen,
                        onTap: () {
                          Navigator.of(context).pushNamed(screen.route);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ScreenCard extends StatelessWidget {
  final ScreenInfo screen;
  final VoidCallback onTap;

  const _ScreenCard({required this.screen, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: WzSpacing.space12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: WzBorderRadius.medium),
      child: InkWell(
        onTap: onTap,
        borderRadius: WzBorderRadius.medium,
        child: Padding(
          padding: const EdgeInsets.all(WzSpacing.space16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _getCategoryColor(screen.category).withOpacity(0.1),
                  borderRadius: WzBorderRadius.medium,
                ),
                child: Icon(
                  _getCategoryIcon(screen.category),
                  color: _getCategoryColor(screen.category),
                  size: 28,
                ),
              ),
              const SizedBox(width: WzSpacing.space16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      screen.title,
                      style: WzTextStyles.heading4.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: WzSpacing.space4),
                    Text(
                      screen.description,
                      style: WzTextStyles.body2.copyWith(
                        color: WzColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: WzSpacing.space8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: WzSpacing.space8,
                        vertical: WzSpacing.space4,
                      ),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(
                          screen.category,
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        screen.category,
                        style: WzTextStyles.small.copyWith(
                          color: _getCategoryColor(screen.category),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: WzColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Authentication':
        return WzColors.primary;
      case 'Profile Creation':
        return WzColors.matrimony;
      case 'Main Features':
        return WzColors.info;
      case 'Vendor/Franchise':
        return WzColors.vendor;
      case 'Components':
        return WzColors.warning;
      default:
        return WzColors.textSecondary;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Authentication':
        return Icons.login;
      case 'Profile Creation':
        return Icons.person_add;
      case 'Main Features':
        return Icons.dashboard;
      case 'Vendor/Franchise':
        return Icons.store;
      case 'Components':
        return Icons.widgets;
      default:
        return Icons.phone_android;
    }
  }
}
