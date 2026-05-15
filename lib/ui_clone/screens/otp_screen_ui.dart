import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weddingzon/core/theme/wz_colors.dart';
import 'package:weddingzon/core/theme/wz_spacing.dart';
import 'package:weddingzon/core/theme/wz_text_styles.dart';
import 'package:weddingzon/core/theme/wz_button_styles.dart';
import 'package:weddingzon/features/auth/providers/auth_provider.dart';
import 'package:weddingzon/core/localization/app_localizations.dart';
import 'package:weddingzon/shared/widgets/wz_toast.dart';

class OTPScreenUI extends StatefulWidget {
  final String phoneNumber;
  final bool isSignup;

  const OTPScreenUI({
    super.key,
    required this.phoneNumber,
    this.isSignup = false,
  });

  @override
  State<OTPScreenUI> createState() => _OTPScreenUIState();
}

class _OTPScreenUIState extends State<OTPScreenUI> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  int _resendTimer = 30;
  bool _canResend = false;
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();

    for (var controller in _otpControllers) {
      controller.addListener(_checkOtpComplete);
    }
  }

  void _checkOtpComplete() {
    setState(() {
      _isButtonEnabled = _otpControllers.every(
        (controller) => controller.text.isNotEmpty,
      );
    });
  }

  void _startResendTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() {
        if (_resendTimer > 0) {
          _resendTimer--;
        } else {
          _canResend = true;
        }
      });
      return _resendTimer > 0;
    });
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  String get _otp => _otpControllers.map((c) => c.text).join();

  String get _maskedPhone {
    if (widget.phoneNumber.length > 6) {
      return '${widget.phoneNumber.substring(0, 6)}xxxx${widget.phoneNumber.substring(widget.phoneNumber.length - 4)}';
    }
    return widget.phoneNumber;
  }

  Future<void> _verifyOtp() async {
    if (_otp.length != 6) {
      WzToast.show(
        context,
        message: AppLocalizations.of(context)!.translate('enter_otp_error'),
        type: WzToastType.error,
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    await auth.verifyOtp(widget.phoneNumber, _otp, isSignup: widget.isSignup);
  }

  Future<void> _resendOtp() async {
    if (!_canResend) return;

    setState(() {
      _resendTimer = 30;
      _canResend = false;
    });

    _startResendTimer();

    if (mounted) {
      WzToast.show(
        context,
        message: AppLocalizations.of(context)!.translate('otp_resent'),
        type: WzToastType.success,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: WzColors.white,
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, auth, child) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: WzSpacing.space16,
                                  vertical: WzSpacing.space16,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.arrow_back_ios),
                                      onPressed: () => Navigator.pop(context),
                                      color: Colors.black,
                                    ),

                                    ElevatedButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: Text(
                                              AppLocalizations.of(
                                                context,
                                              )!.translate(
                                                'didnt_receive_code',
                                              ),
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Check if given mobile number is correct',
                                                  style: WzTextStyles.body2
                                                      .copyWith(
                                                        fontSize: 14,
                                                        color: WzColors.text,
                                                      ),
                                                ),
                                                const SizedBox(height: 12),
                                                Text(
                                                  'Check if given mobile number has sufficient balance',
                                                  style: WzTextStyles.body2
                                                      .copyWith(
                                                        fontSize: 14,
                                                        color: WzColors.text,
                                                      ),
                                                ),
                                                const SizedBox(height: 12),
                                                Text(
                                                  'Check spam folder',
                                                  style: WzTextStyles.body2
                                                      .copyWith(
                                                        fontSize: 14,
                                                        color: WzColors.text,
                                                      ),
                                                ),
                                              ],
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: Text(
                                                  AppLocalizations.of(
                                                    context,
                                                  )!.translate('ok'),
                                                  style: const TextStyle(
                                                    color: WzColors.primary,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      style: WzButtonStyles.primaryButtonAuth(
                                        width: 80,
                                        height: 34,
                                      ),
                                      child: Text(
                                        'Help',
                                        style: WzTextStyles.caption.copyWith(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 24),

                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: WzSpacing.space24,
                                ),
                                child: Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.translate('otp_sent_title'),
                                  textAlign: TextAlign.center,
                                  style: WzTextStyles.heading3.copyWith(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                    color: WzColors.text,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 7),

                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: WzSpacing.space24,
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      AppLocalizations.of(
                                        context,
                                      )!.translate('otp_instruction'),
                                      textAlign: TextAlign.center,
                                      style: WzTextStyles.body2.copyWith(
                                        fontSize: 14,
                                        color: WzColors.muted,
                                      ),
                                    ),
                                    Text(
                                      _maskedPhone,
                                      textAlign: TextAlign.center,
                                      style: WzTextStyles.body2.copyWith(
                                        fontSize: 14,
                                        color: WzColors.muted,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 54),

                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: WzSpacing.space24,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: List.generate(
                                    6,
                                    (index) => Flexible(
                                      child: Container(
                                        constraints: const BoxConstraints(
                                          maxWidth: 50,
                                        ),
                                        margin: EdgeInsets.only(
                                          right: index < 5 ? 8 : 0,
                                        ),
                                        decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.25,
                                              ),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: AspectRatio(
                                          aspectRatio: 1,
                                          child: TextField(
                                            controller: _otpControllers[index],
                                            focusNode: _focusNodes[index],
                                            keyboardType: TextInputType.number,
                                            textAlign: TextAlign.center,
                                            maxLength: 1,
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            decoration: InputDecoration(
                                              counterText: '',
                                              isDense: true,
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 12,
                                                  ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: BorderSide(
                                                  color: Colors.grey[300]!,
                                                  width: 1,
                                                ),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: BorderSide(
                                                  color: Colors.grey[300]!,
                                                  width: 1,
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: const BorderSide(
                                                  color: Color(0xFFEF2F55),
                                                  width: 2,
                                                ),
                                              ),
                                              filled: true,
                                              fillColor: Colors.white,
                                            ),
                                            onChanged: (value) {
                                              if (value.isNotEmpty &&
                                                  index < 5) {
                                                _focusNodes[index + 1]
                                                    .requestFocus();
                                              } else if (value.isEmpty &&
                                                  index > 0) {
                                                _focusNodes[index - 1]
                                                    .requestFocus();
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 8),

                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: WzSpacing.space24,
                                ),
                                child: _canResend
                                    ? Center(
                                        child: ElevatedButton(
                                          onPressed: _resendOtp,
                                          style:
                                              WzButtonStyles.primaryButtonAuth(),
                                          child: Text(
                                            'Resend OTP',
                                            style: WzTextStyles.body2.copyWith(
                                              fontSize: 14,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      )
                                    : Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'Resend OTP in 00:${_resendTimer.toString().padLeft(2, '0')}',
                                          style: WzTextStyles.body2.copyWith(
                                            fontSize: 14,
                                            color: WzColors.text,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                              ),

                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(WzSpacing.space24),
                      child: Center(
                        child: ElevatedButton(
                          onPressed: (auth.isLoading || !_isButtonEnabled)
                              ? null
                              : _verifyOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isButtonEnabled
                                ? const Color(0xFFEF2F55)
                                : const Color(0xFF6B7280),
                            disabledBackgroundColor: const Color(0xFF6B7280),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 15,
                            ),
                          ),
                          child: auth.isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  widget.isSignup
                                      ? AppLocalizations.of(
                                          context,
                                        )!.translate('verify')
                                      : AppLocalizations.of(
                                          context,
                                        )!.translate('verify'),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
