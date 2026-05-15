import 'package:flutter/material.dart';
import '../../../core/routes/app_routes.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../shared/widgets/wz_toast.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Your Role'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            const Text(
              'I am signing up as ...',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _RoleCard(
                  icon: Icons.favorite,
                  title: 'Members',
                  description: 'Find your partner',
                  role: 'member',
                  color: Colors.pink,
                  onTap: () => _selectRole(context, 'member'),
                ),
                _RoleCard(
                  icon: Icons.camera_alt,
                  title: 'Vendor',
                  description: 'Wedding services',
                  role: 'vendor',
                  color: Colors.orange,
                  onTap: () => _selectRole(context, 'vendor'),
                ),
                _RoleCard(
                  icon: Icons.business_center,
                  title: 'Franchise',
                  description: 'Business partner',
                  role: 'franchise',
                  color: Colors.green,
                  onTap: () => _selectRole(context, 'franchise'),
                ),
                _RoleCard(
                  icon: Icons.shopping_bag,
                  title: 'Ecommerce',
                  description: 'Shop wedding products',
                  role: 'ecommerce',
                  color: Colors.purple,
                  onTap: () => _selectRole(context, 'ecommerce'),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _selectRole(BuildContext context, String selection) {
    debugPrint('[ONBOARDING] Selection: $selection');

    if (selection == 'ecommerce') {
      WzToast.show(context, message: "Coming Soon", type: WzToastType.normal);
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
        '[ONBOARDING] 👤 Member role selected - navigating to profile form',
      );
      Navigator.pushNamed(
        context,
        AppRoutes.profileForm,
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
        debugPrint(
          '[ONBOARDING] 👤 Current user: ${authProvider.currentUser!.email}',
        );
        debugPrint(
          '[ONBOARDING] 🎯 Current user role: ${authProvider.currentUser!.role}',
        );
        authProvider.routeUser(authProvider.currentUser!);
      } else {
        debugPrint('[ONBOARDING] ❌ ERROR: Current user is null after update');
      }
    } else {
      debugPrint('[ONBOARDING] ❌ Profile update failed or context not mounted');
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
        debugPrint(
          '[ONBOARDING] 👤 Current user: ${authProvider.currentUser!.email}',
        );
        debugPrint(
          '[ONBOARDING] 🎯 Current user role: ${authProvider.currentUser!.role}',
        );
        authProvider.routeUser(authProvider.currentUser!);
      } else {
        debugPrint('[ONBOARDING] ❌ ERROR: Current user is null after update');
      }
    } else {
      debugPrint('[ONBOARDING] ❌ Profile update failed or context not mounted');
    }
    debugPrint(
      '[ONBOARDING] ========== END FRANCHISE ROLE ASSIGNMENT ==========',
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String role;
  final Color color;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.role,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
