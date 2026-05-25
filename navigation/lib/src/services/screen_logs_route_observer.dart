import 'package:core/core.dart';
import 'package:flutter/material.dart';

class ScreenLogsRouteObserver extends AutoRouteObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    AppLogger.debug('Route pushed: ${route.settings.name}');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    AppLogger.debug('Route popped: ${route.settings.name}');
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    AppLogger.debug('Route removed: ${route.settings.name}');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    AppLogger.debug(
      'Route replaced: ${oldRoute?.settings.name} -> ${newRoute?.settings.name}',
    );
  }
}
