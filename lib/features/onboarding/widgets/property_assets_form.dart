import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/onboarding_provider.dart';

class PropertyAssetsForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;

  const PropertyAssetsForm({super.key, required this.formKey});

  @override
  State<PropertyAssetsForm> createState() => _PropertyAssetsFormState();
}

class _PropertyAssetsFormState extends State<PropertyAssetsForm> {
  final TextEditingController _landAreaController = TextEditingController();
  String _selectedLandUnit = 'Acres';
  List<String> _selectedPropertyTypes = [];

  final List<String> _landUnits = [
    'Acres',
    'Bigha',
    'Ghaz',
    'Sq. Ft.',
    'No Land',
  ];

  final List<String> _propertyOptions = [
    'Commercial',
    'Farming',
    'Plots',
    'Factory',
    'Shops',
    'Houses',
    'Rental',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExistingData();
    });
  }

  void _loadExistingData() {
    final provider = context.read<OnboardingProvider>();

    final landArea = provider.formData['land_area'];
    if (landArea != null && landArea.toString().isNotEmpty) {
      final parts = landArea.toString().split(' ');
      if (parts.length >= 2) {
        if (parts.last == 'Land' && parts[parts.length - 2] == 'No') {
          setState(() {
            _selectedLandUnit = 'No Land';
            _landAreaController.text = '0';
          });
        } else {
          setState(() {
            _landAreaController.text = parts.first;
            _selectedLandUnit = parts.sublist(1).join(' ');
          });
        }
      }
    }

    final propertyTypes = provider.formData['property_types'];
    if (propertyTypes is List) {
      setState(() {
        _selectedPropertyTypes = List<String>.from(propertyTypes);
      });
    }
  }

  void _updateLandArea() {
    final provider = context.read<OnboardingProvider>();
    String landAreaValue;

    if (_selectedLandUnit == 'No Land') {
      landAreaValue = '0 No Land';
    } else {
      landAreaValue = '${_landAreaController.text.trim()} $_selectedLandUnit';
    }

    provider.updateField('land_area', landAreaValue);
  }

  void _updatePropertyTypes() {
    final provider = context.read<OnboardingProvider>();
    provider.updateField('property_types', _selectedPropertyTypes);
  }

  @override
  void dispose() {
    _landAreaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'Property & Assets',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Optional information',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),

          const Text(
            'Land Area',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _landAreaController,
                  decoration: const InputDecoration(
                    labelText: 'Land Value',
                    border: OutlineInputBorder(),
                    hintText: 'Enter value',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  enabled: _selectedLandUnit != 'No Land',
                  validator: (value) {
                    if (_selectedLandUnit != 'No Land') {
                      if (value == null || value.trim().isEmpty) {
                        return 'Required';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Invalid number';
                      }
                    }
                    return null;
                  },
                  onChanged: (value) => _updateLandArea(),
                  onSaved: (value) => _updateLandArea(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  value: _selectedLandUnit,
                  decoration: const InputDecoration(
                    labelText: 'Unit',
                    border: OutlineInputBorder(),
                  ),
                  items: _landUnits.map((unit) {
                    return DropdownMenuItem(value: unit, child: Text(unit));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedLandUnit = value ?? 'Acres';
                      if (_selectedLandUnit == 'No Land') {
                        _landAreaController.text = '0';
                      }
                    });
                    _updateLandArea();
                  },
                  onSaved: (value) => _updateLandArea(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          const Text(
            'Property Types',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _propertyOptions.map((type) {
              final isSelected = _selectedPropertyTypes.contains(type);
              return FilterChip(
                label: Text(type),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedPropertyTypes.add(type);
                    } else {
                      _selectedPropertyTypes.remove(type);
                    }
                  });
                  _updatePropertyTypes();
                },
                selectedColor: Colors.deepPurple.withOpacity(0.2),
                checkmarkColor: Colors.deepPurple,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.deepPurple : Colors.black87,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                side: BorderSide(
                  color: isSelected ? Colors.deepPurple : Colors.grey.shade300,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
