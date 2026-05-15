import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/franchise_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../vendor/repositories/vendor_repository.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/api_service.dart';
import '../../../core/theme/wz_colors.dart';
import '../../../shared/widgets/scaffold_with_background.dart';
import '../../../shared/widgets/wz_toast.dart';

class FranchisePaymentScreen extends StatefulWidget {
  const FranchisePaymentScreen({super.key});

  @override
  State<FranchisePaymentScreen> createState() => _FranchisePaymentScreenState();
}

class _FranchisePaymentScreenState extends State<FranchisePaymentScreen> {
  bool _isProcessing = false;

  void _processPayment() async {
    debugPrint('');
    debugPrint(
      '╔════════════════════════════════════════════════════════════╗',
    );
    debugPrint(
      '║ [PAYMENT] 💳 PAY NOW CLICKED                               ║',
    );
    debugPrint(
      '╚════════════════════════════════════════════════════════════╝',
    );

    setState(() => _isProcessing = true);
    debugPrint('[PAYMENT] ⏳ Processing payment...');

    await Future.delayed(const Duration(seconds: 2));
    debugPrint('[PAYMENT] ✅ Payment simulation complete');

    if (!mounted) {
      debugPrint('[PAYMENT] ⚠️ Widget unmounted during payment');
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userRole = authProvider.currentUser?.role;
    final isVendor = userRole == 'vendor';

    debugPrint('[PAYMENT] ========================================');
    debugPrint('[PAYMENT] 👤 User Role: $userRole');
    debugPrint('[PAYMENT] 📤 Submitting payment to backend...');

    bool success = false;
    String? errorMessage;

    try {
      if (isVendor) {
        debugPrint('[PAYMENT] 📍 Endpoint: PATCH /users/me (vendor_status)');
        final apiService = context.read<ApiService>();
        final vendorRepository = VendorRepository(apiService);
        await vendorRepository.updateVendorStatus('pending_approval');
        success = true;
      } else {
        debugPrint('[PAYMENT] 📍 Endpoint: POST /api/franchise/payment');
        final franchiseProvider = Provider.of<FranchiseProvider>(
          context,
          listen: false,
        );
        success = await franchiseProvider.submitPayment();
        errorMessage = franchiseProvider.error;
      }
    } catch (e) {
      success = false;
      errorMessage = e.toString();
      debugPrint('[PAYMENT] ❌ Exception: $e');
    }

    debugPrint('[PAYMENT] ========================================');
    debugPrint(
      '[PAYMENT] 📥 Status update response: ${success ? 'SUCCESS' : 'FAILED'}',
    );

    if (success) {
      debugPrint('[PAYMENT] ✅ Approval request sent successfully!');
      debugPrint('[PAYMENT] 🔄 Refreshing user data from backend...');

      await authProvider.refreshUser();

      debugPrint('[PAYMENT] 📊 Current user status:');
      final user = authProvider.currentUser;
      if (user != null) {
        debugPrint('[PAYMENT]   - ID: ${user.id}');
        debugPrint('[PAYMENT]   - Role: ${user.role}');
        if (user.role == 'franchise') {
          debugPrint('[PAYMENT]   - franchise_status: ${user.franchiseStatus}');
          debugPrint(
            '[PAYMENT]   - franchise_details: ${user.franchiseDetails}',
          );
        } else if (user.role == 'vendor') {
          debugPrint('[PAYMENT]   - vendor_status: ${user.vendorStatus}');
          debugPrint('[PAYMENT]   - vendor_details: ${user.vendorDetails}');
        }
      } else {
        debugPrint('[PAYMENT]   - User is NULL');
      }

      if (!mounted) {
        debugPrint('[PAYMENT] ⚠️ Widget unmounted after refresh');
        return;
      }

      debugPrint('[PAYMENT] ========================================');
      debugPrint('[PAYMENT] 🚀 Navigating to Approval Screen...');
      debugPrint('[PAYMENT] 📍 Target Route: ${AppRoutes.franchiseApproval}');

      Navigator.pushReplacementNamed(context, AppRoutes.franchiseApproval);

      debugPrint('[PAYMENT] ✅ Navigation complete');
      debugPrint(
        '[PAYMENT] ℹ️ User will wait for admin approval on next screen',
      );
      debugPrint('[PAYMENT] ========================================');
    } else {
      setState(() => _isProcessing = false);

      debugPrint('[PAYMENT] ========================================');
      debugPrint('[PAYMENT] ❌ Failed to send approval request');
      debugPrint('[PAYMENT] 🔴 Error: $errorMessage');
      debugPrint('[PAYMENT] ========================================');

      if (!mounted) return;

      WzToast.show(
        context,
        message: errorMessage?.isNotEmpty == true
            ? errorMessage!
            : 'Payment verification failed. Please try again.',
        type: WzToastType.error,
      );
    }

    debugPrint(
      '╚════════════════════════════════════════════════════════════╝',
    );
    debugPrint('');
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWithBackground(
      appBar: AppBar(
        title: const Text('Franchise Activation'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withOpacity(0.0),
              WzColors.franchiseSoftBg.withOpacity(0.5),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Icon(
                Icons.verified_user_rounded,
                size: 100,
                color: WzColors.franchise,
              ),
              const SizedBox(height: 32),
              const Text(
                'Activate Your Franchise',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: WzColors.textDefault,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'To start managing profiles and accessing the franchise dashboard, a one-time activation fee is required.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: WzColors.textSecondary,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),

              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 32,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: WzColors.franchise.withOpacity(0.1),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                  border: Border.all(
                    color: WzColors.franchise.withOpacity(0.1),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Activation Fee',
                      style: TextStyle(
                        color: WzColors.franchise.withOpacity(0.8),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            '₹',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: WzColors.textDefault,
                            ),
                          ),
                        ),
                        Text(
                          '25,000',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: WzColors.textDefault,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green.shade600,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'One-time Payment',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              const Text(
                'By clicking "Pay Now", you agree to our terms of processing.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 16),

              CustomButton(
                text: 'Pay Now',
                isLoading: _isProcessing,
                onPressed: _processPayment,
                color: WzColors.franchise,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
