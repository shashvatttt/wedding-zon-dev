import 'package:flutter/material.dart';
import '../repositories/connections_repository.dart';
import '../../../core/services/toast_service.dart';

class ConnectionsProvider with ChangeNotifier {
  final ConnectionsRepository _repository;

  ConnectionsProvider(this._repository);

  List<Map<String, dynamic>> _incomingRequests = [];
  final List<Map<String, dynamic>> _sentRequests = [];
  List<Map<String, dynamic>> _myConnections = [];
  bool _isLoading = false;
  final bool _isLoadingSent = false;
  bool _isLoadingConnections = false;
  String? _error;

  final Map<String, Map<String, String>> _statusCache = {};

  final Map<String, bool> _requestingStates = {};
  final Map<String, bool> _requestingDetailsStates = {};
  final Map<String, bool> _sendingInterestStates = {};
  final Map<String, bool> _cancellingStates = {};

  List<Map<String, dynamic>> get incomingRequests => _incomingRequests;
  List<Map<String, dynamic>> get sentRequests => _sentRequests;
  List<Map<String, dynamic>> get myConnections => _myConnections;
  bool get isLoading => _isLoading;
  bool get isLoadingSent => _isLoadingSent;
  bool get isLoadingConnections => _isLoadingConnections;

  String getStatus(String username) {
    return _statusCache[username]?['photoStatus'] ?? 'none';
  }

  String getConnectionStatus(String username) {
    return _statusCache[username]?['friendStatus'] ?? 'none';
  }

  String getDetailsStatus(String username) {
    return _statusCache[username]?['detailsStatus'] ?? 'none';
  }

  bool getCanViewPhotos(String username) {
    return getStatus(username) == 'granted';
  }

  bool getCanViewDetails(String username) {
    return getDetailsStatus(username) == 'granted';
  }

  bool isRequesting(String username) {
    return _requestingStates[username] ?? false;
  }

  bool isRequestingDetails(String username) {
    return _requestingDetailsStates[username] ?? false;
  }

  bool isSendingInterest(String username) {
    return _sendingInterestStates[username] ?? false;
  }

  bool isCancellingRequest(String username) {
    return _cancellingStates[username] ?? false;
  }

  Future<void> fetchStatus(String username) async {
    try {
      final response = await _repository.getConnectionStatus(username);
      debugPrint(
        '[ConnectionsProvider] fetchStatus for $username - success: ${response.success}, data: ${response.data}',
      );

      if (response.success && response.data != null) {
        _statusCache[username] = response.data!;
        debugPrint(
          '[ConnectionsProvider] Cached status for $username: ${response.data}',
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[ConnectionProvider] Error fetching status: $e');
    }
  }

  Future<bool> sendInterest(String username) async {
    _sendingInterestStates[username] = true;
    notifyListeners();

    final response = await _repository.sendConnectionRequest(username);

    if (response.success) {
      _statusCache[username] = {
        ...?_statusCache[username],
        'friendStatus': 'pending',
      };
    }

    _sendingInterestStates[username] = false;
    notifyListeners();
    return response.success;
  }

  Future<void> cancelConnectionRequest(String username) async {
    _cancellingStates[username] = true;
    notifyListeners();

    final response = await _repository.cancelRequest(
      targetUsername: username,
      type: 'connection',
    );

    if (response.success) {
      _statusCache[username] = {
        ...?_statusCache[username],
        'friendStatus': 'none',
      };
    }

    _cancellingStates[username] = false;
    if (response.success) {
      _sentRequests.removeWhere(
        (r) =>
            r['toUser']?['username'] == username &&
            (r['type'] == 'connection' || r['type'] == null),
      );
    }
    notifyListeners();
  }

  Future<void> requestAccess(String username) async {
    _requestingStates[username] = true;
    notifyListeners();

    final response = await _repository.requestPhotoAccess(username);

    if (response.success) {
      _statusCache[username] = {
        ...?_statusCache[username],
        'photoStatus': response.data ?? 'pending',
      };
    } else {
      toast.error(response.message ?? 'Failed to request access');
    }

    _requestingStates[username] = false;
    notifyListeners();
  }

  Future<void> cancelPhotoAccessRequest(String username) async {
    _cancellingStates[username] = true;
    notifyListeners();

    final response = await _repository.cancelRequest(
      targetUsername: username,
      type: 'photo',
    );

    if (response.success) {
      _statusCache[username] = {
        ...?_statusCache[username],
        'photoStatus': 'none',
      };
    } else {
      toast.error(response.message ?? 'Failed to cancel request');
    }

    _cancellingStates[username] = false;
    if (response.success) {
      _sentRequests.removeWhere(
        (r) => r['toUser']?['username'] == username && r['type'] == 'photo',
      );
    }
    notifyListeners();
  }

  Future<void> requestDetailsAccess(String username) async {
    _requestingDetailsStates[username] = true;
    notifyListeners();

    final response = await _repository.requestDetailsAccess(username);

    if (response.success) {
      _statusCache[username] = {
        ...?_statusCache[username],
        'detailsStatus': 'pending',
      };
    } else {
      toast.error(response.message ?? 'Failed to request details access');
    }

    _requestingDetailsStates[username] = false;
    notifyListeners();
  }

  Future<void> cancelDetailsAccessRequest(String username) async {
    _cancellingStates[username] = true;
    notifyListeners();

    final response = await _repository.cancelRequest(
      targetUsername: username,
      type: 'details',
    );

    if (response.success) {
      _statusCache[username] = {
        ...?_statusCache[username],
        'detailsStatus': 'none',
      };
    } else {
      toast.error(response.message ?? 'Failed to cancel request');
    }

    _cancellingStates[username] = false;
    if (response.success) {
      _sentRequests.removeWhere(
        (r) => r['toUser']?['username'] == username && r['type'] == 'details',
      );
    }
    notifyListeners();
  }

  Future<void> loadSentRequests() async {
    debugPrint('🔵 [CONNECTIONS] loadSentRequests() called');
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _repository.getSentRequests();
      debugPrint(
        '🔵 [CONNECTIONS] getSentRequests() response: success=${response.success}, data length=${response.data?.length}',
      );

      if (response.success && response.data != null) {
        final List<dynamic> data = response.data!;
        _sentRequests.clear();
        _sentRequests.addAll(List<Map<String, dynamic>>.from(data));
        debugPrint(
          '✅ [CONNECTIONS] Loaded ${_sentRequests.length} sent requests',
        );
      } else {
        _sentRequests.clear();
        debugPrint(
          '❌ [CONNECTIONS] Failed to load sent requests: ${response.message}',
        );
      }
    } catch (e) {
      debugPrint('❌ [CONNECTIONS] Error loading sent requests: $e');
      _sentRequests.clear();
    }

    _isLoading = false;
    notifyListeners();
    debugPrint('🔵 [CONNECTIONS] loadSentRequests() completed');
  }

  Future<void> loadIncomingRequests() async {
    debugPrint('🟢 [CONNECTIONS] loadIncomingRequests() called');
    _isLoading = true;
    notifyListeners();

    final response = await _repository.getIncomingRequests();
    debugPrint(
      '🟢 [CONNECTIONS] getIncomingRequests() response: success=${response.success}, data length=${response.data?.length}',
    );

    if (response.success && response.data != null) {
      _incomingRequests = List<Map<String, dynamic>>.from(response.data!);
      debugPrint(
        '✅ [CONNECTIONS] Loaded ${_incomingRequests.length} incoming requests',
      );
    } else {
      _incomingRequests = [];
      toast.error(response.message ?? 'Failed to load requests');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> accept(String requestId) async {
    _isLoading = true;
    notifyListeners();

    final response = await _repository.acceptConnection(requestId);

    if (response.success) {
      toast.success('Connection accepted');
      _incomingRequests.removeWhere((r) => r['_id'] == requestId);
    } else {
      toast.error(response.message ?? 'Failed to accept');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> reject(String requestId) async {
    _isLoading = true;
    notifyListeners();

    final response = await _repository.rejectConnection(requestId);

    if (response.success) {
      toast.success('Connection rejected');
      _incomingRequests.removeWhere((r) => r['_id'] == requestId);
    } else {
      toast.error(response.message ?? 'Failed to reject');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> respondPhotoRequest(String requestId, String action) async {
    _isLoading = true;
    notifyListeners();

    final response = await _repository.respondPhotoRequest(
      requestId: requestId,
      action: action,
    );

    if (response.success) {
      final actionText = action == 'grant' ? 'granted' : 'denied';
      _incomingRequests.removeWhere((r) => r['_id'] == requestId);
    } else {
      toast.error(response.message ?? 'Failed to respond to photo request');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> respondDetailsRequest(String requestId, String action) async {
    _isLoading = true;
    notifyListeners();

    final response = await _repository.respondDetailsRequest(
      requestId: requestId,
      action: action,
    );

    if (response.success) {
      final actionText = action == 'grant' ? 'granted' : 'denied';
      _incomingRequests.removeWhere((r) => r['_id'] == requestId);
    } else {
      toast.error(response.message ?? 'Failed to respond to details request');
    }

    _isLoading = false;
    notifyListeners();
    _isLoading = false;
    notifyListeners();
  }

  void handleRealTimeRequest(Map<String, dynamic> data) {
    debugPrint('[ConnectionsProvider] Handling real-time request: $data');

    final requestId = data['requestId'] ?? data['_id'];
    if (requestId != null &&
        _incomingRequests.any((r) => r['_id'] == requestId)) {
      debugPrint(
        '[ConnectionsProvider] Request already exists, skipping: $requestId',
      );
      return;
    }

    loadIncomingRequests();

    notifyListeners();
  }

  Future<void> loadMyConnections() async {
    _isLoadingConnections = true;
    notifyListeners();

    final response = await _repository.getMyConnections();

    if (response.success && response.data != null) {
      final rawList = List<Map<String, dynamic>>.from(response.data!);
      final seenIds = <String>{};
      _myConnections = rawList
          .where((u) => seenIds.add(u['_id'] ?? u['username']))
          .toList();
    } else {
      _myConnections = [];
      toast.error(response.message ?? 'Failed to load connections');
    }

    _isLoadingConnections = false;
    notifyListeners();
  }

  Future<void> removeConnection(String username) async {
    _cancellingStates[username] = true;
    notifyListeners();

    final response = await _repository.removeConnection(username);

    if (response.success) {
      toast.success('Connection removed successfully');
      _statusCache[username] = {
        ...?_statusCache[username],
        'friendStatus': 'none',
      };

      _myConnections.removeWhere((conn) => conn['username'] == username);
    } else {
      toast.error(response.message ?? 'Failed to remove connection');
    }

    _cancellingStates[username] = false;
    notifyListeners();
  }

  Future<void> blockUser(String targetUserId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _repository.blockUser(targetUserId);

      if (response.success) {
        toast.success('User blocked successfully');
      } else {
        _error = response.message;
        toast.error(_error ?? 'Failed to block user');
      }
    } catch (e) {
      _error = e.toString();
      toast.error('An error occurred');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> reportUser(
    String targetUserId,
    String reason,
    String? description,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _repository.reportUser(
        targetUserId: targetUserId,
        reason: reason,
        description: description,
      );

      if (response.success) {
        toast.success('User reported successfully');
      } else {
        _error = response.message;
        toast.error(_error ?? 'Failed to report user');
      }
    } catch (e) {
      _error = e.toString();
      toast.error('An error occurred');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
