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
import 'package:weddingzon/shared/widgets/wz_toast.dart';
import '../widgets/wz_buttons.dart';

class ProfileHabitsScreenUI extends StatefulWidget {
  final bool isEditMode;

  const ProfileHabitsScreenUI({super.key, this.isEditMode = false});

  @override
  State<ProfileHabitsScreenUI> createState() => _ProfileHabitsScreenUIState();
}

class _ProfileHabitsScreenUIState extends State<ProfileHabitsScreenUI> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final isEditFlow = args?['isEditFlow'] ?? false;

      if (!widget.isEditMode && isEditFlow) {
        final authProvider = context.read<AuthProvider>();
        final currentUser = authProvider.currentUser;
        if (currentUser != null) {
          context.read<OnboardingProvider>().prepopulateFromUser(currentUser);
        }
      }
    });
  }

  Future<void> _onNext() async {
    final provider = context.read<OnboardingProvider>();
    final appLoc = AppLocalizations.of(context);

    if (provider.formData['eating_habits'] == null ||
        provider.formData['smoking_habits'] == null ||
        provider.formData['drinking_habits'] == null) {
      WzToast.show(
        context,
        message:
            appLoc?.translate('select_all_habits_error') ??
            'Please select all habits',
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
        AppRoutes.profileProperty,
        arguments: {'isEditFlow': isEditFlow},
      );
    }
  }

  void _toggleHobby(String hobby) {
    final provider = context.read<OnboardingProvider>();
    List<String> hobbies = [];
    if (provider.formData['hobbies'] != null) {
      if (provider.formData['hobbies'] is List) {
        hobbies = List<String>.from(provider.formData['hobbies']);
      } else if (provider.formData['hobbies'] is String) {
        hobbies = [provider.formData['hobbies']];
      }
    }

    if (hobbies.contains(hobby)) {
      hobbies.remove(hobby);
    } else {
      hobbies.add(hobby);
    }
    provider.updateField('hobbies', hobbies);
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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Consumer<OnboardingProvider>(
            builder: (context, provider, _) {
              final currentHobbies =
                  provider.formData['hobbies'] as List? ?? [];

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
                      appLoc?.translate('habits') ?? 'Habits',
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
                        ? '${appLoc.translate('eating_label')}*'
                        : 'Eating*',
                  ),
                  const SizedBox(height: 8.0),

                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: ProfileConstants.eatingHabits
                        .map(
                          (habit) => _buildChip(
                            label: appLoc != null
                                ? appLoc.translate(
                                    'habit_${habit.toLowerCase().replaceAll('-', '_')}',
                                  )
                                : habit,
                            isSelected:
                                provider.formData['eating_habits'] == habit,
                            onTap: () =>
                                provider.updateField('eating_habits', habit),
                          ),
                        )
                        .toList(),
                  ),

                  const SizedBox(height: 13.0),

                  _buildLabel(
                    appLoc != null
                        ? '${appLoc.translate('smoking_label')}*'
                        : 'Smoking*',
                  ),
                  const SizedBox(height: 8.0),

                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: ProfileConstants.smokingHabits
                        .map(
                          (habit) => _buildChip(
                            label: appLoc != null
                                ? appLoc.translate(
                                    'habit_${habit.toLowerCase()}',
                                  )
                                : habit,
                            isSelected:
                                provider.formData['smoking_habits'] == habit,
                            onTap: () =>
                                provider.updateField('smoking_habits', habit),
                          ),
                        )
                        .toList(),
                  ),

                  const SizedBox(height: 13.0),

                  _buildLabel(
                    appLoc != null
                        ? '${appLoc.translate('drinking_label')}*'
                        : 'Drinking*',
                  ),
                  const SizedBox(height: 8.0),

                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: ProfileConstants.drinkingHabits
                        .map(
                          (habit) => _buildChip(
                            label: appLoc != null
                                ? appLoc.translate(
                                    'habit_${habit.toLowerCase()}',
                                  )
                                : habit,
                            isSelected:
                                provider.formData['drinking_habits'] == habit,
                            onTap: () =>
                                provider.updateField('drinking_habits', habit),
                          ),
                        )
                        .toList(),
                  ),

                  const SizedBox(height: 21.0),

                  _buildLabel(
                    appLoc != null
                        ? '${appLoc.translate('hobbies_label')} (${appLoc.translate('optional')})'
                        : 'Hobbies (Optional)',
                  ),
                  const SizedBox(height: 8.0),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: ProfileConstants.hobbies
                        .map(
                          (hobby) => _buildChip(
                            label: appLoc != null
                                ? appLoc.translate(
                                    'hobby_${hobby.toLowerCase()}',
                                  )
                                : hobby,
                            isSelected: currentHobbies.contains(hobby),
                            onTap: () => _toggleHobby(hobby),
                          ),
                        )
                        .toList(),
                  ),

                  const SizedBox(height: 40.0),

                  WzPrimaryButton(
                    text: widget.isEditMode
                        ? (appLoc?.translate('save') ?? 'Save')
                        : (appLoc?.translate('next') ?? 'Next'),
                    onPressed: _onNext,
                    width: double.infinity,
                  ),

                  const SizedBox(height: 40.0),
                ],
              );
            },
          ),
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
