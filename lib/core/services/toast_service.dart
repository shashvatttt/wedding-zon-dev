import 'package:flutter/material.dart';
import '../../shared/widgets/wz_toast.dart';

class ToastService {
  static final ToastService _instance = ToastService._internal();
  factory ToastService() => _instance;
  ToastService._internal();

  static GlobalKey<NavigatorState>? _navigatorKey;

  static void initialize(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
  }

  BuildContext? get _context => _navigatorKey?.currentContext;

  void show(String message, {Duration? duration}) {
    final context = _context;
    if (context == null) {
      debugPrint(
        '[TOAST_SERVICE] ⚠️ Context not available, cannot show toast: $message',
      );
      return;
    }

    WzToast.show(
      context,
      message: message,
      type: WzToastType.normal,
      duration: duration ?? const Duration(seconds: 3),
    );
  }

  void success(String message, {Duration? duration}) {
    final context = _context;
    if (context == null) {
      debugPrint(
        '[TOAST_SERVICE] ⚠️ Context not available, cannot show toast: $message',
      );
      return;
    }

    WzToast.show(
      context,
      message: message,
      type: WzToastType.success,
      duration: duration ?? const Duration(seconds: 3),
    );
  }

  void error(String message, {Duration? duration}) {
    final context = _context;
    if (context == null) {
      debugPrint(
        '[TOAST_SERVICE] ⚠️ Context not available, cannot show toast: $message',
      );
      return;
    }

    WzToast.show(
      context,
      message: message,
      type: WzToastType.error,
      duration: duration ?? const Duration(seconds: 3),
    );
  }
}

final toast = ToastService();
