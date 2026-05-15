import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weddingzon/core/theme/wz_colors.dart';
import 'package:weddingzon/core/theme/wz_text_styles.dart';
import 'package:weddingzon/core/theme/wz_button_styles.dart';
import 'package:weddingzon/features/profile/providers/profile_provider.dart';
import 'package:weddingzon/features/profile/models/partner_preference.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/constants/profile_constants.dart';
import '../../shared/widgets/wz_toast.dart';
import '../widgets/wz_buttons.dart';

class PartnerPreferencesEditUI extends StatefulWidget {
  const PartnerPreferencesEditUI({super.key});

  @override
  State<PartnerPreferencesEditUI> createState() =>
      _PartnerPreferencesEditUIState();
}

class _PartnerPreferencesEditUIState extends State<PartnerPreferencesEditUI> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final TextEditingController _minAgeController = TextEditingController();
  final TextEditingController _maxAgeController = TextEditingController();
  final TextEditingController _occupationController = TextEditingController();
  final TextEditingController _annualIncomeController = TextEditingController();

  String? _minHeight;
  String? _maxHeight;
  String? _religion;
  String? _maritalStatus;
  String? _eatingHabits;
  String? _smokingHabits;
  String? _drinkingHabits;
  String? _highestEducation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPreferences();
    });
  }

  Future<void> _loadPreferences() async {
    final provider = context.read<ProfileProvider>();
    await provider.loadPreferences();

    if (mounted) {
      final prefs = provider.preferences;
      if (prefs != null) {
        _populateForm(prefs);
      }
    }
  }

  void _populateForm(PartnerPreference prefs) {
    if (prefs.minAge != null) {
      _minAgeController.text = prefs.minAge!.toString();
    }
    if (prefs.maxAge != null) {
      _maxAgeController.text = prefs.maxAge!.toString();
    }
    if (prefs.occupation != null) {
      _occupationController.text = prefs.occupation!;
    }
    if (prefs.annualIncome != null) {
      _annualIncomeController.text = prefs.annualIncome!.toString();
    }

    setState(() {
      _minHeight = (prefs.heightMin != null && prefs.heightMin!.isNotEmpty)
          ? prefs.heightMin
          : null;
      _maxHeight = (prefs.heightMax != null && prefs.heightMax!.isNotEmpty)
          ? prefs.heightMax
          : null;
      _religion = (prefs.religion != null && prefs.religion!.isNotEmpty)
          ? prefs.religion
          : null;
      _maritalStatus = prefs.maritalStatus?.firstOrNull;
      _eatingHabits =
          (prefs.eatingHabits != null && prefs.eatingHabits!.isNotEmpty)
          ? prefs.eatingHabits
          : null;
      _smokingHabits =
          (prefs.smokingHabits != null && prefs.smokingHabits!.isNotEmpty)
          ? prefs.smokingHabits
          : null;
      _drinkingHabits =
          (prefs.drinkingHabits != null && prefs.drinkingHabits!.isNotEmpty)
          ? prefs.drinkingHabits
          : null;
      _highestEducation =
          (prefs.highestEducation != null && prefs.highestEducation!.isNotEmpty)
          ? prefs.highestEducation
          : null;
    });
  }

  @override
  void dispose() {
    _minAgeController.dispose();
    _maxAgeController.dispose();
    _occupationController.dispose();
    _annualIncomeController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    debugPrint('[PREFS_EDIT] 🔵 Collecting form data...');
    debugPrint('[PREFS_EDIT] Min Age: ${_minAgeController.text}');
    debugPrint('[PREFS_EDIT] Max Age: ${_maxAgeController.text}');
    debugPrint('[PREFS_EDIT] Min Height: $_minHeight');
    debugPrint('[PREFS_EDIT] Max Height: $_maxHeight');
    debugPrint('[PREFS_EDIT] Religion: $_religion');
    debugPrint('[PREFS_EDIT] Marital Status: $_maritalStatus');
    debugPrint('[PREFS_EDIT] Occupation: ${_occupationController.text}');
    debugPrint('[PREFS_EDIT] Annual Income: ${_annualIncomeController.text}');

    final prefs = PartnerPreference(
      minAge: int.tryParse(_minAgeController.text.trim()),
      maxAge: int.tryParse(_maxAgeController.text.trim()),
      heightMin: _minHeight,
      heightMax: _maxHeight,
      religion: _religion,
      maritalStatus: _maritalStatus != null ? [_maritalStatus!] : null,
      eatingHabits: _eatingHabits,
      smokingHabits: _smokingHabits,
      drinkingHabits: _drinkingHabits,
      highestEducation: _highestEducation,
      occupation: _occupationController.text.trim().isNotEmpty
          ? _occupationController.text.trim()
          : null,
      annualIncome: _annualIncomeController.text.trim().isNotEmpty
          ? _annualIncomeController.text.trim()
          : null,
    );

    final prefsJson = prefs.toJson();
    debugPrint('[PREFS_EDIT] 📤 Preferences JSON: $prefsJson');
    debugPrint('[PREFS_EDIT] 📊 JSON keys: ${prefsJson.keys.toList()}');
    debugPrint('[PREFS_EDIT] 📊 JSON length: ${prefsJson.length}');

    final provider = context.read<ProfileProvider>();
    final success = await provider.updatePreferences(prefsJson);

    if (!mounted) return;

    setState(() => _isLoading = false);
    if (success) {
      if (!mounted) return;
      Navigator.pop(context);
      WzToast.show(
        context,
        message: AppLocalizations.of(
          context,
        )!.translate('preferences_updated_msg'),
        type: WzToastType.success,
      );
    } else {
      if (!mounted) return;
      WzToast.show(
        context,
        message: AppLocalizations.of(
          context,
        )!.translate('preferences_update_failed_msg'),
        type: WzToastType.error,
      );
    }
  }

  Future<void> _onClear() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppLocalizations.of(context)!.translate('clear_preferences_title'),
        ),
        content: Text(
          AppLocalizations.of(context)!.translate('clear_preferences_confirm'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.translate('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(AppLocalizations.of(context)!.translate('clear')),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    debugPrint('[PREFS_EDIT] 🔵 Clearing preferences...');
    setState(() => _isLoading = true);

    final provider = context.read<ProfileProvider>();
    final success = await provider.clearPreferences();

    debugPrint('[PREFS_EDIT] Clear result: $success');

    if (!mounted) return;

    setState(() => _isLoading = false);
    if (success) {
      _minAgeController.clear();
      _maxAgeController.clear();
      _occupationController.clear();
      _annualIncomeController.clear();
      setState(() {
        _minHeight = null;
        _maxHeight = null;
        _religion = null;
        _maritalStatus = null;
        _eatingHabits = null;
        _smokingHabits = null;
        _drinkingHabits = null;
        _highestEducation = null;
      });

      if (!mounted) return;
      WzToast.show(
        context,
        message: AppLocalizations.of(
          context,
        )!.translate('preferences_cleared_msg'),
        type: WzToastType.success,
      );
    } else {
      if (!mounted) return;
      WzToast.show(
        context,
        message: AppLocalizations.of(
          context,
        )!.translate('preferences_clear_failed_msg'),
        type: WzToastType.error,
      );
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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16.0),

                Center(
                  child: Text(
                    AppLocalizations.of(
                      context,
                    )!.translate('partner_preferences_title'),
                    style: WzTextStyles.heading3.copyWith(
                      fontSize: 24.0,
                      fontWeight: FontWeight.w600,
                      color: WzColors.text,
                    ),
                  ),
                ),

                const SizedBox(height: 38.0),

                Center(
                  child: Text(
                    AppLocalizations.of(
                      context,
                    )!.translate('set_preferences_title'),
                    style: WzTextStyles.heading4.copyWith(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w600,
                      color: WzColors.text,
                    ),
                  ),
                ),

                const SizedBox(height: 30.0),

                _buildLabel(
                  AppLocalizations.of(context)!.translate('age_range'),
                ),
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: _inputContainerDecoration(),
                        child: TextFormField(
                          controller: _minAgeController,
                          decoration: _inputDecoration().copyWith(
                            hintText: AppLocalizations.of(
                              context,
                            )!.translate('min_age_hint'),
                          ),
                          keyboardType: TextInputType.number,
                          style: _inputTextStyle(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Container(
                        decoration: _inputContainerDecoration(),
                        child: TextFormField(
                          controller: _maxAgeController,
                          decoration: _inputDecoration().copyWith(
                            hintText: AppLocalizations.of(
                              context,
                            )!.translate('max_age_hint'),
                          ),
                          keyboardType: TextInputType.number,
                          style: _inputTextStyle(),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 26.0),

                _buildLabel(
                  AppLocalizations.of(context)!.translate('height_range'),
                ),
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdownField(
                        hintText: AppLocalizations.of(
                          context,
                        )!.translate('min_height_hint'),
                        value: _minHeight,
                        items: ProfileConstants.heights,
                        onChanged: (val) => setState(() => _minHeight = val),
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: _buildDropdownField(
                        hintText: AppLocalizations.of(
                          context,
                        )!.translate('max_height_hint'),
                        value: _maxHeight,
                        items: ProfileConstants.heights,
                        onChanged: (val) => setState(() => _maxHeight = val),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 26.0),

                _buildLabel(
                  AppLocalizations.of(context)!.translate('religion_label'),
                ),
                const SizedBox(height: 8.0),
                _buildDropdownField(
                  hintText: AppLocalizations.of(
                    context,
                  )!.translate('select_religion_hint'),
                  value: _religion,
                  items: ProfileConstants.religions,
                  onChanged: (val) => setState(() => _religion = val),
                  itemLabelBuilder: (val) => _getLocalizedValue(context, val),
                ),

                const SizedBox(height: 26.0),

                _buildLabel(
                  AppLocalizations.of(
                    context,
                  )!.translate('marital_status_label'),
                ),
                const SizedBox(height: 8.0),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: ProfileConstants.maritalStatus
                      .map(
                        (status) => _StatusChip(
                          label: _getLocalizedValue(context, status),
                          isSelected: _maritalStatus == status,
                          onTap: () => setState(() => _maritalStatus = status),
                        ),
                      )
                      .toList(),
                ),

                const SizedBox(height: 26.0),

                _buildLabel(
                  AppLocalizations.of(
                    context,
                  )!.translate('eating_habits_label'),
                ),
                const SizedBox(height: 8.0),
                _buildDropdownField(
                  hintText: AppLocalizations.of(
                    context,
                  )!.translate('select_eating_habits_hint'),
                  value: _eatingHabits,
                  items: ProfileConstants.eatingHabits,
                  onChanged: (val) => setState(() => _eatingHabits = val),
                  itemLabelBuilder: (val) => _getLocalizedValue(context, val),
                ),

                const SizedBox(height: 26.0),

                _buildLabel(
                  AppLocalizations.of(
                    context,
                  )!.translate('smoking_habits_label'),
                ),
                const SizedBox(height: 8.0),
                _buildDropdownField(
                  hintText: AppLocalizations.of(
                    context,
                  )!.translate('select_smoking_habits_hint'),
                  value: _smokingHabits,
                  items: ProfileConstants.smokingHabits,
                  onChanged: (val) => setState(() => _smokingHabits = val),
                  itemLabelBuilder: (val) => _getLocalizedValue(context, val),
                ),

                const SizedBox(height: 26.0),

                _buildLabel(
                  AppLocalizations.of(
                    context,
                  )!.translate('drinking_habits_label'),
                ),
                const SizedBox(height: 8.0),
                _buildDropdownField(
                  hintText: AppLocalizations.of(
                    context,
                  )!.translate('select_drinking_habits_hint'),
                  value: _drinkingHabits,
                  items: ProfileConstants.drinkingHabits,
                  onChanged: (val) => setState(() => _drinkingHabits = val),
                  itemLabelBuilder: (val) => _getLocalizedValue(context, val),
                ),

                const SizedBox(height: 26.0),

                _buildLabel(
                  AppLocalizations.of(
                    context,
                  )!.translate('highest_education_label'),
                ),
                const SizedBox(height: 8.0),
                _buildDropdownField(
                  hintText: AppLocalizations.of(
                    context,
                  )!.translate('select_education_hint'),
                  value: _highestEducation,
                  items: ProfileConstants.education,
                  onChanged: (val) => setState(() => _highestEducation = val),
                  itemLabelBuilder: (val) => _getLocalizedValue(context, val),
                ),

                const SizedBox(height: 26.0),

                _buildLabel(
                  AppLocalizations.of(context)!.translate('occupation_label'),
                ),
                const SizedBox(height: 8.0),
                Container(
                  decoration: _inputContainerDecoration(),
                  child: TextFormField(
                    controller: _occupationController,
                    decoration: _inputDecoration().copyWith(
                      hintText: AppLocalizations.of(
                        context,
                      )!.translate('occupation_hint'),
                    ),
                    style: _inputTextStyle(),
                  ),
                ),

                const SizedBox(height: 26.0),

                _buildLabel(
                  AppLocalizations.of(
                    context,
                  )!.translate('min_annual_income_label'),
                ),
                const SizedBox(height: 8.0),
                Container(
                  decoration: _inputContainerDecoration(),
                  child: TextFormField(
                    controller: _annualIncomeController,
                    decoration: _inputDecoration().copyWith(
                      hintText: AppLocalizations.of(
                        context,
                      )!.translate('income_hint'),
                    ),
                    keyboardType: TextInputType.number,
                    style: _inputTextStyle(),
                  ),
                ),

                const SizedBox(height: 48.0),

                WzPrimaryButton(
                  text: AppLocalizations.of(
                    context,
                  )!.translate('save_preferences_btn'),
                  onPressed: _isLoading ? null : _onSave,
                  isLoading: _isLoading,
                  width: double.infinity,
                ),

                const SizedBox(height: 16.0),

                WzSecondaryButton(
                  text: AppLocalizations.of(
                    context,
                  )!.translate('clear_preferences_btn'),
                  onPressed: _isLoading ? null : _onClear,
                  isLoading: false,
                  width: double.infinity,
                ),

                const SizedBox(height: 40.0),
              ],
            ),
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
      hintStyle: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 12.0,
        fontWeight: FontWeight.w500,
        color: Color(0xFF6B7280),
      ),
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

  Widget _buildDropdownField({
    required String hintText,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    String Function(String)? itemLabelBuilder,
  }) {
    final validValue =
        value != null && value.isNotEmpty && items.contains(value)
        ? value
        : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        color: WzColors.white,
        border: Border.all(color: const Color(0xFFFBC3CF), width: 1.0),
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
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
                itemLabelBuilder != null ? itemLabelBuilder(item) : item,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14.0,
                  color: WzColors.text,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  String _getLocalizedValue(BuildContext context, String value) {
    final localizations = AppLocalizations.of(context)!;
    switch (value) {
      case 'Hindu':
        return localizations.translate('religion_hindu');
      case 'Muslim':
        return localizations.translate('religion_muslim');
      case 'Christian':
        return localizations.translate('religion_christian');
      case 'Sikh':
        return localizations.translate('religion_sikh');
      case 'Buddhist':
        return localizations.translate('religion_buddhist');
      case 'Jain':
        return localizations.translate('religion_jain');
      case 'Other':
        return localizations.translate('religion_other');

      case 'Never Married':
        return localizations.translate('marital_never_married');
      case 'Divorced':
        return localizations.translate('marital_divorced');
      case 'Widowed':
        return localizations.translate('marital_widowed');
      case 'Awaiting Divorce':
        return localizations.translate('marital_awaiting_divorce');

      case 'Vegetarian':
        return localizations.translate('diet_vegetarian');
      case 'Non-Vegetarian':
        return localizations.translate('diet_non_vegetarian');
      case 'Eggetarian':
        return localizations.translate('diet_eggetarian');
      case 'Vegan':
        return localizations.translate('diet_vegan');

      case 'No':
        return localizations.translate('habit_no');
      case 'Yes':
        return localizations.translate('habit_yes');
      case 'Occasionally':
        return localizations.translate('habit_occasionally');
      case 'Socially':
        return localizations.translate('habit_socially');

      case 'High School':
        return localizations.translate('edu_high_school');
      case 'Diploma':
        return localizations.translate('edu_diploma');
      case "Bachelor's Degree":
        return localizations.translate('edu_bachelors');
      case "Master's Degree":
        return localizations.translate('edu_masters');
      case 'PhD':
        return localizations.translate('edu_phd');
      case 'Professional Degree':
        return localizations.translate('edu_professional');

      default:
        return value;
    }
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
