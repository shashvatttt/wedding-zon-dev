import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/api_response.dart';
import '../../../core/services/api_service.dart';

class ConnectionsRepository {
  final ApiService _apiService;

  ConnectionsRepository(this._apiService);

  Future<ApiResponse<Map<String, dynamic>>> sendConnectionRequest(
    String targetUsername,
  ) async {
    try {
      debugPrint(
        'Calling POST ${AppConstants.connectionsSend} for $targetUsername',
      );
      final response = await _apiService.dio.post(
        AppConstants.connectionsSend,
        data: {'targetUsername': targetUsername},
        options: Options(extra: {'withCredentials': true}),
      );
      debugPrint(
        'SendRequest Response: ${response.statusCode} - ${response.data}',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse(success: true, data: response.data['data']);
      }

      return _error(response);
    } on DioException catch (e) {
      debugPrint('SendRequest Error: ${e.message} - ${e.response?.data}');
      return _dioError(e);
    }
  }

  Future<ApiResponse<void>> acceptConnection(String requestId) async {
    try {
      debugPrint(
        'Calling POST ${AppConstants.connectionsAccept} for $requestId',
      );
      final response = await _apiService.dio.post(
        AppConstants.connectionsAccept,
        data: {'requestId': requestId},
        options: Options(extra: {'withCredentials': true}),
      );
      debugPrint('AcceptConnection Response: ${response.statusCode}');

      return response.statusCode == 200
          ? ApiResponse(success: true)
          : _error(response);
    } on DioException catch (e) {
      debugPrint('AcceptConnection Error: ${e.message} - ${e.response?.data}');
      return _dioError(e);
    }
  }

  Future<ApiResponse<void>> rejectConnection(String requestId) async {
    try {
      final response = await _apiService.dio.post(
        AppConstants.connectionsReject,
        data: {'requestId': requestId},
        options: Options(extra: {'withCredentials': true}),
      );

      return response.statusCode == 200
          ? ApiResponse(success: true)
          : _error(response);
    } on DioException catch (e) {
      return _dioError(e);
    }
  }

  Future<ApiResponse<void>> cancelRequest({
    required String targetUsername,
    required String type,
  }) async {
    try {
      debugPrint(
        'Calling POST ${AppConstants.connectionsCancel} for $targetUsername type: $type',
      );
      final response = await _apiService.dio.post(
        AppConstants.connectionsCancel,
        data: {'targetUsername': targetUsername, 'type': type},
        options: Options(extra: {'withCredentials': true}),
      );
      debugPrint('CancelRequest Response: ${response.statusCode}');

      return response.statusCode == 200
          ? ApiResponse(success: true)
          : _error(response);
    } on DioException catch (e) {
      debugPrint('CancelRequest Error: ${e.message} - ${e.response?.data}');
      return _dioError(e);
    }
  }

  Future<ApiResponse<String>> requestPhotoAccess(String targetUsername) async {
    try {
      final response = await _apiService.dio.post(
        AppConstants.connectionsRequestPhotoAccess,
        data: {'targetUsername': targetUsername},
        options: Options(extra: {'withCredentials': true}),
      );

      if (response.statusCode == 200) {
        final status =
            response.data['data']?['status'] ??
            response.data['status'] ??
            'pending';
        return ApiResponse(
          success: true,
          data: status,
          message: response.data['message'],
        );
      }

      return _error(response);
    } on DioException catch (e) {
      return _dioError(e);
    }
  }

  Future<ApiResponse<void>> requestDetailsAccess(String targetUsername) async {
    try {
      final response = await _apiService.dio.post(
        AppConstants.connectionsRequestDetailsAccess,
        data: {'targetUsername': targetUsername},
        options: Options(extra: {'withCredentials': true}),
      );

      return response.statusCode == 200
          ? ApiResponse(success: true)
          : _error(response);
    } on DioException catch (e) {
      return _dioError(e);
    }
  }

  Future<ApiResponse<void>> respondPhotoRequest({
    required String requestId,
    required String action,
  }) async {
    try {
      final response = await _apiService.dio.post(
        AppConstants.connectionsRespondPhoto,
        data: {'requestId': requestId, 'action': action},
        options: Options(extra: {'withCredentials': true}),
      );

      return response.statusCode == 200
          ? ApiResponse(success: true)
          : _error(response);
    } on DioException catch (e) {
      return _dioError(e);
    }
  }

  Future<ApiResponse<void>> respondDetailsRequest({
    required String requestId,
    required String action,
  }) async {
    try {
      final response = await _apiService.dio.post(
        AppConstants.connectionsRespondDetails,
        data: {'requestId': requestId, 'action': action},
        options: Options(extra: {'withCredentials': true}),
      );

      return response.statusCode == 200
          ? ApiResponse(success: true)
          : _error(response);
    } on DioException catch (e) {
      return _dioError(e);
    }
  }

  Future<ApiResponse<List<dynamic>>> getIncomingRequests() async {
    try {
      debugPrint('Calling GET ${AppConstants.connectionsRequests}');
      final response = await _apiService.dio.get(
        AppConstants.connectionsRequests,
        options: Options(extra: {'withCredentials': true}),
      );
      debugPrint('GetIncomingRequests Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        debugPrint('Incoming Requests Data: ${response.data['data']}');
        return ApiResponse(success: true, data: response.data['data'] ?? []);
      }

      return _error(response);
    } on DioException catch (e) {
      debugPrint(
        'GetIncomingRequests Error: ${e.message} - ${e.response?.data}',
      );
      return _dioError(e);
    }
  }

  Future<ApiResponse<List<dynamic>>> getSentRequests() async {
    try {
      debugPrint('Calling GET ${AppConstants.connectionsSent}');
      final response = await _apiService.dio.get(
        AppConstants.connectionsSent,
        options: Options(extra: {'withCredentials': true}),
      );
      debugPrint('GetSentRequests Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        debugPrint('Sent Requests Data: ${response.data['data']}');
        return ApiResponse(success: true, data: response.data['data'] ?? []);
      }

      return _error(response);
    } on DioException catch (e) {
      debugPrint('GetSentRequests Error: ${e.message} - ${e.response?.data}');
      return _dioError(e);
    }
  }

  Future<ApiResponse<List<dynamic>>> getMyConnections() async {
    try {
      debugPrint(
        '🟢 [CONNECTIONS] Calling GET ${AppConstants.connectionsMyConnections}',
      );
      final response = await _apiService.dio.get(
        AppConstants.connectionsMyConnections,
        options: Options(extra: {'withCredentials': true}),
      );

      debugPrint(
        '🟢 [CONNECTIONS] GetMyConnections Response: ${response.statusCode}',
      );
      debugPrint('🟢 [CONNECTIONS] Response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? [];
        debugPrint(
          '✅ [CONNECTIONS] Successfully fetched ${data.length} connections',
        );
        if (data.isEmpty) {
          debugPrint('⚠️ [CONNECTIONS] WARNING: API returned 0 connections');
        }
        return ApiResponse(success: true, data: data);
      }

      debugPrint('❌ [CONNECTIONS] Failed with status: ${response.statusCode}');
      return _error(response);
    } on DioException catch (e) {
      debugPrint('❌ [CONNECTIONS] DioException: ${e.message}');
      debugPrint('❌ [CONNECTIONS] Response: ${e.response?.data}');
      return _dioError(e);
    }
  }

  Future<ApiResponse<List<dynamic>>> getNotifications() async {
    try {
      final response = await _apiService.dio.get(
        AppConstants.connectionsNotifications,
        options: Options(extra: {'withCredentials': true}),
      );

      if (response.statusCode == 200) {
        return ApiResponse(success: true, data: response.data['data'] ?? []);
      }

      return _error(response);
    } on DioException catch (e) {
      return _dioError(e);
    }
  }

  Future<ApiResponse<Map<String, String>>> getConnectionStatus(
    String username,
  ) async {
    try {
      final response = await _apiService.dio.get(
        '${AppConstants.connectionsStatus}/$username',
        options: Options(extra: {'withCredentials': true}),
      );

      if (response.statusCode == 200) {
        return ApiResponse(
          success: true,
          data: {
            'photoStatus': response.data['status']?.toString() ?? 'none',
            'friendStatus': response.data['friendStatus']?.toString() ?? 'none',
            'detailsStatus':
                response.data['detailsStatus']?.toString() ?? 'none',
          },
        );
      }

      return _error(response);
    } on DioException catch (e) {
      return _dioError(e);
    }
  }

  Future<ApiResponse<void>> removeConnection(String targetUsername) async {
    try {
      final response = await _apiService.dio.delete(
        AppConstants.connectionsRemove,
        data: {'targetUsername': targetUsername},
        options: Options(extra: {'withCredentials': true}),
      );

      return response.statusCode == 200
          ? ApiResponse(success: true)
          : _error(response);
    } on DioException catch (e) {
      return _dioError(e);
    }
  }

  Future<ApiResponse<void>> blockUser(String targetUserId) async {
    try {
      final response = await _apiService.dio.post(
        AppConstants.usersBlock,
        data: {'targetUserId': targetUserId},
        options: Options(extra: {'withCredentials': true}),
      );

      return response.statusCode == 200
          ? ApiResponse(success: true)
          : _error(response);
    } on DioException catch (e) {
      return _dioError(e);
    }
  }

  Future<ApiResponse<void>> reportUser({
    required String targetUserId,
    required String reason,
    String? description,
  }) async {
    try {
      final response = await _apiService.dio.post(
        AppConstants.usersReport,
        data: {
          'targetUserId': targetUserId,
          'reason': reason,
          'description': description,
        },
        options: Options(extra: {'withCredentials': true}),
      );

      return response.statusCode == 200
          ? ApiResponse(success: true)
          : _error(response);
    } on DioException catch (e) {
      return _dioError(e);
    }
  }

  ApiResponse<T> _error<T>(Response response) {
    String message = 'Request failed';

    if (response.data is Map<String, dynamic>) {
      message = response.data['message'] ?? message;
    } else if (response.data is String) {
      message = response.data;
    }

    return ApiResponse(success: false, message: message);
  }

  ApiResponse<T> _dioError<T>(DioException e) {
    String? serverMessage;
    if (e.response?.data is Map) {
      serverMessage = e.response?.data['message']?.toString();
    }

    return ApiResponse(
      success: false,
      message: serverMessage ?? e.message ?? 'Network error',
    );
  }
}
