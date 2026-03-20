import 'package:get_it/get_it.dart';
import 'package:saver_expense_manager/app/app.dart';

final GetIt getIt = GetIt.instance;

void setupServiceLocator() {
  getIt
    ..registerLazySingleton<AuthenticationService>(AuthenticationService.new)
    ..registerLazySingleton<DatabaseService>(DatabaseService.new)
    ..registerLazySingleton<LocalStorageService>(LocalStorageService.new)
    ..registerLazySingleton<RemoteStorageService>(RemoteStorageService.new)
    ..registerLazySingleton<RemoteConfigService>(RemoteConfigService.new)
    ..registerLazySingleton<PerformanceService>(PerformanceService.new)
    ..registerLazySingleton<AiService>(
      () => AiService(
        remoteConfig: getIt<RemoteConfigService>(),
        authentication: getIt<AuthenticationService>(),
      ),
    );
}
