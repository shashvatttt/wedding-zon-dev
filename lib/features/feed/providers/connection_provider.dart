import 'package:flutter/material.dart';
import '../../connections/repositories/connections_repository.dart';
import '../../../shared/widgets/wz_toast.dart';

class ConnectionProvider extends ChangeNotifier {
  final ConnectionsRepository _repository;

  ConnectionProvider(this._repository);

  final Map<String, String> _connectionStatuses = {};

  final Set<String> _sendingInterest = {};
  final Set<String> _cancellingRequest = {};

  String getConnectionStatus(String username) {
    return _connectionStatuses[username] ?? 'none';
  }

  bool isSendingInterest(String username) {
    return _sendingInterest.contains(username);
  }

  bool isCancellingRequest(String username) {
    return _cancellingRequest.contains(username);
  }

  Future<bool> sendInterest(String username) async {
    if (_sendingInterest.contains(username)) return false;

    _sendingInterest.add(username);
    notifyListeners();

    debugPrint('[CONNECTION] Sending interest to: $username');

    final response = await _repository.sendConnectionRequest(username);

    _sendingInterest.remove(username);

    if (response.success) {
      _connectionStatuses[username] = 'pending';
    }

    notifyListeners();
    return response.success;
  }

  Future<bool> cancelConnectionRequest(String username) async {
    if (_cancellingRequest.contains(username)) return false;

    _cancellingRequest.add(username);
    notifyListeners();

    debugPrint('[CONNECTION] Cancelling request for: $username');

    final response = await _repository.cancelRequest(
      targetUsername: username,
      type: 'connection',
    );

    _cancellingRequest.remove(username);

    if (response.success) {
      _connectionStatuses[username] = 'none';
    }

    notifyListeners();
    return response.success;
  }

  Future<void> fetchStatus(String username) async {
    debugPrint('[CONNECTION] Fetching status for: $username');

    final response = await _repository.getConnectionStatus(username);

    if (response.success && response.data != null) {
      final data = response.data!;
      _connectionStatuses[username] = data['friendStatus'] ?? 'none';

      debugPrint(
        '[CONNECTION] Status for $username: friend=${data['friendStatus']}',
      );
      notifyListeners();
    }
  }

  void updateStatusesFromFeed(List<dynamic> users) {
    bool changed = false;
    for (final user in users) {
      if (user.username.isNotEmpty) {
        if (user.connectionStatus != null) {
          _connectionStatuses[user.username] = user.connectionStatus!;
          changed = true;
        }
      }
    }

    if (changed) {
      debugPrint('[CONNECTION] Updated statuses from feed data');
      notifyListeners();
    }
  }

  void reset() {
    _connectionStatuses.clear();
    _sendingInterest.clear();
    _cancellingRequest.clear();
    notifyListeners();
  }
}
