import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Export features to access all screens
export 'package:features/features.dart';

export '../services/screen_logs_route_observer.dart';
export 'router_constants.dart';

final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  GoRouter get router => _router;

  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  final GoRouter _router = GoRouter(
    navigatorKey: _navigatorKey,
    observers: <NavigatorObserver>[ScreenLogsRouteObserver()],
    initialLocation: RouterConstants.exampleRoute,
    routes: <RouteBase>[
      GoRoute(
        path: RouterConstants.exampleRoute,
        name: RouterConstants.exampleRoute,
        builder: (BuildContext context, GoRouterState state) => const ExampleScreen(),
      ),
      // TODO: Add more routes here
    ],
    errorBuilder: (BuildContext context, GoRouterState state) {
      return Scaffold(
        body: Center(
          child: Text('Error: ${state.error}'),
        ),
      );
    },
  );
}