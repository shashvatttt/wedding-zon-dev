import 'package:flutter/material.dart';
import '../../onboarding/models/filter_model.dart';
import '../../onboarding/repositories/filters_repository.dart';

class FeedFiltersProvider extends ChangeNotifier {
  final FiltersRepository _repository;

  FeedFiltersProvider(this._repository);

  List<FilterModel> _filters = [];
  Map<String, String> _currentFilters = {};
  bool _isLoading = false;
  String? _error;
  String _selectedSection = 'basic';

  List<FilterModel> get filters => _filters;
  Map<String, String> get currentFilters => _currentFilters;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedSection => _selectedSection;

  List<String> get sections {
    final sectionSet = <String>{};
    for (final filter in _filters) {
      sectionSet.add(filter.section);
    }
    return sectionSet.toList()..sort();
  }

  List<FilterModel> getFiltersForSection(String section) {
    return _filters.where((filter) => filter.section == section).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  void setSelectedSection(String section) {
    _selectedSection = section;
    notifyListeners();
  }

  Future<void> loadFilters({bool forceRefresh = false}) async {
    if (_filters.isNotEmpty && !forceRefresh) {
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _repository.getFilters();

      if (response.success && response.data != null) {
        _filters = response.data!;
        _error = null;

        debugPrint('[FeedFilters] ✅ Loaded ${_filters.length} filters');
        debugPrint('[FeedFilters] Sections: ${sections.join(', ')}');

        if (_filters.isNotEmpty) {
          final availableSections = sections;
          if (availableSections.contains('basic')) {
            _selectedSection = 'basic';
            debugPrint('[FeedFilters] 📍 Default section set to: basic');
          } else if (availableSections.isNotEmpty) {
            _selectedSection = availableSections.first;
            debugPrint(
              '[FeedFilters] 📍 Default section set to: ${availableSections.first}',
            );
          }
        }
      } else {
        _error = response.message ?? 'Failed to load filters';
        debugPrint('[FeedFilters] ❌ Error: $_error');
      }
    } catch (e) {
      _error = 'Error loading filters: $e';
      debugPrint('[FeedFilters] ❌ Exception: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  void updateFilter(String key, String value) {
    if (value.isEmpty || value == 'Any') {
      _currentFilters.remove(key);
    } else {
      _currentFilters[key] = value;
    }
    notifyListeners();
  }

  void updateFilters(Map<String, String> filters) {
    _currentFilters.addAll(filters);
    notifyListeners();
  }

  void clearFilter(String key) {
    _currentFilters.remove(key);
    notifyListeners();
  }

  void clearAllFilters() {
    _currentFilters.clear();
    notifyListeners();
  }

  int get activeFilterCount => _currentFilters.length;

  bool isFilterActive(String key) => _currentFilters.containsKey(key);

  Map<String, dynamic> getQueryParameters() {
    final params = <String, dynamic>{};

    _currentFilters.forEach((key, value) {
      if (value.isNotEmpty && value != 'Any') {
        params[key] = value;
      }
    });

    return params;
  }

  void initializeFilters(Map<String, String>? savedFilters) {
    if (savedFilters != null) {
      _currentFilters = Map<String, String>.from(savedFilters);
      notifyListeners();
    }
  }

  void reset() {
    _filters = [];
    _currentFilters = {};
    _isLoading = false;
    _error = null;
    _selectedSection = 'basic';
    notifyListeners();
  }
}
