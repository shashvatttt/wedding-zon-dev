import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weddingzon/core/theme/wz_colors.dart';
import 'package:weddingzon/core/theme/wz_text_styles.dart';
import 'package:weddingzon/core/routes/app_routes.dart';
import 'package:weddingzon/features/onboarding/providers/onboarding_provider.dart';
import 'package:weddingzon/features/auth/providers/auth_provider.dart';
import 'package:weddingzon/core/localization/app_localizations.dart';
import 'package:weddingzon/features/profile/widgets/edit_profile_navigation.dart';
import 'package:weddingzon/core/mixins/form_validation_mixin.dart';
import 'package:weddingzon/shared/widgets/wz_toast.dart';
import '../widgets/wz_buttons.dart';

class ProfileAboutMeUI extends StatefulWidget {
  final bool isEditMode;

  const ProfileAboutMeUI({super.key, this.isEditMode = false});

  @override
  State<ProfileAboutMeUI> createState() => _ProfileAboutMeUIState();
}

class _ProfileAboutMeUIState extends State<ProfileAboutMeUI>
    with FormValidationMixin {
  final _formKey = GlobalKey<FormState>();
  final _bioController = TextEditingController();
  int _charCount = 0;

  @override
  GlobalKey<FormState> get formKey => _formKey;

  @override
  void initState() {
    super.initState();

    setupValidationListeners([_bioController]);

    _bioController.addListener(() {
      setState(() {
        _charCount = _bioController.text.length;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final isEditFlow = args?['isEditFlow'] ?? false;

      if (widget.isEditMode || isEditFlow) {
        final authProvider = context.read<AuthProvider>();
        final currentUser = authProvider.currentUser;
        if (currentUser != null) {
          final provider = context.read<OnboardingProvider>();
          provider.prepopulateFromUser(currentUser);
        }
      }

      final provider = context.read<OnboardingProvider>();
      if (provider.formData['about_me'] != null) {
        _bioController.text = provider.formData['about_me'];
      }

      validateForm();
    });
  }

  @override
  void dispose() {
    removeValidationListeners([_bioController]);
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _onNext() async {
    final appLoc = AppLocalizations.of(context);
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      context.read<OnboardingProvider>().updateField(
        'about_me',
        _bioController.text,
      );

      final provider = context.read<OnboardingProvider>();
      final response = await provider.submitProfile();

      if (response.success && response.data != null && mounted) {
        context.read<AuthProvider>().updateUser(response.data!);

        if (!widget.isEditMode) {
          Navigator.pushNamed(
            context,
            AppRoutes.profilePhotos,
            arguments: {'isOnboarding': true},
          );
        }
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
                child: EditProfileProgressIndicator(currentSection: 'about'),
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
                              appLoc?.translate('about_me_title') ?? 'About Me',
                              style: WzTextStyles.heading4.copyWith(
                                fontSize: 20.0,
                                fontWeight: FontWeight.w600,
                                color: WzColors.text,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),

                          const SizedBox(height: 30.0),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                appLoc?.translate('bio_description_label') ??
                                    'Bio/Description',
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF4E4E4E),
                                ),
                              ),
                              Text(
                                '$_charCount/50',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w500,
                                  color: _charCount >= 50
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8.0),

                          Container(
                            height: 120.0,
                            decoration: BoxDecoration(
                              color: WzColors.white,
                              border: Border.all(
                                color: const Color(0xFFE5E7EB),
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(6.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: TextFormField(
                              controller: _bioController,
                              maxLines: null,
                              expands: true,
                              textAlignVertical: TextAlignVertical.top,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.all(15.0),
                                hintText:
                                    appLoc?.translate('bio_hint') ??
                                    'Write about yourself...',
                                hintStyle: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14.0,
                                  color: Color(0xFF9CA3AF),
                                ),
                              ),
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14.0,
                                fontWeight: FontWeight.w500,
                                color: WzColors.text,
                              ),
                              validator: (value) {
                                if (value == null || value.trim().length < 50) {
                                  return appLoc?.translate(
                                        'bio_validation_error',
                                      ) ??
                                      'Please write at least 50 characters about yourself.';
                                }
                                return null;
                              },
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
                currentSection: 'about',
                onSave: isFormValid ? _onNext : null,
              ),
            if (!widget.isEditMode)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: WzPrimaryButton(
                  text: appLoc?.translate('next') ?? 'Next',
                  onPressed: isFormValid ? _onNext : null,
                  width: double.infinity,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
