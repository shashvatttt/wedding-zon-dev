import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/filter_model.dart';
import '../../../core/theme/wz_button_styles.dart';

class DynamicFieldBuilder {
  DynamicFieldBuilder._();

  static const List<String> hardcodedKeys = [
    'username',
    'first_name',
    'last_name',
    'email',
    'phone',
    'dob',
    'gender',
    'password',
    'profilePhoto',
    'photos',
    'role',
    'created_for',
  ];

  static Widget buildField({
    required FilterModel filter,
    required Map<String, dynamic> formData,
    required Function(String key, dynamic value) onChanged,
    Map<String, dynamic>? extraDetails,
  }) {
    if (hardcodedKeys.contains(filter.key)) {
      return const SizedBox.shrink();
    }

    final value = extraDetails?[filter.key] ?? formData[filter.key];

    switch (filter.type) {
      case FilterType.select:
        return _buildSelectField(filter, value, onChanged);

      case FilterType.number:
        return _buildNumberField(filter, value, onChanged);

      case FilterType.checkbox:
        return _buildCheckboxField(filter, value, onChanged);

      case FilterType.date:
        return _buildDateField(filter, value, onChanged);

      case FilterType.range:
        return _buildRangeField(filter, value, onChanged);

      case FilterType.text:
      default:
        return _buildTextField(filter, value, onChanged);
    }
  }

  static Widget _buildTextField(
    FilterModel filter,
    dynamic value,
    Function(String, dynamic) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        initialValue: value?.toString() ?? '',
        decoration: InputDecoration(
          labelText: filter.label + (filter.isRequired ? ' *' : ''),
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        validator: filter.isRequired
            ? (val) => val?.isEmpty ?? true ? 'This field is required' : null
            : null,
        onChanged: (val) => onChanged(filter.key, val.trim()),
      ),
    );
  }

  static Widget _buildNumberField(
    FilterModel filter,
    dynamic value,
    Function(String, dynamic) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        initialValue: value?.toString() ?? '',
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          labelText: filter.label + (filter.isRequired ? ' *' : ''),
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        validator: filter.isRequired
            ? (val) => val?.isEmpty ?? true ? 'This field is required' : null
            : null,
        onChanged: (val) {
          final numValue = num.tryParse(val);
          onChanged(filter.key, numValue);
        },
      ),
    );
  }

  static Widget _buildSelectField(
    FilterModel filter,
    dynamic value,
    Function(String, dynamic) onChanged,
  ) {
    final String? safeValue = filter.options.contains(value?.toString())
        ? value.toString()
        : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: safeValue,
        decoration: InputDecoration(
          labelText: filter.label + (filter.isRequired ? ' *' : ''),
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        items: filter.options
            .map(
              (option) => DropdownMenuItem(value: option, child: Text(option)),
            )
            .toList(),
        validator: filter.isRequired
            ? (val) => val == null ? 'Please select an option' : null
            : null,
        onChanged: (val) => onChanged(filter.key, val),
      ),
    );
  }

  static Widget _buildCheckboxField(
    FilterModel filter,
    dynamic value,
    Function(String, dynamic) onChanged,
  ) {
    final bool isChecked = value == true || value == 'true';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: CheckboxListTile(
        title: Text(filter.label + (filter.isRequired ? ' *' : '')),
        value: isChecked,
        activeColor: const Color(0xFFEF2F55),
        contentPadding: EdgeInsets.zero,
        onChanged: (val) => onChanged(filter.key, val ?? false),
      ),
    );
  }

  static Widget _buildDateField(
    FilterModel filter,
    dynamic value,
    Function(String, dynamic) onChanged,
  ) {
    DateTime? selectedDate;
    if (value != null) {
      if (value is DateTime) {
        selectedDate = value;
      } else if (value is String) {
        selectedDate = DateTime.tryParse(value);
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () async {
          final BuildContext? context = _currentContext;
          if (context == null) return;

          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: selectedDate ?? DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: Color(0xFFEF2F55),
                  ),
                ),
                child: child!,
              );
            },
          );

          if (picked != null) {
            onChanged(filter.key, picked.toIso8601String());
          }
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: filter.label + (filter.isRequired ? ' *' : ''),
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            suffixIcon: const Icon(Icons.calendar_today),
          ),
          child: Text(
            selectedDate != null
                ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
                : 'Select date',
            style: TextStyle(
              color: selectedDate != null ? Colors.black : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildRangeField(
    FilterModel filter,
    dynamic value,
    Function(String, dynamic) onChanged,
  ) {
    return _buildTextField(filter, value, onChanged);
  }

  static BuildContext? _currentContext;

  static void setContext(BuildContext context) {
    _currentContext = context;
  }
}
