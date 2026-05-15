import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weddingzon/core/theme/wz_colors.dart';
import '../providers/vendor_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../widgets/stats_card.dart';
import '../widgets/product_card.dart';
import '../widgets/add_product_sheet.dart';
import '../widgets/edit_product_sheet.dart';
import '../../../shared/widgets/scaffold_with_background.dart';
import '../../../shared/widgets/wz_loading.dart';
import '../../../shared/widgets/skeleton_widgets.dart';
import '../../../shared/widgets/wz_toast.dart';

class VendorDashboard extends StatefulWidget {
  const VendorDashboard({super.key});

  @override
  State<VendorDashboard> createState() => _VendorDashboardState();
}

class _VendorDashboardState extends State<VendorDashboard> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VendorProvider>().loadProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddProductSheet() {
    final vendorProvider = context.read<VendorProvider>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ChangeNotifierProvider.value(
        value: vendorProvider,
        child: const AddProductSheet(),
      ),
    );
  }

  void _showEditProductSheet(product) {
    final vendorProvider = context.read<VendorProvider>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ChangeNotifierProvider.value(
        value: vendorProvider,
        child: EditProductSheet(product: product),
      ),
    );
  }

  Future<void> _deleteProduct(String productId, String productName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "$productName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await context.read<VendorProvider>().removeProduct(
        productId,
      );
      if (success && mounted) {
        WzToast.show(
          context,
          message: 'Product deleted successfully',
          type: WzToastType.success,
        );
      }
    }
  }

  Future<void> _handleLogout() async {
    try {
      debugPrint('[VENDOR_DASHBOARD] 🚪 Logout initiated');

      if (mounted) {
        WzToast.show(
          context,
          message: 'Logging out...',
          type: WzToastType.normal,
        );
      }

      final authProvider = context.read<AuthProvider>();
      await authProvider.logout();

      debugPrint('[VENDOR_DASHBOARD] ✅ Logout successful');

      if (mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/landing', (route) => false);
      }
    } catch (e) {
      debugPrint('[VENDOR_DASHBOARD] ❌ Logout error: $e');

      if (mounted) {
        WzToast.show(
          context,
          message: 'Logout failed: $e',
          type: WzToastType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWithBackground(
      backgroundColor: Colors.grey[50]!,
      appBar: AppBar(
        backgroundColor: const Color(0xFFE91E63),
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vendor Dashboard',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'Manage your products and view statistics',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/vendor/availability-calendar');
            },
            tooltip: 'Availability Calendar',
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/conversations');
            },
            tooltip: 'Messages',
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<VendorProvider>().loadProducts(),
        child: Consumer<VendorProvider>(
          builder: (context, vendorProvider, child) {
            if (vendorProvider.isLoading && vendorProvider.products.isEmpty) {
              return const SkeletonList(
                skeletonItem: VendorCardSkeleton(),
                itemCount: 3,
                padding: EdgeInsets.all(16),
              );
            }

            final products = _searchQuery.isEmpty
                ? vendorProvider.products
                : vendorProvider.searchProducts(_searchQuery);

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: StatsCard(
                          title: 'Total Products',
                          value: vendorProvider.totalProducts.toString(),
                          icon: Icons.inventory_2,
                          iconColor: const Color(0xFFE91E63),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: StatsCard(
                          title: 'Total Views',
                          value: vendorProvider.totalViews.toString(),
                          icon: Icons.visibility,
                          iconColor: WzColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'My Products',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _showAddProductSheet,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Product'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE91E63),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  if (products.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'No products yet'
                                  : 'No products found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (_searchQuery.isEmpty)
                              Text(
                                'Add your first product to get started',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...products.map((product) {
                      return ProductCard(
                        product: product,
                        onEdit: () => _showEditProductSheet(product),
                        onDelete: () =>
                            _deleteProduct(product.id, product.name),
                      );
                    }),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
