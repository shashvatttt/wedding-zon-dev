import 'package:flutter/material.dart';
import '../services/logging_service.dart';

class AppNavigationObserver extends NavigatorObserver {
  final LoggingService _logger = LoggingService();

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    final logMessage =
        'Pushed route: ${route.settings.name} (args: ${route.settings.arguments})';
    _logger.logNavigation(logMessage);
    debugPrint('[NAV_DEBUG] $logMessage');
    if (previousRoute != null) {
      debugPrint('[NAV_DEBUG]   FROM: ${previousRoute.settings.name}');
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    final logMessage = 'Popped route: ${route.settings.name}';
    _logger.logNavigation(logMessage);
    debugPrint('[NAV_DEBUG] $logMessage');
    if (previousRoute != null) {
      debugPrint('[NAV_DEBUG]   TO: ${previousRoute.settings.name}');
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    final logMessage =
        'Replaced route: ${oldRoute?.settings.name} with ${newRoute?.settings.name}';
    _logger.logNavigation(logMessage);
    debugPrint('[NAV_DEBUG] $logMessage');
  }
}
