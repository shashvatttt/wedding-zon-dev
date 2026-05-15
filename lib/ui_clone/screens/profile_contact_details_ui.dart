import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weddingzon/core/theme/wz_colors.dart';
import 'package:weddingzon/core/theme/wz_text_styles.dart';
import 'package:weddingzon/core/routes/app_routes.dart';
import 'package:weddingzon/features/onboarding/providers/onboarding_provider.dart';
import 'package:weddingzon/features/auth/providers/auth_provider.dart';
import 'package:weddingzon/core/localization/app_localizations.dart';
import 'package:weddingzon/core/utils/form_validators.dart';
import 'package:weddingzon/features/profile/widgets/edit_profile_navigation.dart';
import 'package:weddingzon/shared/widgets/wz_toast.dart';
import '../widgets/wz_buttons.dart';

class ProfileContactDetailsUI extends StatefulWidget {
  final bool isEditMode;

  const ProfileContactDetailsUI({super.key, this.isEditMode = false});

  @override
  State<ProfileContactDetailsUI> createState() =>
      _ProfileContactDetailsUIState();
}

class _ProfileContactDetailsUIState extends State<ProfileContactDetailsUI> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _alternatePhoneController = TextEditingController();
  final _convTimeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final isEditFlow = args?['isEditFlow'] ?? false;

      if (!widget.isEditMode && isEditFlow) {
        final authProvider = context.read<AuthProvider>();
        final currentUser = authProvider.currentUser;
        if (currentUser != null) {
          final provider = context.read<OnboardingProvider>();
          provider.prepopulateFromUser(currentUser);
        }
      }

      final provider = context.read<OnboardingProvider>();
      if (provider.formData['phone'] != null) {
        _phoneController.text = provider.formData['phone'];
      }
      if (provider.formData['email'] != null) {
        _emailController.text = provider.formData['email'];
      }
      if (provider.formData['alternate_mobile'] != null) {
        _alternatePhoneController.text = provider.formData['alternate_mobile'];
      }
      if (provider.formData['suitable_time_to_call'] != null) {
        _convTimeController.text = provider.formData['suitable_time_to_call'];
      }
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _alternatePhoneController.dispose();
    _convTimeController.dispose();
    super.dispose();
  }

  Future<void> _onNext() async {
    final appLoc = AppLocalizations.of(context);
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (widget.isEditMode) {
        final provider = context.read<OnboardingProvider>();
        final response = await provider.submitProfile();
        if (response.success && response.data != null && mounted) {
          context.read<AuthProvider>().updateUser(response.data!);
        } else if (mounted) {
          WzToast.show(
            context,
            message:
                response.message ??
                (appLoc?.translate('profile_update_failed') ??
                    'Failed to update profile'),
            type: WzToastType.error,
          );
        }
      } else {
        final args =
            ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        final isEditFlow = args?['isEditFlow'] ?? false;

        Navigator.pushNamed(
          context,
          AppRoutes.profileAbout,
          arguments: {'isEditFlow': isEditFlow},
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLoc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: WzColors.white,
      appBar: AppBar(
        backgroundColor: WzColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: widget.isEditMode
            ? const PreferredSize(
                preferredSize: Size.fromHeight(60),
                child: EditProfileProgressIndicator(currentSection: 'contact'),
              )
            : null,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Consumer<OnboardingProvider>(
                  builder: (context, provider, _) {
                    return Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16.0),

                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              widget.isEditMode
                                  ? (appLoc?.translate('edit_profile') ??
                                        'Edit Profile')
                                  : (appLoc?.translate('create_profile') ??
                                        'Create Profile'),
                              style: WzTextStyles.heading3.copyWith(
                                fontSize: 24.0,
                                fontWeight: FontWeight.w600,
                                color: WzColors.text,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),

                          const SizedBox(height: 34.0),

                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              appLoc?.translate('contact_details_title') ??
                                  'Contact Details',
                              style: WzTextStyles.heading4.copyWith(
                                fontSize: 20.0,
                                fontWeight: FontWeight.w600,
                                color: WzColors.text,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),

                          const SizedBox(height: 34.0),

                          _buildLabel(
                            appLoc?.translate('phone_verified_label') ??
                                'Phone Number(Verified)',
                          ),
                          const SizedBox(height: 8.0),
                          _buildReadOnlyTextField(_phoneController),

                          const SizedBox(height: 30.0),

                          _buildLabel(
                            appLoc?.translate('email_verified_label') ??
                                'Email(Verified)',
                          ),
                          const SizedBox(height: 8.0),
                          _buildReadOnlyTextField(_emailController),

                          const SizedBox(height: 30.0),

                          _buildLabel(
                            appLoc?.translate('alternate_mobile_label') ??
                                'Alternate Mobile Number',
                          ),
                          const SizedBox(height: 8.0),
                          Container(
                            decoration: _inputContainerDecoration(),
                            child: TextFormField(
                              controller: _alternatePhoneController,
                              keyboardType: TextInputType.phone,
                              inputFormatters: FormFormatters.phone(),
                              decoration: _inputDecoration(hint: '9876543210'),
                              style: _inputTextStyle(),
                              validator: (v) => FormValidators.validatePhone(
                                v,
                                required: false,
                              ),
                              onChanged: (val) =>
                                  provider.updateField('alternate_mobile', val),
                            ),
                          ),

                          const SizedBox(height: 30.0),

                          _buildLabel(
                            appLoc?.translate('suitable_time_label') ??
                                'Suitable Time To Call',
                          ),
                          const SizedBox(height: 8.0),
                          Container(
                            decoration: _inputContainerDecoration(),
                            child: TextFormField(
                              controller: _convTimeController,
                              decoration: _inputDecoration(
                                hint:
                                    appLoc?.translate('suitable_time_hint') ??
                                    'e.g. 6 PM - 9 PM',
                              ),
                              style: _inputTextStyle(),
                              onChanged: (val) => provider.updateField(
                                'suitable_time_to_call',
                                val,
                              ),
                            ),
                          ),

                          const SizedBox(height: 40.0),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            if (widget.isEditMode)
              EditProfileNavigationButtons(
                currentSection: 'contact',
                onSave: _onNext,
              ),
            if (!widget.isEditMode)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: WzPrimaryButton(
                  text: appLoc?.translate('next') ?? 'Next',
                  onPressed: _onNext,
                  width: double.infinity,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 14.0,
        fontWeight: FontWeight.w500,
        color: Color(0xCF4E4E4E),
      ),
    );
  }

  Widget _buildReadOnlyTextField(TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(6.0),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: TextField(
        controller: controller,
        readOnly: true,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 15.0,
            vertical: 12.0,
          ),
        ),
        style: _inputTextStyle().copyWith(color: const Color(0xFF6B7280)),
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      isDense: true,
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 15.0,
        vertical: 12.0,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6.0),
        borderSide: const BorderSide(color: WzColors.primarySoftBg),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6.0),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6.0),
        borderSide: const BorderSide(color: WzColors.primary),
      ),
      fillColor: WzColors.white,
      filled: true,
    );
  }

  BoxDecoration _inputContainerDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(6.0),
      boxShadow: [
        BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 4),
      ],
    );
  }

  TextStyle _inputTextStyle() {
    return const TextStyle(
      fontFamily: 'Inter',
      fontSize: 14.0,
      fontWeight: FontWeight.w500,
      color: WzColors.text,
    );
  }
}
