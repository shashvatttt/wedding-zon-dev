import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weddingzon/core/theme/wz_colors.dart';
import 'package:weddingzon/core/localization/app_localizations.dart';
import 'package:weddingzon/core/theme/wz_text_styles.dart';
import 'package:weddingzon/core/theme/wz_button_styles.dart';
import 'package:weddingzon/core/routes/app_routes.dart';
import 'package:weddingzon/features/onboarding/providers/onboarding_provider.dart';
import 'package:weddingzon/features/auth/providers/auth_provider.dart';
import 'package:weddingzon/core/constants/profile_constants.dart';
import 'package:weddingzon/features/profile/widgets/edit_profile_navigation.dart';
import 'package:weddingzon/shared/widgets/wz_toast.dart';
import '../widgets/wz_buttons.dart';

class ProfileEducationUI extends StatefulWidget {
  final bool isEditMode;

  const ProfileEducationUI({super.key, this.isEditMode = false});

  @override
  State<ProfileEducationUI> createState() => _ProfileEducationUIState();
}

class _ProfileEducationUIState extends State<ProfileEducationUI> {
  final _formKey = GlobalKey<FormState>();

  final _collegeController = TextEditingController();

  String? _selectedEducation;
  String? _selectedOccupation;
  String? _selectedIncome;

  List<String> get _educationOptions => ProfileConstants.education;
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
      if (provider.formData['highest_education'] != null) {
        final val = provider.formData['highest_education'];
        if (_educationOptions.contains(val)) {
          setState(() => _selectedEducation = val);
        }
      }
      if (provider.formData['college_name'] != null) {
        _collegeController.text = provider.formData['college_name'];
      }
      if (provider.formData['occupation'] != null) {
        final val = provider.formData['occupation'];
        if (_occupationOptions.contains(val)) {
          setState(() => _selectedOccupation = val);
        }
      }
      if (provider.formData['personal_income'] != null) {
        final val = provider.formData['personal_income'];
        if (_incomeOptions.contains(val)) {
          setState(() => _selectedIncome = val);
        }
      }
    });
  }

  @override
  void dispose() {
    _collegeController.dispose();
    super.dispose();
  }

  String _getTranslatedEducation(String value, AppLocalizations? appLoc) {
    if (appLoc == null) return value;
    final key = 'education_${value.toLowerCase().replaceAll(' ', '_')}';
    return appLoc.translate(key);
  }

  String _getTranslatedOccupation(String value, AppLocalizations? appLoc) {
    if (appLoc == null) return value;
    final key =
        'occupation_${value.toLowerCase().replaceAll('/', '_').replaceAll(' ', '_')}';
    return appLoc.translate(key);
  }

  String _getTranslatedEmployment(String value, AppLocalizations? appLoc) {
    if (appLoc == null) return value;
    final key = 'employment_${value.toLowerCase().replaceAll(' ', '_')}';
    return appLoc.translate(key);
  }

  String _getTranslatedIncome(String value, AppLocalizations? appLoc) {
    if (appLoc == null) return value;
    final key =
        'income_${value.toLowerCase().replaceAll(' - ', '_').replaceAll(' ', '_').replaceAll('+', '_plus')}';
    return appLoc.translate(key);
  }

  Future<void> _onNext() async {
    final appLoc = AppLocalizations.of(context);
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final provider = context.read<OnboardingProvider>();
      if (provider.formData['employed_in'] == null) {
        WzToast.show(
          context,
          message:
              appLoc?.translate('select_employment_type_error') ??
              'Please select Employment Type',
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
          AppRoutes.profileReligious,
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
                child: EditProfileProgressIndicator(
                  currentSection: 'education',
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
                              appLoc?.translate('education_career_title') ??
                                  'Education & Career ',
                              style: WzTextStyles.heading4.copyWith(
                                fontSize: 20.0,
                                fontWeight: FontWeight.w600,
                                color: WzColors.text,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),

                          const SizedBox(height: 27.0),

                          _buildLabel(
                            appLoc != null
                                ? '${appLoc.translate('highest_education_label')}*'
                                : 'Highest Education & Specific Details*',
                          ),
                          const SizedBox(height: 8.0),
                          DropdownButtonFormField<String>(
                            key: ValueKey('education_$_selectedEducation'),
                            value: _selectedEducation,
                            items: _educationOptions.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  _getTranslatedEducation(value, appLoc),
                                ),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                _selectedEducation = newValue;
                              });
                              provider.updateField(
                                'highest_education',
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
                            appLoc?.translate('college_name_label') ??
                                'College Name',
                          ),
                          const SizedBox(height: 8.0),
                          Container(
                            decoration: _inputContainerDecoration(),
                            child: TextFormField(
                              controller: _collegeController,
                              decoration: _inputDecoration(
                                hint: appLoc?.translate(
                                  'enter_college_name_hint',
                                ),
                              ),
                              style: _inputTextStyle(),
                              textCapitalization: TextCapitalization.words,
                              onChanged: (val) {
                                provider.updateField('college_name', val);
                              },
                            ),
                          ),

                          const SizedBox(height: 26.0),

                          _buildLabel(
                            appLoc?.translate('edu_details_label') ??
                                'Education Details (Degree/Specialization)',
                          ),
                          const SizedBox(height: 8.0),
                          Container(
                            decoration: _inputContainerDecoration(),
                            child: TextFormField(
                              initialValue:
                                  provider.formData['education_details'],
                              decoration: _inputDecoration(
                                hint: appLoc?.translate(
                                  'enter_edu_details_hint',
                                ),
                              ),
                              style: _inputTextStyle(),
                              textCapitalization: TextCapitalization.words,
                              onChanged: (val) {
                                provider.updateField('education_details', val);
                              },
                            ),
                          ),

                          const SizedBox(height: 26.0),

                          _buildLabel(
                            appLoc != null
                                ? '${appLoc.translate('occupation_sector_label')}*'
                                : 'Occupation & Working Sector*',
                          ),
                          const SizedBox(height: 8.0),
                          DropdownButtonFormField<String>(
                            key: ValueKey('occupation_$_selectedOccupation'),
                            value: _selectedOccupation,
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
                                _selectedOccupation = newValue;
                              });
                              provider.updateField('occupation', newValue);
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

                          const SizedBox(height: 22.0),

                          _buildLabel(
                            appLoc != null
                                ? '${appLoc.translate('employed_in_label')}*'
                                : 'Employed In*',
                          ),
                          const SizedBox(height: 8.0),

                          Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: ProfileConstants.employedIn
                                .map(
                                  (type) => _EmploymentChip(
                                    label: _getTranslatedEmployment(
                                      type,
                                      appLoc,
                                    ),
                                    isSelected:
                                        provider.formData['employed_in'] ==
                                        type,
                                    onTap: () => provider.updateField(
                                      'employed_in',
                                      type,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                          if (provider.formData['employed_in'] == null)
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
                            appLoc != null
                                ? '${appLoc.translate('personal_income_label')}*'
                                : 'Personal Annual Income*',
                          ),
                          const SizedBox(height: 8.0),
                          DropdownButtonFormField<String>(
                            key: ValueKey('personal_income_$_selectedIncome'),
                            value: _selectedIncome,
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
                                _selectedIncome = newValue;
                              });
                              provider.updateField('personal_income', newValue);
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
                currentSection: 'education',
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

class _EmploymentChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _EmploymentChip({
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
