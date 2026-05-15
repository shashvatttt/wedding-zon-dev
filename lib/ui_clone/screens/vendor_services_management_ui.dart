import 'package:flutter/material.dart';
import '../../core/theme/wz_colors.dart';
import '../../core/theme/wz_text_styles.dart';

import 'package:weddingzon/core/localization/app_localizations.dart';

class VendorServicesManagementScreenUI extends StatelessWidget {
  const VendorServicesManagementScreenUI({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {},
        ),
        title: Text(
          AppLocalizations.of(context)!.myServices,
          style: WzTextStyles.heading2.copyWith(
            fontSize: 20,
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: WzColors.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: WzColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFBC3CF)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: WzColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.manageServicesDesc,
                      style: WzTextStyles.body2.copyWith(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Text(
              AppLocalizations.of(context)!.activeServices,
              style: WzTextStyles.heading2.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 16),

            _buildServiceCard(
              'Wedding Photography',
              'Professional wedding photography services',
              '₹50,000 - ₹1,00,000',
              true,
            ),

            _buildServiceCard(
              'Pre-Wedding Shoot',
              'Outdoor and studio pre-wedding photography',
              '₹25,000 - ₹50,000',
              true,
            ),

            _buildServiceCard(
              'Candid Photography',
              'Candid moments captured beautifully',
              '₹30,000 - ₹60,000',
              false,
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: Text(
                  AppLocalizations.of(context)!.addNewService,
                  style: WzTextStyles.body1.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: WzColors.primary,
                  side: const BorderSide(color: WzColors.primary, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(
    String title,
    String description,
    String price,
    bool isActive,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFBC3CF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: WzTextStyles.heading3.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Switch(
                value: isActive,
                onChanged: (value) {},
                activeTrackColor: WzColors.primary,
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            description,
            style: WzTextStyles.body2.copyWith(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: WzColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  price,
                  style: WzTextStyles.body1.copyWith(
                    fontSize: 14,
                    color: WzColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                onPressed: () {},
                color: Colors.grey[600],
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                onPressed: () {},
                color: Colors.red[400],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
