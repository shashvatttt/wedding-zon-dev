import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weddingzon/core/theme/wz_colors.dart';
import 'package:weddingzon/core/theme/wz_text_styles.dart';
import 'package:weddingzon/core/theme/wz_button_styles.dart';
import 'package:weddingzon/core/routes/app_routes.dart';
import 'package:weddingzon/features/onboarding/providers/onboarding_provider.dart';
import 'package:weddingzon/features/auth/providers/auth_provider.dart';
import 'package:weddingzon/core/localization/app_localizations.dart';
import 'package:weddingzon/core/constants/profile_constants.dart';
import 'package:weddingzon/features/profile/widgets/edit_profile_navigation.dart';
import 'package:weddingzon/shared/widgets/wz_toast.dart';
import '../widgets/wz_buttons.dart';

class ProfileReligiousBackgroundScreenUI extends StatefulWidget {
  final bool isEditMode;

  const ProfileReligiousBackgroundScreenUI({
    super.key,
    this.isEditMode = false,
  });

  @override
  State<ProfileReligiousBackgroundScreenUI> createState() =>
      _ProfileReligiousBackgroundScreenUIState();
}

class _ProfileReligiousBackgroundScreenUIState
    extends State<ProfileReligiousBackgroundScreenUI> {
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
    });
  }

  Future<void> _onNext() async {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.read<OnboardingProvider>();
    if (provider.formData['religion'] == null ||
        provider.formData['community'] == null) {
      WzToast.show(
        context,
        message: l10n.selectReligionCommunityError,
        type: WzToastType.error,
      );
      return;
    }

    if (widget.isEditMode) {
      final response = await provider.submitProfile();
      if (response.success && response.data != null && mounted) {
        context.read<AuthProvider>().updateUser(response.data!);
      } else if (mounted) {
        WzToast.show(
          context,
          message: l10n.profileUpdatedSuccess,
          type: WzToastType.error,
        );
      }
    } else {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final isEditFlow = args?['isEditFlow'] ?? false;

      Navigator.pushNamed(
        context,
        AppRoutes.profileLifestyle,
        arguments: {'isEditFlow': isEditFlow},
      );
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
                child: EditProfileProgressIndicator(
                  currentSection: 'religious',
                ),
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
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16.0),

                        Center(
                          child: Text(
                            widget.isEditMode
                                ? (appLoc != null
                                      ? appLoc.translate('edit_profile')
                                      : 'Edit Profile')
                                : (appLoc != null
                                      ? appLoc.translate('create_profile')
                                      : 'Create Profile'),
                            style: WzTextStyles.heading3.copyWith(
                              fontSize: 24.0,
                              fontWeight: FontWeight.w600,
                              height: 22 / 24,
                              color: WzColors.text,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        const SizedBox(height: 26.0),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            appLoc?.translate('religious_background') ??
                                'Religious Background',
                            style: WzTextStyles.heading4.copyWith(
                              fontSize: 20.0,
                              fontWeight: FontWeight.w600,
                              height: 22 / 20,
                              color: WzColors.text,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        const SizedBox(height: 38.0),

                        _buildLabel(
                          appLoc != null
                              ? '${appLoc.translate('religion_label')}*'
                              : 'Religion*',
                        ),
                        const SizedBox(height: 8.0),

                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: ProfileConstants.religions
                              .map(
                                (religion) => _buildChip(
                                  label: appLoc != null
                                      ? appLoc.translate(
                                          'religion_${religion.toLowerCase()}',
                                        )
                                      : religion,
                                  isSelected:
                                      provider.formData['religion'] == religion,
                                  onTap: () => provider.updateField(
                                    'religion',
                                    religion,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                        if (provider.formData['religion'] == null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              appLoc?.translate('required') ?? 'Required',
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),

                        const SizedBox(height: 44.0),

                        _buildLabel(
                          appLoc != null
                              ? '${appLoc.translate('community_caste_label')}*'
                              : 'Community/Caste*',
                        ),
                        const SizedBox(height: 8.0),

                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: ProfileConstants.communityCategories
                              .map(
                                (community) => _buildChip(
                                  label: appLoc != null
                                      ? appLoc.translate(
                                          'community_${community.toLowerCase()}',
                                        )
                                      : community,
                                  isSelected:
                                      provider.formData['community'] ==
                                      community,
                                  onTap: () => provider.updateField(
                                    'community',
                                    community,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                        if (provider.formData['community'] == null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              appLoc?.translate('required') ?? 'Required',
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),

                        const SizedBox(height: 30.0),

                        _buildLabel(
                          appLoc?.translate('sub_community_label') ??
                              'Sub Community',
                        ),
                        const SizedBox(height: 8.0),
                        Container(
                          decoration: _inputContainerDecoration(),
                          child: TextFormField(
                            initialValue: provider.formData['sub_community'],
                            decoration: _inputDecoration(
                              hint: appLoc?.translate(
                                'enter_sub_community_hint',
                              ),
                            ),
                            style: _inputTextStyle(),
                            textCapitalization: TextCapitalization.words,
                            onChanged: (val) {
                              provider.updateField('sub_community', val);
                            },
                          ),
                        ),

                        const SizedBox(height: 30.0),

                        _buildLabel(
                          appLoc?.translate('manglik_label') ??
                              'Manglik Status',
                        ),
                        const SizedBox(height: 8.0),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: ProfileConstants.manglikStatus
                              .map(
                                (status) => _buildChip(
                                  label: appLoc != null
                                      ? appLoc.translate(
                                          'manglik_${status.toLowerCase().replaceAll(' ', '_')}',
                                        )
                                      : status,
                                  isSelected:
                                      provider.formData['manglik_status'] ==
                                      status,
                                  onTap: () => provider.updateField(
                                    'manglik_status',
                                    status,
                                  ),
                                ),
                              )
                              .toList(),
                        ),

                        const SizedBox(height: 44.0),

                        const SizedBox(height: 30.0),

                        _buildLabel(
                          appLoc?.translate('pob_label') ?? 'Place of Birth',
                        ),
                        const SizedBox(height: 8.0),
                        Container(
                          decoration: _inputContainerDecoration(),
                          child: TextFormField(
                            initialValue: provider.formData['place_of_birth'],
                            decoration: _inputDecoration(
                              hint: appLoc?.translate('enter_pob_hint'),
                            ),
                            style: _inputTextStyle(),
                            textCapitalization: TextCapitalization.words,
                            onChanged: (val) {
                              provider.updateField('place_of_birth', val);
                            },
                          ),
                        ),

                        const SizedBox(height: 44.0),
                      ],
                    );
                  },
                ),
              ),
            ),
            if (widget.isEditMode)
              EditProfileNavigationButtons(
                currentSection: 'religious',
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

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
        decoration: isSelected
            ? WzButtonStyles.chipSelected()
            : WzButtonStyles.chipUnselected(),
        child: Text(
          label,
          style: isSelected
              ? WzButtonStyles.chipTextSelected()
              : WzButtonStyles.chipTextUnselected(),
        ),
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
