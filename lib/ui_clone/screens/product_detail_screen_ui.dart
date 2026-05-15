import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../features/vendor/models/product_model.dart';
import '../../core/theme/wz_colors.dart';
import '../../core/theme/wz_text_styles.dart';
import '../../core/localization/app_localizations.dart';
import '../../shared/widgets/wz_toast.dart';

class ProductDetailScreenUI extends StatefulWidget {
  final Product product;

  const ProductDetailScreenUI({super.key, required this.product});

  @override
  State<ProductDetailScreenUI> createState() => _ProductDetailScreenUIState();
}

class _ProductDetailScreenUIState extends State<ProductDetailScreenUI> {
  AppLocalizations get l10n => AppLocalizations.of(context)!;
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(l10n.productDetailsTitle, style: WzTextStyles.heading4),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              WzToast.show(
                context,
                message: l10n.shareComingSoon,
                type: WzToastType.normal,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                PageView.builder(
                  itemCount: widget.product.images.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentImageIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return CachedNetworkImage(
                      imageUrl: widget.product.images[index],
                      fit: BoxFit.contain,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[100],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[100],
                        child: const Center(
                          child: Icon(
                            Icons.image,
                            size: 80,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                if (widget.product.images.length > 1)
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        widget.product.images.length,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentImageIndex == index
                                ? WzColors.primary
                                : Colors.grey[300],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: WzColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.product.category,
                          style: WzTextStyles.caption.copyWith(
                            color: WzColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        '₹${widget.product.price.toStringAsFixed(0)}',
                        style: WzTextStyles.heading2.copyWith(
                          color: WzColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Text(widget.product.name, style: WzTextStyles.heading3),
                  const SizedBox(height: 24),

                  Text(l10n.description, style: WzTextStyles.heading4),
                  const SizedBox(height: 8),
                  Text(
                    widget.product.description,
                    style: WzTextStyles.body1.copyWith(
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Divider(),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.grey[200],
                        radius: 20,
                        child: const Icon(Icons.store, color: Colors.grey),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.soldBy,
                            style: WzTextStyles.caption.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            '${l10n.vendorId}: ${widget.product.vendorId}',
                            style: WzTextStyles.body2.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () {
              WzToast.show(
                context,
                message: l10n.addedToCartMsg.replaceFirst(
                  '{productName}',
                  widget.product.name,
                ),
                type: WzToastType.success,
              );

              Future.delayed(const Duration(seconds: 1), () {
                WzToast.show(
                  context,
                  message: l10n.cartComingSoon,
                  type: WzToastType.normal,
                );
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: WzColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shopping_cart_outlined),
                const SizedBox(width: 8),
                Text(
                  l10n.addToCart,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
