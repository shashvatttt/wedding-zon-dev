import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:weddingzon/core/theme/wz_colors.dart';
import 'package:weddingzon/core/theme/wz_spacing.dart';
import 'package:weddingzon/core/theme/wz_text_styles.dart';
import 'package:weddingzon/core/routes/app_routes.dart';
import 'package:weddingzon/features/auth/providers/auth_provider.dart';
import 'package:weddingzon/core/localization/app_localizations.dart';
import 'package:weddingzon/core/models/country_code.dart';
import 'package:weddingzon/shared/widgets/wz_toast.dart';

class MobileLoginScreenUI extends StatefulWidget {
  const MobileLoginScreenUI({super.key});

  @override
  State<MobileLoginScreenUI> createState() => _MobileLoginScreenUIState();
}

class _MobileLoginScreenUIState extends State<MobileLoginScreenUI> {
  final _phoneController = TextEditingController();
  String? _errorText;
  bool _isButtonEnabled = false;
  CountryCode _selectedCountry = CountryCode.defaultCountry;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  const Text(
                    'Select Country',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: CountryCode.countries.length,
                itemBuilder: (context, index) {
                  final country = CountryCode.countries[index];
                  return ListTile(
                    leading: Text(
                      country.flag,
                      style: const TextStyle(fontSize: 24),
                    ),
                    title: Text(country.name),
                    trailing: Text(
                      country.dialCode,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        _selectedCountry = country;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _validatePhoneNumber(String value) {
    setState(() {
      _isButtonEnabled = value.length == 10;
      if (value.isEmpty) {
        _errorText = null;
      } else if (value.length < 10) {
        _errorText = AppLocalizations.of(
          context,
        )!.translate('valid_mobile_number_error');
      } else {
        _errorText = null;
      }
    });
  }

  Future<void> _sendOtp() async {
    final phoneText = _phoneController.text.trim();

    if (phoneText.isEmpty) {
      setState(() {
        _errorText = AppLocalizations.of(
          context,
        )!.translate('valid_mobile_number_error');
      });
      return;
    }

    if (phoneText.length != 10) {
      setState(() {
        _errorText = AppLocalizations.of(
          context,
        )!.translate('valid_mobile_number_error');
      });
      WzToast.show(
        context,
        message: AppLocalizations.of(
          context,
        )!.translate('valid_mobile_number_error'),
        type: WzToastType.error,
      );
      return;
    }

    final phoneNumber = '${_selectedCountry.dialCode}$phoneText';
    final auth = context.read<AuthProvider>();
    final success = await auth.sendOtp(phoneNumber);
    if (!mounted) return;
    if (success) {
      Navigator.pushNamed(context, AppRoutes.loginOtp, arguments: phoneNumber);
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
                                padding: const EdgeInsets.all(
                                  WzSpacing.space16,
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.arrow_back_ios),
                                  onPressed: () => Navigator.pop(context),
                                  color: Colors.black,
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
                                  )!.translate('enter_mobile_number_title'),
                                  textAlign: TextAlign.center,
                                  style: WzTextStyles.heading3.copyWith(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                    height: 22 / 24,
                                    color: WzColors.text,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 7),

                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: WzSpacing.space24,
                                ),
                                child: RichText(
                                  text: TextSpan(
                                    style: WzTextStyles.body2.copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      height: 22 / 14,
                                      color: WzColors.muted,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: AppLocalizations.of(context)!
                                            .translate(
                                              'mobile_login_instruction_part1',
                                            ),
                                      ),
                                      TextSpan(
                                        text: AppLocalizations.of(context)!
                                            .translate(
                                              'mobile_login_instruction_create',
                                            ),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      TextSpan(
                                        text: AppLocalizations.of(context)!
                                            .translate(
                                              'mobile_login_instruction_or',
                                            ),
                                      ),
                                      TextSpan(
                                        text: AppLocalizations.of(context)!
                                            .translate(
                                              'mobile_login_instruction_find',
                                            ),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      TextSpan(
                                        text: AppLocalizations.of(context)!
                                            .translate(
                                              'mobile_login_instruction_part2',
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 48),

                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: WzSpacing.space24,
                                ),
                                child: Row(
                                  children: [
                                    GestureDetector(
                                      onTap: _showCountryPicker,
                                      child: Container(
                                        width: 100,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                            color: Colors.grey[300]!,
                                            width: 1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
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
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              _selectedCountry.dialCode,
                                              style: const TextStyle(
                                                fontFamily: 'Inter',
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: WzColors.muted,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              _selectedCountry.flag,
                                              style: const TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(width: 2),
                                            const Icon(
                                              Icons.keyboard_arrow_down,
                                              size: 16,
                                              color: WzColors.muted,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 12),

                                    Expanded(
                                      child: Container(
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                            color: _errorText != null
                                                ? WzColors.error
                                                : Colors.grey[300]!,
                                            width: 1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
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
                                        child: TextField(
                                          controller: _phoneController,
                                          keyboardType: TextInputType.number,
                                          maxLength: 10,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                            LengthLimitingTextInputFormatter(
                                              10,
                                            ),
                                          ],
                                          onChanged: _validatePhoneNumber,
                                          decoration: InputDecoration(
                                            hintText: AppLocalizations.of(
                                              context,
                                            )!.translate('mobile_number_hint'),
                                            hintStyle: const TextStyle(
                                              fontFamily: 'Inter',
                                              fontSize: 12.503,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xCF4E4E4E),
                                            ),
                                            border: InputBorder.none,
                                            counterText: '',
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 15,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              if (_errorText != null)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: WzSpacing.space24,
                                    right: WzSpacing.space24,
                                    top: 8,
                                  ),
                                  child: Text(
                                    _errorText!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: WzColors.error,
                                      fontWeight: FontWeight.w500,
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
                              : _sendOtp,
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
                                  AppLocalizations.of(
                                    context,
                                  )!.translate('continue_button'),
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
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
