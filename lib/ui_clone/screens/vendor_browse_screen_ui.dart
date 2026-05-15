import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weddingzon/core/theme/wz_colors.dart';
import 'package:weddingzon/features/matches/providers/match_provider.dart';
import 'package:weddingzon/core/services/image_cache_service.dart';
import 'package:weddingzon/core/routes/app_routes.dart';
import 'package:weddingzon/core/localization/app_localizations.dart';
import 'package:weddingzon/core/responsive/responsive.dart';
import '../widgets/wz_bottom_nav_bar.dart';
import '../../shared/widgets/skeleton_widgets.dart';

class VendorBrowseScreenUI extends StatefulWidget {
  final bool showNavBar;
  final String? initialCategory;

  const VendorBrowseScreenUI({
    super.key,
    this.showNavBar = true,
    this.initialCategory,
  });

  @override
  State<VendorBrowseScreenUI> createState() => _VendorBrowseScreenUIState();
}

class _VendorBrowseScreenUIState extends State<VendorBrowseScreenUI> {
  final TextEditingController _searchController = TextEditingController();
  late String _selectedCategory;

  final List<Map<String, String>> _serviceCategories = [
    {'key': 'all', 'label': 'category_all'},
    {'key': 'Photography', 'label': 'category_photography'},
    {'key': 'Venue', 'label': 'category_venue'},
    {'key': 'Catering', 'label': 'category_catering'},
    {'key': 'Makeup Artist', 'label': 'category_makeup'},
    {'key': 'Decorator', 'label': 'category_decorator'},
    {'key': 'Music', 'label': 'category_music'},
    {'key': 'Transportation', 'label': 'category_transportation'},
    {'key': 'Invitation', 'label': 'category_invitation'},
    {'key': 'Jewelry', 'label': 'category_jewelry'},
    {'key': 'Clothing', 'label': 'category_clothing'},
    {'key': 'Gifts', 'label': 'category_gifts'},
    {'key': 'Other', 'label': 'category_other'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ?? 'all';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadVendors(
        category: _selectedCategory != 'all' ? _selectedCategory : null,
      );
    });
  }

  void _loadVendors({String? searchQuery, String? category}) {
    debugPrint('[VENDOR_BROWSE] ========================================');
    debugPrint('[VENDOR_BROWSE] 🚀 _loadVendors CALLED');
    debugPrint('[VENDOR_BROWSE]   - searchQuery: $searchQuery');
    debugPrint('[VENDOR_BROWSE]   - category: $category');
    debugPrint('[VENDOR_BROWSE] ========================================');

    final filters = <String, dynamic>{
      'role': 'vendor',
      'vendor_status': 'active',
      'limit': 50,
    };

    if (searchQuery != null && searchQuery.isNotEmpty) {
      filters['q'] = searchQuery;
    }

    if (category != null && category != 'all') {
      filters['occupation'] = category;
    }

    debugPrint('[VENDOR_BROWSE] ========================================');
    debugPrint('[VENDOR_BROWSE] 🔍 Loading vendors with filters:');
    debugPrint('[VENDOR_BROWSE] 📋 Filters: $filters');
    debugPrint('[VENDOR_BROWSE] 📍 Endpoint: /users/search');
    debugPrint(
      '[VENDOR_BROWSE] 🎯 Expected: Users with role=vendor AND vendor_status=active',
    );
    debugPrint('[VENDOR_BROWSE] ========================================');

    context.read<MatchProvider>().search(filters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFEF2F55),
              Color(0xFFFF6B8A),
              Color(0xFFFFB3C6),
              Color(0xFFFFF0F4),
              Color(0xFFF8F9FB),
            ],
            stops: [0.0, 0.10, 0.20, 0.27, 0.35],
          ),
        ),
        child: Consumer<MatchProvider>(
        builder: (context, matchProvider, child) {
          final vendors = matchProvider.searchResults;
          final isLoading = matchProvider.isLoading;
          final error = matchProvider.error;

          debugPrint('[VENDOR_BROWSE] ========================================');
          debugPrint('[VENDOR_BROWSE] 📊 UI State:');
          debugPrint('[VENDOR_BROWSE]   - isLoading: $isLoading');
          debugPrint('[VENDOR_BROWSE]   - vendors.length: ${vendors.length}');
          debugPrint('[VENDOR_BROWSE]   - error: $error');
          debugPrint('[VENDOR_BROWSE]   - _selectedCategory: $_selectedCategory');
          debugPrint('[VENDOR_BROWSE]   - searchText: ${_searchController.text}');
          debugPrint('[VENDOR_BROWSE] ========================================');

          if (isLoading && vendors.isEmpty) {
            return const SkeletonList(
              skeletonItem: VendorCardSkeleton(),
              itemCount: 4,
              padding: EdgeInsets.only(top: 16),
            );
          }

          if (error != null && vendors.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      AppLocalizations.of(
                        context,
                      )!.translate('something_went_wrong'),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => _loadVendors(),
                      icon: const Icon(Icons.refresh),
                      label: Text(
                        AppLocalizations.of(context)!.translate('try_again'),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: WzColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              _loadVendors(
                searchQuery: _searchController.text.isNotEmpty
                    ? _searchController.text
                    : null,
                category: _selectedCategory != 'All' ? _selectedCategory : null,
              );
            },
            color: WzColors.primary,
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 120,
                  floating: false,
                  pinned: false,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    background: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Find vendors for',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white70,
                              ),
                            ),
                            const Text(
                              'Your Wedding',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(
                            context,
                          )!.translate('search_vendors'),
                          hintStyle: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF9CA3AF),
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: WzColors.primary,
                            size: 22,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.clear,
                                    color: Color(0xFF9CA3AF),
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _searchController.clear();
                                    });
                                    _loadVendors(
                                      category:
                                          _selectedCategory != 'all'
                                          ? _selectedCategory
                                          : null,
                                    );
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                        onChanged: (value) {
                          debugPrint('[VENDOR_BROWSE] Search text changed: $value');
                          setState(() {});
                          Future.delayed(
                            const Duration(milliseconds: 500),
                            () {
                              if (_searchController.text == value) {
                                debugPrint('[VENDOR_BROWSE] Executing search for: $value');
                                _loadVendors(
                                  searchQuery: value.isNotEmpty ? value : null,
                                  category: _selectedCategory != 'all'
                                      ? _selectedCategory
                                      : null,
                                );
                              }
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                AppLocalizations.of(
                                  context,
                                )!.translate('featured_categories'),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context)
                                    .pushNamed(
                                      AppRoutes.vendorCategories,
                                      arguments: {
                                        'categories': _serviceCategories,
                                        'selectedCategory': _selectedCategory,
                                      },
                                    )
                                    .then((result) {
                                      if (result != null && result is String) {
                                        setState(() {
                                          _selectedCategory = result;
                                        });
                                        _loadVendors(
                                          searchQuery:
                                              _searchController.text.isNotEmpty
                                              ? _searchController.text
                                              : null,
                                          category: result != 'all'
                                              ? result
                                              : null,
                                        );
                                      }
                                    });
                              },
                              child: Text(
                                AppLocalizations.of(
                                  context,
                                )!.translate('view_all'),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: WzColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 110,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: 5,
                          itemBuilder: (context, index) {
                            final categoryData = _serviceCategories[index];
                            final categoryKey = categoryData['key']!;
                            final categoryLabelKey = categoryData['label']!;
                            final isSelected = _selectedCategory == categoryKey;
                            final icon = _getCategoryIcon(categoryKey);

                            return GestureDetector(
                              onTap: () {
                                debugPrint('[VENDOR_BROWSE] Category tapped: $categoryKey');
                                setState(() {
                                  _selectedCategory = categoryKey;
                                });
                                _loadVendors(
                                  searchQuery: _searchController.text.isNotEmpty
                                      ? _searchController.text
                                      : null,
                                  category: categoryKey != 'all'
                                      ? categoryKey
                                      : null,
                                );
                              },
                              child: Container(
                                width: 90,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            WzColors.primary,
                                            WzColors.primary.withValues(
                                              alpha: 0.8,
                                            ),
                                          ],
                                        )
                                      : null,
                                  color: isSelected ? null : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected
                                        ? WzColors.primary
                                        : const Color(0xFFE5E7EB),
                                    width: isSelected ? 2 : 1,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: WzColors.primary.withValues(
                                              alpha: 0.3,
                                            ),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ]
                                      : [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.05,
                                            ),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Colors.white.withValues(
                                                alpha: 0.2,
                                              )
                                            : WzColors.primary.withValues(
                                                alpha: 0.1,
                                              ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        icon,
                                        size: 28,
                                        color: isSelected
                                            ? Colors.white
                                            : WzColors.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      child: Text(
                                        AppLocalizations.of(
                                          context,
                                        )!.translate(categoryLabelKey),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.black87,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 28),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                _selectedCategory == 'all'
                                    ? AppLocalizations.of(
                                        context,
                                      )!.translate('all_approved_vendors')
                                    : '${AppLocalizations.of(context)!.translate(_serviceCategories.firstWhere((c) => c['key'] == _selectedCategory)['label']!)} ${AppLocalizations.of(context)!.translate('vendors')}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (vendors.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: WzColors.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${vendors.length}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: WzColors.primary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),

                vendors.isEmpty
                    ? SliverFillRemaining(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(32),
                                  decoration: BoxDecoration(
                                    color: WzColors.primary.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.store_outlined,
                                    size: 80,
                                    color: WzColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.translate('no_vendors_found'),
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _searchController.text.isNotEmpty
                                      ? AppLocalizations.of(
                                          context,
                                        )!.translate('try_adjusting_search')
                                      : _selectedCategory != 'all'
                                      ? AppLocalizations.of(context)!
                                            .translate('no_category_vendors')
                                            .replaceAll(
                                              '{category}',
                                              AppLocalizations.of(
                                                context,
                                              )!.translate(
                                                _serviceCategories.firstWhere(
                                                  (c) =>
                                                      c['key'] ==
                                                      _selectedCategory,
                                                )['label']!,
                                              ),
                                            )
                                      : AppLocalizations.of(
                                          context,
                                        )!.translate('no_vendors_available'),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF6B7280),
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (_searchController.text.isNotEmpty ||
                                    _selectedCategory != 'all') ...[
                                  const SizedBox(height: 24),
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        _searchController.clear();
                                        _selectedCategory = 'all';
                                      });
                                      _loadVendors();
                                    },
                                    icon: const Icon(Icons.clear_all),
                                    label: Text(
                                      AppLocalizations.of(
                                        context,
                                      )!.translate('clear_filters'),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: WzColors.primary,
                                      side: const BorderSide(
                                        color: WzColors.primary,
                                        width: 2,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverGrid(
                          gridDelegate: _buildResponsiveGridDelegate(context),
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final vendor = vendors[index];
                            return _buildVendorCard(vendor);
                          }, childCount: vendors.length),
                        ),
                      ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          );
        },
        ),
      ),
      bottomNavigationBar: widget.showNavBar
          ? const WzBottomNavBar(currentIndex: 0)
          : null,
    );
  }

  Widget _buildVendorCard(dynamic vendor) {
    final vendorPhoto =
        vendor.profilePhoto ??
        (vendor.photos.isNotEmpty ? vendor.photos.first.url : null);

    final businessName = vendor.businessName ?? vendor.fullName;
    final serviceType = vendor.serviceType ?? vendor.occupation ?? 'Vendor';

    return GestureDetector(
      onTap: () {
        Navigator.of(
          context,
        ).pushNamed(AppRoutes.vendorProfile, arguments: vendor.username);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Container(
                  width: double.infinity,
                  color: const Color(0xFFE5E7EB),
                  child: vendorPhoto != null
                      ? ImageCacheService.instance.buildFeedImage(
                          imageUrl: vendorPhoto,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        )
                      : const Icon(Icons.store, size: 48, color: Colors.grey),
                ),
              ),
            ),

            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        businessName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    const SizedBox(height: 4),

                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        serviceType.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: WzColors.primary,
                          letterSpacing: 0.5,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Spacer(),

                    Row(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            5,
                            (index) => Padding(
                              padding: const EdgeInsets.only(right: 1),
                              child: Icon(
                                index < (vendor.averageRating?.round() ?? 0)
                                    ? Icons.star
                                    : Icons.star_border,
                                size: 12,
                                color: Colors.amber,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),

                        Expanded(
                          child: Text(
                            vendor.averageRating != null &&
                                    vendor.averageRating! > 0
                                ? '${vendor.averageRating!.toStringAsFixed(1)} (${vendor.reviewCount ?? 0})'
                                : 'No reviews yet',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF6B7280),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'all':
        return Icons.grid_view;
      case 'Photography':
        return Icons.camera_alt;
      case 'Venue':
        return Icons.location_city;
      case 'Catering':
        return Icons.restaurant;
      case 'Makeup Artist':
        return Icons.face;
      case 'Decorator':
        return Icons.celebration;
      case 'Music':
        return Icons.music_note;
      case 'Transportation':
        return Icons.directions_car;
      case 'Invitation':
        return Icons.card_giftcard;
      case 'Jewelry':
        return Icons.diamond;
      case 'Clothing':
        return Icons.checkroom;
      case 'Gifts':
        return Icons.card_giftcard;
      default:
        return Icons.store;
    }
  }

  SliverGridDelegate _buildResponsiveGridDelegate(BuildContext context) {
    return ResponsiveGridDelegate.adaptive(
      context,
      mobileColumns: 2,
      tabletColumns: 3,
      desktopColumns: 4,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 0.75,
    );
  }
}
