import 'package:core/core.dart';
import 'package:domain/domain.dart';
import '../providers/api/api_providers.dart';
import '../repositories/repositories.dart';

final DataDI dataDI = DataDI();

class DataDI {
  // Called from app_di.dart setupUnAuthScope() -> pre-login initialization
  Future<void> preLoginScope() async {
    // Local storage initialization (Hive/Drift) - add if needed
    // await _initLocalStorage();
    _initApi();
    _initRepositories();
  }

  // Called from app_di.dart goToAuthScope() -> post-login initialization
  Future<void> postLoginScope() async {
    // Register post-login dependencies here
    // Example: User-specific API clients, authenticated repositories
  }

  void _initApi() {
    // Register API providers
    // Note: DioConfig is registered in app_di.dart, not here
    appLocator.registerLazySingleton<ExampleApiProvider>(
      () => ExampleApiProvider(appLocator<DioConfig>().dio),
    );
  }

  void _initRepositories() {
    // Register repository implementations
    // They combine API providers and local providers
    appLocator.registerLazySingleton<ExampleRepository>(
      () => ExampleRepositoryImpl(
        apiProvider: appLocator<ExampleApiProvider>(),
      ),
    );
  }
}
