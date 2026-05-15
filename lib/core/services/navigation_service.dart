import 'package:flutter/material.dart';

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<dynamic> navigateTo(String routeName, {Object? arguments}) {
    debugPrint('[NAV] navigateTo: $routeName');
    return navigatorKey.currentState!.pushNamed(
      routeName,
      arguments: arguments,
    );
  }

  Future<dynamic> navigateToReplacement(String routeName, {Object? arguments}) {
    debugPrint('[NAV] navigateToReplacement: $routeName');
    return navigatorKey.currentState!.pushReplacementNamed(
      routeName,
      arguments: arguments,
    );
  }

  void goBack() {
    debugPrint('[NAV] goBack');
    return navigatorKey.currentState!.pop();
  }

  Future<dynamic> pushNamedAndRemoveUntil(
    String routeName, {
    Object? arguments,
  }) {
    debugPrint('[NAV] pushNamedAndRemoveUntil: $routeName');
    return navigatorKey.currentState!.pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  Future<dynamic> navigateFromNotification(
    String targetRoute, {
    Object? arguments,
    String homeRoute = '/shell',
  }) {
    debugPrint('[NAV] navigateFromNotification: $targetRoute');
    debugPrint('[NAV] Ensuring home route exists: $homeRoute');

    final navigator = navigatorKey.currentState;
    if (navigator == null) {
      debugPrint('[NAV] ERROR: Navigator not available');
      return Future.value();
    }

    final hasRoutes = navigator.canPop();

    if (!hasRoutes) {
      debugPrint('[NAV] No routes in stack, pushing home then target');
      return navigator
          .pushNamedAndRemoveUntil(homeRoute, (route) => false)
          .then((_) {
            return navigator.pushNamed(targetRoute, arguments: arguments);
          });
    } else {
      debugPrint('[NAV] Routes exist, navigating to target');
      return navigator.pushNamed(targetRoute, arguments: arguments);
    }
  }

  Future<dynamic> navigateAndClearStack(
    String targetRoute, {
    Object? arguments,
    String homeRoute = '/shell',
  }) {
    debugPrint('[NAV] navigateAndClearStack: $targetRoute');

    final navigator = navigatorKey.currentState;
    if (navigator == null) {
      debugPrint('[NAV] ERROR: Navigator not available');
      return Future.value();
    }

    return navigator.pushNamedAndRemoveUntil(homeRoute, (route) => false).then((
      _,
    ) {
      return navigator.pushNamed(targetRoute, arguments: arguments);
    });
  }
}
