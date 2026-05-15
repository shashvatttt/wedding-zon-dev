import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/wz_button_styles.dart';

class FeedFiltersScreenUI extends StatefulWidget {
  const FeedFiltersScreenUI({super.key});

  @override
  State<FeedFiltersScreenUI> createState() => _FeedFiltersScreenUIState();
}

class _FeedFiltersScreenUIState extends State<FeedFiltersScreenUI> {
  String? _sortBy;
  RangeValues _ageRange = const RangeValues(18, 60);

  String? _country;
  String? _state;
  String? _city;

  String? _maritalStatus;
  String? _minHeight;

  String? _religion;
  String? _community;
  String? _motherTongue;
  String? _familyType;

  String? _education;
  String? _occupation;
  String? _income;

  String? _diet;
  String? _smoking;

  String? _propertyType;
  RangeValues _landAreaRange = const RangeValues(0, 1000);
  bool _showLandAreaFilter = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSavedPreferences();
    });
  }

  void _loadSavedPreferences() {
    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.currentUser;

    if (currentUser == null) return;

    final prefs = currentUser.partnerPreferences;
    if (prefs == null) {
      debugPrint('[FEED_FILTERS] 📊 No saved preferences found');
      return;
    }

    debugPrint(
      '[FEED_FILTERS] 🔵 Loading preferences for user: ${currentUser.id}',
    );
    debugPrint('[FEED_FILTERS] 📦 Preferences data: $prefs');

    setState(() {
      if (prefs.minAge != null && prefs.maxAge != null) {
        final minAge = (prefs.minAge as num).toDouble();
        final maxAge = (prefs.maxAge as num).toDouble();
        _ageRange = RangeValues(minAge, maxAge);
      }

      _country = prefs.country;
      _state = prefs.state;
      _city = prefs.city;

      _maritalStatus = prefs.maritalStatus?.firstOrNull;
      _minHeight = prefs.heightMin;

      _religion = prefs.religion;
      _community = prefs.community;
      _motherTongue = prefs.motherTongue;

      _education = prefs.highestEducation;
      _occupation = prefs.occupation;
      _income = prefs.annualIncome;

      _diet = prefs.eatingHabits;
      _smoking = prefs.smokingHabits;
    });

    debugPrint('[FEED_FILTERS] ✅ Preferences loaded successfully');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(
                    context,
                  )!.translate('search_filters_title'),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextButton(
                  onPressed: _clearAll,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.translate('clear_all'),
                    style: const TextStyle(
                      color: Color(0xFFEF2F55),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildBasicFiltersSection(),
                _buildLocationSection(),
                _buildPersonalSection(),
                _buildCulturalSection(),
                _buildProfessionalSection(),
                _buildLifestyleSection(),
                _buildPropertySection(),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF2F55),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context)!.translate('apply_filters'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _clearAll() {
    setState(() {
      _sortBy = null;
      _ageRange = const RangeValues(18, 60);
      _country = null;
      _state = null;
      _city = null;
      _maritalStatus = null;
      _minHeight = null;
      _religion = null;
      _community = null;
      _motherTongue = null;
      _familyType = null;
      _education = null;
      _occupation = null;
      _income = null;
      _diet = null;
      _smoking = null;
      _propertyType = null;
      _landAreaRange = const RangeValues(0, 1000);
      _showLandAreaFilter = false;
    });
  }

  void _applyFilters() {
    final filters = <String, dynamic>{};

    if (_sortBy != null) filters['sort'] = _sortBy;

    filters['minAge'] = _ageRange.start.round();
    filters['maxAge'] = _ageRange.end.round();

    if (_country != null) filters['country'] = _country;
    if (_state != null && _state!.isNotEmpty) filters['state'] = _state;
    if (_city != null && _city!.isNotEmpty) filters['city'] = _city;

    if (_maritalStatus != null) filters['marital_status'] = _maritalStatus;
    if (_minHeight != null) filters['minHeight'] = _minHeight;

    if (_religion != null) filters['religion'] = _religion;
    if (_community != null && _community!.isNotEmpty) {
      filters['community'] = _community;
    }
    if (_motherTongue != null) filters['mother_tongue'] = _motherTongue;
    if (_familyType != null) filters['family_type'] = _familyType;

    if (_education != null) filters['education'] = _education;
    if (_occupation != null && _occupation!.isNotEmpty) {
      filters['occupation'] = _occupation;
    }
    if (_income != null) filters['income'] = _income;

    if (_diet != null) filters['diet'] = _diet;
    if (_smoking != null) filters['smoking'] = _smoking;

    if (_propertyType != null) filters['property_type'] = _propertyType;

    if (_showLandAreaFilter) {
      filters['minLandArea'] = _landAreaRange.start.round();
      filters['maxLandArea'] = _landAreaRange.end.round();

      filters['minLand_area'] = _landAreaRange.start.round();
      filters['maxLand_area'] = _landAreaRange.end.round();
    }

    Navigator.pop(context, filters);
  }

  Widget _buildBasicFiltersSection() {
    return _buildSection(
      title: AppLocalizations.of(context)!.translate('basic_filters'),
      children: [
        _buildDropdown(
          label: AppLocalizations.of(context)!.translate('sort_by'),
          value: _sortBy,
          hint: AppLocalizations.of(context)!.translate('select_sort_order'),
          items: [
            DropdownMenuItem(
              value: 'newest',
              child: Text(
                AppLocalizations.of(context)!.translate('newest_first'),
              ),
            ),
            DropdownMenuItem(
              value: 'age_asc',
              child: Text(
                AppLocalizations.of(context)!.translate('age_youngest_first'),
              ),
            ),
            DropdownMenuItem(
              value: 'age_desc',
              child: Text(
                AppLocalizations.of(context)!.translate('age_oldest_first'),
              ),
            ),
          ],
          onChanged: (value) => setState(() => _sortBy = value),
        ),
        const SizedBox(height: 16),
        Text(
          '${AppLocalizations.of(context)!.translate('age_range_label')}: ${_ageRange.start.round()} - ${_ageRange.end.round()}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        RangeSlider(
          values: _ageRange,
          min: 18,
          max: 80,
          divisions: 62,
          activeColor: const Color(0xFFEF2F55),
          labels: RangeLabels(
            _ageRange.start.round().toString(),
            _ageRange.end.round().toString(),
          ),
          onChanged: (values) => setState(() => _ageRange = values),
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    final isIndia = _country == 'India';

    return _buildSection(
      title: AppLocalizations.of(context)!.translate('location_section'),
      children: [
        _buildDropdown(
          label: AppLocalizations.of(context)!.translate('country_label'),
          value: _country,
          hint: AppLocalizations.of(context)!.translate('select_country'),
          items: [
            DropdownMenuItem(
              value: 'India',
              child: Text(
                AppLocalizations.of(context)!.translate('country_india'),
              ),
            ),
            DropdownMenuItem(
              value: 'USA',
              child: Text(
                AppLocalizations.of(context)!.translate('country_usa'),
              ),
            ),
            DropdownMenuItem(
              value: 'UK',
              child: Text(
                AppLocalizations.of(context)!.translate('country_uk'),
              ),
            ),
            DropdownMenuItem(
              value: 'Canada',
              child: Text(
                AppLocalizations.of(context)!.translate('country_canada'),
              ),
            ),
            DropdownMenuItem(
              value: 'Australia',
              child: Text(
                AppLocalizations.of(context)!.translate('country_australia'),
              ),
            ),
          ],
          onChanged: (value) {
            setState(() {
              _country = value;
              if (value != 'India') _state = null;
            });
          },
        ),
        const SizedBox(height: 16),
        if (isIndia)
          _buildDropdown(
            label: AppLocalizations.of(context)!.translate('state_label'),
            value: _state,
            hint: AppLocalizations.of(context)!.translate('select_state_hint'),
            items: [
              DropdownMenuItem(
                value: 'Maharashtra',
                child: Text(
                  AppLocalizations.of(context)!.translate('state_maharashtra'),
                ),
              ),
              DropdownMenuItem(
                value: 'Delhi',
                child: Text(
                  AppLocalizations.of(context)!.translate('state_delhi'),
                ),
              ),
              DropdownMenuItem(
                value: 'Karnataka',
                child: Text(
                  AppLocalizations.of(context)!.translate('state_karnataka'),
                ),
              ),
              DropdownMenuItem(
                value: 'Gujarat',
                child: Text(
                  AppLocalizations.of(context)!.translate('state_gujarat'),
                ),
              ),
              DropdownMenuItem(
                value: 'Tamil Nadu',
                child: Text(
                  AppLocalizations.of(context)!.translate('state_tamil_nadu'),
                ),
              ),
            ],
            onChanged: (value) => setState(() => _state = value),
          )
        else
          _buildTextField(
            label: AppLocalizations.of(context)!.translate('state_label'),
            value: _state,
            hint: AppLocalizations.of(context)!.translate('enter_state'),
            onChanged: (value) => _state = value,
          ),
        const SizedBox(height: 16),
        _buildTextField(
          label: AppLocalizations.of(context)!.translate('city_label'),
          value: _city,
          hint: AppLocalizations.of(context)!.translate('enter_city'),
          icon: Icons.location_city,
          onChanged: (value) => _city = value,
        ),
      ],
    );
  }

  Widget _buildPersonalSection() {
    return _buildSection(
      title: AppLocalizations.of(
        context,
      )!.translate('personal_details_section'),
      children: [
        Text(
          AppLocalizations.of(context)!.translate('marital_status_label'),
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['Never Married', 'Divorced', 'Widowed', 'Awaiting Divorce']
              .map((status) {
                return GestureDetector(
                  onTap: () {
                    setState(
                      () => _maritalStatus = _maritalStatus == status
                          ? null
                          : status,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 6.0,
                    ),
                    decoration: _maritalStatus == status
                        ? WzButtonStyles.chipSelected()
                        : WzButtonStyles.chipUnselected(),
                    child: Text(
                      _getLocalizedValue(context, status),
                      style: _maritalStatus == status
                          ? WzButtonStyles.chipTextSelected()
                          : WzButtonStyles.chipTextUnselected(),
                    ),
                  ),
                );
              })
              .toList(),
        ),
        const SizedBox(height: 16),
        _buildDropdown(
          label: AppLocalizations.of(context)!.translate('min_height_label'),
          value: _minHeight,
          hint: AppLocalizations.of(context)!.translate('select_min_height'),
          items: [
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
          ].map((h) => DropdownMenuItem(value: h, child: Text(h))).toList(),
          onChanged: (value) => setState(() => _minHeight = value),
        ),
      ],
    );
  }

  Widget _buildCulturalSection() {
    return _buildSection(
      title: AppLocalizations.of(context)!.translate('cultural_family_section'),
      children: [
        Text(
          AppLocalizations.of(context)!.translate('religion_label'),
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              [
                'Hindu',
                'Muslim',
                'Christian',
                'Sikh',
                'Buddhist',
                'Jain',
                'Other',
              ].map((religion) {
                return GestureDetector(
                  onTap: () {
                    setState(
                      () => _religion = _religion == religion ? null : religion,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 6.0,
                    ),
                    decoration: _religion == religion
                        ? WzButtonStyles.chipSelected()
                        : WzButtonStyles.chipUnselected(),
                    child: Text(
                      _getLocalizedValue(context, religion),
                      style: _religion == religion
                          ? WzButtonStyles.chipTextSelected()
                          : WzButtonStyles.chipTextUnselected(),
                    ),
                  ),
                );
              }).toList(),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: AppLocalizations.of(
            context,
          )!.translate('community_caste_label'),
          value: _community,
          hint: AppLocalizations.of(context)!.translate('enter_community'),
          onChanged: (value) => _community = value,
        ),
        const SizedBox(height: 16),
        _buildDropdown(
          label: AppLocalizations.of(context)!.translate('mother_tongue_label'),
          value: _motherTongue,
          hint: AppLocalizations.of(context)!.translate('select_mother_tongue'),
          items:
              [
                    'Hindi',
                    'English',
                    'Marathi',
                    'Tamil',
                    'Telugu',
                    'Bengali',
                    'Gujarati',
                    'Kannada',
                    'Malayalam',
                    'Punjabi',
                  ]
                  .map(
                    (l) => DropdownMenuItem(
                      value: l,
                      child: Text(
                        _getTranslatedMotherTongue(
                          l,
                          AppLocalizations.of(context)!,
                        ),
                      ),
                    ),
                  )
                  .toList(),
          onChanged: (value) => setState(() => _motherTongue = value),
        ),
        const SizedBox(height: 16),
        const SizedBox(height: 16),
        Text(
          AppLocalizations.of(context)!.translate('family_type_label'),
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['Nuclear', 'Joint'].map((type) {
            return GestureDetector(
              onTap: () {
                setState(() => _familyType = _familyType == type ? null : type);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 6.0,
                ),
                decoration: _familyType == type
                    ? WzButtonStyles.chipSelected()
                    : WzButtonStyles.chipUnselected(),
                child: Text(
                  _getLocalizedValue(context, type),
                  style: _familyType == type
                      ? WzButtonStyles.chipTextSelected()
                      : WzButtonStyles.chipTextUnselected(),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildProfessionalSection() {
    return _buildSection(
      title: AppLocalizations.of(
        context,
      )!.translate('professional_details_section'),
      children: [
        _buildDropdown(
          label: AppLocalizations.of(
            context,
          )!.translate('highest_education_label'),
          value: _education,
          hint: AppLocalizations.of(
            context,
          )!.translate('select_education_hint'),
          items:
              [
                    'High School',
                    'Diploma',
                    "Bachelor's",
                    "Master's",
                    'PhD',
                    'Other',
                  ]
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(_getLocalizedValue(context, e)),
                    ),
                  )
                  .toList(),
          onChanged: (value) => setState(() => _education = value),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: AppLocalizations.of(
            context,
          )!.translate('occupation_optional_label'),
          value: _occupation,
          hint: AppLocalizations.of(context)!.translate('occupation_example'),
          icon: Icons.work,
          onChanged: (value) => _occupation = value,
        ),
        const SizedBox(height: 16),
        _buildDropdown(
          label: AppLocalizations.of(context)!.translate('annual_income_label'),
          value: _income,
          hint: AppLocalizations.of(context)!.translate('select_income_range'),
          items:
              [
                    'Below 5 LPA',
                    '5-10 LPA',
                    '10-15 LPA',
                    '15-20 LPA',
                    '20-30 LPA',
                    'Above 30 LPA',
                  ]
                  .map(
                    (i) => DropdownMenuItem(
                      value: i,
                      child: Text(_getLocalizedValue(context, i)),
                    ),
                  )
                  .toList(),
          onChanged: (value) => setState(() => _income = value),
        ),
      ],
    );
  }

  Widget _buildLifestyleSection() {
    return _buildSection(
      title: AppLocalizations.of(
        context,
      )!.translate('lifestyle_preferences_section'),
      children: [
        Text(
          AppLocalizations.of(context)!.translate('diet_label'),
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['Vegetarian', 'Non-Vegetarian', 'Eggetarian', 'Vegan'].map(
            (diet) {
              return GestureDetector(
                onTap: () {
                  setState(() => _diet = _diet == diet ? null : diet);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 6.0,
                  ),
                  decoration: _diet == diet
                      ? WzButtonStyles.chipSelected()
                      : WzButtonStyles.chipUnselected(),
                  child: Text(
                    _getLocalizedValue(context, diet),
                    style: _diet == diet
                        ? WzButtonStyles.chipTextSelected()
                        : WzButtonStyles.chipTextUnselected(),
                  ),
                ),
              );
            },
          ).toList(),
        ),
        const SizedBox(height: 16),
        const SizedBox(height: 16),
        Text(
          AppLocalizations.of(context)!.translate('smoking_label'),
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['No', 'Occasionally', 'Yes'].map((smoking) {
            return GestureDetector(
              onTap: () {
                setState(() => _smoking = _smoking == smoking ? null : smoking);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 6.0,
                ),
                decoration: _smoking == smoking
                    ? WzButtonStyles.chipSelected()
                    : WzButtonStyles.chipUnselected(),
                child: Text(
                  _getLocalizedValue(context, smoking),
                  style: _smoking == smoking
                      ? WzButtonStyles.chipTextSelected()
                      : WzButtonStyles.chipTextUnselected(),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPropertySection() {
    return _buildSection(
      title: AppLocalizations.of(context)!.translate('property_assets_section'),
      children: [
        Text(
          AppLocalizations.of(context)!.translate('property_type_label'),
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['House', 'Apartment', 'Land', 'Farm'].map((type) {
            return GestureDetector(
              onTap: () {
                setState(
                  () => _propertyType = _propertyType == type ? null : type,
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 6.0,
                ),
                decoration: _propertyType == type
                    ? WzButtonStyles.chipSelected()
                    : WzButtonStyles.chipUnselected(),
                child: Text(
                  _getLocalizedValue(context, type),
                  style: _propertyType == type
                      ? WzButtonStyles.chipTextSelected()
                      : WzButtonStyles.chipTextUnselected(),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        CheckboxListTile(
          title: Text(
            AppLocalizations.of(context)!.translate('filter_by_land_area'),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          value: _showLandAreaFilter,
          activeColor: const Color(0xFFEF2F55),
          contentPadding: EdgeInsets.zero,
          onChanged: (value) {
            setState(() => _showLandAreaFilter = value ?? false);
          },
        ),
        if (_showLandAreaFilter) ...[
          const SizedBox(height: 8),
          Text(
            '${AppLocalizations.of(context)!.translate('land_area_range')}: ${_landAreaRange.start.round()} - ${_landAreaRange.end.round()} ${AppLocalizations.of(context)!.translate('acres')}',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          RangeSlider(
            values: _landAreaRange,
            min: 0,
            max: 1000,
            divisions: 100,
            activeColor: const Color(0xFFEF2F55),
            labels: RangeLabels(
              '${_landAreaRange.start.round()}',
              '${_landAreaRange.end.round()}',
            ),
            onChanged: (values) => setState(() => _landAreaRange = values),
          ),
        ],
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return ExpansionTile(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required String hint,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    T? safeValue = value;
    if (value != null && !items.any((item) => item.value == value)) {
      debugPrint(
        '[FEED_FILTERS] ⚠️ Value "$value" not found in dropdown items for "$label". Resetting to null.',
      );
      safeValue = null;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14)),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          key: ValueKey(safeValue),
          initialValue: safeValue,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          hint: Text(hint),
          items: items,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String? value,
    required String hint,
    IconData? icon,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: value,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: hint,
            prefixIcon: icon != null ? Icon(icon) : null,
          ),
          onChanged: (val) => onChanged(val.trim().isEmpty ? '' : val.trim()),
        ),
      ],
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

      case 'Nuclear':
        return localizations.translate('family_nuclear');
      case 'Joint':
        return localizations.translate('family_joint');

      case 'High School':
        return localizations.translate('edu_high_school');
      case 'Diploma':
        return localizations.translate('edu_diploma');
      case "Bachelor's":
        return localizations.translate('edu_bachelors');
      case "Master's":
        return localizations.translate('edu_masters');
      case 'PhD':
        return localizations.translate('edu_phd');

      case 'Below 5 LPA':
        return localizations.translate('income_below_5_lpa');
      case '5-10 LPA':
        return localizations.translate('income_5_10_lpa');
      case '10-15 LPA':
        return localizations.translate('income_10_15_lpa');
      case '15-20 LPA':
        return localizations.translate('income_15_20_lpa');
      case '20-30 LPA':
        return localizations.translate('income_20_30_lpa');
      case 'Above 30 LPA':
        return localizations.translate('income_above_30_lpa');

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

      case 'House':
        return localizations.translate('property_house');
      case 'Apartment':
        return localizations.translate('property_apartment');
      case 'Land':
        return localizations.translate('property_land');
      case 'Farm':
        return localizations.translate('property_farm');

      default:
        return value;
    }
  }

  String _getTranslatedMotherTongue(
    String value,
    AppLocalizations localizations,
  ) {
    switch (value) {
      case 'Hindi':
        return localizations.translate('tongue_hindi');
      case 'English':
        return localizations.translate('tongue_english');
      case 'Punjabi':
        return localizations.translate('tongue_punjabi');
      case 'Bengali':
        return localizations.translate('tongue_bengali');
      case 'Gujarati':
        return localizations.translate('tongue_gujarati');
      case 'Marathi':
        return localizations.translate('tongue_marathi');
      case 'Tamil':
        return localizations.translate('tongue_tamil');
      case 'Telugu':
        return localizations.translate('tongue_telugu');
      case 'Kannada':
        return localizations.translate('tongue_kannada');
      case 'Malayalam':
        return localizations.translate('tongue_malayalam');
      default:
        return value;
    }
  }
}
