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
    initialLocation: RouterConstants.homeRoute,
    // First-launch gate: until onboarding is completed, force users onto it.
    redirect: (BuildContext context, GoRouterState state) {
      final bool completed = appLocator<OnboardingService>().isCompleted;
      final bool goingToOnboarding = state.matchedLocation == RouterConstants.onboardingRoute;

      if (!completed && !goingToOnboarding) {
        return RouterConstants.onboardingRoute;
      }
      if (completed && goingToOnboarding) {
        return RouterConstants.homeRoute;
      }
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: RouterConstants.onboardingRoute,
        name: RouterConstants.onboardingRoute,
        builder: (BuildContext context, GoRouterState state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: RouterConstants.homeRoute,
        name: RouterConstants.homeRoute,
        builder: (BuildContext context, GoRouterState state) => const HomeScreen(),
      ),
      GoRoute(
        path: RouterConstants.settingsRoute,
        name: RouterConstants.settingsRoute,
        builder: (BuildContext context, GoRouterState state) => const SettingsScreen(),
      ),
      // Dev-only screens
      GoRoute(
        path: RouterConstants.showcaseRoute,
        name: RouterConstants.showcaseRoute,
        builder: (BuildContext context, GoRouterState state) => const ShowcaseScreen(),
      ),
      GoRoute(
        path: RouterConstants.exampleRoute,
        name: RouterConstants.exampleRoute,
        builder: (BuildContext context, GoRouterState state) => const ExampleScreen(),
      ),
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