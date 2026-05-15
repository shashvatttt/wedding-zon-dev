import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../repositories/vendor_repository.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/api_service.dart';
import '../../../shared/widgets/wz_toast.dart';

class VendorPaymentScreen extends StatefulWidget {
  const VendorPaymentScreen({super.key});

  @override
  State<VendorPaymentScreen> createState() => _VendorPaymentScreenState();
}

class _VendorPaymentScreenState extends State<VendorPaymentScreen> {
  bool _isProcessing = false;

  void _processPayment() async {
    debugPrint('');
    debugPrint(
      '╔════════════════════════════════════════════════════════════╗',
    );
    debugPrint(
      '║ [VENDOR_PAYMENT] 💳 PAY NOW CLICKED                        ║',
    );
    debugPrint(
      '╚════════════════════════════════════════════════════════════╝',
    );

    setState(() => _isProcessing = true);
    debugPrint('[VENDOR_PAYMENT] ⏳ Processing payment...');

    await Future.delayed(const Duration(seconds: 2));
    debugPrint('[VENDOR_PAYMENT] ✅ Payment simulation complete');

    if (!mounted) {
      debugPrint('[VENDOR_PAYMENT] ⚠️ Widget unmounted during payment');
      return;
    }

    try {
      final apiService = context.read<ApiService>();
      final repository = VendorRepository(apiService);
      final authProvider = context.read<AuthProvider>();

      debugPrint('[VENDOR_PAYMENT] ========================================');
      debugPrint('[VENDOR_PAYMENT] 📤 Sending approval request to admin...');
      debugPrint(
        '[VENDOR_PAYMENT] 🔄 Updating vendor_status to: pending_approval',
      );
      debugPrint('[VENDOR_PAYMENT] 📍 Endpoint: PATCH /users/me');

      await repository.updateVendorStatus('pending_approval');

      debugPrint('[VENDOR_PAYMENT] ✅ Approval request sent successfully!');
      debugPrint('[VENDOR_PAYMENT] 🔄 Refreshing user data from backend...');

      await authProvider.refreshUser();

      if (!mounted) {
        debugPrint('[VENDOR_PAYMENT] ⚠️ Widget unmounted after refresh');
        return;
      }

      debugPrint('[VENDOR_PAYMENT] 📊 Current user status:');
      final user = authProvider.currentUser;
      if (user != null) {
        debugPrint('[VENDOR_PAYMENT]   - ID: ${user.id}');
        debugPrint('[VENDOR_PAYMENT]   - vendor_status: ${user.vendorStatus}');
        debugPrint(
          '[VENDOR_PAYMENT]   - vendor_details: ${user.vendorDetails}',
        );
      } else {
        debugPrint('[VENDOR_PAYMENT]   - User is NULL');
      }

      debugPrint('[VENDOR_PAYMENT] ========================================');
      debugPrint('[VENDOR_PAYMENT] 🚀 Routing user based on updated status...');

      if (user != null) {
        authProvider.routeUser(user);
      } else {
        debugPrint(
          '[VENDOR_PAYMENT] ⚠️ No user found, routing to approval screen',
        );
        Navigator.pushReplacementNamed(context, AppRoutes.vendorApproval);
      }

      debugPrint('[VENDOR_PAYMENT] ✅ Navigation complete');
      debugPrint('[VENDOR_PAYMENT] ========================================');
    } catch (e) {
      setState(() => _isProcessing = false);

      debugPrint('[VENDOR_PAYMENT] ========================================');
      debugPrint('[VENDOR_PAYMENT] ❌❌❌ EXCEPTION CAUGHT ❌❌❌');
      debugPrint('[VENDOR_PAYMENT] Error Type: ${e.runtimeType}');
      debugPrint('[VENDOR_PAYMENT] Error Message: $e');
      debugPrint('[VENDOR_PAYMENT] ========================================');

      if (!mounted) return;

      WzToast.show(
        context,
        message: 'Payment verification failed: $e',
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
    return Scaffold(
      appBar: AppBar(title: const Text('Vendor Activation')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.store_outlined, size: 80, color: Colors.orange),
            const SizedBox(height: 24),
            const Text(
              'Activate Your Vendor Account',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'To start offering your services and accessing the vendor dashboard, a one-time activation fee is required.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange),
              ),
              child: const Column(
                children: [
                  Text(
                    'Activation Fee',
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '₹15,000',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            CustomButton(
              text: 'Pay Now',
              isLoading: _isProcessing,
              onPressed: _processPayment,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
