import 'package:get_it/get_it.dart';
import 'package:saver_expense_manager/app/app.dart';

final GetIt getIt = GetIt.instance;

void setupServiceLocator() {
  getIt
    ..registerLazySingleton<RemoteStorageService>(RemoteStorageService.new)
    ..registerLazySingleton<AuthenticationService>(AuthenticationService.new)
    ..registerLazySingleton<RemoteConfigService>(RemoteConfigService.new)
    ..registerLazySingleton<LocalStorageService>(LocalStorageService.new)
    ..registerLazySingleton<AiService>(
      () => AiService(remoteConfig: getIt<RemoteConfigService>()),
    );
}
