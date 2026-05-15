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
import 'package:weddingzon/core/utils/form_validators.dart';
import 'package:weddingzon/features/profile/widgets/edit_profile_navigation.dart';
import 'package:weddingzon/shared/widgets/wz_toast.dart';
import '../widgets/wz_buttons.dart';

class ProfileBasicDetailsUI extends StatefulWidget {
  final bool isEditMode;

  const ProfileBasicDetailsUI({super.key, this.isEditMode = false});

  @override
  State<ProfileBasicDetailsUI> createState() => _ProfileBasicDetailsUIState();
}

class _ProfileBasicDetailsUIState extends State<ProfileBasicDetailsUI> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _dobController = TextEditingController();
  final _aadhaarController = TextEditingController();
  String? _selectedRelationship;
  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  void _initializeData() async {
    final provider = context.read<OnboardingProvider>();
    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.currentUser;

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final isEditFlow = args?['isEditFlow'] ?? false;

    if (args != null) {
      if (args['role'] != null) provider.updateField('role', args['role']);
    }

    if (!widget.isEditMode && currentUser != null) {
      if (isEditFlow || currentUser.isProfileComplete == false) {
        provider.prepopulateFromUser(currentUser);
      }

      if (currentUser.phone != null) {
        provider.updateField('phone', currentUser.phone);
      }
      if (currentUser.email != null) {
        provider.updateField('email', currentUser.email);
      }
      if (currentUser.username != null) {
        provider.updateField('username', currentUser.username);
      }
    }

    if (provider.formData['first_name'] != null) {
      _firstNameController.text = provider.formData['first_name'];
    }
    if (provider.formData['last_name'] != null) {
      _lastNameController.text = provider.formData['last_name'];
    }
    if (provider.formData['dob'] != null) {
      _dobController.text = (provider.formData['dob'] as String).split('T')[0];
    }
    if (provider.formData['username'] != null) {
      _usernameController.text = provider.formData['username'];
    }
    if (provider.formData['aadhar_number'] != null) {
      _aadhaarController.text = provider.formData['aadhar_number'];
    }
    if (provider.formData['created_for'] != null) {
      _selectedRelationship = provider.formData['created_for'];
    }
    if (provider.formData['gender'] != null) {
      setState(() {
        _selectedGender = provider.formData['gender'];
      });
    } else if (currentUser?.gender != null) {
      setState(() {
        _selectedGender = currentUser!.gender;
      });
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _dobController.dispose();
    _aadhaarController.dispose();
    super.dispose();
  }

  String _getTranslatedRelationship(String value, AppLocalizations? appLoc) {
    if (appLoc == null) return value;
    final key = 'rel_${value.toLowerCase()}';
    return appLoc.translate(key);
  }

  String _getTranslatedGender(String value, AppLocalizations? appLoc) {
    if (appLoc == null) return value;
    final key = 'gender_${value.toLowerCase()}';
    return appLoc.translate(key);
  }

  Future<void> _selectDate(BuildContext context) async {
    final appLoc = AppLocalizations.of(context);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      helpText: appLoc?.translate('select_dob_help') ?? 'Select Date of Birth',
    );
    if (picked != null) {
      final isoDate = picked.toIso8601String();
      context.read<OnboardingProvider>().updateField('dob', isoDate);
      _dobController.text = isoDate.split('T')[0];
    }
  }

  Future<void> _onNext() async {
    final appLoc = AppLocalizations.of(context);
    if (_formKey.currentState!.validate()) {
      if (_selectedGender == null) {
        WzToast.show(
          context,
          message:
              appLoc?.translate('select_gender_error') ??
              'Please select Gender',
          type: WzToastType.error,
        );
        return;
      }
      if (_selectedRelationship == null) {
        WzToast.show(
          context,
          message:
              appLoc?.translate('select_profile_created_for_error') ??
              'Please select who this profile is created for',
          type: WzToastType.error,
        );
        return;
      }

      final provider = context.read<OnboardingProvider>();
      provider.updateField('first_name', _firstNameController.text);
      provider.updateField('last_name', _lastNameController.text);
      provider.updateField('aadhar_number', _aadhaarController.text);
      provider.updateField('created_for', _selectedRelationship);
      provider.updateField('gender', _selectedGender);

      if (widget.isEditMode) {
        final response = await provider.submitProfile();
        if (response.success && response.data != null && mounted) {
          context.read<AuthProvider>().updateUser(response.data!);
        } else if (mounted) {
          WzToast.show(
            context,
            message:
                appLoc?.translate('profile_update_failed') ??
                'Failed to update profile',
            type: WzToastType.error,
          );
        }
      } else {
        final args =
            ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        final isEditFlow = args?['isEditFlow'] ?? false;

        Navigator.pushNamed(
          context,
          AppRoutes.profileAdditionalDetails,
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
                child: EditProfileProgressIndicator(currentSection: 'basic'),
              )
            : null,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
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
                          appLoc?.translate('basic_details_title') ??
                              'Basic Details',
                          style: WzTextStyles.heading4.copyWith(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w600,
                            color: WzColors.text,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),

                      const SizedBox(height: 30.0),

                      const SizedBox(height: 30.0),

                      _buildLabel(
                        appLoc?.translate('username_label') ?? 'Username',
                      ),
                      const SizedBox(height: 8.0),
                      Container(
                        decoration: _inputContainerDecoration(),
                        child: TextFormField(
                          controller: _usernameController,
                          readOnly: true,
                          decoration: _inputDecoration().copyWith(
                            fillColor: Colors.grey[100],
                            filled: true,
                          ),
                          style: _inputTextStyle().copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ),

                      const SizedBox(height: 26.0),

                      _buildLabel(
                        appLoc?.translate('aadhaar_label') ?? 'Aadhaar Number',
                      ),
                      const SizedBox(height: 8.0),
                      Container(
                        decoration: _inputContainerDecoration(),
                        child: TextFormField(
                          controller: _aadhaarController,
                          keyboardType: TextInputType.number,
                          inputFormatters: FormFormatters.aadhaar(),
                          decoration: _inputDecoration().copyWith(
                            counterText: "",
                            hintText:
                                appLoc?.translate('aadhaar_hint') ??
                                "1234 5678 9012",
                          ),
                          validator: (v) => FormValidators.validateAadhaar(v),
                          style: _inputTextStyle(),
                        ),
                      ),

                      const SizedBox(height: 26.0),

                      _buildLabel(
                        '${appLoc?.translate('first_name_label') ?? 'First Name'}*',
                      ),
                      const SizedBox(height: 8.0),
                      Container(
                        decoration: _inputContainerDecoration(),
                        child: TextFormField(
                          controller: _firstNameController,
                          keyboardType: TextInputType.name,
                          textCapitalization: TextCapitalization.words,
                          inputFormatters: FormFormatters.name(),
                          decoration: _inputDecoration(),
                          validator: (v) => FormValidators.validateName(
                            v,
                            fieldName: 'First name',
                          ),
                          style: _inputTextStyle(),
                        ),
                      ),

                      const SizedBox(height: 26.0),

                      _buildLabel(
                        '${appLoc?.translate('last_name_label') ?? 'Last Name'}*',
                      ),
                      const SizedBox(height: 8.0),
                      Container(
                        decoration: _inputContainerDecoration(),
                        child: TextFormField(
                          controller: _lastNameController,
                          keyboardType: TextInputType.name,
                          textCapitalization: TextCapitalization.words,
                          inputFormatters: FormFormatters.name(),
                          decoration: _inputDecoration(),
                          validator: (v) => FormValidators.validateName(
                            v,
                            fieldName: 'Last name',
                          ),
                          style: _inputTextStyle(),
                        ),
                      ),

                      const SizedBox(height: 30.0),

                      _buildLabel(
                        '${appLoc?.translate('dob_label') ?? 'Date Of Birth'}*',
                      ),
                      const SizedBox(height: 8.0),
                      Container(
                        decoration: _inputContainerDecoration(),
                        child: GestureDetector(
                          onTap: () => _selectDate(context),
                          child: AbsorbPointer(
                            child: TextFormField(
                              controller: _dobController,
                              decoration: _inputDecoration().copyWith(
                                hintText:
                                    appLoc?.translate('dob_hint') ??
                                    'dd/mm/yyyy',
                                suffixIcon: const Icon(
                                  Icons.calendar_today,
                                  size: 16,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                              validator: (v) => v?.isEmpty ?? true
                                  ? (appLoc?.translate('required') ??
                                        'Required')
                                  : null,
                              style: _inputTextStyle(),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30.0),

                      _buildLabel(
                        '${appLoc?.translate('gender_label') ?? 'Gender'}*',
                      ),
                      const SizedBox(height: 8.0),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: ProfileConstants.genders
                            .map(
                              (label) => _RelationshipChip(
                                label: _getTranslatedGender(label, appLoc),
                                originalLabel: label,
                                isSelected: _selectedGender == label,
                                onTap: (original) {
                                  setState(() {
                                    _selectedGender = original;
                                  });
                                },
                              ),
                            )
                            .toList(),
                      ),

                      const SizedBox(height: 30.0),

                      _buildLabel(
                        '${appLoc?.translate('profile_created_for_label') ?? 'Profile is created for'}*',
                      ),
                      const SizedBox(height: 8.0),

                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: ProfileConstants.profileManagedBy
                            .map(
                              (label) => _RelationshipChip(
                                label: _getTranslatedRelationship(
                                  label,
                                  appLoc,
                                ),
                                originalLabel: label,
                                isSelected: _selectedRelationship == label,
                                onTap: (original) {
                                  setState(() {
                                    _selectedRelationship = original;
                                  });
                                },
                              ),
                            )
                            .toList(),
                      ),

                      const SizedBox(height: 48.0),
                    ],
                  ),
                ),
              ),
            ),
            if (widget.isEditMode)
              EditProfileNavigationButtons(
                currentSection: 'basic',
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

  InputDecoration _inputDecoration() {
    return InputDecoration(
      isDense: true,
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
        borderSide: const BorderSide(color: WzColors.primarySoftBg),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6.0),
        borderSide: const BorderSide(color: WzColors.primary),
      ),
      fillColor: WzColors.white,
      filled: true,

      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
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

class _RelationshipChip extends StatelessWidget {
  final String label;
  final String originalLabel;
  final bool isSelected;
  final Function(String) onTap;

  const _RelationshipChip({
    required this.label,
    required this.originalLabel,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(originalLabel),
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
