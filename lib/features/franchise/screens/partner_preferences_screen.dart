import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/wz_colors.dart';
import '../../../core/theme/wz_button_styles.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../ui_clone/widgets/wz_buttons.dart';
import '../../../shared/widgets/wz_loading.dart';
import '../models/partner_preference.dart';
import '../providers/franchise_provider.dart';
import '../../../shared/widgets/wz_toast.dart';

class PartnerPreferencesScreen extends StatefulWidget {
  const PartnerPreferencesScreen({super.key});

  @override
  State<PartnerPreferencesScreen> createState() =>
      _PartnerPreferencesScreenState();
}

class _PartnerPreferencesScreenState extends State<PartnerPreferencesScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _memberId;
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String && _memberId == null) {
      _memberId = args;
      _fetchPreferences();
    }
  }

  Future<void> _fetchPreferences() async {
    if (_memberId == null) return;

    debugPrint(
      '[PARTNER_PREFS_SCREEN] 🔵 _fetchPreferences - Fetching for member: $_memberId',
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() => _isLoading = true);

      final prefs = await context.read<FranchiseProvider>().getPreferences(
        _memberId!,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        if (prefs != null) {
          debugPrint(
            '[PARTNER_PREFS_SCREEN] ✅ _fetchPreferences - Received preferences: $prefs',
          );
          _populateForm(prefs);
        } else {
          debugPrint(
            '[PARTNER_PREFS_SCREEN] ⚠️ _fetchPreferences - No preferences found',
          );
        }
      }
    });
  }

  void _populateForm(Map<String, dynamic> json) {
    debugPrint(
      '[PARTNER_PREFS_SCREEN] 🔵 _populateForm - Populating form with data',
    );
    debugPrint(
      '[PARTNER_PREFS_SCREEN] 📦 _populateForm - Raw JSON from backend: $json',
    );

    final prefs = PartnerPreference.fromJson(json);

    debugPrint(
      '[PARTNER_PREFS_SCREEN] 🔢 _populateForm - Parsed - minAge: ${prefs.minAge}, maxAge: ${prefs.maxAge}',
    );
    debugPrint(
      '[PARTNER_PREFS_SCREEN] 📝 _populateForm - Parsed - religion: ${prefs.religion}, maritalStatus: ${prefs.maritalStatus}',
    );
    debugPrint(
      '[PARTNER_PREFS_SCREEN] 💰 _populateForm - Parsed - annualIncome: ${prefs.annualIncome}',
    );

    if (prefs.minAge != null) {
      _minAgeController.text = prefs.minAge!.toString();
      debugPrint(
        '[PARTNER_PREFS_SCREEN] ✏️ _populateForm - Set minAge: ${_minAgeController.text}',
      );
    }
    if (prefs.maxAge != null) {
      _maxAgeController.text = prefs.maxAge!.toString();
      debugPrint(
        '[PARTNER_PREFS_SCREEN] ✏️ _populateForm - Set maxAge: ${_maxAgeController.text}',
      );
    }
    if (prefs.occupation != null) {
      _occupationController.text = prefs.occupation!;
    }
    if (prefs.annualIncome != null) {
      _annualIncomeController.text = prefs.annualIncome!.toString();
      debugPrint(
        '[PARTNER_PREFS_SCREEN] ✏️ _populateForm - Set annualIncome: ${_annualIncomeController.text}',
      );
    }

    setState(() {
      _minHeight = prefs.heightMin;
      _maxHeight = prefs.heightMax;
      _religion = prefs.religion;
      _maritalStatus = prefs.maritalStatus?.firstOrNull;
      _eatingHabits = prefs.eatingHabits;
      _smokingHabits = prefs.smokingHabits;
      _drinkingHabits = prefs.drinkingHabits;
      _highestEducation = prefs.highestEducation;
    });

    debugPrint(
      '[PARTNER_PREFS_SCREEN] ✅ _populateForm - Form populated successfully',
    );
  }

  @override
  void dispose() {
    _minAgeController.dispose();
    _maxAgeController.dispose();
    _occupationController.dispose();
    _annualIncomeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    debugPrint('[PARTNER_PREFS_SCREEN] 🔘 _submit - Button clicked');

    if (!_formKey.currentState!.validate()) {
      debugPrint('[PARTNER_PREFS_SCREEN] ⚠️ _submit - Form validation failed');
      return;
    }
    if (_memberId == null) {
      debugPrint('[PARTNER_PREFS_SCREEN] ❌ _submit - No member ID');
      return;
    }

    debugPrint(
      '[PARTNER_PREFS_SCREEN] 🔵 _submit - Starting submission for member: $_memberId',
    );
    setState(() => _isLoading = true);

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
      annualIncome: int.tryParse(_annualIncomeController.text.trim()),
    );

    debugPrint(
      '[PARTNER_PREFS_SCREEN] 📤 _submit - Submitting preferences: ${prefs.toJson()}',
    );

    final success = await context.read<FranchiseProvider>().updatePreferences(
      _memberId!,
      prefs.toJson(),
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        debugPrint(
          '[PARTNER_PREFS_SCREEN] ✅ _submit - Preferences saved successfully',
        );
        WzToast.show(
          context,
          message: AppLocalizations.of(
            context,
          )!.translate('preferences_updated_success'),
          type: WzToastType.success,
        );
        Navigator.pop(context);
      } else {
        final error = context.read<FranchiseProvider>().error;
        debugPrint('[PARTNER_PREFS_SCREEN] ❌ _submit - Failed to save: $error');
        WzToast.show(
          context,
          message: error.isNotEmpty
              ? error
              : AppLocalizations.of(
                  context,
                )!.translate('failed_update_preferences'),
          type: WzToastType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context)!.translate('partner_preferences'),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: WzLoading(color: WzColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(
                      AppLocalizations.of(
                        context,
                      )!.translate('age_range_label'),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _minAgeController,
                            label: AppLocalizations.of(
                              context,
                            )!.translate('min_age_label'),
                            hint: '18',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: _maxAgeController,
                            label: AppLocalizations.of(
                              context,
                            )!.translate('max_age_label'),
                            hint: '60',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle(
                      AppLocalizations.of(
                        context,
                      )!.translate('height_range_label'),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdown(
                            label: AppLocalizations.of(
                              context,
                            )!.translate('min_height_label'),
                            value: _minHeight,
                            items: _getHeightOptions(),
                            onChanged: (val) =>
                                setState(() => _minHeight = val),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDropdown(
                            label: AppLocalizations.of(
                              context,
                            )!.translate('max_height_label'),
                            value: _maxHeight,
                            items: _getHeightOptions(),
                            onChanged: (val) =>
                                setState(() => _maxHeight = val),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle(
                      AppLocalizations.of(context)!.translate('religion_label'),
                    ),
                    const SizedBox(height: 12),
                    _buildChipSelection(
                      options: [
                        'Hindu',
                        'Muslim',
                        'Christian',
                        'Sikh',
                        'Buddhist',
                        'Jain',
                        'Other',
                      ],
                      selectedValue: _religion,
                      onSelected: (val) => setState(() => _religion = val),
                      translationPrefix: 'religion_',
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle(
                      AppLocalizations.of(
                        context,
                      )!.translate('marital_status_label'),
                    ),
                    const SizedBox(height: 12),
                    _buildChipSelection(
                      options: [
                        'Never Married',
                        'Divorced',
                        'Widowed',
                        'Awaiting Divorce',
                      ],
                      selectedValue: _maritalStatus,
                      onSelected: (val) => setState(() => _maritalStatus = val),
                      translationPrefix: 'marital_',
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle(
                      AppLocalizations.of(context)!.translate('diet_label'),
                    ),
                    const SizedBox(height: 12),
                    _buildChipSelection(
                      options: [
                        'Vegetarian',
                        'Non-Vegetarian',
                        'Eggetarian',
                        'Vegan',
                      ],
                      selectedValue: _eatingHabits,
                      onSelected: (val) => setState(() => _eatingHabits = val),
                      translationPrefix: 'diet_',
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle(
                      AppLocalizations.of(context)!.translate('smoking_label'),
                    ),
                    const SizedBox(height: 12),
                    _buildChipSelection(
                      options: ['No', 'Occasionally', 'Yes'],
                      selectedValue: _smokingHabits,
                      onSelected: (val) => setState(() => _smokingHabits = val),
                      translationPrefix: 'habit_',
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle(
                      AppLocalizations.of(context)!.translate('drinking_label'),
                    ),
                    const SizedBox(height: 12),
                    _buildChipSelection(
                      options: ['No', 'Socially', 'Yes'],
                      selectedValue: _drinkingHabits,
                      onSelected: (val) =>
                          setState(() => _drinkingHabits = val),
                      translationPrefix: 'habit_',
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle(
                      AppLocalizations.of(
                        context,
                      )!.translate('highest_education_label'),
                    ),
                    const SizedBox(height: 16),
                    _buildDropdown(
                      label: AppLocalizations.of(
                        context,
                      )!.translate('select_education_hint'),
                      value: _highestEducation,
                      items: [
                        'High School',
                        'Diploma',
                        "Bachelor's",
                        "Master's",
                        'PhD',
                        'Other',
                      ],
                      onChanged: (val) =>
                          setState(() => _highestEducation = val),
                      translationPrefix: 'edu_',
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle(
                      AppLocalizations.of(
                        context,
                      )!.translate('occupation_optional_label'),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _occupationController,
                      label: AppLocalizations.of(
                        context,
                      )!.translate('occupation_optional_label'),
                      hint: AppLocalizations.of(
                        context,
                      )!.translate('occupation_example'),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle(
                      AppLocalizations.of(
                        context,
                      )!.translate('annual_income_label'),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _annualIncomeController,
                      label: AppLocalizations.of(
                        context,
                      )!.translate('min_income_label'),
                      hint: '500000',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 40),
                    WzPrimaryButton(
                      text: AppLocalizations.of(
                        context,
                      )!.translate('save_preferences'),
                      onPressed: _submit,
                      isLoading: _isLoading,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: WzColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    String? translationPrefix,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: WzColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      items: items.map((item) {
        final displayText = translationPrefix != null
            ? _getTranslatedValue(item, translationPrefix)
            : item;
        return DropdownMenuItem(value: item, child: Text(displayText));
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildChipSelection({
    required List<String> options,
    required String? selectedValue,
    required Function(String?) onSelected,
    required String translationPrefix,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = selectedValue == option;
        return GestureDetector(
          onTap: () => onSelected(isSelected ? null : option),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 6.0,
            ),
            decoration: isSelected
                ? WzButtonStyles.chipSelected()
                : WzButtonStyles.chipUnselected(),
            child: Text(
              _getTranslatedValue(option, translationPrefix),
              style: isSelected
                  ? WzButtonStyles.chipTextSelected()
                  : WzButtonStyles.chipTextUnselected(),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _getTranslatedValue(String value, String prefix) {
    final localizations = AppLocalizations.of(context)!;
    final key =
        '$prefix${value.toLowerCase().replaceAll(' ', '_').replaceAll("'", '')}';
    return localizations.translate(key);
  }

  List<String> _getHeightOptions() {
    return [
      '4\'6"',
      '4\'8"',
      '4\'10"',
      '5\'0"',
      '5\'2"',
      '5\'4"',
      '5\'6"',
      '5\'8"',
      '5\'10"',
      '6\'0"',
      '6\'2"',
      '6\'4"',
      '6\'6"',
    ];
  }
}
