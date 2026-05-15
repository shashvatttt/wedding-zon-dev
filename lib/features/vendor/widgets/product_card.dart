import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../../../shared/widgets/wz_toast.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProductCard({
    super.key,
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: product.images.isNotEmpty
                        ? Image.network(
                            product.images.first,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey[200],
                                child: Icon(
                                  Icons.image_outlined,
                                  color: Colors.grey[400],
                                  size: 32,
                                ),
                              );
                            },
                          )
                        : Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[200],
                            child: Icon(
                              Icons.image_outlined,
                              color: Colors.grey[400],
                              size: 32,
                            ),
                          ),
                  ),

                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: product.isActive
                            ? Colors.green
                            : Colors.grey[600],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        product.isActive ? 'Active' : 'Inactive',
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    Row(
                      children: [
                        Icon(
                          Icons.category_outlined,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            product.category,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    Row(
                      children: [
                        Icon(
                          Icons.currency_rupee,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 2),
                        Text(
                          product.price.toStringAsFixed(0),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE91E63),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    if (product.numReviews != null && product.numReviews! > 0)
                      Row(
                        children: [
                          Icon(Icons.star, size: 14, color: Colors.amber[700]),
                          const SizedBox(width: 4),
                          Text(
                            '${product.averageRating?.toStringAsFixed(1) ?? '0.0'} (${product.numReviews} reviews)',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      )
                    else
                      Row(
                        children: [
                          Icon(
                            Icons.star_outline,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'No reviews yet',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                itemBuilder: (context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: 12),
                        Text('Edit Product'),
                      ],
                    ),
                  ),

                  const PopupMenuDivider(),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: Colors.red),
                        SizedBox(width: 12),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit();
                  } else if (value == 'delete') {
                    onDelete();
                  } else if (value == 'toggle') {
                    WzToast.show(
                      context,
                      message: product.isActive
                          ? 'Product deactivated'
                          : 'Product activated',
                      type: WzToastType.normal,
                    );
                  } else if (value == 'duplicate') {
                    WzToast.show(
                      context,
                      message: 'Product duplicated',
                      type: WzToastType.success,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
