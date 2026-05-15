import 'package:flutter/material.dart';
import '../models/filter_model.dart';
import '../repositories/filters_repository.dart';

class DynamicFiltersProvider extends ChangeNotifier {
  final FiltersRepository _repository;

  DynamicFiltersProvider(this._repository);

  List<FilterModel> _filters = [];
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic> _extraDetails = {};

  List<FilterModel> get filters => _filters;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic> get extraDetails => _extraDetails;

  Map<String, List<FilterModel>> get filtersBySection {
    final Map<String, List<FilterModel>> grouped = {};
    for (final filter in _filters) {
      grouped.putIfAbsent(filter.section, () => []).add(filter);
    }
    return grouped;
  }

  Future<void> loadFilters() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _repository.getFilters();

      if (response.success && response.data != null) {
        _filters = response.data!;
        _error = null;
      } else {
        _error = response.message ?? 'Failed to load filters';
      }
    } catch (e) {
      _error = 'Error loading filters: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  void updateField(String key, dynamic value) {
    _extraDetails[key] = value;
    notifyListeners();
  }

  void updateFields(Map<String, dynamic> fields) {
    _extraDetails.addAll(fields);
    notifyListeners();
  }

  dynamic getFieldValue(String key) {
    return _extraDetails[key];
  }

  void clearExtraDetails() {
    _extraDetails.clear();
    notifyListeners();
  }

  void initializeFromUserData(Map<String, dynamic>? userData) {
    if (userData != null && userData['extra_details'] != null) {
      _extraDetails = Map<String, dynamic>.from(userData['extra_details']);
      notifyListeners();
    }
  }

  bool validateRequiredFields() {
    for (final filter in _filters) {
      if (filter.isRequired) {
        final value = _extraDetails[filter.key];
        if (value == null || value.toString().trim().isEmpty) {
          return false;
        }
      }
    }
    return true;
  }

  List<String> getMissingRequiredFields() {
    final missing = <String>[];
    for (final filter in _filters) {
      if (filter.isRequired) {
        final value = _extraDetails[filter.key];
        if (value == null || value.toString().trim().isEmpty) {
          missing.add(filter.label);
        }
      }
    }
    return missing;
  }

  void reset() {
    _filters = [];
    _extraDetails = {};
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}
