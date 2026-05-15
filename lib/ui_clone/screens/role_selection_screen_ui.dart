import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weddingzon/core/theme/wz_colors.dart';
import 'package:weddingzon/core/theme/wz_text_styles.dart';
import 'package:weddingzon/core/routes/app_routes.dart';
import 'package:weddingzon/features/auth/providers/auth_provider.dart';
import 'package:weddingzon/core/localization/app_localizations.dart';
import 'package:weddingzon/shared/widgets/wz_toast.dart';

class RoleSelectionScreenUI extends StatelessWidget {
  const RoleSelectionScreenUI({super.key});

  void _selectRole(BuildContext context, String selection) {
    debugPrint('[ONBOARDING] Selection: $selection');

    if (selection == 'ecommerce') {
      WzToast.show(
        context,
        message: AppLocalizations.of(context)!.translate('coming_soon'),
      );
      return;
    }

    final String role;
    final String gender = '';

    switch (selection) {
      case 'member':
        role = 'member';
        break;
      default:
        role = selection;
    }

    debugPrint('[ONBOARDING] Mapped to role: $role, gender: $gender');

    if (role == 'franchise') {
      debugPrint(
        '[ONBOARDING] 🏢 Franchise role selected - calling _assignFranchiseRole',
      );
      _assignFranchiseRole(context);
    } else if (role == 'vendor') {
      debugPrint(
        '[ONBOARDING] 🏪 Vendor role selected - calling _assignVendorRole',
      );
      _assignVendorRole(context);
    } else {
      debugPrint(
        '[ONBOARDING] 👤 Member role selected - navigating to profile basic details',
      );
      Navigator.pushNamed(
        context,
        AppRoutes.profileBasicDetails,
        arguments: {'role': role, 'gender': gender},
      );
    }
  }

  void _assignVendorRole(BuildContext context) async {
    debugPrint('[ONBOARDING] ========== ASSIGNING VENDOR ROLE ==========');
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    debugPrint('[ONBOARDING] 📝 Updating user profile with role: vendor');
    final success = await authProvider.updateProfile({'role': 'vendor'});

    debugPrint('[ONBOARDING] 📊 Update profile result: $success');

    if (success && context.mounted) {
      debugPrint(
        '[ONBOARDING] ✅ Profile update successful, triggering routing...',
      );
      if (authProvider.currentUser != null) {
        authProvider.routeUser(authProvider.currentUser!);
      }
    }
    debugPrint('[ONBOARDING] ========== END VENDOR ROLE ASSIGNMENT ==========');
  }

  void _assignFranchiseRole(BuildContext context) async {
    debugPrint('[ONBOARDING] ========== ASSIGNING FRANCHISE ROLE ==========');
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    debugPrint('[ONBOARDING] 📝 Updating user profile with role: franchise');
    final success = await authProvider.updateProfile({'role': 'franchise'});

    debugPrint('[ONBOARDING] 📊 Update profile result: $success');

    if (success && context.mounted) {
      debugPrint(
        '[ONBOARDING] ✅ Profile update successful, triggering routing...',
      );
      if (authProvider.currentUser != null) {
        authProvider.routeUser(authProvider.currentUser!);
      }
    }
    debugPrint(
      '[ONBOARDING] ========== END FRANCHISE ROLE ASSIGNMENT ==========',
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
      '📍 [SCREEN] ========== ROLE SELECTION SCREEN ========== [ROUTE: ${AppRoutes.roleSelection}]',
    );
    return Scaffold(
      backgroundColor: WzColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 23.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 68.0),

              Center(
                child: Text(
                  AppLocalizations.of(
                    context,
                  )!.translate('role_selection_title'),
                  style: WzTextStyles.heading3.copyWith(
                    fontSize: 24.0,
                    fontWeight: FontWeight.w600,
                    height: 22 / 24,
                    color: WzColors.text,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 57.0),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _RoleCard(
                    icon: Icons.favorite,
                    iconColor: WzColors.primary,
                    title: AppLocalizations.of(
                      context,
                    )!.translate('role_matrimonial'),
                    subtitle: AppLocalizations.of(
                      context,
                    )!.translate('role_matrimonial_subtitle'),
                    onTap: () => _selectRole(context, 'member'),
                  ),
                  _RoleCard(
                    icon: Icons.camera_alt,
                    iconColor: Colors.orange,
                    title: AppLocalizations.of(
                      context,
                    )!.translate('role_vendors'),
                    subtitle: AppLocalizations.of(
                      context,
                    )!.translate('role_vendors_subtitle'),
                    onTap: () => _selectRole(context, 'vendor'),
                  ),
                ],
              ),

              const SizedBox(height: 48.0),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _RoleCard(
                    icon: Icons.business_center,
                    iconColor: Colors.green,
                    title: AppLocalizations.of(
                      context,
                    )!.translate('role_franchise'),
                    subtitle: AppLocalizations.of(
                      context,
                    )!.translate('role_franchise_subtitle'),
                    onTap: () => _selectRole(context, 'franchise'),
                  ),
                  _RoleCard(
                    icon: Icons.shopping_bag,
                    iconColor: Colors.purple,
                    title: AppLocalizations.of(
                      context,
                    )!.translate('role_shopping'),
                    subtitle: AppLocalizations.of(
                      context,
                    )!.translate('role_shopping_subtitle'),
                    onTap: () => _selectRole(context, 'ecommerce'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _RoleCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 170.0,
        height: 193.0,
        decoration: BoxDecoration(
          color: WzColors.white,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: const [
            BoxShadow(
              color: Color(0x40000000),
              offset: Offset(0, 0),
              blurRadius: 4.0,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48.0, color: iconColor),

            const SizedBox(height: 16.0),

            Text(
              title,
              style: WzTextStyles.heading3.copyWith(
                fontSize: 24.0,
                fontWeight: FontWeight.w600,
                height: 22 / 24,
                color: WzColors.text,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 4.0),

            Text(
              subtitle,
              style: WzTextStyles.body2.copyWith(
                fontSize: 14.0,
                fontWeight: FontWeight.w400,
                height: 22 / 14,
                color: WzColors.text,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
