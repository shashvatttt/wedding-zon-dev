import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:weddingzon/core/routes/app_routes.dart';
import 'package:weddingzon/core/theme/wz_colors.dart';
import '../../../features/auth/providers/auth_provider.dart';

class FranchiseAdminPhoneScreen extends StatefulWidget {
  const FranchiseAdminPhoneScreen({super.key});

  @override
  State<FranchiseAdminPhoneScreen> createState() =>
      _FranchiseAdminPhoneScreenState();
}

class _FranchiseAdminPhoneScreenState
    extends State<FranchiseAdminPhoneScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String _normalizePhone(String phone) {
    // Strip spaces and dashes
    phone = phone.replaceAll(RegExp(r'[\s\-]'), '');
    // Add country code if not present
    if (phone.startsWith('0')) {
      phone = '+91${phone.substring(1)}';
    } else if (!phone.startsWith('+')) {
      phone = '+91$phone';
    }
    return phone;
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final rawPhone = _phoneController.text.trim();
    final phone = _normalizePhone(rawPhone);

    final auth = context.read<AuthProvider>();
    final success = await auth.sendOtp(phone);

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (success) {
      Navigator.pushNamed(
        context,
        AppRoutes.franchiseAdminOtp,
        arguments: phone,
      );
    } else {
      setState(() {
        _errorMessage = auth.error ?? 'Failed to send OTP. Please try again.';
      });
    }
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
                // Back button + header
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

                // Title area
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        'Franchise\nAdmin Portal',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter your registered mobile number to continue.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.85),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Form card
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Weddingzon branded card
                          Container(
                            padding: const EdgeInsets.all(24),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Icon badge
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: WzColors.primary.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    Icons.grid_view_rounded,
                                    color: WzColors.primary,
                                    size: 30,
                                  ),
                                ),
                                const SizedBox(height: 20),

                                const Text(
                                  'Mobile Number',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black54,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Phone input
                                TextFormField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'[\d\s\+\-]')),
                                    LengthLimitingTextInputFormatter(15),
                                  ],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                    letterSpacing: 1.5,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: '98765 43210',
                                    hintStyle: const TextStyle(
                                      color: Color(0xFFCBD5E0),
                                      fontWeight: FontWeight.normal,
                                      letterSpacing: 1,
                                    ),
                                    prefixIcon: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text('🇮🇳',
                                              style: TextStyle(fontSize: 20)),
                                          const SizedBox(width: 6),
                                          Text(
                                            '+91',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            width: 1,
                                            height: 24,
                                            color: Colors.grey[300],
                                          ),
                                        ],
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFFF7F8FA),
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 18, horizontal: 16),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide(
                                          color: Colors.grey[200]!, width: 1),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(
                                          color: WzColors.primary, width: 2),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(
                                          color: Colors.red, width: 1.5),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(
                                          color: Colors.red, width: 2),
                                    ),
                                  ),
                                  validator: (val) {
                                    if (val == null || val.trim().isEmpty) {
                                      return 'Please enter your mobile number';
                                    }
                                    final digits =
                                        val.replaceAll(RegExp(r'\D'), '');
                                    if (digits.length < 10) {
                                      return 'Enter a valid 10-digit mobile number';
                                    }
                                    return null;
                                  },
                                  onFieldSubmitted: (_) => _sendOtp(),
                                  enabled: !_isLoading,
                                ),

                                // Error message
                                if (_errorMessage != null) ...[
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.red[50],
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: Colors.red[200]!),
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

                                const SizedBox(height: 24),

                                // Send OTP button
                                SizedBox(
                                  width: double.infinity,
                                  height: 54,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _sendOtp,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: WzColors.primary,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(14),
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
                                            'Send OTP',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Info note
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F4FF),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: const Color(0xFFBFD0FF), width: 1),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.info_outline,
                                    color: Color(0xFF3B5BDB), size: 18),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'This portal is exclusively for authorised Weddingzon Franchise Admins. An OTP will be sent to your registered mobile number.',
                                    style: TextStyle(
                                      color: Colors.blue[900],
                                      fontSize: 12.5,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 40),
                        ],
                      ),
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
