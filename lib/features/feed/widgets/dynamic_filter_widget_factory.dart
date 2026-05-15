import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../onboarding/models/filter_model.dart';

class DynamicFilterWidgetFactory {
  DynamicFilterWidgetFactory._();

  static Widget buildFilter({
    required FilterModel filter,
    required Map<String, String> currentFilters,
    required Function(String key, String value) onUpdate,
  }) {
    switch (filter.type) {
      case FilterType.range:
        return _buildRangeFilter(filter, currentFilters, onUpdate);

      case FilterType.select:
        return _buildSelectFilter(filter, currentFilters, onUpdate);

      case FilterType.checkbox:
        return _buildCheckboxFilter(filter, currentFilters, onUpdate);

      case FilterType.number:
        return _buildNumberFilter(filter, currentFilters, onUpdate);

      case FilterType.text:
      default:
        return _buildTextFilter(filter, currentFilters, onUpdate);
    }
  }

  static Widget _buildRangeFilter(
    FilterModel filter,
    Map<String, String> currentFilters,
    Function(String, String) onUpdate,
  ) {
    final minKey = 'min${_capitalize(filter.key)}';
    final maxKey = 'max${_capitalize(filter.key)}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          filter.label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: currentFilters[minKey] ?? '',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: 'Min',
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                onChanged: (val) => onUpdate(minKey, val),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                initialValue: currentFilters[maxKey] ?? '',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: 'Max',
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                onChanged: (val) => onUpdate(maxKey, val),
              ),
            ),
          ],
        ),
      ],
    );
  }

  static Widget _buildSelectFilter(
    FilterModel filter,
    Map<String, String> currentFilters,
    Function(String, String) onUpdate,
  ) {
    final currentValue = currentFilters[filter.key] ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          filter.label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 12),

        _buildRadioOption(
          label: 'Any',
          value: '',
          groupValue: currentValue,
          onChanged: (val) => onUpdate(filter.key, ''),
        ),

        ...filter.options.map(
          (option) => _buildRadioOption(
            label: option,
            value: option,
            groupValue: currentValue,
            onChanged: (val) => onUpdate(filter.key, val ?? ''),
          ),
        ),
      ],
    );
  }

  static Widget _buildRadioOption({
    required String label,
    required String value,
    required String groupValue,
    required Function(String?) onChanged,
  }) {
    final isSelected = groupValue == value;

    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFEF2F55).withValues(alpha: 0.1)
              : Colors.white,
          border: Border.all(
            color: isSelected
                ? const Color(0xFFEF2F55)
                : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
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
                color: isSelected ? const Color(0xFFEF2F55) : Colors.white,
              ),
              child: isSelected
                  ? const Center(
                      child: Icon(Icons.circle, size: 10, color: Colors.white),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? const Color(0xFFEF2F55)
                      : const Color(0xFF111827),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildCheckboxFilter(
    FilterModel filter,
    Map<String, String> currentFilters,
    Function(String, String) onUpdate,
  ) {
    final isChecked = currentFilters[filter.key] == 'true';

    return CheckboxListTile(
      title: Text(filter.label),
      value: isChecked,
      activeColor: const Color(0xFFEF2F55),
      contentPadding: EdgeInsets.zero,
      onChanged: (val) => onUpdate(filter.key, val == true ? 'true' : ''),
    );
  }

  static Widget _buildNumberFilter(
    FilterModel filter,
    Map<String, String> currentFilters,
    Function(String, String) onUpdate,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          filter.label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: currentFilters[filter.key] ?? '',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          onChanged: (val) => onUpdate(filter.key, val),
        ),
      ],
    );
  }

  static Widget _buildTextFilter(
    FilterModel filter,
    Map<String, String> currentFilters,
    Function(String, String) onUpdate,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          filter.label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: currentFilters[filter.key] ?? '',
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          onChanged: (val) => onUpdate(filter.key, val),
        ),
      ],
    );
  }

  static String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
