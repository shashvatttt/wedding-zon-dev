import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:weddingzon/core/theme/wz_colors.dart';
import 'package:weddingzon/features/feed/models/feed_user.dart';
import 'package:weddingzon/features/matches/providers/match_provider.dart';
import 'package:weddingzon/shared/widgets/wz_loading.dart';
import 'package:weddingzon/core/services/api_service.dart';
import 'package:weddingzon/features/vendor/repositories/vendor_features_repository.dart';
import 'package:weddingzon/core/localization/app_localizations.dart';
import 'package:weddingzon/features/auth/providers/auth_provider.dart';
import 'package:weddingzon/core/routes/app_routes.dart';
import 'package:weddingzon/shared/widgets/wz_toast.dart';

class VendorProfileScreen extends StatefulWidget {
  final String username;

  const VendorProfileScreen({super.key, required this.username});

  @override
  State<VendorProfileScreen> createState() => _VendorProfileScreenState();
}

class _VendorProfileScreenState extends State<VendorProfileScreen> {
  late final VendorFeaturesRepository _vendorFeaturesRepository;
  FeedUser? _vendor;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();

    final apiService = context.read<ApiService>();
    _vendorFeaturesRepository = VendorFeaturesRepository(apiService);
    _loadVendorProfile();
  }

  Future<void> _loadVendorProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final matchProvider = context.read<MatchProvider>();
      final vendor = await matchProvider.getVendorDetails(widget.username);

      if (vendor != null) {
        setState(() {
          _vendor = vendor;
          _isLoading = false;
        });
        debugPrint('[VENDOR_PROFILE] ✅ Loaded vendor: ${vendor.businessName}');
      } else {
        setState(() {
          _error = 'Vendor not found';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      debugPrint('[VENDOR_PROFILE] ❌ Error loading vendor: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(child: WzLoading(color: WzColors.primary)),
      );
    }

    if (_error != null || _vendor == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.translate('failed_load_vendor'),
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadVendorProfile,
                child: Text(AppLocalizations.of(context)!.translate('retry')),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildProfileHeader(),
                const SizedBox(height: 16),
                _buildContactInfo(),
                const SizedBox(height: 16),
                _buildAboutSection(),
                const SizedBox(height: 16),
                _buildProductsSection(),
                const SizedBox(height: 16),
                _buildReviewsSection(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      pinned: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share, color: Colors.black),
          onPressed: _shareVendorProfile,
        ),
      ],
    );
  }

  void _shareVendorProfile() {
    if (_vendor == null) return;

    debugPrint('[VendorProfile] ========================================');
    debugPrint('[VendorProfile] SHARING VENDOR PROFILE');
    debugPrint('[VendorProfile] Username: ${_vendor!.username}');
    debugPrint('[VendorProfile] ========================================');

    const baseUrl = 'https://dev.d34g4kpybwb3xb.amplifyapp.com';
    final profileUrl = '$baseUrl/${_vendor!.username}';

    debugPrint('[VendorProfile] Deep link URL: $profileUrl');

    final displayName = '${_vendor!.firstName ?? ''} ${_vendor!.lastName ?? ''}'
        .trim();
    final serviceType = _vendor!.serviceType ?? _vendor!.occupation ?? 'Vendor';

    final shareText =
        'Check out $displayName - $serviceType on WeddingZon!\n$profileUrl';

    debugPrint('[VendorProfile] Share text: $shareText');

    Share.share(shareText, subject: '$displayName - WeddingZon Vendor');

    debugPrint('[VendorProfile] ✅ Share dialog opened');
    debugPrint('[VendorProfile] ========================================');
  }

  Widget _buildProfileHeader() {
    final businessName = _vendor!.vendorDetails?['business_name'] as String?;
    final displayName =
        businessName ??
        '${_vendor!.firstName ?? ''} ${_vendor!.lastName ?? ''}'.trim();
    final serviceType = _vendor!.serviceType ?? _vendor!.occupation ?? 'Vendor';
    final city = _vendor!.city ?? 'Location not specified';
    final priceRange = _vendor!.priceRange ?? '10000-30000';
    final isVerified = _vendor!.vendorStatus == 'active';

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF5A6C7D),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _vendor!.profilePhoto != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: _vendor!.profilePhoto!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(
                          color: WzColors.primary,
                          strokeWidth: 2,
                        ),
                      ),
                      errorWidget: (context, url, error) => Center(
                        child: Text(
                          displayName[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      displayName[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
              if (isVerified) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: WzColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified, size: 14, color: WzColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        AppLocalizations.of(
                          context,
                        )!.translate('verified_badge'),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: WzColors.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),

          Text(
            serviceType.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: WzColors.primary,
              letterSpacing: 0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  city,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...List.generate(
                5,
                (index) => Icon(
                  index < (_vendor!.averageRating?.round() ?? 0)
                      ? Icons.star
                      : Icons.star_border,
                  size: 16,
                  color: Colors.amber,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '${_vendor!.averageRating?.toStringAsFixed(1) ?? '0.0'} (${_vendor!.reviewCount ?? 0} ${AppLocalizations.of(context)!.translate('reviews_count')})',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: WzColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${AppLocalizations.of(context)!.translate('starting_price')} ₹$priceRange',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: WzColors.primary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  label: AppLocalizations.of(context)!.translate('get_quote'),
                  icon: Icons.request_quote,
                  color: WzColors.primary,
                  onTap: _showGetQuoteSheet,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  label: AppLocalizations.of(
                    context,
                  )!.translate('availability'),
                  icon: Icons.calendar_today,
                  color: Colors.white,
                  textColor: WzColors.primary,
                  onTap: _showAvailabilitySheet,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    final isWhiteButton = color == Colors.white;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: isWhiteButton
              ? Border.all(color: WzColors.primary, width: 1.5)
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: textColor ?? Colors.white),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textColor ?? Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo() {
    final email = _vendor!.email;
    final phone = _vendor!.phone;
    final city =
        _vendor!.city ??
        AppLocalizations.of(context)!.translate('not_specified');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.translate('contact_information'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          _buildContactItem(
            Icons.location_on_outlined,
            AppLocalizations.of(context)!.translate('business_location'),
            city,
          ),
          const SizedBox(height: 12),
          if (phone != null)
            _buildContactItem(
              Icons.phone_outlined,
              AppLocalizations.of(context)!.translate('phone'),
              phone,
            ),
          const SizedBox(height: 12),
          if (email != null)
            _buildContactItem(
              Icons.email_outlined,
              AppLocalizations.of(context)!.translate('email_id'),
              email,
            ),
        ],
      ),
    );
  }

  Widget _buildContactItem(
    IconData icon,
    String label,
    String value, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: WzColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: WzColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    final description = _vendor!.vendorDetails?['description'] as String?;

    final experienceYears =
        _vendor!.vendorDetails?['experience_years'] as int? ??
        _vendor!.vendorDetails?['experienceYears'] as int? ??
        _vendor!.experienceYears ??
        0;

    final totalPhotos = _vendor!.photos.length;
    final isVerified = _vendor!.vendorStatus == 'active';

    final serviceType = _vendor!.vendorDetails?['service_type'] as String?;
    final product = _vendor!.vendorDetails?['product'] as String?;
    final workingHours = _vendor!.vendorDetails?['working_hours'] as String?;
    final paymentTerms = _vendor!.vendorDetails?['payment_terms'] as String?;
    final businessAddress =
        _vendor!.vendorDetails?['business_address'] as String?;
    final city = _vendor!.vendorDetails?['city'] as String? ?? _vendor!.city;
    final state = _vendor!.vendorDetails?['state'] as String? ?? _vendor!.state;
    final pincode = _vendor!.vendorDetails?['pincode'] as String?;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isVerified)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: WzColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.verified_user, color: WzColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(
                            context,
                          )!.translate('identity_verified'),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: WzColors.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          AppLocalizations.of(
                            context,
                          )!.translate('government_id_proof'),
                          style: TextStyle(
                            fontSize: 10,
                            color: WzColors.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                experienceYears.toString(),
                AppLocalizations.of(context)!.translate('years_experience'),
              ),
              Container(width: 1, height: 40, color: Colors.grey[300]),
              _buildStatItem(
                totalPhotos.toString(),
                AppLocalizations.of(context)!.translate('total_work_photos'),
              ),
              Container(width: 1, height: 40, color: Colors.grey[300]),
              _buildStatItem(
                isVerified ? '✓' : '✗',
                AppLocalizations.of(context)!.translate('vendor_status_label'),
                color: isVerified ? Colors.green : Colors.grey,
              ),
            ],
          ),
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                if (serviceType != null && serviceType.isNotEmpty)
                  _buildDetailRow(
                    AppLocalizations.of(
                      context,
                    )!.translate('service_type_label'),
                    serviceType,
                  ),
                if (serviceType != null &&
                    serviceType.isNotEmpty &&
                    product != null)
                  const Divider(height: 16),
                if (product != null && product.isNotEmpty)
                  _buildDetailRow(
                    AppLocalizations.of(context)!.translate('product_label'),
                    product,
                  ),
                if (product != null &&
                    product.isNotEmpty &&
                    workingHours != null)
                  const Divider(height: 16),
                if (workingHours != null && workingHours.isNotEmpty)
                  _buildDetailRow(
                    AppLocalizations.of(
                      context,
                    )!.translate('working_hours_label'),
                    workingHours,
                  ),
                if (workingHours != null &&
                    workingHours.isNotEmpty &&
                    paymentTerms != null)
                  const Divider(height: 16),
                if (paymentTerms != null && paymentTerms.isNotEmpty)
                  _buildDetailRow(
                    AppLocalizations.of(
                      context,
                    )!.translate('payment_terms_label'),
                    paymentTerms,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          if (businessAddress != null ||
              city != null ||
              state != null ||
              pincode != null) ...[
            Text(
              AppLocalizations.of(context)!.translate('business_location'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (businessAddress != null && businessAddress.isNotEmpty)
                    Text(
                      businessAddress,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (businessAddress != null &&
                      businessAddress.isNotEmpty &&
                      (city != null || state != null))
                    const SizedBox(height: 4),
                  if (city != null || state != null || pincode != null)
                    Text(
                      [
                        city,
                        state,
                        pincode,
                      ].where((e) => e != null && e.isNotEmpty).join(', '),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          Text(
            AppLocalizations.of(context)!.translate('about_services'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description != null && description.isNotEmpty
                ? description
                : AppLocalizations.of(
                    context,
                  )!.translate('about_services_default'),
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String value, String label, {Color? color}) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color ?? Colors.black,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildProductsSection() {
    final products = _vendor!.products;

    if (products == null || products.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(
              context,
            )!.translate('featured_packages_products'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return _buildProductCard(product);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    final name = product['name'] ?? 'Product';
    final price = product['price'] ?? 0;
    final image = product['image'];
    final category = product['category'] ?? '';

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
              ),
              child: image != null
                  ? ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(8),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: image,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(
                            color: WzColors.primary,
                            strokeWidth: 2,
                          ),
                        ),
                        errorWidget: (context, url, error) => const Center(
                          child: Icon(
                            Icons.image,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    )
                  : const Center(
                      child: Icon(Icons.image, size: 40, color: Colors.grey),
                    ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (category.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: WzColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        fontSize: 10,
                        color: WzColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${price.toString()}',
                  style: TextStyle(
                    fontSize: 12,
                    color: WzColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            AppLocalizations.of(context)!.translate('ratings'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          TextButton(
            onPressed: _showRateVendorSheet,
            child: Text(
              AppLocalizations.of(context)!.translate('rate_vendor'),
              style: TextStyle(
                fontSize: 14,
                color: WzColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRateVendorSheet() {
    int rating = 5;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.translate('rate_vendor'),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Text(
                    AppLocalizations.of(context)!.translate('your_rating'),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return GestureDetector(
                        onTap: () {
                          setModalState(() {
                            rating = index + 1;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(
                            index < rating ? Icons.star : Icons.star_border,
                            size: 48,
                            color: Colors.amber,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _submitRating(rating);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: WzColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(
                          context,
                        )!.translate('submit_rating'),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitRating(int rating) async {
    try {
      final authProvider = context.read<AuthProvider>();
      final currentUser = authProvider.currentUser;

      if (currentUser == null) {
        WzToast.show(
          context,
          message: AppLocalizations.of(
            context,
          )!.translate('user_not_authenticated'),
          type: WzToastType.error,
        );
        return;
      }

      final response = await _vendorFeaturesRepository.submitReview(
        vendorId: _vendor!.id,
        userId: currentUser.id,
        rating: rating,
        comment: 'User rated this vendor $rating stars',
      );

      if (response.success) {
        WzToast.show(
          context,
          message: AppLocalizations.of(
            context,
          )!.translate('rating_submitted_success'),
          type: WzToastType.success,
        );

        _loadVendorProfile();
      } else {
        WzToast.show(
          context,
          message:
              response.message ??
              AppLocalizations.of(context)!.translate('rating_submit_failed'),
          type: WzToastType.error,
        );
      }
    } catch (e) {
      debugPrint('Error submitting rating: $e');
      WzToast.show(
        context,
        message: AppLocalizations.of(
          context,
        )!.translate('rating_submit_failed'),
        type: WzToastType.error,
      );
    }
  }

  void _showGetQuoteSheet() {
    final dateController = TextEditingController();
    final detailsController = TextEditingController();
    DateTime? selectedDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(
                          context,
                        )!.translate('get_quote_title'),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Text(
                    AppLocalizations.of(context)!.translate('event_date_label'),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: dateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: '04-Jan-2027',
                      suffixIcon: const Icon(Icons.calendar_today),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 730)),
                      );
                      if (date != null) {
                        selectedDate = date;
                        dateController.text = DateFormat(
                          'dd-MMM-yyyy',
                        ).format(date);
                        setModalState(() {});
                      }
                    },
                  ),
                  const SizedBox(height: 20),

                  Text(
                    AppLocalizations.of(
                      context,
                    )!.translate('event_details_label'),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: detailsController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText:
                          'Example: 2 days of photography with 1 videographer...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final authProvider = context.read<AuthProvider>();
                        if (!authProvider.isAuthenticated) {
                          Navigator.pushNamed(context, AppRoutes.loginChoice);
                          return;
                        }

                        if (selectedDate == null ||
                            detailsController.text.trim().isEmpty) {
                          WzToast.show(
                            context,
                            message: AppLocalizations.of(
                              context,
                            )!.translate('fill_all_fields_error'),
                          );
                          return;
                        }
                        _sendQuoteRequest(
                          selectedDate!,
                          detailsController.text.trim(),
                        );
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: WzColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(
                          context,
                        )!.translate('send_request_button'),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAvailabilitySheet() {
    final dateController = TextEditingController();
    final detailsController = TextEditingController();
    DateTime? selectedDate;
    DateTime focusedMonth = DateTime.now();

    Map<DateTime, String> vendorAvailability = {};
    if (_vendor?.vendorDetails?['availability'] != null) {
      final availabilityList = _vendor!.vendorDetails!['availability'] as List;
      for (var entry in availabilityList) {
        try {
          final date = DateTime.parse(entry['date']);
          final dateKey = DateTime(date.year, date.month, date.day);
          vendorAvailability[dateKey] = entry['status'];
        } catch (e) {
          debugPrint('[VENDOR_PROFILE] Error parsing availability: $e');
        }
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(
                        context,
                      )!.translate('check_availability_title'),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chevron_left),
                              onPressed: () {
                                setModalState(() {
                                  focusedMonth = DateTime(
                                    focusedMonth.year,
                                    focusedMonth.month - 1,
                                  );
                                });
                              },
                            ),
                            Text(
                              DateFormat('MMMM yyyy').format(focusedMonth),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_right),
                              onPressed: () {
                                setModalState(() {
                                  focusedMonth = DateTime(
                                    focusedMonth.year,
                                    focusedMonth.month + 1,
                                  );
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        _buildCalendarGrid(
                          focusedMonth,
                          vendorAvailability,
                          selectedDate,
                          (date) {
                            setModalState(() {
                              selectedDate = date;
                              dateController.text = DateFormat(
                                'dd-MMM-yyyy',
                              ).format(date);
                            });
                          },
                        ),

                        const SizedBox(height: 24),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildLegendItem(
                              AppLocalizations.of(
                                context,
                              )!.translate('available'),
                              Colors.green,
                            ),
                            _buildLegendItem(
                              AppLocalizations.of(context)!.translate('booked'),
                              const Color(0xFFEF2F55),
                            ),
                            _buildLegendItem(
                              AppLocalizations.of(
                                context,
                              )!.translate('unavailable'),
                              Colors.grey,
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        Text(
                          AppLocalizations.of(
                            context,
                          )!.translate('details_optional'),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: detailsController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Add any additional details...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final authProvider = context.read<AuthProvider>();
                      if (!authProvider.isAuthenticated) {
                        Navigator.pushNamed(context, AppRoutes.loginChoice);
                        return;
                      }

                      if (selectedDate == null) {
                        WzToast.show(
                          context,
                          message: AppLocalizations.of(
                            context,
                          )!.translate('select_date_error'),
                        );
                        return;
                      }
                      _sendAvailabilityRequest(
                        selectedDate!,
                        detailsController.text.trim(),
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: WzColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'SEND REQUEST',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendQuoteRequest(DateTime eventDate, String details) async {
    try {
      debugPrint('[VENDOR_PROFILE] 📋 Sending quote request...');
      debugPrint('[VENDOR_PROFILE] Vendor ID: ${_vendor!.id}');
      debugPrint('[VENDOR_PROFILE] Event Date: $eventDate');
      debugPrint('[VENDOR_PROFILE] Details: $details');

      final apiDate = DateFormat('yyyy-MM-dd').format(eventDate);
      final formattedDate = DateFormat('dd-MMM-yyyy').format(eventDate);

      final requestDetails = details.isNotEmpty
          ? details
          : 'Quote request for $formattedDate';

      final response = await _vendorFeaturesRepository.submitRequest(
        vendorId: _vendor!.id,
        type: 'quote',
        eventDate: apiDate,
        details: requestDetails,
      );

      if (!response.success) {
        debugPrint(
          '[VENDOR_PROFILE] ❌ Quote request failed: ${response.message}',
        );
        WzToast.show(
          context,
          message:
              response.message ??
              AppLocalizations.of(context)!.translate('request_send_failed'),
          type: WzToastType.error,
        );
        return;
      }

      debugPrint('[VENDOR_PROFILE] ✅ Quote request sent successfully');

      WzToast.show(
        context,
        message: AppLocalizations.of(context)!.translate('quote_request_sent'),
        type: WzToastType.success,
      );
    } catch (e) {
      debugPrint('[VENDOR_PROFILE] ❌ Error sending quote request: $e');
      WzToast.show(
        context,
        message: AppLocalizations.of(context)!.translate('request_send_failed'),
        type: WzToastType.error,
      );
    }
  }

  Future<void> _sendAvailabilityRequest(
    DateTime eventDate,
    String details,
  ) async {
    try {
      debugPrint('[VENDOR_PROFILE] 📅 Sending availability request...');
      debugPrint('[VENDOR_PROFILE] Vendor ID: ${_vendor!.id}');
      debugPrint('[VENDOR_PROFILE] Event Date: $eventDate');
      debugPrint('[VENDOR_PROFILE] Details: $details');

      final apiDate = DateFormat('yyyy-MM-dd').format(eventDate);
      final formattedDate = DateFormat('dd-MMM-yyyy').format(eventDate);

      final requestDetails = details.isNotEmpty
          ? details
          : 'Checking availability for $formattedDate';

      final response = await _vendorFeaturesRepository.submitRequest(
        vendorId: _vendor!.id,
        type: 'availability',
        eventDate: apiDate,
        details: requestDetails,
      );

      if (!response.success) {
        debugPrint(
          '[VENDOR_PROFILE] ❌ Availability request failed: ${response.message}',
        );
        WzToast.show(
          context,
          message:
              response.message ??
              AppLocalizations.of(context)!.translate('request_send_failed'),
          type: WzToastType.error,
        );
        return;
      }

      debugPrint('[VENDOR_PROFILE] ✅ Availability request sent successfully');

      WzToast.show(
        context,
        message: AppLocalizations.of(
          context,
        )!.translate('availability_request_sent'),
        type: WzToastType.success,
      );
    } catch (e) {
      debugPrint('[VENDOR_PROFILE] ❌ Error sending availability request: $e');
      WzToast.show(
        context,
        message: AppLocalizations.of(context)!.translate('request_send_failed'),
        type: WzToastType.error,
      );
    }
  }

  Widget _buildCalendarGrid(
    DateTime month,
    Map<DateTime, String> availability,
    DateTime? selectedDate,
    Function(DateTime) onDateSelected,
  ) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday % 7;
    final daysInMonth = lastDayOfMonth.day;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
              .map(
                (day) => SizedBox(
                  width: 40,
                  child: Center(
                    child: Text(
                      day,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 8),

        ...List.generate((daysInMonth + firstWeekday + 6) ~/ 7, (weekIndex) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (dayIndex) {
                final dayNumber = weekIndex * 7 + dayIndex - firstWeekday + 1;
                if (dayNumber < 1 || dayNumber > daysInMonth) {
                  return const SizedBox(width: 40, height: 40);
                }

                final date = DateTime(month.year, month.month, dayNumber);
                final dateKey = DateTime(date.year, date.month, date.day);
                final status = availability[dateKey];
                final isSelected =
                    selectedDate != null &&
                    dateKey.year == selectedDate.year &&
                    dateKey.month == selectedDate.month &&
                    dateKey.day == selectedDate.day;
                final isPast = date.isBefore(
                  DateTime.now().subtract(const Duration(days: 1)),
                );

                Color bgColor = Colors.transparent;
                Color textColor = Colors.black;

                if (isPast) {
                  textColor = Colors.grey.shade400;
                } else if (status == 'booked') {
                  bgColor = const Color(0xFFEF2F55).withOpacity(0.2);
                  textColor = const Color(0xFFEF2F55);
                } else if (status == 'unavailable') {
                  bgColor = Colors.grey.withOpacity(0.2);
                  textColor = Colors.grey;
                } else if (status == 'available') {
                  bgColor = Colors.green.withOpacity(0.2);
                  textColor = Colors.green;
                }

                if (isSelected) {
                  bgColor = WzColors.primary;
                  textColor = Colors.white;
                }

                return GestureDetector(
                  onTap: isPast ? null : () => onDateSelected(date),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: bgColor,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: WzColors.primary, width: 2)
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '$dayNumber',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 1),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black87),
        ),
      ],
    );
  }
}
