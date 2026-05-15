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

class ProfileFamilyUI extends StatefulWidget {
  final bool isEditMode;

  const ProfileFamilyUI({super.key, this.isEditMode = false});

  @override
  State<ProfileFamilyUI> createState() => _ProfileFamilyUIState();
}

class _ProfileFamilyUIState extends State<ProfileFamilyUI> {
  final _formKey = GlobalKey<FormState>();
  final _brothersController = TextEditingController();
  final _sistersController = TextEditingController();

  String? _selectedFatherOccupation;
  String? _selectedMotherOccupation;
  String? _selectedAnnualIncome;

  List<String> get _occupationOptions => ProfileConstants.occupation;
  List<String> get _incomeOptions => ProfileConstants.incomeRanges;

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
      if (provider.formData['father_occupation'] != null) {
        final val = provider.formData['father_occupation'];
        if (_occupationOptions.contains(val)) {
          setState(() => _selectedFatherOccupation = val);
        }
      }
      if (provider.formData['mother_occupation'] != null) {
        final val = provider.formData['mother_occupation'];
        if (_occupationOptions.contains(val)) {
          setState(() => _selectedMotherOccupation = val);
        }
      }
      if (provider.formData['brothers'] != null) {
        _brothersController.text = provider.formData['brothers'].toString();
      }
      if (provider.formData['sisters'] != null) {
        _sistersController.text = provider.formData['sisters'].toString();
      }
      if (provider.formData['annual_income'] != null) {
        final val = provider.formData['annual_income'];
        if (_incomeOptions.contains(val)) {
          setState(() => _selectedAnnualIncome = val);
        }
      }
    });
  }

  @override
  void dispose() {
    _brothersController.dispose();
    _sistersController.dispose();
    super.dispose();
  }

  String _getTranslatedOccupation(String value, AppLocalizations? appLoc) {
    if (appLoc == null) return value;
    final key =
        'occupation_${value.toLowerCase().replaceAll('/', '_').replaceAll(' ', '_')}';
    return appLoc.translate(key);
  }

  String _getTranslatedIncome(String value, AppLocalizations? appLoc) {
    if (appLoc == null) return value;
    final key =
        'income_${value.toLowerCase().replaceAll(' - ', '_').replaceAll(' ', '_').replaceAll('+', '_plus')}';
    return appLoc.translate(key);
  }

  String _getTranslatedStatus(String value, AppLocalizations? appLoc) {
    if (appLoc == null) return value;
    final key = 'status_${value.toLowerCase().replaceAll(' ', '_')}';
    return appLoc.translate(key);
  }

  String _getTranslatedType(String value, AppLocalizations? appLoc) {
    if (appLoc == null) return value;
    final key = 'type_${value.toLowerCase().replaceAll('-', '_')}';
    return appLoc.translate(key);
  }

  String _getTranslatedValue(String value, AppLocalizations? appLoc) {
    if (appLoc == null) return value;
    final key = 'value_${value.toLowerCase()}';
    return appLoc.translate(key);
  }

  Future<void> _onNext() async {
    final appLoc = AppLocalizations.of(context);
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final provider = context.read<OnboardingProvider>();

      if (provider.formData['family_status'] == null ||
          provider.formData['family_type'] == null ||
          provider.formData['family_values'] == null) {
        WzToast.show(
          context,
          message:
              appLoc?.translate('select_all_family_details_error') ??
              'Please select all Family details options',
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
          AppRoutes.profileEducation,
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
                child: EditProfileProgressIndicator(currentSection: 'family'),
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

                          const SizedBox(height: 38.0),

                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              appLoc?.translate('family_details') ??
                                  'Family Details',
                              style: WzTextStyles.heading4.copyWith(
                                fontSize: 20.0,
                                fontWeight: FontWeight.w600,
                                color: WzColors.text,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),

                          const SizedBox(height: 30.0),

                          _buildLabel(
                            appLoc != null
                                ? '${appLoc.translate('father_occupation_label')}*'
                                : 'Father\'s Occupation/Status*',
                          ),
                          const SizedBox(height: 8.0),
                          DropdownButtonFormField<String>(
                            key: ValueKey(
                              'father_occupation_$_selectedFatherOccupation',
                            ),
                            value: _selectedFatherOccupation,
                            items: _occupationOptions.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  _getTranslatedOccupation(value, appLoc),
                                ),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                _selectedFatherOccupation = newValue;
                              });
                              provider.updateField(
                                'father_occupation',
                                newValue,
                              );
                            },
                            decoration: _inputDecoration(
                              hint: appLoc?.translate('select_option'),
                            ),
                            validator: (v) => v == null
                                ? (appLoc?.translate('required') ?? 'Required')
                                : null,
                            style: _inputTextStyle(),
                            icon: const Icon(
                              Icons.arrow_drop_down,
                              color: WzColors.text,
                            ),
                          ),

                          const SizedBox(height: 26.0),

                          _buildLabel(
                            appLoc != null
                                ? '${appLoc.translate('mother_occupation_label')}*'
                                : 'Mother\'s Occupation/Status*',
                          ),
                          const SizedBox(height: 8.0),
                          DropdownButtonFormField<String>(
                            key: ValueKey(
                              'mother_occupation_$_selectedMotherOccupation',
                            ),
                            value: _selectedMotherOccupation,
                            items: _occupationOptions.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  _getTranslatedOccupation(value, appLoc),
                                ),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                _selectedMotherOccupation = newValue;
                              });
                              provider.updateField(
                                'mother_occupation',
                                newValue,
                              );
                            },
                            decoration: _inputDecoration(
                              hint: appLoc?.translate('select_option'),
                            ),
                            validator: (v) => v == null
                                ? (appLoc?.translate('required') ?? 'Required')
                                : null,
                            style: _inputTextStyle(),
                            icon: const Icon(
                              Icons.arrow_drop_down,
                              color: WzColors.text,
                            ),
                          ),

                          const SizedBox(height: 30.0),

                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel(
                                      appLoc != null
                                          ? '${appLoc.translate('brothers_label')}*'
                                          : 'Brothers*',
                                    ),
                                    const SizedBox(height: 8.0),
                                    Container(
                                      decoration: _inputContainerDecoration(),
                                      child: TextFormField(
                                        controller: _brothersController,
                                        keyboardType: TextInputType.number,
                                        decoration: _inputDecoration(),
                                        validator: (v) => v?.isEmpty ?? true
                                            ? (appLoc?.translate('required') ??
                                                  'Required')
                                            : null,
                                        style: _inputTextStyle(),
                                        onChanged: (val) => provider
                                            .updateField('brothers', val),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel(
                                      appLoc != null
                                          ? '${appLoc.translate('sisters_label')}*'
                                          : 'Sisters*',
                                    ),
                                    const SizedBox(height: 8.0),
                                    Container(
                                      decoration: _inputContainerDecoration(),
                                      child: TextFormField(
                                        controller: _sistersController,
                                        keyboardType: TextInputType.number,
                                        decoration: _inputDecoration(),
                                        validator: (v) => v?.isEmpty ?? true
                                            ? (appLoc?.translate('required') ??
                                                  'Required')
                                            : null,
                                        style: _inputTextStyle(),
                                        onChanged: (val) => provider
                                            .updateField('sisters', val),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 22.0),

                          _buildLabel(
                            appLoc != null
                                ? '${appLoc.translate('family_status_label')}*'
                                : 'Family Status*',
                          ),
                          const SizedBox(height: 8.0),
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: ProfileConstants.familyStatus
                                .map(
                                  (status) => _FamilyChip(
                                    label: _getTranslatedStatus(status, appLoc),
                                    isSelected:
                                        provider.formData['family_status'] ==
                                        status,
                                    onTap: () => provider.updateField(
                                      'family_status',
                                      status,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),

                          const SizedBox(height: 30.0),

                          _buildLabel(
                            appLoc != null
                                ? '${appLoc.translate('family_type_label')}*'
                                : 'Family Type*',
                          ),
                          const SizedBox(height: 8.0),
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: ProfileConstants.familyType
                                .map(
                                  (type) => _FamilyChip(
                                    label: _getTranslatedType(type, appLoc),
                                    isSelected:
                                        provider.formData['family_type'] ==
                                        type,
                                    onTap: () => provider.updateField(
                                      'family_type',
                                      type,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),

                          const SizedBox(height: 30.0),

                          _buildLabel(
                            appLoc != null
                                ? '${appLoc.translate('family_values_label')}*'
                                : 'Family Values*',
                          ),
                          const SizedBox(height: 8.0),
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: ProfileConstants.familyValues
                                .map(
                                  (value) => _FamilyChip(
                                    label: _getTranslatedValue(value, appLoc),
                                    isSelected:
                                        provider.formData['family_values'] ==
                                        value,
                                    onTap: () => provider.updateField(
                                      'family_values',
                                      value,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),

                          const SizedBox(height: 30.0),

                          _buildLabel(
                            appLoc != null
                                ? '${appLoc.translate('family_income_label')}*'
                                : 'Family Annual Income*',
                          ),
                          const SizedBox(height: 8.0),
                          DropdownButtonFormField<String>(
                            key: ValueKey(
                              'annual_income_$_selectedAnnualIncome',
                            ),
                            value: _selectedAnnualIncome,
                            items: _incomeOptions.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  _getTranslatedIncome(value, appLoc),
                                ),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                _selectedAnnualIncome = newValue;
                              });
                              provider.updateField('annual_income', newValue);
                            },
                            decoration: _inputDecoration(
                              hint: appLoc?.translate('select_option'),
                            ),
                            validator: (v) => v == null
                                ? (appLoc?.translate('required') ?? 'Required')
                                : null,
                            style: _inputTextStyle(),
                            icon: const Icon(
                              Icons.arrow_drop_down,
                              color: WzColors.text,
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
                currentSection: 'family',
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

class _FamilyChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FamilyChip({
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
