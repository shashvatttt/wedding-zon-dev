import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/partner_preference.dart';
import '../providers/profile_provider.dart';
import '../../../shared/widgets/scaffold_with_background.dart';
import '../../explore/widgets/advanced_filter_bottom_sheet.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../shared/widgets/wz_toast.dart';

class UserPartnerPreferencesScreen extends StatefulWidget {
  const UserPartnerPreferencesScreen({super.key});

  @override
  State<UserPartnerPreferencesScreen> createState() =>
      _UserPartnerPreferencesScreenState();
}

class _UserPartnerPreferencesScreenState
    extends State<UserPartnerPreferencesScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final TextEditingController _minAgeController = TextEditingController();
  final TextEditingController _maxAgeController = TextEditingController();
  final TextEditingController _minHeightController = TextEditingController();
  final TextEditingController _maxHeightController = TextEditingController();
  final TextEditingController _occupationController = TextEditingController();
  final TextEditingController _annualIncomeController = TextEditingController();

  String? _religion;
  String? _maritalStatus;
  String? _eatingHabits;
  String? _smokingHabits;
  String? _drinkingHabits;
  String? _highestEducation;

  @override
  void initState() {
    super.initState();
    _fetchPreferences();
  }

  Future<void> _fetchPreferences() async {
    debugPrint(
      '[USER_PREFS_SCREEN] 🔵 _fetchPreferences - Fetching user preferences',
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<ProfileProvider>();
      await provider.loadPreferences();

      if (mounted) {
        final prefs = provider.preferences;
        if (prefs != null) {
          debugPrint(
            '[USER_PREFS_SCREEN] ✅ _fetchPreferences - Received preferences',
          );
          _populateForm(prefs);
        } else {
          debugPrint(
            '[USER_PREFS_SCREEN] ⚠️ _fetchPreferences - No preferences found',
          );
        }
      }
    });
  }

  void _populateForm(PartnerPreference prefs) {
    debugPrint('[USER_PREFS_SCREEN] 🔵 _populateForm - Populating form');

    if (prefs.minAge != null) _minAgeController.text = prefs.minAge!.toString();
    if (prefs.maxAge != null) _maxAgeController.text = prefs.maxAge!.toString();
    if (prefs.heightMin != null) _minHeightController.text = prefs.heightMin!;
    if (prefs.heightMax != null) _maxHeightController.text = prefs.heightMax!;
    if (prefs.occupation != null) {
      _occupationController.text = prefs.occupation!;
    }
    if (prefs.annualIncome != null) {
      _annualIncomeController.text = prefs.annualIncome!.toString();
    }

    setState(() {
      _religion = prefs.religion;
      _maritalStatus = prefs.maritalStatus?.firstOrNull;
      _eatingHabits = prefs.eatingHabits;
      _smokingHabits = prefs.smokingHabits;
      _drinkingHabits = prefs.drinkingHabits;
      _highestEducation = prefs.highestEducation;
    });
  }

  @override
  void dispose() {
    _minAgeController.dispose();
    _maxAgeController.dispose();
    _minHeightController.dispose();
    _maxHeightController.dispose();
    _occupationController.dispose();
    _annualIncomeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    debugPrint('[USER_PREFS_SCREEN] 🔘 _submit - Button clicked');

    if (!_formKey.currentState!.validate()) {
      debugPrint('[USER_PREFS_SCREEN] ⚠️ _submit - Form validation failed');
      return;
    }

    setState(() => _isLoading = true);

    final prefs = PartnerPreference(
      minAge: int.tryParse(_minAgeController.text.trim()),
      maxAge: int.tryParse(_maxAgeController.text.trim()),
      heightMin: _minHeightController.text.trim().isNotEmpty
          ? _minHeightController.text.trim()
          : null,
      heightMax: _maxHeightController.text.trim().isNotEmpty
          ? _maxHeightController.text.trim()
          : null,
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

    debugPrint(
      '[USER_PREFS_SCREEN] 📤 _submit - Submitting preferences: ${prefs.toJson()}',
    );

    final success = await context.read<ProfileProvider>().updatePreferences(
      prefs.toJson(),
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        debugPrint(
          '[USER_PREFS_SCREEN] ✅ _submit - Preferences saved successfully',
        );
        WzToast.show(
          context,
          message: AppLocalizations.of(context)!.preferencesUpdatedSuccessfully,
          type: WzToastType.success,
        );
        Navigator.pop(context);
      } else {
        WzToast.show(
          context,
          message: AppLocalizations.of(context)!.failedUpdatePreferences,
          type: WzToastType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWithBackground(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.partnerPreferences),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: AppLocalizations.of(context)!.advancedFilters,
            onPressed: _openAdvancedFilters,
          ),
        ],
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && _minAgeController.text.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Use Advanced Filters for more options',
                              style: TextStyle(color: Colors.blue.shade700),
                            ),
                          ),
                          TextButton(
                            onPressed: _openAdvancedFilters,
                            child: Text(AppLocalizations.of(context)!.open),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _minAgeController,
                          decoration: const InputDecoration(
                            labelText: 'Min Age',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _maxAgeController,
                          decoration: const InputDecoration(
                            labelText: 'Max Age',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _minHeightController,
                          decoration: const InputDecoration(
                            labelText: 'Min Height',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _maxHeightController,
                          decoration: const InputDecoration(
                            labelText: 'Max Height',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDropdown(
                    label: 'Religion',
                    value: _religion,
                    items: const [
                      'Hindu',
                      'Muslim',
                      'Christian',
                      'Sikh',
                      'Buddhist',
                      'Jain',
                      'Other',
                    ],
                    onChanged: (val) => setState(() => _religion = val),
                  ),
                  _buildDropdown(
                    label: 'Marital Status',
                    value: _maritalStatus,
                    items: const [
                      'Never Married',
                      'Divorced',
                      'Widowed',
                      'Awaiting Divorce',
                    ],
                    onChanged: (val) => setState(() => _maritalStatus = val),
                  ),
                  _buildDropdown(
                    label: 'Eating Habits',
                    value: _eatingHabits,
                    items: const [
                      'Vegetarian',
                      'Non-Vegetarian',
                      'Eggetarian',
                      'Vegan',
                    ],
                    onChanged: (val) => setState(() => _eatingHabits = val),
                  ),
                  _buildDropdown(
                    label: 'Smoking Habits',
                    value: _smokingHabits,
                    items: const ['No', 'Occasionally', 'Yes'],
                    onChanged: (val) => setState(() => _smokingHabits = val),
                  ),
                  _buildDropdown(
                    label: 'Drinking Habits',
                    value: _drinkingHabits,
                    items: const ['No', 'Socially', 'Yes'],
                    onChanged: (val) => setState(() => _drinkingHabits = val),
                  ),
                  _buildDropdown(
                    label: 'Highest Education',
                    value: _highestEducation,
                    items: const [
                      'High School',
                      'Diploma',
                      "Bachelor's Degree",
                      "Master's Degree",
                      'PhD',
                      'Professional Degree',
                      'Other',
                    ],
                    onChanged: (val) => setState(() => _highestEducation = val),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _occupationController,
                    decoration: const InputDecoration(
                      labelText: 'Occupation',
                      border: OutlineInputBorder(),
                      hintText: 'e.g. Engineer',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _annualIncomeController,
                    decoration: const InputDecoration(
                      labelText: 'Min Annual Income',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Save Preferences',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _openAdvancedFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AdvancedFilterBottomSheet(
        saveAsPreferences: true,
        onApply: (filters) {
          if (filters['minAge'] != null) {
            _minAgeController.text = filters['minAge'].toString();
          }
          if (filters['maxAge'] != null) {
            _maxAgeController.text = filters['maxAge'].toString();
          }

          WzToast.show(
            context,
            message: AppLocalizations.of(
              context,
            )!.preferencesUpdatedFromFilters,
            type: WzToastType.success,
          );
        },
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        items: items
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
