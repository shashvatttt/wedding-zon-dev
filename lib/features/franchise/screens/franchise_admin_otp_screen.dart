import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:weddingzon/core/routes/app_routes.dart';
import 'package:weddingzon/core/theme/wz_colors.dart';
import '../../../features/auth/providers/auth_provider.dart';

class FranchiseAdminOtpScreen extends StatefulWidget {
  final String phoneNumber;

  const FranchiseAdminOtpScreen({super.key, required this.phoneNumber});

  @override
  State<FranchiseAdminOtpScreen> createState() =>
      _FranchiseAdminOtpScreenState();
}

class _FranchiseAdminOtpScreenState extends State<FranchiseAdminOtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  bool _isResending = false;
  String? _errorMessage;
  int _resendTimer = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _resendTimer = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendTimer == 0) {
        t.cancel();
      } else {
        if (mounted) setState(() => _resendTimer--);
      }
    });
  }

  String get _otp =>
      _controllers.map((c) => c.text).join();

  Future<void> _verifyOtp() async {
    final otp = _otp;
    if (otp.length < 6) {
      setState(() => _errorMessage = 'Please enter the complete 6-digit OTP.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final auth = context.read<AuthProvider>();
    await auth.verifyOtp(widget.phoneNumber, otp, isSignup: false, autoRoute: false);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (auth.isAuthenticated) {
      final user = auth.currentUser;
      if (user?.role == 'franchise') {
        // Navigate to franchise dashboard
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.franchiseDashboard,
          (route) => false,
        );
      } else {
        // Authenticated but not franchise role — show error
        setState(() {
          _errorMessage =
              'Access denied. This portal is only for Franchise Admins.';
        });
        // Sign them out
        await auth.logout();
      }
    } else {
      setState(() {
        _errorMessage = auth.error ?? 'Invalid OTP. Please try again.';
      });
    }
  }

  Future<void> _resendOtp() async {
    if (_resendTimer > 0 || _isResending) return;

    setState(() {
      _isResending = true;
      _errorMessage = null;
    });

    final auth = context.read<AuthProvider>();
    final success = await auth.sendOtp(widget.phoneNumber);

    if (!mounted) return;
    setState(() => _isResending = false);

    if (success) {
      _startResendTimer();
      // Clear fields
      for (final c in _controllers) {
        c.clear();
      }
      _focusNodes.first.requestFocus();
    } else {
      setState(() {
        _errorMessage = auth.error ?? 'Failed to resend OTP.';
      });
    }
  }

  void _onOtpChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    // Auto-submit when all 6 digits entered
    if (_otp.length == 6) {
      _verifyOtp();
    }
    setState(() {});
  }

  String _formatPhone(String phone) {
    // Show last 4 digits clearly: +91 XXXXXX1234
    if (phone.length > 4) {
      final last4 = phone.substring(phone.length - 4);
      final prefix = phone.substring(0, phone.length - 4);
      final masked = prefix.replaceAll(RegExp(r'\d'), '•');
      return '$masked$last4';
    }
    return phone;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Top gradient header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 260,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFEF2F55), Color(0xFFFF6B8A)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(36),
                  bottomRight: Radius.circular(36),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Back button
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.arrow_back,
                              color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),

                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        'Verify OTP',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 13.5,
                            color: Colors.white.withOpacity(0.85),
                          ),
                          children: [
                            const TextSpan(text: 'OTP sent to '),
                            TextSpan(
                              text: _formatPhone(widget.phoneNumber),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Main card
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.07),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // OTP icon
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: WzColors.primary.withOpacity(0.08),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.lock_open_rounded,
                                  color: WzColors.primary,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(height: 20),

                              Text(
                                'Enter the 6-digit code',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 28),

                              // 6 OTP boxes
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: List.generate(6, (i) {
                                  return SizedBox(
                                    width: 44,
                                    height: 52,
                                    child: TextFormField(
                                      controller: _controllers[i],
                                      focusNode: _focusNodes[i],
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(1),
                                      ],
                                      textAlign: TextAlign.center,
                                      enabled: !_isLoading,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                      decoration: InputDecoration(
                                        counterText: '',
                                        filled: true,
                                        fillColor: _controllers[i]
                                                .text
                                                .isNotEmpty
                                            ? WzColors.primary.withOpacity(0.07)
                                            : const Color(0xFFF7F8FA),
                                        contentPadding: EdgeInsets.zero,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide.none,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                              color: _controllers[i]
                                                      .text
                                                      .isNotEmpty
                                                  ? WzColors.primary
                                                  : Colors.grey[200]!,
                                              width: 1.5),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                              color: WzColors.primary,
                                              width: 2),
                                        ),
                                      ),
                                      onChanged: (val) =>
                                          _onOtpChanged(val, i),
                                    ),
                                  );
                                }),
                              ),

                              // Error
                              if (_errorMessage != null) ...[
                                const SizedBox(height: 20),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.red[50],
                                    borderRadius: BorderRadius.circular(10),
                                    border:
                                        Border.all(color: Colors.red[200]!),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.error_outline,
                                          color: Colors.red[700], size: 18),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _errorMessage!,
                                          style: TextStyle(
                                            color: Colors.red[700],
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              const SizedBox(height: 28),

                              // Verify button
                              SizedBox(
                                width: double.infinity,
                                height: 54,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _verifyOtp,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: WzColors.primary,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : const Text(
                                          'Verify & Login',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Resend timer
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Didn't receive? ",
                                    style: TextStyle(
                                        color: Colors.grey[600], fontSize: 13),
                                  ),
                                  _resendTimer > 0
                                      ? Text(
                                          'Resend in ${_resendTimer}s',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        )
                                      : GestureDetector(
                                          onTap: _isResending
                                              ? null
                                              : _resendOtp,
                                          child: Text(
                                            _isResending
                                                ? 'Sending...'
                                                : 'Resend OTP',
                                            style: TextStyle(
                                              color: _isResending
                                                  ? Colors.grey
                                                  : WzColors.primary,
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
