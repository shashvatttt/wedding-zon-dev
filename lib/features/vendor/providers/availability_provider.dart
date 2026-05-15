import 'package:flutter/material.dart';
import '../repositories/availability_repository.dart';
import '../models/availability_entry.dart';
import '../../auth/providers/auth_provider.dart';

class AvailabilityProvider with ChangeNotifier {
  final AvailabilityRepository _repository;
  final AuthProvider _authProvider;

  bool _isLoading = false;
  Map<DateTime, AvailabilityEntry> _availabilityMap = {};

  AvailabilityProvider(this._repository, this._authProvider) {
    _loadAvailabilityFromUser();
  }

  bool get isLoading => _isLoading;
  Map<DateTime, AvailabilityEntry> get availabilityMap => _availabilityMap;

  void _loadAvailabilityFromUser() {
    final user = _authProvider.currentUser;
    if (user?.vendorDetails?.availability != null) {
      _availabilityMap = {};
      for (var entry in user!.vendorDetails!.availability) {
        final dateKey = DateTime(
          entry.date.year,
          entry.date.month,
          entry.date.day,
        );
        _availabilityMap[dateKey] = entry;
      }
      notifyListeners();
    }
  }

  AvailabilityEntry? getAvailabilityForDate(DateTime date) {
    final dateKey = DateTime(date.year, date.month, date.day);
    return _availabilityMap[dateKey];
  }

  Future<bool> updateAvailability({
    required DateTime date,
    required AvailabilityStatus status,
    String? note,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _repository.updateAvailability(
        date: date,
        status: status.toString().split('.').last,
        action: 'add',
        note: note,
      );

      if (response.success && response.data != null) {
        _availabilityMap = {};
        for (var entry in response.data!) {
          final dateKey = DateTime(
            entry.date.year,
            entry.date.month,
            entry.date.day,
          );
          _availabilityMap[dateKey] = entry;
        }

        await _authProvider.refreshUser();

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('[AVAILABILITY_PROVIDER] Error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeAvailability(DateTime date) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _repository.updateAvailability(
        date: date,
        status: 'available',
        action: 'remove',
      );

      if (response.success && response.data != null) {
        _availabilityMap = {};
        for (var entry in response.data!) {
          final dateKey = DateTime(
            entry.date.year,
            entry.date.month,
            entry.date.day,
          );
          _availabilityMap[dateKey] = entry;
        }

        await _authProvider.refreshUser();

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('[AVAILABILITY_PROVIDER] Error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
