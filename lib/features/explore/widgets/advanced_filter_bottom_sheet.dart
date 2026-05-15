import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../profile/repositories/user_repository.dart';
import '../../../shared/widgets/wz_toast.dart';

class AdvancedFilterBottomSheet extends StatefulWidget {
  final Function(Map<String, dynamic>) onApply;
  final Map<String, dynamic>? initialFilters;
  final bool saveAsPreferences;

  const AdvancedFilterBottomSheet({
    super.key,
    required this.onApply,
    this.initialFilters,
    this.saveAsPreferences = false,
  });

  @override
  State<AdvancedFilterBottomSheet> createState() =>
      _AdvancedFilterBottomSheetState();
}

class _AdvancedFilterBottomSheetState extends State<AdvancedFilterBottomSheet> {
  int _selectedCategoryIndex = 0;
  bool _savePreferences = false;

  String? _typeOfMatches;
  final List<String> _basedOutOf = [];
  final List<String> _postedBy = [];
  final List<String> _activityOnSite = [];
  final List<String> _religion = [];
  final List<String> _caste = [];
  final List<String> _subcaste = [];
  RangeValues _ageRange = const RangeValues(18, 70);
  final List<String> _motherTongue = [];
  final List<String> _country = [];
  double _minIncome = 0;
  double _maxIncome = 0;
  final List<String> _employedIn = [];
  final List<String> _education = [];
  final List<String> _drinking = [];
  final List<String> _smoking = [];
  final List<String> _eatingHabits = [];
  final List<String> _maritalStatus = [];
  final List<String> _familyTypes = [];
  final List<String> _siblings = [];
  final List<String> _propertyTypes = [];
  final List<String> _landArea = [];

  final List<String> _categories = [
    'Type of Matches',
    'Based Out Of',
    'Posted By',
    'Activity On Site',
    'Religion',
    'Caste',
    'Subcaste',
    'Age',
    'Mother Tongue',
    'Country',
    'Income',
    'Employed In',
    'Education',
    'Drinking',
    'Smoking',
    'Eating Habits',
    'Maritial Status',
    'Family types',
    'Siblings',
    'Property Types',
    'Land Area',
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialFilters();
  }

  void _loadInitialFilters() {
    if (widget.initialFilters != null) {
      final filters = widget.initialFilters!;

      _ageRange = RangeValues(
        (filters['minAge'] ?? 18).toDouble(),
        (filters['maxAge'] ?? 70).toDouble(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Row(
              children: [
                _buildSidebar(),
                Expanded(child: _buildContent()),
              ],
            ),
          ),
          _buildBottomButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Filters',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Color(0xFF374151),
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: _resetFilters,
                child: const Text(
                  'Reset',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFEF2F55),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              IconButton(
                icon: const Icon(Icons.close, size: 28),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 224,
      decoration: const BoxDecoration(
        color: Color(0xFFFFF9FA),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(16)),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedCategoryIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategoryIndex = index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 31, vertical: 16),
              color: isSelected ? Colors.white : Colors.transparent,
              child: Text(
                _categories[index],
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF374151),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: _buildCategoryContent(),
    );
  }

  Widget _buildCategoryContent() {
    switch (_selectedCategoryIndex) {
      case 0:
        return _buildTypeOfMatchesContent();
      case 1:
        return _buildBasedOutOfContent();
      case 2:
        return _buildPostedByContent();
      case 3:
        return _buildActivityOnSiteContent();
      case 4:
        return _buildReligionContent();
      case 5:
        return _buildCasteContent();
      case 6:
        return _buildSubcasteContent();
      case 7:
        return _buildAgeContent();
      case 8:
        return _buildMotherTongueContent();
      case 9:
        return _buildCountryContent();
      case 10:
        return _buildIncomeContent();
      case 11:
        return _buildEmployedInContent();
      case 12:
        return _buildEducationContent();
      case 13:
        return _buildDrinkingContent();
      case 14:
        return _buildSmokingContent();
      case 15:
        return _buildEatingHabitsContent();
      case 16:
        return _buildMaritalStatusContent();
      case 17:
        return _buildFamilyTypesContent();
      case 18:
        return _buildSiblingsContent();
      case 19:
        return _buildPropertyTypesContent();
      case 20:
        return _buildLandAreaContent();
      default:
        return const SizedBox();
    }
  }

  Widget _buildTypeOfMatchesContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRadioOption('All', _typeOfMatches == 'All', () {
          setState(() => _typeOfMatches = 'All');
        }),
        const SizedBox(height: 12),
        _buildRadioOption('Verified', _typeOfMatches == 'Verified', () {
          setState(() => _typeOfMatches = 'Verified');
        }),
        const SizedBox(height: 12),
        _buildRadioOption('Just Joined', _typeOfMatches == 'Just Joined', () {
          setState(() => _typeOfMatches = 'Just Joined');
        }),
        const SizedBox(height: 12),
        _buildRadioOption('Nearby', _typeOfMatches == 'Nearby', () {
          setState(() => _typeOfMatches = 'Nearby');
        }),
      ],
    );
  }

  Widget _buildBasedOutOfContent() {
    final options = [
      'Uttar Pradesh',
      'Madhya Pradesh',
      'Bihar',
      'Delhi',
      'Rajasthan',
      'Jharkhand',
      'Gujarat',
      'Haryana',
      'Karnataka',
      'Maharashtra',
    ];
    return _buildCheckboxList(options, _basedOutOf);
  }

  Widget _buildPostedByContent() {
    final options = ['Parent', 'Self', 'Sibling', 'Other'];
    return _buildCheckboxList(options, _postedBy);
  }

  Widget _buildActivityOnSiteContent() {
    final options = [
      'Online',
      'Active in last week',
      'Active in last month',
      'Active in last 2 month',
    ];
    return _buildCheckboxList(options, _activityOnSite);
  }

  Widget _buildReligionContent() {
    final options = ['Hindu', 'Muslim', 'Sikh', 'Christian'];
    return _buildCheckboxList(options, _religion);
  }

  Widget _buildCasteContent() {
    final options = ['Brahmins', 'Kayastha', 'Yadav', 'Rajput', 'Jaat'];
    return _buildCheckboxList(options, _caste);
  }

  Widget _buildSubcasteContent() {
    final options = [
      'Kanyakubj',
      'Gaur',
      'Maithil',
      'Saxena',
      'Bhatnagar',
      'Nigam',
      'Suryavanshi',
    ];
    return _buildCheckboxList(options, _subcaste);
  }

  Widget _buildAgeContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Minimum Age',
          style: TextStyle(fontSize: 22, color: Color(0xFF374151)),
        ),
        const SizedBox(height: 8),
        Text(
          '${_ageRange.start.round()} Years',
          style: const TextStyle(fontSize: 22, color: Color(0xFF374151)),
        ),
        Slider(
          value: _ageRange.start,
          min: 18,
          max: 70,
          divisions: 52,
          activeColor: const Color(0xFFEF2F55),
          onChanged: (value) {
            setState(() {
              _ageRange = RangeValues(value, _ageRange.end);
            });
          },
        ),
        const SizedBox(height: 24),
        const Text(
          'Maximum Age',
          style: TextStyle(fontSize: 22, color: Color(0xFF374151)),
        ),
        const SizedBox(height: 8),
        Text(
          '${_ageRange.end.round()} Years',
          style: const TextStyle(fontSize: 22, color: Color(0xFF374151)),
        ),
        Slider(
          value: _ageRange.end,
          min: 18,
          max: 70,
          divisions: 52,
          activeColor: const Color(0xFFEF2F55),
          onChanged: (value) {
            setState(() {
              _ageRange = RangeValues(_ageRange.start, value);
            });
          },
        ),
      ],
    );
  }

  Widget _buildMotherTongueContent() {
    final options = [
      'Hindi-UP/UK',
      'Hindi-Delhi',
      'Hindi-MP/CG',
      'Hindi-Rajasthan',
      'Punjabi',
    ];
    return _buildCheckboxList(options, _motherTongue);
  }

  Widget _buildCountryContent() {
    final options = ['India', 'Australia', 'United States', 'Russia'];
    return _buildCheckboxList(options, _country);
  }

  Widget _buildIncomeContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'INR(₹)',
          style: TextStyle(fontSize: 33, color: Color(0xFF374151)),
        ),
        const SizedBox(height: 16),
        const Text(
          'Minimum Income',
          style: TextStyle(fontSize: 27, color: Color(0xFF374151)),
        ),
        const SizedBox(height: 8),
        Text(
          'Rs. ${_minIncome.round()}',
          style: const TextStyle(fontSize: 27, color: Color(0xFF374151)),
        ),
        const Divider(),
        const SizedBox(height: 24),
        const Text(
          'Maximum Income',
          style: TextStyle(fontSize: 27, color: Color(0xFF374151)),
        ),
        const SizedBox(height: 8),
        const Text(
          'and above',
          style: TextStyle(fontSize: 27, color: Color(0xFF374151)),
        ),
        const Divider(),
        const SizedBox(height: 32),
        const Text(
          'USD(\$)',
          style: TextStyle(fontSize: 34, color: Color(0xFF374151)),
        ),
        const SizedBox(height: 16),
        const Text(
          'Fill if you are looking for a partner outside of India',
          style: TextStyle(fontSize: 20, color: Color(0xFF374151)),
        ),
      ],
    );
  }

  Widget _buildEmployedInContent() {
    final options = [
      'Not working currently',
      'Private Sector',
      'Business/ Self Employed',
      'Government/Public Sector',
      'Defence',
    ];
    return _buildCheckboxList(options, _employedIn);
  }

  Widget _buildEducationContent() {
    final options = [
      'Arts/Science',
      'B.A',
      'B.A.(Hons)',
      'B.Ed',
      'B.Sc',
      'B.Sc.(Post Basic)',
      'BFA',
      'BJMC',
      'M.Sc',
      'D.Ed',
      'M.A.',
    ];
    return _buildCheckboxList(options, _education);
  }

  Widget _buildDrinkingContent() {
    final options = [
      'Non-Drinker',
      'Occasionally',
      'Social Drinker',
      'Regular Drinker',
      'Yes',
      'No',
      'Prefer Not to say',
    ];
    return _buildCheckboxList(options, _drinking);
  }

  Widget _buildSmokingContent() {
    final options = [
      'Non-Smoker',
      'Occasionally',
      'Social Smoker',
      'Regular Smoker',
      'Yes',
      'No',
      'Prefer Not to say',
    ];
    return _buildCheckboxList(options, _smoking);
  }

  Widget _buildEatingHabitsContent() {
    final options = ['Vegetarian', 'Non-Vegetarian', 'Eggetarian'];
    return _buildCheckboxList(options, _eatingHabits);
  }

  Widget _buildMaritalStatusContent() {
    final options = ["Doesn't Matter", 'Never Married', 'Divorced'];
    return _buildCheckboxList(options, _maritalStatus);
  }

  Widget _buildFamilyTypesContent() {
    final options = ["Doesn't Matter", 'Nuclear', 'Joint'];
    return _buildCheckboxList(options, _familyTypes);
  }

  Widget _buildSiblingsContent() {
    final options = ['No Siblings', '2-3 Siblings', 'More than 3 Siblings'];
    return _buildCheckboxList(options, _siblings);
  }

  Widget _buildPropertyTypesContent() {
    final options = [
      'Self-Acquired property',
      'Joint Family Property',
      'Multiple Properties',
    ];
    return _buildCheckboxList(options, _propertyTypes);
  }

  Widget _buildLandAreaContent() {
    final options = [
      'Below 500 sq ft',
      '500 - 1000 sq ft',
      '1000 - 2000 sq ft',
      '2000 - 5000 sq ft',
      'Above 5000 sq ft',
    ];
    return _buildCheckboxList(options, _landArea);
  }

  Widget _buildRadioOption(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? const Color(0xFFEF2F55)
                    : const Color(0xFF9CA3AF),
                width: 2,
              ),
            ),
            child: isSelected
                ? Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFEF2F55),
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(fontSize: 18, color: Color(0xFF374151)),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxList(List<String> options, List<String> selectedValues) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCheckboxOption(
          'All',
          selectedValues.length == options.length,
          () {
            setState(() {
              if (selectedValues.length == options.length) {
                selectedValues.clear();
              } else {
                selectedValues.clear();
                selectedValues.addAll(options);
              }
            });
          },
        ),
        const SizedBox(height: 16),

        ...options.map((option) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildCheckboxOption(
              option,
              selectedValues.contains(option),
              () {
                setState(() {
                  if (selectedValues.contains(option)) {
                    selectedValues.remove(option);
                  } else {
                    selectedValues.add(option);
                  }
                });
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildCheckboxOption(
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected
                    ? const Color(0xFFEF2F55)
                    : const Color(0xFF9CA3AF),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(4),
              color: isSelected ? const Color(0xFFEF2F55) : Colors.transparent,
            ),
            child: isSelected
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 18, color: Color(0xFF374151)),
            ),
          ),
        ],
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      _typeOfMatches = null;
      _basedOutOf.clear();
      _postedBy.clear();
      _activityOnSite.clear();
      _religion.clear();
      _caste.clear();
      _subcaste.clear();
      _ageRange = const RangeValues(18, 70);
      _motherTongue.clear();
      _country.clear();
      _minIncome = 0;
      _maxIncome = 0;
      _employedIn.clear();
      _education.clear();
      _drinking.clear();
      _smoking.clear();
      _eatingHabits.clear();
      _maritalStatus.clear();
      _familyTypes.clear();
      _siblings.clear();
      _propertyTypes.clear();
      _landArea.clear();
    });

    widget.onApply({});
    Navigator.pop(context);
  }

  void _applyFilters() async {
    final filters = <String, dynamic>{};

    if (_typeOfMatches != null) filters['typeOfMatches'] = _typeOfMatches;
    if (_basedOutOf.isNotEmpty) filters['basedOutOf'] = _basedOutOf;
    if (_postedBy.isNotEmpty) filters['postedBy'] = _postedBy;
    if (_activityOnSite.isNotEmpty) {
      filters['activityOnSite'] = _activityOnSite;
    }
    if (_religion.isNotEmpty) filters['religion'] = _religion;
    if (_caste.isNotEmpty) filters['caste'] = _caste;
    if (_subcaste.isNotEmpty) filters['subcaste'] = _subcaste;

    filters['minAge'] = _ageRange.start.round();
    filters['maxAge'] = _ageRange.end.round();

    if (_motherTongue.isNotEmpty) filters['motherTongue'] = _motherTongue;
    if (_country.isNotEmpty) filters['country'] = _country;
    if (_minIncome > 0) filters['minIncome'] = _minIncome;
    if (_maxIncome > 0) filters['maxIncome'] = _maxIncome;
    if (_employedIn.isNotEmpty) filters['employedIn'] = _employedIn;
    if (_education.isNotEmpty) filters['education'] = _education;
    if (_drinking.isNotEmpty) filters['drinking'] = _drinking;
    if (_smoking.isNotEmpty) filters['smoking'] = _smoking;
    if (_eatingHabits.isNotEmpty) filters['eatingHabits'] = _eatingHabits;
    if (_maritalStatus.isNotEmpty) filters['maritalStatus'] = _maritalStatus;
    if (_familyTypes.isNotEmpty) filters['familyTypes'] = _familyTypes;
    if (_siblings.isNotEmpty) filters['siblings'] = _siblings;
    if (_propertyTypes.isNotEmpty) filters['propertyTypes'] = _propertyTypes;
    if (_landArea.isNotEmpty) filters['landArea'] = _landArea;

    if (widget.saveAsPreferences && _savePreferences && mounted) {
      try {
        final userRepo = context.read<UserRepository>();
        final response = await userRepo.updateMyPreferences(filters);

        if (response.success) {
          WzToast.show(
            context,
            message: 'Preferences saved successfully',
            type: WzToastType.success,
          );
        } else {
          WzToast.show(
            context,
            message: 'Failed to save preferences: ${response.message}',
            type: WzToastType.error,
          );
        }
      } catch (e) {
        debugPrint('[FILTER] Error saving preferences: $e');
        WzToast.show(
          context,
          message: 'Error saving preferences',
          type: WzToastType.error,
        );
      }
    }

    widget.onApply(filters);
    Navigator.pop(context);
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.saveAsPreferences)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Checkbox(
                    value: _savePreferences,
                    onChanged: (value) {
                      setState(() => _savePreferences = value ?? false);
                    },
                    activeColor: const Color(0xFFEF2F55),
                  ),
                  const Expanded(
                    child: Text(
                      'Save these filters as my partner preferences',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _resetFilters,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Color(0xFFEF2F55)),
                    foregroundColor: const Color(0xFFEF2F55),
                  ),
                  child: const Text('Clear All'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF2F55),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
