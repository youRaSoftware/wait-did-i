import 'dart:async';

import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:get_it/get_it.dart';
import 'package:navigation/navigation.dart';

import '../config/app_config.dart';
import '../config/network/dio_config.dart';

// Shared GetIt instance - used across all packages
final GetIt appLocator = GetIt.instance;

// Scope names for lifecycle management
const String unauthScope = 'unauthScope';
const String authScope = 'authScope';

// SINGLE ENTRY POINT: Called from main_common.dart
Future<void> setupUnAuthScope(Flavor flavor) async {
  final Completer<void> completer = Completer<void>();

  appLocator.pushNewScope(
    scopeName: unauthScope,
    init: (_) async {
      // 1. Register app configuration (based on flavor)
      appLocator.registerSingleton<AppConfig>(AppConfig.fromFlavor(flavor));

      // 2. Register router
      appLocator.registerLazySingleton<AppRouter>(AppRouter.new);

      // 3. Register network
      appLocator.registerLazySingleton<DioConfig>(
        () => DioConfig(appConfig: appLocator<AppConfig>()),
      );

      // 4. Initialize base services (core services)
      _initBaseServices();

      // 5. Initialize data layer (pre-login dependencies)
      await dataDI.preLoginScope();

      // 6. Initialize main domain service (entry point service)
      // This service will initialize other dependent services
      await ExampleService.instance.initialize;

      completer.complete();
    },
  );

  return completer.future;
}

void _initBaseServices() {
  // Register core services that don't depend on authentication
  // Add other base services here as needed
  // appLocator.registerSingleton<ConnectivityService>(ConnectivityService.instance);
  // appLocator.registerLazySingleton<ToastService>(ToastService.new);
}

// Called by services (like AuthService) when user logs in
Future<void> goToAuthScope() async {
  appLocator.pushNewScope(
    scopeName: authScope,
    init: (_) {
      // Initialize post-login dependencies
      dataDI.postLoginScope();
    },
  );
}

// Called by services (like AuthService) when user logs out
Future<void> dropAuthScope() async {
  await appLocator.dropScope(authScope);
}
