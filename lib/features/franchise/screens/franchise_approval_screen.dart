import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/wz_colors.dart';
import '../../../shared/widgets/scaffold_with_background.dart';
import 'dart:async';
import '../../../shared/widgets/wz_toast.dart';

class FranchiseApprovalScreen extends StatefulWidget {
  const FranchiseApprovalScreen({super.key});

  @override
  State<FranchiseApprovalScreen> createState() =>
      _FranchiseApprovalScreenState();
}

class _FranchiseApprovalScreenState extends State<FranchiseApprovalScreen> {
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
      '║ [APPROVAL] 📋 APPROVAL SCREEN LOADED                       ║',
    );
    debugPrint(
      '╚════════════════════════════════════════════════════════════╝',
    );
    debugPrint('[APPROVAL] ⏰ Starting auto-check timer (every 5 seconds)');

    _autoCheckTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        _checkCount++;
        debugPrint('[APPROVAL] ⏰ Auto-check triggered (count: $_checkCount)');
        _checkStatus(isAuto: true);
      }
    });
  }

  @override
  void dispose() {
    debugPrint('[APPROVAL] 🔴 Disposing approval screen, cancelling timer');
    _autoCheckTimer?.cancel();
    super.dispose();
  }

  void _checkStatus({bool isAuto = false}) async {
    if (_isChecking) {
      debugPrint('[APPROVAL] ⚠️ Already checking status, skipping...');
      return;
    }

    debugPrint('');
    debugPrint(
      '╔════════════════════════════════════════════════════════════╗',
    );
    debugPrint(
      '║ [APPROVAL] 🔍 CHECK STATUS ${isAuto ? '(AUTO)' : '(MANUAL)'}                     ║',
    );
    debugPrint(
      '╚════════════════════════════════════════════════════════════╝',
    );

    setState(() => _isChecking = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    debugPrint('[APPROVAL] 🔄 Refreshing user data from backend...');
    await authProvider.refreshUser();

    if (!mounted) {
      debugPrint('[APPROVAL] ⚠️ Widget unmounted during status check');
      return;
    }

    final user = authProvider.currentUser;
    final userRole = user?.role;
    final isVendor = userRole == 'vendor';
    final currentStatus = isVendor ? user?.vendorStatus : user?.franchiseStatus;

    debugPrint('[APPROVAL] ========================================');
    debugPrint('[APPROVAL] 📊 Current User Status:');
    if (user != null) {
      debugPrint('[APPROVAL]   - ID: ${user.id}');
      debugPrint('[APPROVAL]   - Name: ${user.fullName}');
      debugPrint('[APPROVAL]   - Role: ${user.role}');
      if (isVendor) {
        debugPrint('[APPROVAL]   - vendor_status: ${user.vendorStatus}');
        debugPrint('[APPROVAL]   - vendor_details: ${user.vendorDetails}');
      } else {
        debugPrint('[APPROVAL]   - franchise_status: ${user.franchiseStatus}');
        debugPrint(
          '[APPROVAL]   - franchise_details: ${user.franchiseDetails}',
        );
      }
    } else {
      debugPrint('[APPROVAL]   - User is NULL');
    }
    debugPrint('[APPROVAL] ========================================');

    setState(() => _isChecking = false);

    if (currentStatus == 'active') {
      debugPrint('[APPROVAL] ========================================');
      debugPrint('[APPROVAL] ✅✅✅ APPROVED! STATUS IS ACTIVE! ✅✅✅');
      debugPrint('[APPROVAL] ========================================');
      debugPrint(
        '[APPROVAL] 🎉 Admin has approved the ${isVendor ? 'vendor' : 'franchise'}!',
      );
      debugPrint(
        '[APPROVAL] 🚀 Auto-routing to ${isVendor ? 'Vendor' : 'Franchise'} Dashboard...',
      );
      final targetRoute = isVendor
          ? AppRoutes.vendorDashboard
          : AppRoutes.franchiseDashboard;
      debugPrint('[APPROVAL] 📍 Target Route: $targetRoute');
      debugPrint('[APPROVAL] ⏰ Cancelling auto-check timer');

      _autoCheckTimer?.cancel();

      if (!mounted) return;

      Navigator.of(context).pushReplacementNamed(targetRoute);

      debugPrint('[APPROVAL] ✅ Navigation complete');
      debugPrint(
        '╚════════════════════════════════════════════════════════════╝',
      );
      debugPrint('');
    } else if (currentStatus == 'rejected') {
      debugPrint('[APPROVAL] ========================================');
      debugPrint('[APPROVAL] ❌❌❌ REJECTED BY ADMIN ❌❌❌');
      debugPrint('[APPROVAL] ========================================');
      debugPrint('[APPROVAL] 🔴 Routing to landing page');
      debugPrint('[APPROVAL] ⏰ Cancelling auto-check timer');

      _autoCheckTimer?.cancel();

      if (!mounted) return;

      WzToast.show(
        context,
        message: 'Your application was rejected. Please contact support.',
        type: WzToastType.error,
      );

      Navigator.of(context).pushReplacementNamed(AppRoutes.landing);

      debugPrint('[APPROVAL] ✅ Navigation complete');
      debugPrint(
        '╚════════════════════════════════════════════════════════════╝',
      );
      debugPrint('');
    } else {
      debugPrint('[APPROVAL] ========================================');
      debugPrint('[APPROVAL] ⏳ Still pending approval...');
      debugPrint('[APPROVAL]   - Status: ${currentStatus ?? 'null'}');
      debugPrint('[APPROVAL]   - Next auto-check in 5 seconds');
      debugPrint('[APPROVAL] ========================================');

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
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final isVendor = user?.role == 'vendor';

    return ScaffoldWithBackground(
      appBar: AppBar(
        title: const Text('Approval Status'),
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
                WzColors.franchiseSoftBg.withValues(alpha: 0.5),
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
                      color: WzColors.franchise.withValues(alpha: 0.4),
                      size: 200.0,
                    ),
                    SpinKitPulse(
                      color: WzColors.franchise.withValues(alpha: 0.2),
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
                            color: WzColors.franchise.withValues(alpha: 0.2),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.hourglass_empty_rounded,
                        size: 60,
                        color: WzColors.franchise,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                const Text(
                  'Approval Pending',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: WzColors.textDefault,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Your ${isVendor ? 'vendor' : 'franchise'} application is currently being reviewed by our administrative team.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: WzColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),

                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: WzColors.franchise.withValues(alpha: 0.2),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
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

                const Spacer(),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SpinKitThreeBounce(
                      color: WzColors.franchise,
                      size: 15.0,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Auto-checking status...',
                      style: TextStyle(
                        color: WzColors.textSecondary.withValues(alpha: 0.8),
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
                  color: WzColors.franchise,
                ),
                const SizedBox(height: 12),
                CustomButton(
                  text: 'Logout',
                  isOutlined: true,
                  onPressed: () async {
                    debugPrint('[APPROVAL] 🔵 Logout clicked');
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
              : (isCurrent ? WzColors.franchise : Colors.grey.shade300),
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
                ? WzColors.textDefault
                : Colors.grey.shade400,
          ),
        ),
        const Spacer(),
        if (isCompleted)
          const Icon(Icons.done, color: Colors.green, size: 20)
        else if (isCurrent)
          const SpinKitRing(color: WzColors.franchise, size: 20, lineWidth: 2),
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
