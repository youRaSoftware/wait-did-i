import 'package:core/core.dart';
import 'package:domain/domain.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import '../entities/checklist_entity.dart';
import '../hive/hive_registrar.g.dart';
import '../providers/api/api_providers.dart';
import '../providers/hive/checklist_hive_provider.dart';
import '../repositories/repositories.dart';

final DataDI dataDI = DataDI();

class DataDI {
  // Called from app_di.dart setupUnAuthScope() -> pre-login initialization
  Future<void> preLoginScope() async {
    await _initLocalStorage();
    _initApi();
    _initRepositories();
  }

  // Called from app_di.dart goToAuthScope() -> post-login initialization
  Future<void> postLoginScope() async {
    // Register post-login dependencies here
    // Example: User-specific API clients, authenticated repositories
  }

  Future<void> _initLocalStorage() async {
    await Hive.initFlutter();
    Hive.registerAdapters();
    final Box<ChecklistEntity> checklistBox = await Hive.openBox<ChecklistEntity>('checklists');
    final Box<dynamic> metaBox = await Hive.openBox<dynamic>('app_meta');
    appLocator.registerSingleton<ChecklistHiveProvider>(
      ChecklistHiveProvider(box: checklistBox, metaBox: metaBox),
    );
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
    appLocator.registerLazySingleton<ChecklistRepository>(
      () => ChecklistRepositoryImpl(provider: appLocator<ChecklistHiveProvider>()),
    );
    appLocator.registerLazySingleton<ExampleRepository>(
      () => ExampleRepositoryImpl(
        apiProvider: appLocator<ExampleApiProvider>(),
      ),
    );
  }
}
