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

class ProfileAdditionalDetailsUI extends StatefulWidget {
  final bool isEditMode;

  const ProfileAdditionalDetailsUI({super.key, this.isEditMode = false});

  @override
  State<ProfileAdditionalDetailsUI> createState() =>
      _ProfileAdditionalDetailsUIState();
}

class _ProfileAdditionalDetailsUIState
    extends State<ProfileAdditionalDetailsUI> {
  final _formKey = GlobalKey<FormState>();
  final _disabilityDescriptionController = TextEditingController();
  AppLocalizations get l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final isEditFlow = args?['isEditFlow'] ?? false;

      final provider = context.read<OnboardingProvider>();

      if (!widget.isEditMode && isEditFlow) {
        final authProvider = context.read<AuthProvider>();
        final currentUser = authProvider.currentUser;
        if (currentUser != null) {
          provider.prepopulateFromUser(currentUser);

          if (currentUser.disabilityDescription != null &&
              currentUser.disabilityDescription!.isNotEmpty) {
            _disabilityDescriptionController.text =
                currentUser.disabilityDescription!;
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _disabilityDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _onNext() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final provider = context.read<OnboardingProvider>();
      if (provider.formData['marital_status'] == null) {
        WzToast.show(
          context,
          message: l10n.selectMaritalStatusError,
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
            message: response.message ?? l10n.profileUpdateFailed,
            type: WzToastType.error,
          );
        }
      } else {
        final args =
            ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        final isEditFlow = args?['isEditFlow'] ?? false;

        Navigator.pushNamed(
          context,
          AppRoutes.profileLocation,
          arguments: {'isEditFlow': isEditFlow},
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  currentSection: 'additional',
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
                    if (provider.formData['disability_description'] != null &&
                        _disabilityDescriptionController.text !=
                            provider.formData['disability_description']) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _disabilityDescriptionController.text =
                            provider.formData['disability_description'];
                      });
                    }

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
                                  ? l10n.editProfile
                                  : l10n.createProfile,
                              style: WzTextStyles.heading3.copyWith(
                                fontSize: 24.0,
                                fontWeight: FontWeight.w600,
                                color: WzColors.text,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),

                          const SizedBox(height: 38.0),

                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              l10n.additionalDetailsTitle,
                              style: WzTextStyles.heading4.copyWith(
                                fontSize: 20.0,
                                fontWeight: FontWeight.w600,
                                color: WzColors.text,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),

                          const SizedBox(height: 30.0),

                          _buildLabel('${l10n.heightLabel}*'),
                          const SizedBox(height: 8.0),
                          _buildDropdownField(
                            hintText: l10n.selectHeightHint,
                            value: provider.formData['height'],
                            items: ProfileConstants.heights,
                            onChanged: (val) =>
                                provider.updateField('height', val),
                          ),

                          const SizedBox(height: 26.0),

                          _buildLabel('${l10n.maritalStatusLabel}*'),
                          const SizedBox(height: 8.0),

                          Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: ProfileConstants.maritalStatus.map((
                              status,
                            ) {
                              String label = status;
                              if (status == 'Never Married' ||
                                  status == 'Unmarried') {
                                label = l10n.maritalUnmarried;
                              } else if (status == 'Awaiting Divorce')
                                label = l10n.maritalAwaitingDivorce;
                              else if (status == 'Widowed' || status == 'Widow')
                                label = l10n.maritalWidow;
                              else if (status == 'Divorced')
                                label = l10n.maritalDivorced;
                              else if (status == 'Annulled')
                                label = l10n.maritalAnnulled;

                              return _StatusChip(
                                label: label,
                                isSelected:
                                    provider.formData['marital_status'] ==
                                    status,
                                onTap: () => provider.updateField(
                                  'marital_status',
                                  status,
                                ),
                              );
                            }).toList(),
                          ),
                          if (provider.formData['marital_status'] == null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                l10n.required,
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),

                          const SizedBox(height: 26.0),

                          _buildLabel('${l10n.motherTongueLabel}*'),
                          const SizedBox(height: 8.0),
                          _buildDropdownField(
                            hintText: l10n.selectMotherTongueHint,
                            value: provider.formData['mother_tongue'],
                            items: ProfileConstants.motherTongues,
                            onChanged: (val) =>
                                provider.updateField('mother_tongue', val),
                            labelBuilder: (item) {
                              if (item == 'Hindi')
                                return l10n.translate('tongue_hindi');
                              if (item == 'English')
                                return l10n.translate('tongue_english');
                              if (item == 'Punjabi')
                                return l10n.translate('tongue_punjabi');
                              if (item == 'Bengali')
                                return l10n.translate('tongue_bengali');
                              if (item == 'Gujarati')
                                return l10n.translate('tongue_gujarati');
                              if (item == 'Marathi')
                                return l10n.translate('tongue_marathi');
                              if (item == 'Tamil')
                                return l10n.translate('tongue_tamil');
                              if (item == 'Telugu')
                                return l10n.translate('tongue_telugu');
                              if (item == 'Kannada')
                                return l10n.translate('tongue_kannada');
                              if (item == 'Malayalam')
                                return l10n.translate('tongue_malayalam');
                              if (item == 'Odia')
                                return l10n.translate('tongue_odia');
                              if (item == 'Urdu')
                                return l10n.translate('tongue_urdu');
                              if (item == 'Assamese')
                                return l10n.translate('tongue_assamese');
                              if (item == 'Maithili')
                                return l10n.translate('tongue_maithili');
                              if (item == 'Sanskrit')
                                return l10n.translate('tongue_sanskrit');
                              if (item == 'Nepali')
                                return l10n.translate('tongue_nepali');
                              if (item == 'Other') return l10n.other;
                              return item;
                            },
                          ),

                          const SizedBox(height: 26.0),

                          _buildLabel('${l10n.disabilityLabel}*'),
                          const SizedBox(height: 8.0),
                          _buildDropdownField(
                            hintText: l10n.selectDisabilityHint,
                            value: provider.formData['disability'],
                            items: ['None', 'Physical', 'Mental', 'Other'],
                            onChanged: (val) {
                              provider.updateField('disability', val);

                              if (val == 'None') {
                                _disabilityDescriptionController.clear();
                                provider.updateField(
                                  'disability_description',
                                  null,
                                );
                              }
                            },
                            labelBuilder: (item) {
                              if (item == 'None') return l10n.disabilityNone;
                              if (item == 'Physical')
                                return l10n.disabilityPhysical;
                              if (item == 'Mental')
                                return l10n.disabilityMental;
                              if (item == 'Other') return l10n.other;
                              return item;
                            },
                          ),

                          if (provider.formData['disability'] != null &&
                              provider.formData['disability'] != 'None') ...[
                            const SizedBox(height: 26.0),
                            _buildLabel(
                              '${l10n.translate('disability_description')}*',
                            ),
                            const SizedBox(height: 8.0),
                            _buildTextField(
                              controller: _disabilityDescriptionController,
                              hintText: l10n.translate(
                                'describe_disability_hint',
                              ),
                              maxLines: 3,
                              onChanged: (val) => provider.updateField(
                                'disability_description',
                                val,
                              ),
                              validator: (val) {
                                if (provider.formData['disability'] != null &&
                                    provider.formData['disability'] != 'None' &&
                                    (val == null || val.trim().isEmpty)) {
                                  return l10n.translate(
                                    'disability_description_required',
                                  );
                                }
                                return null;
                              },
                            ),
                          ],

                          const SizedBox(height: 26.0),

                          _buildLabel('${l10n.bloodGroupLabel}*'),
                          const SizedBox(height: 8.0),
                          _buildDropdownField(
                            hintText: l10n.selectBloodGroupHint,
                            value: provider.formData['blood_group'],
                            items: ProfileConstants.bloodGroups,
                            onChanged: (val) =>
                                provider.updateField('blood_group', val),
                          ),

                          const SizedBox(height: 48.0),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

            if (widget.isEditMode)
              EditProfileNavigationButtons(
                currentSection: 'additional',
                onSave: _onNext,
              ),
            if (!widget.isEditMode)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Previous'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFEF2F55),
                          side: const BorderSide(color: Color(0xFFEF2F55)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final provider = context.read<OnboardingProvider>();
                          if (provider.formData['marital_status'] == null) {
                            WzToast.show(
                              context,
                              message: l10n.selectMaritalStatusError,
                              type: WzToastType.error,
                            );
                            return;
                          }
                          _onNext();
                        },
                        icon: const Icon(Icons.arrow_forward),
                        label: Text(l10n.next),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF2F55),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
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

  Widget _buildDropdownField({
    required String hintText,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    String Function(String)? labelBuilder,
  }) {
    final validValue = value != null && items.contains(value) ? value : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        color: WzColors.white,
        border: Border.all(color: const Color(0xFFFBC3CF), width: 1.0),
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<String>(
          key: ValueKey('${hintText}_$validValue'),
          value: validValue,
          isExpanded: true,
          hint: Text(
            hintText,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12.0,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
            ),
          ),
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF6B7280)),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                labelBuilder?.call(item) ?? item,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14.0,
                  color: WzColors.text,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          validator: (v) => v == null ? l10n.required : null,
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
    Function(String)? onChanged,
    String? Function(String?)? validator,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: WzColors.white,
        border: Border.all(color: const Color(0xFFFBC3CF), width: 1.0),
        borderRadius: BorderRadius.circular(6.0),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 4),
        ],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        onChanged: onChanged,
        validator: validator,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14.0,
          color: WzColors.text,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 12.0,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6B7280),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          isDense: true,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusChip({
    required this.label,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
