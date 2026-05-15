import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weddingzon/core/theme/wz_colors.dart';
import 'package:weddingzon/core/theme/wz_text_styles.dart';
import 'package:weddingzon/core/theme/wz_button_styles.dart';
import 'package:weddingzon/core/routes/app_routes.dart';
import 'package:weddingzon/features/onboarding/providers/onboarding_provider.dart';
import 'package:weddingzon/core/localization/app_localizations.dart';
import 'package:weddingzon/core/constants/profile_constants.dart';
import 'package:weddingzon/features/auth/providers/auth_provider.dart';
import 'package:weddingzon/features/profile/widgets/edit_profile_navigation.dart';
import 'package:weddingzon/shared/widgets/wz_toast.dart';
import '../widgets/wz_buttons.dart';

class ProfileLifestyleScreenUI extends StatefulWidget {
  final bool isEditMode;

  const ProfileLifestyleScreenUI({super.key, this.isEditMode = false});

  @override
  State<ProfileLifestyleScreenUI> createState() =>
      _ProfileLifestyleScreenUIState();
}

class _ProfileLifestyleScreenUIState extends State<ProfileLifestyleScreenUI> {
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
    final provider = context.read<OnboardingProvider>();
    final appLoc = AppLocalizations.of(context);

    if (provider.formData['appearance'] == null ||
        provider.formData['living_status'] == null) {
      WzToast.show(
        context,
        message:
            appLoc?.translate('select_appearance_living_error') ??
            'Please select Appearance and Living Status',
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
        AppRoutes.profileHabits,
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
                  currentSection: 'lifestyle',
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
                        const SizedBox(height: 25.0),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            appLoc?.translate('lifestyle') ?? 'Lifestyle',
                            style: WzTextStyles.heading4.copyWith(
                              fontSize: 20.0,
                              fontWeight: FontWeight.w600,
                              color: WzColors.text,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        const SizedBox(height: 39.0),

                        _buildLabel(
                          appLoc != null
                              ? '${appLoc.translate('appearance_label')}*'
                              : 'Appearance*',
                        ),
                        const SizedBox(height: 8.0),

                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: ProfileConstants.appearance
                              .map(
                                (appearance) => _buildChip(
                                  label: appLoc != null
                                      ? appLoc.translate(
                                          'appearance_${appearance.toLowerCase()}',
                                        )
                                      : appearance,
                                  isSelected:
                                      provider.formData['appearance'] ==
                                      appearance,
                                  onTap: () => provider.updateField(
                                    'appearance',
                                    appearance,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                        if (provider.formData['appearance'] == null)
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

                        const SizedBox(height: 21.0),

                        _buildLabel(
                          appLoc != null
                              ? '${appLoc.translate('living_status_label')}*'
                              : 'Living Status*',
                        ),
                        const SizedBox(height: 8.0),

                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: ProfileConstants.livingStatus
                              .map(
                                (status) => _buildChip(
                                  label: appLoc != null
                                      ? appLoc.translate(
                                          'living_status_${status.toLowerCase().replaceAll(' ', '_')}',
                                        )
                                      : status,
                                  isSelected:
                                      provider.formData['living_status'] ==
                                      status,
                                  onTap: () => provider.updateField(
                                    'living_status',
                                    status,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                        if (provider.formData['living_status'] == null)
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

                        const SizedBox(height: 40.0),
                      ],
                    );
                  },
                ),
              ),
            ),
            if (widget.isEditMode)
              EditProfileNavigationButtons(
                currentSection: 'lifestyle',
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
}
