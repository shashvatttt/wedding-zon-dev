import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weddingzon/core/theme/wz_colors.dart';
import 'package:weddingzon/core/theme/wz_text_styles.dart';
import 'package:weddingzon/core/routes/app_routes.dart';
import 'package:weddingzon/features/onboarding/providers/onboarding_provider.dart';
import 'package:weddingzon/features/profile/providers/profile_provider.dart';
import 'package:weddingzon/features/profile/models/partner_preference.dart';
import 'package:weddingzon/features/auth/providers/auth_provider.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/constants/profile_constants.dart';
import 'package:weddingzon/shared/widgets/wz_toast.dart';
import '../widgets/wz_buttons.dart';

class ProfilePartnerPreferencesOnboardingUI extends StatefulWidget {
  const ProfilePartnerPreferencesOnboardingUI({super.key});

  @override
  State<ProfilePartnerPreferencesOnboardingUI> createState() =>
      _ProfilePartnerPreferencesOnboardingUIState();
}

class _ProfilePartnerPreferencesOnboardingUIState
    extends State<ProfilePartnerPreferencesOnboardingUI> {
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
    debugPrint(
      '📍 [SCREEN] ========== PARTNER PREFERENCES ONBOARDING ========== [ROUTE: ${AppRoutes.profilePartnerPreferences}]',
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExistingPreferences();
    });
  }

  Future<void> _loadExistingPreferences() async {
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
      _minHeight = prefs.heightMin;
      _maxHeight = prefs.heightMax;
      _religion = prefs.religion;
      _maritalStatus = prefs.maritalStatus?.isNotEmpty == true
          ? prefs.maritalStatus!.first
          : null;
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
    _occupationController.dispose();
    _annualIncomeController.dispose();
    super.dispose();
  }

  Future<void> _onContinue() async {
    setState(() => _isLoading = true);

    try {
      if (_hasAnyPreferences()) {
        debugPrint('[PREFS_ONBOARDING] 🔵 Saving preferences...');

        final prefs = PartnerPreference(
          minAge: int.tryParse(_minAgeController.text.trim()),
          maxAge: int.tryParse(_maxAgeController.text.trim()),
          heightMin: _minHeight,
          heightMax: _maxHeight,
          religion: _religion,
          maritalStatus: _maritalStatus != null ? [_maritalStatus!] : [],
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
        debugPrint('[PREFS_ONBOARDING] 📤 Preferences JSON: $prefsJson');

        final success = await context.read<ProfileProvider>().updatePreferences(
          prefsJson,
        );

        if (!success) {
          debugPrint('[PREFS_ONBOARDING] ❌ Failed to save preferences');
          if (mounted) {
            WzToast.show(
              context,
              message: AppLocalizations.of(
                context,
              )!.translate('preferences_update_failed_msg'),
              type: WzToastType.error,
            );
          }
          return;
        }

        debugPrint('[PREFS_ONBOARDING] ✅ Preferences saved successfully');
      } else {
        debugPrint('[PREFS_ONBOARDING] 📝 No preferences to save, skipping...');
      }

      debugPrint('[PREFS_ONBOARDING] 🚀 Completing profile...');
      final onboardingProvider = context.read<OnboardingProvider>();
      final response = await onboardingProvider.submitProfile();

      if (!response.success) {
        debugPrint(
          '[PREFS_ONBOARDING] ❌ Profile completion failed: ${response.message}',
        );
        if (mounted) {
          WzToast.show(
            context,
            message:
                response.message ??
                AppLocalizations.of(
                  context,
                )!.translate('failed_create_profile'),
            type: WzToastType.error,
          );
        }
        return;
      }

      debugPrint('[PREFS_ONBOARDING] ✅ Profile completed successfully');

      if (!mounted) return;
      final authProvider = context.read<AuthProvider>();
      await authProvider.refreshUser();

      if (!mounted) return;
      debugPrint('[PREFS_ONBOARDING] 🎯 Navigating to feed...');
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.feed,
        (route) => false,
      );
    } catch (e, stackTrace) {
      debugPrint('[PREFS_ONBOARDING] ❌ Error in _onContinue: $e');
      debugPrint('[PREFS_ONBOARDING] StackTrace: $stackTrace');
      if (mounted) {
        WzToast.show(context, message: 'Error: $e', type: WzToastType.error);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onSkip() async {
    debugPrint('[PREFS_ONBOARDING] 📝 Skipping preferences...');
    setState(() => _isLoading = true);

    try {
      debugPrint(
        '[PREFS_ONBOARDING] 🚀 Completing profile without preferences...',
      );
      final onboardingProvider = context.read<OnboardingProvider>();
      final response = await onboardingProvider.submitProfile();

      if (!response.success) {
        debugPrint(
          '[PREFS_ONBOARDING] ❌ Profile completion failed: ${response.message}',
        );
        if (mounted) {
          WzToast.show(
            context,
            message:
                response.message ??
                AppLocalizations.of(
                  context,
                )!.translate('failed_create_profile'),
            type: WzToastType.error,
          );
        }
        return;
      }

      debugPrint('[PREFS_ONBOARDING] ✅ Profile completed successfully');

      if (!mounted) return;
      final authProvider = context.read<AuthProvider>();
      await authProvider.refreshUser();

      if (!mounted) return;
      debugPrint('[PREFS_ONBOARDING] 🎯 Navigating to feed...');
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.feed,
        (route) => false,
      );
    } catch (e, stackTrace) {
      debugPrint('[PREFS_ONBOARDING] ❌ Error in _onSkip: $e');
      debugPrint('[PREFS_ONBOARDING] StackTrace: $stackTrace');
      if (mounted) {
        WzToast.show(context, message: 'Error: $e', type: WzToastType.error);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool _hasAnyPreferences() {
    return _minAgeController.text.trim().isNotEmpty ||
        _maxAgeController.text.trim().isNotEmpty ||
        _minHeight != null ||
        _maxHeight != null ||
        _religion != null ||
        _maritalStatus != null ||
        _eatingHabits != null ||
        _smokingHabits != null ||
        _drinkingHabits != null ||
        _highestEducation != null ||
        _occupationController.text.trim().isNotEmpty ||
        _annualIncomeController.text.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.translate('partner_preferences_title'),
                    style: WzTextStyles.heading3.copyWith(
                      fontSize: 24.0,
                      fontWeight: FontWeight.w600,
                      color: WzColors.text,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),

                const SizedBox(height: 16.0),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.translate('partner_preferences_subtitle'),
                    style: WzTextStyles.body2.copyWith(
                      fontSize: 16.0,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),

                const SizedBox(height: 38.0),

                _buildSectionTitle(l10n.translate('age_range')),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _minAgeController,
                        label: l10n.translate('min_age'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: _buildTextField(
                        controller: _maxAgeController,
                        label: l10n.translate('max_age'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24.0),

                _buildSectionTitle(l10n.translate('height_range')),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdown(
                        value: _minHeight,
                        label: l10n.translate('min_height'),
                        items: ProfileConstants.heights,
                        onChanged: (value) =>
                            setState(() => _minHeight = value),
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: _buildDropdown(
                        value: _maxHeight,
                        label: l10n.translate('max_height'),
                        items: ProfileConstants.heights,
                        onChanged: (value) =>
                            setState(() => _maxHeight = value),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24.0),

                _buildSectionTitle(l10n.translate('religion_label')),
                const SizedBox(height: 16.0),
                _buildDropdown(
                  value: _religion,
                  label: l10n.translate('religion_label'),
                  items: ProfileConstants.religions,
                  onChanged: (value) => setState(() => _religion = value),
                ),

                const SizedBox(height: 24.0),

                _buildSectionTitle(l10n.translate('marital_status_label')),
                const SizedBox(height: 16.0),
                _buildDropdown(
                  value: _maritalStatus,
                  label: l10n.translate('marital_status_label'),
                  items: ProfileConstants.maritalStatus,
                  onChanged: (value) => setState(() => _maritalStatus = value),
                ),

                const SizedBox(height: 24.0),

                _buildSectionTitle(l10n.translate('lifestyle_preferences')),
                const SizedBox(height: 16.0),

                _buildDropdown(
                  value: _eatingHabits,
                  label: l10n.translate('diet'),
                  items: ProfileConstants.eatingHabits,
                  onChanged: (value) => setState(() => _eatingHabits = value),
                ),

                const SizedBox(height: 16.0),

                _buildDropdown(
                  value: _smokingHabits,
                  label: l10n.translate('smoking'),
                  items: ProfileConstants.smokingHabits,
                  onChanged: (value) => setState(() => _smokingHabits = value),
                ),

                const SizedBox(height: 16.0),

                _buildDropdown(
                  value: _drinkingHabits,
                  label: l10n.translate('drinking'),
                  items: ProfileConstants.drinkingHabits,
                  onChanged: (value) => setState(() => _drinkingHabits = value),
                ),

                const SizedBox(height: 24.0),

                _buildSectionTitle(l10n.translate('education_career')),
                const SizedBox(height: 16.0),

                _buildDropdown(
                  value: _highestEducation,
                  label: l10n.translate('highest_education_label'),
                  items: ProfileConstants.education,
                  onChanged: (value) =>
                      setState(() => _highestEducation = value),
                ),

                const SizedBox(height: 16.0),

                _buildTextField(
                  controller: _occupationController,
                  label: l10n.translate('occupation_label'),
                ),

                const SizedBox(height: 16.0),

                _buildTextField(
                  controller: _annualIncomeController,
                  label: l10n.translate('annual_income'),
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 48.0),

                Row(
                  children: [
                    Expanded(
                      child: WzSecondaryButton(
                        text: l10n.translate('skip'),
                        onPressed: _isLoading ? null : _onSkip,
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: WzPrimaryButton(
                        text: _isLoading
                            ? l10n.translate('saving')
                            : l10n.translate('continue'),
                        onPressed: _isLoading ? null : _onContinue,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: WzTextStyles.heading4.copyWith(
        fontSize: 18.0,
        fontWeight: FontWeight.w600,
        color: WzColors.text,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: WzColors.primary),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 12.0,
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String label,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final validValue = value != null && items.contains(value) ? value : null;

    return DropdownButtonFormField<String>(
      initialValue: validValue,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: WzColors.primary),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 12.0,
        ),
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(value: item, child: Text(item));
      }).toList(),
      onChanged: onChanged,
    );
  }
}
