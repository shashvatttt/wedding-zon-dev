import 'package:flutter/material.dart';
import 'package:weddingzon/core/theme/wz_colors.dart';
import 'package:weddingzon/core/localization/app_localizations.dart';

class VendorCategoriesScreenUI extends StatelessWidget {
  final List<Map<String, String>> categories;
  final String selectedCategory;

  const VendorCategoriesScreenUI({
    super.key,
    required this.categories,
    required this.selectedCategory,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: WzColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context)!.translate('featured_categories'),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.85,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final categoryData = categories[index];
              final categoryKey = categoryData['key']!;
              final categoryLabelKey = categoryData['label']!;
              final isSelected = selectedCategory == categoryKey;
              final icon = _getCategoryIcon(categoryKey);

              return GestureDetector(
                onTap: () {
                  Navigator.of(context).pop(categoryKey);
                },
                child: Container(
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              WzColors.primary,
                              WzColors.primary.withValues(alpha: 0.8),
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
                              color: WzColors.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.2)
                              : WzColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          icon,
                          size: 32,
                          color: isSelected ? Colors.white : WzColors.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          AppLocalizations.of(
                            context,
                          )!.translate(categoryLabelKey),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : Colors.black87,
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
}
