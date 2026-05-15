enum FilterType { text, number, select, range, checkbox, date }

class FilterModel {
  final String label;
  final String key;
  final FilterType type;
  final List<String> options;
  final String section;
  final int order;
  final bool isRequired;
  final bool isVisible;

  FilterModel({
    required this.label,
    required this.key,
    required this.type,
    this.options = const [],
    required this.section,
    this.order = 0,
    this.isRequired = false,
    this.isVisible = true,
  });

  factory FilterModel.fromJson(Map<String, dynamic> json) {
    bool parseIsVisible(dynamic value) {
      if (value == null) return true;
      if (value is bool) return value;
      if (value is String) {
        final lower = value.toLowerCase();
        return lower == 'true' || lower == '1' || lower == 'yes';
      }
      if (value is num) return value != 0;
      return true;
    }

    return FilterModel(
      label: json['label']?.toString() ?? '',
      key: json['key']?.toString() ?? '',
      type: _parseFilterType(json['type']),
      options: json['options'] != null
          ? (json['options'] is List
                ? List<String>.from(json['options'].map((e) => e.toString()))
                : [])
          : [],
      section: json['section']?.toString() ?? 'general',
      order: json['order'] is int
          ? json['order']
          : (int.tryParse(json['order']?.toString() ?? '0') ?? 0),
      isRequired:
          json['isRequired'] == true ||
          json['isRequired']?.toString().toLowerCase() == 'true',
      isVisible: parseIsVisible(json['isVisible']),
    );
  }

  static FilterType _parseFilterType(dynamic type) {
    if (type == null) return FilterType.text;

    final typeStr = type.toString().toLowerCase();
    switch (typeStr) {
      case 'text':
        return FilterType.text;
      case 'number':
        return FilterType.number;
      case 'select':
        return FilterType.select;
      case 'range':
        return FilterType.range;
      case 'checkbox':
        return FilterType.checkbox;
      case 'date':
        return FilterType.date;
      default:
        return FilterType.text;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'key': key,
      'type': type.name,
      'options': options,
      'section': section,
      'order': order,
      'isRequired': isRequired,
      'isVisible': isVisible,
    };
  }
}
