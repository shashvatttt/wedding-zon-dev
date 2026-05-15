import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../core/routes/app_routes.dart';

import '../../../shared/widgets/scaffold_with_background.dart';
import 'dart:async';
import '../../../shared/widgets/wz_toast.dart';

class VendorApprovalScreen extends StatefulWidget {
  const VendorApprovalScreen({super.key});

  @override
  State<VendorApprovalScreen> createState() => _VendorApprovalScreenState();
}

class _VendorApprovalScreenState extends State<VendorApprovalScreen> {
  bool _isChecking = false;
  Timer? _autoCheckTimer;
  int _checkCount = 0;

  @override
  void initState() {
    super.initState();
    debugPrint('');
    debugPrint(
      '╔════════════════════════════════════════════════════════════╗',
    );
    debugPrint(
      '║ [VENDOR_APPROVAL] 📋 APPROVAL SCREEN LOADED                ║',
    );
    debugPrint(
      '╚════════════════════════════════════════════════════════════╝',
    );
    debugPrint('[VENDOR_APPROVAL] ⏰ Starting auto-check timer (every 5 seconds)');

    _autoCheckTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        _checkCount++;
        debugPrint('[VENDOR_APPROVAL] ⏰ Auto-check triggered (count: $_checkCount)');
        _checkStatus(isAuto: true);
      }
    });
  }

  @override
  void dispose() {
    debugPrint('[VENDOR_APPROVAL] 🔴 Disposing approval screen, cancelling timer');
    _autoCheckTimer?.cancel();
    super.dispose();
  }

  void _checkStatus({bool isAuto = false}) async {
    if (_isChecking) {
      debugPrint('[VENDOR_APPROVAL] ⚠️ Already checking status, skipping...');
      return;
    }

    debugPrint('');
    debugPrint(
      '╔════════════════════════════════════════════════════════════╗',
    );
    debugPrint(
      '║ [VENDOR_APPROVAL] 🔍 CHECK STATUS ${isAuto ? '(AUTO)' : '(MANUAL)'}              ║',
    );
    debugPrint(
      '╚════════════════════════════════════════════════════════════╝',
    );

    setState(() => _isChecking = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    debugPrint('[VENDOR_APPROVAL] 🔄 Refreshing user data from backend...');
    await authProvider.refreshUser();

    if (!mounted) {
      debugPrint('[VENDOR_APPROVAL] ⚠️ Widget unmounted during status check');
      return;
    }

    final user = authProvider.currentUser;
    final currentStatus = user?.vendorStatus;

    debugPrint('[VENDOR_APPROVAL] ========================================');
    debugPrint('[VENDOR_APPROVAL] 📊 Current User Status:');
    if (user != null) {
      debugPrint('[VENDOR_APPROVAL]   - ID: ${user.id}');
      debugPrint('[VENDOR_APPROVAL]   - Name: ${user.fullName}');
      debugPrint('[VENDOR_APPROVAL]   - Role: ${user.role}');
      debugPrint('[VENDOR_APPROVAL]   - vendor_status: ${user.vendorStatus}');
      debugPrint('[VENDOR_APPROVAL]   - vendor_details: ${user.vendorDetails}');
    } else {
      debugPrint('[VENDOR_APPROVAL]   - User is NULL');
    }
    debugPrint('[VENDOR_APPROVAL] ========================================');

    setState(() => _isChecking = false);

    if (currentStatus == 'active') {
      debugPrint('[VENDOR_APPROVAL] ========================================');
      debugPrint('[VENDOR_APPROVAL] ✅✅✅ APPROVED! STATUS IS ACTIVE! ✅✅✅');
      debugPrint('[VENDOR_APPROVAL] ========================================');
      debugPrint('[VENDOR_APPROVAL] 🎉 Admin has approved the vendor!');
      debugPrint('[VENDOR_APPROVAL] 🚀 Auto-routing to Vendor Dashboard...');
      debugPrint('[VENDOR_APPROVAL] 📍 Target Route: ${AppRoutes.vendorDashboard}');
      debugPrint('[VENDOR_APPROVAL] ⏰ Cancelling auto-check timer');

      _autoCheckTimer?.cancel();

      if (!mounted) return;

      Navigator.of(context).pushReplacementNamed(AppRoutes.vendorDashboard);

      debugPrint('[VENDOR_APPROVAL] ✅ Navigation complete');
      debugPrint(
        '╚════════════════════════════════════════════════════════════╝',
      );
      debugPrint('');
    } else if (currentStatus == 'rejected') {
      debugPrint('[VENDOR_APPROVAL] ========================================');
      debugPrint('[VENDOR_APPROVAL] ❌❌❌ REJECTED BY ADMIN ❌❌❌');
      debugPrint('[VENDOR_APPROVAL] ========================================');
      debugPrint('[VENDOR_APPROVAL] 🔴 Routing to landing page');
      debugPrint('[VENDOR_APPROVAL] ⏰ Cancelling auto-check timer');

      _autoCheckTimer?.cancel();

      if (!mounted) return;

      WzToast.show(
        context,
        message: 'Your application was rejected. Please contact support.',
        type: WzToastType.error,
      );

      Navigator.of(context).pushReplacementNamed(AppRoutes.landing);

      debugPrint('[VENDOR_APPROVAL] ✅ Navigation complete');
      debugPrint(
        '╚════════════════════════════════════════════════════════════╝',
      );
      debugPrint('');
    } else {
      debugPrint('[VENDOR_APPROVAL] ========================================');
      debugPrint('[VENDOR_APPROVAL] ⏳ Still pending approval...');
      debugPrint('[VENDOR_APPROVAL]   - Status: ${currentStatus ?? 'null'}');
      debugPrint('[VENDOR_APPROVAL]   - Next auto-check in 5 seconds');
      debugPrint('[VENDOR_APPROVAL] ========================================');

      if (!isAuto && mounted) {
        WzToast.show(
          context,
          message: 'Still pending approval. Please wait.',
          type: WzToastType.normal,
        );
      }

      debugPrint(
        '╚════════════════════════════════════════════════════════════╝',
      );
      debugPrint('');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWithBackground(
      appBar: AppBar(
        title: const Text('Vendor Approval Status'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: SafeArea(
        bottom: true,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withValues(alpha: 0.0),
                Colors.blue.withValues(alpha: 0.1),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                Stack(
                  alignment: Alignment.center,
                  children: [
                    SpinKitPulse(
                      color: Colors.blue.withValues(alpha: 0.4),
                      size: 200.0,
                    ),
                    SpinKitPulse(
                      color: Colors.blue.withValues(alpha: 0.2),
                      size: 250.0,
                    ),
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withValues(alpha: 0.2),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.store_rounded,
                        size: 60,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                const Text(
                  'Vendor Approval Pending',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Your vendor application is currently being reviewed by our administrative team.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),

                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.blue.withValues(alpha: 0.2),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildStatusRow(
                        Icons.check_circle_rounded,
                        'Application Received',
                        true,
                      ),
                      _buildDivider(),
                      _buildStatusRow(
                        Icons.payment_rounded,
                        'Payment Verified',
                        true,
                      ),
                      _buildDivider(),
                      _buildStatusRow(
                        Icons.admin_panel_settings_rounded,
                        'Final Admin Review',
                        false,
                        isCurrent: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'What happens next?',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 20,
                            color: Colors.blue,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Our team will review your application within 24-48 hours',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 20,
                            color: Colors.blue,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'You will receive an email notification once approved',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 20,
                            color: Colors.blue,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Once approved, you can access your vendor dashboard',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SpinKitThreeBounce(
                      color: Colors.blue,
                      size: 15.0,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Auto-checking status...',
                      style: TextStyle(
                        color: Colors.black54.withValues(alpha: 0.8),
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                CustomButton(
                  text: _isChecking ? 'Checking...' : 'Check Status Now',
                  isLoading: _isChecking,
                  onPressed: () => _checkStatus(isAuto: false),
                  color: Colors.blue,
                ),
                const SizedBox(height: 12),
                CustomButton(
                  text: 'Logout',
                  isOutlined: true,
                  onPressed: () async {
                    debugPrint('[VENDOR_APPROVAL] 🔵 Logout clicked');
                    _autoCheckTimer?.cancel();
                    await context.read<AuthProvider>().logout();
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusRow(
    IconData icon,
    String label,
    bool isCompleted, {
    bool isCurrent = false,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: isCompleted
              ? Colors.green
              : (isCurrent ? Colors.blue : Colors.grey.shade300),
          size: 24,
        ),
        const SizedBox(width: 16),
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: (isCompleted || isCurrent)
                ? FontWeight.w600
                : FontWeight.normal,
            color: (isCompleted || isCurrent)
                ? Colors.black87
                : Colors.grey.shade400,
          ),
        ),
        const Spacer(),
        if (isCompleted)
          const Icon(Icons.done, color: Colors.green, size: 20)
        else if (isCurrent)
          const SpinKitRing(color: Colors.blue, size: 20, lineWidth: 2),
      ],
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: Container(height: 20, width: 1, color: Colors.grey.shade200),
    );
  }
}
